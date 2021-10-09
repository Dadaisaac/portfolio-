select *
from [Portfolio projectCovid]..CovidDeaths$
where continent is not null
order by 3,4
--select *
--from [Portfolio projectCovid]..CovidVaccinations$
--where continent is not null
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio projectCovid]..CovidDeaths$
order by 1,2
--looking at Total cases to Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio projectCovid]..CovidDeaths$
where location like '%nigeria%'
order by 1,2
-- looking at total case to population
-- Shows percentage of population got Covid
select location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from [Portfolio projectCovid]..CovidDeaths$
--where location like '%nigeria%'
order by 1,2

-- Countries with the highest infection rate to population
select location,population,max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopInfected
from [Portfolio projectCovid]..CovidDeaths$
--where location like '%nigeria%'
Group by location,population
order by PercentPopInfected desc

--Countries with Highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio projectCovid]..CovidDeaths$
--where location like %states%
where continent is not null
group by location
order by TotalDeathCount desc

--Breakdown by continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio projectCovid]..CovidDeaths$
--where location like %states%
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select Sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio projectCovid]..CovidDeaths$
--where location like '%nigeria%'
 where continent is not null
 --Group by date
order by 1,2

-- Total accination to Total Population

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
from [Portfolio projectCovid]..CovidDeaths$ dea
join [Portfolio projectCovid]..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3


  select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))
  over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinated
from [Portfolio projectCovid]..CovidDeaths$ dea
join [Portfolio projectCovid]..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

select*
from [Portfolio projectCovid]..CovidDeaths$ dea
join [Portfolio projectCovid]..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date

  -- Use CTE
  with PopvsVac ( continent,location,date,population,new_vaccination,TotalPeopleVaccinated)
  as
  (
  select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))
  over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinated
from [Portfolio projectCovid]..CovidDeaths$ dea
join [Portfolio projectCovid]..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  )
  select * ,(TotalPeopleVaccinated/population) *100 as TotalVaccPercentage
  from PopvsVac


  --using Temp table
  Drop table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  continent nvarchar (255),
  location nvarchar(255),
  date datetime,
  Population numeric,
  New_vaccination numeric,
  TotalPeopleVaccinated numeric
  )
 Insert into  #PercentPopulationVaccinated

  Select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))
  over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinated
from [Portfolio projectCovid]..CovidDeaths$ dea
join [Portfolio projectCovid]..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
   select * ,(TotalPeopleVaccinated/population) *100 as TotalVaccPercentage
  from #PercentPopulationVaccinated

  --Creating views for Data Visualizations
  create view PercentPopulationVaccinated as
  Select  dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))
  over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinated
from [Portfolio projectCovid]..CovidDeaths$ dea
join [Portfolio projectCovid]..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null