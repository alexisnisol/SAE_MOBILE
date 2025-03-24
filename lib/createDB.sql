DROP TABLE IF EXISTS UTILISATEUR;
DROP TABLE IF EXISTS PROPOSER;
DROP TABLE IF EXISTS RESTAURANT;
DROP TABLE IF EXISTS TYPE_CUISINE;
DROP TABLE IF EXISTS TYPE;
DROP TABLE IF EXISTS FAIRE_TYPE;


CREATE TABLE UTILISATEUR (
    id_utilisateur   INT NOT NULL,
    nom              VARCHAR(42),
    prenom           VARCHAR(42),
    email            VARCHAR(100),
    mdp              VARCHAR(64),
    role             TEXT CHECK (role in ('CLIENT','MODERATEUR','ADMIN')) DEFAULT 'CLIENT',
    PRIMARY KEY (id_utilisateur)
);

CREATE TABLE RESTAURANT (
    id_restaurant SERIAL PRIMARY KEY,
    name VARCHAR,
    operator VARCHAR,
    brand VARCHAR,
    opening_hours VARCHAR,
    wheelchair BOOLEAN,
    vegetarian BOOLEAN,
    vegan BOOLEAN,
    delivery BOOLEAN,
    takeaway BOOLEAN,
    internet_access VARCHAR,
    stars INT,
    capacity INT,
    drive_through BOOLEAN,
    wikidata VARCHAR,
    brand_wikidata VARCHAR,
    siret VARCHAR,
    phone VARCHAR,
    website VARCHAR,
    facebook VARCHAR,
    smoking BOOLEAN,
    com_insee BIGINT,
    com_nom VARCHAR,
    region VARCHAR,
    code_region BIGINT,
    departement VARCHAR,
    code_departement BIGINT,
    commune VARCHAR,
    code_commune BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);

CREATE TABLE TYPE_CUISINE (
    id_cuisine SERIAL PRIMARY KEY,
    cuisine VARCHAR NOT NULL
);

CREATE TABLE PROPOSER (
    id_restaurant INT NOT NULL,
    id_cuisine INT NOT NULL,
    PRIMARY KEY (id_restaurant, id_cuisine),
    FOREIGN KEY (id_restaurant) REFERENCES RESTAURANT(id_restaurant),
    FOREIGN KEY (id_cuisine) REFERENCES TYPE_CUISINE(id_cuisine)
);

CREATE TABLE TYPE (
    id_type INT PRIMARY KEY,
    type VARCHAR NOT NULL
);

CREATE TABLE FAIRE_TYPE (
    id_restaurant INT NOT NULL,
    id_type INT NOT NULL,
    PRIMARY KEY (id_restaurant, id_type),
    FOREIGN KEY (id_restaurant) REFERENCES RESTAURANT(id_restaurant),
    FOREIGN KEY (id_type) REFERENCES TYPE(id_type)
);

CREATE TABLE AVIS (
    id_avis         INT NOT NULL, 
    id_utilisateur  INT NOT NULL,
    id_restaurant   INT NOT NULL,
    etoile          INT CHECK (etoile >= 0 AND etoile <= 5),
    avis            VARCHAR(200),
    date_avis       DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_avis),
    FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEUR(id_utilisateur), 
    FOREIGN KEY (id_restaurant) REFERENCES RESTAURANT(id_restaurant)
);

CREATE TABLE CUISINE_AIME (
    id_utilisateur  INT NOT NULL,
    id_cuisine      INT NOT NULL,
    PRIMARY KEY (id_utilisateur, id_cuisine), 
    FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEUR(id_utilisateur), 
    FOREIGN KEY (id_cuisine) REFERENCES TYPE_CUISINE(id_cuisine)
); 

CREATE TABLE RESTAURANT_AIME (
    id_utilisateur  INT NOT NULL,
    id_restaurant   INT NOT NULL,
    PRIMARY KEY (id_utilisateur, id_restaurant), 
    FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEUR(id_utilisateur), 
    FOREIGN KEY (id_restaurant) REFERENCES RESTAURANT(id_restaurant)
);

