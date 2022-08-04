SELECT *
FROM Data1

SELECT *
FROM Data2

-- Number of rows into our dataset // Numero de linhas no conjunto de dados

SELECT COUNT(*) 
FROM Data1;

SELECT COUNT(*)
FROM Population..Data2;

-- dataset for Jharkhand and Bihar // Conjunto de dados de Jharkhand e Bihar

SELECT *
FROM Population..Data1
WHERE State IN('Jharkhand', 'Bihar');

-- Population of India // Populacao da India

SELECT SUM(Population_2011) as 'Population'
FROM Population..Data2

-- Avg Growth // Crescimento medio

SELECT State, AVG(Growth)*100 as 'Avg-Growth' 
FROM Population..Data1 
GROUP BY State

-- Avg sex ratio // Media de razao sexual

SELECT State, ROUND(AVG(Sex_Ratio), 0) AS Avg_Sex_Ratio 
FROM Population..Data1
GROUP BY State
ORDER BY Avg_Sex_Ratio DESC;

-- Avg literacy rate // Taxa media de alfabetizacao

SELECT State, ROUND(AVG(Literacy), 2) AS Avg_literacy_rate
FROM Data1
GROUP BY State
HAVING ROUND(AVG(Literacy), 2) > 90
ORDER BY Avg_Literacy_rate DESC;

-- Top 3 state showing highest ratio // OS 3 estados com a maior proporcao

SELECT TOP 3 State, AVG(Growth)*100 'Avg_Growth'
FROM Data1 
GROUP BY State
ORDER BY Avg_Growth DESC; 

-- Bottom 3 state showing Lowest sex ratio // Os 3 estados com a menor proporcao sexual

SELECT TOP 3 State, ROUND(AVG(sex_ratio), 0) AS Avg_sex_ratio
FROM Data1 
GROUP BY State
ORDER BY Avg_sex_ratio ASC 

-- Top and bottom 3 states in literacy state // Melhores e piores 3 estados na estatistica de alfabetizacao

-- Top 
Drop table if exists #topstates
CREATE TABLE #topstates
(	
	state NVARCHAR(255),
	topstate float		
)

INSERT INTO #topstates 
SELECT state, ROUND(AVG(literacy),0) AS 'Avg_literacy_ratio'
FROM Data1
GROUP BY state
ORDER BY Avg_literacy_ratio DESC;

SELECT Top 3 * FROM #topstates 
ORDER BY #topstates.topstate DESC;

-- Bottom
Drop table if exists #bottomstates
CREATE TABLE #bottomstates
(	
	state NVARCHAR(255),
	bottomstate float		

)

INSERT INTO #bottomstates 
SELECT state, ROUND(AVG(literacy),0) AS 'Avg_literacy_ratio'
FROM Data1
GROUP BY state
ORDER BY Avg_literacy_ratio DESC;


SELECT Top 3 * FROM #bottomstates 
ORDER BY #bottomstates.bottomstate ASC;

-- Union operator

SELECT * FROM (
SELECT TOP 3 * FROM #topstates ORDER BY #topstates.topstate DESC) a
UNION
SELECT * FROM (
SELECT TOP 3 * FROM #bottomstates ORDER BY #bottomstates.bottomstate ASC) b

ORDER BY topstate DESC;

-- states starting with letter A or B OR C // Estados que comecam com a letra A ou B ou C

SELECT DISTINCT(State)
FROM Data1
WHERE State LIKE 'A%' OR state LIKE('B%') OR state LIKE('C%');

SELECT DISTINCT(State)
FROM Data1
WHERE State LIKE 'A%' AND state LIKE('%M') 

-- Joining both table // Conectando ambas Tabelas

SELECT Data1.District, Data1.state, Data1.Sex_Ratio, Data2.Population_2011	
FROM Data1 JOIN Data2
on Data1.District = Data2.District

-- Total Males and Females // Total de 'Masculino' e 'Feminino'

SELECT d.State, SUM(d.males) 'Total-Males', SUM(d.Females) 'Total-Females'
FROM
(SELECT c.district, c.state, ROUND(c.Population_2011/(c.Sex_Ratio + 1), 0) as Males, ROUND((c.Population_2011 * c.Sex_Ratio)/(c.Sex_Ratio + 1),0) as Females 
FROM 
(SELECT a.district, a.state, a.Sex_Ratio/1000 Sex_Ratio, b.Population_2011
FROM Population..Data1 as a JOIN Population..Data2 as b
ON a.District = b.District ) c) d
GROUP BY d.State
ORDER BY SUM(d.Females) DESC

-- Total literacy rate // taxa total de alfabetizacao 

SELECT c.state, sum(literate_people) Total_Literate_pop, sum(iliterate_people) Total_Iliterate_pop FROM
(SELECT d.district, d.state, ROUND(d.literacy_Ratio * d.Population_2011,0) literate_people, ROUND((1 - d.Literacy_Ratio) * d.Population_2011,0) iliterate_people FROM
(SELECT a.district, a.state, a.literacy/100 Literacy_Ratio, b.Population_2011 
FROM Data1 a INNER JOIN Data2 b ON a.district = b.district) d) c
GROUP BY c.state

-- Population in previous census

SELECT SUM(m.previous_census_population) Total_previous_census_population, SUM(m.current_census_population) Total_current_census_population FROM
(SELECT e.state, SUM(e.current_census_population) previous_census_population, SUM(e.previous_census_population) current_census_population FROM
(SELECT d.district, d.state, ROUND(d.population_2011/(1 + d.growth),0) previous_census_population, d.population_2011 current_census_population FROM
(SELECT a.district, a.state, a.growth growth, b.population_2011 
FROM Population..data1 a INNER JOIN Population..Data2 b
ON a.District = b.District) d) e
GROUP BY e.state) m



