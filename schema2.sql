
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

INSERT INTO don (id_don, num_carte_bancaire, montant, date_don, type_don, etat_don, id_donateur, id_campagne)
VALUES (1, '1234567890123456', 10000.0, NOW(), 'financier', 'valide', 4, 4);


CREATE OR REPLACE FUNCTION create_user_with_transaction(
  p_email TEXT,
  p_hashed_password TEXT,
  p_user_id UUID,
  p_user_type TEXT,
  p_nom TEXT,
  p_prenom TEXT,
  p_num_carte_identite TEXT,
  p_nom_association TEXT,
  p_type_beneficiaire TEXT
) RETURNS VOID AS $$
DECLARE
  v_historique_id INTEGER;
  v_dashboard_id INTEGER;
  v_profile_id INTEGER;
  v_acteur_id INTEGER;
BEGIN
  -- Début de la transaction
  BEGIN
    -- Insérer dans 'historique'
    INSERT INTO historique (date, action, details)
    VALUES (NOW(), 'Compte créé', 'Création d’un nouveau compte utilisateur')
    RETURNING id_historique INTO v_historique_id;

    -- Insérer dans 'dashboard'
    INSERT INTO dashboard (id_historique)
    VALUES (v_historique_id)
    RETURNING id_dashboard INTO v_dashboard_id;

    -- Insérer dans 'profile'
    INSERT INTO profile (id_dashboard)
    VALUES (v_dashboard_id)
    RETURNING id_profile INTO v_profile_id;

    -- Insérer dans 'acteur'
    INSERT INTO acteur (
      type_acteur, email, mot_de_passe, id_profile, supabase_user_id
    ) VALUES (
      'utilisateur', p_email, p_hashed_password, v_profile_id, p_user_id
    )
    RETURNING id_acteur INTO v_acteur_id;

    -- Mettre à jour 'historique' avec l'ID de l'acteur
    UPDATE historique SET id_acteur = v_acteur_id WHERE id_historique = v_historique_id;

    -- Insérer dans 'utilisateur'
    INSERT INTO utilisateur (
      id_acteur, type_utilisateur, num_carte_identite
    ) VALUES (
      v_acteur_id, p_user_type, p_num_carte_identite
    );

    -- Insérer dans la table spécifique (donateur/association/beneficiaire)
    CASE p_user_type
      WHEN 'donateur' THEN
        INSERT INTO donateur (id_acteur, nom, prenom)
        VALUES (v_acteur_id, p_nom, p_prenom);
      WHEN 'association' THEN
        INSERT INTO association (id_acteur, nom_association)
        VALUES (v_acteur_id, p_nom_association);
      WHEN 'beneficiaire' THEN
        INSERT INTO beneficiaire (id_acteur, nom, prenom, type_beneficiaire)
        VALUES (v_acteur_id, p_nom, p_prenom, p_type_beneficiaire);
    END CASE;

    -- Valider la transaction si tout réussit
    COMMIT;
  EXCEPTION
    WHEN others THEN
      -- Annuler la transaction en cas d'erreur
      ROLLBACK;
      RAISE;
  END;
END;
$$ LANGUAGE plpgsql;

