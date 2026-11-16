-- Requêtes d'analyse des tickets (MySQL 8)
-- Pré-requis : avoir exécuté schema.sql puis data.sql
USE tickets_it;

-- 1. Nombre de tickets par statut
SELECT statut, COUNT(*) AS nb_tickets
FROM tickets
GROUP BY statut
ORDER BY nb_tickets DESC;

-- 2. Nombre de tickets par catégorie
SELECT c.libelle AS categorie, COUNT(*) AS nb_tickets
FROM tickets t
JOIN categories c ON c.id_categorie = t.id_categorie
GROUP BY c.libelle
ORDER BY nb_tickets DESC;

-- 3. Temps moyen de résolution (en heures) par priorité
SELECT priorite,
       COUNT(*) AS nb_tickets_resolus,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, date_creation, date_resolution)) / 60, 1) AS heures_moyennes
FROM tickets
WHERE date_resolution IS NOT NULL
GROUP BY priorite
ORDER BY FIELD(priorite, 'Critique', 'Haute', 'Moyenne', 'Basse');

-- 4. Charge de travail par technicien
SELECT te.nom, te.niveau,
       COUNT(*) AS nb_tickets,
       SUM(t.date_resolution IS NOT NULL) AS nb_resolus
FROM tickets t
JOIN techniciens te ON te.id_technicien = t.id_technicien
GROUP BY te.id_technicien, te.nom, te.niveau
ORDER BY nb_tickets DESC;

-- 5. Tickets non résolus de priorité Haute ou Critique
SELECT t.id_ticket, t.titre, t.priorite, t.statut, u.nom AS demandeur, t.date_creation
FROM tickets t
JOIN utilisateurs u ON u.id_utilisateur = t.id_utilisateur
WHERE t.date_resolution IS NULL
  AND t.priorite IN ('Haute', 'Critique')
ORDER BY t.date_creation;

-- 6. Tickets résolus au-delà du délai cible (SLA)
--    SLA : Critique 4 h, Haute 8 h, Moyenne 24 h, Basse 72 h
SELECT t.id_ticket, t.titre, t.priorite,
       ROUND(TIMESTAMPDIFF(MINUTE, t.date_creation, t.date_resolution) / 60, 1) AS heures_reelles
FROM tickets t
WHERE t.date_resolution IS NOT NULL
  AND TIMESTAMPDIFF(MINUTE, t.date_creation, t.date_resolution) / 60 >
      CASE t.priorite
          WHEN 'Critique' THEN 4
          WHEN 'Haute'    THEN 8
          WHEN 'Moyenne'  THEN 24
          ELSE 72
      END
ORDER BY heures_reelles DESC;

-- 7. Départements qui génèrent le plus de tickets
SELECT u.departement, COUNT(*) AS nb_tickets
FROM tickets t
JOIN utilisateurs u ON u.id_utilisateur = t.id_utilisateur
GROUP BY u.departement
ORDER BY nb_tickets DESC;

-- 8. Évolution mensuelle du nombre de tickets
SELECT DATE_FORMAT(date_creation, '%Y-%m') AS mois, COUNT(*) AS nb_tickets
FROM tickets
GROUP BY mois
ORDER BY mois;

-- 9. Types d'équipements les plus concernés par des incidents
SELECT e.type, e.marque, COUNT(*) AS nb_incidents
FROM tickets t
JOIN equipements e ON e.id_equipement = t.id_equipement
GROUP BY e.type, e.marque
ORDER BY nb_incidents DESC;

-- 10. Classement des techniciens selon le nombre de tickets résolus
--     (fonction de fenêtrage RANK, disponible en MySQL 8)
SELECT te.nom,
       COUNT(*) AS nb_resolus,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rang
FROM tickets t
JOIN techniciens te ON te.id_technicien = t.id_technicien
WHERE t.date_resolution IS NOT NULL
GROUP BY te.id_technicien, te.nom;
