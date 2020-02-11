# SQL进阶教程

学习`SQL`进阶的一些语法，提升自己的`SQL`基础知识和技能。`SQL`语法较为通用，在后续学习`Spark SQL`、`Hive SQL`时会使用到。

### 1. CASE表达式使用

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
有数据表美国各主要城市人口`main_city_population`，需使用`CASE`表达式完成高级查询（`sexual`中`1`表示男性、`2`表示女性），其中对于城市`houston`、`los angeles`属于西部地区，`chicago`则属于东部地区：
| CITY_NAME   | SEXUAL | POPULATION |
| ----------- | ------ | ---------- |
| houston     | 1      | 30         |
| houston     | 2      | 35         |
| los angeles | 1      | 40         |
| los angeles | 2      | 46         |
| chicago     | 1      | 42         |
| chicago     | 2      | 45         |

按东、西部地区统计其总人数的`SQL`查询语句，该语句简化部分在于`group by area`，将`case`判断之后的值直接作为分组的依据。严格来讲这种写法违反`SQL`的规则，事实上`MySQL`和`PostgreSQL`是支持这种写法的。在`GROUP BY`子句里使用`CASE`表达式，可以灵活地选择作为聚合的单位的编号或等级，这一点在进行非定制化统计时能发挥巨大的威力：

```sql
select case city_name 
			when 'houston' then 'west'
			when 'los angeles' then 'west'
            when 'chicago' then 'east'
       else 'other' end as area, sum(population)
	   from main_city_population group by area;
```

用一条`SQL`语句进行不同条件的统计，将"行结构"的数据转换为“列结构”的数据，`SUM`、`AVG`、`COUNT`等聚合函数都可以用于将行结构数据转换成列结构数据：

```sql
select city_name,
	sum(case when sexual = '1' then population else 0 end) as cnt_male,
    sum(case when sexual = '2' then population else 0 end) as cnt_female
    from main_city_population group by city_name;
```

此外，在对数据表进行`update`若存在多个条件分支时，分别执行两个`update`操作好像能做到，但这样会存在问题。可以使用`case`语句用一条语句正确的更新数据，如下在`case`中根据不同条件更新工资：

```sql
update salaries 
	set salary = case when salary > 30000 then salary * 0.9
		when salary >= 25000 and salary < 28000 then salary * 1.2
    	else salary end;
```

对于两表之间的数据匹配，将两张关联表中的数据进行汇总然后生成报表（主课程表和开设的课程时间），在主`SQL`中其会查询所有主课程信息，其根据`course_id`关联将课程时间展示在列表中：

```sql
select CM.course_name,
	case when exists(
    	select course_id from openCourse OC where month = 200706 and OC.course_id = CM.course_id
   	) then 'ok' else 'none' end as 'june',
	case when exists(
    	select course_id from openCourse OC where month = 200707 and OC.course_id = CM.course_id
   	) then 'ok' else 'none' end as 'july',
	case when exists(
    	select course_id from openCourse OC where month = 200708 and OC.course_id = CM.course_id
   	) then 'ok' else 'none' end as 'august',    
    from CourseMaster CM;
```

在`CASE`表达式中使用聚合函数，从学生主表找到学生的主社团的`SQL`，想比依赖于具体数据库的函数，`CASE`表达式有更强的表达能力和更好的移植性：

```sql
select std_id,
	case when count(*) = 1 then max(club_id),
		 else max (case when main_club_flag = 'Y' then club_id else null end)
	end as main_club 
	from StudentClub group by std_id;
```



