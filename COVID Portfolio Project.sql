--SELECT *
--FROM CovidDeaths
--WHERE continent is NOT NULL
--ORDER BY 3,4



--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


--Looking at the Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is NOT NULL
ORDER BY 1,2


--Looking at the Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is NOT NULL
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


--Showing the Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the Highest Death Count

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC



--Global Numbers

--Total Cases/Deaths per Day across the World
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1

--Allover Total Cases/Deaths across the World
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL




--SELECT *
--FROM CovidVaccinations
--WHERE continent is NOT NULL
--ORDER BY 3,4


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY dea.location, dea.date


--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY dea.location, dea.date
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
FROM PopvsVac


--Use Temp Table

DROP TABLE if EXISTS #PercentPopulationVaccinated  --> add this to make any alterations/ easy to maintain
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY dea.location, dea.date

SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated


--Creating VIEW to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY dea.location, dea.date

SELECT *
FROM PercentPopulationVaccinated