-- Etape 7 : Data Quality Logs - Data Enginneering

-- Vérification la data quality (règles de validation globales)

-- Unicité et Non-Nullité
SELECT 'Doublons Clients' as test, COUNT(*) as result 
FROM analytics.dim_customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1
UNION ALL
SELECT 'ID Produit Null' as test, COUNT(*) 
FROM analytics.dim_products 
WHERE product_id IS NULL;

-- Intégrité Référentielle
    -- Est-ce qu'on a des ventes dans fct_sales dont le produit n'existe pas dans dim_products ?
SELECT COUNT(f.product_id) as orphelins_produits
FROM analytics.fct_sales f
LEFT JOIN analytics.dim_products p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Cohérence Métier
SELECT 'Prix Négatif' as alerte, COUNT(*) 
FROM analytics.fct_sales 
WHERE unit_price < 0
UNION ALL
SELECT 'Livraison Incohérente' as alerte, COUNT(*) 
FROM analytics.fct_sales 
WHERE days_to_deliver < 0;


-- Création de la table de Logs Qualité

CREATE TABLE IF NOT EXISTS analytics.data_quality_logs (
    check_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    test_name VARCHAR,
    table_tested VARCHAR,
    result_count INTEGER,
    status VARCHAR
);

-- Script de validation automatique

-- Nettoyage des anciens logs pour le rapport du jour
DELETE FROM analytics.data_quality_logs;

-- Test 1 : Vérifier les prénoms/noms non transformés (Nulls)
INSERT INTO analytics.data_quality_logs (test_name, table_tested, result_count, status)
SELECT 
    'Missing Customer Names', 
    'dim_customers', 
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN 'CRITICAL' ELSE 'OK' END
FROM analytics.dim_customers 
WHERE first_name IS NULL OR last_name IS NULL;

-- Test 2 : Vérifier les montants incohérents
INSERT INTO analytics.data_quality_logs (test_name, table_tested, result_count, status)
SELECT 
    'Negative Sales Amount', 
    'fct_sales', 
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN 'CRITICAL' ELSE 'OK' END
FROM analytics.fct_sales 
WHERE line_amount < 0;

-- Test 3 : Vérifier les délais de livraison impossibles (livré avant d'être commandé)
INSERT INTO analytics.data_quality_logs (test_name, table_tested, result_count, status)
SELECT 
    'Impossible Delivery Dates', 
    'fct_sales', 
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN 'CRITICAL' ELSE 'OK' END
FROM analytics.fct_sales 
WHERE days_to_deliver < 0;

-- Test 4 : Vérifier l'intégrité des produits (Orphelins)
INSERT INTO analytics.data_quality_logs (test_name, table_tested, result_count, status)
SELECT 
    'Orphaned Product IDs', 
    'fct_sales', 
    COUNT(*),
    CASE WHEN COUNT(*) > 0 THEN 'CRITICAL' ELSE 'OK' END
FROM analytics.fct_sales f
LEFT JOIN analytics.dim_products p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Rapport
SELECT * 
FROM analytics.data_quality_logs 
ORDER BY status DESC;