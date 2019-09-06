LeetCode
===

## 1

### 题目描述

给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。

你可以假设每种输入只会对应一个答案。但是，你不能重复利用这个数组中同样的元素。

示例:

```
给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]
```
### 暴力解题

```C++
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        int i,j;
        for(i=0;i<nums.size()-1;i++){
            for(j=i+1;j<nums.size();j++){
                if(nums[i]+nums[j]==target){
                   return {i,j};
                }
            }
        }
        return {};
    };
};
```
- 注意返回的形式为 {i, j}，返回类型为 `vector<int>`，可见 C++ 允许这样的操作。
- 一波 vector<> 的使用：
```C++
#include <iostream>
#include <vector>
using namespace std;
int main() {
    vector<int> v;
    int i;
    vector<int>::iterator it; // 这样使用。
    for (i = 0; i < 10; i++) {
        v.push_back(i); // 添加。
    }
    for (it = v.begin(); it != v.end(); it++) {
        cout << *it << " "; // 读取，记住读内容，使用 *。
        cout << endl;
    }

	v.erase(v.begin()); // 删除 vector 中的第一个元素。
	v.insert(v.begin(), 999); // 将 999 添加到开始。

	cout<<v.size()<<endl; // 看一下数组的大小。
	v.clear(); // 清空数组。

    return 0;
}
```
- 一波 map<> 的使用：
```C++
#include <map>
...
map<int, int> m;
    m[1] = 19; // 还是这样的添加比较好用。
    m[2] = 18;
    m[3] = 17;
    m.insert(map<int, int>::value_type(4, 16));
    map<int, int>::iterator it;
    it = m.begin();
    cout << it->first << "-" << it->second << endl;

    it = m.find(3); // 注意查找的是 key 值，而不是 value 值。
    cout << it->first << " " << it->second << endl;

	m.erase(it); // 元素的删除。

	map<int, int> map2 = {{1,2}, {2, 4}}; // 这样也可以。
```
### 两遍哈希表
该方法用map实现，map是STL的一个关联容器，它提供一对一（其中第一个可以称为关键字，每个关键字只能在map中出现一次，第二个可能称为该关键字的值）的数据处理能力

```C++
class Solution {
public:
    vector<int> twoSum(vector<int> &nums, int target) {
        map<int, int> a;//建立hash表存放数组元素
        vector<int> b(2, -1);//存放结果
        for (int i = 0; i < nums.size(); i++)
            a.insert(map<int, int>::value_type(nums[i], i));
        for (int i = 0; i < nums.size(); i++) {
            if (a.count(target - nums[i]) > 0 && (a[target - nums[i]] != i))
                //判断是否找到目标元素且目标元素不能是本身
            {
                b[0] = i;
                b[1] = a[target - nums[i]];
                break;
            }
        }
        return b;
    };
};
```
### 一遍哈希表
在进行迭代并将元素插入到表中的同时，我们还会回过头来检查表中是否已经存在当前元素所对应的目标元素。如果它存在，那我们已经找到了对应解，并立即将其返回。
```C++
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        map<int,int> a;//提供一对一的hash
        vector<int> b(2,-1);//用来承载结果，初始化一个大小为2，值为-1的容器b
        for(int i=0;i<nums.size();i++)
        {
            if(a.count(target-nums[i])>0)
            {
                b[0]=a[target-nums[i]];
                b[1]=i;
                break;
            }
            a[nums[i]]=i;//反过来放入map中，用来获取结果下标
        }
        return b;
    };
};
```