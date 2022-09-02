select * from census_dataexploration.dbo.Data1;

select * from census_dataexploration.dbo.Data2;
-- counting number of rows into data set

select count(*) from census_dataexploration..data1
select count(*) from census_dataexploration..data2

-- dataset for Punjab and Delhi

select * from census_dataexploration.dbo.Data1 WHERE State IN ('Punjab', 'Delhi');

select sum(Population) as Population from census_dataexploration..data2

-- avgerage growth

select State, avg(Growth)*100 as Average_Growth from census_dataexploration..data1
GROUP BY State; 

--average sex ratio

select State, round(avg(sex_ratio),0) as Average_sex_ratio from census_dataexploration..data1 group by state order by Average_sex_ratio desc;

--avaerage literacy rate

select State, round(avg(literacy),0) as Average_literacy_ratio from census_dataexploration..data1 
group by state 
HAVING round(avg(literacy),0) > 90 order by Average_literacy_ratio desc;

-- Top 4 state showing the highest growth ratio

select top 4 State, avg(Growth)*100 as Average_growth from census_dataexploration..data1 group by state order by Average_growth desc;

--select state, (Growth)*100
--from census_dataexploration..data1
--where state = 'Nagaland';

-- bottom 4 state showing the lowest growth ratio

select top 4 State, avg(Growth)*100 as Average_growth from census_dataexploration..data1 group by state order by Average_growth asc;

--TEMP TABLE
-- top 4 and bottom 4 states in literacy rate

drop table if exists #topstates;   -- if we run entire thing from create table statement it will throw error, topstates is already present in db so used drop to delete data at very first instance
CREATE table #topstates
(state nvarchar(255), 
topstate float)

INSERT INTO #topstates
select state, round(avg(literacy),0) as Average_literacy_ratio from census_dataexploration..data1 
group by state order by Average_literacy_ratio desc;

select top 4 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;   -- if we run entire thing from create table statement it will throw error, topstates is already present in db so used drop to delete data at very first instance
CREATE table #bottomstates
(state nvarchar(255), 
bottomstate float)


INSERT INTO #bottomstates
select state, round(avg(literacy),0) as Average_literacy_ratio from census_dataexploration..data1 
group by state order by Average_literacy_ratio desc;

select top 4 * from #bottomstates order by #bottomstates.bottomstate asc;

--union

SELECT * FROM(

select top 4 * from #topstates order by #topstates.topstate desc)a

UNION
SELECT * FROM(
select top 4 * from #bottomstates order by #bottomstates.bottomstate asc)b;



--select state, round(avg(literacy),0)
--from census_dataexploration..data1
-- where state = 'Goa'
-- group by state;

select distinct state from census_dataexploration..data1 
where lower(state) like 'd%' and lower(state) like '%i'

-- JOINING BOTH TABLES

-- total males and females
(select c.district, c.state, c.population, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from 
(select a.district, a.state, a.sex_ratio, b.population from census_dataexploration..data1 a
INNER JOIN census_dataexploration..data2 b
ON a.district = b.district) c)

--Total literacy rate
--total literate people/population = literacy_ratio
--total literate people = literacy_ratio*population

select c.district, c.state, c.literacy_ratio*c.population literate_people, (1-c.literacy_ratio)*c.population illeterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from census_dataexploration..data1 a
INNER JOIN census_dataexploration..data2 b
ON a.district = b.district) c


-- population in previous census

select c.district, c.state, round(c.population/(1+c.growth),0) previos_census_population, c.population current_population from
(select a.district, a.state, a.growth growth, b.population from census_dataexploration..data1 a
INNER JOIN census_dataexploration..data2 b
ON a.district = b.district) c


-- top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from census_dataexploration..data1) a
where a.rnk in (1,2,3) order by state