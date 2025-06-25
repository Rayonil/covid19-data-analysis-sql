
/*
COVID-19 Data Exploration

This project performs exploratory analysis of "CovidDeaths" and "CovidVaccinations" data, which were extracted and stored in the "centered-carver-463915-a1" project, within the "COVID_19" dataset.

  Important: To use this script in your environment, replace the project and dataset name with the corresponding name(s) of your SQL project.

Objectives and Skills Used
  Integrated analysis of COVID-19 case, death, and vaccination data.
  Advanced data manipulation using:
  Joining to combine information from different tables.
  Common Table Expressions (CTEs) for modularization and code readability.
  Window Functions for cumulative calculations and temporal analysis.
  Aggregation functions for data summarization.
  Creation of views to facilitate future queries and visualizations.
  Conversion of data types to ensure the integrity and accuracy of the analyses.

*/

-- [STEP 1] Base query: full selection of the 'CovidDeaths' table containing global COVID-19 mortality data.
-- The data is sorted by the first two columns, usually 'place' and 'date',
-- to facilitate temporal visualization by country or region.
-- This query serves as the basis for further analysis on COVID-19 deaths.

SELECT *
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
ORDER BY 1, 2;


-- [STEP 2] Selects key columns from the 'CovidDeaths' table in SQL for analysis of COVID-19 cases and deaths.
-- Filtering by 'continent IS NOT NULL' ensures that only country/region data is considered,
-- excluding aggregated totals by continents and other generic categories.

Select 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
From `centered-carver-463915-a1.COVID_19.CovidDeaths`
Where continent is not null 
order by 1,2


-- [STEP 3] Total Cases vs Total Deaths from COVID-19 in Brazil
-- Objective: To estimate the lethality of COVID-19 (Death_Percentage), that is, the percentage of people who died after contracting the virus in the country.
-- The metric is calculated as (total_deaths / total_cases) * 100 and rounded to one decimal place.

SELECT 
  location, 
  date, 
  total_cases, 
  ROUND((total_deaths/total_cases) * 100, 1) AS Death_Percentage
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
WHERE location LIKE '%Brazil%'
AND continent IS NOT null
ORDER BY 1, 2


-- [STEP 4] Total Cases vs Population
-- Objective: To estimate the percentage of the population infected by COVID-19 over time in Brazil.
-- The 'Got_Covid_Percentage' metric is calculated as (total_cases / population) * 100,
-- indicating the proportion of people who tested positive in relation to the total population.

SELECT 
  location, 
  date,  
  population,
  total_cases,
  ROUND((total_cases/population) * 100, 1) AS Got_Covid_Percentage 
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
WHERE location LIKE '%Brazil%'
AND continent IS NOT null
ORDER BY 1, 2


-- [STEP 5] Countries with Highest Infection Rate Relative to Population
-- Objective: To identify countries with the highest proportion of COVID-19 infections relative to population size.
-- The 'Percentage_High_Infection' metric represents the peak recorded infection rate, calculated as:
-- (maximum total cases / population) * 100.
-- Using MAX(total_cases) ensures that the highest cumulative case count is considered per country.

SELECT 
  location, 
  population,
  MAX(total_cases) AS Hight_Infection,
  MAX((total_cases/population)) * 100 AS Percentage_Hight_Infection
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY Percentage_Hight_Infection DESC


-- [STEP 6] Countries with Highest COVID-19 Deaths
-- Objective: List the countries with the highest cumulative total of recorded deaths.
-- The 'Highest_Deaths' metric represents the highest total deaths per country.

SELECT 
  location, 
  MAX(total_deaths) AS Hight_Deaths
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
WHERE continent IS NOT null
GROUP BY location
ORDER BY Hight_Deaths DESC


-- [STEP 7] Analysis by Continent: Total Deaths by Population
-- Objective: Identify the continents with the highest cumulative number of deaths from COVID-19.
-- The MAX function is used to extract the peak of total deaths recorded by continent.
-- The WHERE clause ensures that only records with a defined continent are included in the analysis.

SELECT 
  continent, 
  MAX(total_deaths) AS Total_Death_Count
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;


-- [STEP 8] Global Numbers: Cases, Deaths and Case Fatality
-- Objective: To obtain a global overview of the pandemic, adding all new cases and deaths reported.
-- The 'Deaths_Percentage' metric represents the global case fatality rate,
-- calculated as (sum of deaths / sum of cases) * 100.
-- Records aggregated by continent are excluded to keep only data from real countries/regions.

SELECT 
  SUM(new_cases) AS Total_Cases,
  SUM(new_deaths) AS Total_Deaths,
  SUM(new_deaths)/SUM(new_cases) * 100 AS Deaths_Percentage
FROM `centered-carver-463915-a1.COVID_19.CovidDeaths`
WHERE continent IS NOT null
ORDER BY 1,2



-- [STEP 9] Total Population vs Vaccination: Integrated Analysis with Table Joins
-- Objective: To evaluate the proportion of the population that has received at least one dose of the COVID-19 vaccine.
-- This query performs a JOIN between two tables: 'CovidDeaths' and 'CovidVaccinations',
-- based on location and date, allowing to correlate vaccination with demographic data.
-- The 'Rolling_People_Vaccinated' metric uses an aggregation window (WINDOW FUNCTION)
-- to calculate the cumulative total of vaccinated people per country over time.
-- Only data from real countries/regions is considered ('continent IS NOT NULL').

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM 
  `centered-carver-463915-a1.COVID_19.CovidDeaths` AS dea
JOIN
  `centered-carver-463915-a1.COVID_19.CovidVaccinations` AS vac
  ON
    dea.location = vac.location
  AND
    dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3


-- [STEP 10] Calculating the Percentage of the Vaccinated Population Using CTE (Common Table Expression)
-- Objective: Calculate the percentage of the population that has received at least one dose of the COVID-19 vaccine.
-- This step reuses the logic of the previous step, but encapsulates the subquery in a CTE called 'PopVsVac',
-- making the code easier to read, modularize, and maintain.
-- The CTE joins the death and vaccination tables, and applies a window function
-- to obtain the accumulated vaccination over time by country.
-- The final query calculates the percentage of vaccinated people in relation to the total population.

WITH PopVsVac AS
(
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
  FROM 
    `centered-carver-463915-a1.COVID_19.CovidDeaths` AS dea
  JOIN
    `centered-carver-463915-a1.COVID_19.CovidVaccinations` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)

SELECT *, (Rolling_People_Vaccinated/population) * 100 AS Percent_People_Vaccinated
FROM PopVsVac


-- [STEP 11] Creating a VIEW for Visualizations: Percentage of Vaccinated Population
-- Objective: Create a persistent VIEW that stores processed data on vaccination by country over time.
-- The 'PercentPopulationVaccinated' VIEW encapsulates the join logic between the death and vaccination tables,
-- including the accumulated aggregation of vaccinated people by country (window function).
-- This structure facilitates the use of data in dashboards and visualization tools (e.g.: Data Studio, Power BI),
-- allowing quick queries without the need to reprocess the raw data.
-- NOTE: The VIEW will be saved in the 'COVID_19' dataset of the current project and can be reused in future analyses.

CREATE VIEW `centered-carver-463915-a1.COVID_19.PercentPopulationVaccinated` AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM 
  `centered-carver-463915-a1.COVID_19.CovidDeaths` AS dea
JOIN
  `centered-carver-463915-a1.COVID_19.CovidVaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


