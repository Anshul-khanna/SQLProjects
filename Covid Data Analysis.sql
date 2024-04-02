use portfolio;

select * from coviddeaths
order by 3,4;

select * from covidvaccinations
order by 3,4;

-- selecting data to be used

select
	location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
from
	coviddeaths
order by
	1 , 2;
    
-- Looking at total cases vs total deaths

select
	location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as death_percentage
from
	coviddeaths
where location = 'India'
order by
	1 , 2;
    
-- Looking at total cases vs population

select
	location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 as infected_percentage
from
	coviddeaths
-- where location like '%states'
order by
	1 , 2;

-- Looking at countries with highest infection rate

select
	location,
    max(total_cases) as MAXINFECTION,
    population,
    max((total_cases/population))*100 as max_infected_percentage
from
	coviddeaths	
-- where location = 'India'
group by 
	location, population
order by
	max_infected_percentage desc;
    
-- showing countries with highest death count per population

SELECT 
    location, MAX(cast(total_deaths as unsigned)) AS TotalDeathCount
FROM
    coviddeaths
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking it down as per continent

SELECT 
    continent, MAX(cast(total_deaths as unsigned)) AS TotalDeathCount
FROM
    coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers

	select
		sum(total_cases),
		sum(total_deaths),
		(sum(new_deaths)/sum(new_cases))*100 as newdeathpercentage
	--     (total_deaths/total_cases)*100 as death_percentage
	from
		coviddeaths
	order by
		1 , 2;
	
select
		date,
		sum(total_cases),
		sum(total_deaths),
		(sum(new_deaths)/sum(new_cases))*100 as newdeathpercentage
	--     (total_deaths/total_cases)*100 as death_percentage
	from
		coviddeaths
	group by date
	order by
		1 , 2;
        
-- Covid Vaccinations
-- Looking at total population vs vaccination


SELECT 
    dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
    sum(vax.new_vaccinations) over (partition by dea.location order by dea.location and dea.date) as RollingPeopleVax
from    coviddeaths dea
        JOIN
    covidvaccinations vax ON dea.location = vax.location
        AND dea.date = vax.date
order by 1 , 2 , 3;

-- USE CTE

With PopVsVax (continent, location, date, population, new_vaccinations, rollingpeoplevax)
as (
SELECT 
    dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
    sum(vax.new_vaccinations) over (partition by dea.location order by dea.location and dea.date ROWS BETWEEN unbounded PRECEDING AND current row) as RollingPeopleVax
from    coviddeaths dea
        JOIN
    covidvaccinations vax ON dea.location = vax.location
        AND dea.date = vax.date
-- order by 1 , 2 , 3
)
select *, (rollingpeoplevax/population)*100 as rollingvaxpercantage
from PopVsVax;


-- Temp Table
drop table if exists PercentPopulationVaxed;
CREATE TEMPORARY TABLE PercentPopulationVaxed 
(
    Continent VARCHAR(255),
    location VARCHAR(255),
    Date DATETIME,
    population NUMERIC,
    New_vaccination NUMERIC,
    RollingPeopleVaxed NUMERIC
);

INSERT INTO PercentPopulationVaxed
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    population, 
    vax.new_vaccinations,
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaxed
FROM    
    coviddeaths dea
JOIN
    covidvaccinations vax ON dea.location = vax.location
    AND dea.date = vax.date;
-- where dea.continent is not null

SELECT 
    *
FROM 
    PercentPopulationVaxed;

-- create view

Create view PercentPopulationVaxed as 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    population, 
    vax.new_vaccinations,
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaxed
FROM    
    coviddeaths dea
JOIN
    covidvaccinations vax ON dea.location = vax.location
    AND dea.date = vax.date
where dea.continent is not null;
