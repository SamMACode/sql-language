# SQL进阶教程

学习`SQL`进阶的一些语法，提升自己的`SQL`基础知识和技能。`SQL`语法较为通用，在后续学习`Spark SQL`、`Hive SQL`时会使用到。

### 1. CASE表达式

> 在`SQL`里表达式条件分支：`CASE`表达式是`SQL`里非常重要而且使用起来非常便利的技术，我们应学会用其来描述条件分支。可用于行列转换、已有数据重分组（分类）、与约束的结合使用、针对聚合结果的条件分支等。

`CASE`表达式的语法可分为简单`CASE`表达式、搜索`CASE`表达式两种，在编写`CASE`表达式时需注意：统一各分支返回的数据类型、不能忘了写`END`、养成写`ELSE`子句的习惯。


```sql
-- syntax one: 简单CASE表达式, case value的表达式结构
case value 
	when assume_value1 then expression1
	when assume_value2 then expression2
else expression3 end	

-- syntax two: 搜索CASE表达式
case when value = assume_value1 then expression1
	 when value = assume_value2 then expression2
else expression3 end	 
```

