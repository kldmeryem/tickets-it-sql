-- Projet : gestion et analyse des tickets du support IT
-- SGBD   : MySQL 8
-- Usage  : mysql -u root -p < schema.sql

DROP DATABASE IF EXISTS tickets_it;
CREATE DATABASE tickets_it CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tickets_it;

CREATE TABLE techniciens (
    id_technicien INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(100) NOT NULL,
    niveau        ENUM('N1','N2') NOT NULL
);

CREATE TABLE categories (
    id_categorie INT AUTO_INCREMENT PRIMARY KEY,
    libelle      VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE utilisateurs (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    nom            VARCHAR(100) NOT NULL,
    departement    VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE equipements (
    id_equipement  INT AUTO_INCREMENT PRIMARY KEY,
    type           VARCHAR(50)  NOT NULL,
    marque         VARCHAR(50)  NOT NULL,
    numero_serie   VARCHAR(50)  NOT NULL UNIQUE,
    id_utilisateur INT NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur)
);

CREATE TABLE tickets (
    id_ticket       INT AUTO_INCREMENT PRIMARY KEY,
    titre           VARCHAR(200) NOT NULL,
    id_categorie    INT NOT NULL,
    id_utilisateur  INT NOT NULL,
    id_technicien   INT NOT NULL,
    id_equipement   INT NULL,
    priorite        ENUM('Basse','Moyenne','Haute','Critique') NOT NULL,
    statut          ENUM('Ouvert','En cours','Résolu','Clôturé') NOT NULL,
    date_creation   DATETIME NOT NULL,
    date_resolution DATETIME NULL,
    FOREIGN KEY (id_categorie)   REFERENCES categories(id_categorie),
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur),
    FOREIGN KEY (id_technicien)  REFERENCES techniciens(id_technicien),
    FOREIGN KEY (id_equipement)  REFERENCES equipements(id_equipement)
);

CREATE INDEX idx_tickets_statut  ON tickets(statut);
CREATE INDEX idx_tickets_date    ON tickets(date_creation);
