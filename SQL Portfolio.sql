
--Looking at Total Cases vs Total Deaths
--Shows the odds of dying if you contract COVID-19
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..['COVID DEATHS$']
WHERE continent is not null
ORDER BY 1,2

--Looking at total cases vs population
SELECT location, date, population,total_cases, (total_cases/population)*100 as positivity_percentage
FROM PortfolioProject..['COVID DEATHS$']
WHERE continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as positivity_percentage
FROM PortfolioProject..['COVID DEATHS$']
WHERE continent is not null
GROUP BY population, location
ORDER BY positivity_percentage DESC

--Showing countries with highest death count per population

--Continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..['COVID DEATHS$']
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC


--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..['COVID DEATHS$']
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccination
SELECT death.continent,death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as vaccincation_rolling_count
FROM PortfolioProject..['COVID DEATHS$'] death
JOIN PortfolioProject..['COVID VACC$'] vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null
ORDER BY 2,3

--USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, vaccination_rolling_count)
as 
(
SELECT death.continent,death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as vaccination_rolling_count
FROM PortfolioProject..['COVID DEATHS$'] death
JOIN PortfolioProject..['COVID VACC$'] vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null
--ORDER BY 2,3
)

Select*, (vaccination_rolling_count/population)*100 as running_vaccine_percentage
FROM PopVsVac

--TEMP TABLE
DROP TABLE if exists #percent_population_vacc
Create Table #percent_population_vacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccination_rolling_count numeric
)

Insert into #percent_population_vacc
SELECT death.continent,death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as vaccination_rolling_count
FROM PortfolioProject..['COVID DEATHS$'] death
JOIN PortfolioProject..['COVID VACC$'] vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null
--ORDER BY 2,3

Select*, (vaccination_rolling_count/population)*100 as running_vaccine_percentage
FROM #percent_population_vacc

--Creating View for later visuals
Create View percent_population_vaccinated as
SELECT death.continent,death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as vaccination_rolling_count
FROM PortfolioProject..['COVID DEATHS$'] death
JOIN PortfolioProject..['COVID VACC$'] vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null
--ORDER BY 2,3


--Query off of view for testing
Select *
FROM
percent_population_vaccinated