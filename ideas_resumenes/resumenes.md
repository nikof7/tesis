Para analizar cómo los **patrones de actividad de los mamíferos** cambian frente a diferentes **estresores** usando datos de **cámaras trampa**, un **GLMM** con **`glmmTMB`** puede ser una excelente elección. Los estresores, como la tasa de registros de ganado vacuno, y las covariables, como las precipitaciones, pueden influir en la actividad de los mamíferos, lo que sugiere que deberías considerar varias **distribuciones** y **estructuras de efectos aleatorios** al construir tu modelo.

Aquí te dejo algunos puntos clave que debes considerar para diseñar tu análisis:

### 1. **Definir la variable de respuesta**
   Lo primero es determinar qué tipo de variable de respuesta tienes para los patrones de actividad de los mamíferos, ya que esto guiará la selección de la distribución correcta:
   - **Conteos**: Si tu variable de respuesta es el número de registros de mamíferos en las cámaras, podrías considerar una distribución de conteo, como **Poisson** o **binomial negativa** (si hay sobredispersión).
   - **Proporciones**: Si estás modelando la proporción de tiempo que los mamíferos están activos en relación al total del tiempo observado, podrías usar una distribución **binomial** o **beta**.

   Ejemplo de variables de respuesta:
   - **Conteo de registros** de un mamífero por cámara en un período de tiempo.
   - **Proporción de horas activas** en comparación con el total de horas en las que hubo registros.

### 2. **Modelar los estresores (variables independientes)**
   Tu principal interés es el efecto del **ganado vacuno** como estresor, por lo que es importante incluir esta variable como un **efecto fijo** en tu modelo. Además, las **precipitaciones** pueden ser una **covariable** importante.

   Ejemplo de variables predictoras:
   - **Tasa de registros de ganado vacuno**: Número de registros de vacas por día o por unidad de tiempo.
   - **Precipitaciones**: Medida continua de las precipitaciones.

   Estas variables pueden modelarse de manera lineal o incluso con términos no lineales si crees que su efecto sobre la actividad de los mamíferos no es constante.

### 3. **Efectos aleatorios**
   Los **efectos aleatorios** son esenciales si tus cámaras trampa están instaladas en diferentes ubicaciones o en diferentes períodos de tiempo, ya que estos factores pueden influir en los patrones de actividad de los mamíferos.

   Ejemplos de efectos aleatorios podrían incluir:
   - **Ubicación de la cámara**: Las cámaras podrían estar en diferentes sitios, lo que genera variabilidad entre lugares.
   - **Tiempo**: La variabilidad temporal (días, meses) también puede ser importante. Podrías ajustar por día, mes o estación como efectos aleatorios.

   La estructura de los efectos aleatorios sería algo como:
   ```r
   (1 | ubicación) + (1 | tiempo)
   ```

### 4. **Especificación del modelo en `glmmTMB`**
   Ahora que has definido tu variable de respuesta, los estresores, las covariables y los efectos aleatorios, podrías plantear un modelo como este:
   
   #### Ejemplo para una respuesta de **conteo** (registros de mamíferos por cámara):
   Si los datos de actividad son conteos de registros de mamíferos por cámara en un período de tiempo, puedes usar una distribución **Poisson** o **binomial negativa** (en caso de sobredispersión):
   ```r
   library(glmmTMB)

   modelo <- glmmTMB(conteo_mamiferos ~ tasa_ganado + precipitaciones + (1 | ubicación) + (1 | tiempo),
                     family = nbinom2, # o family = poisson si no hay sobredispersión
                     data = datos)
   summary(modelo)
   ```

   #### Ejemplo para una respuesta de **proporciones** (tiempo activo / total tiempo):
   Si tu variable de respuesta es una proporción de tiempo activo de los mamíferos:
   ```r
   modelo <- glmmTMB(proporcion_actividad ~ tasa_ganado + precipitaciones + (1 | ubicación) + (1 | tiempo),
                     family = beta_family(), # Modelo beta para proporciones continuas
                     data = datos)
   summary(modelo)
   ```

### 5. **Diagnóstico del modelo**
   Después de ajustar el modelo, es importante verificar su ajuste mediante herramientas de diagnóstico. En el caso de modelos GLMM, puedes usar el paquete **DHARMa** para revisar los residuos y la calidad del ajuste:
   ```r
   library(DHARMa)

   simulacion_residuos <- simulateResiduals(fittedModel = modelo)
   plot(simulacion_residuos)
   ```

   Esto te permitirá ver si hay patrones en los residuos que sugieran una falta de ajuste en el modelo o algún tipo de dependencia en los datos no capturada por los efectos aleatorios.

### 6. **Comparación de modelos**
   Si quieres probar diferentes combinaciones de estresores o covariables, puedes usar **criterios de selección de modelos** como el **AIC** para comparar la bondad del ajuste entre modelos:
   ```r
   modelo1 <- glmmTMB(conteo_mamiferos ~ tasa_ganado + precipitaciones + (1 | ubicación) + (1 | tiempo), family = nbinom2, data = datos)
   modelo2 <- glmmTMB(conteo_mamiferos ~ tasa_ganado + (1 | ubicación) + (1 | tiempo), family = nbinom2, data = datos)

   AIC(modelo1, modelo2)
   ```

### 7. **Interacciones y no linealidad**
   Si crees que la relación entre los **estresores** (por ejemplo, la tasa de ganado) y la actividad de los mamíferos no es lineal, puedes probar **términos no lineales** como splines o incluir **interacciones** entre las covariables (por ejemplo, la interacción entre las precipitaciones y la tasa de ganado):
   ```r
   modelo_interaccion <- glmmTMB(conteo_mamiferos ~ tasa_ganado * precipitaciones + (1 | ubicación) + (1 | tiempo), 
                                 family = nbinom2, data = datos)
   summary(modelo_interaccion)
   ```

### 8. **Efectos cero-inflados**
   Si observas que hay un número desproporcionado de ceros en tus datos (es decir, cámaras que no registran mamíferos durante ciertos períodos), podrías considerar un **modelo cero-inflado**. Esto puede ser útil si hay muchos sitios donde no se registraron mamíferos debido a ciertos factores (como la presencia del ganado).

   Ejemplo de un modelo cero-inflado:
   ```r
   modelo_zero_infl <- glmmTMB(conteo_mamiferos ~ tasa_ganado + precipitaciones + (1 | ubicación) + (1 | tiempo), 
                               ziformula = ~1, family = nbinom2, data = datos)
   ```

### 9. **Interpretación de resultados**
   - Los **coeficientes estimados** de los estresores, como la tasa de registros de ganado, indicarán cómo cada unidad adicional de esa variable afecta la actividad de los mamíferos.
   - Si has utilizado una **distribución logarítmica**, debes tener en cuenta que los coeficientes se interpretan en términos de la transformación del logaritmo.
   - Las **interacciones** entre covariables (si se incluyeron) también deben interpretarse cuidadosamente, ya que indican cómo un estresor modula el efecto de otro.

### Resumen de lo que debes considerar:
1. **Variable de respuesta**: Define si es conteo (Poisson/binomial negativa) o proporción (Beta).
2. **Efectos fijos**: Incluir los estresores (e.g., tasa de ganado) y covariables (e.g., precipitaciones).
3. **Efectos aleatorios**: Considerar la ubicación de las cámaras y el tiempo como efectos aleatorios.
4. **Diagnóstico del modelo**: Usa herramientas como **DHARMa** para evaluar el ajuste del modelo.
5. **Comparación de modelos**: Usa **AIC** u otros criterios para seleccionar el mejor modelo.
6. **Interacciones y no linealidad**: Considera incluir interacciones o términos no lineales si son relevantes.

Trabajando con estos puntos en mente, podrás evaluar si los patrones de actividad de los mamíferos cambian frente a los estresores (como la tasa de ganado) de manera robusta y bien fundamentada.

Claro, te explicaré el modelo y te daré un ejemplo con datos ficticios.

### Explicación del Modelo GLMM

Un **Modelo Lineal Generalizado Mixto (GLMM)** es una extensión de los modelos lineales que permite incluir tanto efectos fijos como aleatorios. En tu caso:

- **Efectos fijos**: Son los efectos de variables que estás interesado en estudiar, como la especie, la densidad de casas y las precipitaciones.
- **Efectos aleatorios**: Se utilizan para manejar la variabilidad no observada entre grupos, como diferentes sitios donde se registraron los datos.

### Ejemplo de Datos

Supongamos que tienes el siguiente dataframe con datos ficticios:

```r
# Crear un dataframe de ejemplo
data <- data.frame(
  especie = factor(c("ciervo_axis", "ciervo_axis", "ciervo_guazubira", "ciervo_guazubira")),
  actividad = factor(c("diurno", "nocturno", "diurno", "crepuscular")),
  densidad_casas = c(10, 15, 20, 5),  # Densidad de casas
  precipitaciones = c(100, 200, 150, 50),  # Precipitaciones
  sitio = factor(c("sitio1", "sitio1", "sitio2", "sitio2"))  # Efecto aleatorio
)
```

### Ajuste del Modelo

Puedes ajustar el modelo de la siguiente manera:

```r
library(glmmtmb)

modelo <- glmmtmb(actividad ~ especie + densidad_casas + precipitaciones + 
                  (1 | sitio),  # Efecto aleatorio por sitio
                  family = "binomial",  # Ajusta según la naturaleza de tu variable
                  data = data)

# Resumen del modelo
summary(modelo)
```

### Salida del Modelo

El resumen del modelo te proporcionará información sobre los coeficientes estimados, errores estándar y valores de p, algo así como:

```
Call:
glmmtmb(formula = actividad ~ especie + densidad_casas + precipitaciones + 
    (1 | sitio), data = data, family = "binomial")

Coefficients:
                  Estimate Std. Error z value Pr(>|z|)    
(Intercept)        0.1234     0.5678   0.217   0.8283    
especieciervo_guazubira 0.5678     0.2345   2.427   0.0153 *  
densidad_casas    0.0456     0.0123   3.707   0.0002 ***
precipitaciones    0.0123     0.0045   2.733   0.0063 **
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Random effects:
 Groups Name        Variance Std.Dev.
 sitio  (Intercept) 0.0123   0.1111  
```

### Interpretación

- **(Intercept)**: El valor base del log-odds de la actividad diurna para el ciervo axis con una densidad de casas y precipitaciones de cero.
- **especieciervo_guazubira**: Muestra cómo cambia la probabilidad de actividad en comparación con el ciervo axis.
- **densidad_casas**: Un aumento en la densidad de casas se asocia con un incremento en el log-odds de la actividad.
- **precipitaciones**: Similarmente, un aumento en las precipitaciones también afecta la actividad.

### Ejemplo de Tablas

Para visualizar los efectos de los factores puedes usar `emmeans`:

```r
library(emmeans)
resultados <- emmeans(modelo, ~ especie | actividad)
summary(resultados)
```

Esto te dará una tabla que muestra las estimaciones de los efectos para cada combinación de especie y actividad.
