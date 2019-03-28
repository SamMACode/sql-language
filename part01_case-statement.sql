# 1.create table district and init data
# tableName: district
# tableField: pref_name, population
create table district (
  pref_name varchar(20),
  population integer
) charset=utf8;
show tables;
drop table district;
insert into district values('德岛', 100), ('香川', 200), ('爱媛', 150),
  ('高知', 200), ('福冈', 300), ('佐贺', 100), ('长崎', 200),
  ('东京', 400), ('群马', 50);

# 2.group by pref_name field and sum all population
select case pref_name
          when '德岛' then '四国'
          when '香川' then '四国'
          when '爱媛' then '四国'
          when '高知' then '四国'
          when '福冈' then '九州'
          when '佐贺' then '九州'
          when '长崎' then '九州'
      else '其他' end as gp_field,
      sum(population) from district group by gp_field;

# 3.group by population and sum state num
select case when population < 100 then '01'
            when population >= 100 and population < 200 then '02'
            when population >= 200 and population < 300 then '03'
            when population >= 300 then '04'
       else null end as pop_class,
       count(*) as cnt
    from district group by pop_class;

# 4.create table district_sex and init data
# tableName: district_sex
# tableField: pref_name, population
create table district_sex (
  pref_name varchar(20),
  population integer,
  sex integer
) charset=utf8;
insert into district_sex values('德岛', 60, 1), ('德岛', 40, 2), ('香川', 100, 1), ('香川', 100, 2),
  ('爱媛', 100, 1), ('爱媛', 50, 2),
  ('高知', 100, 1), ('高知', 100, 2),
  ('福冈', 200, 1), ('福冈', 100, 2);

# group by pref_name field, count population.
# when using group, other field must use aggregate function.
select pref_name,
  sum(case when sex = 1 then population else 0 end) as man_cnt,
  sum(case when sex = 2 then population else 0 end) as woman_cnt
from district_sex group by pref_name;

# using case when for constraint field
# constraint check_salary check (
#     case when sex = '2' then
#             case when salary <= 200000 then 1
#               else 0
#             end
#          else 1
#     end = 1
# );

# 5.update using case when
# tableName: salaries
# tableField: name, salary
create table salaries (
  name varchar(30),
  salary int
)charset=utf8;
insert into salaries values('相田', 300000), ('神崎', 270000), ('木村', 220000), ('齐腾', 290000);

# update table field using case
update salaries
  set salary = (case when salary >= 300000 then salary * 0.9
                     when salary >= 250000 and salary < 280000 then salary*1.2
                     else salary
                end);

# change master table primary key value(using case)
update sometable
  set p_key = (case when p_key = 'a' then 'b'
                    when p_key = 'b' then 'a'
                    else p_key
               end);

# 6.match data from different table
# tableName: course_master
# tableField: course_id, course_name
create table course_master(
  course_id integer,
  course_name varchar(200)
) charset=utf8;
insert into course_master values(1, '会计入门'), (2, '财务知识'), (3, '簿籍考试'), (4, '税务师');

# tableName: open_course
# tableField: month, course_id
create table open_course(
  month varchar(20),
  course_id integer
)charset=utf8;
insert into open_course values('200706', 1), ('200706', 3), ('200706', 4), ('200707', 4), ('200708', 2), ('200708', 4);

## 7.query field by ["course_name", "6month", "7month", "8month"]
## using in operator
select course_name,
    case when course_id in (select course_id from open_course where month = '200706') then true
         else false
    end as 6_month,
    case when course_id in (select course_id from open_course where month = '200707') then true
         else false
    end as 7_month,
    case when course_id in (select course_id from open_course where month = '200708') then true
         else false
    end as 8_month
from course_master;

## 8.query field by ["course_name", "6month", "7month", "8month"]
## using exists operator
select course_name,
  case when exists(select course_id from open_course oc where month = '200706' and oc.course_id = cm.course_id) then true
       else false
  end as 6_month,
  case when exists(select course_id from open_course oc where month = '200707' and oc.course_id = cm.course_id) then true
  else false
  end as 7_month,
  case when exists(select course_id from open_course oc where month = '200708' and oc.course_id = cm.course_id) then true
  else false
  end as 8_month
from course_master cm;

# 10.match data from different table
# tableName: course_master
# tableField: course_id, course_name
create table student_club (
  std_id integer,
  club_id integer,
  club_name varchar(200),
  main_club_flag boolean
)charset=utf8;
# init student_club data
insert into student_club values(100, 1, '棒球', true),
  (100, 2, '管弦乐', false), (200, 2, '管弦乐', false),
  (200, 3, '羽毛球', true), (200, 4, '足球', false),
  (300, 4, '足球', false), (400, 5, '游泳', false),
  (500, 6, '围棋', false);

# query with condition:
# 1) main club only join one club
select std_id, max(club_id) as main_club_id from student_club group by std_id having count(*) = 1;
# 2) main club when student join many clubs
select std_id, club_id as main_club_id from student_club where main_club_flag = true;

## merge query condition:
# group by std_id and then filter with main_club_flag field;
select std_id,
       case when count(*) = 1 then max(club_id)
            else max(case when main_club_flag = true then club_id else null end)
       end as main_club
from student_club group by std_id;