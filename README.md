# 🌍 World-Wide Energy Consumption & Emission Analysis

## 📌 Project Overview
This project analyzes global energy consumption, production, emissions, GDP, and population data using SQL. It uncovers insights on energy usage, economic growth, and environmental impact using trend analysis, YoY comparison, per capita metrics, and ratio calculations.

## 🎯 Objectives
- Analyze relationship between energy consumption, production, and emissions  
- Identify top economies and their energy usage patterns  
- Evaluate energy surplus and deficit across countries  
- Perform year-over-year (YoY) analysis  
- Conduct per capita and ratio-based analysis  

## 🗂️ Dataset Description
- Country – Country details  
- Population_3 – Population data  
- GDP_3 – GDP data  
- Emission_3 – Emission data  
- Production_3 – Energy production  
- Consum_3 – Energy consumption  

## 🔗 Database Relationships
- One-to-Many relationship between Country and all other tables  

## 🛠️ Tools & Technologies
- SQL (MySQL/PostgreSQL)  
- Window Functions (LAG)  
- Aggregations & Joins  

## 📊 Key Analysis
### General Analysis
- Total emissions per country  
- Top countries by GDP  
- Energy production vs consumption  
- Major emission contributors  

### Trend Analysis
- Year-over-Year emission trends  
- GDP growth trends  
- Population vs emissions  
- Energy consumption trends  

### Ratio & Per Capita Analysis
- Emission-to-GDP ratio  
- Energy consumption per capita  
- Energy production per capita  

### Global Comparisons
- Top populated countries vs emissions  
- Emission reductions  
- Global emission share  
- Global averages  

## 💡 Key Insights
- Global emissions are increasing due to fossil fuels  
- Coal and petroleum are major contributors  
- GDP growth increases energy demand  
- Population growth raises emissions  
- Many countries depend on energy imports  

## 🚀 Recommendations
- Increase renewable energy adoption  
- Improve energy efficiency  
- Reduce fossil fuel dependency  
- Promote sustainable policies  

## 📈 Sample SQL Query
```sql
SELECT energy_type, year,
SUM(consumption) AS total_consumption,
SUM(consumption) - LAG(SUM(consumption)) 
OVER (PARTITION BY energy_type ORDER BY year) AS growth
FROM consum_3
GROUP BY energy_type, year;
