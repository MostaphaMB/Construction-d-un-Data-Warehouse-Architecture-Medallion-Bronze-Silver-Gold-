# 🏗️ Construction d'un Data Warehouse : Architecture Medallion (Bronze → Silver → Gold)

## 📝 Présentation du Projet
Ce projet consiste à concevoir et implémenter un **Data Warehouse** complet basé sur une architecture en couches (Medallion Architecture). L'objectif est de transformer des données financières brutes provenant de systèmes opérationnels (ERP, CRM, fichiers CSV) en une solution analytique structurée et performante, garantissant la qualité et la traçabilité de la donnée.

## 🎯 Objectifs du Projet
* **Ingestion de masse** : Charger des données brutes depuis des fichiers CSV via des techniques de *Bulk Insert*.
* **Architecture Medallion** : Maîtriser le passage de la donnée à travers les couches **Bronze** (Raw), **Silver** (Cleansed) et **Gold** (Curated).
* **Modélisation Dimensionnelle** : Concevoir un modèle en étoile (**Star Schema**) optimisé pour le reporting et l'analyse décisionnelle.
* **Data Quality** : Mettre en place des contrôles de qualité et de standardisation à chaque étape du pipeline.
* **Automatisation SQL** : Développer des scripts T-SQL robustes pour les processus ETL.

## 🛠️ Stack Technique
* **Base de Données** : SQL Server / Azure SQL Database.
* **Langage** : T-SQL (Stored Procedures, Views, Bulk Insert).
* **Architecture** : Medallion (Bronze, Silver, Gold).
* **Modélisation** : Power BI (pour la validation du modèle Gold).
* **Gestion de Projet** : Jira & GitHub.

---

## 🏗️ Architecture du Data Warehouse

Le flux de données est segmenté en trois zones distinctes pour assurer une gouvernance optimale :

1.  **🥉 Couche Bronze (Raw Data)** : Ingestion des données brutes fidèles aux sources. Stockage des fichiers sources sans transformation pour permettre le rechargement si nécessaire.
2.  **🥈 Couche Silver (Cleansed Data)** : Nettoyage technique et fonctionnel (gestion des doublons, formats de dates, types de données). Application des contrôles de qualité (Data Quality Checks).
3.  **🥇 Couche Gold (Business Data)** : Modélisation en étoile avec tables de faits (Transactions) et tables de dimensions (Magasins, Catégories, Temps). Les données sont agrégées et prêtes pour la BI.

---

## 🚀 Étapes de Réalisation

### 1. Ingestion & Couche Bronze 📥
* Création des schémas et des tables de "Staging".
* Utilisation de scripts `BULK INSERT` pour l'importation massive des fichiers CSV financiers.
* Validation de la conformité technique du chargement initial.

### 2. Transformation & Couche Silver ⚙️
* Nettoyage des enregistrements (suppression des anomalies et des doublons).
* Standardisation des formats et conversion des types de données.
* Mise en œuvre de règles de gestion pour assurer la cohérence des données financières.

### 3. Modélisation & Couche Gold 💎
* Création des **Tables de Dimensions** et de la **Table de Faits** (P&L, revenus et coûts).
* Mise en place des relations et des clés étrangères pour garantir l'intégrité référentielle.
* Création de vues SQL optimisées pour la consommation par Power BI.

### 4. Analyse et Reporting 📊
* Connexion du modèle Gold à Power BI.
* Analyse des revenus et des coûts, suivi des tendances temporelles et analyse par segment.
