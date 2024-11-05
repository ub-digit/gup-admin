-- PostgreSQL database dump
--

-- Dumped from database version 12.15 (Debian 12.15-1.pgdg110+1)
-- Dumped by pg_dump version 12.15 (Debian 12.15-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: publications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publications (
    id bigint NOT NULL,
    json text,
    publication_id character varying(255),
    attended boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);




ALTER TABLE public.publications OWNER TO postgres;
--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.publications_id_seq OWNER TO postgres;

--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.publications_id_seq OWNED BY public.publications.id;



-- Name: persons; Type: TABLE; Schema: public; Owner: postgres
CREATE TABLE public.persons (
    id bigint NOT NULL,
    json text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    deleted boolean DEFAULT false NOT NULL
);

ALTER TABLE public.persons OWNER TO postgres;

CREATE SEQUENCE public.persons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.persons_id_seq OWNER TO postgres;



--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.persons_id_seq OWNED BY public.persons.id;



--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: publications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications ALTER COLUMN id SET DEFAULT nextval('public.publications_id_seq'::regclass);
ALTER TABLE ONLY public.persons ALTER COLUMN id SET DEFAULT nextval('public.persons_id_seq'::regclass);



--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);

--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

