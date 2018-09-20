declare @yy smallint
declare @gubun smallint

set @yy = 2017
set @gubun = 1

select company_code--, mm, count(*)
from RJ_001.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun 
group by company_code--, mm 
order by company_code--, mm
--// RM_103, RM_104


select company_code--, mm, count(*)
from RJ_002.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--// RM_225, RM_299 

select company_code--, mm, count(*)
from RJ_007.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--// RM_734 

select company_code--, mm, count(*)
from RJ_008.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--// RM_866 

select company_code--, mm, count(*)
from RJ_108.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--// RM_K15, RM_K35 

select company_code--, mm, count(*)
from RJ_013.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--// RM_D21 

select company_code--, mm, count(*)
from AJ_005.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--// AS_569 

select company_code--, mm, count(*)
from AJ_008.dbo.cust_gs_maechul where yy = @yy and gubun = @gubun
group by company_code--, mm
order by company_code--, mm
--AS_805, AS_819, AS_820, AS_823, AS_828, AS_837, AS_838, AS_839, AS_840, AS_841, AS_845, AS_846, AS_852, AS_859 








