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

### 2. 自连接的用法
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

关于编写`SQL`时`Null`和三指逻辑问题，不同于大多数编程语言，`SQL`语言则采用一种特别的逻辑体系——三值逻辑，即逻辑真值除了真和假，还有第三个值“不确定”。三值逻辑经常会带来一些想象不到的情况，致使`SQL`的查询结果与预期不一致。在对于`null`上应使用`is null`作为判断条件，例句：

```sql
select * from class_a where age < all (
	select age from class_b where city = 'tokyo'
);
```

这条语句在`class_b`表中不存在`age`为`null`的字段时，查询返回的数据是正常的。当`age`中存在`null`值时，是查询不到任何数据记录的。在这种情况下，可以使用极值函数在统计时把为`null`的数据排除过滤掉。解决`null`带来的各种问题，最佳方法应该是往表里添加`not null`约束来尽力排除`null`：

```sql
select * from class_a where age < all (
	select MIN(age) from class_b where city = 'tokyo'
);
```

### 3. HAVING子句的力量
> `Having`子句是`SQL`里一个非常重要的功能，但其价值并没有被人们深刻地认识。另外，它还是理解`SQL`面向集合这一本质的关键，应用范围非常广泛。在学习`Having`子句的用法时，进而理解面向集合语言的第二个特性——以集合为单位进行操作。 

在正常的思维逻辑中，`having`子句通常是`group by`分组语句一起使用的。按照现在的`SQL`标准来说，`having`子句是可以单独使用的，可以认为是对空字段进行了`group by`的操作，只不过省略了`group by`子句。

用`having`子句进行子查询—求众数，若存在毕业生表`graduates`中存在`name`、`income`字段表示毕业生的工作收入，现需找出年薪资在哪个值的学生最多：

```sql
select income, count(*) as cnt
	from graduates group by income
	having count(*) >= all (select count(*) from graduates group by income);
```

通过对`income`进行分组，可以分组得到"20000"的有2个人（`jane`和`diana`）。在`all`函数中会出现所有分组，上面的`sql`语句是找出`income`人数最多的分组。

另外一个常见需求是求中位数，它指的是将集合中元素按升序排列后恰好位于正中间的元素。如果集合的元素个数为偶数，则取中间两个元素的平均值作为中位数。其`sql`的编写思路是：将集合里的元素按照大小分为上半部分和下半部分两个子集，同时让这2个子集共同拥有集合正中间的元素。这样，共同部分的元素的平均值就是中位数：

```sql
select avg(distinct income) from (
	select t1.income from graduates t1, graduates t2 group by t1.income
    	having sum(case when t2.income >= t1.income then 1 else 0 end) >= count(*)/2
    	and sum(case when t2.income <1 t1.income then 1 else 0 end) >= count(*)/2
) tmp;
```

查询不包含`null`的集合，`count`函数的使用方法有`count(*)`和`count(column_name)`两种，它们之间的区别：第一是性能上的区别，第二个是`count(*)`可以用于`null`，而`count(column)`与其它聚合函数一样，要先排除掉`null`的行再进行统计。另一种理解方式：`count(*)`查询的是所有行的数目，而`count(column)`查询的规则不一定是这样。下面的`sql`用于统计出所有作业已经上交的`dept`名称：

```sql
select dpt from students group by dpt having count(*) = count(abmt_date);
```

用关系除法运算进行购物篮分析，有商品表`items`、商店商品表`shopitem`，求包含所有商品的商店：

```sql
select si.shop from shopitem si, items i 
	where si.item = i.item group by si.shop
	having count(si.item) = (select count(item) from items)
```

若要进行“精确关系除法”，即只选择没有剩余商品的店铺（与此相对，前一个问题被称为“带余除法”）。解决这个问题需要使用外连接：

``` sql
select si.shop 
	from shopitems si left outer join items i on si.item = i.item
	group by si.shop
	having count(si.item) = (select count(item) from items)
		and count(i.item) = (select count(item) from items);
```

### 4. 外连接的用法

> 数据库工程师经常面对的一个难题是无法将`SQL`语句的执行结果转换为想要的格式，因为`SQL`语言本来就不是为了这个目的而出现的，所以需要费些功夫。将通过格式转换中具有代表性的行列转换和嵌套式侧栏的生成方式，深入理解在其中起着重要作用的外连接。

用外连接进行行列转换（行`->`列），用于制作交叉表。现有课程表`courses`包含`name`（员工姓名）和`course`（课程）两列，表数据为学生及所选课程（同一学生选多门课）。现对表中数据进行格式转换，竖列为学生姓名，横列为所有选择课程：

```sql
select c.name
	case when c1.name is not null then 'true' else 'false' end as 'sql',
	case when c2.name is not null then 'true' else 'false' end as 'unix',
    case when c3.name is not null then 'true' else 'false' end as 'java'
	from (select distinct name from course) c0
	left outer join
		(select name from courses where course = 'sql') c1 
		on c0.name = c1.name
			left outer join
				(select name from courses where course = 'unix') c2
					on co.name = c2.name
						left outer join
							(select name from courses where course = 'java') c3
								on c0.name = c3.name;
```

这种写法具有比较直观和易于理解的优点，但是因为大量用到了内嵌视图和连接操作，代码会显得很臃肿。而且，随着表头列数的增加，性能也会恶化。有一种更好的做法，外连接可以使用标量子查询替代：

```sql
select c0.name,
	(select 'true' from courses c1 
     	where course = 'sql' and c1.name = c0.name) as 'sql',
	(select 'true' from courses c2 
     	where course = 'unix' and c2.name = c0.name) as 'unix',
	(select 'true' from courses c3 
     	where course = 'java' and c3.name = co.name) as 'java'
	from (select distinct name from courses) c0;
```

这里的要点在于使用标量子查询来生成`3`列表头，最后一行`from`子句的集合`c0`和前面的"员工主表"一样，标量子查询的条件和外连接一样。这种做法的优点在于，需要增加或减少课程时，只修改`select`子句即可，代码修改起来比较简单。

用外连接进行行列转换（列`->`行），汇总重复项于一列。现有员工子女信息表`personnel`，第一列`employee`表示员工，`child_1`、`child_2`、`child_3`列为员工的孩子，若员工有多个孩子。现进行行列转换，新表结构存在两列，第一列表示`employee`，第二列表示`child`（若该员工有2个孩子，则共存在两行数据）：

```sql
create view children(child) as select child_1 from personnel
union select child_2 from personnel
union select child_3 from personnel;
```

然后根据新生成的员工子女表进行主表关联，重点在于连接谓词是通过`in`进行指定的：

```sql
select emp.employee, children.child from personnel emp
	left outer join children 
	on children.child in (emp.child_1, emp.child_2, emp.child3);	
```

