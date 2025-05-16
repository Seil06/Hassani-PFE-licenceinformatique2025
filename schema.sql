-- Enable PostGIS extension for geographic data
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table: mot_cle (pour représenter l'enum Mot_cles)
CREATE TABLE mot_cle (
    id_mot_cle SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT check_nom_mot_cle CHECK (nom IN (
        'urgence', 'eau', 'nourriture', 'affaire_scolaire', 'eidElFitr', 'eidElAdha', 
        'ramadan', 'sadaquah', 'yennayer', 'hiver', 'animaux', 'boisement', 'recyclage', 
        'sante', 'medicament', 'marriage', 'mosquee', 'vetement', 'vetementHivers', 
        'inondations', 'tremblementDeTerre', 'refuges', 'femmes', 'reservoirsOxygene', 'autre'
    ))
);

-- Insertion des valeurs possibles pour Mot_cles
INSERT INTO mot_cle (nom) VALUES 
    ('urgence'), ('eau'), ('nourriture'), ('affaire_scolaire'), ('eidElFitr'), ('eidElAdha'),
    ('ramadan'), ('sadaquah'), ('yennayer'), ('hiver'), ('animaux'), ('boisement'), ('recyclage'),
    ('sante'), ('medicament'), ('marriage'), ('mosquee'), ('vetement'), ('vetementHivers'),
    ('inondations'), ('tremblementDeTerre'), ('refuges'), ('femmes'), ('reservoirsOxygene'), ('autre');

-- Table: historique
CREATE TABLE historique (
    id_historique SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    action VARCHAR(255) NOT NULL,
    details TEXT NOT NULL,
    id_acteur INT
);

-- Table: dashboard
CREATE TABLE dashboard (
    id_dashboard SERIAL PRIMARY KEY,
    id_historique INT NOT NULL,
    CONSTRAINT fk_historique FOREIGN KEY (id_historique) REFERENCES historique(id_historique)
);

-- Table: profile
CREATE TABLE profile (
    id_profile SERIAL PRIMARY KEY,
    photo_url TEXT,
    bio TEXT,
    id_dashboard INT NOT NULL,
    CONSTRAINT fk_dashboard FOREIGN KEY (id_dashboard) REFERENCES dashboard(id_dashboard)
);

-- Table: acteur
CREATE TABLE acteur (
    id_acteur SERIAL PRIMARY KEY,
    type_acteur VARCHAR(50) NOT NULL CHECK (type_acteur IN ('admin', 'utilisateur')),
    email VARCHAR(255) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    id_profile INT NOT NULL,
    note_moyenne FLOAT DEFAULT 0.0 CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    supabase_user_id VARCHAR(36),
    CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES profile(id_profile)
);

-- Update historique to add foreign key after acteur is created
ALTER TABLE historique
ADD CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur);

-- Table: utilisateur
CREATE TABLE utilisateur (
    id_acteur INT PRIMARY KEY,
    type_utilisateur VARCHAR(50) NOT NULL CHECK (type_utilisateur IN ('donateur', 'association', 'beneficiaire')),
    telephone VARCHAR(20),
    adresse_utilisateur GEOGRAPHY(POINT),
    num_carte_identite VARCHAR(18) UNIQUE,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: admin
CREATE TABLE admin (
    id_acteur INT PRIMARY KEY,
    nom_admin VARCHAR(100) NOT NULL,
    prenom_admin VARCHAR(100) NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: donateur
CREATE TABLE donateur (
    id_acteur INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: association
CREATE TABLE association (
    id_acteur INT PRIMARY KEY,
    nom_association VARCHAR(255) NOT NULL,
    document_authorisation TEXT NOT NULL,
    statut_validation BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: beneficiaire
CREATE TABLE beneficiaire (
    id_acteur INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    document_situation TEXT NOT NULL,
    type_beneficiaire VARCHAR(50) NOT NULL CHECK (type_beneficiaire IN ('pauvre', 'sdf', 'orphelin', 'enfantMalade', 'personneAgee', 'malade', 'handicape', 'femmeDivorcee', 'femmeSeule', 'femmeVeuve', 'autre')),
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: post (without id_don foreign key initially)
CREATE TABLE post (
    id_post SERIAL PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    type_post VARCHAR(50) NOT NULL CHECK (type_post IN ('officiel', 'invite', 'demande', 'campagne')),
    image TEXT,
    date_limite TIMESTAMP,
    adresse_utilisateur GEOGRAPHY(POINT),
    note_moyenne FLOAT DEFAULT 0.0 CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    id_acteur INT NOT NULL,
    id_don INT,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: campagne
CREATE TABLE campagne (
    id_campagne INT PRIMARY KEY,
    etat_campagne VARCHAR(50) NOT NULL CHECK (etat_campagne IN ('brouillon', 'publiee', 'enCours', 'objectif_atteint', 'annulee', 'cloturee')),
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL,
    lieu_evenement GEOGRAPHY(POINT) NOT NULL,
    type_campagne VARCHAR(50) NOT NULL CHECK (type_campagne IN ('evenement', 'volontariat', 'sensibilisation', 'collecte')),
    montant_objectif FLOAT DEFAULT 0.0 CHECK (montant_objectif >= 0),
    montant_recolte FLOAT DEFAULT 0.0 CHECK (montant_recolte >= 0),
    nombre_participants INT DEFAULT 0,
    id_association INT NOT NULL,
    CONSTRAINT fk_post FOREIGN KEY (id_campagne) REFERENCES post(id_post),
    CONSTRAINT fk_association FOREIGN KEY (id_association) REFERENCES association(id_acteur)
);

-- Table: don
CREATE TABLE don (
    id_don SERIAL PRIMARY KEY,
    num_carte_bancaire VARCHAR(16) NOT NULL,
    montant FLOAT CHECK (montant >= 0) NOT NULL,
    date_don TIMESTAMP NOT NULL,
    type_don VARCHAR(50) NOT NULL CHECK (type_don IN ('financier', 'materiel', 'alimentaire', 'medicament', 'benevolat', 'service', 'autre')),
    etat_don VARCHAR(50) NOT NULL CHECK (etat_don IN ('enAttente', 'valide', 'refuse', 'enCours', 'termine')),
    id_donateur INT NOT NULL,
    id_campagne INT,
    id_beneficiaire INT,
    id_post INT,
    CONSTRAINT fk_donateur FOREIGN KEY (id_donateur) REFERENCES donateur(id_acteur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT fk_beneficiaire FOREIGN KEY (id_beneficiaire) REFERENCES beneficiaire(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT check_don_target CHECK (
        (id_campagne IS NOT NULL AND id_beneficiaire IS NULL AND id_post IS NULL) OR
        (id_campagne IS NULL AND id_beneficiaire IS NOT NULL AND id_post IS NULL) OR
        (id_campagne IS NULL AND id_beneficiaire IS NULL AND id_post IS NOT NULL)
    )
);

-- Add id_don foreign key to post after don is created
ALTER TABLE post
ADD CONSTRAINT fk_don FOREIGN KEY (id_don) REFERENCES don(id_don);

-- Table: post_mot_cle
CREATE TABLE post_mot_cle (
    id_post INT NOT NULL,
    id_mot_cle INT NOT NULL,
    PRIMARY KEY (id_post, id_mot_cle),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_mot_cle FOREIGN KEY (id_mot_cle) REFERENCES mot_cle(id_mot_cle)
);

-- Table: zakat
CREATE TABLE zakat (
    id_zakat SERIAL PRIMARY KEY,
    montant FLOAT NOT NULL CHECK (montant >= 0),
    date TIMESTAMP NOT NULL,
    id_donateur INT NOT NULL,
    id_don INT NOT NULL,
    id_association INT,
    id_beneficiaire INT,
    CONSTRAINT fk_donateur FOREIGN KEY (id_donateur) REFERENCES donateur(id_acteur),
    CONSTRAINT fk_don FOREIGN KEY (id_don) REFERENCES don(id_don),
    CONSTRAINT fk_association FOREIGN KEY (id_association) REFERENCES association(id_acteur),
    CONSTRAINT fk_beneficiaire FOREIGN KEY (id_beneficiaire) REFERENCES beneficiaire(id_acteur),
    CONSTRAINT check_zakat_target CHECK (
        (id_association IS NOT NULL AND id_beneficiaire IS NULL) OR
        (id_association IS NULL AND id_beneficiaire IS NOT NULL)
    )
);

-- Table: notification
CREATE TABLE notification (
    id_notification SERIAL PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    contenu TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    type_notification VARCHAR(50) NOT NULL CHECK (type_notification IN ('nouveau_post', 'nouvelle_campagne', 'avertissement', 'message', 'autre')),
    id_acteur INT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: note
CREATE TABLE note (
    id_note SERIAL PRIMARY KEY,
    note FLOAT NOT NULL CHECK (note >= 0 AND note <= 5),
    date TIMESTAMP NOT NULL,
    raison TEXT,
    id_utilisateur_auteur INT NOT NULL,
    id_post INT,
    id_profile INT,
    id_campagne INT,
    CONSTRAINT fk_utilisateur_auteur FOREIGN KEY (id_utilisateur_auteur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES profile(id_profile),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT unique_note UNIQUE (id_utilisateur_auteur, id_post, id_profile, id_campagne),
    CONSTRAINT check_note_target CHECK (
        (id_post IS NOT NULL AND id_profile IS NULL AND id_campagne IS NULL) OR
        (id_post IS NULL AND id_profile IS NOT NULL AND id_campagne IS NULL) OR
        (id_post IS NULL AND id_profile IS NULL AND id_campagne IS NOT NULL)
    )
);

-- Table: like
CREATE TABLE "like" (
    id_like SERIAL PRIMARY KEY,
    date_like TIMESTAMP NOT NULL,
    id_utilisateur INT NOT NULL,
    id_post INT,
    id_campagne INT,
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT unique_like UNIQUE (id_utilisateur, id_post, id_campagne),
    CONSTRAINT check_like_target CHECK (
        (id_post IS NOT NULL AND id_campagne IS NULL) OR
        (id_post IS NULL AND id_campagne IS NOT NULL)
    )
);

-- Table: commentaire
CREATE TABLE commentaire (
    id_commentaire SERIAL PRIMARY KEY,
    contenu TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    id_acteur INT NOT NULL,
    id_post INT,
    id_campagne INT,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT check_commentaire_target CHECK (
        (id_post IS NOT NULL AND id_campagne IS NULL) OR
        (id_post IS NULL AND id_campagne IS NOT NULL)
    )
);

-- Table: avertissement
CREATE TABLE avertissement (
    id_avertissement SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    id_admin INT NOT NULL,
    id_utilisateur INT NOT NULL,
    CONSTRAINT fk_admin FOREIGN KEY (id_admin) REFERENCES admin(id_acteur),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table: conversation_groupe
CREATE TABLE conversation_groupe (
    id_conversation SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    date_creation TIMESTAMP NOT NULL DEFAULT NOW(),
    id_createur INT NOT NULL,
    CONSTRAINT fk_createur FOREIGN KEY (id_createur) REFERENCES acteur(id_acteur)
);

-- Table: membre_conversation
CREATE TABLE membre_conversation (
    id_conversation INT NOT NULL,
    id_acteur INT NOT NULL,
    date_ajout TIMESTAMP NOT NULL DEFAULT NOW(),
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'membre')),
    PRIMARY KEY (id_conversation, id_acteur),
    CONSTRAINT fk_conversation FOREIGN KEY (id_conversation) REFERENCES conversation_groupe(id_conversation),
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: message
CREATE TABLE message (
    id_message SERIAL PRIMARY KEY,
    contenu TEXT NOT NULL,
    date_envoi TIMESTAMP NOT NULL,
    id_expediteur INT NOT NULL,
    id_conversation INT,
    est_groupe BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_expediteur FOREIGN KEY (id_expediteur) REFERENCES acteur(id_acteur),
    CONSTRAINT fk_conversation FOREIGN KEY (id_conversation) REFERENCES conversation_groupe(id_conversation),
    CONSTRAINT check_message_type CHECK (
        (est_groupe = TRUE AND id_conversation IS NOT NULL) OR
        (est_groupe = FALSE AND id_conversation IS NULL)
    )
);

-- Table: message_destinataire
CREATE TABLE message_destinataire (
    id_message INT NOT NULL,
    id_destinataire INT NOT NULL,
    PRIMARY KEY (id_message, id_destinataire),
    CONSTRAINT fk_message FOREIGN KEY (id_message) REFERENCES message(id_message),
    CONSTRAINT fk_destinataire FOREIGN KEY (id_destinataire) REFERENCES acteur(id_acteur)
);

-- Table: piece_jointe
CREATE TABLE piece_jointe (
    id_piece_jointe SERIAL PRIMARY KEY,
    url_fichier TEXT NOT NULL,
    type_fichier VARCHAR(50) NOT NULL,
    id_message INT NOT NULL,
    CONSTRAINT fk_message FOREIGN KEY (id_message) REFERENCES message(id_message)
);

-- Table: utilisateur_suivi
CREATE TABLE utilisateur_suivi (
    id_suiveur INT NOT NULL,
    id_suivi INT NOT NULL,
    PRIMARY KEY (id_suiveur, id_suivi),
    CONSTRAINT fk_suiveur FOREIGN KEY (id_suiveur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_suivi FOREIGN KEY (id_suivi) REFERENCES utilisateur(id_acteur)
);

-- Table: campagne_suivi
CREATE TABLE campagne_suivi (
    id_campagne INT NOT NULL,
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_campagne, id_utilisateur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table: participants_campagne
CREATE TABLE participants_campagne (
    id_utilisateur INT NOT NULL,
    id_campagne INT NOT NULL,
    PRIMARY KEY (id_utilisateur, id_campagne),
    CONSTRAINT fk_utilisateur_campagne FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne)
);

-- Table: post_utilisateur_tag
CREATE TABLE post_utilisateur_tag (
    id_post INT NOT NULL,
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_post, id_utilisateur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table: don_association
CREATE TABLE don_association (
    id_don INT NOT NULL,
    id_association INT NOT NULL,
    PRIMARY KEY (id_don, id_association),
    CONSTRAINT fk_don FOREIGN KEY (id_don) REFERENCES don(id_don),
    CONSTRAINT fk_association FOREIGN KEY (id_association) REFERENCES association(id_acteur)
);

-- Table: parametre_zakat
CREATE TABLE parametre_zakat (
    id_parametre SERIAL PRIMARY KEY,
    annee INT NOT NULL,
    seuil_nisab FLOAT NOT NULL,
    taux_zakat FLOAT NOT NULL DEFAULT 0.025,
    devise VARCHAR(10) NOT NULL DEFAULT 'DZD',
    date_mise_a_jour TIMESTAMP NOT NULL DEFAULT NOW()
);


-- Insert initial zakat parameters
INSERT INTO parametre_zakat (annee, seuil_nisab, taux_zakat, devise) VALUES 
    (2024, 750000.0, 0.025, 'DZD'),
    (2024, 5000.0, 0.025, 'USD'),
    (2024, 4600.0, 0.025, 'EUR');

-- Table: bien_zakat
CREATE TABLE bien_zakat (
    id_bien_zakat SERIAL PRIMARY KEY,
    id_donateur INT NOT NULL,
    type_bien VARCHAR(50) NOT NULL CHECK (type_bien IN ('especes', 'or', 'argent', 'actions', 'marchandises', 'recoltes', 'betail', 'creances', 'autres')),
    valeur FLOAT NOT NULL,
    devise VARCHAR(10) NOT NULL DEFAULT 'DZD',
    date_ajout TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_donateur FOREIGN KEY (id_donateur) REFERENCES donateur(id_acteur)
);

-- Table: rappel_evenement
CREATE TABLE rappel_evenement (
    id_rappel SERIAL PRIMARY KEY,
    id_campagne INT NOT NULL,
    date_rappel TIMESTAMP NOT NULL,
    message TEXT NOT NULL,
    envoye BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne)
);

-- Table: critere_notation
CREATE TABLE critere_notation (
    id_critere SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    poids FLOAT NOT NULL DEFAULT 1.0 CHECK (poids > 0)
);

-- Insert initial rating criteria
INSERT INTO critere_notation (nom, description, poids) VALUES
    ('Fiabilité', 'Fiabilité de l''utilisateur ou du service', 1.0),
    ('Qualité', 'Qualité du service ou du produit fourni', 1.0),
    ('Communication', 'Qualité de la communication', 0.8),
    ('Ponctualité', 'Respect des délais', 0.7);

-- Table: note_detaillee
CREATE TABLE note_detaillee (
    id_note_detaillee SERIAL PRIMARY KEY,
    id_note INT NOT NULL,
    id_critere INT NOT NULL,
    valeur FLOAT NOT NULL CHECK (valeur >= 0 AND valeur <= 5),
    CONSTRAINT fk_note FOREIGN KEY (id_note) REFERENCES note(id_note),
    CONSTRAINT fk_critere FOREIGN KEY (id_critere) REFERENCES critere_notation(id_critere),
    CONSTRAINT unique_note_critere UNIQUE (id_note, id_critere)
);

-- Table: statistique_plateforme
CREATE TABLE statistique_plateforme (
    id_statistique SERIAL PRIMARY KEY,
    date_statistique DATE NOT NULL DEFAULT CURRENT_DATE,
    nb_utilisateurs_actifs INT NOT NULL DEFAULT 0,
    nb_posts_publies INT NOT NULL DEFAULT 0,
    nb_dons_effectues INT NOT NULL DEFAULT 0,
    montant_total_dons FLOAT NOT NULL DEFAULT 0,
    nb_campagnes_actives INT NOT NULL DEFAULT 0
);

-- Table: historique_recherche
CREATE TABLE historique_recherche (
    id_historique_recherche SERIAL PRIMARY KEY,
    terme_recherche TEXT NOT NULL,
    date_recherche TIMESTAMP NOT NULL DEFAULT NOW(),
    resultats_count INT,
    id_acteur INT NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: zone_geographique
CREATE TABLE zone_geographique (
    id_zone SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    perimetre GEOGRAPHY(POLYGON),
    id_acteur INT,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Trigger to ensure message_destinataire only references one-to-one messages
CREATE OR REPLACE FUNCTION check_message_destinataire_one_to_one()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM message m
        WHERE m.id_message = NEW.id_message
        AND m.est_groupe = FALSE
    ) THEN
        RAISE EXCEPTION 'message_destinataire can only reference one-to-one messages (est_groupe = FALSE)';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_message_destinataire_one_to_one
BEFORE INSERT OR UPDATE ON message_destinataire
FOR EACH ROW
EXECUTE FUNCTION check_message_destinataire_one_to_one();

-- Trigger to ensure post creator is admin or allowed user type
CREATE OR REPLACE FUNCTION check_post_creator()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM acteur a
        LEFT JOIN utilisateur u ON a.id_acteur = u.id_acteur
        WHERE a.id_acteur = NEW.id_acteur
        AND (a.type_acteur = 'admin' OR u.type_utilisateur IN ('donateur', 'beneficiaire'))
    ) THEN
        RAISE EXCEPTION 'Post creator must be an admin or a donateur/beneficiaire user';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_post_creator
BEFORE INSERT OR UPDATE ON post
FOR EACH ROW
EXECUTE FUNCTION check_post_creator();

-- Trigger to enforce post address rules
CREATE OR REPLACE FUNCTION check_post_adresse_utilisateur()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.adresse_utilisateur IS NULL AND EXISTS (
        SELECT 1 FROM acteur a WHERE a.id_acteur = NEW.id_acteur AND a.type_acteur = 'admin'
    )) OR
       (NEW.adresse_utilisateur IS NOT NULL AND EXISTS (
        SELECT 1 FROM utilisateur u WHERE u.id_acteur = NEW.id_acteur AND u.type_utilisateur IN ('donateur', 'beneficiaire')
    )) OR
       (NEW.adresse_utilisateur IS NULL AND EXISTS (
        SELECT 1 FROM utilisateur u WHERE u.id_acteur = NEW.id_acteur AND u.type_utilisateur = 'association'
    )) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Invalid adresse_utilisateur for post creator type';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_post_adresse_utilisateur
BEFORE INSERT OR UPDATE ON post
FOR EACH ROW
EXECUTE FUNCTION check_post_adresse_utilisateur();

-- Trigger to ensure zakat donations are financial
CREATE OR REPLACE FUNCTION check_zakat_don_type()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM don
        WHERE don.id_don = NEW.id_don
        AND don.type_don = 'financier'
    ) THEN
        RAISE EXCEPTION 'Zakat must reference a financial donation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_zakat_don_type
BEFORE INSERT OR UPDATE ON zakat
FOR EACH ROW
EXECUTE FUNCTION check_zakat_don_type();

-- Trigger to ensure group creator is added as admin
CREATE OR REPLACE FUNCTION add_creator_to_group()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO membre_conversation (id_conversation, id_acteur, date_ajout, role)
    VALUES (NEW.id_conversation, NEW.id_createur, NOW(), 'admin');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_creator_to_group
AFTER INSERT ON conversation_groupe
FOR EACH ROW
EXECUTE FUNCTION add_creator_to_group();

-- Trigger to check post keywords on delete
CREATE OR REPLACE FUNCTION check_post_mot_cle_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM post_mot_cle
        WHERE post_mot_cle.id_post = OLD.id_post
    ) THEN
        RAISE EXCEPTION 'Un post doit conserver au moins un mot-clé';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_post_mot_cle_on_delete
BEFORE DELETE ON post_mot_cle
FOR EACH ROW
EXECUTE FUNCTION check_post_mot_cle_on_delete();

-- Function to calculate zakat
CREATE OR REPLACE FUNCTION calculer_zakat(id_donateur_param INT)
RETURNS FLOAT AS $$
DECLARE
    total_biens FLOAT := 0;
    seuil FLOAT;
    taux FLOAT;
    zakat_due FLOAT := 0;
BEGIN
    SELECT COALESCE(SUM(valeur), 0) INTO total_biens
    FROM bien_zakat
    WHERE id_donateur = id_donateur_param;
    
    SELECT seuil_nisab, taux_zakat INTO seuil, taux
    FROM parametre_zakat
    WHERE devise = 'DZD' AND annee = EXTRACT(YEAR FROM CURRENT_DATE);
    
    IF total_biens >= seuil THEN
        zakat_due := total_biens * taux;
    END IF;
    
    RETURN zakat_due;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate distance between points
CREATE OR REPLACE FUNCTION distance_entre_points(point1 GEOGRAPHY, point2 GEOGRAPHY) 
RETURNS FLOAT AS $$
BEGIN
    RETURN ST_Distance(point1, point2);
END;
$$ LANGUAGE plpgsql;

-- Function to update platform statistics
CREATE OR REPLACE FUNCTION update_statistiques_quotidiennes()
RETURNS VOID AS $$
BEGIN
    INSERT INTO statistique_plateforme (
        date_statistique,
        nb_utilisateurs_actifs,
        nb_posts_publies,
        nb_dons_effectues,
        montant_total_dons,
        nb_campagnes_actives
    )
    VALUES (
        CURRENT_DATE,
        (SELECT COUNT(*) FROM acteur WHERE id_acteur IN (SELECT id_acteur FROM historique WHERE date > CURRENT_DATE - INTERVAL '30 days')),
        (SELECT COUNT(*) FROM post WHERE date_limite > CURRENT_DATE OR date_limite IS NULL),
        (SELECT COUNT(*) FROM don WHERE date_don > CURRENT_DATE - INTERVAL '30 days'),
        (SELECT COALESCE(SUM(montant), 0) FROM don WHERE date_don > CURRENT_DATE - INTERVAL '30 days'),
        (SELECT COUNT(*) FROM campagne WHERE etat_campagne = 'enCours')
    );
END;
$$ LANGUAGE plpgsql;

-- Triggers for updating average ratings
CREATE OR REPLACE FUNCTION update_acteur_note_moyenne()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE acteur
    SET note_moyenne = (
        SELECT COALESCE(AVG(note), 0.0)
        FROM note
        WHERE note.id_profile = acteur.id_profile
    )
    WHERE acteur.id_profile = NEW.id_profile;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_acteur_note_moyenne
AFTER INSERT OR UPDATE ON note
FOR EACH ROW
WHEN (NEW.id_profile IS NOT NULL)
EXECUTE FUNCTION update_acteur_note_moyenne();

CREATE OR REPLACE FUNCTION update_post_note_moyenne()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE post
    SET note_moyenne = (
        SELECT COALESCE(AVG(note), 0.0)
        FROM note
        WHERE note.id_post = post.id_post
    )
    WHERE post.id_post = NEW.id_post;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_post_note_moyenne
AFTER INSERT OR UPDATE ON note
FOR EACH ROW
WHEN (NEW.id_post IS NOT NULL)
EXECUTE FUNCTION update_post_note_moyenne();

CREATE OR REPLACE FUNCTION update_campagne_note_moyenne()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE post
    SET note_moyenne = (
        SELECT COALESCE(AVG(note), 0.0)
        FROM note
        WHERE note.id_campagne = post.id_post
    )
    WHERE post.id_post = NEW.id_campagne;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_campagne_note_moyenne
AFTER INSERT OR UPDATE ON note
FOR EACH ROW
WHEN (NEW.id_campagne IS NOT NULL)
EXECUTE FUNCTION update_campagne_note_moyenne();

-- Indexes for performance
CREATE INDEX idx_acteur_id_profile ON acteur(id_profile);
CREATE INDEX idx_utilisateur_id_acteur ON utilisateur(id_acteur);
CREATE INDEX idx_post_id_acteur ON post(id_acteur);
CREATE INDEX idx_don_id_donateur ON don(id_donateur);
CREATE INDEX idx_don_id_campagne ON don(id_campagne);
CREATE INDEX idx_don_id_beneficiaire ON don(id_beneficiaire);
CREATE INDEX idx_notification_id_acteur ON notification(id_acteur);
CREATE INDEX idx_utilisateur_suivi_id_suiveur ON utilisateur_suivi(id_suiveur);
CREATE INDEX idx_utilisateur_suivi_id_suivi ON utilisateur_suivi(id_suivi);
CREATE INDEX idx_campagne_suivi_id_campagne ON campagne_suivi(id_campagne);
CREATE INDEX idx_participants_campagne_id_utilisateur ON participants_campagne(id_utilisateur);
CREATE INDEX idx_post_mot_cle_id_post ON post_mot_cle(id_post);
CREATE INDEX idx_post_mot_cle_id_mot_cle ON post_mot_cle(id_mot_cle);
CREATE INDEX idx_message_id_conversation ON message(id_conversation);
CREATE INDEX idx_message_destinataire_id_message ON message_destinataire(id_message);
CREATE INDEX idx_post_fulltext ON post USING GIN (to_tsvector('french', titre || ' ' || description));

-- Step 1: Create a historique record first (required for dashboard)
INSERT INTO historique (date, action, details)
VALUES (NOW(), 'Creation manuelle', 'Creation manuelle d''un compte admin');

-- Step 2: Create a dashboard record
INSERT INTO dashboard (id_historique)
VALUES (1);  -- This assumes it's the first historique record

-- Step 3: Create a profile record
INSERT INTO profile (photo_url, bio, id_dashboard)
VALUES (
    'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile.jpg', 
    'Administrateur de la plateforme',
    1  -- Assuming it's the first dashboard record
);

-- Step 4: Create the acteur record
INSERT INTO acteur (
    id_acteur,
    type_acteur,
    email,
    mot_de_passe,
    id_profile,
    supabase_user_id
)
VALUES (
    1,  -- Setting id_acteur to 1 as requested
    'admin',
    'mazalkayenelkhir@gmail.com',
    'AdminSecure123',  -- Note: In a real application, you should hash this password
    1,  -- Assuming it's the first profile record
    uuid_generate_v4()  -- Generate a UUID for supabase_user_id
);

-- Step 5: Update the historique record with the actor id
UPDATE historique
SET id_acteur = 1
WHERE id_historique = 1;

-- Step 6: Create the admin record
INSERT INTO admin (
    id_acteur,
    nom_admin,
    prenom_admin
)
VALUES (
    1,  -- The same id_acteur as created above
    'Administrateur ',
    'Mazal kayen El Khir'
);

UPDATE acteur
SET supabase_user_id = '' /*here i updated it's value from the Users table fou*/
WHERE id_acteur = 1;

-- Begin transaction
BEGIN;

-- 1. Create dashboard and profile records for each actor with explicit IDs
INSERT INTO historique (id_historique, date, action, details)
VALUES 
    (2, NOW(), 'Creation', 'Creation of Dzair El Khir Association'),
    (3, NOW(), 'Creation', 'Creation of Yennayer Association'),
    (4, NOW(), 'Creation', 'Creation of Karima Donor Profile'),
    (5, NOW(), 'Creation', 'Creation of Manel Beneficiary Profile'),
    (6, NOW(), 'Creation', 'Creation of Orphan Beneficiary Profile');

-- Set the sequences to continue after our manual inserts
SELECT setval('historique_id_historique_seq', 6);

INSERT INTO dashboard (id_dashboard, id_historique)
VALUES 
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6);

-- Set the sequence to continue after our manual inserts
SELECT setval('dashboard_id_dashboard_seq', 6);
-- Create profiles with explicit IDs
INSERT INTO profile (id_profile, photo_url, bio, id_dashboard)
VALUES 
    (2, 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile2.jpg', 'Association caritative qui aide les plus démunis en Algérie depuis 2010.', 2),
    (3, 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile3.jpg', 'Association culturelle amazighe qui promeut la culture et les traditions berbères.', 3),
    (4, 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile4.jpg', 'Donatrice régulière passionnée par l''aide aux enfants et aux femmes en difficulté.', 4),
    (5, 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile5.jpg', 'Mère célibataire en recherche d''emploi avec deux enfants à charge.', 5),
    (6, 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/profile//profile6.jpg', 'Orphelin qui a besoin de soutien pour ses études et son quotidien.', 6);

-- Set the sequence to continue after our manual inserts
SELECT setval('profile_id_profile_seq', 6);

-- 2. Create acteur records with clear passwords (commented) and properly hashed passwords
-- Clear passwords for reference:
-- Dzair El Khir: DzairElKhir2024!
-- Yennayer: Yennayer2024!
-- Karima: Karima40Ans!
-- Manel: Manel34Ans!
-- Orphelin: Orphelin2024!

INSERT INTO acteur (id_acteur, type_acteur, email, mot_de_passe, id_profile)
VALUES 
    (2, 'utilisateur', 'contact@dzairelkhir.org', '$2a$10$WsYgGkJxfxVu8.H5U4GeA.N1.Rwq5XCBCe1Muc2lZeRu4A0k4oqWa', 2),
    (3, 'utilisateur', 'yennayer.association@gmail.com', '$2a$10$qvT5XgF7jS1qm2NJi2tL8.RiUhU2cL.q5YSE5EJzPvt0JvZ8RyGsi', 3),
    (4, 'utilisateur', 'karima.benali@gmail.com', '$2a$10$L1LwF3OcSoNjTmRl5d5YaeFoTyKTAKQzhDXnS1r4V4ZPB5HpNa3QK', 4),
    (5, 'utilisateur', 'manel.hadj@hotmail.com', '$2a$10$8NqS3sPZAZN1Wo8bVRdm1.aQRGDOiJC0kEcFNPSuq1Sz.3W2QhWmi', 5),
    (6, 'utilisateur', 'orphelin.aid@gmail.com', '$2a$10$k2xTCQjdmf18s3FJ1PVNRuBfJxBKRIjftC20kV1.5gzNDvg5Q0G9e', 6);

-- Set the sequence to continue after our manual inserts
SELECT setval('acteur_id_acteur_seq', 6);

-- Helper function to generate a random point in Algeria
CREATE OR REPLACE FUNCTION random_algerian_point() 
RETURNS GEOGRAPHY AS $$
DECLARE
    -- Approximate geographic bounds of Algeria
    min_lat FLOAT := 19.0;  -- Southern bound
    max_lat FLOAT := 37.0;  -- Northern bound
    min_lon FLOAT := -8.7;  -- Western bound
    max_lon FLOAT := 12.0;  -- Eastern bound
    
    rand_lat FLOAT;
    rand_lon FLOAT;
BEGIN
    -- Generate random coordinates within Algeria's bounds
    rand_lat := min_lat + (max_lat - min_lat) * random();
    rand_lon := min_lon + (max_lon - min_lon) * random();
    
    -- Return as GEOGRAPHY point
    RETURN ST_SetSRID(ST_MakePoint(rand_lon, rand_lat), 4326)::GEOGRAPHY;
END;
$$ LANGUAGE plpgsql;

-- 3. Create utilisateur records with type details
INSERT INTO utilisateur (id_acteur, type_utilisateur, telephone, adresse_utilisateur, num_carte_identite)
VALUES 
    (2, 'association', '+213558990011', random_algerian_point(), NULL),
    (3, 'association', '+213661234567', random_algerian_point(), NULL),
    (4, 'donateur', '+213795551122', random_algerian_point(), '123456789012345'),
    (5, 'beneficiaire', '+213662335577', random_algerian_point(), '987654321098765'),
    (6, 'beneficiaire', '+213699887766', random_algerian_point(), '543216789054321');

-- 4. Create associations
INSERT INTO association (id_acteur, nom_association, document_authorisation, statut_validation)
VALUES 
    (2, 'Dzair El Khir', 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/association-documents//2_document_autorisation.pdf', TRUE), 
    (3, 'Association Yennayer', 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/association-documents//3_document_autorisation.png', TRUE);

-- 5. Create donateur record for Karima
INSERT INTO donateur (id_acteur, nom, prenom)
VALUES (4, 'Benali', 'Karima');

-- 6. Create beneficiaire records
INSERT INTO beneficiaire (id_acteur, nom, prenom, document_situation, type_beneficiaire)
VALUES 
    (5, 'Hadj', 'Manel', 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/situation//situation5.jpeg', 'femmeDivorcee'),
    (6, 'Saidi', 'Sofiane', 'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/situation//situation6.jpeg', 'orphelin');

-- Update historique with actor IDs
UPDATE historique 
SET id_acteur = 2
WHERE id_historique = 2;

UPDATE historique 
SET id_acteur = 3
WHERE id_historique = 3;

UPDATE historique 
SET id_acteur = 4
WHERE id_historique = 4;

UPDATE historique 
SET id_acteur = 5
WHERE id_historique = 5;

UPDATE historique 
SET id_acteur = 6
WHERE id_historique = 6;

-- Commit transaction
COMMIT;

-- Optional: Drop the helper function if no longer needed
DROP FUNCTION IF EXISTS random_algerian_point();

-- Begin transaction
BEGIN;

-- 1. Create posts for Karima, Manel, and Sofiane
INSERT INTO post (
    id_post,
    titre,
    description,
    type_post,
    image,
    date_limite,
    adresse_utilisateur,
    note_moyenne,
    id_acteur,
    id_don
) VALUES 
    -- Karima (id_post=1, donateur): Offering children's winter clothes
    (
        1,
        'Don de Vêtements d’Hiver pour Enfants',
        'Je donne les vêtements d’hiver de mes enfants qui ont grandi. Ils sont en bon état et parfaits pour les enfants dans le besoin cet hiver. Contactez-moi pour organiser la collecte à Alger.',
        'invite',
        'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/post//post_1.jpg',
        NULL,
        (SELECT adresse_utilisateur FROM utilisateur WHERE id_acteur = 4),
        0.0,
        4,
        NULL
    ),
    -- Manel (id_post=2, beneficiaire): Requesting help
    (
        2,
        'Aide pour une Mère Célibataire',
        'Je suis une mère célibataire avec deux enfants. J’ai besoin d’aide pour payer le loyer et acheter des fournitures scolaires. Toute contribution est la bienvenue.',
        'demande',
        'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/post//post_2.png',
        NULL,
        (SELECT adresse_utilisateur FROM utilisateur WHERE id_acteur = 5),
        0.0,
        5,
        NULL
    ),
    -- Sofiane (id_post=3, beneficiaire): Requesting educational support
    (
        3,
        'Soutien pour Mes Études',
        'Je suis orphelin et j’aimerais poursuivre mes études secondaires. J’ai besoin de fournitures scolaires et d’un soutien financier pour les frais de scolarité.',
        'demande',
        'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/post//post_3.jpg',
        '2025-12-31 23:59:59',
        (SELECT adresse_utilisateur FROM utilisateur WHERE id_acteur = 6),
        0.0,
        6,
        NULL
    );

-- Set post sequence
SELECT setval('post_id_post_seq', 3);

-- 2. Assign keywords to posts via post_mot_cle
INSERT INTO post_mot_cle (id_post, id_mot_cle)
VALUES 
    -- Post 1: Karima (Don de Vêtements d’Hiver pour Enfants)
    (1, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'sante')),
    (1, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'medicament')),
    (1, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'vetementHivers')),
    -- Post 2: Manel (Aide pour une Mère Célibataire)
    (2, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'femmes')),
    (2, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'affaire_scolaire')),
    (2, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'autre')),
    -- Post 3: Sofiane (Soutien pour Mes Études)
    (3, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'affaire_scolaire')),
    (3, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'autre'));

-- 3. Log actions in historique
INSERT INTO historique (id_historique, date, action, details, id_acteur)
VALUES 
    (7, NOW(), 'Post Creation', 'Karima created post: Don de Vêtements d’Hiver pour Enfants', 4),
    (8, NOW(), 'Post Creation', 'Manel created post: Aide pour une Mère Célibataire', 5),
    (9, NOW(), 'Post Creation', 'Sofiane created post: Soutien pour Mes Études', 6),
    (10, NOW(), 'Keyword Assignment', 'Assigned keywords to post: Don de Vêtements d’Hiver pour Enfants', 4),
    (11, NOW(), 'Keyword Assignment', 'Assigned keywords to post: Aide pour une Mère Célibataire', 5),
    (12, NOW(), 'Keyword Assignment', 'Assigned keywords to post: Soutien pour Mes Études', 6);

-- Set historique sequence
SELECT setval('historique_id_historique_seq', 12);

-- Commit transaction
COMMIT;

 -- Begin transaction
BEGIN;

-- 1. Modify trigger_check_post_creator to allow association
CREATE OR REPLACE FUNCTION check_post_creator()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM acteur a
        LEFT JOIN utilisateur u ON a.id_acteur = u.id_acteur
        WHERE a.id_acteur = NEW.id_acteur
        AND (a.type_acteur = 'admin' OR u.type_utilisateur IN ('donateur', 'beneficiaire', 'association'))
    ) THEN
        RAISE EXCEPTION 'Post creator must be an admin, donateur, beneficiaire, or association';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Re-attach the modified trigger
DROP TRIGGER IF EXISTS trigger_check_post_creator ON post;
CREATE TRIGGER trigger_check_post_creator
BEFORE INSERT OR UPDATE ON post
FOR EACH ROW
EXECUTE FUNCTION check_post_creator();

-- 2. Create posts for campaigns
INSERT INTO post (
    id_post,
    titre,
    description,
    type_post,
    image,
    date_limite,
    adresse_utilisateur,
    note_moyenne,
    id_acteur,
    id_don
) VALUES 
    -- Dzair El Khir Campaign (id_post=4)
    (
        4,
        'Campagne Hivernale pour les Démunis',
        'Dzair El Khir organise une collecte de couvertures, chauffages et vêtements chauds pour les familles démunies à Alger cet hiver. Rejoignez-nous pour apporter chaleur et confort !',
        'campagne',
        'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/campagne//campagne_4.png',
        '2025-12-31 23:59:59',
        NULL, -- Valid for association
        0.0,
        2, -- Dzair El Khir
        NULL
    ),
    -- Yennayer Campaign (id_post=5)
    (
        5,
        'Célébration de Yennayer 2976',
        'L’Association Yennayer invite à célébrer Yennayer 2976 avec des spectacles culturels, ateliers et conférences sur la culture amazighe. Événement à Tizi Ouzou.',
        'campagne',
        'https://eouymrxocetlfxyyibou.supabase.co/storage/v1/object/public/campagne//campagne_5.png',
        '2026-01-15 23:59:59',
        NULL,
        0.0,
        3, -- Yennayer
        NULL
    );

-- Set post sequence
SELECT setval('post_id_post_seq', 5);

-- 3. Create campaigns
INSERT INTO campagne (
    id_campagne,
    etat_campagne,
    date_debut,
    date_fin,
    lieu_evenement,
    type_campagne,
    montant_objectif,
    montant_recolte,
    nombre_participants,
    id_association
) VALUES 
    -- Dzair El Khir (id_campagne=4)
    (
        4,
        'enCours',
        '2025-05-15 00:00:00',
        '2025-12-31 23:59:59',
        (SELECT adresse_utilisateur FROM utilisateur WHERE id_acteur = 2),
        'collecte',
        500000.0, -- 500,000 DZD
        0.0,
        0,
        2
    ),
    -- Yennayer (id_campagne=5)
    (
        5,
        'enCours',
        '2026-01-01 00:00:00',
        '2026-01-15 23:59:59',
        (SELECT adresse_utilisateur FROM utilisateur WHERE id_acteur = 3),
        'evenement',
        200000.0, -- 200,000 DZD
        0.0,
        0,
        3
    );

-- 4. Assign keywords to campaigns via post_mot_cle
INSERT INTO post_mot_cle (id_post, id_mot_cle)
VALUES 
    -- Dzair El Khir Campaign (id_post=4)
    (4, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'hiver')),
    (4, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'sante')),

    -- Yennayer Campaign (id_post=5)
    (5, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'yennayer')),
    (5, (SELECT id_mot_cle FROM mot_cle WHERE nom = 'autre'));

-- 5. Log actions in historique
INSERT INTO historique (id_historique, date, action, details, id_acteur)
VALUES 
    (13, NOW(), 'Campaign Post Creation', 'Dzair El Khir created post for campaign: Campagne Hivernale pour les Démunis', 2),
    (14, NOW(), 'Campaign Creation', 'Dzair El Khir created campaign: Campagne Hivernale pour les Démunis', 2),
    (15, NOW(), 'Keyword Assignment', 'Dzair El Khir assigned keywords to campaign post: Campagne Hivernale pour les Démunis', 2),
    (16, NOW(), 'Campaign Post Creation', 'Yennayer created post for campaign: Célébration de Yennayer 2976', 3),
    (17, NOW(), 'Campaign Creation', 'Yennayer created campaign: Célébration de Yennayer 2976', 3),
    (18, NOW(), 'Keyword Assignment', 'Yennayer assigned keywords to campaign post: Célébration de Yennayer 2976', 3);

-- Set historique sequence
SELECT setval('historique_id_historique_seq', 18);

-- Commit transaction
COMMIT;  

-- Modify don table to add expiration and CVV, with constraints
-- 1. First add new nullable columns without constraints
ALTER TABLE don
ADD COLUMN date_expiration VARCHAR(5),
ADD COLUMN cvv VARCHAR(3);

-- 2. Update existing financial donations with dummy values (temporarily)
UPDATE don SET 
    date_expiration = '12/30',
    cvv = '123',
    num_carte_bancaire = '4111111111111111'
WHERE type_don = 'financier' 
AND (num_carte_bancaire IS NULL OR date_expiration IS NULL OR cvv IS NULL);

-- 3. Now add the constraints
ALTER TABLE don
ALTER COLUMN num_carte_bancaire TYPE VARCHAR(16),
ADD CONSTRAINT chk_credit_card_format CHECK (num_carte_bancaire ~ '^[0-9]{16}$'),
ALTER COLUMN date_expiration SET NOT NULL,
ALTER COLUMN cvv SET NOT NULL,
ADD CONSTRAINT chk_date_expiration_format CHECK (date_expiration ~ '^(0[1-9]|1[0-2])/[0-9]{2}$'),
ADD CONSTRAINT chk_cvv_format CHECK (cvv ~ '^[0-9]{3}$'),
ADD CONSTRAINT chk_financial_don_requirements CHECK (
    (type_don = 'financier' AND 
    num_carte_bancaire IS NOT NULL AND
    date_expiration IS NOT NULL AND
    cvv IS NOT NULL) OR
    (type_don <> 'financier')
);

-- 4. Finally add the trigger
CREATE OR REPLACE FUNCTION validate_card_expiration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type_don = 'financier' THEN
        IF TO_DATE(NEW.date_expiration, 'MM/YY') < CURRENT_DATE THEN
            RAISE EXCEPTION 'Carte expirée';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_card_expiration
BEFORE INSERT OR UPDATE ON don
FOR EACH ROW
EXECUTE FUNCTION validate_card_expiration();

INSERT INTO don (id_don, num_carte_bancaire, montant, date_don, type_don, etat_don, id_donateur, id_campagne)
VALUES (1, '1234567890123456', 10000.0, NOW(), 'financier', 'valide', 4, 4);

ALTER TABLE post 
ALTER COLUMN note_moyenne TYPE double precision;

CREATE POLICY "Allow all" ON public.post 
FOR SELECT 
USING (true);

CREATE POLICY "Enable read access" ON public.campagne 
AS PERMISSIVE FOR SELECT
TO public
USING (true);