declare @dangYy smallint
declare @ymd_1 varchar(10)
declare @ymd_2 varchar(10)
declare @acCode varchar(20)
declare @custCode varchar(6)

set @dangYy = year(getdate())
set @ymd_1 = cast(@dangYy-1 as char(4)) + '-01-01'
set @ymd_2 = cast(@dangYy as char(4)) + '-12-31'

set @acCode =  '111-04-01-0' --// 외상매출금
set @custCode = 'AS_4'   --//대전아스콘
--set @custCode = 'RM_9'  --// 울산레미콘

select distinct U.cust_code
into #tmp_1
from cm_connect_user U, cm_connect_program P
where U.cust_code like @custCode + '%'
and P.program_no = 6 --// 조합 쓰는 회원사만 조회
and U.cust_code = P.cust_code
and U.user_id = P.user_id

select S.cust_code, S.yy, null ymd, cast(S.yy-1 as char(4)) + '년도 이월금액' jeokyo, '이월' jongryu, isnull(S.cr_geumaek,0) cr_geumaek, isnull(S.dr_geumaek,0) dr_geumaek
into #tmp_2
from #tmp_1 T, ac_sisan_cust S
where S.ac_code =@acCode
and S.yy = @dangYy-1
and S.cust_code = T.cust_code

select J.cust_code, year(J.ymd) yy, J.ymd, J.jeokyo, case when J.jongryu = 3 then '미수'  when J.jongryu = 4 then '입금' end jongryu, 
case when J.jongryu = 3 then geumaek else 0 end cr_geumaek, case when J.jongryu = 4 then geumaek else 0 end dr_geumaek
into #tmp_3
from #tmp_1 T, ac_jeonpyo J
where J.ac_code =@acCode
and J.ymd >= @ymd_1
and J.ymd <= @ymd_2
and J.cust_code = T.cust_code

select * into #tmp_4 from #tmp_2 union all
select * from #tmp_3

select cust_code, yy, sum(cr_geumaek) cr_geumaek, sum(dr_geumaek) dr_geumaek, sum(cr_geumaek) -  sum(dr_geumaek) geumaek, grouping(cust_code) gubunAll, grouping(yy) gubunCust
into #tmp_5
from #tmp_4
group by cust_code, yy
with rollup

select *
into #tmp_6
from #tmp_5
where gubunAll = 0  --// 
and gubunCust = 1 --// 업체별 합계 중에
and geumaek >= 198000  --// 6개월분 이상 (1달 3만원 / 분기 9만원)

declare @SelectCust varchar(7)
set @SelectCust = @custCode + '' 

--// 업체별 
select C.sangho cust_name, T.*
from #tmp_6 T left outer join cm_cust C 
on C.cust_code = T.cust_code
where T.cust_code like @SelectCust + '%'
order by T.gubunAll, T.cust_code, T.gubunCust, T.yy

--// 업체별 년도 
select C.sangho cust_name, T.*
from #tmp_5 T left outer join cm_cust C 
on C.cust_code = T.cust_code
where T.cust_code like @SelectCust + '%'
order by T.gubunAll, T.cust_code, T.gubunCust, T.yy

--// 업체별 내역
select C.sangho cust_name, T.*
from #Tmp_4 T left outer join cm_cust C 
on C.cust_code = T.cust_code
where T.cust_code like @SelectCust + '%'
order by T.cust_code, T.yy, T.ymd

drop table #tmp_1
drop table #tmp_2
drop table #tmp_3
drop table #tmp_4
drop table #tmp_5
drop table #tmp_6
