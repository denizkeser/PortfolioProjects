--Let's check if the imported tables are working.

SELECT location, date, new_deaths from coviddeaths
SELECT location, date, tests_per_case from covidvaccinations

--select data that we are going to be using

SELECT location,date , total_cases, new_cases, total_deaths, population 
from coviddeaths
order by 1,2

--looking at total cases vs total death


SELECT location,date , total_cases, total_deaths, round(((total_deaths/total_cases)*100),3) as percentage_of_death 
from coviddeaths
where location="Turkey"
order by 1,2

-- total cases vs population. show what percentage of population got covid


SELECT location,date , total_cases, population, round(((total_cases/population)*100),3) as percentage_of_population_got_covid 
from coviddeaths
where location="Turkey"
order by 1,2

-- loking at countries with highest infection rate compared to population

SELECT location, max(total_cases) as highestinfcount, population, round(((total_cases/population)*100),3) as percentage_of_population_got_covid 
from coviddeaths
GROUP by 1,3
order by 4 DESC

--showing highest death count per population

SELECT location, max(cast(total_deaths as INT))
from coviddeaths
WHERE continent is not NULL
GROUP by 1
order by 2 DESC

--Countries with the highest population loss as a percentage
SELECT location, (max(cast(total_deaths as INT))/population)*100
from coviddeaths
WHERE continent is not NULL
GROUP by 1
order by 2 DESC

-- death counts per contınents

SELECT continent, max(cast(total_deaths as INT))
from coviddeaths
WHERE continent is not NULL
GROUP by 1
order by 2 DESC
-- above datas are not accurate. we can check lie this

SELECT location, max(cast(total_deaths as INT))
from coviddeaths
WHERE continent is NULL
GROUP by 1
order by 2 DESC

--global numbers by days

select date, sum(new_cases),sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
GROUP by date
order by 1,2

--global numbers by years

select substr(date,-4,4)as year, sum(new_cases) as totalcases,sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
GROUP by 1
order by 1,2

--total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--use cte

WITH popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp TABLE

drop table if EXISTS percentpopulationvaccinated
create table percentpopulationvaccinated(continent TEXT,
location TEXT,
date text,
population NUMERIC,
new_vaccinations NUMERIC,
rollingpeoplevaccinated NUMERIC
)
INSERT INTO percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

select *, (rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated

--creating view to store data for later visualisation

CREATE VIEW percentpopulationvaccinatedview as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null