
Use master
Go

SELECT TOP 3 * FROM dbo.Zomato
SELECT COUNT(*) FROM dbo.Zomato

--Data Standardization

--// Renaming the Column Name --//

SP_RENAME 'Zomato.[Restaurant ID]','Restaurant_ID','COLUMN'
SP_RENAME 'Zomato.[Country Code]','Country_Code','COLUMN'
SP_RENAME 'Zomato.[Restaurant Name]','Restaurant_Name','COLUMN'
SP_RENAME 'Zomato.[Locality Verbose]','Locality_Verbose','COLUMN'
SP_RENAME 'Zomato.[Average Cost for two]','Average_Cost_for_two','COLUMN'
SP_RENAME 'Zomato.[Has Table booking]','Has_Table_booking','COLUMN'
SP_RENAME 'Zomato.[Has Online delivery]','Has_Online_delivery','COLUMN'
SP_RENAME 'Zomato.[Is delivering now]','Is_delivering_now','COLUMN'
SP_RENAME 'Zomato.[Switch to order menu]','Switch_to_order_menu','COLUMN'
SP_RENAME 'Zomato.[Price range]','Price_range','COLUMN'
SP_RENAME 'Zomato.[Aggregate rating]','Aggregate_rating','COLUMN'
SP_RENAME 'Zomato.[Rating color]','Rating_color','COLUMN'
SP_RENAME 'Zomato.[Rating text]','Rating_text','COLUMN'

--// Duplicate Check --//

SELECT  [Restaurant ID], count(*)
FROM dbo.Zomato
Group by  [Restaurant ID]
Having count(*)>1


--Q1) Find the Number of Restaurant in each country ? 

 SELECT
        SUM(CASE WHEN Country_Code = 1 THEN 1 
		     ELSE 0
			 END) AS India,
		SUM(CASE WHEN Country_Code = 14 THEN 1 
		     ELSE 0
			 END) AS Australia,
		SUM(CASE WHEN Country_Code = 30 THEN 1 
		     ELSE 0
			 END) AS Brazil,
		SUM(CASE WHEN Country_Code = 37 THEN 1 
		     ELSE 0
			 END) AS Canada,
		SUM(CASE WHEN Country_Code = 94 THEN 1 
		     ELSE 0
			 END) AS Indonesia,
		SUM(CASE WHEN Country_Code = 148 THEN 1 
		     ELSE 0
			 END) AS New_Zealand,
		SUM(CASE WHEN Country_Code = 162 THEN 1 
		     ELSE 0
			 END) AS Phillipines,
		SUM(CASE WHEN Country_Code = 166 THEN 1 
		     ELSE 0
			 END) AS Qatar,
		SUM(CASE WHEN Country_Code = 184 THEN 1 
		     ELSE 0
			 END) AS Singapore,
		SUM(CASE WHEN Country_Code = 189 THEN 1 
		     ELSE 0
			 END) AS South_Africa,
		SUM(CASE WHEN Country_Code = 191 THEN 1 
		     ELSE 0
			 END) AS SriLanka,
		SUM(CASE WHEN Country_Code = 208 THEN 1 
		     ELSE 0
			 END) AS Turkey,
		SUM(CASE WHEN Country_Code = 214 THEN 1 
		     ELSE 0
			 END) AS UAE,
		SUM(CASE WHEN Country_Code = 215 THEN 1 
		     ELSE 0
			 END) AS UnitedKingdom,
		SUM(CASE WHEN Country_Code = 216 THEN 1 
		     ELSE 0
			 END) AS UnitedStates
FROM Zomato

--- Restaurant serving via Zomota is Highest in India(8652), followed by United_States(434) and Least but not the last, United Kingdom(80)

-- Q2) What's the Average Cost of two Person dinning Country wise ?

With Cte_Sum AS
(SELECT B.Country,SUM(Average_Cost_for_two)SUM_TOTAL,A.Currency
FROM Zomato A 
INNER JOIN Zomato_Country B
ON A.Country_Code = B.[Country Code]
Group by B.Country,A.Currency),
Cte_Avg AS
(SELECT B.Country,ROUND(AVG(Average_Cost_for_two),0)AVG_TOTAL,A.Currency
FROM Zomato A 
INNER JOIN Zomato_Country B
ON A.Country_Code = B.[Country Code]
Group by B.Country,A.Currency
)
SELECT A.Country,A.Currency,A.AVG_TOTAL,B.SUM_TOTAL,C.Currency_Exchange_Rate,CONCAT('Avg Dinning Expense','  ',A.AVG_TOTAL,' ',A.Currency)Per_Person_Avg
FROM 
Cte_Avg A inner join 
Cte_Sum B
ON A.Country = B.Country
INNER JOIN Ex_Rate C
ON A.Country = C.Country
Order by 3 

----Average Cost of Two People Dinning is more in Indonesia,SriLanka, Phillipines due to depreciation of currency and Slightly afforable in India. 

--Q3) What's the Count of Restaurant which is rated as 'Excellent' ?

SELECT B.Country, COUNT(DISTINCT A.Restaurant_ID)Restaurant_Count,Rating_text AS Rating_Matrix
FROM dbo.Zomato A
INNER JOIN Zomato_Country B
ON A.Country_Code = B.[Country Code]
WHERE Rating_text = 'Excellent'
GROUP BY B.Country,Rating_text
Order by 2 DESC

--// Restaurant in India, United states, United Kingdom has best of the best Restaurant in globe, where as Countries like Australia, Sri Lanka, Qatar, Indonesia 
 -- has low count of Restaurant as the Zomota reach is mentioned countries is minimum due to less brand awareness and revenue model. 

-- Q4) What's the Count of Restaurant and it's cumulative total which is rated as 'Very Good'  --

SELECT B.Country, COUNT(DISTINCT A.Restaurant_ID)Restaurant_Count,Rating_text AS Rating_Matrix,
SUM(Count(A.Restaurant_ID)) OVER (ORDER BY B.Country)Cumulative_Total 
FROM dbo.Zomato A
INNER JOIN Zomato_Country B
ON A.Country_Code = B.[Country Code]
WHERE Rating_text = ('Very Good')
GROUP BY B.Country,Rating_text

--//1079 Restaurant is rated "Good" across the Globe. Restaurant's in India followed by United States & South Africa are rated 'Very Good' based 
--on food quality and higher customer satisfaction.

--Q5) What's the Count of Restaurant which is rated as 'Good','Average','Poor','Not rated'  --

SELECT B.Country, COUNT(DISTINCT A.Restaurant_ID)Restaurant_Count,Rating_text AS Rating_Matrix,
SUM(Count(A.Restaurant_ID)) OVER (ORDER BY B.Country)Cumulative_Total 
FROM dbo.Zomato A
INNER JOIN Zomato_Country B
ON A.Country_Code = B.[Country Code]
WHERE Rating_text IN ('Good','Average','Poor','Not rated')
GROUP BY B.Country,Rating_text


--// 8171 Restaurant are such that which falls under the category of 'Good','Average','Poor','Not rated' which 80% of entire restaurant listed in Zomato dataset


--Q6) What is Average relative rating of restaurant which is rated as 'Excellent' in Zomota ?

SELECT DISTINCT Country,Restaurant_Per_Country,Total_Avg_Rating_Per_Country,ROUND(Restaurant_Per_Country/Total_Avg_Rating_Per_Country,0)Avg_Relative_Rating
FROM ( 
        SELECT B.Country,A.Aggregate_Rating,Rating_text,
        SUM(COUNT(Restaurant_ID)) OVER(PARTITION BY Country_Code ORDER BY Country_Code)Restaurant_Per_Country,
		SUM(Aggregate_Rating) OVER(PARTITION BY Country_Code ORDER BY Country_Code)Total_Avg_Rating_Per_Country
        FROM dbo.Zomato A
		INNER JOIN Zomato_Country B
        ON A.Country_Code = B.[Country Code]
        WHERE Rating_text = 'Excellent'
        Group by B.Country,Aggregate_Rating,Country_Code,Rating_text
)AB
ORDER BY Avg_Relative_Rating DESC

--// We see positive average relative rating in India and United states for the restaurant which is rated 'Excellent' due to better customer engagement and it
  -- also implies better revenue growth,client retention rate and profit margin.

--Q7) What is the average relative rating of restaurant which is not rated 'Excellent'  --

SELECT DISTINCT Country,Restaurant_Per_Country,Total_Avg_Rating_Per_Country,ROUND(Restaurant_Per_Country/Total_Avg_Rating_Per_Country,0)Avg_Relative_Rating
FROM ( 
        SELECT B.Country,A.Aggregate_Rating,Rating_text,
        SUM(COUNT(Restaurant_ID)) OVER(PARTITION BY Country_Code ORDER BY Country_Code)Restaurant_Per_Country,
		SUM(Aggregate_Rating) OVER(PARTITION BY Country_Code ORDER BY Country_Code)Total_Avg_Rating_Per_Country
        FROM dbo.Zomato A
		INNER JOIN Zomato_Country B
        ON A.Country_Code = B.[Country Code]
        WHERE Rating_text IN ('Good','Average','Poor')
        Group by B.Country,Aggregate_Rating,Country_Code,Rating_text
)AB
ORDER BY Avg_Relative_Rating DESC

--// We observe that India is rated over and above due the fact that restaurant count is more in India, Secondly we see United states rating is Good. 

--Q8) Which type of Cuisines are served in the Restaurant which is rated as 'Excellent'?

SELECT Country,Cuisines,Count_of_Restaurant
FROM
(
Select Cuisines, COUNT(Restaurant_ID)Count_of_Restaurant,B.Country 
FROM dbo.Zomato A
INNER JOIN Zomato_Country B
 ON A.Country_Code = B.[Country Code]
WHERE Rating_text = 'Excellent' AND Rating_text IS NOT NULL
Group by Cuisines,B.Country
)AD
Order by 1,3

--Analysis depicts that Cuisines served in restaurants at India, USA & UnitedKingdom partially covers variety of dishes and least variety of dishes are only available in Australia due to
--Which is rated As 'Excellent'


--Q9) Which type of Cuisines are served in the Restaurant which is rated as 'Good','Average','Poor''  --

SELECT Country,Cuisines,Count_of_Restaurant
FROM
(
Select Cuisines, COUNT(Restaurant_ID)Count_of_Restaurant,B.Country 
FROM dbo.Zomato A
INNER JOIN Zomato_Country B
 ON A.Country_Code = B.[Country Code]
WHERE Rating_text IN ('Good','Average','Poor') AND Rating_text IS NOT NULL
Group by Cuisines,B.Country
)AD
Order by 1

----We have observed that Restaurants in India, USA Covers Multi Cuisines dishes Which are Rated 'Good','Average','Poor'---

--Q10) Which type of Cuisines are served in the Restaurant which is Not Rated and these No Rated Restaurant are New  --

SELECT Country,Cuisines,Count_of_Restaurant
FROM
(
Select Cuisines, COUNT(Restaurant_ID)Count_of_Restaurant,B.Country 
FROM dbo.Zomato A
INNER JOIN Zomato_Country B
 ON A.Country_Code = B.[Country Code]
WHERE Rating_text = 'Not Rated' AND Rating_text IS NOT NULL
Group by Cuisines,B.Country
)AD
Order by 3 DESC


--We see that in India particularly there is growing demand of Food Eateries of Cuisines consisting of North Indian,Chinese,Fast Food,Bakery,Mughlai & Street Food.
--Which means high business opportunity for Zomato in terms of delivery fees and Commission, apart from this Zomato delivery partners fleet size will be also increase
---considering user traffic and orders will increase & fulfillment will need additional resources for Zomato


--Q11)Find the location of Restaurants in India where avg cost of two more than 1000, and doesn't supports Online delivery and Online table booking

SELECT City,COUNT(Restaurant_ID)No_of_Restaurants, Average_Cost_for_two, Has_Table_booking,Has_Online_delivery
FROM dbo.Zomato
WHERE Has_Table_booking = 'No' AND Has_Online_delivery = 'No' AND Currency = 'Indian Rupees(Rs.)'
Group by Average_Cost_for_two,Has_Table_booking,Has_Online_delivery,City
having AVG(Average_Cost_for_two) > 1000
Order by 2 desc,1

---We have More No_of_Restaurant in New Delhi,followed by Gurgaon where average expense for two individual is more than 1000 ---

--Q12) Find the location of Restaurants in India where average cost of two is less than 1000 and doesn't supports Online delivery and Online table booking

SELECT City,COUNT(Restaurant_ID)No_of_Restaurants, Average_Cost_for_two, Has_Table_booking,Has_Online_delivery
FROM dbo.Zomato
WHERE Has_Table_booking = 'No' AND Has_Online_delivery = 'No' AND Currency = 'Indian Rupees(Rs.)'
Group by Average_Cost_for_two,Has_Table_booking,Has_Online_delivery,City
having AVG(Average_Cost_for_two) < 1000
Order by 2 desc,1

-- We found out that NCR(National Capital Region) of India has highest number of restaurant which are pocket friendly. 


--Q13) Find the location of Restaurants In USA where average cost of two is less than 35$ and doesn't supports Online delivery and Online table booking

SELECT City,COUNT(Restaurant_ID)No_of_Restaurants, Average_Cost_for_two, Has_Table_booking,Has_Online_delivery
FROM dbo.Zomato
WHERE Has_Table_booking = 'No' AND Has_Online_delivery = 'No' AND  Country_Code = 216
Group by Average_Cost_for_two,Has_Table_booking,Has_Online_delivery,City
having AVG(Average_Cost_for_two) <= 35
Order by 2 desc,1

---We found that City in USA like Dalton,Davenport,Athens,Des Moines,Valdosta has most numbers of Restaurants and coming to its Geography 
---City of Dalton is often referred to as the "Carpet Capital of the World," home to over 150 carpet plants
----City of Davenport is Located along the banks of the Mississippi River seens Home to a variety of craft breweries, fun local shops, and nationally recognized chains.
-----Athens & Valdosta is located in Georgia & Des Moines in state of Iowa which is considered states of stategic imporatance. 


--Q14) Find the location of Restaurants In USA where average cost of two is more than 35$ and doesn't supports Online delivery and Online table booking


SELECT City,COUNT(Restaurant_ID)No_of_Restaurants, Average_Cost_for_two, Has_Table_booking,Has_Online_delivery
FROM dbo.Zomato
WHERE Has_Table_booking = 'No' AND Has_Online_delivery = 'No' AND  Country_Code = 216
Group by Average_Cost_for_two,Has_Table_booking,Has_Online_delivery,City
having AVG(Average_Cost_for_two) > 35
Order by 2 desc,1

--- We seen that Orlando has more numbers of restaurant in USA, Considering Orlando, Florida may be best known for Disney World and Universal.

--- Focus on votes & bands 

--Q15) Create a Votes_Band Column and Create a Inteval Bucket of 25 for Votes 0-100, 100 Inteval Bucket for votes 100 to 500 and 500 Inteval Bucket for votes between 500 to 1000
---    and 1000 Inteval Bucket for 1000+
SELECT * INTO Zomato_Updated FROM (
SELECT *, CASE 
		 WHEN CAST(Votes AS varchar(20)) BETWEEN 26 AND 50 THEN '26-50'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 0 AND 25 THEN '0-25'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 51 AND 75 THEN '51-75'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 76 AND 100 THEN '76-100'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 101 AND 200 THEN '101-200'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 201 AND 300 THEN '201-300'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 301 AND 400 THEN '301-400'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 401 AND 500 THEN '401-500'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 501 AND 1000 THEN '501-1000'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 1001 AND 2000 THEN '1001-2000'
		 WHEN CAST(Votes AS varchar(10)) BETWEEN 2001 AND 3000 THEN '2001-3000'
		 WHEN CAST(Votes AS varchar(10)) >= 3001 THEN '3001+'
		 END AS Votes_Band
FROM dbo.Zomato)Updated

Select * from Zomato_Updated

--Q16) Find the count of Restaurants as per Rating description and Rating Colour 

SELECT Rating_color,Rating_text,Votes_Band,COUNT(DISTINCT Restaurant_ID)No_of_Restaurant
FROM Zomato_Updated
Group BY Rating_color,Rating_text,Votes_Band
ORDER BY 4 DESC,2

--It is revealed during analysis that many restaurants are Not Rated having votes between 0-25 and 200+ restaurant are rated Excellent & Very Good having 1000+ votes
---While 8 restaurants rated Average, 1 restaurants rated poorly.



--Q17) Find the Name of the Restaurant and its geographical location where the votes are greater than 1000

SELECT A.Restaurant_Name,B.Country,A.City,COUNT(A.Votes)A,Votes_Band
FROM Zomato_Updated A
INNER JOIN Zomato_Country B
ON A.Country_Code = B.[Country Code]
WHERE Votes_Band  IN ('2001-3000','1001-2000','2001-3000','3001+')
GROUP BY A.Restaurant_Name,B.Country,A.City,Votes_Band
HAVING COUNT(A.Votes) >= 1


SELECT * FROM Zomato_Updated

--Q18) Find the Name of Cuisine which is famous across globe, also keeping filter on count greater than 50 ?

SELECT DISTINCT Cuisines, COUNT(*)No_Of_Cuisines
FROM Zomato_Updated
GROUP BY Cuisines
HAVING COUNT(*)>50
ORDER BY 2 DESC

-- Zomato Foodies Highly Prefers North Indian and Chinese Cuisines, Moderately Prefers Chinese,Fast Food, Mughlai Cuisines and Low Preference on Thai,Italian,Pizza Etc.
--- and to Deep Dive further, Zomota Geographical Presence and Popularity is located In India. Hence, Foodies preference is Directly Associated with North Indian and Chinese Cuisines


--Q19) Find the Name of the Restaurant which is rated 'Excellent' and Earned the highest Rating for North Indian Cuisines


SELECT Restaurant_Name,Cuisines,City,Average_Cost_for_two,Votes_Band 
FROM Zomato_Updated
WHERE Rating_color = 'Dark Green' AND Cuisines ='North Indian'
ORDER BY 5

-- Barbeque Nation in City of Lucknow and Guwahati and Bombay Brasserie in Chennai City is one of Excellent Places to Dine North Indian Cuisine.


--Q20) Find the Name of the Restaurant which is rated 'Excellent' and Earned the highest Rating for Chinese Cuisines ?


SELECT Restaurant_Name,Cuisines,City,Average_Cost_for_two,Votes_Band 
FROM Zomato_Updated
WHERE Rating_color = 'Dark Green' AND Cuisines ='Chinese'
ORDER BY 5

---Mainland China Restaurant in the City Of Doha is one of the Excellent Places to Dine Chinese Cuisine.

