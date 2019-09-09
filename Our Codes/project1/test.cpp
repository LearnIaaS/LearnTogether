#include <gflags/gflags.h>
#include <butil/logging.h>
#include <butil/time.h>
#include <brpc/channel.h>
#include "gtest/gtest.h"
#include "server.hpp"

DEFINE_string(attachment, "response hello", "Carry this along with requests");
DECLARE_bool(echo_attachment);
//extern bool FLAGS_echo_attachment;


TEST(Echo, test){
  example::EchoRequest request;
  example::EchoResponse response;
  brpc::Controller cntl;
  example::EchoServiceImpl service;
  
  cntl.set_log_id(1);
  cntl.request_attachment().append(FLAGS_attachment);
  std::string value = "Hello world";
  request.set_message(value);
  FLAGS_echo_attachment = false;
  service.Echo(&cntl, &request, &response, NULL);

  //std::string str_message = response.message();
  //ASSERT_STREQ(value.c_str(), str_message.c_str());

  std::string str_attachment = cntl.response_attachment().to_string();
  std::cout << "attachment:" << str_attachment << std::endl;
  ASSERT_STRNE(FLAGS_attachment.c_str(), str_attachment.c_str());
}


int main(int argc, char* argv[]){
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();

}
