--duckdb ecommerce_dwh -c ".read Execution_des_tables.sql"

-- Etape 1 : Création des tables dans le data Warehouse
.read 01_Creation_des_tables.sql

-- Etape 2: - Chargement des données dans les tables
.read 02_Insertion_des_donnees.sql

-- Etape 3 : Exploration des données
.read 03_Exploration_des_donnees.sql

-- Etape 4 : Analyse métier et Data Quality
.read 04_Analyse_metier_data_quality.sql

-- Etape 5 : Analyse Avancée
.read 05_Analyse_avancee.sql

-- Etape 6 : Optimisation Pipeline - Data Enginneering
.read 06_Data_Pipeline_ETL.sql

-- Etape 7 : Data Quality Logs - Data Enginneering
.read 07_data_quality_logs_pipeline.sql
