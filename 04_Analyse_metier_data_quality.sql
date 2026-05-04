-- Etape 4 : Analyse métier et Data Quality

--Quel est le revenu total par pays ?
SELECT 
    shipping_country,
    SUM(total_amount) AS revenu_total
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered')
GROUP by shipping_country
ORDER BY revenu_total DESC;

-- Quel est le panier moyen par client ?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(AVG(total_amount),2) AS panier_moyen
FROM customers c 
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY ALL;

--Quels produits sont les plus vendus ?
SELECT
    p.product_id,
    p.name,
    p.category,
    SUM(ot.quantity) AS quantite_vendus
FROM order_items ot
INNER JOIN products p 
    on ot.product_id = p.product_id
GROUP BY ALL
ORDER BY quantite_vendus DESC;

-- Quel est le taux de conversion des événements web → achat
SELECT 
    
    ROUND (COUNT (DISTINCT CASE WHEN event_type = 'purchase' THEN customer_id END) * 100 /
    COUNT (DISTINCT customer_id),2) AS taux_conversion
FROM web_events;

--Identifier les commandes sans paiement associé
SELECT 
    o.order_id
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id 
    AND 
    p.payment_status = 'success'
WHERE p.order_id IS NULL;


--Trouver les incohérences entre order total et order_items
SELECT 
    o.order_id,
    oi.order_item_id,
    SUM(oi.quantity * oi.unit_price) AS montant_total,
    o.total_amount
FROM orders o
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY ALL
HAVING o.total_amount != SUM(oi.quantity * oi.unit_price);


--Identifier les clients inactifs avec historique d’achats
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    MAX(o.order_date) AS date_derniere_commande,
    DATEDIFF('day', MAX(o.order_date), CURRENT_DATE) AS jours_depuis_derniere_commande
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE c.is_active = false
GROUP BY ALL
HAVING MAX(o.order_date) < CURRENT_DATE - INTERVAL '3 months' 
   OR MAX(o.order_date) IS NULL;