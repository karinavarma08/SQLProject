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

