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

### 2.自连接的用法
>`SQL`通常在不同的表或者视图间进行连接运算，但是也可以对相同的表进行”自连接“运算。自连接的处理过程不太容易想象，因此人们常常对其敬而远之。但是，如果能够熟练掌握，就会发现它是非常方便的技术。

| name（商品名称） | price（商品价格）     |
| ---------------- | --------------------- |
| apple            | 50                    |
| banana           | 100                   |
| cherry           | 80                    |
| cherry           | 80（用于去重SQL语法） |

若要对`fruits`表进行任意排序，生成其对应的笛卡尔积，`3 * 3 = 9`也就是`9`种排列组合的结果：

```sql
select f1.name as name_1, f2.name as name_2 from fruits f1, fruits f2;
```

当要排除一个重复组合`apple apple`、以及只出现一次的重复组合`apple banana`和`banana apple`：

```sql
select f1.name as name_1, f2.name as name_2 from fruits f1, fruits f2 
	where f1.name > f2.name;
```

使用关联子查询删除重复行的方法，当重复的列里不包含主键时就可以使用主键进行处理。但当存在所有列都重复时，则需要使用数据库独立实现的行`ID`，这里的行`ID`可以理解成拥有“任何表都可以使用的主键”这种特征的虚拟列（如`oracle`数据库的`rowid`）：

```sql
delete from fruits f1 where rowid < (
    select max(f2.rowid) from fruits f2 where p1.name = p2.name and p1.price = p2.price
);
```

或者使用非等值连接删除重复行的`SQL`:

```sql
delete from fruits f1 where exists (
	select * from fruits f2 where f1.name = f2.name and f1.price = f2.price 
    	and f1.rowid < f2.rowid  
);
```

当用来查找局部不一致的列时，可以通过非等值自连接进行查询，此处`distinct`关键字不能进行省略：

```sql
select distinct a1.name, a2.name from address a1, address a2 
	where a1.family_id = a2.family_id and a1.address <> a2.address; 
```

当使用数据库制作各种票据和统计表工作时，经常会遇到按分数、人数和销售额等数值进行排序的需求。可以按照价格从高到低的顺序进行排序：

```sql
select p1.name, p1.price, 
	(select count(p2.price) from product p2 where p2.price > p1.price) + 1 as rank_1
	from product p1 order by rank_1;
```

此外，对于一些需要以左表作为基础按条件进行组合的情况可以使用`left outer join`进行自连接：

```sql
 select p1.name, 
		max(p1.price) as price, 
		count(p2.name) + 1 as rank_1
	from product p1 left outer join product p2 on p1.price < p2.price
	group by p1.name order by rank_1; 
```

