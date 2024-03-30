-- Link Of the Data https://www.youtube.com/watch?v=S2zBHmkRbhY&list=PLi5spBcf0UMXfbMt1X2bHQkk7mHXkTUhs&index=2

-- Combining  All  Data in one table 
SELECT 
	* INTO HotelDayilData
FROM (
    SELECT * FROM dbo.['2018']
    UNION
    SELECT * FROM dbo.['2019']
    UNION
    SELECT * FROM dbo.['2020']
) AS CombinedData;

-- Traffic In each Hotel
select 
  hotel , count (*)
from HotelDayilData
group by hotel

-- Explore the Revenue Alond year
-- adr (Daily rate) For Each Type Of Hotel
select
	arrival_date_year
	,hotel
	,Round (Sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) ,0) as Revenue
from	
	HotelDayilData 
group by
	arrival_date_year,hotel
	 
order by 
	hotel

-- Total Revenue
Select
	Round (Sum ((stays_in_week_nights+stays_in_weekend_nights)*adr) ,0) as Revenue
from HotelDayilData


-- Total Nights  
Select 
	Sum (stays_in_week_nights+stays_in_weekend_nights)as [Total Nights]
from HotelDayilData


-- What is the overall cancellation rate for hotel bookings?

select Round( Sum (
			case 
				when is_canceled=1 
					then is_canceled 
				else 0
			end 
				) / count(is_canceled)*100 ,0)as cancellation_rate
from HotelDayilData
 
--cancellation rate vary between different hotels

 Select hotel ,
			Round( Sum (
			case 
				when is_canceled=1 
					then is_canceled 
				else 0
			end 
				) / count(is_canceled)*100 ,0)as cancellation_rate
from HotelDayilData
group by hotel
--Correlation between Guests Type and Cancellation:

-- adults corelation 
Select 
	adults ,
	 
	Sum(
		case 
		when is_canceled=1 then 1
		else 0 
		end
		)Canceled
from 
	HotelDayilData
where  
	adults <>0 
	
group by 
	adults 
order by 
	Canceled desc

-- children corelation 
Select 
	children ,
	 
	Sum(
		case 
		when is_canceled=1 then 1
		else 0 
		end
		)Canceled
from 
	HotelDayilData
where  
	children <>0 
group by 
	children 
order by 
	Canceled desc
-- babies corelation 
 Select 
	babies ,
	 
	Sum(
		case 
		when is_canceled=1 then 1
		else 0 
		end
		)Canceled
from 
	HotelDayilData
where  
	babies <>0 
group by 
	babies 
order by 
	Canceled desc
	 
 -- How does the distribution channel affect the cancellation rate?

select distribution_channel
		, Sum (case 
				when is_canceled = 0 
				then 1 else 0 
				end )[cancellation rate For distribution_channel ]
from
	HotelDayilData
group by
	distribution_channel
order by
	[cancellation rate For distribution_channel ] desc


--Are there any trends in booking cancellations over the years?
Select 
	 Year (reservation_status_date)Year
	,MONTH(reservation_status_date)MONTH,
	 Sum (
			case 
				when is_canceled=1 
					then is_canceled 
				else 0
			end 
				)as  cancellations
from HotelDayilData
group by reservation_status_date
order by cancellations desc

---What is the distribution of lead times for bookings?
Select 
	Year (reservation_status_date )Year,
	Month(reservation_status_date) Month, 
	Sum(lead_time)lead_time
from 
	HotelDayilData 
where 
	lead_time >0
group by
	reservation_status_date
order by 
	lead_time desc


--Which month has the highest number of bookings?
Select 
	Month(reservation_status_date)Month,
	Count(is_canceled)as [Resevation Rate]
from 
	HotelDayilData
where 
	is_canceled=0
group by 
	Month(reservation_status_date)
order by 
	[Resevation Rate] desc


---What is the average length of stay for bookings?
Select 
	Round (AVG (stays_in_week_nights+stays_in_weekend_nights),0)[Night_Per_Reservation]
from HotelDayilData

--What are the most common market segments for hotel bookings?
Select 
	market_segment ,
	count(*)market_segment_Count
from 
	HotelDayilData
group by
	market_segment
order by
	market_segment_Count desc



--What percentage of bookings are made by repeated guests?
select 
	(Sum (
		case when is_repeated_guest  = 1 then 1 else 0 end)*1.0
	/count (Case 
		when is_repeated_guest  = 1 and is_repeated_guest  = 0 then 1 else 0 end))as [repeated guests]
	 
from 
	HotelDayilData

 --How do different deposit types affect the cancellation rate?

 Select 
	deposit_type ,
	( SUM (case when is_canceled=1 then 1 else 0 end)*1.0/COUNT(is_canceled) )as is_canceled
 from 
	HotelDayilData
group by
	deposit_type


--Are bookings made by certain types of customers (e.g., transient, group) more likely to be canceled?
Select 
	customer_type , 
	(SUM(is_canceled)/COUNT(is_canceled))*100 as Cansel_rate
from
	HotelDayilData
group by
	customer_type
order by
	Cansel_rate

--What is the average number of days customers spend on the waiting list before their booking is confirmed?
-- in hotel type
Select hotel,
  Round (AVG (days_in_waiting_list ),1)*24 AVG_Hour_in_waiting_list
from HotelDayilData
group by	
	hotel

---What is the average daily rate (ADR) for bookings?
Select
	Round (AVG (adr),0)ADR
From	
	 HotelDayilData
 
 --Are there any specific countries with a higher cancellation rate?
Select * From (
Select 
	country , Round ( (SUM(is_canceled)*1.0 / Count (is_canceled)),3)[cancellation rate]
 from 
	HotelDayilData
group by
	country
	)x
where x.[cancellation rate]>0

---Are bookings with special requests more likely to be canceled?

Select 
	AVG (case when total_of_special_requests>0 and is_canceled=1 then 1.0 else 0 end)*100 Special_is_canceled
	,
	AVG(case when total_of_special_requests =0 and is_canceled=1 then 1.0 else 0 end)*100 Not_Special_canceled

from 
	HotelDayilData