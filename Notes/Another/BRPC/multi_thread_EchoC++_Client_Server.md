# multi thread Echo_C++ Client & Server

echo.proto：

```protobuf
syntax="proto2";
option cc_generic_services = true;

package example;

message EchoRequest {
      required string message = 1;
};

message EchoResponse {
      required string message = 1;
};

service EchoService {
      rpc Echo(EchoRequest) returns (EchoResponse);
};
```

client.cpp：

```c++
#include <gflags/gflags.h>
#include <bthread/bthread.h>
#include <butil/logging.h>
#include <brpc/server.h>
#include <brpc/channel.h>
#include "echo.pb.h"
#include <bvar/bvar.h>

// 【TEST】线程数。
DEFINE_int32(thread_num, 50, "Number of threads to send requests");
// 【TODO】使用 bthread 和不适用 bthread 会有区别吗？
DEFINE_bool(use_bthread, false, "Use bthread to send requests");
// attachment 大小，代码中会用字母进行填充。Client 端行为，与 Server 端无关。
DEFINE_int32(attachment_size, 0, "Carry so many byte attachment along with requests");
// 【TODO】请求大小，需查看具体效果。
DEFINE_int32(request_size, 16, "Bytes of each request");
// 【TODO】具体有什么效果？
DEFINE_string(protocol, "baidu_std", "Protocol type. Defined in src/brpc/options.proto");
// 【TODO】尝试三个参数效果。
DEFINE_string(connection_type, "", "Connection type. Available values: single, pooled, short");
// 【TODO】端口号。测试端口号不同时的效果。
DEFINE_string(server, "0.0.0.0:8002", "IP Address of server");
// 【跳过】负载均衡。
DEFINE_string(load_balancer, "", "The algorithm for load balancing");
// 【TODO】每 100 毫秒发送一个 RPC？
DEFINE_int32(timeout_ms, 100, "RPC timeout in milliseconds");
// 【TODO】这个参数在哪里用的？
DEFINE_int32(max_retry, 3, "Max retries(not including the first RPC)"); 
// 【TEST】是否当请求失败时打印错误信息并退出？
DEFINE_bool(dont_fail, false, "Print fatal when some call failed");
// 【跳过】
DEFINE_bool(enable_ssl, false, "Use SSL connection");
// 【TODO】似乎是单机模式。需要进行尝试。
DEFINE_int32(dummy_port, -1, "Launch dummy server at this port");

std::string g_request;
std::string g_attachment;

// bvar::LatencyRecorder : 专用于记录延时和 qps 的变量。输入延时，平均延时/最大延时/qps/总次数 都有了。
bvar::LatencyRecorder g_latency_recorder("client");
// bvar::Adder : 计数器，默认0，varname << N相当于varname += N。
bvar::Adder<int> g_error_count("client_error_count");

static void* sender(void* arg) {
    
    // 打桩，这样所有的线程就能够共享。【TODO】共享什么，是否需要测试？
    example::EchoService_Stub stub(static_cast<google::protobuf::RpcChannel*>(arg));

    int log_id = 0;
    while (!brpc::IsAskedToQuit()) {
        // We will receive response synchronously, safe to put variables
        // on stack.
        example::EchoRequest request;
        example::EchoResponse response;
        brpc::Controller cntl;

        request.set_message(g_request);
        // 这个 log 怎么查看？
        cntl.set_log_id(log_id++);  // set by user
        // Set attachment which is wired to network directly instead of 
        // being serialized into protobuf messages.
        cntl.request_attachment().append(g_attachment);

        // 因为最后一个参数 done 为空，函数将等待接收到 response 或错误发生。
        // Echo(cntl, request, response, done) 这个函数是在 echo.proto 中定义的:
        // service EchoService {
        //     rpc Echo(EchoRequest) returns (EchoResponse);
        // };
        // 这是 proto 规定的。若：
        // service EchoService {
        //     rpc Echo(A) returns (B);
        // };
        // 则：Echo(cntl, A, B, done)，函数返回 B。
        stub.Echo(&cntl, &request, &response, NULL); // 这句真正实现了传输。
        if (!cntl.Failed()) {
            g_latency_recorder << cntl.latency_us();
        } else {
            g_error_count << 1;
            // 这句话是什么意思？
            CHECK(brpc::IsAskedToQuit() || !FLAGS_dont_fail)
                << "error=" << cntl.ErrorText() << " latency=" << cntl.latency_us();
            // We can't connect to the server, sleep a while. Notice that this
            // is a specific sleeping to prevent this thread from spinning too
            // fast. You should continue the business logic in a production 
            // server rather than sleeping.
            // 【TODO】能否想办法走到 cntl.Failed() 这个分支里？
            bthread_usleep(50000);
        }
    }
    return NULL;
}

int main(int argc, char* argv[]) {   
    GFLAGS_NS::ParseCommandLineFlags(&argc, &argv, true);
    
    // Channel 是线程安全的，能够被所有的线程共享。
    brpc::Channel channel;
    
    // Initialize the channel, NULL means using default options.
    brpc::ChannelOptions options;
    if (FLAGS_enable_ssl) { // 使用 ssl 协议。
        options.mutable_ssl_options();
    }
    options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.connect_timeout_ms = std::min(FLAGS_timeout_ms / 2, 100);
    options.timeout_ms = FLAGS_timeout_ms;
    options.max_retry = FLAGS_max_retry;
    if (channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options) != 0) {
        LOG(ERROR) << "Fail to initialize channel";
        return -1;
    }

    // 当 attachment 变量大于 0 时，用 'a' 填满。
    if (FLAGS_attachment_size > 0) {
        g_attachment.resize(FLAGS_attachment_size, 'a');
    }
    if (FLAGS_request_size <= 0) {
        LOG(ERROR) << "Bad request_size=" << FLAGS_request_size;
        return -1;
    }
    // 用 'r' 填满 request 信息。【TODO】测试一下 request 的实际效果。
    g_request.resize(FLAGS_request_size, 'r');

    // 【TODO】试一下启用 dummy 模式。
    if (FLAGS_dummy_port >= 0) {
        brpc::StartDummyServerAt(FLAGS_dummy_port);
    }

    std::vector<bthread_t> bids; // 使用 bthread。
    std::vector<pthread_t> pids; // 使用 pthread。
    if (!FLAGS_use_bthread) {
        pids.resize(FLAGS_thread_num); // 容器 pids 大小初始化。
        for (int i = 0; i < FLAGS_thread_num; ++i) {
            // 创建线程。
            if (pthread_create(&pids[i], NULL, sender, &channel) != 0) {
                LOG(ERROR) << "Fail to create pthread";
                return -1;
            }
        }
    } else {
        bids.resize(FLAGS_thread_num); // 容器 bids 大小初始化。
        for (int i = 0; i < FLAGS_thread_num; ++i) {
            // 创建线程。
            if (bthread_start_background(
                    &bids[i], NULL, sender, &channel) != 0) {
                LOG(ERROR) << "Fail to create bthread";
                return -1;
            }
        }
    }

    while (!brpc::IsAskedToQuit()) {
        sleep(1); // 每秒输出一次。
        LOG(INFO) << "Sending EchoRequest at qps=" << g_latency_recorder.qps(1)
                  << " latency=" << g_latency_recorder.latency(1);
    }

    LOG(INFO) << "EchoClient is going to quit";
    
    // 【TODO】这一段有什么用？
    for (int i = 0; i < FLAGS_thread_num; ++i) {
        if (!FLAGS_use_bthread) {
            pthread_join(pids[i], NULL);
        } else {
            bthread_join(bids[i], NULL);
        }
    }

    return 0;
}
```



server.cpp：

```c++
#include <gflags/gflags.h>
#include <butil/logging.h>
#include <brpc/server.h>
#include "echo.pb.h"

// 【TEST√】是否有 attachment。
DEFINE_bool(echo_attachment, true, "Echo attachment as well");
// 【TODO√】不一致会出现什么错误？
DEFINE_int32(port, 8002, "TCP Port of this server");
// 【TOOO】什么是 the last idle_timeout_s？
DEFINE_int32(idle_timeout_s, -1, "Connection will be closed if there is no "
             "read/write operations during the last `idle_timeout_s'");
// 【TODO】这个参数是干什么的？
DEFINE_int32(logoff_ms, 2000, "Maximum duration of server's LOGOFF state "
             "(waiting for client to close connection before server stops)");
// 【TODO】同时请求的 request 数？
DEFINE_int32(max_concurrency, 0, "Limit of request processing in parallel");
// 【TODO】没懂这个参数的意思。
DEFINE_int32(internal_port, -1, "Only allow builtin services at this port");

namespace example {
// Your implementation of EchoService
// 这个函数继承了 proto 中的 EchoService，是实际处理的函数部分。
// 测试大概应该主要围绕这部分进行测试。
class EchoServiceImpl : public EchoService {
public:
    EchoServiceImpl() {}
    ~EchoServiceImpl() {};
    // 重写 Echo()。
    void Echo(google::protobuf::RpcController* cntl_base,
              const EchoRequest* request,
              EchoResponse* response,
              google::protobuf::Closure* done) {
        brpc::ClosureGuard done_guard(done);
        brpc::Controller* cntl =
            static_cast<brpc::Controller*>(cntl_base);

        // Echo request and its attachment
        response->set_message(request->message());
        if (FLAGS_echo_attachment) {
            cntl->response_attachment().append(cntl->request_attachment());
        }
    }
};
}  // namespace example

DEFINE_bool(h, false, "print help information");

int main(int argc, char* argv[]) {
    std::string help_str = "dummy help infomation";
    GFLAGS_NS::SetUsageMessage(help_str);

    GFLAGS_NS::ParseCommandLineFlags(&argc, &argv, true);

    if (FLAGS_h) {
        fprintf(stderr, "%s\n%s\n%s", help_str.c_str(), help_str.c_str(), help_str.c_str());
        return 0;
    }

    // Generally you only need one Server.
    brpc::Server server;

    // Instance of your service.
    example::EchoServiceImpl echo_service_impl;

    // Add the service into server. Notice the second parameter, because the
    // service is put on stack, we don't want server to delete it, otherwise
    // use brpc::SERVER_OWNS_SERVICE.
    if (server.AddService(&echo_service_impl, 
                          brpc::SERVER_DOESNT_OWN_SERVICE) != 0) {
        LOG(ERROR) << "Fail to add service";
        return -1;
    }

    // Start the server. 
    brpc::ServerOptions options;
    options.mutable_ssl_options()->default_cert.certificate = "cert.pem";
    options.mutable_ssl_options()->default_cert.private_key = "key.pem";
    options.idle_timeout_sec = FLAGS_idle_timeout_s;
    options.max_concurrency = FLAGS_max_concurrency;
    options.internal_port = FLAGS_internal_port;
    if (server.Start(FLAGS_port, &options) != 0) {
        LOG(ERROR) << "Fail to start EchoServer";
        return -1;
    }

    // Wait until Ctrl-C is pressed, then Stop() and Join() the server.
    server.RunUntilAskedToQuit();
    return 0;
}
```

client_test.cpp（用于测试 Server 端）：

```c++
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
        	threads_number++;
            g_latency_recorder << cntl.latency_us();
            std::cout << "threads_number: " << threads_number << std::endl;
        } else {
            g_error_count << 1;
            CHECK(brpc::IsAskedToQuit() || !FLAGS_dont_fail) // 查看是否退出，若退出：
                << "error=" << cntl.ErrorText() << " latency=" << cntl.latency_us();
            // bthread_usleep(50000);
        }
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
    FLAGS_thread_num = 50;
	pids.resize(FLAGS_thread_num);
	for (int i = 0; i < FLAGS_thread_num; ++i) {
		pthread_create(&pids[i], NULL, sender, &channel); // 创建线程。
	}
	// sleep(4); // <------ 这里等待两秒，是让所有线程全部执行完毕。
	
	int threads_number_temp = FLAGS_thread_num * loop_number;
	std::cout << "运行次数：" << threads_number_temp << "____" << threads_number << std::endl;

	for (int i = 0; i < FLAGS_thread_num; ++i) {
		pthread_join(pids[i], NULL);
    }

	EXPECT_EQ(threads_number_temp, threads_number);
}

int main(int argc, char *argv[])
{
	GFLAGS_NS::ParseCommandLineFlags(&argc, &argv, true);
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

