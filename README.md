## 🚀 E-commerce Data Warehouse – SQL Data Engineering Project

### 👋 À propos du projet
Ce projet simule la conception complète d’un Data Warehouse e-commerce en environnement réel.

Il démontre ma capacité à :

- construire un pipeline de données complet
- manipuler des volumes importants (>1M lignes)
- gérer la qualité des données
- produire des analyses métier avancées

### 🎯 Objectifs
- Construire un Data Warehouse scalable
- Implémenter un pipeline RAW → STAGING → DATA MART
- Assurer la qualité des données
- Réaliser des analyses métier et avancées
- Travailler dans un environnement reproductible (DuckDB)

### 🧠 Compétences démontrées
#### 🔹 Data Engineering
- Modélisation Data Warehouse (fact / dimension)
- Conception pipeline ETL
- Data Quality & validation
- Gestion des données à grande échelle
#### 🔹 SQL avancé
- Window functions
- Agrégations complexes
- Jointures avancées
- Optimisation de requêtes
#### 🔹 Data Processing
- Nettoyage de données
- Déduplication
- Gestion des anomalies
- Logging de qualité

## ⚙️ Outils & technologies utilisés
- DuckDB → moteur analytique (traitement local haute performance)
- MotherDuck → stockage cloud
- SQL → transformation, analyse et pipeline
- VS Code → environnement de développement
- Git / GitHub → versioning et partage

## 🏗️ Architecture
#### 🔄 Pipeline
![Data Lakehouse Architecture](<Capture d’écran 2026-05-04 043114.jpg>)

#### 🧩 Modèle de données
![E-Commerce Database ER Diagram](<Capture d’écran 2026-05-04 043657.jpg>)

## 📊 Cas métiers traités
#### 📈 Marketing
- Analyse du churn
- Funnel de conversion
#### 💸 Finance
- Analyse du chiffre d’affaires
- Détection anomalies paiement
#### 📦 Logistique
- Suivi des livraisons
- Détection retards / pertes
#### 🏪 Marketplace
- Performance vendeurs
- Détection vendeurs inactifs

## 🧪 Data Quality
- Détection des doublons
- Gestion des NULL
- Validation des clés étrangères
- Incohérences temporelles
- Logs d’anomalies

## ⚡ Optimisation
- Réduction des scans
- Structuration des requêtes (CTE)
- Optimisation logique SQL
- Réflexion sur indexation

## 🖥️ Exécution du projet
#### ▶️ Lancer le projet
```bash
duckdb ecommerce_dwh
```
#### ▶️ Exécution étape par étape
``` SQL
-- Création des tables
.read 01_Creation_des_tables.sql

-- Chargement des données
.read 02_Insertion_des_donnees.sql

-- Exploration
.read 03_Exploration_des_donnees.sql

-- Analyse & Data Quality
.read 04_Analyse_metier_data_quality.sql

-- Analyse avancée
.read 05_Analyse_avancee.sql

-- Pipeline ETL
.read 06_Data_Pipeline_ETL.sql

-- Logs qualité
.read 07_data_quality_logs_pipeline.sql
````

#### ▶️ Exécution automatique
```bash
duckdb ecommerce_dwh -c ".read Execution_des_tables.sql"
```

## 📂 Structure du projet
````
├── 01_Creation_des_tables.sql
├── 02_Insertion_des_donnees.sql
├── 03_Exploration_des_donnees.sql
├── 04_Analyse_metier_data_quality.sql
├── 05_Analyse_avancee.sql
├── 06_Data_Pipeline_ETL.sql
├── 07_data_quality_logs_pipeline.sql
└── Execution_des_tables.sql
````

## 📈 Résultats
- Dataset réaliste (>1M lignes)
- Data Warehouse complet
- Pipeline ETL fonctionnel
- Analyses métier exploitables
- Système de Data Quality

## 🚨 Challenges rencontrés
- Gestion des contraintes de clés étrangères
- Données incohérentes (NULL, duplications)
- Optimisation de requêtes volumineuses
- Structuration d’un pipeline SQL complet

## 💼 Impact Business
Ce projet permettrait à une entreprise de :

- 📈 améliorer la conversion client
- 💸 surveiller les revenus et anomalies
- 📦 optimiser la logistique
- 🏪 suivre la performance des vendeurs

## ⭐ Conclusion
Ce projet démontre une capacité à :

- construire un pipeline Data Engineering complet
- gérer la qualité des données
- produire des analyses avancées
- travailler sur un cas réel proche de la production