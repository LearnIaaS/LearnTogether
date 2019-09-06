# 练习 multi_thread_echo_c++

文档结构：

```shell
[root@artist multi_threaded_echo_c++]# tree -L 2
.
├── build
│   ├── CMakeCache.txt
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── echo.pb.cc
│   ├── echo.pb.h
│   ├── Makefile
│   ├── multi_threaded_echo_client
│   ├── multi_threaded_echo_client_test
│   └── multi_threaded_echo_server
├── cert.pem
├── client.cpp
├── client.o
├── client_test.cpp
├── CMakeLists_back.txt
├── CMakeLists.txt
├── echo_client
├── echo.pb.h
├── echo.pb.o
├── echo.proto
├── key.pem
├── Makefile
├── server.cpp
├── server.cpp.backup
├── server.o
└──server_test.cpp
```

之前想要单独新建一个文件夹用于测试，像这样：

```shell
[root@artist testServer]# tree
.
├── echo.pb.cc
├── echo.pb.h
├── libgtest.a
├── server.hpp
└── server_test.cpp
```

但是编译的时候总是不行：

```shell
[root@artist testServer]# g++ -std=c++11 -o run server_test.cpp echo.pb.cc -lbrpc -lpthread -lgflags -lprotobuf libgtest.a
server_test.cpp:3:27: fatal error: butil/logging.h: No such file or directory
 #include <butil/logging.h>
                           ^
compilation terminated.
```

怀疑是无法找到 <butil/logging.h>，于是：

```
yum install boost-devel
```

但还是不行。

放弃，之后备份了一份 `server.cpp`，就直接改 `server.cpp` 了，每次运行代码的时候要在 `build/` 中 make 一下。目前的代码 `` 如下：

```c++
#include <iostream>
#include <gtest/gtest.h>
#include <gflags/gflags.h>
#include <butil/logging.h>
#include <brpc/server.h>
#include "echo.pb.h"

DEFINE_bool(echo_attachment, true, "Echo attachment as well");
DEFINE_int32(port, 8002, "TCP Port of this server");
DEFINE_int32(idle_timeout_s, -1, "Connection will be closed if there is no "
             "read/write operations during the last `idle_timeout_s'");
DEFINE_int32(logoff_ms, 2000, "Maximum duration of server's LOGOFF state "
             "(waiting for client to close connection before server stops)");
DEFINE_int32(max_concurrency, 0, "Limit of request processing in parallel");
DEFINE_int32(internal_port, -1, "Only allow builtin services at this port");

DEFINE_string(attachment, "response hello", "Carry this along with requests");

static int NUMBER = 0;

namespace example {
// Your implementation of EchoService
class EchoServiceImpl : public EchoService {
public:
    EchoServiceImpl() {}
    ~EchoServiceImpl() {};
    void Echo(google::protobuf::RpcController* cntl_base,
              const EchoRequest* request,
              EchoResponse* response,
              google::protobuf::Closure* done) {
        brpc::ClosureGuard done_guard(done);
        brpc::Controller* cntl =
            static_cast<brpc::Controller*>(cntl_base);

        // Echo request and its attachment
        std::cout << "---------------" << std::endl;
        if (FLAGS_echo_attachment) {
            cntl->response_attachment().append(cntl->request_attachment());
            // LOG(INFO) << " (attached=" << cntl->request_attachment() << ")";
            LOG(INFO) << "NUMBER: " << NUMBER++;
        }
    }
};
}  // namespace example

DEFINE_bool(h, false, "print help information");

int main(int argc, char* argv[]) {
	testing::InitGoogleTest(&argc, argv);
	GFLAGS_NS::ParseCommandLineFlags(&argc, &argv, true);
	std::string help_str = "dummy help infomation";
	GFLAGS_NS::SetUsageMessage(help_str); // 设置帮助信息。
	if (FLAGS_h) {
        fprintf(stderr, "%s\n", help_str.c_str());
    }

    return RUN_ALL_TESTS();
}

TEST(Add, test0)
{
	// request
	example::EchoRequest request;
	request.set_message("this is a test");

	// cntl
	brpc::Controller cntl;
	cntl.set_log_id(1);
	cntl.request_attachment().append(FLAGS_attachment);
	
	// response
	example::EchoResponse response;

	// service
	example::EchoServiceImpl echo_service_impl;
	echo_service_impl.Echo(&cntl, &request, &response, NULL);
	
	// server
	brpc::Server server;
	int result = server.AddService(&echo_service_impl, 
								brpc::SERVER_DOESNT_OWN_SERVICE);
	std::cout << result << std::endl;
	
	// start the server
	brpc::ServerOptions options;
	options.idle_timeout_sec = FLAGS_idle_timeout_s;
    options.max_concurrency = FLAGS_max_concurrency;
    options.internal_port = FLAGS_internal_port;
    result = server.Start(FLAGS_port, &options); // 开启服务器。
    server.RunUntilAskedToQuit();
	
    int a = 1;
    int b = 1;
    EXPECT_EQ(a, b);
}
```

