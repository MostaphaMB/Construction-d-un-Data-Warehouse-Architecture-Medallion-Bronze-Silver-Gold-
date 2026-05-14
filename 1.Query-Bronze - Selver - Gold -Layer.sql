-- 1. Création de la base de données
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- 2. Création des schémas (les dossiers logiques)
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

--

--Étape 1 : Bronze Layer (Ingestion)

--1.1 Création de la Base et des Schémas

-- 1. Création de la base de données
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- 2. Création des schémas (les dossiers logiques)
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

--Etape 1.2 Création des Tables Bronze
-- Table pour account.csv
CREATE TABLE bronze.account (
    account_number NVARCHAR(255),
    account_name NVARCHAR(255),
    account_type NVARCHAR(255),
    currency NVARCHAR(255)
);

-- Table pour account_mapping.csv
CREATE TABLE bronze.account_mapping (
    AccountNumber NVARCHAR(255),
    AccountName NVARCHAR(255),
    PLLine NVARCHAR(255),
    StatementType NVARCHAR(255),
    SortOrder NVARCHAR(255),
    Notes NVARCHAR(MAX)
);

-- Table pour Ftransaction.csv (on l'appelle gl_transaction)
CREATE TABLE bronze.gl_transaction (
    transaction_id NVARCHAR(255),
    transaction_date NVARCHAR(255),
    store_code NVARCHAR(255),
    account_number NVARCHAR(255),
    amount_local NVARCHAR(255),
    currency NVARCHAR(255),
    document_number NVARCHAR(255),
    description NVARCHAR(MAX)
);

-- Table pour store.csv
CREATE TABLE bronze.store (
    store_code NVARCHAR(255),
    country NVARCHAR(255),
    region NVARCHAR(255)
);

-- Table pour store_master.csv
CREATE TABLE bronze.store_master (
    store_code NVARCHAR(255),
    store_name NVARCHAR(255),
    store_type NVARCHAR(255)
);
GO

---Etape 1.3 : Chargement des données
-- Chargement des Comptes
BULK INSERT bronze.account
FROM 'D:\Data Analyst -JobInTech\Construction d’un Data Warehouse (Bronze → Silver → Gold)\data_brute\account.csv'
WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2, CODEPAGE = '65001');

-- Chargement du Mapping (Attention aux virgules dans les notes, on utilise souvent '"' comme qualificateur si besoin)
BULK INSERT bronze.account_mapping
FROM 'D:\Data Analyst -JobInTech\Construction d’un Data Warehouse (Bronze → Silver → Gold)\data_brute\account_mapping.csv'
WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2, CODEPAGE = '65001');

-- Chargement des Transactions (Ftransaction.csv)
BULK INSERT bronze.gl_transaction
FROM 'D:\Data Analyst -JobInTech\Construction d’un Data Warehouse (Bronze → Silver → Gold)\data_brute\Ftransaction.csv'
WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2, CODEPAGE = '65001');

-- Chargement des Stores
BULK INSERT bronze.store
FROM 'D:\Data Analyst -JobInTech\Construction d’un Data Warehouse (Bronze → Silver → Gold)\data_brute\store.csv'
WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2, CODEPAGE = '65001');

-- Chargement du Store Master
BULK INSERT bronze.store_master
FROM 'D:\Data Analyst -JobInTech\Construction d’un Data Warehouse (Bronze → Silver → Gold)\data_brute\store_master.csv'
WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2, CODEPAGE = '65001');

--Etape 1.4 : Vérification (Data Quality Check)

-- 1. Est-ce que les tables sont remplies ?
SELECT 'account' as TableName, COUNT(*) as Total FROM bronze.account
UNION ALL
SELECT 'gl_transaction', COUNT(*) FROM bronze.gl_transaction;

-- 2. Regarder un échantillon pour vérifier si les colonnes sont décalées
SELECT TOP 5 * FROM bronze.gl_transaction;

--------------------------------- Étape 2 : Silver Layer (Nettoyage et Standardisation)----------------------------

---2.1 Création des tables Silver

-- Table Silver pour les comptes
CREATE TABLE silver.dim_account (
    account_number INT PRIMARY KEY,
    account_name NVARCHAR(255),
    account_type NVARCHAR(100),
    currency NVARCHAR(10)
);

-- Table Silver pour les magasins (fusion de store et store_master)
CREATE TABLE silver.dim_store (
    store_code NVARCHAR(50) PRIMARY KEY,
    store_name NVARCHAR(255),
    store_type NVARCHAR(50),
    country NVARCHAR(100),
    region NVARCHAR(100)
);

-- Table Silver pour les transactions
CREATE TABLE silver.fact_gl_transaction (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE,
    store_code NVARCHAR(50),
    account_number INT,
    amount_local DECIMAL(18, 2),
    currency NVARCHAR(10),
    description NVARCHAR(MAX)
);

-- Table Silver pour le mapping
CREATE TABLE silver.account_mapping (
    account_number INT,
    pl_line NVARCHAR(100),
    statement_type NVARCHAR(100),
    sort_order INT
);

---2.2 Transformation et Nettoyage

SELECT * FROM silver.fact_gl_transaction
SELECT * FROM silver.account_mapping
----Script pour les transactions :
INSERT INTO silver.fact_gl_transaction
SELECT 
    CAST(transaction_id AS INT),
    CAST(transaction_date AS DATE),
    TRIM(UPPER(store_code)), -- On enlève les espaces et on met en majuscules
    CAST(account_number AS INT),
    CAST(amount_local AS DECIMAL(18,2)),
    TRIM(currency),
    TRIM(description)
FROM bronze.gl_transaction
WHERE transaction_id IS NOT NULL; -- On ignore les lignes vides

-- Remplissage des Comptes

INSERT INTO silver.dim_account (account_number, account_name, account_type, currency)
SELECT 
    CAST(account_number AS INT), 
    MAX(TRIM(account_name)), -- On prend un des noms si doublon
    MAX(TRIM(account_type)), 
    MAX(TRIM(currency))
FROM bronze.account
GROUP BY CAST(account_number AS INT);


---Script pour le mapping (Standardisation "P L" -> "P&L") :

TRUNCATE TABLE silver.account_mapping;

INSERT INTO silver.account_mapping (account_number, pl_line, statement_type, sort_order)
SELECT 
    CAST(AccountNumber AS INT),
    MAX(TRIM(PLLine)),
    MAX(CASE WHEN StatementType = 'P L' THEN 'P&L' ELSE TRIM(StatementType) END),
    MAX(CAST(CAST(SortOrder AS DECIMAL(18,2)) AS INT))
FROM bronze.account_mapping
WHERE AccountNumber IS NOT NULL
GROUP BY CAST(AccountNumber AS INT); 

-- Remplissage des Magasins (Fusion)
INSERT INTO silver.dim_store
SELECT TRIM(UPPER(m.store_code)), TRIM(m.store_name), TRIM(m.store_type), TRIM(s.country), TRIM(s.region)
FROM bronze.store_master m
LEFT JOIN bronze.store s ON m.store_code = s.store_code;

---Etape 2.3 : Data Quality Checks (DQC) sur la couche Silver---
----1. Test de Complétude (Bronze vs Silver)
SELECT 
    (SELECT COUNT(*) FROM bronze.gl_transaction) AS count_bronze,
    (SELECT COUNT(*) FROM silver.fact_gl_transaction) AS count_silver;

---2 Test d'Unicité (Doublons)
SELECT transaction_id, COUNT(*)
FROM silver.fact_gl_transaction
GROUP BY transaction_id
HAVING COUNT(*) > 1;

SELECT account_number, COUNT(*)
FROM silver.dim_account
GROUP BY account_number
HAVING COUNT(*) > 1;

---3. Test de Validité (Valeurs Nulles critiques)
SELECT COUNT(*) AS missing_values
FROM silver.fact_gl_transaction
WHERE amount_local IS NULL 
   OR transaction_date IS NULL 
   OR account_number IS NULL;

---4. Test d'Intégrité Référentielle
SELECT DISTINCT t.store_code
FROM silver.fact_gl_transaction t
LEFT JOIN silver.dim_store s ON t.store_code = s.store_code
WHERE s.store_code IS NULL;

------------------------------------Étape 3 : Gold Layer (Le Modèle en Étoile)--------------------------------------

---3.2 Création de la Dimension Compte (dim_account)

CREATE VIEW gold.dim_account AS
SELECT 
    a.account_number,
    a.account_name,
    a.account_type,
    m.pl_line,
    m.statement_type,
    m.sort_order
FROM silver.dim_account a
LEFT JOIN silver.account_mapping m ON a.account_number = m.account_number;
GO

---3.3 Création de la Dimension Magasin (dim_store)

CREATE VIEW gold.dim_store AS
SELECT 
    store_code,
    store_name,
    store_type,
    country,
    region
FROM silver.dim_store;
GO

---3.4 Création de la Table de Faits (fact_gl_transaction)
CREATE VIEW gold.fact_gl_transaction AS
SELECT 
    transaction_id,
    transaction_date,
    store_code,      -- Clé pour joindre dim_store
    account_number,  -- Clé pour joindre dim_account
    amount_local,
    currency,
    description
FROM silver.fact_gl_transaction;
GO
---Test ultime pour voir si modèle répond bien

--Somme des montants par Type de Rapport (P&L vs Bilan)
SELECT 
    a.statement_type, 
    SUM(f.amount_local) as Total
FROM gold.fact_gl_transaction f
JOIN gold.dim_account a ON f.account_number = a.account_number
GROUP BY a.statement_type;

----
select * from gold.fact_gl_transaction;
select * from gold.dim_account;
select * from gold.dim_store;

-------------------pour vider les tables silver------------------

--TRUNCATE TABLE silver.fact_gl_transaction;
--TRUNCATE TABLE silver.dim_account;
--TRUNCATE TABLE silver.account_mapping;
--TRUNCATE TABLE silver.dim_store;







