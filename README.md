# Bibliothèque SQL — Lab 5 (Agrégations & Rapport mensuel 2025)

## Objectif
Ce lab permet de synthétiser et analyser les données de la base **bibliotheque** via :
- fonctions d’agrégation (`COUNT`, `AVG`, etc.)
- `GROUP BY` / `HAVING`
- jointures + agrégats
- CTE (`WITH`) et fonctions de fenêtre (MySQL 8) pour produire un rapport exploitable.

## Prérequis
- MySQL 8
- Base `bibliotheque` déjà créée (Labs 1 à 4)
- Tables : `auteur`, `ouvrage`, `abonne`, `emprunt`

> Remarque : dans ce projet, la table `emprunt` n’a pas de colonne `id`.
> La clé primaire est composite : `(ouvrage_id, abonne_id, date_debut)`.

---

## Fichiers
- `lab5_aggregation.sql` : requêtes d’agrégation (COUNT/AVG), GROUP BY/HAVING, jointures, top 3, index + EXPLAIN, exercices.
- <img width="1872" height="847" alt="1" src="https://github.com/user-attachments/assets/c2adef3b-f73b-4bb8-80cd-1e688b52f6c8" />

- `lab5_exercice.sql` : rapport mensuel complet des emprunts pour l’année 2025 (12 mois, même si un mois n’a aucun emprunt).
<img width="1635" height="370" alt="2" src="https://github.com/user-attachments/assets/74754079-1925-45d3-8fae-c057dbca1ee9" />
---

## Exécution dans MySQL
<img width="1635" height="370" alt="2" src="https://github.com/user-attachments/assets/74754079-1925-45d3-8fae-c057dbca1ee9" />

### 1) Se connecter et choisir la base
```sql
mysql -u root -p
USE bibliotheque;
