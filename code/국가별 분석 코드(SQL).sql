SELECT * FROM plt.retail_on_top10;
# 주문번호,상품번호,상품명,구매수,가격,고객번호,판매국가,판매일자

# 국가별 월별 총매출
select country,count(*) from plt.retail_on_top10 group by country;
select Country,date_format(InvoiceDate,'%m') Month,
sum(quantity*unitprice) Total 
from plt.retail_on_top10 
group by 1,2 order by 3 desc;

# 상품 좀류 총 3783개
select count(CNT) from(SELECT Description,count(Description) CNT FROM plt.retail_on_top10 group by Description) A;

# 최다 판매 상위 5개
select * from (select Country,Description,sum(Quantity),
row_number() over(partition by country order by sum(Quantity) desc) RNK 
from plt.retail_on_top10 
group by 1,2)A where RNK<=5;

select Description,count(*) goods from (select * from (select Country,Description,sum(Quantity),
row_number() over(partition by country order by sum(Quantity) desc) RNK 
from plt.retail_on_top10 
group by 1,2)A where RNK<=5)A group by Description order by 2 desc;

#최대 매출 상위 5개
select * from (select Country,Description,sum(Quantity*unitprice) Total,
row_number() over(partition by country order by sum(Quantity*UnitPrice) desc) RNK 
from plt.retail_on_top10 
group by 1,2)A where RNK<=5;


# 국가별 상품 순위 테이블 생성
create view plt.temp1 as
select * from (select Country,Description,sum(Quantity*unitprice) Total,
row_number() over(partition by country order by sum(Quantity*UnitPrice) desc) RNK 
from plt.retail_on_top10 
group by 1,2)A where RNK<=5;



select A.country,Description,100*(Total/total_s) pct0 from plt.temp1 A left join (select country,sum(UnitPrice*quantity) total_s from plt.retail_on_top10 group by 1)B
on A.country=B.country;


select country,sum(p)*100 pct from(select A.country,total/total_s p from plt.temp1 A left join (select country,sum(UnitPrice*quantity) total_s from plt.retail_on_top10 group by 1)B
on A.country=B.country)A group by 1;

#최대 매출 상위 5개 상품의 국가 매출 중 전체 비율
select country,sum(p)*100 pct from(select A.country,total/total_s p from plt.temp1 A left join (select country,sum(UnitPrice*quantity) total_s from plt.retail_on_top10 group by 1)B
on A.country=B.country)A group by 1;

select * from plt.temp1;
# 상위 5개 상품에서 국가마다 겹친 상품 3개 테이블(temp1테이블을 중복 참조하면 reopen error때문에 뷰테이블 생성)
create view plt.product as
select Description,count(*) CNT from plt.temp1 group by 1 order by 2 desc;

select * from plt.product;

# 매출 상위 상품에서 겹친 국가와 상품 조회
select country,A.Description from plt.temp1 A,plt.product B 
where A.Description=B.Description order by CNT desc,2;

# 국가별 월별 구매건수
select country,date_format(InvoiceDate,'%m') 'M',
count(*) cust_n from plt.retail_on_top10 group by 1,2;

# 국가별 월별 구매수 계산
create view plt.month_rev as
select country,
IFNULL(sum(CASE WHEN M = '01' THEN cust_n END),0) month1,
IFNULL(sum(CASE WHEN M = '02' THEN cust_n END),0) month2,
IFNULL(sum(CASE WHEN M = '03' THEN cust_n END),0) month3,
IFNULL(sum(CASE WHEN M = '04' THEN cust_n END),0) month4,
IFNULL(sum(CASE WHEN M = '05' THEN cust_n END),0) month5,
IFNULL(sum(CASE WHEN M = '06' THEN cust_n END),0) month6,
IFNULL(sum(CASE WHEN M = '07' THEN cust_n END),0) month7,
IFNULL(sum(CASE WHEN M = '08' THEN cust_n END),0) month8,
IFNULL(sum(CASE WHEN M = '09' THEN cust_n END),0) month9,
IFNULL(sum(CASE WHEN M = '10' THEN cust_n END),0) month10,
IFNULL(sum(CASE WHEN M = '11' THEN cust_n END),0) month11,
IFNULL(sum(CASE WHEN M = '12' THEN cust_n END),0) month12
from (select country,date_format(InvoiceDate,'%m') 'M',
count(*) cust_n from plt.retail_on_top10 group by 1,2)A group by 1;

select * from plt.month_rev;



 
# Retention Rate
create table plt.m_diff as
select *,date_format(invoiceDate, '%m') M,
lead(invoiceDate) over(partition by customerid order by invoicedate) next_d
,TIMESTAMPDIFF(day,invoicedate,lead(invoiceDate) over(partition by customerid order by invoicedate)) month_diff 
from plt.retail_on_top10;

select * from plt.m_diff order by month_diff desc;
select count(distinct customerid) from retail_on_top10;
select country,M
		,count(distinct customerid) cust_cnt
		,count(distinct case when month_diff = 1 then customerid else null end) m1_cnt
		,count(distinct case when month_diff = 2 then customerid else null end) m2_cnt
        ,count(distinct case when month_diff = 3 then customerid else null end) m3_cnt
        ,count(distinct case when month_diff = 4 then customerid else null end) m4_cnt
        ,count(distinct case when month_diff = 5 then customerid else null end) m5_cnt
        ,count(distinct case when month_diff = 6 then customerid else null end) m6_cnt
        ,count(distinct case when month_diff = 7 then customerid else null end) m7_cnt
        ,count(distinct case when month_diff = 8 then customerid else null end) m8_cnt
        ,count(distinct case when month_diff = 9 then customerid else null end) m9_cnt
        ,count(distinct case when month_diff = 1 then customerid else null end) m10_cnt
from plt.m_diff group by 1,2;

# 첫구매후 이탈비율 (국가별)
create view plt.churn as
(select country,customerid,count(distinct invoicedate) pur_cnt from plt.retail_on_top10 group by 1,2);

# pur_cnt가 1이면 1번 구매후 이탈한 회원,1이상이면 이탈하지 않은 회원
select country,sum(case when pur_cnt=1 then 1 else 0 end)/sum(1) pur_1 from plt.churn group by 1;