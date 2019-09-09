#include <gtest/gtest.h>
#include <gflags/gflags.h>
#include <bthread/bthread.h>
#include <butil/logging.h>
#include <brpc/server.h>
#include <brpc/channel.h>
#include "echo.pb.h"
#include <bvar/bvar.h>
#include <iostream>
#include <typeinfo>
#include <string>
#include <thread>
#include <mutex> // <----- 互斥锁。
// #include <boost/thread/mutex.hpp>
// #include <boost/thread/thread.hpp>


using namespace std;

DEFINE_int32(thread_num, 50, "Number of threads to send requests");
DEFINE_bool(use_bthread, false, "Use bthread to send requests");
DEFINE_int32(attachment_size, 0, "Carry so many byte attachment along with requests");
DEFINE_int32(request_size, 16, "Bytes of each request");
DEFINE_string(protocol, "baidu_std", "Protocol type. Defined in src/brpc/options.proto");
DEFINE_string(connection_type, "", "Connection type. Available values: single, pooled, short");
DEFINE_string(server, "0.0.0.0:8002", "IP Address of server"); 
DEFINE_string(load_balancer, "", "The algorithm for load balancing");
DEFINE_int32(timeout_ms, 100, "RPC timeout in milliseconds");
DEFINE_int32(max_retry, 3, "Max retries(not including the first RPC)"); 
DEFINE_bool(dont_fail, false, "Print fatal when some call failed");
DEFINE_bool(enable_ssl, false, "Use SSL connection");
DEFINE_int32(dummy_port, -1, "Launch dummy server at this port");

std::string g_request;
std::string g_attachment;
int log_id = 0;
int threads_number = 0;
static int loop_number = 10;
mutex m;

bvar::LatencyRecorder g_latency_recorder("client");
bvar::Adder<int> g_error_count("client_error_count"); 

static void* sender(void* arg) {
    example::EchoService_Stub stub(static_cast<google::protobuf::RpcChannel*>(arg));
    for(int i = 0; i < loop_number; i++) {
        example::EchoRequest request;
        example::EchoResponse response;
        brpc::Controller cntl;

        request.set_message(g_request);
        cntl.set_log_id(log_id++);  // set by user
        // Set attachment which is wired to network directly instead of 
        // being serialized into protobuf messages.
        cntl.request_attachment().append(g_attachment);

        // Because `done'(last parameter) is NULL, this function waits until
        // the response comes back or error occurs(including timedout).
        stub.Echo(&cntl, &request, &response, NULL);
        if (!cntl.Failed()) {
        	m.lock();
        	threads_number++; // <---- 这里要加锁。
        	m.unlock();
            g_latency_recorder << cntl.latency_us();
            // std::cout << "threads_number: " << threads_number << std::endl;
        } else {
        	// threads_number++;
            g_error_count << 1;
            CHECK(brpc::IsAskedToQuit() || !FLAGS_dont_fail) // 查看是否退出，若退出：
                << "error=" << cntl.ErrorText() << " latency=" << cntl.latency_us();
            // bthread_usleep(50000);
        }
        usleep(500);
    }
    return NULL;
}

TEST(server_basic_function, message_and_attachment){
	// 最基础的测试：
	// （1）测试发出的 message 和接收到的 message 是否相同。
	// （2）测试发出的 attachment 和接受到的 attachment 是否相同。
	
	brpc::Channel channel;
	
	brpc::ChannelOptions options;
	options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.connect_timeout_ms = std::min(FLAGS_timeout_ms / 2, 100);
    options.timeout_ms = FLAGS_timeout_ms;
    options.max_retry = FLAGS_max_retry;
    
    channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options);
    example::EchoService_Stub stub(&channel);
		
	example::EchoRequest request;
	example::EchoResponse response;
    brpc::Controller cntl;
    
    g_request = "Hello world!";
    g_attachment = "This is attachment.";
    request.set_message(g_request);
    cntl.request_attachment().append(g_attachment);

    stub.Echo(&cntl, &request, &response, NULL);

    int result_A = g_request.compare(response.message().c_str());
    int result_B = g_attachment.compare(cntl.response_attachment().to_string());

    EXPECT_EQ(0, result_A);
    EXPECT_EQ(0, result_B);
    // EXPECT_EQ(response.message(), g_request); // 这样直接比较也可以，而且更简单。
}

TEST(server_basic_function, different_server){
	// 测试当地址 server 不同时。
	brpc::Channel channel;
	
	brpc::ChannelOptions options;
	options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.connect_timeout_ms = std::min(FLAGS_timeout_ms / 2, 100);
    options.timeout_ms = FLAGS_timeout_ms;
    options.max_retry = FLAGS_max_retry;
    
    FLAGS_server = "0.0.0.1:8003"; // <--------- 更改为不同的地址。
    channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options);
    example::EchoService_Stub stub(&channel);

    example::EchoRequest request;
	example::EchoResponse response;
    brpc::Controller cntl;

    g_request = "Hello world!";
    request.set_message(g_request);

    stub.Echo(&cntl, &request, &response, NULL);
    int result_A = g_request.compare(response.message().c_str());
    EXPECT_NE(0, result_A);
}

TEST(server_basic_function, multi_thread){
	// 测试使用多线程。
	FLAGS_server = "0.0.0.0:8002"; // 这里注意，上一个测试修改了 server 值，这里必须再改回来。
    brpc::Channel channel;
    
    brpc::ChannelOptions options;
    
    options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.connect_timeout_ms = std::min(FLAGS_timeout_ms / 2, 100);
    options.timeout_ms = FLAGS_timeout_ms;
    options.max_retry = FLAGS_max_retry;
    channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options);

    // loop_number = 2;

    // 多线程部分：
    std::vector<pthread_t> pids; // pthread_t。
    FLAGS_thread_num = 100;
	pids.resize(FLAGS_thread_num);
	for (int i = 0; i < FLAGS_thread_num; ++i) {
		pthread_create(&pids[i], NULL, sender, &channel); // 创建线程。
	}
	
	int threads_number_temp = FLAGS_thread_num * loop_number;
	for (int i = 0; i < FLAGS_thread_num; ++i) { // 等待线程运行完主进程再关闭。
		pthread_join(pids[i], NULL);
    }

	EXPECT_EQ(threads_number_temp, threads_number);
}

TEST(server_basic_function, use_ssl){
	brpc::Channel channel;
	
	brpc::ChannelOptions options;
	options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.connect_timeout_ms = std::min(FLAGS_timeout_ms / 2, 100);
    options.timeout_ms = FLAGS_timeout_ms;
    options.max_retry = FLAGS_max_retry;
    options.mutable_ssl_options(); // <----- 添加了这一句，使用 SSL。
    
    channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options);
    example::EchoService_Stub stub(&channel);
		
	example::EchoRequest request;
	example::EchoResponse response;
    brpc::Controller cntl;
    
    g_request = "Use SSL!";
    request.set_message(g_request);

    stub.Echo(&cntl, &request, &response, NULL);

    int result_A = g_request.compare(response.message().c_str());

    EXPECT_EQ(0, result_A);
}

int main(int argc, char *argv[])
{
	GFLAGS_NS::ParseCommandLineFlags(&argc, &argv, true);
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}