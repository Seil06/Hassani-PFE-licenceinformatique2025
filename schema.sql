-- Enable PostGIS extension for geographic data
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table: Mot_cle (pour représenter l'enum Mot_cles)
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

-- Table: Dashboard
CREATE TABLE dashboard (
    id_dashboard SERIAL PRIMARY KEY
);

-- Table: Profile
CREATE TABLE profile (
    id_profile SERIAL PRIMARY KEY,
    photo_url TEXT,
    bio TEXT,
    id_dashboard INT NOT NULL,
    CONSTRAINT fk_dashboard FOREIGN KEY (id_dashboard) REFERENCES dashboard(id_dashboard)
);

-- Table: Historique
CREATE TABLE historique (
    id_historique SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    action VARCHAR(255) NOT NULL,
    details TEXT NOT NULL,
    id_acteur INT -- FK sera ajoutée plus tard
);

-- Table: Acteur 
CREATE TABLE acteur (
    id_acteur SERIAL PRIMARY KEY,
    type_acteur VARCHAR(50) NOT NULL CHECK (type_acteur IN ('admin', 'utilisateur')),
    email VARCHAR(255) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    num_carte_identite VARCHAR(18) NOT NULL,
    id_profile INT NOT NULL,
    note_moyenne FLOAT DEFAULT 0.0 CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES profile(id_profile)
);

-- Ajout de la clé étrangère pour historique
ALTER TABLE historique
ADD CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur);

-- Table: Utilisateur
CREATE TABLE utilisateur (
    id_acteur INT PRIMARY KEY,
    type_utilisateur VARCHAR(50) NOT NULL CHECK (type_utilisateur IN ('donateur', 'association', 'beneficiaire')),
    telephone VARCHAR(20),
    adresse_utilisateur GEOGRAPHY(POINT) NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: Admin
CREATE TABLE admin (
    id_acteur INT PRIMARY KEY,
    nom_admin VARCHAR(100) NOT NULL,
    prenom_admin VARCHAR(100) NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: Donateur
CREATE TABLE donateur (
    id_acteur INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: Association
CREATE TABLE association (
    id_acteur INT PRIMARY KEY,
    nom_association VARCHAR(255) NOT NULL,
    document_authorisation TEXT NOT NULL,
    statut_validation BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: Beneficiaire
CREATE TABLE beneficiaire (
    id_acteur INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    document_situation TEXT NOT NULL,
    type_beneficiaire VARCHAR(50) NOT NULL CHECK (type_beneficiaire IN ('pauvre', 'sdf', 'orphelin', 'enfantMalade', 'personneAgee', 'malade', 'handicape', 'femmeDivorcee', 'femmeSeule', 'femmeVeuve', 'autre')),
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: Don 
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

-- Table: Post
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
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur),
    CONSTRAINT fk_don FOREIGN KEY (id_don) REFERENCES don(id_don),
    CONSTRAINT check_post_creator CHECK (
        EXISTS (
            SELECT 1
            FROM acteur a
            LEFT JOIN utilisateur u ON a.id_acteur = u.id_acteur
            WHERE a.id_acteur = post.id_acteur
            AND (a.type_acteur = 'admin' OR u.type_utilisateur IN ('donateur', 'beneficiaire'))
        )
    ),
    CONSTRAINT check_adresse_utilisateur CHECK (
        (adresse_utilisateur IS NULL AND EXISTS (
            SELECT 1 FROM acteur a WHERE a.id_acteur = post.id_acteur AND a.type_acteur = 'admin'
        )) OR
        (adresse_utilisateur IS NOT NULL AND EXISTS (
            SELECT 1 FROM utilisateur u WHERE u.id_acteur = post.id_acteur AND u.type_utilisateur IN ('donateur', 'beneficiaire')
        )) OR
        (adresse_utilisateur IS NULL AND EXISTS (
            SELECT 1 FROM utilisateur u WHERE u.id_acteur = post.id_acteur AND u.type_utilisateur = 'association'
        ))
    )
);

-- Table de jointure: post_mot_cle (N:N entre Post et Mot_cle)
CREATE TABLE post_mot_cle (
    id_post INT NOT NULL,
    id_mot_cle INT NOT NULL,
    PRIMARY KEY (id_post, id_mot_cle),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_mot_cle FOREIGN KEY (id_mot_cle) REFERENCES mot_cle(id_mot_cle)
);

-- Table: Campagne
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

-- Table: Zakat 
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
    ),
    CONSTRAINT check_zakat_don_type CHECK (
        EXISTS (
            SELECT 1
            FROM don
            WHERE don.id_don = zakat.id_don
            AND don.type_don = 'financier'
        )
    )
);

-- Table: Notification
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

-- Table: Note
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

-- Table: Like
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

-- Table: Commentaire
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

-- Table: Avertissement
CREATE TABLE avertissement (
    id_avertissement SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    id_admin INT NOT NULL,
    id_utilisateur INT NOT NULL,
    CONSTRAINT fk_admin FOREIGN KEY (id_admin) REFERENCES admin(id_acteur),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table: Conversation_groupe (for group chats)
CREATE TABLE conversation_groupe (
    id_conversation SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    date_creation TIMESTAMP NOT NULL DEFAULT NOW(),
    id_createur INT NOT NULL,
    CONSTRAINT fk_createur FOREIGN KEY (id_createur) REFERENCES acteur(id_acteur)
);

-- Table: Membre_conversation (members of group chats)
CREATE TABLE membre_conversation (
    id_conversation INT NOT NULL,
    id_acteur INT NOT NULL,
    date_ajout TIMESTAMP NOT NULL DEFAULT NOW(),
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'membre')),
    PRIMARY KEY (id_conversation, id_acteur),
    CONSTRAINT fk_conversation FOREIGN KEY (id_conversation) REFERENCES conversation_groupe(id_conversation),
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Table: Message
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

-- Table: Message_destinataire (for 1:1 message recipients)
CREATE TABLE message_destinataire (
    id_message INT NOT NULL,
    id_destinataire INT NOT NULL,
    PRIMARY KEY (id_message, id_destinataire),
    CONSTRAINT fk_message FOREIGN KEY (id_message) REFERENCES message(id_message),
    CONSTRAINT fk_destinataire FOREIGN KEY (id_destinataire) REFERENCES acteur(id_acteur),
    CONSTRAINT check_one_to_one CHECK (
        EXISTS (
            SELECT 1
            FROM message m
            WHERE m.id_message = message_destinataire.id_message
            AND m.est_groupe = FALSE
        )
    )
);

-- Table: PieceJointe
CREATE TABLE piece_jointe (
    id_piece_jointe SERIAL PRIMARY KEY,
    url_fichier TEXT NOT NULL,
    type_fichier VARCHAR(50) NOT NULL,
    id_message INT NOT NULL,
    CONSTRAINT fk_message FOREIGN KEY (id_message) REFERENCES message(id_message)
);

-- Table de jointure: utilisateur_suivi (N:N entre Utilisateur et Utilisateur)
CREATE TABLE utilisateur_suivi (
    id_suiveur INT NOT NULL,
    id_suivi INT NOT NULL,
    PRIMARY KEY (id_suiveur, id_suivi),
    CONSTRAINT fk_suiveur FOREIGN KEY (id_suiveur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_suivi FOREIGN KEY (id_suivi) REFERENCES utilisateur(id_acteur)
);

-- Table de jointure: campagne_suivi (N:N entre Campagne et Utilisateur)
CREATE TABLE campagne_suivi (
    id_campagne INT NOT NULL,
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_campagne, id_utilisateur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table participants associated with campaigns
CREATE TABLE participants_campagne (
    id_utilisateur INT NOT NULL,
    id_campagne INT NOT NULL,
    PRIMARY KEY (id_utilisateur, id_campagne),
    CONSTRAINT fk_utilisateur_campagne FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne)
);

-- Table de jointure: post_utilisateur_tag (N:N entre Post et Utilisateur)
CREATE TABLE post_utilisateur_tag (
    id_post INT NOT NULL,
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_post, id_utilisateur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table de jointure: don_association (N:N entre Don et Association)
CREATE TABLE don_association (
    id_don INT NOT NULL,
    id_association INT NOT NULL,
    PRIMARY KEY (id_don, id_association),
    CONSTRAINT fk_don FOREIGN KEY (id_don) REFERENCES don(id_don),
    CONSTRAINT fk_association FOREIGN KEY (id_association) REFERENCES association(id_acteur)
);

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

-- Enhanced Features
-- 1. Recherche avancée
CREATE INDEX idx_post_fulltext ON post USING GIN (to_tsvector('french', titre || ' ' || description));

CREATE TABLE historique_recherche (
    id_historique_recherche SERIAL PRIMARY KEY,
    terme_recherche TEXT NOT NULL,
    date_recherche TIMESTAMP NOT NULL DEFAULT NOW(),
    resultats_count INT,
    id_acteur INT NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- 2. Géolocalisation
CREATE OR REPLACE FUNCTION distance_entre_points(point1 GEOGRAPHY, point2 GEOGRAPHY) 
RETURNS FLOAT AS $$
BEGIN
    RETURN ST_Distance(point1, point2);
END;
$$ LANGUAGE plpgsql;

CREATE TABLE zone_geographique (
    id_zone SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    perimetre GEOGRAPHY(POLYGON),
    id_acteur INT,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- 3. Calculateur de Zakat
CREATE TABLE parametre_zakat (
    id_parametre SERIAL PRIMARY KEY,
    annee INT NOT NULL,
    seuil_nisab FLOAT NOT NULL,
    taux_zakat FLOAT NOT NULL DEFAULT 0.025,
    devise VARCHAR(10) NOT NULL DEFAULT 'DZD',
    date_mise_a_jour TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO parametre_zakat (annee, seuil_nisab, taux_zakat, devise) VALUES 
    (2024, 750000.0, 0.025, 'DZD'),
    (2024, 5000.0, 0.025, 'USD'),
    (2024, 4600.0, 0.025, 'EUR');

CREATE TABLE bien_zakat (
    id_bien_zakat SERIAL PRIMARY KEY,
    id_donateur INT NOT NULL,
    type_bien VARCHAR(50) NOT NULL CHECK (type_bien IN ('especes', 'or', 'argent', 'actions', 'marchandises', 'recoltes', 'betail', 'creances', 'autres')),
    valeur FLOAT NOT NULL,
    devise VARCHAR(10) NOT NULL DEFAULT 'DZD',
    date_ajout TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_donateur FOREIGN KEY (id_donateur) REFERENCES donateur(id_acteur)
);

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

-- 4. Organisation d'événements
CREATE TABLE rappel_evenement (
    id_rappel SERIAL PRIMARY KEY,
    id_campagne INT NOT NULL,
    date_rappel TIMESTAMP NOT NULL,
    message TEXT NOT NULL,
    envoye BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne)
);

-- 5. Système de notation détaillé
CREATE TABLE critere_notation (
    id_critere SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    poids FLOAT NOT NULL DEFAULT 1.0 CHECK (poids > 0)
);

INSERT INTO critere_notation (nom, description, poids) VALUES
    ('Fiabilité', 'Fiabilité de l''utilisateur ou du service', 1.0),
    ('Qualité', 'Qualité du service ou du produit fourni', 1.0),
    ('Communication', 'Qualité de la communication', 0.8),
    ('Ponctualité', 'Respect des délais', 0.7);

CREATE TABLE note_detaillee (
    id_note_detaillee SERIAL PRIMARY KEY,
    id_note INT NOT NULL,
    id_critere INT NOT NULL,
    valeur FLOAT NOT NULL CHECK (valeur >= 0 AND valeur <= 5),
    CONSTRAINT fk_note FOREIGN KEY (id_note) REFERENCES note(id_note),
    CONSTRAINT fk_critere FOREIGN KEY (id_critere) REFERENCES critere_notation(id_critere),
    CONSTRAINT unique_note_critere UNIQUE (id_note, id_critere)
);

-- 6. Statistiques de la plateforme
CREATE TABLE statistique_plateforme (
    id_statistique SERIAL PRIMARY KEY,
    date_statistique DATE NOT NULL DEFAULT CURRENT_DATE,
    nb_utilisateurs_actifs INT NOT NULL DEFAULT 0,
    nb_posts_publies INT NOT NULL DEFAULT 0,
    nb_dons_effectues INT NOT NULL DEFAULT 0,
    montant_total_dons FLOAT NOT NULL DEFAULT 0,
    nb_campagnes_actives INT NOT NULL DEFAULT 0
);

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

-- Index pour améliorer les performances
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

-- Triggers pour la mise à jour des notes moyennes
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

-- Trigger pour vérifier les mots-clés des posts
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