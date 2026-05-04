-- Etape 5 : Analyse Avancée

-- Détecter les clients à risque de churn (aucune activité récente + historique)
WITH clt_act_rec AS (
   SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    MAX(o.order_date) AS date_derniere_commande,
    DATEDIFF('day', MAX(o.order_date), CURRENT_DATE) AS jours_depuis_derniere_commande,
    COUNT(o.order_id) AS volume_historique,
    CASE 
        WHEN MAX(o.order_date) IS NULL THEN 'Prospect inactif'
        WHEN DATEDIFF('day', MAX(o.order_date), CURRENT_DATE) > 180 THEN 'Churn confirmé'
        WHEN DATEDIFF('day', MAX(o.order_date), CURRENT_DATE) BETWEEN 90 AND 180 THEN 'Risque élevé'
        ELSE 'Actif'
    END AS segment_client
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE c.is_active = true
GROUP BY ALL
HAVING MAX(o.order_date) < CURRENT_DATE - INTERVAL '3 months' 
   OR MAX(o.order_date) IS NULL
)

SELECT *
FROM clt_act_rec
ORDER BY volume_historique DESC;


-- Identifier les comportements suspects (fraude potentielle paiement)
WITH payment_history AS (
SELECT
    o.customer_id,
    o.order_id,
    p.payment_method,
    p.payment_date,
    LAG(p.payment_date) OVER(PARTITION BY o.customer_id ORDER BY p.payment_date) AS date_precedente,
    DATEDIFF('second', LAG(p.payment_date) OVER(PARTITION BY o.customer_id ORDER BY p.payment_date), p.payment_date) AS secondes_depuis_dernier_paiments
FROM orders o  
LEFT JOIN payments p    
    ON o.order_id = p.order_id
)

SELECT * FROM payment_history
WHERE secondes_depuis_dernier_paiments < 60;

-- Construire une métrique de “delivery performance” par transporteur
SELECT
    carrier, 
    COUNT(shipment_id) AS total_expeditions,
    -- On calcule le taux de performance (SLA 5 jours)
    ROUND(AVG(CASE WHEN DATEDIFF('day', shipped_date, delivered_date) <= 5 THEN 1 ELSE 0 END)*100, 2) AS taux_respect_delais,
    ROUND(AVG(DATEDIFF('day', shipped_date, delivered_date)), 2) AS delai_moyen_par_jour
FROM shipments
WHERE status = 'delivered'
    AND shipped_date IS NOT NULL 
    AND delivered_date IS NOT NULL
GROUP BY carrier;

-- Trouver les sellers avec taux de retour anormalement élevé
WITH seller_performance AS(
SELECT 
    s.name,
    COUNT (oi.order_item_id) AS total_vente,
    COUNT(r.return_id) AS total_retour
FROM sellers s 
LEFT JOIN products p
    ON s.seller_id = p.seller_id
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN returns r
    ON oi.order_id = r.order_id
GROUP BY s.name
)
SELECT
    name,
    total_retour,
    ROUND(total_retour * 100/ NULLIF(total_vente, 0), 2)AS taux_retour
FROM seller_performance
WHERE total_vente > 0
ORDER BY taux_retour DESC;

-- Détecter les doublons clients (fuzzy matching logique)
SELECT 
    c1.customer_id AS id_1, 
    c2.customer_id AS id_2, 
    c1.first_name,
    c1.last_name,
    c1.email AS email_1, 
    c2.email AS email_2
FROM customers c1 
INNER JOIN customers c2
    ON c1.first_name = c2.first_name
    AND c1.last_name = c2.last_name
    AND c1.customer_id != c2.customer_id
WHERE c1.customer_id < c2.customer_id;

-- Construire une analyse cohortes clients (rétention mensuelle)
WITH customer_history AS (
    SELECT 
        customer_id,
        -- On définit le "mois de naissance" du client
            DATE(MIN(DATE_TRUNC('month', order_date)) OVER(PARTITION BY customer_id)) AS mois_cohorte,
        -- On définit le mois de la commande actuelle
        DATE_TRUNC('month', order_date) AS mois_achat
    FROM orders
),
cohort_logic AS (
    SELECT 
        mois_cohorte,
        DATEDIFF('month', mois_cohorte, mois_achat) AS index_mois,
        customer_id
    FROM customer_history
)
SELECT 
    mois_cohorte,
    index_mois,
    COUNT(DISTINCT customer_id) AS nb_clients
FROM cohort_logic
GROUP BY ALL
ORDER BY 1,2;

-- Identifier les goulots d’étranglement logistiques (delay shipment)
SELECT
    o.shipping_country,
    COUNT(o.order_id) AS nbre_commandes,
    ROUND(AVG(DATEDIFF('day', o.order_date, s.shipped_date)), 2) AS moyen_preparation,
    ROUND(AVG(DATEDIFF('day', shipped_date, delivered_date)), 2) AS moyen_transit
FROM orders o
INNER JOIN shipments s
    ON o.order_id = s.order_id
WHERE s.status = 'delivered'
GROUP BY o.shipping_country
ORDER BY moyen_preparation DESC;
