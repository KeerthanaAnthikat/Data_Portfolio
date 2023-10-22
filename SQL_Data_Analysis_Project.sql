
SELECT *
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


SELECT location,date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES VS THE TOTAL DEATHS

-- Shows the likelihood of dying if you contract covid in India

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%India%'
--WHERE continent is not null
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what peecentage of population got Covid

SELECT location,date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking  at Countries with the Highest Infection rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc



-- Showing the countries with the Highest Death Count per population

SELECT location,  MAX(cast(total_deaths as int)) as HighestDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc


-- CONTINENT WISE DATA


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccination
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

)

Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




CREATE VIEW PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null



