SELECT  f.festival_year,
        pm.description                      AS payment_method,
        COALESCE(SUM(t.ticket_cost), 0)     AS total_revenue
FROM        Festival          f                      
CROSS JOIN  Purchase_method   pm                     
LEFT JOIN   Event             e  ON e.festival_id_FK = f.festival_id
LEFT JOIN   Ticket            t  ON t.event_id_FK    = e.event_id
                                  AND t.purchase_method_id = pm.purchase_method_id
GROUP BY    f.festival_year, pm.description
ORDER BY    f.festival_year, pm.description;
