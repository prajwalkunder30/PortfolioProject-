select location,date,total_cases,new_cases,total_deaths,population
from [Project Portfolio]..CovidDeaths$ 
order by 1,2
---Total Cases vs Total Deaths
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Project Portfolio]..CovidDeaths$ 
where location like '%India%'
order by 1,2

---Total Cases vs Population 
select location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from [Project Portfolio]..CovidDeaths$ 
where location like '%India%'
order by 1,2
---Looking at countries with Highest Infection Rate compared to Population
select location,population,max(total_cases) as Highest_Infecrate,max((total_cases/population))*100 as Perecntpopinfected
from [Project Portfolio]..CovidDeaths$ 
group by location,population
order by Perecntpopinfected desc

---Showing Countries with Highest Death Count per Population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from [Project Portfolio]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

----Lets breakdown by continent
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from [Project Portfolio]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc
 
 --Global Numbers 

 select sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [Project Portfolio]..CovidDeaths$
where continent is not null
order by 1,2

---Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths$ dea join CovidVaccinations$ vac 
on (dea.location = vac.location) and (dea.date =vac.date)
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Project Portfolio]..CovidDeaths$ dea
Join [Project Portfolio]..CovidVaccinations$  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac 

-- Using Temp Table to perform Calculation on Partition By in previous query

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
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths$ dea join CovidVaccinations$ vac 
on (dea.location = vac.location) and (dea.date =vac.date)
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths$ dea join CovidVaccinations$ vac 
on (dea.location = vac.location) and (dea.date =vac.date)
where dea.continent is not null
 
