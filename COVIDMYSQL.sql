# Crecimiento porcentual mensual de casos positivos de coronavirus en CABA

SELECT 
  Fecha, 
  Casos_Positivos,
  ROUND((Casos_Positivos - Casos_PositivosRT) / Casos_PositivosRT, 2) AS Crecimiento
FROM (SELECT 
        Fecha, 
        Casos_Positivos,
        COALESCE (LAG(Casos_Positivos) OVER (ORDER BY Fecha ASC), 1) AS Casos_PositivosRT
      FROM (SELECT  
              DATE_FORMAT(Primer_Caso,'%Y-%m') AS Fecha,
              COUNT(DISTINCT numero_de_caso) AS Casos_Positivos
            FROM (SELECT 
                    numero_de_caso, 
                    MIN(fecha_apertura_snvs) AS Primer_Caso
                  FROM casos_covid19Final
                  WHERE clasificacion = 'confirmado'
                  GROUP BY numero_de_caso) AS Cas1
           GROUP BY Fecha
           ORDER BY Fecha) AS dgs
     ORDER BY Fecha ASC) AS dgba
;

# Crecimiento porcentual mensual de fallecidos confirmados de coronavirus en CABA

SELECT 
  Fecha, 
  Cantidad_Fallecidos,
  ROUND((Cantidad_Fallecidos - Cantidad_FallecidosRT) / Cantidad_FallecidosRT, 2) AS Crecimiento
FROM (SELECT 
        Fecha, 
        Cantidad_Fallecidos,
        COALESCE (LAG(Cantidad_Fallecidos) OVER (ORDER BY Fecha ASC), 1) AS Cantidad_FallecidosRT
      FROM (SELECT  
              DATE_FORMAT(Primer_Fallecido,'%Y-%m') AS Fecha,
              COUNT(DISTINCT numero_de_caso) AS Cantidad_Fallecidos
            FROM (SELECT 
                    numero_de_caso, 
                    MIN(fecha_apertura_snvs) AS Primer_Fallecido
                  FROM casos_covid19Final
                  WHERE clasificacion = 'confirmado'
                  AND fallecido = 'si'
                  GROUP BY numero_de_caso) AS Cas1
           GROUP BY Fecha
           ORDER BY Fecha) AS dgs
     ORDER BY Fecha ASC) AS dgba
;

# Edad promedio de casos positivos

SELECT ROUND(AVG(edad)) AS Edad_promedio
FROM casos_covid19Final
WHERE clasificacion = 'confirmado'
;

# Análisis estadístico, desviación estándar: Dispersión desde el promedio de las edades promedio de los casos positivos
# Dispersión graficada en Tableau


Select ROUND(STDDEV_POP(edad),2) as Disperción_en_Años
from casos_covid19Final
WHERE clasificacion = 'confirmado'
;

# Edad promedio de casos positivos fallecidos

SELECT ROUND(AVG(edad)) AS Edad_promedio
FROM casos_covid19Final
WHERE clasificacion = 'confirmado'
AND fallecido = 'si'
;

# Análisis estadístico, desviación estándar: Dispersión desde el promedio de las edades de los fallecidos
# Dispersión graficada en Tableau


Select ROUND(STDDEV_POP(edad),2) as Disperción_en_Años
from casos_covid19Final
WHERE clasificacion = 'confirmado'
AND fallecido = 'si'
;

SELECT barrio, COUNT(numero_de_caso) as cantidad_femenino
FROM casos_covid19Final
WHERE genero = 'femenino'
AND clasificacion = 'confirmado'
GROUP BY barrio

;

SELECT barrio, COUNT(numero_de_caso) as cantidad_masculino
FROM casos_covid19Final
WHERE genero = 'masculino'
AND clasificacion = 'confirmado'
GROUP BY barrio

;

# Crear tabla temporal para analizar las incidencias cada 100k habitantes y Segmentar por edades

DROP TABLE IF EXISTS Covid_k;
CREATE TEMPORARY TABLE Covid_k
SELECT *, (Cantidad/Poblacion)*100000 AS Cantidad_cada_100k
FROM ( SELECT *, 1 as Cantidad
       FROM (SELECT *,
  CASE
    WHEN edad <= '16'
    THEN 'Infantes y adolescentes'
    WHEN edad >= '17' and edad <= '25'
    THEN 'Jovenes adultos'
    WHEN edad >= '26' and edad <= '65'
    THEN 'Adultos'
    ELSE 'Mayores'
    END AS Tipo    
FROM casos_covid19Final) AS fas) AS jgs
;

# Barrio con más casos positivos cada 100k habitantes

select barrio, max(poblacion), sum(cantidad), sum(Cantidad_cada_100k)
from covid_k
where clasificacion = 'confirmado'
group by barrio
order by sum(Cantidad_cada_100k) DESC
;

select *
from Covid_K
;