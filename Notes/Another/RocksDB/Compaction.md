# Compaction原理

compaction 主要包括两类：将内存中 imutable 转储到磁盘上 sst 的过程称之为 flush 或者 minor compaction；磁盘上的 sst 文件从低层向高层转储的过程称之为 compaction 或者是 major compaction。

对于 myrocks 来说，compaction 过程都由后台线程触发，对于 minor compaction 和 major compaction 分别对应一组线程，通过参数`rocksdb_max_background_flushes`和`rocksdb_max_background_compactions`可以来控制。通过 minor compaction，内存中的数据不断地写入的磁盘，保证有足够的内存来应对新的写入；而通过major compaction，多层之间的 SST 文件的重复数据和无用的数据可以迅速减少，进而减少 SST 文件占用的磁盘空间。

## flush(minor-compaction)

Rockdb中在内存的数据都是通过memtable存储，主要包括两种形式，active-memtable和immutable-memtable。active-memtable是当前正在提供写操作的memtable，当active-memtable写入超过阀值(通过参数wirte_buffer_size控制)，会将这个memtable标记为read-only，然后再创建一个新的memtable供新的写入，这个read-only的memtable就是immutable-memtable。我们所说的flush操作就是将imumutable-memtable 写入到level0的过程。

flush过程以column family为单位进行，一个column family是一组sst文件的集合，在myrocks中一个表可以是一个单独的column family，也可以多个表共用一个column family。每个column family中可能包含一个或多个immutable-memtable，一个flush线程会抓取column family中所有的immutable-memtable进行merge，然后flush到level0。由于一个线程在flush过程中，新的写入也源源不断进来，进而产生新的immutable-memtable，其它flush线程可以新起一个任务进行flush，因此在rocksdb体系下，active-memtable->immutable-memtable->sst文件转换过程是流水作业，并且flush可以并发执行，相对于levelDB，并发compaction的速度要快很多。通过参数max_write_buffer_number可以控制memtable的总数量，如果写入非常快，而compaction很慢，会导致memtable数量超过阀值，导致write stall的严重后果。另外一个参数是min_write_buffer_number_to_merge，整个参数是控制至少几个immutable才会触发flush，默认是1。

## compaction(major-compaction)

我们通常所说的 compaction 就是 major-compaction，sst 文件从低 level 合并到高 level 的过程，这个过程与flush过程类似，也是通过迭代器将多个 sst 文件的 key 进行 merge，遍历 key 然后创建 sst 文件。flush 的触发条件是 immutable memtable 的数量是否超过了 min_write_buffer_number_to_merge，而 compaction 的触发条件是两类：文件个数和文件大小。对于level0，触发条件是 sst 文件个数，通过参数`level0_file_num_compaction_trigger`控制，score 通过 sst 文件数目与 `level0_file_num_compaction_trigger`的比值得到。level1 - levelN 触发条件是 sst 文件的大小，通过参数`max_bytes_for_level_base`和`max_bytes_for_level_multiplier`来控制每一层最大的容量，score 是本层当前的总容量与能存放的最大容量的比值。rocksdb 中通过一个任务队列维护 compaction 任务流，通过判断某个 level 是否满足 compaction 条件来加入队列，然后从队列中获取任务来进行 compact。compaction 的主要流程如下：

1. <font color=red>首先找score最高的level，</font>如果level的score>1，则选择从这个level进行compaction

2. <font color=red>根据一定的策略，</font>从level中选择一个sst文件进行compact，对于level0，由于sst文件之间(minkey,maxkey)有重叠，所以可能有多个。

3. 从level中选出的文件，我们能计算出(minkey, maxkey)

4. 从level+1中选出与(minkey,maxkey)有重叠的sst文件

5. 多个sst文件进行**归并排序**，合并写出到sst文件

6. 根据<font color=red>压缩策略</font>，对写出的sst文件进行压缩

7. 合并结束后，利用 VersionEdit 更新 VersionSet，更新统计信息

## Universal Compaction

前面介绍的compaction类型是level compaction，在rocksdb中还有一类compaction，称之为Univeral Compaction。Univeral模式中，所有的sst文件都可能存在重叠的key范围。对于R1,R2,R3,...,Rn,每个R是一个sst文件，R1中包含了最新的数据，而Rn包含了最老的数据。合并的前提条件是sst文件数目大于level0_file_num_compaction_trigger，如果没有达到这个阀值，则不会触发合并。在满足前置条件的情况下，按优先级顺序触发以下合并。

1. 如果空间放大超过一定的比例，则所有sst进行一次compaction，所谓的full compaction，通过参数max_size_amplification_percent控制。

2. 如果前size(R1)小于size(R2)在一定比例，默认1%，则与R1与R2一起进行compaction，如果（R1+R2)*(100+ratio)%100<R3，则将R3也加入到compaction任务中，依次顺序加入sst文件

3. 如果第1和第2种情况都没有compaction，则强制选择前N个文件进行合并。

​      相对于level compaction，Univeral compaction由于每一次合并的文件较多，相对于level compaction的多层合并，写放大较小，付出的代价是空间放大较大。除了前面介绍的level compaction和univeral compaction，rocksdb还支持一种FIFO的compaction。FIFO顾名思义就是先进先出，这种模式周期性地删除旧数据。在FIFO模式下，所有文件都在level0，当sst文件总大小超过阀值max_table_files_size，则删除最老的sst文件。整个compaction是LSM-tree数据结构的核心，也是rocksDB的核心，本文梳理了几种compaction方式的基本流程，里面还有很多的细节没有涉及到，有兴趣的同学可以在本文的基础上仔细阅读源码，加深对compaction的理解。



## 归并排序

```c++
#include <iostream>
#include <cstdio>

void MergeSort(int pInt[10], int elements);

void Merge(int *pInt, int *l, int mid, int *r, int i);

using namespace std;

int main() {
    int A[] = {6, 2, 3, 1, 9, 10, 15, 13, 12, 17};
    int i, numberOfElements;
    numberOfElements = sizeof(A) / sizeof(A[0]);
    MergeSort(A, numberOfElements);
    for (i = 0; i < numberOfElements; i++) {
        cout << " " << A[i];
    }
    return 0;
}

void MergeSort(int *A, int n) {
    int mid, i, *L, *R;
    if(n < 2) return; // 当数组中的元素小于 2 时，结束递归。
    mid = n / 2;
    L = new int[mid];
    R = new int[n - mid];
    for (i = 0; i < mid; i++) {
        L[i] = A[i];
    }
    for (i = mid; i < n; i++) {
        R[i - mid] = A[i];
    }
    MergeSort(L, mid);
    MergeSort(R, n - mid);
    Merge(A, L, mid, R, n - mid);
    delete [] R;
    delete [] L;
}

void Merge(int *A, int *L, int leftCount, int *R, int rightCount) {
    int i, j, k;
    i = 0; j = 0; k = 0;
    while(i < leftCount && j < rightCount){
        if(L[i] < R[j])
            A[k++] = L[i++];
        else
            A[k++] = R[j++];
    }
    while(i < leftCount) A[k++] = L[i++];
    while(j < rightCount) A[k++] = R[j++];
}
```

