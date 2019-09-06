# RocksDB笔记

## 基本环境和安装

不管三七二十一，全装了再说：

```shell
$ yum install epel-release

$ yum install -y ninja-build meson gcc-c++ git make cmake3 nfs-utils libnfsidmap

$ yum install -y glog-devel gflags-devel protobuf-devel protobuf-compiler leveldb-devel gperftools-devel gtest-devel snappy-devel openssl-devel libaio-devel libstdc++-devel yaml-cpp-devel
```

注意将 cmake3 链接到 cmake

```shell
$ ln -s /usr/bin/cmake3 /usr/bin/cmake
```

之后下载 RocksDB：

```
https://github.com/facebook/rocksdb/releases/tag/v5.17.2
```

**注意！** 在 CentOS 上需要修改`util/gflags_compat.h`里面的`namespace`为`gflags`

```
$ cmake -DPORTABLE=on -DBUILD_SHARED_LIBS=on <path>
$ make install
```

## 尝试运行一个基本的例子

首先，在父目录中：

```shell
$ make static_lib
```

编译所有示例文件：

```
$ cd examples
$ make all
```

这是一个例子【例1】：

```C++
#include "rocksdb/db.h"
 
rocksdb::DB* db;
rocksdb::Options options;
options.create_if_missing = true;
 
rocksdb::Status status = rocksdb::DB::Open(options, "/tmp/testdb", &db);
 
assert(status.ok());
 
status = db->Get(rocksdb::ReadOptions(), key1, &value);
status = db->Put(rocksdb::WriteOptions(), key2, value);
status = db->Delete(rocksdb::WriteOptions(), key1);
 
delete db;
```

这也是一个例子【例2】：

```C++
#include <cstdio>
#include <string>

#include "rocksdb/db.h"
#include "rocksdb/slice.h"
#include "rocksdb/options.h"

using namespace std;
using namespace rocksdb;

const std::string PATH = "/kv/rocksdb_tmp";

int main(){
    DB* db;
    Options options;
    options.create_if_missing = true;
    Status status = DB::Open(options, PATH, &db);
    assert(status.ok());
    Slice key("foo");
    Slice value("bar");
    
    std::string get_value;
    status = db->Put(WriteOptions(), key, value);
    if(status.ok()){
        status = db->Get(ReadOptions(), key, &get_value);
        if(status.ok()){
            printf("get %s\n", get_value.c_str());
        }else{
            printf("get failed\n"); 
        }
    }else{
        printf("put failed\n");
    }

    delete db;
}
```

这是另外一个例子【例3】：

```C++
#include <cstdio>
#include <string>
 
#include "rocksdb/db.h"
#include "rocksdb/slice.h"
#include "rocksdb/options.h"
 
using namespace std;
 
//数据库存储的路径
std::string kDBPath = "/tmp/rocksdb_simple_example";
 
int main(){
	DB * db;
	Options options;
 
	//增加并发和水平压实风格
	options.IncreaseParallelism();
	options.OptimizieLevelStyleCompaction();
 
	options.create_if_missing = true;
 
	//open DB
	Status s=DB::Open(options,kDBPath,&db);
	assert(s.ok());
 
	//Put key-value
	s = db->Put(WriteOptions(),"key1","value");
	assert(s.ok());
 
	std::string value;
	//get value
	s = db->Get(ReadOptions(),"key1",&value);
	assert(s.ok());
	assert(value == "value");
 
	//将一组更新原子化
	{
		WriteBatch batch;
		batch.Delete("key1");
		batch.Put("key2",value);
		s = db->Write(WriteOption(),&batch);
	}
 
	s = db->Get(ReadOptions(),"key1",&value);
	assert(s.IsNotFound());
 
	db->Get(ReadOptions(),"key2",&value);
	assert(value=="value");
 
	{
		PinnableSlice pinnable_val;
		db->Get(ReadOptions(),db->DefaultColumnFamily(),"key2",&pinnable_val);
		assert(pinnable_val=="value");
	}
 
	{
		std::string string_val;
		//如果无法锁定值，则将该值复制到其内部缓冲区
		//内部缓冲区可以在构造时设置
		PinnableSlice pinnable_val (&string_val);
		db->Get(ReadOptions(),db->DefaultColumnFamily(),"key2",&pinnable_val);
		assert(pinnable_val=="value");
		//如果值没被固定，则一定在内部缓冲区里
		assert(pinnable_val.IsPinned()||string_val=="value");
	}
 
 
	PinnalbeSlice pinnable_val;
	db->Get(ReadOptions(),db->DefaultColumnFamily(),"key1",&pinnable_val);
	assert(s.IsNotFound());
	//每次使用之后和每次重新使用之前重置PinnableSlice
	pinnable_val.Reset();
	db->Get(ReadOptions(),db->DefaultColumnFamily(),"key2",&pinnable_val);
	assert(pinnable_val == "value");
	pinnable_val.Reset();
	//在这之后，pinnable_val指向的Slice无效。
 
	delete db;
	
	return 0;
}
```

**TODO** 官方 example 代码因为有 Makefile 文件所以可以运行，但是自己编写的代码老是出错，先忽略。这里要解决，要认真去看 make、cmake。

然后我直接修改 example 文件夹中的 `simple_example.cc` 进行学习。



# RocksDB 原理

它是一个高性能的Key-Value数据库。设计了完善的持久化机制，同时保证性能和安全性。能够良好的支持范围查询，因为K-V记录就是按照Key来排序的。

![](H:\StudyNote\RocksDB\img\RocksDB Structure.png)

## rocksdb对leveldb的优化

* 增加了column family，有了列簇的概念，可把一些相关的key存储在一起，column famiy的设计挺有意思的，后面会单独分析
* 内存中有多个immute memtalbe，可防止Leveldb中的 write stall
* 可支持多线程同时compation，理论上多线程同时comaption会比一个线程compation要快
* 增加了merge operator，也就是原地更新，优化了modify的效率
* 支持DB级的TTL
* flush与compation分开不同的线程池来调度，并具有不同的优先级，flush要优于compation，这样可以加快flush，防止stall
* 对SSD存储做了优化，可以以in-memory方式运行

## Column Family 列簇

![](H:\StudyNote\RocksDB\img\Column Family.png)

Rocksdb中引入了ColumnFamily(列族, CF)的概念，所谓列族也就是一系列kv组成的数据集。所有的读写操作都需要先指定列族。



参考：

https://www.jianshu.com/p/73fa1d4e4273

http://kernelmaker.github.io/

[【Rocksdb实现及优化分析】 JoinBatchGroup](http://kernelmaker.github.io/Rocksdb_Study_1)