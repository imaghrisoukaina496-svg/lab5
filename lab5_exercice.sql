USE bibliotheque;

-- Rapport mensuel d’activité d’emprunts – Année 2025
-- Contraintes : mois sans emprunt doit apparaître (0), utiliser CTE, lisible

WITH
-- 1) Liste des mois 2025 (1..12) pour forcer l’affichage même si aucun emprunt
mois_2025 AS (
  SELECT 1 AS mois UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
  UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
),

-- 2) Emprunts filtrés sur 2025 + extraction mois/année
e2025 AS (
  SELECT
    YEAR(date_debut) AS annee,
    MONTH(date_debut) AS mois,
    ouvrage_id,
    abonne_id,
    date_debut
  FROM emprunt
  WHERE date_debut >= '2025-01-01' AND date_debut < '2026-01-01'
),

-- 3) Indicateurs de base par mois
base AS (
  SELECT
    2025 AS annee,
    m.mois,
    COALESCE(COUNT(e.ouvrage_id), 0) AS total_emprunts,
    COALESCE(COUNT(DISTINCT e.abonne_id), 0) AS abonnes_actifs
  FROM mois_2025 m
  LEFT JOIN e2025 e ON e.mois = m.mois
  GROUP BY m.mois
),

-- 4) Ouvrages distincts empruntés par mois (pourcentage)
ouvrages_mensuels AS (
  SELECT
    2025 AS annee,
    m.mois,
    COALESCE(COUNT(DISTINCT e.ouvrage_id), 0) AS ouvrages_empruntes
  FROM mois_2025 m
  LEFT JOIN e2025 e ON e.mois = m.mois
  GROUP BY m.mois
),

-- 5) Comptage des emprunts par ouvrage et par mois
cnt_ouvrage AS (
  SELECT
    annee,
    mois,
    ouvrage_id,
    COUNT(*) AS nb_emprunts
  FROM e2025
  GROUP BY annee, mois, ouvrage_id
),

-- 6) Classement des ouvrages (top 3) par mois
ranked AS (
  SELECT
    c.annee,
    c.mois,
    c.ouvrage_id,
    c.nb_emprunts,
    ROW_NUMBER() OVER (
      PARTITION BY c.annee, c.mois
      ORDER BY c.nb_emprunts DESC, c.ouvrage_id
    ) AS rn
  FROM cnt_ouvrage c
),

-- 7) Top 3 titres concaténés par mois
top3 AS (
  SELECT
    r.annee,
    r.mois,
    GROUP_CONCAT(CONCAT(o.titre, ' (', r.nb_emprunts, ')')
                 ORDER BY r.nb_emprunts DESC SEPARATOR ', ') AS top_3_ouvrages
  FROM ranked r
  JOIN ouvrage o ON o.id = r.ouvrage_id
  WHERE r.rn <= 3
  GROUP BY r.annee, r.mois
),

-- 8) Total ouvrages bibliothèque (constante)
totaux AS (
  SELECT COUNT(*) AS total_ouvrages
  FROM ouvrage
)

-- 9) Rapport final
SELECT
  b.annee,
  b.mois,
  b.total_emprunts,
  b.abonnes_actifs,
  ROUND(b.total_emprunts / NULLIF(b.abonnes_actifs, 0), 2) AS moyenne_par_abonne,
  ROUND(om.ouvrages_empruntes * 100 / NULLIF(t.total_ouvrages, 0), 2) AS pct_ouvrages_empruntes,
  COALESCE(t3.top_3_ouvrages, '') AS top_3_ouvrages
FROM base b
JOIN ouvrages_mensuels om ON om.annee = b.annee AND om.mois = b.mois
CROSS JOIN totaux t
LEFT JOIN top3 t3 ON t3.annee = b.annee AND t3.mois = b.mois
ORDER BY b.annee, b.mois;
