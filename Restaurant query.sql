--Firstly we display data from all th tables then we will begin with finding answers to some important questions

Select *
From Restaurant..consumers;

Select *
From Restaurant..consumer_preferences;

Select *
From Restaurant..ratings;

Select *
From Restaurant..restaurant_cuisines;

Select *
From Restaurant..restaurants;

--Find the total number of consumers who do not smoke.
Select count(smoker) number_nonsmokers
From Restaurant..consumers
where smoker = 0;

--Find the number of consumers in each occupation group.
Select distinct Occupation occupation , count(*) nos
From Restaurant..consumers
group by Occupation
order by nos desc;

--Create 4 Quartiles for different age groups and use childern as partition by
Select Consumer_ID,
		Age,
		NTILE(4) OVER (partition by children order by age) as quartile_age
From Restaurant..consumers;

--Find the most used means of transportation.
Select Distinct Transportation_Method, count(*) counts
From Restaurant..consumers
Group by Transportation_Method
Order by counts desc
Offset 0 rows Fetch first 1 rows only;

--How many single Consumers have low budget?
With t1 as (Select Consumer_ID 
From Restaurant..consumers
where Marital_Status = 'single'),

t2 as (Select Consumer_ID
	    From Restaurant..consumers
		Where Budget = 'low')


Select count(t1.consumer_id) numbr_single_low_budget
From t1
join t2
on t1.consumer_id = t2.Consumer_ID;

--Name all the city starting with the letter s.
Select distinct City
From Restaurant..consumers
Where city like 'S%';

--Which restaurants have wine and beer services?
Select Name
From Restaurant..restaurants
Where Alcohol_Service = 'wine & beer'
Group by Name;

--Find the restaurnats which were rated 2 among all rating sections.
Select distinct Restaurant_ID
From Restaurant..ratings
Where Overall_Rating = 2 and Food_Rating = 2 and Service_Rating = 2;

--along with their cuisines
Select distinct r.Restaurant_ID, c.Cuisine
From Restaurant..ratings r
join Restaurant..restaurant_cuisines c
on r.Restaurant_ID = c.Restaurant_ID
Where r.Overall_Rating = 2 and r.Food_Rating = 2 and r.Service_Rating = 2;

--List all the restaurants which had parking services available and provide american cuisine
Select r.Name
From Restaurant..restaurants r
join Restaurant..restaurant_cuisines c
on r.Restaurant_ID = c.Restaurant_ID
Where r.Parking not in ('none')
and c.Cuisine =  'american';

--find the restaurant name and consumers id of consumers who have visited restaurant with alcohol and have children.
Select c.Consumer_ID,r.Name
From Restaurant..restaurants r
join Restaurant..ratings s
on r.Restaurant_ID = s.Restaurant_ID
join Restaurant..consumers c
on c.Consumer_ID = s.Consumer_ID
Where r.Alcohol_Service not in ('none') and 
c.Children = 'independent';

--Which consumer prefer which cuisine and where are the available?
Select c.Consumer_ID, p.Preferred_Cuisine,rc.Restaurant_ID, rs.Name
From Restaurant..consumers c
join Restaurant..consumer_preferences p
on c.Consumer_ID = p.Consumer_ID
join Restaurant..ratings r
on r.Consumer_ID = c.Consumer_ID
join Restaurant..restaurants rs
on rs.Restaurant_ID= r.Restaurant_ID
join Restaurant..restaurant_cuisines rc
on rs.Restaurant_ID= rc.Restaurant_ID
Where  p.Preferred_Cuisine = rc.Cuisine
and rc.Restaurant_ID = r.Restaurant_ID
Order by rs.Name;

--Name the restaurant that have food rating of 2.
Select r.Name
From Restaurant..restaurants r
join Restaurant..ratings rs
on r.Restaurant_ID= rs.Restaurant_ID
Where rs.Food_Rating = 2;

--Create window according to overall ratings.
Select r.Name,
		rs.food_rating,
		dense_rank() over (partition by r.name order by rs.food_rating desc) ranks
From Restaurant..restaurants r
join Restaurant..ratings rs
on r.Restaurant_ID= rs.Restaurant_ID;

--Name the restaurants that provide open area along with smoking services.
Select Name
From Restaurant..restaurants r
Where Smoking_Allowed = 'yes' and
Area = 'open';

--number of restaurants with atleast 1 franchise
Select count(*) restaurant_with_franchises
From Restaurant..restaurants
Where Franchise >= 1;

--Find all the restaurants that have high prices but the sum of overall arting, food rating and service rating is less than 4
Select distinct name, total
From  
	(Select r.Name name ,s.Food_Rating +s.Overall_Rating+s.Service_Rating as total, r.Price price
	From Restaurant..restaurants r 
	join Restaurant..ratings s
	on r.restaurant_id = s.restaurant_id
	) t1
Where total < 4 and
		price = 'high'
Order by total;

