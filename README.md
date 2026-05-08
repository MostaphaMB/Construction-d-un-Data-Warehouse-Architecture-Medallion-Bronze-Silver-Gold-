# 🏗️ Construction d'un Data Warehouse : Architecture Medallion (Bronze → Silver → Gold)

## 📝 Présentation du Projet
Ce projet consiste à concevoir et implémenter un **Data Warehouse** complet basé sur une architecture en couches (Medallion Architecture). L'objectif est de transformer des données financières brutes provenant de systèmes opérationnels en une solution analytique structurée et performante, garantissant la qualité et la traçabilité de la donnée.

## 🎯 Objectifs du Projet
* **Ingestion de masse** : Charger des données brutes depuis des fichiers CSV via des techniques de *Bulk Insert*.
* **Architecture en couches** : Maîtriser le passage de la donnée à travers les couches **Bronze** (Raw), **Silver** (Cleansed) et **Gold** (Curated).
* **Modélisation Dimensionnelle** : Concevoir un modèle en étoile (**Star Schema**) optimisé pour le reporting.
* **Data Quality** : Mettre en place des contrôles de qualité à chaque étape du pipeline.
* **Automatisation SQL** : Développer des scripts SQL robustes pour les processus ETL.

## 🛠️ Stack Technique
* **Base de Données** : SQL Server / Azure SQL Database.
* **Langage** : T-SQL (Stored Procedures, Views, Bulk Insert).
* **Architecture** : Medallion (Bronze, Silver, Gold).
* **Modélisation** : Power BI (pour la validation du modèle Gold).
* **Gestion de Projet** : Jira & GitHub.

---

## 🏗️ Architecture du Data Warehouse

Le flux de données est segmenté en trois zones distinctes :

1.  **🥉 Couche Bronze (Raw Data)** : Stockage des données brutes telles qu'elles proviennent des sources. Aucune transformation n'est appliquée, l'objectif est la fidélité à la source.
2.  **🥈 Couche Silver (Cleansed Data)** : Nettoyage, standardisation des formats (dates, devises), gestion des doublons et application des règles de gestion élémentaires.
3.  **🥇 Couche Gold (Business Data)** : Modélisation en étoile avec tables de faits et tables de dimensions. Les données sont agrégées et prêtes pour la consommation par les outils de BI.

---

## 🚀 Étapes de Réalisation

### 1. Ingestion & Couche Bronze 📥
* Création des tables de "Staging" correspondant à la structure des fichiers sources.
* Utilisation de scripts `BULK INSERT` pour l'importation massive des fichiers CSV.
* Vérification de l'intégrité technique du chargement.

### 2. Transformation & Couche Silver ⚙️
* Suppression des enregistrements erronés ou incomplets.
* Normalisation des champs textuels et conversion des types de données.
* Mise en place de contrôles de qualité (Data Quality Checks).

### 3. Modélisation & Couche Gold 💎
* Création des **Tables de Dimensions** (Clients, Temps, Produits, etc.).
* Création de la **Table de Faits** (Transactions financières).
* Mise en place des relations et des clés étrangères pour assurer l'intégrité référentielle.

### 4. Analyse et Reporting 📊
* Connexion du modèle Gold à un outil de BI (Power BI).
* Création de mesures de performance financière et de visualisations décisionnelles.


