-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.commandes (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  utilisateurid bigint,
  offreid bigint,
  statut text DEFAULT 'en_attente'::text,
  prix numeric,
  notes text,
  stripesessionid text,
  datecreation timestamp with time zone DEFAULT now(),
  dateannulation timestamp with time zone,
  numero_commande text,
  datepaiement timestamp with time zone,
  CONSTRAINT commandes_pkey PRIMARY KEY (id),
  CONSTRAINT commandes_utilisateurid_fkey FOREIGN KEY (utilisateurid) REFERENCES public.utilisateurs(id),
  CONSTRAINT commandes_offreid_fkey FOREIGN KEY (offreid) REFERENCES public.offres(id)
);
CREATE TABLE public.communes_fermeture_cuivre (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  commune text NOT NULL,
  code_postal text NOT NULL,
  region text NOT NULL,
  departement text NOT NULL,
  date_fermeture_commerciale date,
  date_fermeture_technique date,
  statut text DEFAULT 'programmee'::text CHECK (statut = ANY (ARRAY['programmee'::text, 'effective'::text, 'effectuee'::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT communes_fermeture_cuivre_pkey PRIMARY KEY (id)
);
CREATE TABLE public.glossaire (
  id integer NOT NULL DEFAULT nextval('glossaire_id_seq'::regclass),
  terme text NOT NULL,
  definition text NOT NULL,
  lettre character NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT glossaire_pkey PRIMARY KEY (id)
);
CREATE TABLE public.offres (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nom text,
  prix numeric,
  description text,
  features jsonb,
  options jsonb,
  surface text DEFAULT ''::text,
  populaire boolean DEFAULT false,
  ordre integer DEFAULT 0,
  profil ARRAY DEFAULT ARRAY['particulier'::text],
  prixsuffix text,
  CONSTRAINT offres_pkey PRIMARY KEY (id)
);
CREATE TABLE public.password_resets (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  utilisateur_id bigint,
  token text NOT NULL UNIQUE,
  expires_at timestamp with time zone NOT NULL,
  used_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT password_resets_pkey PRIMARY KEY (id),
  CONSTRAINT password_resets_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id)
);
CREATE TABLE public.rdv (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nom text NOT NULL,
  email text NOT NULL,
  telephone text NOT NULL,
  adresse text DEFAULT ''::text,
  date text NOT NULL,
  heure text NOT NULL,
  service text DEFAULT 'diagnostic'::text,
  rubrique text DEFAULT ''::text,
  notes text DEFAULT ''::text,
  statut text DEFAULT 'en_attente'::text CHECK (statut = ANY (ARRAY['en_attente'::text, 'confirme'::text, 'annule'::text])),
  datecreation timestamp with time zone DEFAULT now(),
  CONSTRAINT rdv_pkey PRIMARY KEY (id)
);
CREATE TABLE public.utilisateurs (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email text NOT NULL UNIQUE,
  motdepasse text NOT NULL,
  prenom text,
  nom text,
  role text DEFAULT 'client'::text,
  datecreation timestamp with time zone DEFAULT now(),
  telephone text DEFAULT ''::text,
  adresse text DEFAULT ''::text,
  ville text DEFAULT ''::text,
  codepostal text DEFAULT ''::text,
  CONSTRAINT utilisateurs_pkey PRIMARY KEY (id)
);
