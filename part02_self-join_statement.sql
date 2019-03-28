# 1.create table district and init data
# tableName: product
# tableField: name, price
create table product (
  name varchar(20) comment 'product name',
  price float comment 'product price'
)charset=utf8;
insert into product values('苹果', 50), ('橘子', 100), ('香蕉', 80);

# joining with 2 tables
select p1.name as name_p1, p2.name as name_p2 from product p1, product p2;
# joining with tables with sorting
select p1.name as name_p1, p2.name as name_p2 from product p1, product p2 where p1.name <> p2.name;
# joining 2 tables with direction
select p1.name as name_p1, p2.name as name_p2 from product p1, product p2 where p1.name > p2.name;

## remove duplicate row from database
## 1) there are 2 ways
delete from product p1 where rowid < (
    select max(p2.rowid) from product p2
    where p2.name = p1.name and p1.price = p2.price
);

## 2) using another way to remove duplicate row
delete from product p1
    where exists(
        select * from product p2
          where p1.name = p2.name and p1.price = p2.price and p1.row_id < p2.row_id
    );

# 2.create table japan_address and init data
# tableName: japan_address
# tableField: name, family_id, address
create table japan_address (
  name varchar(20) comment 'family member name',
  family_id integer comment 'family id',
  address varchar(200) comment 'address'
) charset=utf8;
insert into japan_address values('前田义明', 100, '东京都港区虎之门3-2-29'),
  ('前田由美', 100, '东京都港区虎之门3-2-92'), ('加藤茶', 200, '东京都新宿区西新宿2-8-1'),
  ('加藤胜', 200, '东京都新宿区西新宿2-8-1'), ('福尔摩斯', 300, '贝克街221B'), ('华生', 300, '贝克街221B');

## finding same family_id but different address
select DISTINCT jap1.family_id, jap1.address from japan_address jap1, japan_address jap2
where jap1.family_id = jap2.family_id
and jap1.address <> jap2.address;

### 2, find all product which has same price
select distinct p1.name, p1.price from product p1, product p2
  where p1.price = p2.price and p1.name <> p2.name;

### 3.sort table with target field
select p1.name, p1.price,
  (select count(p2.price) from product p2 where p2.price > p1.price) + 1 as rank_1
from product p1 order by rank_1;

### 4.sort table with
select p1.name, max(p1.price) as price, count(p2.name) + 1 as rank_1
from product p1 left outer join product p2 on p1.price < p2.price
  group by p1.name
  order by rank_1;

### 5.not aggregate
select p1.name, p2.name from product p1 left outer join product p2
  on p1.price < p2.price;

### 6.change to inner join
select p1.name, max(p1.price) as price, count(p2.name)+1 as rank_1
  from product p1 inner join product p2 on p1.price < p2.price
  group by p1.name order by rank_1;

### 5.not aggregate
select p1.name, p2.name from product p1 left outer join product p2
    on p1.price < p2.price;

### 4.sort table with
select p1.name, max(p1.price) as price, count(p2.name) + 1 as rank_1
from product p1 left outer join product p2 on p1.price < p2.price
group by p1.name
order by rank_1;