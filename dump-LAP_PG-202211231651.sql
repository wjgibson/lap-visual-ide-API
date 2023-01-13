--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

-- Started on 2022-11-23 16:51:48

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

--
-- TOC entry 3388 (class 1262 OID 33116)
-- Name: LAP_PG; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "LAP_PG" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';


ALTER DATABASE "LAP_PG" OWNER TO postgres;

\connect "LAP_PG"

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

--
-- TOC entry 3 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 7 (class 2615 OID 33219)
-- Name: sequenceconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sequenceconfig;


ALTER SCHEMA sequenceconfig OWNER TO postgres;

--
-- TOC entry 4 (class 2615 OID 33117)
-- Name: setup; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA setup;


ALTER SCHEMA setup OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 33220)
-- Name: stepconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stepconfig;


ALTER SCHEMA stepconfig OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 33158)
-- Name: types; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA types;


ALTER SCHEMA types OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 33221)
-- Name: alarms; Type: TABLE; Schema: sequenceconfig; Owner: postgres
--

CREATE TABLE sequenceconfig.alarms (
    sequuid uuid,
    alarmuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    description character varying,
    type uuid
);


ALTER TABLE sequenceconfig.alarms OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 33132)
-- Name: configurations; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.configurations (
    topicuuid uuid NOT NULL,
    configuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    description character varying
);


ALTER TABLE setup.configurations OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 33177)
-- Name: controlmodules; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.controlmodules (
    configuuid uuid,
    cmuuid uuid DEFAULT gen_random_uuid(),
    type uuid,
    name character varying,
    description character varying
);


ALTER TABLE setup.controlmodules OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 33145)
-- Name: sequences; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.sequences (
    configuuid uuid,
    sequuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    description character varying,
    type uuid
);


ALTER TABLE setup.sequences OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 33206)
-- Name: steps; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.steps (
    sequuid uuid,
    stepuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    type integer,
    name character varying,
    description character varying
);


ALTER TABLE setup.steps OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 33124)
-- Name: topics; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.topics (
    topicuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE setup.topics OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 33234)
-- Name: alarmtypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.alarmtypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.alarmtypes OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 33188)
-- Name: controlmoduletypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.controlmoduletypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.controlmoduletypes OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 33159)
-- Name: sequencetypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.sequencetypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.sequencetypes OWNER TO postgres;

--
-- TOC entry 3381 (class 0 OID 33221)
-- Dependencies: 220
-- Data for Name: alarms; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.alarms (sequuid, alarmuuid, name, description, type) FROM stdin;
\.


--
-- TOC entry 3375 (class 0 OID 33132)
-- Dependencies: 214
-- Data for Name: configurations; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.configurations (topicuuid, configuuid, name, description) FROM stdin;
\.


--
-- TOC entry 3378 (class 0 OID 33177)
-- Dependencies: 217
-- Data for Name: controlmodules; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.controlmodules (configuuid, cmuuid, type, name, description) FROM stdin;
\.


--
-- TOC entry 3376 (class 0 OID 33145)
-- Dependencies: 215
-- Data for Name: sequences; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.sequences (configuuid, sequuid, name, description, type) FROM stdin;
\.


--
-- TOC entry 3380 (class 0 OID 33206)
-- Dependencies: 219
-- Data for Name: steps; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.steps (sequuid, stepuuid, type, name, description) FROM stdin;
\.


--
-- TOC entry 3374 (class 0 OID 33124)
-- Dependencies: 213
-- Data for Name: topics; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.topics (topicuuid, name, description) FROM stdin;
\.


--
-- TOC entry 3382 (class 0 OID 33234)
-- Dependencies: 221
-- Data for Name: alarmtypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.alarmtypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- TOC entry 3379 (class 0 OID 33188)
-- Dependencies: 218
-- Data for Name: controlmoduletypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.controlmoduletypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- TOC entry 3377 (class 0 OID 33159)
-- Dependencies: 216
-- Data for Name: sequencetypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.sequencetypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- TOC entry 3221 (class 2606 OID 33228)
-- Name: alarms alarms_pk; Type: CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarms_pk PRIMARY KEY (alarmuuid);


--
-- TOC entry 3211 (class 2606 OID 33139)
-- Name: configurations configurations_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_pk PRIMARY KEY (configuuid);


--
-- TOC entry 3213 (class 2606 OID 33152)
-- Name: sequences sequences_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_pk PRIMARY KEY (sequuid);


--
-- TOC entry 3219 (class 2606 OID 33213)
-- Name: steps steps_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_pk PRIMARY KEY (stepuuid);


--
-- TOC entry 3209 (class 2606 OID 33131)
-- Name: topics topics_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.topics
    ADD CONSTRAINT topics_pk PRIMARY KEY (topicuuid);


--
-- TOC entry 3223 (class 2606 OID 33241)
-- Name: alarmtypes alarmtypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3217 (class 2606 OID 33195)
-- Name: controlmoduletypes controlmoduletypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3215 (class 2606 OID 33166)
-- Name: sequencetypes sequencetypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3233 (class 2606 OID 33247)
-- Name: alarms alarm_type_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarm_type_fk FOREIGN KEY (type) REFERENCES types.alarmtypes(typeuuid);


--
-- TOC entry 3232 (class 2606 OID 33229)
-- Name: alarms alarms_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarms_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- TOC entry 3224 (class 2606 OID 33140)
-- Name: configurations configurations_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_fk FOREIGN KEY (topicuuid) REFERENCES setup.topics(topicuuid) ON DELETE CASCADE;


--
-- TOC entry 3229 (class 2606 OID 33201)
-- Name: controlmodules controlmodule_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodule_type_fk FOREIGN KEY (type) REFERENCES types.controlmoduletypes(typeuuid);


--
-- TOC entry 3228 (class 2606 OID 33183)
-- Name: controlmodules controlmodules_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- TOC entry 3226 (class 2606 OID 33172)
-- Name: sequences sequence_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequence_type_fk FOREIGN KEY (type) REFERENCES types.sequencetypes(typeuuid);


--
-- TOC entry 3225 (class 2606 OID 33153)
-- Name: sequences sequences_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- TOC entry 3231 (class 2606 OID 33214)
-- Name: steps steps_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- TOC entry 3234 (class 2606 OID 33242)
-- Name: alarmtypes alarmtypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3230 (class 2606 OID 33196)
-- Name: controlmoduletypes controlmoduletypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3227 (class 2606 OID 33167)
-- Name: sequencetypes sequencetypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


-- Completed on 2022-11-23 16:51:48

--
-- PostgreSQL database dump complete
--

