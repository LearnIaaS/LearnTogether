# Level DB

## LevelDB 介绍

LevelDB 是由 Google 开发的 key-value 非关系型数据库存储系统，是基于  LSM(Log-Structured-Merge Tree) 的典型实现，LSM 的原理是：当读写数据库时，首先纪录读写操作到 Op log  文件中，然后再操作内存数据库，当达到 checkpoint 时，则写入磁盘，同时删除相应的 Op log 文件，后续重新生成新的内存文件和 Op  log 文件。

LevelDB 内部采用了内存缓存机制，也就是在写数据库时，首先会存储在内存中，内存的存储结构采用了 skip list 结构，待达到 checkpoint 时，才进行落盘操作，保证了数据库的高效运转。

![](H:\StudyNote\RocksDB\img\LevelDB Structure.png)

如上图所示，整个 LevelDB 由以下几部分组成：

1. Write(k,v)，对外的接口
2. Op log，操作日志记录文件
3. memtable，数据库存储的内存结构
4. Immutable memtable，待落盘的数据库内存数据
5. sstable，落盘后的磁盘存储结构
6. manifest，LevelDB 元信息清单，包括数据库的配置信息和中间使用的文件列表
7. current，当前正在使用的文件清单

整体结构清晰紧凑，非常容易理解。



## 对外接口

```c++
DB() { }; // 数据库创建。
virtual ~DB(); // 数据库删除。
static Status Open(const Options& options,
                   const std::string& name,
                   DB** dbptr); // 数据库打开。
virtual Status Put(const WriteOptions& options,
                   const Slice& key,
                   const Slice& value) = 0; // 写。
virtual Status Delete(const WriteOptions& options, const Slice& key) = 0; // 删除。
virtual Status Write(const WriteOptions& options, WriteBatch* updates) = 0; // 数据库批处理操作。
virtual Status Get(const ReadOptions& options,
                   const Slice& key, std::string* value) = 0; // 读。
virtual Iterator* NewIterator(const ReadOptions& options) = 0; // 数据库遍历操作。
// 数据库快照：
virtual const Snapshot* GetSnapshot() = 0;
virtual void ReleaseSnapshot(const Snapshot* snapshot) = 0;
```



## sstable 结构分析

sstable 作为落盘的存储结构，每个 sstable 最大 2MB，从宏观来看，它属于分层的结构，即：

- level 0：最多存储 4 个 sstable
- level 1：存储不超过 10MB 大小的 sstable
- level 2：存储不超过 100MB 大小的 sstable
- level 3 及之后：存储大小不超过上一级大小的 10 倍

之所以这样分层，是为了提高查找效率，也是 LevelDB 名称的由来。当每一层超过限制时，会进行 compaction 操作，合并到上一层，递归进行。

从微观的角度看，每个 sstable 文件结构入下图所示：

![](H:\StudyNote\RocksDB\img\LeveLDB sstable structure.png)

其中：

- Data Block 存储具体的 k-v 数据
- Meta Block 存储索引过滤信息，用于快速定位 key 是否存在于 Data Block 中
- Meta Index Block 存储 Meta Block 的偏移位置及大小
- Index Block 存储 Data Block 的偏移位置及大小
- Footer 则存储 Meta Index Block 和 Index Block 的偏移位置及大小，相当于二级索引

另外 Data Block 及 Meta Block 的存储格式是统一的，都是如下格式：

![](H:\StudyNote\RocksDB\img\Data Block Save Type.png)

对于 Meta Block 来说，它保存了用于快速定位 key 是否在 Data Block 中的信息，具体方法是：

* 采用了 bloom filter 的过滤机制，bloom filter 是一种 hash 机制，它对每一个 key，会计算 k 个  hash 值，然后在 k 个 bit 位记录为 1。当查找时，相应计算出 k 个 hash 值，然后比对 k 个 bit 位是否为  1，只要有一个不为 1，则不存在。
* 对于每一个 Data Block，所有的 key 值会传入进行 bloom filter 的 hash 计算，每个 key 存储 k 个 bit 位值。



## LevelDB的使用

LevelDB本身只是一个lib库，在源码目录make编译即可，然后在我们的应用程序里面可以直接include leveldb/include/db.h头文件，该头文件有几个基本的数据库操作接口，下面是一个测试例子：

```c++
#include 
#include 
#include     
#include "leveldb/db.h"    
 
using namespace std;
 
int main(void) 
{
    leveldb::DB      *db;    
    leveldb::Options  options;    
    options.create_if_missing = true;    
 
    // open
    leveldb::Status status = leveldb::DB::Open(options,"/tmp/testdb", &amp;db);    
    assert(status.ok());    
 
    string key = "name";    
    string value = "chenqi";    
 
    // write
    status = db-&gt;Put(leveldb::WriteOptions(), key, value);    
    assert(status.ok());    
 
    // read
    status = db-&gt;Get(leveldb::ReadOptions(), key, &amp;value);    
    assert(status.ok());    
 
    cout&lt;&lt;value&lt;&lt;endl;    
 
    // delete
    status = db-&gt;Delete(leveldb::WriteOptions(), key);    
    assert(status.ok());        
 
    status = db-&gt;Get(leveldb::ReadOptions(),key, &amp;value);    
    if(!status.ok()) {
        cerr&lt;&lt;key&lt;&lt;"    "&lt;&lt;status.ToString()&lt;&lt;endl;
    } else {
        cout&lt;&lt;key&lt;&lt;"==="&lt;&lt;value&lt;&lt;endl;    
    }   
 
    // close 
    delete db;    
 
    return 0;    
}
```

上面的例子演示了如何插入、获取、删除一条记录，编译代码：

```
g++ -o test test.cpp libleveldb.a -lpthread -Iinclude
```

执行./test后，会在/tmp下面生成一个目录testdb，里面包含若干文件：

![](H:\StudyNote\RocksDB\img\简单例子执行以后.jpg)

然后简要说下各个文件的含义：

1、CURRENT

2、LOG

3、LOCK

4、MANIFEST

下图是LevelDB运行一段时间后的存储模型快照：内存中的MemTable和Immutable 
MemTable以及磁盘上的几种主要文件：Current文件，Manifest文件，log文件以及SSTable文件。当然，LevelDb除了这六个主要部分还有一些辅助的文件，但是以上六 个文件和数据结构是LevelDb的主体构成元素。

LevelDb的Log文件，当应用写入一条Key:Value记录的时候，LevelDb会先往log文件里写入，成功后将记录插进Memtable中，这样基本就算完成了写入操作，因为一次写入操作只涉及一次磁盘顺序写和一次内存写入，所以这是为何说LevelDb写入速度极快的主要原因。

![](H:\StudyNote\RocksDB\img\LevelDB Structure 2.png)

Log文件在系统中的作用主要是用于系统崩溃恢复而不丢失数据，假如没有Log文件，因为写入的记录刚开始是保存在内存中的，此时如果系统崩溃，内存中的数据还没有来得及Dump到磁盘，所以会丢失数据（Redis就存在这个问题）。为了避免这种情况，LevelDb在写入内存前先将操作记录到Log文件中，然后再记入内存中，这样即使系统崩溃，也可以从Log文件中恢复内存中的Memtable，不会造成数据的丢失。

log文件、MemTable、SSTable文件都是用来存储k-v记录的，下面再说说manifest和Current文件的作用。

当Memtable插入的数据占用内存到了一个界限后，需要将内存的记录导出到外存文件中，LevleDb会生成新的Log文件和Memtable，原先的Memtable就成为Immutable Memtable，顾名思义，就是说这个Memtable的内容是不可更改的，只能读不能写入或者删除。新到来的数据被记入新的Log文件和Memtable，LevelDb后台调度会将Immutable Memtable的数据导出到磁盘，形成一个新的SSTable文件。SSTable就是由内存中的数据不断导出并进行Compaction操作后形成的，而且SSTable的所有文件是一种层级结构，第一层为Level 0，第二层为Level 1，依次类推，层级逐渐增高，这也是为何称之为LevelDb的原因。

SSTable中的某个文件属于特定层级，而且其存储的记录是key有序的，那么必然有文件中的最小key和最大key，这是非常重要的信息，Manifest   就记载了SSTable各个文件的管理信息，比如属于哪个Level，文件名称叫啥，最小key和最大key各自是多少。下图是Manifest所存储内容的示意：

![](H:\StudyNote\RocksDB\img\manifest.png)

另外，在LevleDb的运行过程中，随着Compaction的进行，SSTable文件会发生变化，会有新的文件产生，老的文件被废弃，Manifest也会跟着反映这种变化，此时往往会新生成Manifest文件来记载这种变化，而Current则用来指出哪个Manifest文件才是我们关心的那个Manifest文件。



## LevelDB Log 文件结构

写入数据的时候，最开始会写入到log文件中，由于是顺序写入文件，所以写入速度很快，可以马上返回。

来看Log文件的结构：

- 一个Log文件由多个Block组成，每个Block大小为32KB。
- 一个Block内部又有多个Record组成，Record分为四种类型：

Full：一个Record占满了整个Block存储空间。

First：一个Block的***个Record。

Last：一个Block的***一个Record。

Middle：其余的都是Middle类型的Record。

- Record的结构如下：

32位长度的CRC Checksum：存储这个Record的数据校验值，用于检测Record合法性。

16位长度的Length：存储数据部分长度。

8位长度的Type：存储Record类型，就是上面说的四种类型。

Header部分

数据部分

![](H:\StudyNote\RocksDB\img\LevelDB Log.jpg)



## SSTable文件

### SSTable原理

SST文件并不是平坦的结构，而是分层组织的，这也是LevelDB名称的来源。

**SST文件的一些实现细节：**

- 每个SST文件大小上限为2MB，所以，LevelDB通常存储了大量的SST文件；
- SST文件由若干个4K大小的blocks组成，block也是读/写操作的最小单元；
- SST文件的最后一个block是一个index，指向每个data block的起始位置，以及每个block第一个entry的key值（block内的key有序存储）；
- 使用[Bloom filter](http://www.cnblogs.com/chenny7/p/4074250.html)加速查找，只要扫描index，就可以快速找出所有可能包含指定entry的block。
- 同一个block内的key可以共享前缀（只存储一次），这样每个key只要存储自己唯一的后缀就行了。如果block中只有部分key需要共享前缀，在这部分key与其它key之间插入"reset"标识。

 

由log直接读取的entry会写到Level 0的SST中（最多4个文件）；

当Level 0的4个文件都存储满了，会选择其中一个文件Compact到Level 1的SST中；

注意：Level  0的SSTable文件和其它Level的文件相比有特殊性：这个层级内的.sst文件，两个文件可能存在key重叠，比如有两个level  0的sst文件，文件A和文件B，文件A的key范围是：{bar,  car}，文件B的Key范围是{blue,samecity}，那么很可能两个文件都存在key=”blood”的记录。对于其它Level的SSTable文件来说，则不会出现同一层级内.sst文件的key重叠现象，就是说Level  L中任意两个.sst文件，那么可以保证它们的key值是不会重叠的。

 

Log：最大4MB (可配置), 会写入Level 0；
Level 0：最多4个SST文件,；
Level 1：总大小不超过10MB；
Level 2：总大小不超过100MB；
Level 3 ：总大小不超过上一个Level ×10的大小。

比如：0 ↠ 4 SST, 1 ↠ 10M, 2 ↠ 100M, 3 ↠ 1G, 4 ↠ 10G, 5 ↠ 100G, 6 ↠ 1T, 7 ↠ 10T

 

在读操作中，要查找一条entry，先查找log，如果没有找到，然后在Level 0中查找，如果还是没有找到，再依次往更底层的Level顺序查找；如果查找了一条不存在的entry，则要遍历一遍所有的Level才能返回"Not Found"的结果。

在写操作中，新数据总是先插入开头的几个Level中，开头的这几个Level存储量也比较小，因此，对某条entry的修改或删除操作带来的性能影响就比较可控。

可见，SST采取分层结构是为了最大限度减小插入新entry时的开销；

### SSTable文件存储结构

LevelDb不同层级有很多SSTable文件（以后缀.sst为特征），所有.sst文件内部布局都是一样的。上节介绍Log文件是物理分块的，SSTable也一样会将文件划分为固定大小的物理存储块，但是两者逻辑布局大不相同，根本原因是：Log文件中的记录是Key无序的，即先后记录的key大小没有明确大小关系，而**.sst文件**内部则是**根据记录的Key由小到大排列**的，从下面介绍的SSTable布局可以体会到Key有序是为何如此设计.sst文件结构的关键。

![](H:\StudyNote\RocksDB\img\sst文件的分块结构.png)

上图展示了一个.sst文件的物理划分结构，同Log文件一样，也是划分为固定大小的存储块，每个Block分为三个部分，红色部分是数据存储区， 蓝色的**Type**区用于标识数据存储区是否采用了**数据压缩算法**（Snappy压缩或者无压缩两种），**CRC**部分则是**数据校验码**，用于判别数据是否在生成和传输中出错。

**以上是.sst的物理布局**，下面介绍.sst文件的逻辑布局，所谓逻辑布局，就是说尽管大家都是物理块，但是每一块存储什么内容，内部又有什么结构等。	

![](H:\StudyNote\RocksDB\img\sst文件的逻辑结构.png)

从上图可以看出，从大的方面，可以将.sst文件划分为数据存储区和数据管理区，数据存储区存放实际的 ey:Value数据，数据管理区则提供一些索引指针等管理数据，目的是更快速便捷的查找相应的记录。两个区域都是在上述的分块基础上的，就是说文-件的前面若干块实际存储KV数据，后面数据管理区存储管理数据。管理数据又分为四种不同类型：紫色的Meta  Block，红色的MetaBlock 索引和蓝色的数据索引块以及一个文件尾部块。

LevelDb 1.2版对于Meta Block尚无实际使用，只是保留了一个接口，估计会在后续版本中加入内容，下面我们看看数据索引区和文件尾部Footer的内部结构。

![](H:\StudyNote\RocksDB\img\数据索引.png)

再次强调一下，Data Block内的KV记录是按照Key**由小到大排列**的，数据索引区的每条记录是对某个Data Block 建立的索引信息，每条索引信息包含三个内容，以图4.3所示的数据块i的索引Index i 来说：红色部分的第一个字段记载大于等于数据块i中最大的Key值的那个Key，第二个字段指出数据块i在.sst文件中的起始位置，第三个字段指出Data Block i 的大小（有时候是有数据压缩的）。后面两个字段好理解，是用于定位数据块在文件中的位置的，第一个字段需要详细解释一下，在索引里保存的这个Key值**未必一定是某条记录的Key**,以图的例子来说，假设数据块i 的最小Key=“samecity”，最大Key=“the best”;数据块i+1的最小Key=“the fox”,最大Key=“zoo”,那么对于数据块i的索引Index i来说，其第一个字段记载大于等于数据块i的最大Key(“the best”)同时要小于数据块i+1的最小Key(“the fox”)，所以例子中Index i的第一个字段是：“the c”，这个是满足要求的；而Index i+1的第一个字段则是“zoo”，即数据块i+1的最大Key。

文件末尾Footer块的内部结构见图，**metaindex_handle** 指出了metaindex block的起始位置和大小；**inex_handle**指出了index Block的起始地址和大小；这两个字段可以理解为索引的索引，是为了正确读出索引值而设立的，后面跟着一个填充区和魔数。

![](H:\StudyNote\RocksDB\img\Footer.png)



## MemTable详解

所有KV数据都是存储在Memtable，Immutable Memtable和SSTable中的，Immutable Memtable从结构上讲和Memtable是完全一样的，区别仅仅在于其是只读的，不允许写入操作，而Memtable则是允许写入和读取的。当Memtable写入的数据占用内存到达指定数量，则自动转换为Immutable Memtable，等待Dump到磁盘中，系统会自动生成新的Memtable供写操作写入新数据，理解了Memtable，那么Immutable Memtable自然不在话下。

LevelDb的MemTable提供了将KV数据写入，删除以及读取KV记录的操作接口，但是事实上Memtable并不存在真正的删除操作,删除某个Key的Value在Memtable内是作为插入一条记录实施的，但是会打上一个Key的删除标记，真正的删除操作是Lazy的，会在以后的Compaction过程中去掉这个KV。

需要注意的是，LevelDb的Memtable中KV对是根据Key大小有序存储的，在系统插入新的KV时，LevelDb要把这个KV插到合适的位置上以保持这种Key有序性。其实，LevelDb的Memtable类只是一个接口类，真正的操作是通过背后的SkipList来做的，包括插入操作和读取操作等，所以Memtable的核心数据结构是一个SkipList。

SkipList是由William Pugh发明。他在Communications of the ACM June 1990, 33(6) 668-676 发表了Skip lists: a probabilistic alternative to balanced trees，在该论文中详细解释了SkipList的数据结构和插入删除操作。

SkipList是平衡树的一种替代数据结构，但是和红黑树不相同的是，SkipList对于树的平衡的实现是基于一种随机化的算法的，这样也就是说SkipList的插入和删除的工作是比较简单的。

关于SkipList的详细介绍可以参考这篇文章：http://www.cnblogs.com/xuqiang/archive/2011/05/22/2053516.html，讲述的很清楚，LevelDb的SkipList基本上是一个具体实现，并无特殊之处。

SkipList不仅是维护有序数据的一个简单实现，而且相比较平衡树来说，在插入数据的时候可以避免频繁的树节点调整操作，所以写入效率是很高的，LevelDb整体而言是个高写入系统，SkipList在其中应该也起到了很重要的作用。Redis为了加快插入操作，也使用了SkipList来作为内部实现数据结构。

### 补充

leveldb根据用途将这些block又分为数据块，元数据块，元数据块索引块，数据块索引块和文件尾。

1. 数据块主要就是存储数据的地方，immemtable中的键值对就是存储在数据块；
2. 元数据块主要就是用于过滤，加快检索速度；
3. 元数据块索引块，leveldb默认一个过滤器，所以元数据块索引块就一条记录；
4. 数据块索引块，存储每一个数据块的偏移和大小，用于定位索引块；
5. 文件尾，存储了数据块索引块和元数据块索引块，用于读取这两个块。

## 读写操作

### 写操作流程

1、顺序写入磁盘log文件；
2、写入内存memtable（采用skiplist结构实现）；
3、写入磁盘SST文件(sorted string table files)，这步是数据归档的过程（永久化存储）；

**注意：**

- log文件的作用是是用于系统崩溃恢复而不丢失数据，假如没有Log文件，因为写入的记录刚开始是保存在内存中的，此时如果系统崩溃，内存中的数据还没有来得及Dump到磁盘，所以会丢失数据；
- 在写memtable时，如果其达到check point（满员）的话，会将其改成immutable memtable（只读），然后等待dump到磁盘SST文件中，此时也会生成新的memtable供写入新数据；
- memtable和sst文件中的key都是有序的，log文件的key是无序的；
- LevelDB删除操作也是插入，只是标记Key为删除状态，真正的删除要到Compaction的时候才去做真正的操作；
- LevelDB没有更新接口，如果需要更新某个Key的值，只需要插入一条新纪录即可；或者先删除旧记录，再插入也可。

### 读操作流程

1、在内存中依次查找memtable、immutable memtable；
2、如果配置了cache，查找cache；
3、根据mainfest索引文件，在磁盘中查找SST文件。

![](H:\StudyNote\RocksDB\img\LevelDB read.png)

举个例子：我们先往levelDb里面插入一条数据` {key="www.samecity.com" value="我们"}`，过了几天，samecity网站改名为：69同城，此时我们插入数据`{key="www.samecity.com"  value="69同城"}`，同样的`key`，不同的`value`；逻辑上理解好像 levelDb 中只有一个存储记录，即第二个记录，但是在levelDb中很可能存在两条记录，即上面的两个记录都在levelDb中存储了，此时如果用户查询 key="www.samecity.com"，我们当然希望找到最新的更新记录，也就是第二个记录返回，因此，查找的顺序应该依照数据更新的新鲜度来，对于SSTable文件来说，如果同时在level L和Level L 1找到同一个key，level L的信息一定比level L 1的要新。



## Compaction操作

前文有述，对于LevelDb来说，写入记录操作很简单，删除记录仅仅写入一个删除标记就算完事，但是读取记录比较复杂，需要在内存以及各个层级文件中依照新鲜程度依次查找，代价很高。为了加快读取速度，levelDb采取了compaction的方式来对已有的记录进行整理压缩，通过这种方式，来删除掉一些不再有效的KV数据，减小数据规模，减少文件数量等。

levelDb的compaction机制和过程与Bigtable所讲述的是基本一致的，Bigtable中讲到三种类型的compaction: minor ，major和full。所谓minor Compaction，就是把memtable中的数据导出到SSTable文件中；major compaction就是合并不同层级的SSTable文件，而full compaction就是将所有SSTable进行合并。

LevelDb包含其中两种，minor和major。

### minor Compaction

Minor compaction 的目的是当内存中的memtable大小到了一定值时，将内容保存到磁盘文件中，下图是其机理示意图。 

![](H:\StudyNote\RocksDB\img\minor Compaction.png)

当memtable数量到了一定程度会转换为immutable memtable，此时不能往其中写入记录，只能从中读取KV内容。之前介绍过，immutable memtable其实是一个多层级队列SkipList，其中的记录是根据key有序排列的。所以这个minor compaction实现起来也很简单，就是按照immutable memtable中记录由小到大遍历，并依次写入一个level 0 的新建SSTable文件中，写完后建立文件的index 数据，这样就完成了一次minor compaction。从图中也可以看出，对于被删除的记录，在minor compaction过程中并不真正删除这个记录，原因也很简单，这里只知道要删掉key记录，但是这个KV数据在哪里?那需要复杂的查找，所以在minor compaction的时候并不做删除，只是将这个key作为一个记录写入文件中，至于真正的删除操作，在以后更高层级的compaction中会去做。

### major Compaction

当某个level下的SSTable文件数目超过一定设置值后，levelDb会从这个level的SSTable中选择一个文件（level>0），将其和高一层级的level+1的SSTable文件合并，这就是major compaction。

当某个level下的SSTable文件数目超过一定设置值后，levelDb会从这个level的SSTable中选择一个文件（level>0），将其和高一层级的level+1的SSTable文件合并，这就是major compaction。

我们知道在大于0的层级中，每个SSTable文件内的Key都是由小到大有序存储的，而且不同文件之间的key范围（文件内最小key和最大key之间）不会有任何重叠。Level 0的SSTable文件有些特殊，尽管每个文件也是根据Key由小到大排列，但是因为level 0的文件是通过minor compaction直接生成的，所以任意两个level 0下的两个sstable文件可能再key范围上有重叠。所以在做major compaction的时候，对于大于level 0的层级，选择其中一个文件就行，但是对于level 0来说，指定某个文件后，本level中很可能有其他SSTable文件的key范围和这个文件有重叠，这种情况下，要找出所有有重叠的文件和level 1的文件进行合并，即level 0在进行文件选择的时候，可能会有多个文件参与major compaction。

levelDb在选定某个level进行compaction后，还要选择是具体哪个文件要进行compaction，levelDb在这里有个小技巧， 就是说轮流来，比如这次是文件A进行compaction，那么下次就是在key range上紧挨着文件A的文件B进行compaction，这样每个文件都会有机会轮流和高层的level 文件进行合并。

如果选好了level L的文件A和level L+1层的文件进行合并，那么问题又来了，应该选择level L+1哪些文件进行合并？levelDb选择L+1层中和文件A在key range上有重叠的所有文件来和文件A进行合并。

也就是说，选定了level L的文件A,之后在level L+1中找到了所有需要合并的文件B,C,D…..等等。剩下的问题就是具体是如何进行major 合并的？就是说给定了一系列文件，每个文件内部是key有序的，如何对这些文件进行合并，使得新生成的文件仍然Key有序，同时抛掉哪些不再有价值的KV 数据。

![](H:\StudyNote\RocksDB\img\major Compaction.png)

Major compaction的过程如下：对多个文件采用多路归并排序的方式，依次找出其中最小的Key记录，也就是对多个文件中的所有记录重新进行排序。之后采取一定的标准判断这个Key是否还需要保存，如果判断没有保存价值，那么直接抛掉，如果觉得还需要继续保存，那么就将其写入level L+1层中新生成的一个SSTable文件中。就这样对KV数据一一处理，形成了一系列新的L+1层数据文件，之前的L层文件和L+1层参与compaction 的文件数据此时已经没有意义了，所以全部删除。这样就完成了L层和L+1层文件记录的合并过程。

那么在major compaction过程中，判断一个KV记录是否抛弃的标准是什么呢？其中一个标准是:对于某个key来说，如果在小于L层中存在这个Key，那么这个KV在major compaction过程中可以抛掉。因为我们前面分析过，对于层级低于L的文件中如果存在同一Key的记录，那么说明对于Key来说，有更新鲜的Value存在，那么过去的Value就等于没有意义了，所以可以删除。

## 读放大、写放大、空间放大

基于 LSM-Tree 的存储系统越来越常见了，如 RocksDB、LevelDB。LSM-Tree 能将**离散**的**随机**写请求都转换成**批量**的**顺序**写请求（WAL + Compaction），以此提高写性能。但也带来了一些问题：

- 读放大（Read Amplification）。LSM-Tree 的读操作需要从新到旧（从上到下）一层一层查找，直到找到想要的数据。这个过程可能需要不止一次 I/O。特别是 range query 的情况，影响很明显。
- 空间放大（Space Amplification）。因为所有的写入都是顺序写（append-only）的，不是 in-place update ，所以过期数据不会马上被清理掉。

RocksDB 和 LevelDB 通过后台的 compaction 来减少读放大（减少 SST 文件数量）和空间放大（清理过期数据），但也因此带来了写放大（Write Amplification）的问题。

- 写放大。实际写入 HDD/SSD 的数据大小和程序要求写入数据大小之比。正常情况下，HDD/SSD 观察到的写入数据多于上层程序写入的数据。

在 HDD 作为主流存储的时代，RocksDB 的 compaction 带来的写放大问题并没有非常明显。这是因为：

1. HDD 顺序读写性能远远优于随机读写性能，足以抵消写放大带来的开销。
2. HDD 的写入量基本不影响其使用寿命。

现在 SSD 逐渐成为主流存储，compaction 带来的写放大问题显得越来越严重：

1. SSD 顺序读写性能比随机读写性能好一些，但是差距并没有 HDD 那么大。所以，顺序写相比随机写带来的好处，能不能抵消写放大带来的开销，这是个问题。
2. SSD 的使用寿命和其写入量有关，写放大太严重会大大缩短 SSD 的使用寿命。因为 SSD 不支持覆盖写，必须先擦除（erase）再写入。而每个 SSD block（block 是 SSD 擦除操作的基本单位） 的平均擦除次数是有限的。

所以，在 SSD 上，LSM-Tree 的写放大是一个非常值得关注的问题。而写放大、读放大、空间放大，三者就像 CAP 定理一样，需要做好权衡和取舍。



## 网站参考

[LevelDB日知](https://www.cnblogs.com/haippy/archive/2011/12/04/2276064.html)

[跳表SkipList](https://www.cnblogs.com/xuqiang/archive/2011/05/22/2053516.html)

[RocksDB. Leveled Compaction原理分析](https://www.jianshu.com/p/99cc0df8ed21)

http://stor.51cto.com/art/201903/593197.htm

