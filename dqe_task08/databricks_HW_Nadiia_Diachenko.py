# Databricks notebook source
# MAGIC %md
# MAGIC ## Databricks Homework
# MAGIC Since in July 2025 Databricks Community Edition was deprecated and instead of creating separate cluster they are being provided in serverless mode it will be easier for you to work with data - since all the data and tables will be saving not only when cluster as active.
# MAGIC
# MAGIC So, no separate activities for cluser creating should be executed - it will be autoattached/started when you will execute any of the cells below.
# MAGIC
# MAGIC
# MAGIC Please, create table in the default schema using file Sales_December_2019.csv. On the left found Catalog => Add Data => Drop files to upload, or click to browse => Sales_December_2019.csv After file will be uploaded, just need to confirm that table should be uploaded.
# MAGIC
# MAGIC  Make sure that the first row is header selected => Create Table. Table will be created with name that you specified (sales_december_2019 by default) You will be able to change the table name later if needed.

# COMMAND ----------

# MAGIC %md
# MAGIC PySpark can process SQL queries as a text. In other words you don't need to switch cell language to SQL.
# MAGIC 1. Write data from table that you created into the dataframe using PySpark with SQL query. Show data in the dataframe

# COMMAND ----------

# Create DataFrame from SQL query
df = spark.sql("SELECT * FROM sales_december_2019")
display(df)


# COMMAND ----------

# MAGIC %md
# MAGIC Any notebook can be parameterized using dbutils.widgets. Try to add one parameter "Product_name" and select data from dataframe filtered by value from this parameter. 
# MAGIC
# MAGIC 2. Select data where product = "product_name" from dataframe using PySpark

# COMMAND ----------

# Your code here
from pyspark.sql.functions import col

dbutils.widgets.text("Product_name", "USB-C Charging Cable")

product_name = dbutils.widgets.get("Product_name")

df_filtered = df.filter(col("Product") == product_name)
display(df_filtered)

# COMMAND ----------

# MAGIC %md
# MAGIC As well as in SQL, in PySpark you can use aggregate functions. Package pyspark.sql.functions contains all aggregated function from SQL. Try to perform simple aggregation with dataframe. Don't forget, that column types, which you want to calculate, shoud be numerical.  
# MAGIC 3. Calculate the sales for each product, including the number of products sold

# COMMAND ----------

# Your code here
from pyspark.sql.functions import col, sum as _sum

df_num = (
    df
    .filter(col("Order ID") != "Order ID")
    .withColumn("Quantity Ordered", col("Quantity Ordered").cast("int"))
    .withColumn("Price Each", col("Price Each").cast("double"))
    .withColumn("Sales", col("Quantity Ordered") * col("Price Each"))
)

df_sales_by_product = (
    df_num
    .groupBy("Product")
    .agg(
        _sum("Sales").alias("Total Sales"),
        _sum("Quantity Ordered").alias("Products Sold")
    )
    .orderBy(col("Total Sales").desc())
)

display(df_sales_by_product)


# COMMAND ----------

# MAGIC %md
# MAGIC In the PySpark you can perform dataframe profiling using one of two special commands or simple aggregated functions. Try to find special commands to complete this task or just use aggregated functions. Hint: please, сhange the column data types based on the data in them
# MAGIC
# MAGIC 4. Show data profiles output for the new dataframe of table sales_december_2019_csv: row count, min and max value for each column

# COMMAND ----------

# Your code here
from pyspark.sql.functions import col, to_timestamp

df_typed = (
    df
    .filter(col("Order ID") != "Order ID")
    .withColumn("Order ID", col("Order ID").cast("int"))
    .withColumn("Quantity Ordered", col("Quantity Ordered").cast("int"))
    .withColumn("Price Each", col("Price Each").cast("double"))
    .withColumn("Order Date", to_timestamp(col("Order Date"), "M/d/yy H:mm"))
)

print("Row count:", df_typed.count())

display(df_typed.summary("count", "min", "max"))

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC 5. Add new column to the dataframe from previous task with any default value that you want

# COMMAND ----------

#your code here
from pyspark.sql.functions import lit

df_with_col = df_typed.withColumn("Data_Source", lit("Sales_December_2019"))
display(df_with_col)

# COMMAND ----------

# MAGIC %md
# MAGIC Temporary views are processed by cluster and always dropped when the session ends (when the cluster turns off).
# MAGIC
# MAGIC 6. Create temporary view from task 4 dataframe using PySpark and perform any select using SQL

# COMMAND ----------

# Your code here for view creation
df_typed.createOrReplaceTempView("sales_temp_view")

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Your SQL code here
# MAGIC SELECT Product,
# MAGIC        SUM(`Quantity Ordered`) AS total_units,
# MAGIC        ROUND(SUM(`Price Each` * `Quantity Ordered`), 2) AS total_sales
# MAGIC FROM sales_temp_view
# MAGIC GROUP BY Product
# MAGIC ORDER BY total_sales DESC