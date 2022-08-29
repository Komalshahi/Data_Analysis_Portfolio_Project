--COVID-19 DATA EXPLORATION

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECTING DATA THAT IS GOING TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths where location like '%hong%'
WHERE continent is not null
order by 1,2

--Total Cases vs Population
--shows what % population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
order by 1,2


--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount   
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount   
FROM PortfolioProject..CovidDeaths 
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc


--CONTINENTS WITH HIGHEST DEATH COUNT 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as
int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


--TOTAL POPULATION VS VACCINATION
--shows %age of population that received atleast one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USING CTE to perform CALCULATIONS on Partition by in the previous query

WITH PopvsVac  (Continenet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM PopvsVac



--USING TEMP TABLE to perform CALCULATIONS on Partition by 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * FROM PercentPopulationVaccinated


CREATE VIEW HighestDeathsContinent AS
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

SELECT * FROM HighestDeathsContinent

