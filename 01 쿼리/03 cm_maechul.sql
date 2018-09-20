declare @ym varchar(7) 
set @ym = '2017-12' 
declare @ymd_D smalldatetime, @ymd_N smalldatetime, @year_B smalldatetime 
set @ymd_D = @ym + '-01' 
set @year_B = dateadd(year, -1, @ymd_D) 
set @ymd_N = dateadd(month, 1, @ymd_D) 

-- select  @ymd_D
-- select  @year_B
-- select  @ymd_N
--//jeokyong_gubun 1월납, 2년납, 3분기초, 4분기말
select M.*, case when jeokyong_gubun = 1 then @ym 
                       when jeokyong_gubun = 2 and month(@ymd_D) >= jeokyong_mm then cast(year(@ymd_D) as varchar(7)) + '-' + (case when jeokyong_mm < 10 then '0' + cast(jeokyong_mm as varchar(2)) else cast(jeokyong_mm as varchar(2)) end) 
                       when jeokyong_gubun = 2 and month(@ymd_D) < jeokyong_mm then cast(year(@year_B) as varchar(7)) + '-' + (case when jeokyong_mm < 10 then '0' + cast(jeokyong_mm as varchar(2)) else cast(jeokyong_mm as varchar(2)) end) 
                       when jeokyong_gubun = 3 and month(@ymd_D) <= 3 then left(@ym, 4) + '-01' 
                       when jeokyong_gubun = 3 and month(@ymd_D) > 3 and month(@ymd_D) <= 6  then left(@ym, 4) + '-04'  
                       when jeokyong_gubun = 3 and month(@ymd_D) > 6 and month(@ymd_D) <= 9  then left(@ym, 4) + '-07'  
                       when jeokyong_gubun = 3 and month(@ymd_D) > 9 and month(@ymd_D) <= 12 then left(@ym, 4) + '-10' 
                       when jeokyong_gubun = 4 and month(@ymd_D) < 3                         then cast(year(@year_B) as varchar(7)) + '-12'  
                       when jeokyong_gubun = 4 and month(@ymd_D) >= 3 and month(@ymd_D) < 6  then left(@ym, 4) + '-03'  
                       when jeokyong_gubun = 4 and month(@ymd_D) >= 6 and month(@ymd_D) < 9  then left(@ym, 4) + '-06'  
                       when jeokyong_gubun = 4 and month(@ymd_D) >= 9 and month(@ymd_D) < 12 then left(@ym, 4) + '-09' 
                       when jeokyong_gubun = 4 and month(@ymd_D) = 12                        then left(@ym, 4) + '-12' end vt_ck_ym 
into #tmp_01 
from cm_maechul M 
where M.ymd < @ymd_N 
and M.ymd = (select max(G.ymd) from cm_maechul G where G.cust_code = M.cust_code and G.maechul_gubun = M.maechul_gubun and G.ymd < @ymd_N) 
and M.Maechul_Gubun in (2,7) --//1프로그램, 2광역전산, 3홈페이지,4 관제료, 5모바일, 7전자세금계산서
and M.cust_code like 'As_4%'

select T.*, MG.gubun_name, C.sangho_yakeo sangho  
from #tmp_01 T left outer join cm_maechul_gubun MG on MG.maechul_gubun = T.maechul_gubun 
left outer join cm_cust C on C.cust_code = T.cust_code 
order by T.vt_ck_ym, T.cust_code, T.maechul_gubun 

drop table #tmp_01 

