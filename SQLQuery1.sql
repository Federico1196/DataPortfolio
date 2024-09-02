SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


SELECT	location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Likelyhood of dying from covid by country
SELECT	location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/NULLIF(total_cases,0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2



-- Total percentage of population got covid

SELECT	location,
		date,
		population,
		total_cases,
		ROUND((total_cases/NULLIF(population,0))*100, 6) AS PercentInfected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY date


-- Highest infection rates

SELECT	location,
		population,
		MAX(total_cases) AS HighestInfectionCount,
		(MAX(total_cases)/NULLIF(population,0))*100 AS PercentInfected
FROM CovidDeaths
GROUP BY population, location
ORDER BY PercentInfected desc


--highest death count by population

SELECT	location,
		MAX(cast(total_deaths as bigint)) AS totalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY totalDeathCount desc


-- highest death count by continent

SELECT	continent,
		MAX(cast(total_deaths as bigint)) AS totalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount desc


--Global numbers

SELECT  date,
		SUM(new_cases) as totalCases,
		SUM(cast(new_deaths as int)) as totalDeaths,
		SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


SELECT  
		SUM(new_cases) as totalCases,
		SUM(cast(new_deaths as int)) as totalDeaths,
		SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1, 2



-- Join for total vaccinations vs Population

SELECT  dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidDeaths as dea
	 join CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- CTE

With PopvsVax (Continent, Location, Date, Population, New_Vax, PeopleVaccinated )
as
(
SELECT  dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidDeaths as dea
	 join CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
)

Select *, (PeopleVaccinated/Population)*100
From PopvsVax


-- TEMP TABLE 

DROP TABLE IF EXISTS #PeopleVaccinated
CREATE TABLE #PeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
PeopleVaccinated numeric
)

INSERT INTO #PeopleVaccinated
SELECT  dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidDeaths as dea
	 join CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (PeopleVaccinated/Population)*100
From #PeopleVaccinated


-- View to store data for visualizations

CREATE View PercentageOfPeopleVaccinated as
SELECT  dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidDeaths as dea
	 join CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null


-- Using the view 

Select *
From PercentageOfPeopleVaccinated


-- additional views

Create View TotalDeathCounts as
SELECT	continent,
		MAX(cast(total_deaths as bigint)) AS totalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent


Select *
From TotalDeathCounts

