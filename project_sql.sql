USE energy_consumption;

-- Cleaning and Modeling Dataset

-- renaming column name
alter table country_3 modify column country varchar(30);
ALTER TABLE emission_3 Change COLUMN `energy type` energy_type varchar(20);

-- setting primary key
alter table country_3
add primary key(Country);

-- Connecting Tables Using Foreign Key
alter table consum_3 modify column country varchar(30);
alter table consum_3 
add constraint fk_1
foreign key (country) References country_3(Country);

alter table emission_3 modify column country varchar(30);
alter table emission_3 
add constraint fk_2
foreign key (country) References country_3(Country);

alter table gdp_3 modify column country varchar(30);
alter table gdp_3 
add constraint fk_3
foreign key (country) References country_3(Country);

alter table population_3 modify column countries varchar(30);
alter table population_3 
add constraint fk_4
foreign key (countries) References country_3(Country);

alter table production_3 modify column country varchar(30);
alter table production_3 
add constraint fk_5
foreign key (country) References country_3(Country);

-- Data Analysis Questions
-- eneral & Comparative Analysis
-- What is the total emission per country for the most recent year available?

select country,year,sum(emission) as Total_Emission
from emission_3
where year = (select max(year) from emission_3) 
group by country, year
order by Total_Emission desc;


-- What are the top 5 countries by GDP in the most recent year? 

select country,value from gdp_3
where year = (select max(year) from gdp_3) 
order by value desc 
limit 5;

-- Compare energy production and consumption by country and year. 
Select
    p.country,p.year,SUM(p.production) as total_production,
    SUM(c.consumption) as total_consumption,SUM(p.production) - SUM(c.consumption) AS energy_balance
From production_3 p
join consum_3 c
    on p.country = c.country
    and p.year = c.year
    and p.energy = c.energy
group by p.country, p.year
order by p.country, p.year desc;

-- Which energy types contribute most to emissions across all countries? 
select energy_type,sum(emission) as total_emission 
from emission_3 
group by energy_type;

 -- Trend Analysis Over Time
-- How have global emissions changed year over year?
SELECT 
    year,
    SUM(emission) AS total_emission,
    SUM(emission) - LAG(SUM(emission)) OVER (ORDER BY year) AS year_by_year
FROM 
    emission_3
GROUP BY 
    year
ORDER BY 
    year;

-- What is the trend in GDP for each country over the given years?
SELECT country,year,value AS gdp_3,
value - LAG(value) OVER (PARTITION BY country ORDER BY year) AS yoy_change
from gdp_3
order by country, year;

-- How has population growth affected total emissions in each country?
select p.countries,p.value as population,sum(e.emission) as total_emission,
p.value - Lag(p.value) over (Partition by e.country order by e.year) as population_growth
from population_3 as p
join emission_3 as e
on p.countries=e.country
and p.year=e.year
group by e.country,e.year,p.value
order by e.country,e.year;

-- Has energy consumption increased or decreased over the years for major economies?
select c.country,c.year,
    sum(c.consumption) as total_consumption,sum(g.value) as total_gdp
from consum_3 as  c
join gdp_3 as g 
    on c.country = g.country 
    and c.year = g.year
where c.country IN (
    select country FROM (
        select country
        from consum_3
        group by country
        order by SUM(consumption) DESC
        limit 10
    ) as top_countries
)
group by c.country, c.year
order by total_gdp desc;


-- What is the average yearly change in emissions per capita for each country?

select energy,year,SUM(consumption) AS total_consumption,
sum(consumption) - lag(SUM(consumption)) over (partition by energy order by year) 
as yoy_difference
from consum_3
group by energy, year
order by energy, year;


-- Ratio & Per Capita Analysis
-- What is the emission-to-GDP ratio for each country by year?
select e.country,e.year,sum(e.emission) as total_emission,g.value as gdp,
round(SUM(e.emission) / g.value,2) AS emission_gdp_ratio
from emission_3 e
join gdp_3 g
on e.country = g.country
and e.year = g.year
group by e.country, e.year, g.value
order by e.country, e.year;


-- What is the energy consumption per capita for each country over the last decade?
select c.country,c.year,
sum(c.consumption) / p.value as per_capita_consumption
from consum_3 c
join population_3 p
    on c.country = p.countries
    and c.year = p.year
where c.year >= (select max(year) - 10 from consum_3)
group by c.country, c.year, p.value
order by c.country, c.year;

-- How does energy production per capita vary across countries?
select p.country,p.year, sum(production)/pp.value Per_capita_production from production_3 as p
join
population_3 as pp
on p.country = pp.countries
and p.year = pp.year

group by p.country,p.year,pp.value
order by p.country,p.year desc;


-- What is the correlation between GDP growth and energy production growth?
with growth_cte as (
select p.country,p.year,
(g.value - lag(g.value) over (partition by p.country order by p.year))/lag(g.value) over 
(partition by p.country order by p.year) as gdp_growth,
(sum(p.production)-lag(sum(p.production)) over (partition by p.country order by p.year))/lag(sum(p.production)) over
 (partition by p.country order by p.year) as prod_growth
    from production_3 p
    join gdp_3 g
        on p.country = g.country
        and p.year = g.year
    group by p.country, p.year, g.value
)
select country,
(count(*) * sum(gdp_growth * prod_growth) - sum(gdp_growth) * sum(prod_growth))
/sqrt((count(*) * sum(gdp_growth * gdp_growth) - pow(sum(gdp_growth), 2)) * (count(*) * sum(prod_growth * prod_growth)
-pow(sum(prod_growth), 2))) as correlation
from growth_cte
where gdp_growth is not null 
and prod_growth is not null
group by country
order by correlation desc;





 -- Global Comparisons

-- What are the top 10 countries by population and how do their emissions compare?
select p.countries as country,max(p.value) as population,
sum(e.emission) as total_emission
from population_3 p
join emission_3 e
on p.countries = e.country
and p.year = e.year
group by p.countries
order by population desc
limit 10;


-- which countries have reduced their total emissions the most over time?
SELECT 
    country,
    SUM(CASE WHEN year = (SELECT MIN(year) FROM emission_3) THEN emission END) -
    SUM(CASE WHEN year = (SELECT MAX(year) FROM emission_3) THEN emission END) 
    AS emission_reduction
FROM emission_3
GROUP BY country
ORDER BY emission_reduction DESC;

-- What is the global share (%) of emissions by country?
select 
    country,
    sum(case when year = (select min(year) from emission_3) then emission end) -
    sum(case when year = (select max(year) from emission_3) then emission end) 
    as emission_reduction
from emission_3
group by country
order by emission_reduction desc;

-- What is the global average GDP, emission, and population by year?
select g.year,avg(g.value) as avg_gdp,avg(e.emission) as avg_emission,
avg(p.value) as avg_population
from gdp_3 g
join emission_3 e
on g.country = e.country
and g.year = e.year
join population_3 p
on g.country = p.countries
and g.year = p.year
group by g.year
order by g.year;