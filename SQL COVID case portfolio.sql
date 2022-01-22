---Data exploration with COVID case--
SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--select *
--from PortfolioProjects..CovidVaccination
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
SELECT location, date, population, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%france%'
and continent is not null
ORDER BY 1,2
--Percentage of population who got covid-19
SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%france%'
and continent is not null
ORDER BY 1,2

--Countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPopulationPercentage desc

--Countries with the highest death rate due to covid19 per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths desc

--Breaking things down by continent

--Continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc

--Global numbers
SELECT date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%france%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%france%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vacination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as people_vaccinated
--, (people_vaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

with PopulationvsVaccination (continent, location, date, population, new_vaccinations, people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as people_vaccinated
--, (people_vaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (people_vaccinated/population)*100
FROM PopulationvsVaccination


--TEMP TABLE

DROP TABLE if exists #PopulationVaccinatedPercentage
CREATE TABLE #PopulationVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

INSERT INTO #PopulationVaccinatedPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as people_vaccinated
--, (people_vaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (people_vaccinated/population)*100
FROM #PopulationVaccinatedPercentage


--Creating view to prepare for data visualization

CREATE VIEW PopulationVaccinatedPercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as people_vaccinated
--, (people_vaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PopulationVaccinatedPercentage
