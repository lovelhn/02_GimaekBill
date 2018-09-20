use RJ_001
-- 기맥 마지막 접속일자
-- 최초 배정일자 / 마지막 배정일자
-- 최초 청구일자 / 마지막 청구일자

-- select * from JOHAP_DB.Gimaek.dbo.cm_cust where cust_code = 'RM_810'
-- select * from JOHAP_DB.Gimaek.dbo.cm_connect_cust where cust_code = 'RM_810'
-- select * from JOHAP_DB.Gimaek.dbo.cm_connect_user where cust_code = 'RM_810'
-- select * from JOHAP_DB.Gimaek.dbo.cm_connect_program where cust_code = 'RM_810'
--select * from cg_cheonggu_1

declare @johapCode char(6)
declare @startYmd datetime
declare @nowYmd datetime
declare @in_date datetime

set @johapCode = 'RJ_001'
set @startYmd = '2016-01-01'
set @nowYmd = '2018-09-19'
set @in_date = '2009-12-01'  --광역전산망 최초 사용일자

select J.johap_cust_code cust_code, J.cust_code company_code, max(U.connect_ymd) connect_ymd 
into #tmp_1
from JOHAP_DB.Gimaek.dbo.cm_connect_cust J, JOHAP_DB.Gimaek.dbo.cm_connect_user U, JOHAP_DB.Gimaek.dbo.cm_connect_program P
where J.cust_code = U.cust_code
and J.johap_code = @johapCode
and J.cust_code = P.cust_code
and U.user_id = P.user_id
and P.program_no = 6
group by J.johap_cust_code, J.cust_code

select cust_code, min(baejeong_ilja) min_baejeong, max(baejeong_ilja) max_baejeong
into #tmp_2
from bj_baejeong_1
--where baejeong_gubun = 0
group by cust_code

select cust_code, max(cheonggu_ilja) max_cheonggu
into #tmp_3
from cust_cheonggu_1
where cheonggu_ilja <= @nowYmd
group by cust_code

select cust_code into #tmp_4 from #tmp_1 union
select cust_code from #tmp_2 union
select cust_code from #tmp_3

select  J.company_code,T.cust_code, convert(char(10), J.connect_ymd, 120) connect_ymd, convert(char(10), B.min_baejeong, 120) min_baejeong, 
convert(char(10), B.max_baejeong, 120) max_baejeong, convert(char(10), C.max_cheonggu, 120) max_cheonggu
into #tmp_5
from #tmp_4 T
left outer join #tmp_1 J
on J.cust_code = T.cust_code
left outer join #tmp_2 B 
on B.cust_code = T.cust_code
left outer join #tmp_3 C 
on  C.cust_code = T.cust_code

select G.sangho, C.sangho johap_sangho, T.*, convert(char(10), C.in_date, 120) johap_in_date,  convert(char(10), C.out_date, 120) johap_out_date,  
convert(char(10), G.in_date, 120) in_date,  convert(char(10), G.out_date, 120) out_date, 
G.J_sayong_gubun, G.J_sayong_bigo_1, G.J_sayong_bigo_2
--select C.sangho johap_sangho, T.*, convert(char(10), C.in_date, 120) johap_in_date,  convert(char(10), C.out_date, 120) johap_out_date
into #tmp_6
from cm_cust C, #Tmp_5 T left outer join JOHAP_DB.Gimaek.dbo.cm_cust G
on G.cust_code = T.company_code
where C.cust_code = T.cust_code
and T.max_baejeong >= @startYmd
and T.max_cheonggu >= @startYmd
and (G.out_date is null or G.out_date >= @nowYmd)
and G.J_sayong_gubun = 1

select G.sangho, C.sangho johap_sangho, T.*, convert(char(10), C.in_date, 120) johap_in_date,  convert(char(10), C.out_date, 120) johap_out_date,  
convert(char(10), G.in_date, 120) in_date,  convert(char(10), G.out_date, 120) out_date, 
G.J_sayong_gubun, G.J_sayong_bigo_1, G.J_sayong_bigo_2
--select C.sangho johap_sangho, T.*, convert(char(10), C.in_date, 120) johap_in_date,  convert(char(10), C.out_date, 120) johap_out_date
into #tmp_7
from cm_cust C, #Tmp_5 T left outer join JOHAP_DB.Gimaek.dbo.cm_cust G
on G.cust_code = T.company_code
where C.cust_code = T.cust_code
and (G.out_date is null or G.out_date >= @nowYmd)
and G.J_sayong_gubun = 2  --// 대기업은 배정산과없이 따로 계산서 끊기 때문에 


-- select * from #tmp_5 where cust_code = '101-260' 
-- select * from #tmp_6 where cust_code = '101-260' 

-- --1. 기맥_사용구분 1.조합 / 2,대기업 
-- update JOHAP_DB.Gimaek.dbo.cm_cust
-- set J_sayong_gubun = 1
-- from #tmp_6 T,  JOHAP_DB.Gimaek.dbo.cm_cust G
-- where G.cust_code = T.company_code
-- 
-- --2. 기맥_가입일자
-- update JOHAP_DB.Gimaek.dbo.cm_cust
-- set in_date = T.min_baejeong
-- from #tmp_6 T,  JOHAP_DB.Gimaek.dbo.cm_cust G
-- where G.cust_code = T.company_code
-- and G.in_date is null

-- --3. 기맥 최초 사용일자보다 적을 경우
-- update JOHAP_DB.Gimaek.dbo.cm_cust
-- set in_date = @in_date
-- from #tmp_6 T,  JOHAP_DB.Gimaek.dbo.cm_cust G
-- where G.cust_code = T.company_code
-- and G.in_date < @in_date

-- 
select * 
from #tmp_6
order by max_baejeong, max_cheonggu

select * 
from #tmp_7
order by max_baejeong, max_cheonggu

drop table #tmp_1, #tmp_2, #tmp_3, #tmp_4, #tmp_5, #tmp_6, #tmp_7


-- 
-- select * from bj_baejeong_1 where cust_code = '101-253'
-- select * from cust_cheonggu_1 where cust_code = '101-253'

-- J_sayong_gubun 1: 조합 / 2: 대기업,개별

