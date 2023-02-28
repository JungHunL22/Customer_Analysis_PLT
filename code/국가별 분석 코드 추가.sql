# 첫구매후 이탈비율 (국가별)
create view plt.churn as
(select country,customerid,count(distinct invoicedate) pur_cnt from plt.retail_on_top10 group by 1,2);



# pur_cnt가 1이면 1번 구매후 이탈한 회원,1이상이면 이탈하지 않은 회원
select country,sum(case when pur_cnt=1 then 1 else 0 end)/sum(1) pur_1 from plt.churn group by 1;

select * from plt.churn where country='eire';