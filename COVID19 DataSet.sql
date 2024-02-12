select *
FROM CovidDeaths
Where continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccines
--Where continent IS NOT NULL
--ORDER BY 3,4

SELECT Location, date,total_cases, new_cases, total_deaths,population
FROM CovidDeaths
Where continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases VS total Deaths
--shows us the likely hood of a person dying if he contracts covid

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From CovidDeaths
Where location like '%pakistan%'
AND continent IS NOT NULL
order by 1,2

--looking at total cases vs the population

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PopulationPercentage
From CovidDeaths
--Where location like '%pakistan%'
--where location like '%United kingdom%'
order by 1,2

-- looking at countries with the highest infection rate with in relation to it population

Select Location, population, MAX(total_cases) as HighestInfectioncount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentagePopulationInfected
From CovidDeaths
--Where location like '%pakistan%'
--where location like '%United kingdom%'
Where continent IS NOT NULL
Group by population, location
order by PercentagePopulationInfected DESC

-- showing the number of death as per population

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%pakistan%'
--where location like '%United kingdom%'
Where continent IS NOT NULL
Group by location
order by TotalDeathCount DESC

--Doing it by Contients Now

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC

--showing the continents with the highes deathcount as per population

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC


--breaking global numbers
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%pakistan%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2


--looking at total population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- KNOW USING A CTE

WITH PopvsVac (Continent, location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--DOING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




----Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

