Select * 
From Portfolioproject..CovidDeaths
Where continent is not null
order by 3,4
--Select *
--From Portfolioproject..CovidVaccinations
--order by 3,4

---Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths
Where continent is not null
order by 1,2

---Looking at total cases vs total deaths
---shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

---Looking at total cases vs population
--- shows what  percentage of population got covid 
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentagePopulationInfected
From Portfolioproject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population.
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentagePopulationInfected
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


---Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-----Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac 
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

---USE  CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac 
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

------TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac 
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated

----Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac 
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated


