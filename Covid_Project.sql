Use Covid_Project

--Select data that we are going to be using.

Select Location, Date, total_cases,new_cases,total_deaths,population
from CovidDeaths$
order by 1,2

--looking at total cases vs total deaths in India(Coverting str to float).

Select Location, Date,total_cases,total_deaths,(cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths$
where location = 'India'
order by 1,2

--looking at total cases vs population in India.

Select Location, Date,population,total_cases,(total_cases/ population)*100 as percentpopulationInfected
from CovidDeaths$
where location = 'India'
order by 1,2

--looking at countries highest infection rate compared to population

Select Location,population,max(total_cases)as HighestInfectioncount,max((total_cases/ population))*100 as percentpopulationInfected
from CovidDeaths$
group by Location , population
order by percentpopulationInfected Desc

--showing countries with highest death count per polulation
Select location,max(total_deaths)as Totaldeathcount
from CovidDeaths$
group by location 
order by Totaldeathcount Desc


---let's break down by Continent

---Showing Continents with highest death count per population

Select continent,max(total_deaths)as Totaldeathcount
from CovidDeaths$
where continent is not null
group by continent 
order by Totaldeathcount Desc


--Showing continents with highest Cases

Select continent , max(total_cases) as HighestCasesCount
from CovidDeaths$
where continent is not null
group by continent
order by HighestCasesCount DESC

--looking at Avg of total cases vs total deaths by continent

Select continent,avg((cast(total_deaths as float) / cast(total_cases as float)))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by continent
order by DeathPercentage Desc

--looking at total cases vs population by Continent.

Select continent,max(population) as Population,max((total_cases/ population))*100 as percentpopulationInfected
from CovidDeaths$
where continent is not null
group by continent
order by percentpopulationInfected Desc

--looking at countries highest infection rate compared to population

Select continent,max(total_cases)as HighestInfectioncount,max((total_cases/ population))*100 as percentpopulationInfected
from CovidDeaths$
Where continent is not null
group by continent 
order by percentpopulationInfected Desc


--- Move to GlobalNumbers

Select Date, Sum(new_cases) as toal_cases, sum(new_deaths) as total_deaths
from CovidDeaths$
where continent is not null
group by date
order by 1,2 desc

--- Vaccination Data

--- Looking at total Population vs Vaccination

Select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations,
sum(Convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccination$ cv on 
cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

--- USe CTE

with PopvsVac (continent, location , Date , population , New_Vaccinations , RollingPeopleVaccinated)
as
(
Select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations,
sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccination$ cv on 
cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

) 
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated	
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations,
sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccination$ cv on 
cd.location = cv.location and cd.date = cv.date

Select *,(RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated

--- creating view to store data for visualisation

create view percentPopulationVaccinated as
Select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations,
sum(Convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccination$ cv on 
cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

Select *
from percentPopulationVaccinated