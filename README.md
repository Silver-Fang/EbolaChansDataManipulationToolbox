埃博拉酱的MATLAB数据操纵工具包
# ArrayBuilder<handle（MATLAB类）
数组累加器

将数据向内存中积累时，经常遇到需要不断累加数组的问题，MATLAB会提示预分配内存。但如果读取之前无法得知将会有多少项，预分配就会变成一个十分麻烦的动态任务。本类建立一个增长维度，在此维度上可以不断累加一个内置的数组。用户只需不断Append即可，无需考虑内存分配的问题，本类会自动进行优化的内存管理。

构造参数：BuildDimension(1,1)uint8=1，累加维度。数组的这个维度将不断累加增长，其它维度将由第一次Append决定，以后不再改变。
## 只读属性
BuildDimension(1,1)uint8，累加维度

Stock(1,1)uint32，当前在累加维度上的累加数
## 成员方法
### Append
向数组累加新内容

输入参数：New，要累加的内容。第一次可以累加任意内容，以后累加内容可以和第一次在累加维度上尺寸不一致，其它维度必须尺寸一致。
### Harvest
收获累加完毕的MATLAB数组。收获后可以释放本对象，也可以继续累加。

返回值：Array，累加完毕的MATLAB数组。
# DivideEquallyOnDimensionsIntoCells
将一个数组沿指定多个维度尽可能均等地拆分到多个元胞中
```
>> DivideEquallyOnDimensionsIntoCells(rand(3,3,3),2,2)

ans =

  1×2 cell 数组

    {3×1×3 double}    {3×2×3 double}
```
## 输入参数
Array，要拆分的数组

Dimensions(1,:)uint8，要拆分哪些维度

NoDivisions(1,:)uint8，每个维度拆成几份，顺序与Dimensions一一对应
## 返回值
Array cell，拆分后的元胞数组。如果维度尺寸是拆分数的整倍数，将均等拆分；如果不整倍，则将尽可能均等，各分块尺寸最多相差1。
# DelimitedStrings2Table
将一列分隔符字符串的前几个字段读出为表格或时间表
分隔符字符串列如下形式：
```
4003.20210204.BlueBase.All.10%400V_0002.Registered.Measurements.mat
4003.20210204.BlueBase.PV.10%400V_0002.Registered.Measurements.mat
4003.20210204.GreenRef.All.10%400V_0005.Registered.Measurements.mat
4003.20210204.GreenRef.PV.10%400V_0005.Registered.Measurements.mat
```
每行一个字符串，字符串用特定的符号分割成了一系列字段。如果前几个字段有固定的意义且在所有字符串中都存在，则可以将它们读出成表。如果某个字段是时间，还可以读出成时间表。
## 必需参数
Strings(:,1)string，分隔符字符串列

FieldNames(1,:)string，从头开始按顺序排列每个字段的名称。如果有时间字段，直接跳过，不要在FieldNames里指示，也不要留空，而是直接将后面的字段提前上来。

Delimiter(1,1)string，分隔符，将传递给split用于分隔。
## 可选位置参数
TimeField(1,1)uint8=0，时间字段在字符串中是第几个字段。如果设为0，则没有时间字段，返回普通表；否则返回时间表。

DatetimeFormat(1,:)char='yyyyMMddHHmmss'，日期时间格式。不支持含有分隔符的日期时间格式，时间字段字符串必须全为日期时间数字，如"20210306", "202103061723"等。如果实际的字段长度不足，将会自动截短格式字符串以匹配之。将作为datetime函数的InputFormat参数。时间字段在所有字符串之间不需要长度相同。如果TimeField为0，将忽略该参数。
## 返回值
Table(:,:)，如果TimeField为0，返回table，否则返回timetable。
# IntegralSplit
将一个大整数拆分成尽可能相等的多个小整数之和
```
>> IntegralSplit(10,3)

ans =

  3×1 uint8 列向量

   3
   4
   3
```
## 输入参数
Sum(1,1)uint8，要拆分的大整数

NoSplits(1,1)uint8，拆分的份数
## 返回值
Parts(:,1)uint8，拆分后的小整数，其和等于大整数。如果Sum正好是NoSplits的整倍数，这些小整数相等；否则最多相差1。
# StructAggregateByFields
对结构体的每个字段执行累积运算，累积结果放在一个字段相同的结构体标量中返回。
```MATLAB
A(1).a=1;
A(1).b=2;
A(2).a=3;
A(2).b=4;
B=StructAggregateByFields(@cell2mat,A)
```
## 输入参数
AggregateFunction(1,1)function_handle，要执行的累积函数，必须接受一个和StructArray尺寸相同的元胞数组输入

StructArray struct，要累积的结构体数组
## 返回值
(1,1)struct，和StructArray字段相同的结构体标量，保存每个字段各自的累积运算结果。
# SuperCell2Mat
cell2mat的升级版

本函数是cell2mat的升级版，使用前请先参阅cell2mat函数文档，了解其功能和局限性。

cell2mat是一个功能十分强大的MATLAB函数，可以将元胞数组内的数组提取出来，拼成一个大数组，而且这些数组的尺寸不必完全相同，例如可以支持以下拼接：

![](resources/cell2mat.gif)

但它也存在局限性。首先，只支持数值、逻辑、结构体、字符的拼接，其它常见数据类型（字符串、元胞、类对象）都无法使用。其次。对于以下结构，虽然尺寸恰好合适，但也无法拼接：

![](resources/SuperCell2Mat.png)

这是因为cell2mat默认先拼第1维，自然会遇到尺寸不匹配的问题。但我们可以看到，只要先拼第2维，就可以得到1×3和2×3两个矩阵，然后第1维就可以拼接了。本函数不仅支持各种数据类型，还会自动尝试从不同的维度进行拼接，因此支持更多复杂的结构。

输入参数：Cells cell，要拼接的元胞数组，各元胞内含有数据类型一致的数组，且各维尺寸上恰好可以拼接成一个大数组，维度不限。

返回值：拼接好的大数组