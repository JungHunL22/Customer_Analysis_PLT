# 국가,날짜별 일일 평균 매출액 테이블 생성
# 일일 총매출로 출력할경우 영국의 값이 매우 많아 다른나라와 비교가 어려움.
create table plt.Sales as 
SELECT country,date_format(InvoiceDate,'%Y-%m-%d') DATE,
avg(Quantity*unitprice) Sales,
date_format(InvoiceDate,'%m') Month,
date_format(InvoiceDate,'%d') Day
FROM plt.retail_on_top10 group by 1,2;

select * from plt.sales;

# 월별 일일 평균 매출이 가장 큰 국가
# 월별 일일 매출 최대액
# mx=sales와 month가 일치해야 제대로된 국가가 출력됨.
select country,month,max(sales) mx from plt.sales group by 2;

select A.Month,A.country,A.Date,B.mx from plt.sales A, (select country,month,max(sales) mx from plt.sales group by 2) B
where A.sales=B.mx and A.month=B.month;

select * from plt.sales where month=06 order by sales desc;