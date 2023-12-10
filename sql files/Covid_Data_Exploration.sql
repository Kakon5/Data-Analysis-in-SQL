-- select data
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..covidDeaths
ORDER BY 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying because of covid in a specific country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_death
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%desh%'
ORDER BY 1,2

-- looking at total cases vs population
-- shows the percentage of total population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as percentage_of_cases
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%desh%'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population))*100 as percentage_of_infection
FROM PortfolioProject..covidDeaths
GROUP BY location, population
ORDER BY percentage_of_infection DESC


-- showing the countries with highest death count compared to population
SELECT location, population, MAX(total_deaths) as highest_deaths, MAX((total_deaths/population))*100 as percentage_of_deaths
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_deaths DESC

-- showing the continents with total death count
SELECT continent, MAX(total_deaths) as total_death_count
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

-- showing the countries with highest death count by continent
SELECT location, MAX(total_deaths) as highest_deaths
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
AND continent LIKE 'Asia'
GROUP BY location, population
ORDER BY highest_deaths DESC

-- global number
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as percentage_of_death
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
AND new_cases != 0
GROUP BY date
ORDER BY 1

-- creating view of global numbers
CREATE VIEW GlobalCovidCases AS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as percentage_of_death
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
AND new_cases != 0
GROUP BY date

-- selecting from GlobalCovidCases view
SELECT *
FROM GlobalCovidCases


-- looking at total population vs vaccinations
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations 
FROM PortfolioProject..covidDeaths death
JOIN PortfolioProject..covidVaccinations vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
AND vaccine.new_vaccinations IS NOT NULL
ORDER BY 1,2,3

-- showing total population vs vaccinations by date and location with CTE (common table expression)
With PopVsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_vaccinated_people)
as
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(numeric, vaccine.new_vaccinations)) OVER(PARTITION BY death.location 
ORDER BY death.location, death.date) as rolling_vaccinated_people
FROM PortfolioProject..covidDeaths death
JOIN PortfolioProject..covidVaccinations vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
)
SELECT *, (Rolling_vaccinated_people/Population)*100 as Percentage_of_vaccination
FROM PopVsVac

-- showing the continents with total vaccination count
SELECT continent, MAX(CAST(total_vaccinations as numeric)) as highest_vaccinations
FROM PortfolioProject..covidVaccinations
WHERE continent IS NOT NULL
GROUP BY continent

-- showing the countries with highest death count by continent
SELECT location, population, MAX(CAST(total_vaccinations as numeric)) as highest_vaccinations
FROM PortfolioProject..covidVaccinations
WHERE continent IS NOT NULL
AND continent LIKE 'Asia'
GROUP BY location, population
ORDER BY highest_vaccinations DESC

--TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinated_people numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(numeric, vaccine.new_vaccinations)) OVER(PARTITION BY death.location 
ORDER BY death.location, death.date) as rolling_vaccinated_people
FROM PortfolioProject..covidDeaths death
JOIN PortfolioProject..covidVaccinations vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent IS NOT NULL

SELECT *, (Rolling_vaccinated_people/Population)*100 as Percentage_of_vaccination
FROM #PercentPopulationVaccinated

-- creating view
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(numeric, vaccine.new_vaccinations)) OVER(PARTITION BY death.location 
ORDER BY death.location, death.date) as rolling_vaccinated_people
FROM PortfolioProject..covidDeaths death
JOIN PortfolioProject..covidVaccinations vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent IS NOT NULL

-- selecting from view
SELECT *
FROM PercentPopulationVaccinated
