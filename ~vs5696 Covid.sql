/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..['covid-deaths$']
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid-deaths$']
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalofVaccinated
--, (RollingTotalofVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalofVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalofVaccinated
--, (RollingTotalofVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingTotalofVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalofVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalofVaccinated
--, (RollingTotalofVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingTotalofVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- Creating View for likelihood of dying if you contract covid in your country

create view LikelihoodDyingCovid as
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where location like '%states%'
and continent is not null 
--order by 1,2


-- Creating View that shows what percentage of population infected with Covid

create view PercentagePopulationInfected as
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'

-- Creating Views for Countries with Highest Death Count per Population

create view CountriesHighestDeathCountPopulation as
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
Where continent is not null 
Group by Location
--order by TotalDeathCount desc

-- Creating View for GLOBAL NUMBERS

create view GlobalNummbersCovid as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
where continent is not null 
--Group By date
--order by 1,2

-- Creating View that shows Percentage of Population that has recieved at least one Covid Vaccine

create view PercentagePopulationCovidVaccine as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalofVaccinated
--, (RollingTotalofVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

