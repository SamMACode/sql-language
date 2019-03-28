### sqlTbl table
create table seqtbl (
  seq integer comment 'sequence',
  name varchar(20) comment 'name'
)charset=utf8;
insert into seqtbl(seq, name) values(1, '迪克'), (2, '安'), (3, '莱露'), (5, '卡'), (6, '玛丽'), (8, '本');

## 1) whether exists not found pageId
select '存在缺失的编号' as gap from seqtbl having count(*) <> max(seq);

## 2) find min not found pageId
select min(seq+1) as gap from grammer.seqtbl where (seq+1) not in (
  select seq from grammer.seqtbl
);

### graduates tables
create table graduates (
  name varchar(20) comment 'student name',
  income integer comment 'income'
) charset=utf8;
insert into graduates(name, income) values('桑普森', 40000), ('迈克', 30000),('怀特', 20000),('阿诺德', 20000),
('史密斯', 20000), ('劳伦斯', 15000), ('哈德逊', 15000), ('肯特', 10000), ('贝克', 10000), ('斯科特', 10000);

## 3) finding most students income
select income, count(*) as cnt from grammer.graduates group by income
having count(*) >= all(
  select count(*) from grammer.graduates group by income
);

## 4) exclude null value (using extra function)
select income, count(*) as cnt from grammer.graduates group by income
having count(*) >= (
  select max(cnt) from (
    SELECT count(*) AS cnt FROM grammer.graduates group by income
  ) as tmp
);

## 5) middle student income
select avg(distinct income) from (
  select t1.income from grammer.graduates t1, grammer.graduates t2 group by t1.income
      -- s1 judging condition
      having sum(case when t2.income >= t1.income then 1 else 0 end) >= count(*)/2
      -- s2 judging condition
      and sum(case when t2.income <= t1.income then 1 else 0 end) >= count(*)/2
)tmp;

### students count(*) and count(null) difference
create table students (
  student_id integer comment 'student id',
  dpt varchar(20) comment 'dpt id',
  sbmt_date varchar(20) comment 'sbmt_date'
)charset=utf8;
insert into students(student_id, dpt, sbmt_date) values (100, '理学院', '2005-10-10'), (101, '理学院', '2005-09-22'),
  (102, '文学院', null), (103, '文学院', '2005-09-22'), (200, '文学院', null), (202, '经济学院', '2005-09-25');

## 6) all student which submit all task
select dpt from grammer.students group by dpt having count(*) = count(sbmt_date);

## 7) using case statement
select dpt from grammer.students group by dpt having count(*) = sum(
  case when sbmt_date is null then 0 else 1
  end
);

### table: items/  relation division
create table grammer.items(
  item varchar(20) comment 'item name'
) charset=utf8;
insert into grammer.items(item) values('啤酒'), ('纸尿裤'), ('自行车');

create table grammer.shopitems(
  shop varchar(20) comment 'shop name',
  item varchar(20) comment 'item name'
) charset=utf8;
insert into grammer.shopitems(shop, item) values('仙台', '啤酒'),('仙台', '纸尿裤'),('仙台', '自行车'),('仙台', '窗帘'),
  ('东京', '啤酒'), ('东京', '纸尿裤'), ('东京', '自行车'),('大阪', '电视'), ('大阪', '纸尿裤'),('大阪', '自行车');

## 8) find shop which have all items
select sitem.shop from grammer.shopitems sitem, grammer.items item
where sitem.item = item.item group by sitem.shop
# juding by item number (warning: must using count(item))
having count(sitem.item) = (select count(item) from grammer.items);

## 9) exact divide method
select sitem.shop from grammer.shopitems sitem left outer join grammer.items item on sitem.item = item.item
group by sitem.shop
having count(sitem.item) = (select count(item) from grammer.items)
  # null value will be filter
and count(item.item) = (select count(item) from grammer.items);