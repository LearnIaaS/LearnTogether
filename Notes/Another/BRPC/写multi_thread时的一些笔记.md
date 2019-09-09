# 笔记

## 数据类型

- 使用 `typeid(aa).name()` 返回对象的数据类型：

  ```c++
  #include <typeinfo>
  ...
  char* aa = "123";
  std::cout << "chars类型：" << typeid(aa).name() << std::endl;
  ```

- 几种数据的类型：

  ```c++
  char* aa = "123";
  std::string bb = "123";
  std::string message_response = response.message().c_str();
  
  std::cout << typeid(g_request.c_str()).name() << std::endl; // PKc
  std::cout << typeid(response.message().c_str()).name() << std::endl; // PKc
  std::cout << typeid(g_attachment.c_str()).name() << std::endl; // PKc
  std::cout << typeid(cntl.response_attachment().to_string()).name() << std::endl; // Ss
  std::cout << typeid(aa).name() << std::endl; // Pc
  std::cout << typeid(bb).name() << std::endl; // Ss
  std::cout << typeid(message_response).name() << std::endl; // Ss
  ```

- 因为数据类型不同，所以无法在断言中直接比较。故先使用 `StringA.compare(StringB)` 进行比较，再使用断言：`EXPECT_EQ(a,b)` 的方法。

  ```c++
  int result_A = g_request.compare(response.message().c_str());
  int result_B = g_attachment.compare(cntl.response_attachment().to_string());
  
  EXPECT_EQ(0, result_A);
  EXPECT_EQ(0, result_B);
  ```

  

