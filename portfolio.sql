
-- death vs total case 

SELECT location, date,total_cases,new_cases,total_deaths,population,(CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 as deathpercentage
FROM covid_deaths
Where location like 'andorra'
ORDER BY total_cases desc

-- covid vs population(tells about what amount of population got covid)

SELECT location,date,total_cases,new_cases,total_deaths,population,CAST(ROUND((CONVERT(float,total_cases)/population)*100,5) as nvarchar) +'%' as covid_chance
FROM covid_deaths
Where location like '%india%'
ORDER BY 7 desc

---which country have infection rate

SELECT location,MAX(cast(total_cases as int)) as Highest_case,population,((Max(CONVERT(float,total_cases)))/population)*100 as covid_percentage
FROM covid_deaths
Where location like '%india%'
and continent is not null
group by location , population
order by 4 desc

-- highest death in country
SELECT location,MAX(cast(total_deaths as int)) as highest_deathcount, (MAX(cast(total_deaths as int))/population)*100 as percentage
FROM covid_deaths
--Where location like '%india%' and
WHere continent is not null
group by location,population
order by 2 desc

-- GLOBAL NUMBER

SELECT SUM(new_cases) as total_cases,Sum(new_deaths) as total_death ,Sum(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM covid_deaths
--Where location like '%india%' and
WHere continent is not null and new_cases != 0
--group by date
order by 4 desc


-- vaccination table
SELECT cd.continent,cd.location,cd.date,cd.new_cases,cd.population,cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location,cd.date) as rolling_vaccination
FROM covid_vaccine cv
join covid_deaths cd
	on cv.location = cd.location
	and cv.date = cd.date
WHERE cd.continent is not null -- and cd.location like '%india%'
order by 2,3


-- USE CTE
with population_vacc(continent,location,date,new_cases,population,new_vaccinations,rolling_vaccination)
as
(SELECT cd.continent,cd.location,cd.date,cd.new_cases,cd.population,cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location,cd.date) as rolling_vaccination
FROM covid_vaccine cv
join covid_deaths cd
	on cv.location = cd.location
	and cv.date = cd.date
WHERE cd.continent is not null and cv.continent is not null
)
SELECT *,rolling_vaccination/population*100 as vactioned_people
from population_vacc
order by 2,3

--use temp table

Drop table if exists #temp1
CREATE TABLE #temp1 (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	new_cases numeric,
	population numeric,
	new_vaccinations numeric,
	rolling_vaccination numeric
)

INSERT into #temp1
SELECT cd.continent,cd.location,cd.date,cd.new_cases,cd.population,cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location,cd.date) as rolling_vaccination
FROM covid_vaccine cv
join covid_deaths cd
	on cv.location = cd.location
	and cv.date = cd.date
WHERE cd.continent is not null and cv.continent is not null


--create view for later visulaization
create view  coviddata as
SELECT cd.continent,cd.location,cd.date,cd.new_cases,cd.population,cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location,cd.date) as rolling_vaccination
FROM covid_vaccine cv
join covid_deaths cd
	on cv.location = cd.location
	and cv.date = cd.date
WHERE cd.continent is not null and cv.continent is not null

-- using view
select *
from coviddata