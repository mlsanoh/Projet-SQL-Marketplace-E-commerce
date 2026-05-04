-- Etape 3 : Exploration des données

-- Quels sont les clients actifs par pays ?
SELECT 
    country,
    COUNT(*) AS active_customers
FROM customers
WHERE is_active = true
GROUP BY country
ORDER BY active_customers DESC;

-- Combien de commandes ont été passées par jour ?
SELECT 
    DATE(DATE_TRUNC ('day', order_date)) AS date_commande,
    COUNT(*) AS nombre_commande
FROM orders
GROUP BY DATE_TRUNC ('day', order_date)
ORDER BY date_commande;

-- Quel est le nombre de produits par catégorie
SELECT 
    category,
    COUNT (*) AS nombre_produit
FROM products
GROUP BY category
ORDER BY nombre_produit DESC;

--Quels sont les statuts les plus fréquents des commandes
SELECT 
    status,
    COUNT (*) AS nombre_commande
FROM shipments
GROUP BY status
ORDER BY nombre_commande DESC;

-- Quels clients n’ont jamais passé de commande ?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
AND c.is_active = true;