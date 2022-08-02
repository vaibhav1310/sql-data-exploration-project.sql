 #  SQL Data Exploration

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths,population
from coviddeaths
where continent not in ("")
order by 1;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you are covid positive in your country 

select location ,date, total_cases, total_deaths, (total_deaths/total_cases)*100
as Deathpercentage from coviddeaths
where location = "india";

-- Looking at total cases vs population
-- Shows what percent of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as Covidpositive_percentage
from coviddeaths
where continent not in ("")
order by 1 ;

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases)
as Infected_people_number, max((total_cases/population))*100 as Infected_people_percentage
from coviddeaths
where continent not in ("")
group by location, population
order by Infected_people_percentage desc;

-- Showing Countries with Highest Death count per Population

select location,population, max(total_deaths) as Totaldeathcount
from coviddeaths
where continent not in ("")
group by location,population
order by Totaldeathcount desc

# LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with highest death count per Population
select continent, max(total_deaths) as Totaldeathcount
from coviddeaths
where continent not in ("")
group by continent
order by totaldeathcount desc;

-- GLOBAL MUMBERS

select sum(new_cases) as Total_cases ,
sum(new_deaths) as Total_deaths ,sum(new_deaths)/sum(new_cases)*100 as Deathpercent
from coviddeaths
where continent not in ("");

-- USE CTE
-- Population vs Vaccination

with popvsvac as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date)
as Rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent not in ("")
)
select *, (Rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from popvsvac;

-- Percent of Population Vaccinated Per Country

with vv as (
with popvsvac as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date)
as Rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent not in ("")
)
select *, (Rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from popvsvac
)
select location, max(PercentPopulationVaccinated) as Percent_Population_Vaccinated_per_country
from vv
where  PercentPopulationVaccinated is not null 
group by location
order by location;

-- Creating view to store data for later visualisation

-- Deathpercentage_india
create view Deathpercentage_india as
select location ,date, total_cases, total_deaths, (total_deaths/total_cases)*100
as Deathpercentage from coviddeaths
where location = "india"

-- Covidpositive_percentage
create view Covidpositive_percentage as 
select location, date, population, total_cases, (total_cases/population)*100 as Covidpositive_percentage
from coviddeaths
where continent not in ("")
order by 1 

-- Infected_people_percentage
create view Infected_people_percentage as
select location, population, max(total_cases)
as Infected_people_number, max((total_cases/population))*100 as Infected_people_percentage
from coviddeaths
where continent not in ("")
group by location, population
order by Infected_people_percentage desc

-- Deathcount per population
create view Deathcount_per_population as
select location,population, max(total_deaths) as Totaldeathcount
from coviddeaths
where continent not in ("")
group by location,population
order by Totaldeathcount desc

-- Global death rate
create view global_death_percent as
select sum(new_cases) as Total_cases ,
sum(new_deaths) as Total_deaths ,sum(new_deaths)/sum(new_cases)*100 as Deathpercent
from coviddeaths
where continent not in ("")

-- Percent of Population Vaccinated
create view PercentPopulationVaccinated as
with popvsvac as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date)
as Rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent not in ("")
)
select *, (Rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from popvsvac

-- Percent of Population Vaccinated per country
create view Percent_Population_Vaccinated_per_country as
with vv as (
with popvsvac as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date)
as Rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent not in ("")
)
select *, (Rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from popvsvac
)
select location, max(PercentPopulationVaccinated) as Percent_Population_Vaccinated_per_country
from vv
where  PercentPopulationVaccinated is not null 
group by location
order by location
