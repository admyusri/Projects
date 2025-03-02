Select *
From [PortfolioProject].[dbo].[CovidDeaths]
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases vs Total Deaths, reflects the probability of dying due to covid for each country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
From PortfolioProject..CovidDeaths
Order by 1,2

-- Total Cases vs Population, reflects the percentage  of cases in each population

Select Location, date, total_cases, population, (total_cases/population)*100 as CaseperPopulation
From PortfolioProject..CovidDeaths
Order by 1,2

-- Countries with Highest Infection Rate compared to population

Select Location, max(total_cases) as HighestCases, population, max((total_cases/population))*100 as CaseperPopulation
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by CaseperPopulation desc

-- Countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as HighestTotalDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by HighestTotalDeath desc

-- Continent with highest death count per population

Select continent, max(cast(total_deaths as int)) as HighestTotalDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by HighestTotalDeath desc

-- Global Cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Percentage_Death
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by Date 
Order by 1,2

-- Total Population that is vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CONVERT(int, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CONVERT(int, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CONVERT(int, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- View to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CONVERT(int, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated