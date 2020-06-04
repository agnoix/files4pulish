
报表：Account List

 select a1.account_name
       ,a1.account_abbrv 
     ,a1.account_abbrv account_number
     ,case when a1.account_type_id =1  then  'Carrier' 
         when a1.account_type_id =2  then 'InterCompany' 
       when a1.account_type_id =3  then 'InterMachine'
       else null end  Account_type
     ,a1.ACCOUNT_STATUS
     ,a1.ACCOUNT_ID
     ,a2.company_name
     ,a1.Buyer_ID
     ,a1.seller_id
   ,a3.COUNTRY_ENG_NAME as COUNTRY
   ,a1.credit_limit
   ,a1.deposit
     ,a1.MODIFIED_DATE
     ,a1.MODIFIEDBY_ID
     ,a1.remark as NOTE
     from SRD.R_CM_ACCOUNT a1   
   left join SRD.R_CM_company a2
   on a1.company_id =a2.company_id
   left join SRD.r_sys_country a3
   on a1.account_region_id =a3.region_id
   where   {account_type} and 
      TO_DATE(to_char(a1.eff_date,'yyyymmdd'),'yyyymmdd') <=  to_date('{Account_Date1}','yyyymmdd') 
  and  TO_DATE(to_char(a1.exp_date,'yyyymmdd'),'yyyymmdd') >=to_date('{Account_Date1}','yyyymmdd')
    and a1.account_name  like '{Account}'
	
	
---------------------------------------------------------------------------------------

报表：destination_list


  select a.region_name
      ,b.country_ENG_name
      ,b.country_code
      ,C.Destination_name
      ,C.Destination_abbrv
      ,C.Internal_code
      ,C.External_code
      ,I.category_name as destination_group
      ,g.category_name as destination_category
from Srd.R_SYS_REGION a
inner join Srd.R_SYS_COUNTRY b
on a.region_id =b.region_id
inner join Srd.R_PM_DESTINATION c
on b.country_id =c.country_id
inner join Srd.R_PM_NUMBER_PLAN d
on c.number_plan_id =d.number_plan_id
inner join Srd.R_PM_NUMBER_PLAN_type e
on d.number_plan_type_id =e.number_plan_type_id
left join (select destination_id,category_id from Srd.r_pm_category_ref group by destination_id,category_id) f
on c.destination_id=f.destination_id
left join Srd.r_sys_category g
on f.category_id =g.category_id
left join Srd.r_sys_category_ref H
on c.destination_id =H.instance_id
left join Srd.r_sys_category I
on H.category_id=I.category_id and I.category_type_id=16
where {number_plan}
      and {number_plan_type}
and    TO_DATE(to_char(c.eff_date,'yyyymmdd'),'yyyymmdd')  <=   to_date('{Destination_Date1}','yyyymmdd') 
and    (TO_DATE(to_char(c.exp_date,'yyyymmdd'),'yyyymmdd') >=   to_date('{Destination_Date1}','yyyymmdd') or c.exp_date is null)
	
-----------------------------------------------------
报表： Dialed Digits LIST


   select
       c.country_code
      ,b.dialed_digits
      ,b.Eff_Date  as DD_Begin_Date
      ,b.EXP_Date  as DD_END_Date
      ,d.number_plan_name
      ,a.destination_name
      ,a.Eff_Date as Dest_Begin_Date
      ,a.EXP_Date as Dest_End_Date
from 
Srd.R_PM_DESTINATION a
left join Srd.R_PM_DIALED_DIGITS b
on a.destination_id=b.destination_id
left join Srd.R_SYS_COUNTRY c
on a.country_id =c.country_id
left join Srd.R_PM_NUMBER_PLAN d
on a.number_plan_id =d.number_plan_id
left  join Srd.R_PM_NUMBER_PLAN_type e
on d.number_plan_type_id =e.number_plan_type_id
and  a.destination_name =a.destination_name
and  b.dialed_digits =b.dialed_digits
where  {number_plan_type_name} and {Number Plan} and {country}
and a.destination_name like '{destination_name}' and b.dialed_digits={dialed_digits}
and {Dialed_Digits_Date} 


------------------------------------------------------------------------
报表：Dialed Digits LIST  with rates 



 select o2.account_name 
      ,c.country_code
      ,b.DD
      ,b.EFFECTIVE_DATE as DD_Begin_date
      ,'' as DD_End_date
      ,d.number_plan_name
      ,a.destination_name
      ,a.Eff_Date
      ,a.EXP_Date
	  ,o1.rate_plan_ABBRV
      ,h.RATE_ITEM_ID as rate_type
      ,g.rate
      --,o3.offer_date
    ,f.eff_date as rate_begin_date
    ,f.exp_date as rate_end_date
from Srd.r_pm_source_customer o
left join 
Srd.r_pm_rate_plan o1
on o.rate_plan_id =o1.rate_plan_id
left join Srd.r_cm_account o2
on o.account_id=o2.account_id
left join 
(select * from (select source_id,destination_id,offer_id,row_number()over(partition by source_id,destination_id order by offer_date desc) px from 
Srd.r_pm_upload_destination)  where px=1
) o3
on o.source_id=O3.SOURCE_ID
LEft join 
Srd.R_PM_DESTINATION a
on o3.destination_id=a.destination_id
left join Srd.R_PM_UPLOAD_DD b
on o3.offer_id=b.offer_id
left join Srd.R_SYS_COUNTRY c
on a.country_id =c.country_id
left join Srd.R_PM_NUMBER_PLAN d
on a.number_plan_id =d.number_plan_id
inner join Srd.R_PM_NUMBER_PLAN_type e
on d.number_plan_type_id =e.number_plan_type_id
left join Srd.r_pm_product e1
on o3.destination_id =e1.destination_id
 left join Srd.r_pm_rate f
on o.rate_plan_id=f.rate_plan_id and f.product_id=e1.product_id
left join  Srd.r_pm_rate_detail g
on f.rate_id =g.rate_id
left join Srd.R_PM_RATING_METHOD_DETAIL h
on f.RATING_METHOD_ID =h.RATING_METHOD_ID
where {Account} and {Rate_Plan} 
and {Rate_Type}  and  {Country}
and a.destination_name like '{Destination}' and b.DD={dialed_digits}



-------------------------------------------------------------------------------------------
报表: Dialed Digits Upload Report


  select a.dd
      ,a.country_code
      ,b.destination_name
    --  ,c.country_ENG_name
--select *       
from Srd.R_PM_UPLOAD_DD a
left join (select * from (select source_id,destination_id,upload_destination_id,offer_id,rank()over(partition by source_id,destination_id order by offer_date desc) px from 
Srd.r_pm_upload_destination where TO_DATE(to_char(eff_date,'yyyymmdd'),'yyyymmdd')  <=   to_date('{Destination_Date1}','yyyymmdd'))  where px=1) b
on a.upload_destination_id=b.upload_destination_id
--left join Srd.R_SYS_COUNTRY c
--on a.country_code=c.country_code
left join Srd.r_pm_destination d
on b.destination_id =d.destination_id
--where b.country_id =(select country_id from Srd.R_SYS_COUNTRY where country_ENG_NAME ='Argentina')
left join Srd.R_SYS_COUNTRY e
on d.country_id=e.country_id
where {Country}





-------------------------------------------------

报表:Customer Price History 

select a1.* from  (
 select a2.rate_plan_ABBRV
      ,a4.product_name
      ,a5.product_catalog_name
      ,a6.rate_item_id--101
      ,a3.rate
      ,a1.eff_date
      ,a1.exp_date
 --     select distinct a6.rate_item_id 
from Srd.R_PM_rate a1
left join Srd.r_pm_rate_plan a2
on a1.rate_plan_id =a2.rate_plan_id
left join Srd.R_PM_rate_detail a3
on a1.rate_id=a3.rate_id
left join Srd.r_pm_product a4
on a1.product_id=a4.product_id
left join Srd.R_PM_PRODUCT_CATALOG a5
on a4.product_catalog_id=a5.product_catalog_id
left join Srd.R_PM_RATING_METHOD_DETAIL a6
on a1.RATING_METHOD_ID =a6.RATING_METHOD_ID
where --a4.product_name ='Albania ALBTEL-IDDD'
--and
a5.product_catalog_id =5
and  {product_name} and {rate_plan_ABBRV}) a1
inner join
(select a2.rate_plan_ABBRV
      ,a4.product_name
      ,a5.product_catalog_name
      ,a6.rate_item_id--101
      ,a3.rate
      ,a1.eff_date
      ,a1.exp_date
 --     select distinct a6.rate_item_id 
from Srd.R_PM_rate a1
left join Srd.r_pm_rate_plan a2
on a1.rate_plan_id =a2.rate_plan_id
left join Srd.R_PM_rate_detail a3
on a1.rate_id=a3.rate_id
left join Srd.r_pm_product a4
on a1.product_id=a4.product_id
left join Srd.R_PM_PRODUCT_CATALOG a5
on a4.product_catalog_id=a5.product_catalog_id
left join Srd.R_PM_RATING_METHOD_DETAIL a6
on a1.RATING_METHOD_ID =a6.RATING_METHOD_ID
where --a4.product_name ='Albania ALBTEL-IDDD'
--and
a5.product_catalog_id =5
and  {product_name} and {rate_plan_ABBRV}
and    TO_DATE(to_char(a1.eff_date,'yyyymmdd'),'yyyymmdd')  <=   to_date('{Begin_Date1}','yyyymmdd') 
and    (TO_DATE(to_char(a1.exp_date,'yyyymmdd'),'yyyymmdd') >=   to_date('{End_Date1}','yyyymmdd') or a1.exp_date is null)
) a2
on a1.rate_plan_ABBRV=a2.rate_plan_ABBRV
and a1.product_name=a2.product_name

---------------------------------------------------------
报表:Price VS. Destination
 select  a4.account_name
       ,a3.rate_plan_ABBRV
	   ,a6.product_name
	   ,a7.product_catalog_name
	   ,a8.rate_item_id
	   ,a5.rate
from (select * from (
select upload_destination_id
,source_id,destination_id,RATING_METHOD_ID,route_class_id
,rank()over(partition by source_id,destination_id,offer_id order by eff_DATE desc) px 
from Srd.R_PM_UPLOAD_DESTINATION) where px=1) a1
inner join Srd.r_pm_source_customer a2
on a1.source_id =a2.source_id
left join
Srd.r_pm_rate_plan a3
on a2.rate_plan_id=a3.rate_plan_id
left join Srd.r_cm_account a4
on a2.account_id=a4.account_id
left join Srd.r_pm_upload_rate a5
on a1.upload_destination_id=a5.upload_destination_id
left join Srd.r_pm_product a6
on a1.destination_id=a6.destination_id
left join Srd.R_PM_PRODUCT_CATALOG a7
on a6.product_catalog_id=a7.product_catalog_id
left join Srd.R_PM_RATING_METHOD_DETAIL a8
on a1.RATING_METHOD_ID =a8.RATING_METHOD_ID
left join Srd.R_PM_destination a9
on a1.destination_id =a9.destination_id
left join Srd.R_sys_country a10
on a9.country_id =a10.country_id
left join Srd.r_pm_number_plan a11
on a9.number_plan_id = a11.number_plan_id
left join Srd.r_pm_route_class a12
on  a1.route_class_id =a12.route_class_id 
where a7.product_catalog_id=5
and {Country} and  {number_plan_name}
and a9.destination_name like '%{destination_name}%' and {route_class}
and {Rate_Type} and a4.account_status ={account_status}


---------------------------------------------------------------------------












	