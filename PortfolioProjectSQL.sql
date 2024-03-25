select *
from portfolioProject..CovidDeaths
order by location

select data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2
 
 --looking at total cases vs total deaths
 --show the likelihood of dying of covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

--specify location
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'Nigeria'
order by 1,2

--looking at the total cases vs population
--shows the percentage of the population that got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with the highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
from CovidDeaths
where continent is not null
Group By Location, population
order by PercentagePopulationInfected desc

--showing the countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)*100) as PercentagePopulationDeath
from CovidDeaths
where continent is not null
Group By Location
order by 2 desc

--lets break things down by continent
select location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)*100) as PercentagePopulationDeath
from CovidDeaths
where continent is null
Group By location
order by 2 desc

select continent, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)*100) as PercentagePopulationDeath
from CovidDeaths
where continent is not null
Group By continent
order by 2 desc

--showing the continets witht the higest death counts by using GROUP BY CONTINENT

--Global numbers of cases and death per day
select date, sum(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Global numbers of cases and death altogether
select sum(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


select *
from CovidDeaths Death
Join CovidVaccinations Vaccine
	on Death.location = Vaccine.location
	and Death.date = Vaccine.date
order by Death.location

--looking at total popultion vs vaccination
select Death.continent, Death.location, Death.date, Death.population,
Vaccine.new_vaccinations
from CovidDeaths Death
Join CovidVaccinations Vaccine
	on Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null
order by 2,3

--cummulative sum of the new_cases
select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as CummulativePeopleVaccinated
from CovidDeaths Death
Join CovidVaccinations Vaccine
	on Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null
order by 2,3


--use a CTE
With PopulationvsVaccination (continent, location, date, population, new_vaccinations, CummulativePeopleVaccinated) 
As
(
select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) 
as CummulativePeopleVaccinated
from CovidDeaths Death
Join CovidVaccinations Vaccine
	on Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null
)

Select location, Max(CummulativePeopleVaccinated) as totalvaccination
From PopulationvsVaccination
group by location
order by 2 desc



--Temp table (temporary table)

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CummulativePeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated 
select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) 
as CummulativePeopleVaccinated
from CovidDeaths Death
Join CovidVaccinations Vaccine
	on Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not nullù


Select location, Max(CummulativePeopleVaccinated) as totalvaccination
From #PercentPopulationVaccinated 
group by location
order by 2 desc



--creating View to store data for later visualization
Create View PercentPopulationVaccinated as
select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) 
as CummulativePeopleVaccinated
from CovidDeaths Death
Join CovidVaccinations Vaccine
	on Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null

--querying the view
select *
From PercentPopulationVaccinated