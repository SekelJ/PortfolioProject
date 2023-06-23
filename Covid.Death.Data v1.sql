SELECT *
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

/*
SELECT *
FROM Portfolio..CovidVaccinations
ORDER BY 3,4
*/


--Selecting Data



SELECT Location, date, total_cases, new_cases, total_deaths,  (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if infected with covid by country
SELECT Location, date, total_cases, total_deaths,  (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--1-2% chance of death if infected

--Looking at Total Cases vs Population
SELECT Location, date, total_cases, Population,  (CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 AS CasePercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

--Highest Infection Rates by Coountry compared to population
SELECT Location, MAX(total_cases) as HighestInfectionCount, Population,  (CAST(MAX(total_cases) AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 AS PercentPopulationInfected
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

--Break down by Continent
SELECT continent, (CAST(MAX(total_deaths) AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Showing Countries with Highest Death Count per population
SELECT Location, (CAST(MAX(total_deaths) AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count
SELECT continent, (CAST(MAX(total_deaths) AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers

SELECT date, SUM(new_cases), SUM(new_deaths), ((SUM(new_deaths)/SUM(new_cases))*100) as DeathPercentage--total_cases, total_deaths,  (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null AND new_cases <> 0
GROUP BY date, total_cases, total_deaths
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ((SUM(new_deaths)/SUM(new_cases))*100) as DeathPercentage--total_cases, total_deaths,  (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null AND new_cases <> 0
--GROUP BY total_cases, total_deaths
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(DEC(12,2), vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) RollingPeopleVaccinated
,
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(DEC(12,2), vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2,3
)T
--Select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVaccinatedPercent
--FROM PopvsVac

--Temp Table

--IF table needs to be remade / edited use, can just keep there
DROP TABLE if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(DEC(12,2), vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2,3

Select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVaccinatedPercent
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinatedv as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(DEC(12,2), vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2,3

SELECT *
FROM PercentPopulationVaccinatedv