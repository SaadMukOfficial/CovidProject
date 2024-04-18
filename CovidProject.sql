--SELECT *
--FROM CovidProject..CovidDeaths
--ORDER BY 3, 4

--look at the Data that we are going to be using:
--SELECT *
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--ORDER BY 3, 4


--SELECT CD.continent , cd.location, cd.date, cd.total_cases, 
--cd.new_cases, cd.total_deaths, cd.population
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3

--looking at Total Cases VS Total Deaths:
--SELECT cd.continent, cd.location, cd.date, cd.total_cases, cd.total_deaths, 
--	CASE 
--		WHEN cd.total_cases = 0 THEN 0
--		ELSE CAST(total_deaths * 100.0 / total_cases AS decimal(10, 2))
--	END AS DeathP
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3

--looking at United States for Total Cases VS Total Deaths:
--SELECT cd.continent, cd.location, cd.date, cd.total_cases, cd.total_deaths,
--	CASE WHEN cd.total_cases = 0 THEN 0 -- Set 0 for zero cases
--		ELSE CAST(cd.total_deaths * 100.0 / cd.total_cases AS decimal(10,2)) 
--	END AS DeathP
--FROM CovidProject..CovidDeaths cd
--WHERE cd.location like '%States%'
--ORDER BY 2, 3;

--looking at the Total Cases VS Population
--SELECT cd.continent, cd.location, cd.date, cd.population, cd.total_cases,
--	CASE WHEN cd.total_cases = 0 THEN 0 -- Set 0 for zero cases
--		ELSE CAST(cd.total_cases * 100.0 / cd.population AS decimal(10,8)) 
--	END AS CasesP
--FROM CovidProject..CovidDeaths cd
--WHERE cd.location like '%states%'
--ORDER BY 2, 3;

--looking at Countries with highest infection rate in the World:
--SELECT cd.location, cd.population, MAX(cd.total_cases) AS TotalCases,
--Max(CAST(cd.total_cases * 100.0 / cd.population AS decimal(10,8))) CasesP
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--GROUP BY cd.location, cd.population
--ORDER BY CasesP desc

--looking at Countries with highest death rate in the World:
--Try 1:
--SELECT cd.location, MAX(CAST(cd.total_deaths AS int)) AS TotalDeaths
--FROM CovidProject..CovidDeaths cd
--GROUP BY cd.location
--ORDER BY TotalDeaths desc

--Try 2:
--SELECT cd.location, MAX(CAST(cd.total_deaths AS int)) AS TotalDeaths
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--GROUP BY cd.continent, cd.location
--ORDER BY TotalDeaths desc

--Let's break things down by Continent:
--SELECT cd.location, MAX(CAST(cd.total_deaths AS int)) AS TotalDeaths
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NULL
--GROUP BY cd.continent, cd.location
--ORDER BY TotalDeaths desc

--Let's break things down by Continent (MISTAKEN):
--SELECT cd.continent, MAX(CAST(cd.total_deaths AS int)) AS TotalDeaths
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--GROUP BY cd.continent
--ORDER BY TotalDeaths desc

-- Global Numbers date wise and Deaths VS Cases:
--SELECT cd.date, SUM(CAST(cd.new_cases AS INT)) TotalCases, SUM(CAST(cd.new_deaths AS INT)) TotalDeaths,
--SUM(CAST(cd.new_deaths AS INT)) * 100.0 / SUM(CAST(cd.new_cases AS INT)) AS DeathPercentage
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL
--GROUP BY cd.date
--ORDER BY 1;

-- Global Numbers for Deaths VS Cases:
--SELECT SUM(CAST(cd.new_cases AS INT)) TotalCases, SUM(CAST(cd.new_deaths AS INT)) TotalDeaths,
--SUM(CAST(cd.new_deaths AS INT)) * 100.0 / SUM(CAST(cd.new_cases AS INT)) AS DeathPercentage
--FROM CovidProject..CovidDeaths cd
--WHERE CD.continent IS NOT NULL

----------------------------------------------------------
--Vaccinations Table:
--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3, 4

--JOIN the 2 Tables:
--SELECT *
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--ORDER BY 3, 4

--looking at Total Population VS Vaccinations:
--SELECT cd.continent, cd.location, cd.date, 
--cd.population, cv.new_vaccinations, cv.total_vaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3

--looking at Total Population VS Vaccinations without Total_Vacc:
--SELECT cd.continent, cd.location, cd.date, cd.population,  
--cv.new_vaccinations, 
--SUM(CONVERT(INT, cv.new_vaccinations)) 
--OVER (PARTITION BY cd.location ORDER BY cd.date) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3

------------------------------------------------------
--use CTE for sum of total SumVaccinatios / Population:
--1st try:
--WITH PopVSVac (continent, location, date, population,
--new_vaccinations, SumVaccinations)
--AS
--(
--SELECT cd.continent, cd.location, cd.date, cd.population,  
--cv.new_vaccinations, 
--SUM(CAST(cv.new_vaccinations AS INT)) 
--OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--)
--SELECT *,
--CASE WHEN SumVaccinations IS NULL THEN 0
--	ELSE CAST(SumVaccinations * 100.0 / population AS decimal(10, 7))
--END AS VacPopPercentage
--FROM PopVSVac
--WHERE new_vaccinations IS NOT NULL

--2nd Try:
--WITH PopVSVac (continent, location, date, population,
--new_vaccinations, SumVaccinations)
--AS
--(
--SELECT cd.continent, cd.location, cd.date, cd.population,  
--cv.new_vaccinations, 
--SUM(CAST(cv.new_vaccinations AS INT)) 
--OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--)
--SELECT *, (SumVaccinations * 100.0 / population)--CAST(SumVaccinations * 100.0 / population AS decimal(10, 7))
--AS VaccinatedPerPopulationPercentage
--FROM PopVSVac
--WHERE new_vaccinations IS NOT NULL

--3Rd Try:
--WITH PopVSVac (continent, location, date, population,
--new_vaccinations, SumVaccinations)
--AS
--(
--SELECT cd.continent, cd.location, cd.date, cd.population,  
--cv.new_vaccinations, 
--SUM(CAST(cv.new_vaccinations AS INT)) 
--OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL AND CV.new_vaccinations IS NOT NULL
--)
--SELECT *, (SumVaccinations * 100.0 / population)
--AS VaccinatedPerPopulationPercentage
--FROM PopVSVac

--Try country wise and NOT date wise (MYSELF):
--WITH PopVSVac (location, population, SumVaccinations)
--AS
--(
--SELECT cd.location, cd.population, SUM(CAST(cv.new_vaccinations AS INT)) 
--OVER (PARTITION BY cd.location) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL 
--GROUP BY cd.location, cd.population, cv.new_vaccinations
--)
--SELECT DISTINCT(location), population, 
--SumVaccinations, (SumVaccinations * 100.0 / population)
--AS VaccinatedPerPopulationPercentage
--FROM PopVSVac


-------------------------------------------------------------
--TEMP TABLES:
--1st try:
--DROP TABLE IF EXISTS #PopVSVac
--CREATE TABLE #PopVSVac
--(continent nvarchar(255),
--location  nvarchar(255),
--date date,
--population numeric,
--new_vaccination numeric,
--SumVaccinations numeric
--)
--INSERT INTO #PopVSVac
--SELECT cd.continent, cd.location, cd.date, cd.population,  
--cv.new_vaccinations, 
--SUM(CONVERT(INT, cv.new_vaccinations)) 
--OVER (PARTITION BY cd.location ORDER BY cd.date) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3
--SELECT *, (SumVaccinations * 100.0 / population)
--AS VaccinatedPerPopulationPercentage
--FROM #PopVSVac

------------------------------------------------------------------------
--Creating a VIEW to store data for later:
--Create VIEW PopVSVac AS
--SELECT cd.continent, cd.location, cd.date, cd.population,  
--cv.new_vaccinations, 
--SUM(CONVERT(INT, cv.new_vaccinations)) 
--OVER (PARTITION BY cd.location ORDER BY cd.date) SumVaccinations
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--	ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
----ORDER BY 2, 3

SELECT *
FROM PopVSVac