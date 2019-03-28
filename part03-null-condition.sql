## 1)students table
create table students(
  name varchar(20) comment 'student name',
  age integer comment 'student age'
)charset=utf8;
insert into students(name, age) values('布朗', 22), ('拉里', 19), ('约翰', null),('伯杰', 21);

## using is null to judge empty value
select * from grammer.students where age is null or age <> null;
## find all students record
select * from grammer.students where age = 20 or age <> 20 or age is null;

## 2) not exist or not in
create table class_a (
  name varchar(20) comment 'student name',
  age integer comment 'student age',
  city varchar(100) comment 'student address'
)charset=utf8;
insert into class_a(name, age, city) values('布朗', 22, '东京'), ('拉里', 19, '琦玉'), ('伯杰', 21, '千叶');
create table class_b (
  name varchar(20) comment 'student name',
  age integer comment 'student age',
  city varchar(20) comment 'address'
)charset=utf8;
insert into class_b(name, age, city) values('齐腾', 22, '东京'), ('田久', 23, '东京'), ('山田', null,'东京'),
('和泉', 18,'千叶'), ('武田', 20,'千叶'), ('石川', 19,'神奈川');

## (not in) and (not exist) expression
## finding all students in class_a who's age not (23, 22, null)
select * from grammer.class_a where age not in (
  select age from grammer.class_b where class_b.city = '东京'
);

## 1.finds all age list
select * from grammer.class_a where age not in (22, 23, null);

## 2.finds all not and in expression
select * from grammer.class_a where not age in (22, 23, null);

## 3.using or instead of in expression
select * from grammer.class_a where not ((age = 22) or (age = 23) or (age = null));

## 4.using morgan principle
select * from grammer.class_a where not(age = 22) and not(age = 23) and not(age = null);

## 5.using <> instead of 'not' and '=' operator
select * from grammer.class_a where (age <> 22) and (age <> 23) and (age <> null);

## 6.using unknown
select * from grammer.class_a where (age <> 22) and (age <> null) and unknown;

## using exist in condition
select * from grammer.class_a where not exists (
  select * from grammer.class_b
  where class_a.age = class_b.age
        and class_b.city = '东京'
);

### 3.SQL 'all' usage:
update grammer.class_b set age = 20 where name = '山田';
## class_a student name who's age is less than class_b
select * from grammer.class_a where class_a.age < all(
  select age from grammer.class_b where class_b.city = '东京'
);

## using min() or max() to filter null value
select * from grammer.class_a where age < (
  select min(age) from grammer.class_b where city='东京'
);

### 4. SQL using 'aggregate' function
select * from grammer.class_a where age < (select avg(age) from class_b where city = '东京');
