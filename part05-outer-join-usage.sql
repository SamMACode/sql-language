-- 1. 用外连接进行行列转换(1)(行->列): 制作交叉表
select c0.name,
    case when c1.name is not null then 'ok' else null end as 'SQL入门',
    case when c2.name is not null then 'ok' else null end as 'UNIX基础',
    case when c3.name is not null then 'ok' else null end as 'Java中级'
from (select distinct name from courses) c0     -- 这里是c0的侧边栏
left outer join 
    (select name from courses where course = 'SQL入门') c1 
    on c0.name  = c1.name
        left outer JOIN
            (select name from courses where course = 'UNIX基础') c2
            on c0.name = c2.name
                left outer join 
                    (select name from courses where course = 'Java中级') c3
                        on c0.name = c3.name;

/* 2.水平展开：使用表量子查询 */
select c0.name,
    (select 'ok' from courses c1 
        where course = 'SQL入门' and c1.name = c0.name) as 'SQL入门',
    (select 'ok' from courses c2
        where c2.course = 'UNIX基础' and c2.name = c0.name) as 'UNIX基础',
    (select 'ok' from courses c3
        where course = 'Java中级' and c3.name = c0.name) as 'Java中级'
    -- 利于需求变更：当想再加上php入门课程时
    /*(select 'ok' from courses c4
        where course = 'PHP入门' and c3.name = c0.name) as 'PHP入门'*/    
    from (select distinct name from courses) c0;    -- 这里的c0是指侧边栏   

 /* 3.水平展开(3): 嵌套使用case表达式 */
 select name,
    case when sum(case when course = 'SQL入门' then 1 else null end) = 1
        then 'ok' else null end as 'SQL入门',
    case when sum(case when course = 'UNIX基础' then 1 else null end) = 1
        then 'ok' else null end as 'UNIX基础',
    case when sum(case when course = 'Java中级' then 1 else null end) = 1
        then 'ok' else null end as 'Java中级'        
    from courses group by name;  

/* 2.用外连接 进行行列转换(2) (列->行): 汇总重复项于一列, union all 不会排除掉重复的行 */
select employee, child_1 as child from personnel
union ALL
select employee, child_2 as child from personnel
union all 
select employee, child_3 as child from personnel;

/* 生成员工子女表图, 先创建一个children的view视图，通过union进行去重 */
create view children(child)
as select child_1 from personnel
    UNION
    select child_2 from personnel
    union 
    select child_3 from personnel;

-- 获取员工子女列表的sql语句（没有孩子的员工也要输出）
select emp.employee,  children.child from personnel emp 
    left outer join children 
    on children.child in (emp.child_1, emp.child_2, emp.child_3); 
/* sql result:
employee|child|
--------|-----|
赤井      |一郎   
工藤      |春子   
工藤      |夏子   
铃木      |夏子   
赤井      |二郎   
赤井      |三郎   
吉田      |     |*/  