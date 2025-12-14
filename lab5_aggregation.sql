USE bibliotheque;

-- Total abonnés
SELECT COUNT(*) AS total_abonnes
FROM abonne;

-- Moyenne de prêts par abonné (abonnés ayant au moins 1 emprunt)
SELECT AVG(nb) AS moyenne_emprunts
FROM (
  SELECT COUNT(*) AS nb
  FROM emprunt
  GROUP BY abonne_id
) AS sous;

-- Prix moyen des ouvrages (si colonne prix_unitaire existe)
-- (Décommente seulement si la colonne existe)
-- SELECT AVG(prix_unitaire) AS prix_moyen
-- FROM ouvrage;



-- Nombre d’emprunts par abonné
SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id;

-- Nombre d’ouvrages par auteur
SELECT auteur_id, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY auteur_id;



-- Abonnés avec au moins 3 emprunts
SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id
HAVING COUNT(*) >= 3;

-- Auteurs avec plus de 5 ouvrages
SELECT auteur_id, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY auteur_id
HAVING COUNT(*) > 5;



-- Pour chaque abonné : nom + nombre d’emprunts
SELECT a.id, a.nom, COUNT(e.ouvrage_id) AS emprunts
FROM abonne a
LEFT JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom;

-- Pour chaque auteur : nom + nombre total d’emprunts de ses ouvrages
SELECT au.id, au.nom, COUNT(e.ouvrage_id) AS total_emprunts
FROM auteur au
JOIN ouvrage o ON o.auteur_id = au.id
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
GROUP BY au.id, au.nom;

-- % d’ouvrages empruntés au moins une fois (global)
SELECT
  ROUND(
    COUNT(DISTINCT e.ouvrage_id) * 100 / (SELECT COUNT(*) FROM ouvrage),
    2
  ) AS pct_ouvrages_empruntes
FROM emprunt e;

-- Top 3 abonnés les plus actifs (global)
SELECT a.id, a.nom, COUNT(*) AS nbre_emprunts
FROM abonne a
JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom
ORDER BY nbre_emprunts DESC
LIMIT 3;

-- =========================
-- ETAPE 7 : CTE (MySQL 8)
-- =========================

-- Auteurs dont la moyenne d’emprunts par ouvrage > 2
WITH stats AS (
  SELECT
    o.auteur_id,
    COUNT(e.ouvrage_id) AS emprunts,
    COUNT(DISTINCT o.id) AS ouvrages
  FROM ouvrage o
  LEFT JOIN emprunt e ON e.ouvrage_id = o.id
  GROUP BY o.auteur_id
)
SELECT
  s.auteur_id,
  ROUND(s.emprunts / NULLIF(s.ouvrages, 0), 2) AS moyenne
FROM stats s
WHERE s.emprunts / NULLIF(s.ouvrages, 0) > 2;



-- Index utiles (si non présents)
CREATE INDEX idx_emprunt_abonne  ON emprunt(abonne_id);
CREATE INDEX idx_emprunt_ouvrage ON emprunt(ouvrage_id);
CREATE INDEX idx_emprunt_date    ON emprunt(date_debut);

-- EXPLAIN exemple
EXPLAIN
SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id;

-- 1) Moyenne d’emprunts par jour de semaine (sur 2025)
SELECT
  DAYOFWEEK(date_debut) AS jour_semaine,
  COUNT(*) / COUNT(DISTINCT date_debut) AS moyenne_par_jour
FROM emprunt
WHERE YEAR(date_debut) = 2025
GROUP BY DAYOFWEEK(date_debut)
ORDER BY jour_semaine;

-- 2) Total d’emprunts par mois en 2025
SELECT
  YEAR(date_debut) AS annee,
  MONTH(date_debut) AS mois,
  COUNT(*) AS total_emprunts
FROM emprunt
WHERE date_debut >= '2025-01-01' AND date_debut < '2026-01-01'
GROUP BY YEAR(date_debut), MONTH(date_debut)
ORDER BY annee, mois;

-- 3) Ouvrages jamais empruntés (liste + compteur)
SELECT o.id, o.titre
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
WHERE e.ouvrage_id IS NULL;

SELECT COUNT(*) AS nb_ouvrages_jamais_empruntes
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
WHERE e.ouvrage_id IS NULL;
