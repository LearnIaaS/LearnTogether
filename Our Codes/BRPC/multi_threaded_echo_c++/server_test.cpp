#include <gflags/gflags.h>
#include <butil/logging.h>
#include <brpc/server.h>
#include <gtest/gtest.h>
#include "echo.pb.h"

DEFINE_bool(echo_attachment, true, "Echo attachment as well");
DEFINE_int32(port, 8002, "TCP Port of this server");
DEFINE_int32(idle_timeout_s, -1, "Connection will be closed if there is no "
	"read/write operations during the last `idle_timeout_s'");
DEFINE_int32(logoff_ms, 2000, "Maximum duration of server's LOGOFF state "
	"(waiting for client to close connection before server stops)");
DEFINE_int32(max_concurrency, 0, "Limit of request processing in parallel");
DEFINE_int32(internal_port, -1, "Only allow builtin services at this port");
DEFINE_bool(h, false, "print help information");

// static int NUMBER;

/*
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
		response->set_message(request->message());
		if (FLAGS_echo_attachment) {
			cntl->response_attachment().append(cntl->request_attachment());
            // LOG(INFO) << " (attached=" << cntl->request_attachment() << ")";
			LOG(INFO) << "NUMBER: " << NUMBER++;
		}
	}
};
*/

TEST(Echo, test01){
	className name;
	name.say();
	int a = 1;
	int b = 1;
	EXPECT_EQ(a, b);
}

int main(int argc, char* argv[]){
	testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
