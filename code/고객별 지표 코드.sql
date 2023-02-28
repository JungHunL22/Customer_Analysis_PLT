select max(invoicedate) from plt.retail_on_top10;

drop view plt.rfm;
# RFM : 얼마나 최근,자주,많이 구매했는지에 대한 지표
create view plt.rfm as
select customerid,max(invoicedate) mx,
datediff('2011-12-09 9:46',max(invoicedate)) Recency,
count(distinct invoiceno) Frequency,
sum(quantity*UnitPrice) Monetary,
sum(unitprice*quantity)/count(customerid) ATV,
case when datediff('2011-12-09 9:46',max(invoicedate))>90 then 1 else 0 end churn_yn
 from plt.retail_on_top10 group by 1;

select * from plt.rfm;

select customerid,sum(unitprice*quantity)/count(customerid) from plt.retail_on_top10 group by 1;






