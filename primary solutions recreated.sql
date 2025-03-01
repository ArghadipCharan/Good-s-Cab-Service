/* 1. Top and Bottom Performing Cities
• Identify the top 3 and bottom 3 cities by total trips over the entire analysis period. */

-- top 3

select  dc.city_name, count(ft.trip_id) as Total_trips
from fact_trips ft
join dim_city as dc on ft.city_id = dc.city_id
group by  dc.city_name
order by Total_trips desc
limit 3;

-- bottom 3

select  dc.city_name, count(ft.trip_id) as Total_trips
from fact_trips ft
join dim_city as dc on ft.city_id = dc.city_id
group by  dc.city_name
order by Total_trips asc
limit 3;

/* 2. Average Fare per Trip by City
Calculate the average fare per trip for each city and compare it with the city's average trip distance.
Identify the cities with the highest and lowest average fare per trip to assess pricing efficiency across locations. */

select * from fact_trips;
select 
    dc.city_name,
    round(avg(ft.fare_amount), 2) as avg_fare_per_trip,
    round(avg(ft.distance_travelled_km), 2) as avg_distance_travelled,
    round(avg(ft.fare_amount)/avg(ft.distance_travelled_km), 2) as avg_fare_per_km
from fact_trips ft
join dim_city dc on ft.city_id = dc.city_id
group by dc.city_name
order by avg_fare_per_km desc;


create view avg_fare as 
select 
	ft.city_id,
    dc.city_name,
    round(avg(ft.fare_amount), 2) as avg_fare_per_trip,
    round(avg(ft.distance_travelled_km), 2) as avg_distance_travelled,
    round(avg(ft.fare_amount)/avg(ft.distance_travelled_km), 2) as avg_fare_per_km
from fact_trips ft
join dim_city dc on ft.city_id = dc.city_id
group by ft.city_id, dc.city_name
order by avg_fare_per_km desc;

select city_name, avg_fare_per_trip
from avg_fare
order by avg_fare_per_trip desc
limit 1;

select city_name, avg_fare_per_trip
from avg_fare
order by avg_fare_per_trip asc
limit 1;

/* 3. Average Ratings by City and Passenger Type
Calculate the average passenger and driver ratings for each city, segmented by passenger type (new vs. repeat). 
Identify cities with the highest and lowest average ratings. */

select * from fact_trips;

select 
    dc.city_name,
    round(avg(case when ft.passenger_type = "new" then ft.passenger_rating end)) as New_pass_avg_rating,
    round(avg(case when ft.passenger_type = "repeated" then ft.passenger_rating end)) as Repeated_pass_avg_rating,
    round(avg(driver_rating)) as driver_rating
from fact_trips ft
join dim_city dc on ft.city_id = dc.city_id
group by dc.city_name;

create view rating as 
select 
	ft.city_id,
    dc.city_name,
    round(avg(case when ft.passenger_type = "new" then ft.passenger_rating end)) as New_pass_avg_rating,
    round(avg(case when ft.passenger_type = "repeated" then ft.passenger_rating end)) as Repeated_pass_avg_rating,
    round(avg(driver_rating)) as driver_rating
from fact_trips ft
join dim_city dc on ft.city_id = dc.city_id
group by ft.city_id, dc.city_name;

-- cities with highest new passenger rating

select 
    city_name,
    New_pass_avg_rating
from rating
where New_pass_avg_rating = (select max(New_pass_avg_rating) from rating);

-- cities with lowest new passenger rating

select 
    city_name,
    New_pass_avg_rating
from rating
where New_pass_avg_rating = (select min(New_pass_avg_rating) from rating);

-- cities with highest repeated passenger rating

select 
    city_name,
    Repeated_pass_avg_rating
from rating
where Repeated_pass_avg_rating = (select max(Repeated_pass_avg_rating) from rating);

-- cities with lowest repeated passenger rating

select 
    city_name,
    Repeated_pass_avg_rating
from rating
where Repeated_pass_avg_rating = (select min(Repeated_pass_avg_rating) from rating);

/* 4. Peak and Low Demand Months by City
For each city, identify the month with the highest total trips (peak demand) and the month with the lowest total trips (low demand). 
This analysis will help Goodcabs understand seasonal patterns and adjust resources accordingly.*/

select * from dim_city;
select * from fact_trips;
    
with monthly_trips as (
select 
    dc.city_name,
	ft.date,
    monthname(ft.date) as month_name,
    count(ft.trip_id) as total_trips
from fact_trips ft
join dim_city dc on ft.city_id = dc.city_id
group by ft.date, dc.city_name),
ranked_trips as (
select 
	city_name,
    month_name,
	total_trips,
    rank() over (partition by city_name order by total_trips desc) as rank_highest,
    rank() over (partition by city_name order by total_trips asc) as rank_lowest
from monthly_trips)
select 
	city_name,
	month_name,
    case when
			rank_highest = 1
		 then "Peak Demand"
         else "Low Demand"
         end as demand_type
from ranked_trips
where rank_highest = 1 or rank_lowest = 1
group by city_name, month_name;
	
    

	