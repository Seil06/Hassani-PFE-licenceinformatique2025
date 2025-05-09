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

-- Table: Profile
CREATE TABLE profile (
    id_profile SERIAL PRIMARY KEY,
    photo_url TEXT,
    bio TEXT
);

-- Table: Dashboard
CREATE TABLE dashboard (
    id_dashboard SERIAL PRIMARY KEY,
    id_historique INT
);

-- Table: Acteur 
CREATE TABLE acteur (
    id_acteur SERIAL PRIMARY KEY,
    type_acteur VARCHAR(50) NOT NULL CHECK (type_acteur IN ('admin', 'utilisateur')),
    email VARCHAR(255) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    id_profile INT NOT NULL,
    id_dashboard INT NOT NULL,
    note_moyenne FLOAT DEFAULT 0.0 CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES profile(id_profile),
    CONSTRAINT fk_dashboard FOREIGN KEY (id_dashboard) REFERENCES dashboard(id_dashboard)
);

-- Table: Historique (maintenant qu'acteur existe)
CREATE TABLE historique (
    id_historique SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    action VARCHAR(255) NOT NULL,
    details TEXT NOT NULL,
    id_acteur INT,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);

-- Ajout de la contrainte de clé étrangère à dashboard
ALTER TABLE dashboard
ADD CONSTRAINT fk_historique FOREIGN KEY (id_historique) REFERENCES historique(id_historique);

-- Table: Utilisateur
CREATE TABLE utilisateur (
    id_acteur INT PRIMARY KEY,
    type_utilisateur VARCHAR(50) NOT NULL CHECK (type_utilisateur IN ('donateur', 'association', 'beneficiaire')),
    telephone VARCHAR(20),
    adresse TEXT,
    location GEOGRAPHY(POINT),
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
    type_beneficiaire VARCHAR(50) NOT NULL CHECK (type_beneficiaire IN ('pauvre', 'sdf', 'orphelin', 'enfantMalade', 'personneAgee', 'malade', 'handicape', 'femmeDivorcee', 'femmeSeule', 'femmeVeuve', 'autre')),
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES utilisateur(id_acteur)
);

-- Table: Post
CREATE TABLE post (
    id_post SERIAL PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    type_post VARCHAR(50) NOT NULL CHECK (type_post IN ('officiel', 'offre', 'demande', 'campagne')),
    type_don VARCHAR(50) NOT NULL CHECK (type_don IN ('financier', 'materiel', 'alimentaire', 'medicament', 'benevolat', 'service', 'autre')),
    image TEXT,
    video TEXT,
    lieu_acteur TEXT NOT NULL,
    date_limite TIMESTAMP,
    location GEOGRAPHY(POINT),
    note_moyenne FLOAT DEFAULT 0.0 CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    id_acteur INT NOT NULL,
    id_dashboard INT NOT NULL,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur),
    CONSTRAINT fk_dashboard FOREIGN KEY (id_dashboard) REFERENCES dashboard(id_dashboard)
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
    date_debut TIMESTAMP,
    date_fin TIMESTAMP,
    lieu_evenement TEXT,
    type_campagne VARCHAR(50) NOT NULL CHECK (type_campagne IN ('evenement', 'volontariat', 'sensibilisation', 'collecte')),
    montant_objectif FLOAT DEFAULT 0.0 CHECK (montant_objectif >= 0),
    montant_recolte FLOAT DEFAULT 0.0 CHECK (montant_recolte >= 0),
    nombre_participants INT DEFAULT 0,
    id_association INT NOT NULL,
    CONSTRAINT fk_post FOREIGN KEY (id_campagne) REFERENCES post(id_post),
    CONSTRAINT fk_association FOREIGN KEY (id_association) REFERENCES association(id_acteur)
);

-- Table: Zakat (créée d'abord sans la référence à don)
CREATE TABLE zakat (
    id_zakat SERIAL PRIMARY KEY,
    montant FLOAT NOT NULL CHECK (montant >= 0),
    date TIMESTAMP NOT NULL,
    id_donateur INT NOT NULL,
    CONSTRAINT fk_donateur FOREIGN KEY (id_donateur) REFERENCES donateur(id_acteur)
);

-- Table: Don
CREATE TABLE don (
    id_don SERIAL PRIMARY KEY,
    num_carte_bancaire VARCHAR(16),
    montant FLOAT CHECK (montant >= 0),
    date_don TIMESTAMP NOT NULL,
    type_don VARCHAR(50) NOT NULL CHECK (type_don IN ('financier', 'materiel', 'alimentaire', 'medicament', 'benevolat', 'service', 'autre')),
    etat_don VARCHAR(50) NOT NULL CHECK (etat_don IN ('enAttente', 'valide', 'refuse', 'enCours', 'termine')),
    id_donateur INT NOT NULL,
    id_campagne INT,
    id_beneficiaire INT,
    id_post INT,
    id_zakat INT,
    CONSTRAINT fk_donateur FOREIGN KEY (id_donateur) REFERENCES donateur(id_acteur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT fk_beneficiaire FOREIGN KEY (id_beneficiaire) REFERENCES beneficiaire(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_zakat FOREIGN KEY (id_zakat) REFERENCES zakat(id_zakat)
);

-- Ajout de la clé étrangère id_don dans zakat
ALTER TABLE zakat
ADD COLUMN id_don INT,
ADD CONSTRAINT fk_don FOREIGN KEY (id_don) REFERENCES don(id_don);

-- Table: Notification
CREATE TABLE notification (
    id_notification SERIAL PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    contenu TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    type_notification VARCHAR(50) NOT NULL CHECK (type_notification IN ('nouveau_post', 'nouvelle_campagne', 'avertissement', 'message', 'autre')),
    id_acteur INT NOT NULL,
    id_dashboard INT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_acteur FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur),
    CONSTRAINT fk_dashboard FOREIGN KEY (id_dashboard) REFERENCES dashboard(id_dashboard)
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
    id_profile INT,
    id_campagne INT,
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_profile FOREIGN KEY (id_profile) REFERENCES profile(id_profile),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT unique_like UNIQUE (id_utilisateur, id_post, id_profile, id_campagne),
    CONSTRAINT check_like_target CHECK (
        (id_post IS NOT NULL AND id_profile IS NULL AND id_campagne IS NULL) OR
        (id_post IS NULL AND id_profile IS NOT NULL AND id_campagne IS NULL) OR
        (id_post IS NULL AND id_profile IS NULL AND id_campagne IS NOT NULL)
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

-- Table: Message
CREATE TABLE message (
    id_message SERIAL PRIMARY KEY,
    contenu TEXT NOT NULL,
    date_envoi TIMESTAMP NOT NULL,
    id_expediteur INT NOT NULL,
    est_groupe BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_expediteur FOREIGN KEY (id_expediteur) REFERENCES acteur(id_acteur)
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

-- Table de jointure: post_suivi (N:N entre Post et Utilisateur)
CREATE TABLE post_suivi (
    id_post INT NOT NULL,
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_post, id_utilisateur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table de jointure: campagne_suivi (N:N entre Campagne et Utilisateur)
CREATE TABLE campagne_suivi (
    id_campagne INT NOT NULL,
    id_utilisateur INT NOT NULL,
    PRIMARY KEY (id_campagne, id_utilisateur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne),
    CONSTRAINT fk_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur)
);

-- Table participants associated with posts
CREATE TABLE participants_post (
    id_utilisateur INT NOT NULL,
    id_post INT NOT NULL,
    PRIMARY KEY (id_utilisateur, id_post),
    CONSTRAINT fk_utilisateur_post FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_post FOREIGN KEY (id_post) REFERENCES post(id_post)
);

-- Table participants associated with campaigns
CREATE TABLE participants_campagne (
    id_utilisateur INT NOT NULL,
    id_campagne INT NOT NULL,
    PRIMARY KEY (id_utilisateur, id_campagne),
    CONSTRAINT fk_utilisateur_campagne FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_acteur),
    CONSTRAINT fk_campagne FOREIGN KEY (id_campagne) REFERENCES campagne(id_campagne)
);

-- Table de jointure: message_destinataire (N:N entre Message et Acteur)
CREATE TABLE message_destinataire (
    id_message INT NOT NULL,
    id_destinataire INT NOT NULL,
    PRIMARY KEY (id_message, id_destinataire),
    CONSTRAINT fk_message FOREIGN KEY (id_message) REFERENCES message(id_message),
    CONSTRAINT fk_destinataire FOREIGN KEY (id_destinataire) REFERENCES acteur(id_acteur)
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

-- Index pour améliorer les performances
CREATE INDEX idx_acteur_id_profile ON acteur(id_profile);
CREATE INDEX idx_acteur_id_dashboard ON acteur(id_dashboard);
CREATE INDEX idx_utilisateur_id_acteur ON utilisateur(id_acteur);
CREATE INDEX idx_post_id_acteur ON post(id_acteur);
CREATE INDEX idx_post_id_dashboard ON post(id_dashboard);
CREATE INDEX idx_don_id_donateur ON don(id_donateur);
CREATE INDEX idx_don_id_campagne ON don(id_campagne);
CREATE INDEX idx_don_id_beneficiaire ON don(id_beneficiaire);
CREATE INDEX idx_notification_id_acteur ON notification(id_acteur);
CREATE INDEX idx_utilisateur_suivi_id_suiveur ON utilisateur_suivi(id_suiveur);
CREATE INDEX idx_utilisateur_suivi_id_suivi ON utilisateur_suivi(id_suivi);
CREATE INDEX idx_post_suivi_id_post ON post_suivi(id_post);
CREATE INDEX idx_campagne_suivi_id_campagne ON campagne_suivi(id_campagne);
CREATE INDEX idx_participants_id_utilisateur ON participants(id_utilisateur);
CREATE INDEX idx_post_mot_cle_id_post ON post_mot_cle(id_post);
CREATE INDEX idx_post_mot_cle_id_mot_cle ON post_mot_cle(id_mot_cle);

-- Trigger pour mettre à jour note_moyenne dans acteur
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

-- Trigger pour mettre à jour note_moyenne dans post
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

-- Trigger pour mettre à jour note_moyenne dans post (pour campagne)
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

-- Trigger pour garantir qu'un post a au moins un mot-clé
CREATE OR REPLACE FUNCTION check_post_mot_cle()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM post_mot_cle
        WHERE post_mot_cle.id_post = NEW.id_post
    ) THEN
        RAISE EXCEPTION 'Un post doit avoir au moins un mot-clé';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_post_mot_cle
AFTER INSERT ON post
FOR EACH ROW
EXECUTE FUNCTION check_post_mot_cle();
