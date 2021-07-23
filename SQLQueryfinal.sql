SELECT*
FROM PortfolioProjects..['CVaccines$']
ORDER BY 3,4

SELECT*
FROM PortfolioProjects..['CDeaths$']
ORDER BY 3,4



----SELECT DATA WE WANT TO USE----

SELECT LOCATION, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..['CDeaths$']
ORDER BY 1,2



----LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT LOCATION,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercenteage
FROM PortfolioProjects..['CDeaths$']
ORDER BY 1,2



----SHOWS LIKELIHOOD IF YOU CONTRACT INFECTION IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..['CDeaths$']
where location like '%India%'



----LOOKING AT TOTAL CASES VS TOTAL POPULATION OF INDIA
----AND SHOWS WHAT PERCENTAGE OF PUPULATION CONTRACTED COVID-19

SELECT location , date,total_cases, population, (total_cases/population)*100 as covid_infected
FROM PortfolioProjects..['CDeaths$']
WHERE location like '%India%'
ORDER BY 1,2



----LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
----HIGHEST NUMBER FROM TOTAL CASE, AND HIGHEST PERCENTAGE OF INFECTION FROM  max of total_Cases/population

SELECT location, population, MAX(total_cases) AS maximumnumber_oftotalcases, MAX(total_cases/population)* 100 AS totalcovid_infected_casesfrompopulation
FROM PortfolioProjects..['CDeaths$']
GROUP BY location,population
ORDER BY location



----SHOWING COUNTRIES WITH HIGHEST/TOTAL DEATH COUNT PER POPULATION

SELECT location,MAX(cast(total_deaths as int)) as totalDeaths,population
FROM PortfolioProjects..['CDeaths$']
WHERE continent is not null
GROUP BY location,population
ORDER BY totalDeaths DESC



----SHOWING TOTAL DEATHS PER CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as totalDeaths
FROM PortfolioProjects..['CDeaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeaths DESC

--2nd

SELECT location, MAX(cast(total_deaths as int)) as totalDeaths
FROM PortfolioProjects..['CDeaths$']
WHERE continent is  null--we took continent is null, because we need to also have data of deaths from there, no null simply means we are taking lesser data
GROUP BY location
ORDER BY totalDeaths DESC



----GLOBAL NUMBERS

SELECT DISTINCT location, MAX(cast(total_deaths as int)) as totalDeaths, population
FROM PortfolioProjects..['CDeaths$'] 
WHERE continent is not null
GROUP BY location,population
ORDER BY totalDeaths DESC	


SELECT date, SUM(new_cases) AS totalcases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..['CDeaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--2nd

SELECT  SUM(new_cases) AS totalcases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..['CDeaths$']
WHERE continent IS NOT NULL
ORDER BY 1,2


----POPULATION VS VACCINATIONS
----USING CTE (COMMON TABLE EXPPRESSION)

WITH PopVsVac (continent, locations, date, population, new_vaccinations, RollingVaccinations) --TITLES
AS(

SELECT DISTINCT Deaths.continent, Deaths.location,  Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(CONVERT(bigint, Vaccines.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,
Deaths.date) AS RollingVaccinations
FROM PortfolioProjects..['CDeaths$'] AS Deaths
JOIN PortfolioProjects..['CVaccines$'] AS Vaccines 
	ON Deaths.location = Vaccines.location
	AND Deaths.date = Vaccines.date
WHERE Deaths.continent IS NOT NULL

)
SELECT*, (RollingVaccinations/population)*100
FROM PopVsVac
	


----TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Locations nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	Rolling_Vaccinations numeric
)

INSERT INTO PercentPopulationVaccinated
	SELECT DISTINCT Deaths.continent, Deaths.location,  Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
	SUM(CONVERT(bigint, Vaccines.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,
	Deaths.date) AS RollingVaccinations
	FROM PortfolioProjects..['CDeaths$'] AS Deaths
	JOIN PortfolioProjects..['CVaccines$'] AS Vaccines 
		ON Deaths.location = Vaccines.location
		AND Deaths.date = Vaccines.date
	--WHERE Deaths.continent IS NOT NULL

SELECT*, (Rolling_Vaccinations/population)*100
FROM PercentPopulationVaccinated
	


----CREATING VIEWS FOR LATER VISUALIZATIONS
--1st view

CREATE VIEW VACCINEATEDPERCENT AS
SELECT  Deaths.continent, Deaths.location,  Deaths.date, Deaths.population, Vaccines.new_vaccinations, 
SUM(CONVERT(bigint, Vaccines.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,
Deaths.date) AS RollingVaccinations
FROM PortfolioProjects..['CDeaths$'] AS Deaths
JOIN PortfolioProjects..['CVaccines$'] AS Vaccines 
	ON Deaths.location = Vaccines.location
	AND Deaths.date = Vaccines.date
WHERE Deaths.continent IS NOT NULL




--2nd view

CREATE VIEW MaxDeathsLocations AS
SELECT location, MAX(cast(total_deaths as int)) as totalDeaths
FROM PortfolioProjects..['CDeaths$']
WHERE continent is  null--we took continent is null, because we need to also have data of deaths from there, no null simply means we are taking lesser data
GROUP BY location



/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



---- Just a double check based off the data provided
---- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

---- We take these out as they are not inluded in the above queries and want to stay consistent
----European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc















