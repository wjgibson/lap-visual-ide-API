--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: reactflow; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA reactflow;


ALTER SCHEMA reactflow OWNER TO postgres;

--
-- Name: sequenceconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sequenceconfig;


ALTER SCHEMA sequenceconfig OWNER TO postgres;

--
-- Name: setup; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA setup;


ALTER SCHEMA setup OWNER TO postgres;

--
-- Name: stepconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stepconfig;


ALTER SCHEMA stepconfig OWNER TO postgres;

--
-- Name: types; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA types;


ALTER SCHEMA types OWNER TO postgres;

--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: findfirstmissingconfig(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findfirstmissingconfig() RETURNS integer
    LANGUAGE plpgsql
    AS $$
	begin
		return (SELECT s.i AS missing_cmd 
		FROM generate_series(1,1000) s(i) 
		WHERE NOT EXISTS (SELECT 1 FROM setup.configurations where plcid = s.i) limit 1);
	END;
$$;


ALTER FUNCTION public.findfirstmissingconfig() OWNER TO postgres;

--
-- Name: add_cm(uuid, uuid, character varying, character varying, uuid); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.add_cm(cm uuid, config uuid, name character varying, description character varying, cmtype uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$   
    begin
	    delete from setup.controlmodules where configuuid=config;
		insert into setup.controlmodules (configuuid, cmuuid, "type", "name", description) values (config, cm, cmtype, name, description)
		on conflict (cmuuid) do update set name=excluded.name, description=excluded.description, type=excluded.type;         
    END;$$;


ALTER FUNCTION setup.add_cm(cm uuid, config uuid, name character varying, description character varying, cmtype uuid) OWNER TO postgres;

--
-- Name: add_config(uuid, character varying, jsonb); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.add_config(topic uuid, name character varying, rfdata jsonb) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
    declare        config uuid;
    BEGIN
        insert into setup.configurations (topicuuid,"name" ,description, plcid) values (topic,name,'', (select setup.find_missing_id())) returning configuuid into config;
        insert into reactflow.reactflowdata (json, "name", cid) values (rfdata, name, config);
        insert into types.sequencetypes (configuuid,name,plcid) values (config,'Control Module',1);
        insert into types.sequencetypes (configuuid,name,plcid) values (config,'Phase',2);
        insert into types.sequencetypes (configuuid,name,plcid) values (config,'Operation',3);
        insert into types.sequencetypes (configuuid,name,plcid) values (config,'Procedure',4);
       	insert into types.controlmoduletypes (configuuid,name) values (config,'Type 1');
		insert into types.controlmoduletypes (configuuid,name) values (config,'Type 2');
		insert into types.controlmoduletypes (configuuid,name) values (config,'Type 3');
		insert into types.controlmoduletypes (configuuid,name) values (config,'Type 4');        
	return config;
    END;$$;


ALTER FUNCTION setup.add_config(topic uuid, name character varying, rfdata jsonb) OWNER TO postgres;

--
-- Name: add_seq(uuid, uuid, character varying, character varying, uuid); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.add_seq(seq uuid, config uuid, name character varying, description character varying, seqtype uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$   
    begin
		insert into setup.sequences (configuuid, sequuid, "name", description, "typeuuid") values (config, seq, name, description, seqtype)
		on conflict (sequuid) do update set name=excluded.name, description=excluded.description, typeuuid=excluded.typeuuid;         
    END;$$;


ALTER FUNCTION setup.add_seq(seq uuid, config uuid, name character varying, description character varying, seqtype uuid) OWNER TO postgres;

--
-- Name: add_sub_seq(uuid, uuid, uuid); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.add_sub_seq(parent uuid, child uuid, configuuid uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
	    insert into sequenceconfig.subsequences (sequuid, subsequuid, plcid, configuuid) values (parent,child, (select setup.find_missing_id_for_subseq(parent)), configuuid)
	    on conflict (sequuid,subsequuid) do update set sequuid=excluded.sequuid, subsequuid=excluded.subsequuid;
    END;$$;


ALTER FUNCTION setup.add_sub_seq(parent uuid, child uuid, configuuid uuid) OWNER TO postgres;

--
-- Name: delete_config(uuid); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.delete_config(config uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
	    delete from setup."sequences" where configuuid=config;
	    delete from setup.controlmodules where configuuid=config;
	    delete from "types".sequencetypes where configuuid=config;
	   	delete from "types".controlmoduletypes where configuuid=config;
	    delete from setup.configurations where configuuid=config;
    END;$$;


ALTER FUNCTION setup.delete_config(config uuid) OWNER TO postgres;

--
-- Name: find_missing_id(); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.find_missing_id() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
		return (SELECT s.i AS missing_cmd FROM generate_series(1,1000) s(i) WHERE NOT EXISTS (SELECT 1 FROM setup.configurations where plcid = s.i) limit 1);
    END;
$$;


ALTER FUNCTION setup.find_missing_id() OWNER TO postgres;

--
-- Name: find_missing_id_for_config(); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.find_missing_id_for_config() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
		return (SELECT s.i AS missing_cmd FROM generate_series(1,1000) s(i) WHERE NOT EXISTS (SELECT 1 FROM setup.configurations where plcid = s.i) limit 1);
    END;
$$;


ALTER FUNCTION setup.find_missing_id_for_config() OWNER TO postgres;

--
-- Name: find_missing_id_for_subseq(); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.find_missing_id_for_subseq() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
		return (SELECT s.i AS missing_cmd FROM generate_series(1,1000) s(i) WHERE NOT EXISTS (SELECT 1 FROM sequenceconfig.subsequences where plcid = s.i) limit 1);
    END;
$$;


ALTER FUNCTION setup.find_missing_id_for_subseq() OWNER TO postgres;

--
-- Name: find_missing_id_for_subseq(uuid); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.find_missing_id_for_subseq(parent uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
		return (SELECT s.i AS missing_cmd FROM generate_series(1,1000) s(i) WHERE NOT EXISTS (SELECT 1 FROM sequenceconfig.subsequences where plcid = s.i and sequuid=parent) limit 1);
    END;
$$;


ALTER FUNCTION setup.find_missing_id_for_subseq(parent uuid) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: configjson; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.configjson (
    json jsonb,
    name character varying NOT NULL,
    cid uuid DEFAULT gen_random_uuid()
);


ALTER TABLE public.configjson OWNER TO postgres;

--
-- Name: testing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testing (
    json jsonb,
    name character varying NOT NULL,
    cid uuid DEFAULT gen_random_uuid()
);


ALTER TABLE public.testing OWNER TO postgres;

--
-- Name: reactflowdata; Type: TABLE; Schema: reactflow; Owner: postgres
--

CREATE TABLE reactflow.reactflowdata (
    json jsonb,
    name character varying NOT NULL,
    cid uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE reactflow.reactflowdata OWNER TO postgres;

--
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
-- Name: subsequences; Type: TABLE; Schema: sequenceconfig; Owner: postgres
--

CREATE TABLE sequenceconfig.subsequences (
    sequuid uuid NOT NULL,
    subsequuid uuid NOT NULL,
    plcid integer NOT NULL,
    seqsubsequuid uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE sequenceconfig.subsequences OWNER TO postgres;

--
-- Name: configurations; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.configurations (
    topicuuid uuid NOT NULL,
    configuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    description character varying,
    plcid integer NOT NULL
);


ALTER TABLE setup.configurations OWNER TO postgres;

--
-- Name: controlmodules; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.controlmodules (
    configuuid uuid,
    cmuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    type uuid,
    name character varying,
    description character varying
);


ALTER TABLE setup.controlmodules OWNER TO postgres;

--
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
-- Name: topics; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.topics (
    topicuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE setup.topics OWNER TO postgres;

--
-- Name: alarmtypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.alarmtypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.alarmtypes OWNER TO postgres;

--
-- Name: controlmoduletypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.controlmoduletypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.controlmoduletypes OWNER TO postgres;

--
-- Name: sequencetypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.sequencetypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    plcid integer NOT NULL
);


ALTER TABLE types.sequencetypes OWNER TO postgres;

--
-- Data for Name: configjson; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.configjson (json, name, cid) FROM stdin;
{"viewportInitialized": true}	Reload_actual	6902a54f-7f02-4367-bc38-82b8914bfebc
{"jsonData": {"nodes": []}}	tst	6a4232dd-c039-40f2-8880-927666cbe311
{"nodes": []}	Reload_baby	1b8ad594-411a-4abc-8d9e-dd670c325867
{"nodes": []}	testconfg	027980bf-af52-4bbc-bdde-2750630ad3fb
{"nodes": []}	testtt	3ce43d4c-d860-487d-8ef9-771103e8fc1e
{"nodes": []}	Test_Again	b14f2a7d-075a-49a8-81d6-45c77427c009
{"nodes": [{"id": "reactflow__edge-sequence_0-sequence_3", "type": "step", "source": "sequence_0", "target": "sequence_3", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-sequence_3-sequence_1", "type": "step", "source": "sequence_3", "target": "sequence_1", "animated": true, "sourceHandle": null, "targetHandle": null}]}	testtttt	1a22680a-cf88-4df6-b584-e5ce50d3c4e0
null	null	502bbee6-a450-4e6f-9c79-31a9a1bd3670
null	blah	f79e0810-374b-47a5-b02c-709f0d2c1f65
\.


--
-- Data for Name: testing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.testing (json, name, cid) FROM stdin;
{"viewportInitialized": true}	test	221194d7-c8f7-476a-9eb2-9d67e21477ed
\.


--
-- Data for Name: reactflowdata; Type: TABLE DATA; Schema: reactflow; Owner: postgres
--

COPY reactflow.reactflowdata (json, name, cid) FROM stdin;
{"edges": [], "nodes": [{"id": "faa0f3af-ac61-4dbe-8d5b-d79fdb3eacad", "data": {"name": "", "label": "sequence node", "configId": "46c26896-ed5c-45a1-8726-c278848978f3"}, "type": "sequence", "width": 300, "height": 207, "position": {"x": 412, "y": 282}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 412, "y": 282}}, {"id": "fbd43ca6-babe-44e1-ad21-ba51dfa8c20e", "data": {"name": "", "label": "sequence node", "configId": "46c26896-ed5c-45a1-8726-c278848978f3"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 367.5, "y": 28.25}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 367.5, "y": 28.25}}, {"id": "0a81e023-909a-440a-9ee3-808c2e54795f", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "46c26896-ed5c-45a1-8726-c278848978f3"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 360.75, "y": 319.625}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 360.75, "y": 319.625}}, {"id": "d0ac7471-47ec-4cbf-91ef-715337998fd6", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "46c26896-ed5c-45a1-8726-c278848978f3"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 549.625, "y": 166.6875}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 549.625, "y": 166.6875}}], "viewport": {"x": -629.25, "y": 78.625, "zoom": 2}}	null	46c26896-ed5c-45a1-8726-c278848978f3
{"edges": [], "nodes": [{"id": "cd4b0328-f09c-4c7e-badb-bd55cbd59e77", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "224c0b0c-aadc-4ab2-ba93-51e82469c2ea"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 369, "y": 531}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 369, "y": 531}}, {"id": "bc2138fd-1c83-4bf5-a922-26c461b120ae", "data": {"name": "Control Module", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "224c0b0c-aadc-4ab2-ba93-51e82469c2ea"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 508.5, "y": 413.25}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 508.5, "y": 413.25}}], "viewport": {"x": -569, "y": -625.5, "zoom": 2}}	kfsd	224c0b0c-aadc-4ab2-ba93-51e82469c2ea
{"edges": [], "nodes": [{"id": "d7a3207a-42ba-45d7-9e57-bfab36c59816", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "d60c6a1d-5d7c-425b-a341-ac51bc4ff70c"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 284, "y": 589}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 284, "y": 589}}, {"id": "afe62f24-3539-48b4-a44c-32b2b1f8922f", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "d60c6a1d-5d7c-425b-a341-ac51bc4ff70c"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 331, "y": 458.75}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 331, "y": 458.75}}], "viewport": {"x": -399, "y": -741.5, "zoom": 2}}	jfds	d60c6a1d-5d7c-425b-a341-ac51bc4ff70c
{"edges": [], "nodes": [{"id": "4c61a117-663d-4bcc-9260-b69981e43ed8", "data": {"name": "Control Module1", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "f6dc362b-f55c-4e72-a0c9-9d2fae72c85d"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 313, "y": 421}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 313, "y": 421}}, {"id": "78ecff55-f2dd-46dc-a4b3-f85927dec28b", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "f6dc362b-f55c-4e72-a0c9-9d2fae72c85d"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 381.5, "y": 348.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 381.5, "y": 348.25}}], "viewport": {"x": -456, "y": -405.5, "zoom": 2}}	kfsdf	f6dc362b-f55c-4e72-a0c9-9d2fae72c85d
{"edges": [{"id": "reactflow__edge-89c3e983-3fcf-4cb7-a5f8-a0380aa727aa-cee62627-f040-47e7-a1b7-55ddaeaf83a0", "type": "step", "source": "89c3e983-3fcf-4cb7-a5f8-a0380aa727aa", "target": "cee62627-f040-47e7-a1b7-55ddaeaf83a0", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-a900dbd0-e789-4469-8ebe-7a620136a094-89c3e983-3fcf-4cb7-a5f8-a0380aa727aa", "type": "step", "source": "a900dbd0-e789-4469-8ebe-7a620136a094", "target": "89c3e983-3fcf-4cb7-a5f8-a0380aa727aa", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "89c3e983-3fcf-4cb7-a5f8-a0380aa727aa", "data": {"type": "cb4034bb-24e9-46b6-8f27-e04af81802b3|2", "label": "sequence node", "configId": "d59cb56e-7f8d-4ca3-8607-3b4a4dcae320"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 165.71124154614733, "y": -119.55647304695276}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 165.71124154614733, "y": -119.55647304695276}}, {"id": "cee62627-f040-47e7-a1b7-55ddaeaf83a0", "data": {"type": "d87a6112-fd9a-48b7-9e1e-b18d205265ce|1", "label": "controlModule node", "seqType": "c|1", "configId": "d59cb56e-7f8d-4ca3-8607-3b4a4dcae320"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 492, "y": 149.75}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 492, "y": 149.75}}, {"id": "a900dbd0-e789-4469-8ebe-7a620136a094", "data": {"type": "41fdebec-c4e2-4d2e-9170-50fcde1e7720|3", "label": "sequence node", "configId": "d59cb56e-7f8d-4ca3-8607-3b4a4dcae320"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 595.1526366495012, "y": -157.97189613463163}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 595.1526366495012, "y": -157.97189613463163}}, {"id": "b9ac37a1-8d1a-4b61-86b2-d00db8787428", "data": {"type": "85353095-517a-4b49-94ae-8501369f5d31|4", "label": "sequence node", "configId": "d59cb56e-7f8d-4ca3-8607-3b4a4dcae320"}, "type": "sequence", "width": 300, "height": 207, "position": {"x": 442.188120709999, "y": -209.78713549207376}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 442.188120709999, "y": -209.78713549207376}}], "viewport": {"x": -184.47072332664305, "y": 335.81578486017634, "zoom": 1.3195079107728942}}	test	d59cb56e-7f8d-4ca3-8607-3b4a4dcae320
null	delete test	5e6b59a8-0267-417f-bd47-7eeeff18729a
null	delete test	3946e8f2-a3f9-406b-b648-1e7ddeb31170
null	test	0ef82a8c-3e20-4dfa-9b6e-70ee73988b9e
null	null	ccb3a132-4c7d-4e2b-83f7-0cbc08c407e6
null	null	27dcdd3c-6d7d-42ec-89c6-c45d1b46c90d
null	test	f985150c-6d8e-4ba4-ba9e-40b6c57fca15
null	delete test	48eb8798-840e-429c-8fbe-581243c4832f
null	delete test	d4af3bb3-0117-48bf-afed-b0cafd70a5d3
null	delete 1	d6cc3086-5c76-4d2f-b233-7157b12d2a8b
null	delete 2	e0dcc45b-0d13-4790-a1d1-a21162235893
null	delete 3	f5b9c9f0-8247-4d65-a9dd-6c1cc191719b
null	delete 4	467e2cb1-3f01-4bdb-a2ef-04007771839a
null	null	581f1d97-9fb0-4fcb-ba0f-9598fc4afdac
null	delete 1 	f16f691d-83b3-42e9-8afa-2ec9faf50b9e
null	delete 2	b1dce6c7-9db3-486d-9df8-4c3092556412
null	delete 1	e02064d0-9148-4558-b818-b8eb98233967
null	delete 2	f0f13ce2-d6ba-4725-9d16-a458a5ddb281
null	delete 1	e981884b-7c48-441a-aac5-2be5e5373580
null	delete 2	a8e990ce-c94f-4686-85f3-f0b1b23ad554
null	delete 1	52d462b2-d6ba-4802-b8bf-9437c9dd9b96
null	delete 2	b2733460-8475-4554-a3cb-40c280165fbd
null	delet 1	f148bbd0-e18a-4678-869d-5cd7a57a1796
null	d 2	e2c68808-6c12-40e8-bb4c-59ac452fa792
null	delete 1	53696c8f-7232-4084-9ab4-06fc693afd11
null	d 2	8c02e5d7-7b3c-47f0-89d7-1377161070f4
null	delete 1	5fc2ff8b-73fa-4531-bd56-5e533ec7cebb
null	d1	8d05cb4f-a6c2-4661-b648-1f4e5fc79c2c
null	d2	8645836c-c1a8-4383-bedb-1eebb01dff1c
{"edges": [], "nodes": [{"id": "3977db98-0c71-4365-8d4a-ee59efba4612", "data": {"name": "", "label": "sequence node", "configId": "0872f300-0ddf-4e01-a5bd-a59fb98ac0cd"}, "type": "sequence", "width": 300, "height": 207, "position": {"x": 148, "y": 307}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 148, "y": 307}}, {"id": "95d6ab52-1ec4-4b94-9312-ac2852d1799f", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "0872f300-0ddf-4e01-a5bd-a59fb98ac0cd"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 291.2189765458422, "y": 396.4393390191898}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 291.2189765458422, "y": 396.4393390191898}}, {"id": "41a8b70d-72b4-4639-8670-43aca48b8b70", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "0872f300-0ddf-4e01-a5bd-a59fb98ac0cd"}, "type": "controlModule", "width": 300, "height": 178, "dragging": false, "position": {"x": 177.21977611940298, "y": 193.75}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 177.21977611940298, "y": 193.75}}, {"id": "d2cff3bf-e73d-4454-8246-7dab059e96e9", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "0872f300-0ddf-4e01-a5bd-a59fb98ac0cd"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 333.74560733493666, "y": 203.42238991230263}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 333.74560733493666, "y": 203.42238991230263}}], "viewport": {"x": -217.17789810458703, "y": -56.23364724671387, "zoom": 1.7555017685199377}}	null	0872f300-0ddf-4e01-a5bd-a59fb98ac0cd
{"edges": [], "nodes": [{"id": "faee6f0f-e266-43ab-a4c1-595e69bd28e2", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "c8d89126-6297-43ed-8b2b-46ff52ee308c"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 443.19323027718553, "y": 520.0274520255864}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 443.19323027718553, "y": 520.0274520255864}}, {"id": "0589117b-7bdd-47ab-a435-903d64ff6b7c", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "c8d89126-6297-43ed-8b2b-46ff52ee308c"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 512.5, "y": 329.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 512.5, "y": 329.25}}], "viewport": {"x": -652.8842051802944, "y": -255.38725241239194, "zoom": 1.9055358049771456}}	dashdas	c8d89126-6297-43ed-8b2b-46ff52ee308c
{"edges": [], "nodes": [{"id": "e60975a1-887e-4abf-a27f-ec51b1d46e5b", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "08b298f7-51d0-4951-a0b1-e9d5b490068b"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 315, "y": 449}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 315, "y": 449}}, {"id": "4e91c249-1f61-4925-b97d-50f03011b7e3", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "08b298f7-51d0-4951-a0b1-e9d5b490068b"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 486.5, "y": 323.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 486.5, "y": 323.25}}], "viewport": {"x": -527.0541791188662, "y": -242.007085703268, "zoom": 1.8085414055721583}}	jkasd	08b298f7-51d0-4951-a0b1-e9d5b490068b
{"edges": [], "nodes": [{"id": "17da1c0b-0395-4d70-b98a-ade407eccd35", "data": {"name": "Control Module", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "9ea07332-7d7d-49fc-9682-66548eea78ac"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 225.99424307036247, "y": 425.0102345415778}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 225.99424307036247, "y": 425.0102345415778}}, {"id": "8e65a7ab-1241-4754-96e8-21258c2459d0", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "9ea07332-7d7d-49fc-9682-66548eea78ac"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 370.5, "y": 285.75}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 370.5, "y": 285.75}}], "viewport": {"x": -445.2076095065544, "y": -241.96680166258125, "zoom": 1.9993605456676968}}	jdas	9ea07332-7d7d-49fc-9682-66548eea78ac
{"edges": [], "nodes": [{"id": "f1519e0c-80fa-4c30-b234-a0acb54bb83f", "data": {"name": "", "label": "sequence node", "configId": "d0451fa8-bb50-4156-844c-c21fb3af98fd"}, "type": "sequence", "width": 300, "height": 207, "position": {"x": 416, "y": 364}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 416, "y": 364}}, {"id": "b2f9bfd8-cae7-43b5-b165-1ac57b2acff4", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "d0451fa8-bb50-4156-844c-c21fb3af98fd"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 622.5, "y": 286.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 622.5, "y": 286.25}}, {"id": "db7ff9c7-41dd-4903-bd37-12e7ae58dc30", "data": {"name": "Control Module", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "d0451fa8-bb50-4156-844c-c21fb3af98fd"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 468.5, "y": 259.75}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 468.5, "y": 259.75}}], "viewport": {"x": -663, "y": -291.5, "zoom": 2}}	djasd	d0451fa8-bb50-4156-844c-c21fb3af98fd
null	d1	ef1c29b4-d0e2-4e86-a000-eccf79ec8e16
null	null	0f048dc7-6245-4d05-b250-755fcf317463
null	d2	b1ecb200-fa02-434f-9cf1-0b14b17ecfe9
null	d1	25ca3e5c-68d6-4776-9e99-aff23255bae0
null	d12	fc0e35cf-07e1-4013-8a93-6e5c455466b9
null	d1	caab5c75-9161-407b-be19-f6a534d86580
null	d2	132feddd-155a-4cad-9726-d2469a7b40b3
null	d1	41d52dec-4e3b-4774-83dd-cc84e757372c
null	d2	6b7b92d0-4684-4af6-9b94-c3d21a3377c5
null	d1	f9ebd0e8-2c78-42fe-a898-714d5b1a734b
null	d2	9edc8ef8-89eb-4059-9a0f-08f0d3933819
null	d1	60ab00b0-4adf-4668-859d-9759fd97d4ac
null	d1	7cd3f29b-6466-436a-a065-33a7810563ff
null	d2	12e32e0c-8a9f-4d68-bbf1-01193affe4f1
null	d1	ca26da69-b07b-4bdf-99c7-6f6a6490c1b5
null	d2	a29c55fb-4a0b-4c19-8d48-de3404f802cd
null	d1	0561ee75-f945-41fc-8cb0-8cc737c93fa7
null	d2	9f121a00-c3d8-4655-826f-fded57e8c891
null	d1	898a99d5-20af-44fa-a30b-2a69b1e60a3f
null	d2	deda65e3-781d-463a-9fd9-8f8b832a91f8
null	d1	afb00e00-acd6-474f-b332-b129d71b668a
{"edges": [], "nodes": [{"id": "d71f3ae2-f9f0-4c80-85fe-88ebb67bcb7d", "data": {"name": "", "label": "sequence node", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 153, "y": 331}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 153, "y": 331}}, {"id": "e2b83f8d-700f-48ea-8544-4baf0af6090e", "data": {"name": "", "type": "undefined|1|1|1|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 302, "y": 219.75}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 302, "y": 219.75}}, {"id": "5da4754b-4ab5-4f93-9c3d-3b0236bc1b1b", "data": {"name": "", "type": "undefined|1|1|1|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "dragging": false, "position": {"x": 96.56524520255863, "y": 25.453944562899764}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 96.56524520255863, "y": 25.453944562899764}}, {"id": "9b80ec66-7ddb-48f1-9c63-30c7b4113ada", "data": {"name": "", "type": "undefined|1|1|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 269.6006396588486, "y": 320.1651119402985}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 269.6006396588486, "y": 320.1651119402985}}, {"id": "b6182bde-6200-4b26-b519-372694e4c301", "data": {"name": "", "type": "undefined|1|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 409.7408096889903, "y": 71.60513578543468}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 409.7408096889903, "y": 71.60513578543468}}, {"id": "3ba75096-83b6-4506-b41f-69ddb14703f9", "data": {"name": "", "type": "undefined|1|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "dragging": false, "position": {"x": 325.49283868139486, "y": 20.342911023561026}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 325.49283868139486, "y": 20.342911023561026}}, {"id": "01d53302-bddd-4b34-8d63-a7e125d40107", "data": {"name": "", "type": "undefined|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 365.04200888547706, "y": 21.382773363353696}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 365.04200888547706, "y": 21.382773363353696}}, {"id": "979c73ac-a13f-4cb2-ae6d-944c59364f16", "data": {"name": "", "type": "undefined|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 178, "position": {"x": 501.66641504503383, "y": -118.11793608377269}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 501.66641504503383, "y": -118.11793608377269}}, {"id": "3c2b91d0-b26a-42c6-b686-88163cf971b8", "data": {"name": "Control Module", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 259.76083579189907, "y": -78.22584806226253}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 259.76083579189907, "y": -78.22584806226253}}, {"id": "b39ca3e1-fbeb-4700-9ceb-04d2bcb1449d", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "da4ce7ea-4718-4871-90c0-24f72fd33e6d"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 622.7601480700774, "y": -187.3737050570679}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 622.7601480700774, "y": -187.3737050570679}}], "viewport": {"x": -74.14661971936437, "y": 389.6038908002572, "zoom": 1.209368682394582}}	sajdasjd	da4ce7ea-4718-4871-90c0-24f72fd33e6d
null	ghoss	7ed75ed9-45aa-4ed6-b699-8d5013870a65
null	s1	1839ca1b-544f-4036-99a4-550f981a96ef
null	s2	b0e821d9-a015-442d-92e4-e7348a975ff2
null	t1	c97779ce-6b23-4e22-90be-c23a3461f766
null	t2	05903512-7e6a-40c7-9813-6b0ec0838d74
null	c1	9597003b-1349-454b-99d6-fb181afb9f18
null	c2	5a6196d9-6dd6-4864-aca1-1fb90001e275
null	t1	4150e242-40b8-4994-89cb-b7ddcf831aa5
null	d1	032ba567-dce0-4b5e-89bf-9e177f614b81
null	d1	c68a36bc-c2cf-4123-aa7c-1857c111d930
{"edges": [], "nodes": [{"id": "d6d1570e-d6b4-4961-ac98-6875090207d8", "data": {"type": "542cc87c-4f3d-4bd1-a28c-d80ac8fb1c2e|3", "label": "sequence node", "configId": "8ba2819f-25d9-41cf-b6d5-98019e61dbf5"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 362.5, "y": 118}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 362.5, "y": 118}}], "viewport": {"x": -600, "y": -134.5, "zoom": 2}}	test	8ba2819f-25d9-41cf-b6d5-98019e61dbf5
{"edges": [], "nodes": [{"id": "a8bffc85-5034-491d-8333-bab42571ddcf", "data": {"type": "899c2c17-3410-4c9f-8b20-188f40f651e6|2", "label": "sequence node", "configId": "f4ac836e-b085-48f0-b2cc-e6af7b1e77db"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 391.5, "y": 72.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 391.5, "y": 72.5}}, {"id": "0efa562e-0fca-4662-8a45-edf8313191b0", "data": {"type": "d6a18ad9-67ad-498f-896f-05413f8e403f|undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "f4ac836e-b085-48f0-b2cc-e6af7b1e77db"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 570, "y": 286.25}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 570, "y": 286.25}}], "viewport": {"x": -734.6611570247933, "y": -80.87380070295421, "zoom": 1.998670086444381}}	d1	f4ac836e-b085-48f0-b2cc-e6af7b1e77db
{"edges": [], "nodes": [{"id": "b4963a5a-1119-4946-b882-f0bfa3a258a4", "data": {"type": "3f31cecf-0814-41c7-9d08-83c3e8c8ddcd|4", "label": "sequence node", "seqType": "423d39a6-a1cb-47c0-9a43-7d44b897f8e2|3", "configId": "2ed4a6cc-5add-4e47-8b98-30eeb60884ed", "invalidConnection": false}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 372, "y": 181.5}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 372, "y": 181.5}}], "viewport": {"x": -518, "y": -85.5, "zoom": 2}}	test	2ed4a6cc-5add-4e47-8b98-30eeb60884ed
{"edges": [{"id": "reactflow__edge-154d0e7f-1406-4da5-8fe3-a4120a6a628e-3fea68ec-32e9-4d24-99ac-b08856aa4b24", "type": "step", "source": "154d0e7f-1406-4da5-8fe3-a4120a6a628e", "target": "3fea68ec-32e9-4d24-99ac-b08856aa4b24", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "154d0e7f-1406-4da5-8fe3-a4120a6a628e", "data": {"type": "15815f37-9421-4f2a-bd4d-febd55fc4339|3", "label": "sequence node", "configId": "23680c75-686b-45ba-86b5-494a8588a257"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 27, "y": 67}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 27, "y": 67}}, {"id": "3fea68ec-32e9-4d24-99ac-b08856aa4b24", "data": {"type": "c2cbf745-9202-4cf9-83e8-dc7ba062d019|1", "label": "controlModule node", "seqType": "c|1", "configId": "23680c75-686b-45ba-86b5-494a8588a257"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 136.5, "y": 326.25}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 136.5, "y": 326.25}}], "viewport": {"x": 22, "y": -132.5, "zoom": 2}}	test	23680c75-686b-45ba-86b5-494a8588a257
{"edges": [{"id": "reactflow__edge-75fce170-ebf9-4ddf-8ac0-8a95c788b95a-25613a8e-971d-43bd-a4c6-a26f4395febd", "type": "step", "source": "75fce170-ebf9-4ddf-8ac0-8a95c788b95a", "target": "25613a8e-971d-43bd-a4c6-a26f4395febd", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "75fce170-ebf9-4ddf-8ac0-8a95c788b95a", "data": {"type": "b480dea9-86d2-4a66-ad52-2eeb4e674aa8|3", "label": "sequence node", "configId": "29f1ddd4-c45a-47fb-96b0-69f6d5273f16"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 163.5, "y": -31.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 163.5, "y": -31.5}}, {"id": "25613a8e-971d-43bd-a4c6-a26f4395febd", "data": {"type": "7a43beb7-c2d9-4954-960c-129ff8ba9917|1", "label": "controlModule node", "seqType": "c|1", "configId": "29f1ddd4-c45a-47fb-96b0-69f6d5273f16"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 375, "y": 207.25}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 375, "y": 207.25}}], "viewport": {"x": -284, "y": 95.5, "zoom": 2}}	final test	29f1ddd4-c45a-47fb-96b0-69f6d5273f16
null	ff	631ba18e-61b7-4502-a74f-9850911b0f9f
null	test	706295a1-8407-42a4-92c7-33d27c27d2d0
null	test	b83e1c2d-a88a-43cc-bc99-08bc6751f494
{"edges": [], "nodes": [{"id": "c569c4f6-1435-4265-b3fc-d95610d6037b", "data": {"name": "", "type": "undefined|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 334.5, "y": 586.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 334.5, "y": 586.5}}, {"id": "1c13df08-9d48-4e79-85a9-7ddb145359fc", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 571.0744402985074, "y": 623.0632462686567}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 571.0744402985074, "y": 623.0632462686567}}, {"id": "6e5ada74-85e2-40f0-a0d1-43cbffe97954", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 616.5858209353021, "y": 182.51749399325334}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 616.5858209353021, "y": 182.51749399325334}}, {"id": "41adc450-d856-481f-9f49-baff7c452c26", "data": {"name": "", "label": "sequence node", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 511.6623756484103, "y": 433.26857421315594}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 511.6623756484103, "y": 433.26857421315594}}, {"id": "e8692a03-9e54-4b2f-bd4f-7168cc23c063", "data": {"name": "hasd", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 346.0552278187951, "y": 193.62088861065138}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 346.0552278187951, "y": 193.62088861065138}}, {"id": "c8a9286f-79f1-489c-9d06-c4830584d15c", "data": {"name": "Sequence", "label": "sequence node", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 458.06085192375014, "y": 477.4104193484867}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 458.06085192375014, "y": 477.4104193484867}}, {"id": "59ea74ea-d258-4855-b36b-27f466e9e122", "data": {"name": "", "label": "sequence node", "configId": "ea26fc5f-0026-4f14-843c-f6985e1bc45d"}, "type": "sequence", "width": 300, "height": 207, "position": {"x": 522.8730950856061, "y": 313.8066987457435}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 522.8730950856061, "y": 313.8066987457435}}], "viewport": {"x": -501.95301391316957, "y": -205.70346085836673, "zoom": 1.589205911956751}}	jskaf	ea26fc5f-0026-4f14-843c-f6985e1bc45d
{"edges": [], "nodes": [{"id": "256fcebb-7bbf-4630-abfe-a60cf6860d4f", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "configId": "4515bb94-84ac-4537-b2ae-c7e187568378"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 364, "y": 312}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 364, "y": 312}}], "viewport": {"x": -559, "y": -187.5, "zoom": 2}}	sajdda	4515bb94-84ac-4537-b2ae-c7e187568378
{"edges": [], "nodes": [{"id": "1acefc51-28dd-4df1-9fc1-38301842be0b", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "configId": "425011c8-e6ac-4ed8-8ea5-008c0dc9645e"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 354, "y": 428}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 354, "y": 428}}], "viewport": {"x": -539, "y": -419.5, "zoom": 2}}	jsadj	425011c8-e6ac-4ed8-8ea5-008c0dc9645e
{"edges": [], "nodes": [{"id": "a4c68149-a5fb-4a30-9514-ae5bed559488", "data": {"name": "", "label": "sequence node", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "sequence", "width": 251, "height": 207, "position": {"x": 180.195037781184, "y": -190.18663561222385}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 180.195037781184, "y": -190.18663561222385}}, {"id": "57952f47-f00c-4aef-8ffb-2949ec04ab2f", "data": {"name": "Sequence", "label": "sequence node", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 465.25252525387964, "y": -164.0078867626906}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 465.25252525387964, "y": -164.0078867626906}}, {"id": "ac945893-8dd5-4dd6-a7ed-0be160c7ce17", "data": {"name": "", "label": "sequence node", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": -85.03798664046889, "y": 69.6485798557957}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": -85.03798664046889, "y": 69.6485798557957}}, {"id": "84ff251c-5516-47d0-a10c-1810866e92ac", "data": {"name": "", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 426.8438746044709, "y": 366.0616370246419}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 426.8438746044709, "y": 366.0616370246419}}, {"id": "a1ccfa2c-edd1-4f6a-8c82-ed68dccdbb32", "data": {"name": "Control Module", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 764.7276997389389, "y": 98.66704028223327}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 764.7276997389389, "y": 98.66704028223327}}, {"id": "5ae05205-f31f-499d-9394-372c9c00fe13", "data": {"name": "Control Modulasdsk;ld", "type": "undefined|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 54.28947098531148, "y": 393.25388677225436}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 54.28947098531148, "y": 393.25388677225436}}, {"id": "1d34b2e9-e38e-4595-aca1-df4f47e7dca0", "data": {"name": "", "label": "sequence node", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "sequence", "width": 251, "height": 207, "position": {"x": 900.6884016922482, "y": 483.8522842119294}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 900.6884016922482, "y": 483.8522842119294}}, {"id": "ff7a3347-ea85-4e15-b9ca-55a78bde6dc9", "data": {"name": "Sequence", "label": "sequence node", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 429.8742301340239, "y": 149.98596103470948}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 429.8742301340239, "y": 149.98596103470948}}, {"id": "29a3e900-d6ab-43af-a886-a19dcb2e1be4", "data": {"name": "Sequenc", "label": "sequence node", "configId": "fd885750-aa9b-4d94-98e7-d3408a93e04c"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 949.0229364149557, "y": -108.69330812941}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 949.0229364149557, "y": -108.69330812941}}], "viewport": {"x": 609.7386597303525, "y": 262.43364310137224, "zoom": 1.117213609478089}}	sad	fd885750-aa9b-4d94-98e7-d3408a93e04c
null	asdlkas	52bf78a3-4d71-47d0-8566-89e930b86a94
null	asdasljka	02ae7d38-30a1-4e6d-abe6-6f057cf98913
null	adjalksa	636b7935-26e6-430c-ab7e-14ce35b05686
null	asdjlkasdkas	bd3496ff-463d-4ad4-89f0-945b881d02d5
null	adaskl;da;l	80cef272-3b98-42e4-94f9-8e28616be13b
null	sad;kakd	3457d9f8-7a70-4916-94ec-d3ac7ce60087
null	dakdal;	791f9206-f86b-4360-8306-a074d19ab017
null	asdas;kj	9416129a-1e13-4ee7-8fa9-54338807a1a4
null	asdasjlk	e7d2808e-3a8c-4764-befd-7fe29a878c8a
null	asdasjlka	ec40c92a-1cc1-45ef-b6c4-d94daff421de
null	dask;ldal;	25b152bf-f051-4b95-a00b-4027e70df089
null	asd;kadal	37488d46-fc6c-4b6b-ab62-b57deb1aa241
null	dakdas;das	b18b3230-193e-4522-83da-931590e8992e
null	dk;ad;	0502c139-5bb3-4cc9-ad18-6d1a17776450
null	sadaljsd	f97f19c2-c383-4cff-8074-e0bb081b6d25
null	asdasjlkd	37ed31e1-1ebe-4326-8242-840bfe7f6ba3
null	dasjaska	779e71e5-6813-433e-b05d-a756908e9aa0
null	asdjkaa;	ad2eae7d-56bb-46c2-a4ea-f6b37aa2f81d
null	asd;lkasdas	7c1cc11a-922d-465b-9270-2705ae174f61
null	sad;akd	1f6faf66-5c6c-4b35-9539-f34dee8491d8
null	asdakada	90d4f02c-032b-4375-bc07-43f0f07ee850
null	null	a1cd6045-70a8-415d-b416-7e1ff63f810a
null	null	731e958e-4efb-4ea6-be2e-f34dfc62f611
null	hads	3ffbc38b-e726-4a53-b8d9-46871904af49
null	djasa	731373eb-9b03-4904-bd90-48bbb463ba67
null	sdasdk	8eb58cf1-edba-4f88-92cc-dbe88ef6ebcd
null	dasdkas;	951b9f68-5a80-4417-8518-da46ecb3dce5
null	sadasdks	8df54bc9-30f4-41c5-a3de-662152dc44eb
null	sdsadkaj	5a6ef50c-cf35-4b86-bdb6-d79e6dd12d11
null	sdaska	c00d3df0-45f7-44a8-b17b-0bfff82d978b
null	asdask	2b27bb55-9997-4617-a868-ec2dc975172b
null	asdask	a49d6d99-5c71-43a3-baa1-9186a63344de
null	sadsj	38b6628b-f7b2-4ec2-8e04-85b15bf04b49
null	null	4b073a0a-d6c9-4b0f-ad23-e5395c1299f7
null	jdass	4140c807-d385-4fec-972a-5aa7367d8927
null	null	4230231c-4ee7-4efa-b74a-6d4375ab3d7c
null	null	5b8aa2a5-a7ab-4f2a-8b2e-510120342bbe
null	null	21b9811c-a64b-4af2-9e0a-62d2e8cfe2cc
null	null	31b1a40c-6fc1-439e-9cb2-dabb3592b739
null	null	907fc2dd-ccba-4e19-8e62-e9a726a00eae
{"edges": [], "nodes": [{"id": "d24e4c07-f21e-446e-ad1d-bcb5f2fd96da", "data": {"name": "", "label": "sequence node", "configId": "8ba683fc-b4b2-43e1-b04e-ea1addd1aa3b"}, "type": "sequence", "width": 251, "height": 207, "position": {"x": 453, "y": 330}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 453, "y": 330}}], "viewport": {"x": -615, "y": -255.5, "zoom": 2}}	asdaskl	8ba683fc-b4b2-43e1-b04e-ea1addd1aa3b
{"edges": [], "nodes": [{"id": "1aeea8bc-22ad-4cb4-a6b4-6195f3f76d23", "data": {"type": "134afa44-4506-4b32-b5f5-53f2f1f64827|2", "isNew": true, "label": "sequence node", "configId": "0e9ab823-fd81-40fc-b594-8ba957dc870e"}, "type": "sequence", "width": 300, "height": 191, "dragging": false, "position": {"x": 41.5, "y": -645}, "selected": true, "positionAbsolute": {"x": 41.5, "y": -645}}, {"id": "e8616554-16dc-4da1-a6e4-e954ad7b47ec", "data": {"type": "ae384eab-c5f3-4b97-a903-ee1839e7e6de", "isNew": true, "label": "controlModule node", "configId": "0e9ab823-fd81-40fc-b594-8ba957dc870e"}, "type": "controlModule", "width": 300, "height": 191, "dragging": false, "position": {"x": 216.5, "y": -407.25}, "selected": false, "positionAbsolute": {"x": 216.5, "y": -407.25}}], "viewport": {"x": -32, "y": 1345.75, "zoom": 2}}	test	0e9ab823-fd81-40fc-b594-8ba957dc870e
{"edges": [], "nodes": [{"id": "d8e33c1e-48de-4b38-ad2a-5a1605b1b304", "data": {"name": "", "label": "sequence node", "configId": "84debdbc-b803-4bf6-a441-1611a83a21dc"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 394.5, "y": 368}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 394.5, "y": 368}}, {"id": "ed97b37c-d950-456b-b03b-24dc0dcb1025", "data": {"name": "", "label": "sequence node", "configId": "84debdbc-b803-4bf6-a441-1611a83a21dc"}, "type": "sequence", "width": 251, "height": 207, "position": {"x": 544.5, "y": 237.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 544.5, "y": 237.25}}], "viewport": {"x": -498, "y": -331.5, "zoom": 2}}	sdasjda	84debdbc-b803-4bf6-a441-1611a83a21dc
{"edges": [{"id": "reactflow__edge-be6cc95f-f9da-4e8f-8ad1-91906ece0668-2a579767-d7c6-4883-b311-fc2d7aa9a497", "type": "step", "style": {"stroke": "red"}, "source": "be6cc95f-f9da-4e8f-8ad1-91906ece0668", "target": "2a579767-d7c6-4883-b311-fc2d7aa9a497", "animated": true, "selected": false, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "be6cc95f-f9da-4e8f-8ad1-91906ece0668", "data": {"type": "c6f865f9-5d32-455c-ba81-05c94e91a3b0|3", "label": "sequence node", "configId": "c0392cb4-e613-482c-9a0f-94d36cd92c15", "connection": {"source": "be6cc95f-f9da-4e8f-8ad1-91906ece0668", "target": "2a579767-d7c6-4883-b311-fc2d7aa9a497", "sourceHandle": null, "targetHandle": null}, "invalidConnection": true}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 375.566185908105, "y": 73.39094462931408}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 375.566185908105, "y": 73.39094462931408}}, {"id": "2a579767-d7c6-4883-b311-fc2d7aa9a497", "data": {"type": "86982ac3-aa38-4fe5-8f9f-86c44c1be30d|2", "label": "sequence node", "configId": "c0392cb4-e613-482c-9a0f-94d36cd92c15", "invalidConnection": false}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 669.2337126507879, "y": 317.8689568787453}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 669.2337126507879, "y": 317.8689568787453}}], "viewport": {"x": -70.33353107200469, "y": 48.807257775865935, "zoom": 1.0746406233983055}}	color test	c0392cb4-e613-482c-9a0f-94d36cd92c15
null	test	05976203-3e2f-4620-bbb5-c0bf1d49f035
null	rftest	cfaf9fba-471f-4f29-a0a8-07d7ad7b4361
{"edges": [{"id": "reactflow__edge-7a909957-4281-4e6c-8cb6-d99d74026992-90570e9c-8ab3-4748-b9c3-29fdd4d0bcfb", "type": "step", "style": {"stroke": "black"}, "source": "7a909957-4281-4e6c-8cb6-d99d74026992", "target": "90570e9c-8ab3-4748-b9c3-29fdd4d0bcfb", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "7a909957-4281-4e6c-8cb6-d99d74026992", "data": {"type": "d993189d-a7c0-4147-8d16-f9299845abf0|3", "label": "sequence node", "configId": "5d832ae6-f812-4b76-8d15-88ff7e1cb8e3", "connection": {"source": "7a909957-4281-4e6c-8cb6-d99d74026992", "target": "90570e9c-8ab3-4748-b9c3-29fdd4d0bcfb", "sourceHandle": null, "targetHandle": null}, "invalidConnection": false}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 253.5, "y": 104.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 253.5, "y": 104.5}}, {"id": "90570e9c-8ab3-4748-b9c3-29fdd4d0bcfb", "data": {"type": "71297c69-1980-42dd-bb47-3858fb62718c|2", "label": "sequence node", "configId": "5d832ae6-f812-4b76-8d15-88ff7e1cb8e3", "invalidConnection": false}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 336.5, "y": 348.25}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 336.5, "y": 348.25}}], "viewport": {"x": -296, "y": -100.5, "zoom": 2}}	test	5d832ae6-f812-4b76-8d15-88ff7e1cb8e3
{"edges": [], "nodes": [{"id": "51ebbc9f-06e4-41c4-b8af-85208e432ab2", "data": {"type": "474eff11-dc5b-4901-9042-ecd00de2f201|3", "label": "sequence node", "configId": "47605b66-ec97-4d62-82d1-9b7eb3083e82"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 391, "y": -47.5}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 391, "y": -47.5}}], "viewport": {"x": -556, "y": 372.5, "zoom": 2}}	Iteration 3 test	47605b66-ec97-4d62-82d1-9b7eb3083e82
{"edges": [], "nodes": [{"id": "16572221-5abb-44b7-9be8-3625296227f2", "data": {"type": "c3892d61-c7a8-4cca-9f11-9faba240a4d4|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "c10e28bd-3fac-4874-ba3b-c91f1fe8f6ac"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 453, "y": 206}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 453, "y": 206}}], "viewport": {"x": -680, "y": -134.5, "zoom": 2}}	test	c10e28bd-3fac-4874-ba3b-c91f1fe8f6ac
{"edges": [{"id": "reactflow__edge-19692d7c-ff31-428c-8b7a-9d689dd97c5b-0ec6be52-29d0-413f-b1f8-da6a3af780eb", "type": "step", "source": "19692d7c-ff31-428c-8b7a-9d689dd97c5b", "target": "0ec6be52-29d0-413f-b1f8-da6a3af780eb", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-9cc81460-d9b6-4313-a278-38182cd17a39-19692d7c-ff31-428c-8b7a-9d689dd97c5b", "type": "step", "source": "9cc81460-d9b6-4313-a278-38182cd17a39", "target": "19692d7c-ff31-428c-8b7a-9d689dd97c5b", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "9cc81460-d9b6-4313-a278-38182cd17a39", "data": {"type": "aeb784c0-6718-4ded-abe5-a3f411d4b8d3|3", "label": "sequence node", "configId": "d6e90434-b61b-4aeb-8b34-6205ddcc9c01"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 309.95257426830153, "y": -113.2740780639086}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 309.95257426830153, "y": -113.2740780639086}}, {"id": "19692d7c-ff31-428c-8b7a-9d689dd97c5b", "data": {"type": "501957d9-289a-4de3-8331-a25b83fa41eb|2", "label": "sequence node", "configId": "d6e90434-b61b-4aeb-8b34-6205ddcc9c01"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 451.4307405148696, "y": 144.05847107354245}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 451.4307405148696, "y": 144.05847107354245}}, {"id": "0ec6be52-29d0-413f-b1f8-da6a3af780eb", "data": {"type": "009e7cdf-0411-4501-92f7-16f927e5ab27|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "d6e90434-b61b-4aeb-8b34-6205ddcc9c01"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 88.62665436044762, "y": 64.80240602030565}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 88.62665436044762, "y": 64.80240602030565}}], "viewport": {"x": -89.13141952430556, "y": 258.17259178977054, "zoom": 1.4549753939491497}}	full test	d6e90434-b61b-4aeb-8b34-6205ddcc9c01
{"edges": [], "nodes": [{"id": "95a38bca-311b-4dfd-a442-a17055244d13", "data": {"type": "ab5e6826-e3d5-4247-866d-e79cf52ed647|1|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "ba7e029b-15a6-4b1a-92f1-ddb33f7d94a3"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 668, "y": 218}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 668, "y": 218}}], "viewport": {"x": -869, "y": -158.5, "zoom": 2}}	test 2	ba7e029b-15a6-4b1a-92f1-ddb33f7d94a3
{"edges": [{"id": "reactflow__edge-9af5f5d8-7b64-48b1-a905-5959b99d3de5-df1d8b4f-aadc-4730-ad7f-2ab3d2f5babd", "type": "step", "source": "9af5f5d8-7b64-48b1-a905-5959b99d3de5", "target": "df1d8b4f-aadc-4730-ad7f-2ab3d2f5babd", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-df1d8b4f-aadc-4730-ad7f-2ab3d2f5babd-598a370c-fa9a-4b12-826b-91291ff78421", "type": "step", "source": "df1d8b4f-aadc-4730-ad7f-2ab3d2f5babd", "target": "598a370c-fa9a-4b12-826b-91291ff78421", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "9af5f5d8-7b64-48b1-a905-5959b99d3de5", "data": {"type": "af457840-6dd7-4467-b7be-4e84ea9d03ba|3", "label": "sequence node", "configId": "4bf433eb-9782-4988-b816-fd590c867d11"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 485, "y": 95}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 485, "y": 95}}, {"id": "598a370c-fa9a-4b12-826b-91291ff78421", "data": {"type": "b5dfb69d-382a-4b71-a39b-771532db8020|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "4bf433eb-9782-4988-b816-fd590c867d11"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 969.6991549662257, "y": 574.2480634642669}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 969.6991549662257, "y": 574.2480634642669}}, {"id": "df1d8b4f-aadc-4730-ad7f-2ab3d2f5babd", "data": {"type": "db2addb7-5a24-498b-ad21-9030b217e4b0|2", "label": "sequence node", "configId": "4bf433eb-9782-4988-b816-fd590c867d11"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 545.5, "y": 337.25}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 545.5, "y": 337.25}}], "viewport": {"x": -185.8928090785821, "y": 57.427640364961746, "zoom": 1.1628002190451359}}	integration test	4bf433eb-9782-4988-b816-fd590c867d11
null	d test	a2bf8835-d94d-4c1e-bb36-c9b5b9eb6ace
{"edges": [{"id": "reactflow__edge-b415a572-bcdf-4955-a6d2-31984fbe6d23-d6642535-7cab-498d-b40c-369a22ad158d", "type": "step", "source": "b415a572-bcdf-4955-a6d2-31984fbe6d23", "target": "d6642535-7cab-498d-b40c-369a22ad158d", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "b415a572-bcdf-4955-a6d2-31984fbe6d23", "data": {"type": "11f860ac-c877-4e56-b1a7-83b303219aa8|2", "label": "sequence node", "configId": "f15193f4-274a-4d8d-8c12-cd09066106a7"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 504, "y": 16}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 504, "y": 16}}, {"id": "d6642535-7cab-498d-b40c-369a22ad158d", "data": {"type": "f7e534c5-c0db-47ef-bbfa-912475c8ba96|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "f15193f4-274a-4d8d-8c12-cd09066106a7"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 778.5, "y": 251.25}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 778.5, "y": 251.25}}], "viewport": {"x": -809.0753378899224, "y": 12.175368723983752, "zoom": 1.991880363841924}}	test	f15193f4-274a-4d8d-8c12-cd09066106a7
{"edges": [{"id": "reactflow__edge-7673b435-9ca3-4ba7-98bd-39aafee56f71-29147bb2-c29e-4a40-95fa-9e519df15219", "type": "step", "source": "7673b435-9ca3-4ba7-98bd-39aafee56f71", "target": "29147bb2-c29e-4a40-95fa-9e519df15219", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "77910f1e-c122-4234-ae24-fbaed1c12e9b", "data": {"name": "", "label": "sequence node", "configId": "87dad7cc-af55-47ad-8af3-910fd2ef31d9"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 265.6641957316101, "y": -132.17174712979815}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 265.6641957316101, "y": -132.17174712979815}}, {"id": "171fa248-27cc-4ed0-943a-75c95b170d8b", "data": {"name": "", "label": "sequence node", "configId": "87dad7cc-af55-47ad-8af3-910fd2ef31d9"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 381.03131865170917, "y": 161.2684359678585}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 381.03131865170917, "y": 161.2684359678585}}, {"id": "2b5e4e76-cedf-4df5-9c74-64057c03123d", "data": {"name": "", "label": "sequence node", "configId": "87dad7cc-af55-47ad-8af3-910fd2ef31d9"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 1006.2807551781635, "y": -185.0689505053772}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1006.2807551781635, "y": -185.0689505053772}}, {"id": "3be473ae-9ee9-4ab2-b565-f63e590bdaef", "data": {"name": "", "label": "sequence node", "configId": "87dad7cc-af55-47ad-8af3-910fd2ef31d9"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 369.6505977702537, "y": -396.38584916776455}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 369.6505977702537, "y": -396.38584916776455}}, {"id": "7673b435-9ca3-4ba7-98bd-39aafee56f71", "data": {"name": "", "type": "513f1829-5752-44ad-8f55-ecc01bcf1ad6|2", "label": "sequence node", "configId": "87dad7cc-af55-47ad-8af3-910fd2ef31d9"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 739.2661991179191, "y": -413.7836951535344}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 739.2661991179191, "y": -413.7836951535344}}, {"id": "29147bb2-c29e-4a40-95fa-9e519df15219", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "87dad7cc-af55-47ad-8af3-910fd2ef31d9"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 665.2947736331561, "y": -140.32300421523746}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 665.2947736331561, "y": -140.32300421523746}}], "viewport": {"x": -721.2362004585091, "y": 791.0857278677618, "zoom": 1.7893411652064442}}	jdas	87dad7cc-af55-47ad-8af3-910fd2ef31d9
{"edges": [{"id": "reactflow__edge-65d8ffb9-a8c5-43f7-b46d-d388a427dc1e-45c015e2-ae65-4816-a57b-bd9a2565ae2e", "type": "step", "source": "65d8ffb9-a8c5-43f7-b46d-d388a427dc1e", "target": "45c015e2-ae65-4816-a57b-bd9a2565ae2e", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "45c015e2-ae65-4816-a57b-bd9a2565ae2e", "data": {"name": "", "type": "9d39dfa7-5c87-49ab-bb4a-5c86be7aadba|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "c8c33e25-b71b-4c14-be14-cdfd1200c430"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 1721.203125, "y": 472.5}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1721.203125, "y": 472.5}}, {"id": "65d8ffb9-a8c5-43f7-b46d-d388a427dc1e", "data": {"name": "", "type": "2065a78d-6bda-4334-a39b-41fc36347adb|2", "label": "sequence node", "configId": "c8c33e25-b71b-4c14-be14-cdfd1200c430"}, "type": "sequence", "width": 152, "height": 207, "position": {"x": 1442.0546875, "y": 364.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1442.0546875, "y": 364.25}}], "viewport": {"x": -2003.90625, "y": -431.5, "zoom": 2}}	jfs	c8c33e25-b71b-4c14-be14-cdfd1200c430
{"edges": [{"id": "reactflow__edge-d2e4f718-75fe-4acd-980d-a8aade281983-952d08ce-58fb-4dfa-b93b-64a43734ed2a", "type": "step", "source": "d2e4f718-75fe-4acd-980d-a8aade281983", "target": "952d08ce-58fb-4dfa-b93b-64a43734ed2a", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "d2e4f718-75fe-4acd-980d-a8aade281983", "data": {"name": "", "type": "5fdefa66-a7b4-4106-9ed5-7e63039e12cc|2", "label": "sequence node", "configId": "4fad11ba-493f-4e26-aa1e-1aa39442b1c0"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 958.5546875, "y": 256}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 958.5546875, "y": 256}}, {"id": "952d08ce-58fb-4dfa-b93b-64a43734ed2a", "data": {"name": "", "type": "c4e13d9a-8913-4eec-8775-f9ffa6ca6594|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "4fad11ba-493f-4e26-aa1e-1aa39442b1c0"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 996.23046875, "y": 511}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 996.23046875, "y": 511}}], "viewport": {"x": -975.2578125, "y": -426, "zoom": 2}}	sdjfksd	4fad11ba-493f-4e26-aa1e-1aa39442b1c0
{"edges": [{"id": "reactflow__edge-cd64a271-f0bc-42a1-99d1-3a606a20ecd5-b941fd96-b6bf-40f0-8980-d4444d32cfd3", "type": "step", "source": "cd64a271-f0bc-42a1-99d1-3a606a20ecd5", "target": "b941fd96-b6bf-40f0-8980-d4444d32cfd3", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "b941fd96-b6bf-40f0-8980-d4444d32cfd3", "data": {"name": "", "type": "97fd0ff7-8057-4200-a981-04465f37db32|1undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "4c319b5b-640d-42f0-ba93-aab7927491ed"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 1389.203125, "y": 616}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1389.203125, "y": 616}}, {"id": "cd64a271-f0bc-42a1-99d1-3a606a20ecd5", "data": {"name": "", "type": "429f684b-c4a4-4d62-ade2-93abbfe1e5f4|3", "label": "sequence node", "configId": "4c319b5b-640d-42f0-ba93-aab7927491ed"}, "type": "sequence", "width": 172, "height": 207, "position": {"x": 1182.5546875, "y": 317.75}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1182.5546875, "y": 317.75}}], "viewport": {"x": -1697.90625, "y": -560.5, "zoom": 2}}		4c319b5b-640d-42f0-ba93-aab7927491ed
{"edges": [{"id": "reactflow__edge-87b34628-9640-4229-a780-8dec5f04c476-b2f69d63-30c7-4d2f-b0e5-08e9c871a622", "type": "step", "source": "87b34628-9640-4229-a780-8dec5f04c476", "target": "b2f69d63-30c7-4d2f-b0e5-08e9c871a622", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "b2f69d63-30c7-4d2f-b0e5-08e9c871a622", "data": {"name": "", "type": "Type 2|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "4425dbb3-5faa-4426-adf7-2f3db4efdf2a"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 1728.203125, "y": 635.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1728.203125, "y": 635.5}}, {"id": "87b34628-9640-4229-a780-8dec5f04c476", "data": {"name": "", "type": "8228f7c7-e28c-4681-9272-5789e05fb244|2", "label": "sequence node", "configId": "4425dbb3-5faa-4426-adf7-2f3db4efdf2a"}, "type": "sequence", "width": 152, "height": 207, "position": {"x": 1393.0546875, "y": 592.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1393.0546875, "y": 592.25}}], "viewport": {"x": -2184.191263115167, "y": -502.5228125359922, "zoom": 1.6044925074556433}}	djas	4425dbb3-5faa-4426-adf7-2f3db4efdf2a
{"edges": [{"id": "reactflow__edge-e745f5d4-e26c-4ca1-957c-dcafe4d26e50-577cbf1a-ec50-4fb3-aa7a-f195ea4609d3", "type": "step", "source": "e745f5d4-e26c-4ca1-957c-dcafe4d26e50", "target": "577cbf1a-ec50-4fb3-aa7a-f195ea4609d3", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "577cbf1a-ec50-4fb3-aa7a-f195ea4609d3", "data": {"name": "", "type": "Type 3", "label": "controlModule node", "seqType": "c|1", "configId": "bb364975-66b0-4dd6-b7ea-c9f189226b0a"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 828.984375, "y": 517.5}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 828.984375, "y": 517.5}}, {"id": "e745f5d4-e26c-4ca1-957c-dcafe4d26e50", "data": {"name": "", "type": "404f2c11-ad5a-403f-b1ec-acd47c4d6d75|2", "label": "sequence node", "configId": "bb364975-66b0-4dd6-b7ea-c9f189226b0a"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 674.4765625, "y": 277.25}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 674.4765625, "y": 277.25}}], "viewport": {"x": -1242.9609375, "y": -353.25, "zoom": 2}}	jsdakdljaksd	bb364975-66b0-4dd6-b7ea-c9f189226b0a
{"edges": [{"id": "reactflow__edge-83227167-db73-4e08-b722-3638c0e1a7fb-208b1e88-75f8-480f-8bc8-e45b2e358fce", "type": "step", "source": "83227167-db73-4e08-b722-3638c0e1a7fb", "target": "208b1e88-75f8-480f-8bc8-e45b2e358fce", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "83227167-db73-4e08-b722-3638c0e1a7fb", "data": {"name": "", "type": "066ea752-c8a7-44f0-8eda-d25cb3877c7f|3", "label": "sequence node", "configId": "8989689c-4713-4fdd-8fc6-09031e7db66a"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 860.703125, "y": 420.5}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 860.703125, "y": 420.5}}, {"id": "208b1e88-75f8-480f-8bc8-e45b2e358fce", "data": {"name": "", "type": "Type 2", "label": "controlModule node", "seqType": "c|1", "configId": "8989689c-4713-4fdd-8fc6-09031e7db66a"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 1381.0546875, "y": 605.75}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1381.0546875, "y": 605.75}}], "viewport": {"x": -1433.2578125, "y": -584.75, "zoom": 2}}	dkals;da	8989689c-4713-4fdd-8fc6-09031e7db66a
{"edges": [{"id": "reactflow__edge-fedc0a6c-1a94-4924-b13a-506688463950-cdab627c-2bb6-4766-8017-814ce68dd21f", "type": "step", "source": "fedc0a6c-1a94-4924-b13a-506688463950", "target": "cdab627c-2bb6-4766-8017-814ce68dd21f", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "cdab627c-2bb6-4766-8017-814ce68dd21f", "data": {"name": "", "type": "01a43aa6-ec37-4f8d-9712-924f510424d2|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "102a17e1-d304-4dcc-8c9f-5da87081251b"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 662.484375, "y": 582.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 662.484375, "y": 582.5}}, {"id": "fedc0a6c-1a94-4924-b13a-506688463950", "data": {"name": "", "type": "04ff3b9b-92cc-45a1-b57d-1fa4cd991b7d|2", "label": "sequence node", "configId": "102a17e1-d304-4dcc-8c9f-5da87081251b"}, "type": "sequence", "width": 152, "height": 207, "position": {"x": 577.9765625, "y": 307.25}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 577.9765625, "y": 307.25}}], "viewport": {"x": -431.9609375, "y": -448.25, "zoom": 2}}	djasajjada	102a17e1-d304-4dcc-8c9f-5da87081251b
{"edges": [], "nodes": [{"id": "d803a608-a43b-4a4f-8c73-ab01bcf94250", "data": {"name": "Control Module", "type": "7403ae23-09f9-4346-80da-0accf11657ea|1|1", "color": "#871212", "label": "controlModule node", "seqType": "c|1", "configId": "9ac841fb-5753-4c6f-8299-a20322750272"}, "type": "controlModule", "width": 300, "height": 239, "dragging": false, "position": {"x": 503.765625, "y": 323}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 503.765625, "y": 323}}], "viewport": {"x": -787.53125, "y": -239, "zoom": 2}}	cringe	9ac841fb-5753-4c6f-8299-a20322750272
{"edges": [], "nodes": [{"id": "4bf5c74d-d61d-4136-9acb-2128ce9d8af0", "data": {"name": "", "type": "7e79f38e-f3cf-47ea-bd7f-4984ab4a2a04|1|1", "color": "#3b2b2b", "label": "controlModule node", "seqType": "c|1", "configId": "5e13950d-0be4-4c3a-843e-f7c549259a28"}, "type": "controlModule", "width": 300, "height": 239, "dragging": false, "position": {"x": 767.765625, "y": 213.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 767.765625, "y": 213.5}}], "viewport": {"x": -1316.53125, "y": -24, "zoom": 2}}	null	5e13950d-0be4-4c3a-843e-f7c549259a28
null	sdf	f216bbe8-64f7-414b-aaa6-dafe11af26bd
{"edges": [], "nodes": [{"id": "8d9952c8-8868-4b67-9da2-25478e5e848c", "data": {"name": "", "type": "33ae749c-3978-414a-a53d-7a38af168302|1|1|1|1|1|1", "color": "#18622b", "label": "controlModule node", "seqType": "c|1", "configId": "284de2db-6bdd-4ac3-88ab-4f42533eb675"}, "type": "controlModule", "width": 300, "height": 239, "dragging": false, "position": {"x": 587.265625, "y": 540}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 587.265625, "y": 540}}, {"id": "da627e5d-5543-4e45-b5e9-0f4ac41f6751", "data": {"name": "", "color": "#931515", "label": "sequence node", "configId": "284de2db-6bdd-4ac3-88ab-4f42533eb675"}, "type": "sequence", "width": 251, "height": 239, "dragging": false, "position": {"x": 760.1484375, "y": 279.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 760.1484375, "y": 279.5}}], "viewport": {"x": -943.9140625, "y": -410.5, "zoom": 2}}	dsljkdsajlksa	284de2db-6bdd-4ac3-88ab-4f42533eb675
{"edges": [], "nodes": [{"id": "67f846be-3d8b-4af9-ae8d-3c18b455a368", "data": {"name": "", "type": "undefined|1", "label": "controlModule node", "seqType": "c|1", "configId": "2e7e66cd-6acf-459c-b6b9-f330bcab431a"}, "type": "controlModule", "width": 300, "height": 239, "position": {"x": 580.765625, "y": 369}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 580.765625, "y": 369}}], "viewport": {"x": -942.53125, "y": -335, "zoom": 2}}	null	2e7e66cd-6acf-459c-b6b9-f330bcab431a
{"edges": [{"id": "reactflow__edge-19c35b43-d931-4a8f-80d5-368e735cbcac-3952e9fa-b636-47aa-8a55-a46913da429d", "type": "step", "source": "19c35b43-d931-4a8f-80d5-368e735cbcac", "target": "3952e9fa-b636-47aa-8a55-a46913da429d", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "3952e9fa-b636-47aa-8a55-a46913da429d", "data": {"name": "", "type": "4c90efd8-db30-4d43-87e2-74c91f74a064|1|1", "color": "#df0101", "label": "controlModule node", "seqType": "c|1", "configId": "169715f2-ba5f-400d-a5ce-6e1c808ccf8f"}, "type": "controlModule", "width": 300, "height": 207, "position": {"x": 728.375, "y": 409}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 728.375, "y": 409}}, {"id": "19c35b43-d931-4a8f-80d5-368e735cbcac", "data": {"name": "", "type": "0546c00a-e941-4708-b071-5a921953610f|2", "color": "#322929", "label": "sequence node", "configId": "169715f2-ba5f-400d-a5ce-6e1c808ccf8f"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 656.8125, "y": 134.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 656.8125, "y": 134.5}}], "viewport": {"x": -1167.25, "y": -214, "zoom": 2}}	jkskjalsdsa	169715f2-ba5f-400d-a5ce-6e1c808ccf8f
{"edges": [{"id": "reactflow__edge-0f48c6ee-66f2-43c6-88fe-abdf65282cec-95b4e309-ae30-456d-aede-4424de5f9280", "type": "step", "source": "0f48c6ee-66f2-43c6-88fe-abdf65282cec", "target": "95b4e309-ae30-456d-aede-4424de5f9280", "animated": true, "selected": false, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-8f5ce1ed-9359-400d-80b1-07b9832284c2-95b4e309-ae30-456d-aede-4424de5f9280", "type": "step", "source": "8f5ce1ed-9359-400d-80b1-07b9832284c2", "target": "95b4e309-ae30-456d-aede-4424de5f9280", "animated": true, "selected": false, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-0f48c6ee-66f2-43c6-88fe-abdf65282cec-14e646cd-4413-494e-9c27-659124344625", "type": "step", "source": "0f48c6ee-66f2-43c6-88fe-abdf65282cec", "target": "14e646cd-4413-494e-9c27-659124344625", "animated": true, "selected": false, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-8f5ce1ed-9359-400d-80b1-07b9832284c2-14e646cd-4413-494e-9c27-659124344625", "type": "step", "source": "8f5ce1ed-9359-400d-80b1-07b9832284c2", "target": "14e646cd-4413-494e-9c27-659124344625", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "0f48c6ee-66f2-43c6-88fe-abdf65282cec", "data": {"name": "Chocolate", "type": "6f65b22f-5f24-4d3a-ae20-41036198d42d|2", "color": "#056d03", "label": "sequence node", "configId": "efb30bbc-3493-4471-b82c-ed73ee400bd0"}, "type": "sequence", "width": 156, "height": 207, "dragging": false, "position": {"x": 188.5471329597142, "y": 370.04984274047735}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 188.5471329597142, "y": 370.04984274047735}}, {"id": "95b4e309-ae30-456d-aede-4424de5f9280", "data": {"name": "Brownies", "type": "Type 1", "color": "#130c4b", "label": "controlModule node", "seqType": "c|1", "configId": "efb30bbc-3493-4471-b82c-ed73ee400bd0"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 276.703125, "y": 748}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 276.703125, "y": 748}}, {"id": "8f5ce1ed-9359-400d-80b1-07b9832284c2", "data": {"name": "Eggs", "type": "b3aef097-977c-4626-9bf0-b9c668ccc34d|3", "color": "#4d758f", "label": "sequence node", "configId": "efb30bbc-3493-4471-b82c-ed73ee400bd0"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 604.4859599820184, "y": 334.2355742476019}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 604.4859599820184, "y": 334.2355742476019}}, {"id": "14e646cd-4413-494e-9c27-659124344625", "data": {"name": "Cupcakes", "type": "Type 3", "color": "#99e000", "label": "controlModule node", "seqType": "c|1", "configId": "efb30bbc-3493-4471-b82c-ed73ee400bd0"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 735.6336049910092, "y": 729.367787123801}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 735.6336049910092, "y": 729.367787123801}}], "viewport": {"x": 137.31426448094476, "y": 4.858666811598823, "zoom": 0.9999999999999999}}	ajdass	efb30bbc-3493-4471-b82c-ed73ee400bd0
null	sdasdasjkdadajadms	8d6fec05-f9f6-4ae2-ae7b-050f7f5fdf15
null	null	b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe
{"edges": [], "nodes": [{"id": "a73a2ad6-2009-45fd-9c56-96c0a7cba118", "data": {"name": "", "type": "90b55097-47ce-496a-b11d-27d907b83b9d|1", "color": "#7aae9a", "label": "sequence node", "configId": "57975338-f4f2-401a-99c3-deae730dec68"}, "type": "sequence", "width": 208, "height": 207, "dragging": false, "position": {"x": 785.703125, "y": 241}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 785.703125, "y": 241}}, {"id": "7c998fc5-a4ff-4a74-af69-fea187d5ebcb", "data": {"name": "", "type": "5b0b8085-ea99-499f-9d84-5967dc424408|1|1", "color": "#c91818", "label": "controlModule node", "seqType": "c|1", "configId": "57975338-f4f2-401a-99c3-deae730dec68"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 1234.5792840799616, "y": 215.143447434971}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1234.5792840799616, "y": 215.143447434971}}, {"id": "b748b626-fc86-4591-a072-2d872187c009", "data": {"name": "", "type": "5b0b8085-ea99-499f-9d84-5967dc424408|1|1|1|1|1|1|1|1|1", "color": "#5a1616", "label": "controlModule node", "seqType": "c|1", "configId": "57975338-f4f2-401a-99c3-deae730dec68"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 802.0546875, "y": 492.25}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 802.0546875, "y": 492.25}}, {"id": "752378ca-0bfb-43f2-981f-bb0fecedc198", "data": {"name": "", "type": "undefined|1", "color": "#672222", "label": "controlModule node", "seqType": "c|1", "configId": "57975338-f4f2-401a-99c3-deae730dec68"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 1186.4927670399807, "y": 488.625}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1186.4927670399807, "y": 488.625}}], "viewport": {"x": -1262.7824090799613, "y": -265.893447434971, "zoom": 2}}	bob	57975338-f4f2-401a-99c3-deae730dec68
null	p[osdfkjsfsdfksdfsd	096cca07-3a2b-4775-9d39-a83aa3919314
{"edges": [{"id": "reactflow__edge-f9eecb16-c28b-4a0e-9952-1cdc48b86ba1-aa7bf986-1f40-4839-963e-51013fa08ae2", "type": "step", "source": "f9eecb16-c28b-4a0e-9952-1cdc48b86ba1", "target": "aa7bf986-1f40-4839-963e-51013fa08ae2", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "f9eecb16-c28b-4a0e-9952-1cdc48b86ba1", "data": {"name": "", "type": "36632018-db5e-4e67-a06b-805252c15ed5|2", "color": "#b80000", "label": "sequence node", "configId": "01cbdbb7-c816-48c5-bc45-54f77c02ce94"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 616, "y": 223}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 616, "y": 223}}, {"id": "aa7bf986-1f40-4839-963e-51013fa08ae2", "data": {"name": "", "type": "dfcf27c6-33a4-4f86-8373-5c4371f2c51e|1|1|1", "color": "#1c1212", "label": "controlModule node", "seqType": "c|1", "configId": "01cbdbb7-c816-48c5-bc45-54f77c02ce94"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 903, "y": 325.75}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 903, "y": 325.75}}, {"id": "ae6cfcb9-f2e5-4e89-bed7-03346ef91cef", "data": {"name": "Control Module", "type": "undefined|1", "color": "#621818", "label": "controlModule node", "seqType": "c|1", "configId": "01cbdbb7-c816-48c5-bc45-54f77c02ce94"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 656.9568172179813, "y": 760.146925360475}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 656.9568172179813, "y": 760.146925360475}}], "viewport": {"x": -988.2598899673819, "y": -1190.7454319150288, "zoom": 2}}	djsadkasdaksjsadklajdkasldjaskjdajksdjalkajsdaa	01cbdbb7-c816-48c5-bc45-54f77c02ce94
null	null	b1116ac2-387f-491d-ab5d-37650f795e73
null	null	29ce550d-f862-4ac7-80b7-225b8e9bc863
null	null	34a01fa6-de45-48d3-a231-f33062a3ec0a
null	sdjasjk	681c56b0-88ae-46ee-9b4d-223dd6211ab2
\.


--
-- Data for Name: alarms; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.alarms (sequuid, alarmuuid, name, description, type) FROM stdin;
\.


--
-- Data for Name: subsequences; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.subsequences (sequuid, subsequuid, plcid, seqsubsequuid) FROM stdin;
\.


--
-- Data for Name: configurations; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.configurations (topicuuid, configuuid, name, description, plcid) FROM stdin;
14f38f2c-97c2-46af-b79a-07672eb2f94e	efb30bbc-3493-4471-b82c-ed73ee400bd0	ajdass		1
14f38f2c-97c2-46af-b79a-07672eb2f94e	57975338-f4f2-401a-99c3-deae730dec68	bob		2
14f38f2c-97c2-46af-b79a-07672eb2f94e	9ac841fb-5753-4c6f-8299-a20322750272	cringe		3
14f38f2c-97c2-46af-b79a-07672eb2f94e	5e13950d-0be4-4c3a-843e-f7c549259a28	null		4
14f38f2c-97c2-46af-b79a-07672eb2f94e	f216bbe8-64f7-414b-aaa6-dafe11af26bd	sdf		5
14f38f2c-97c2-46af-b79a-07672eb2f94e	2e7e66cd-6acf-459c-b6b9-f330bcab431a	null		6
14f38f2c-97c2-46af-b79a-07672eb2f94e	284de2db-6bdd-4ac3-88ab-4f42533eb675	dsljkdsajlksa		7
14f38f2c-97c2-46af-b79a-07672eb2f94e	b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	null		8
14f38f2c-97c2-46af-b79a-07672eb2f94e	169715f2-ba5f-400d-a5ce-6e1c808ccf8f	jkskjalsdsa		9
14f38f2c-97c2-46af-b79a-07672eb2f94e	b1116ac2-387f-491d-ab5d-37650f795e73	null		10
14f38f2c-97c2-46af-b79a-07672eb2f94e	29ce550d-f862-4ac7-80b7-225b8e9bc863	null		11
14f38f2c-97c2-46af-b79a-07672eb2f94e	34a01fa6-de45-48d3-a231-f33062a3ec0a	null		12
14f38f2c-97c2-46af-b79a-07672eb2f94e	681c56b0-88ae-46ee-9b4d-223dd6211ab2	sdjasjk		13
\.


--
-- Data for Name: controlmodules; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.controlmodules (configuuid, cmuuid, type, name, description) FROM stdin;
\.


--
-- Data for Name: sequences; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.sequences (configuuid, sequuid, name, description, type) FROM stdin;
\.


--
-- Data for Name: steps; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.steps (sequuid, stepuuid, type, name, description) FROM stdin;
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.topics (topicuuid, name, description) FROM stdin;
14f38f2c-97c2-46af-b79a-07672eb2f94e	bsu	ball
\.


--
-- Data for Name: alarmtypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.alarmtypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- Data for Name: controlmoduletypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.controlmoduletypes (configuuid, typeuuid, name) FROM stdin;
efb30bbc-3493-4471-b82c-ed73ee400bd0	1537c04a-3514-44e4-ae40-72316a014e37	Type 1
efb30bbc-3493-4471-b82c-ed73ee400bd0	51dc5ade-e1a5-4aa3-b1dd-773ba9f1a613	Type 2
efb30bbc-3493-4471-b82c-ed73ee400bd0	91630cb1-c932-4c65-9a69-1cc66389a8ee	Type 3
efb30bbc-3493-4471-b82c-ed73ee400bd0	36decc00-68e0-4a88-9e19-4f420de7e014	Type 4
57975338-f4f2-401a-99c3-deae730dec68	5b0b8085-ea99-499f-9d84-5967dc424408	Type 1
57975338-f4f2-401a-99c3-deae730dec68	91f806c3-9fdc-4a68-9911-55247f738acf	Type 2
57975338-f4f2-401a-99c3-deae730dec68	03163328-ba5f-496e-8473-b643f893b18e	Type 3
57975338-f4f2-401a-99c3-deae730dec68	d9060f7d-f481-4073-819d-bbfd0fdd2ec3	Type 4
9ac841fb-5753-4c6f-8299-a20322750272	7403ae23-09f9-4346-80da-0accf11657ea	Type 1
9ac841fb-5753-4c6f-8299-a20322750272	2d765d35-8ffc-4564-9d2d-fd806fec84cb	Type 2
9ac841fb-5753-4c6f-8299-a20322750272	7be61735-d5db-4155-a3be-9429beb41888	Type 3
9ac841fb-5753-4c6f-8299-a20322750272	b0a4d4d4-39d5-4085-9464-f105e38e2954	Type 4
5e13950d-0be4-4c3a-843e-f7c549259a28	7e79f38e-f3cf-47ea-bd7f-4984ab4a2a04	Type 1
5e13950d-0be4-4c3a-843e-f7c549259a28	455c23fb-9ff2-4b13-97ec-e7c71c4c6cbc	Type 2
5e13950d-0be4-4c3a-843e-f7c549259a28	c2bfce3a-7ea0-4e65-a7f3-1b44d476bc27	Type 3
5e13950d-0be4-4c3a-843e-f7c549259a28	ff848bb0-1b3b-42bf-8395-b200d702ad79	Type 4
f216bbe8-64f7-414b-aaa6-dafe11af26bd	07312906-e99b-4976-bdd9-9f676f7d4d23	Type 1
f216bbe8-64f7-414b-aaa6-dafe11af26bd	b882ea80-f6d8-4abf-9ef7-b5de7ef94bd2	Type 2
f216bbe8-64f7-414b-aaa6-dafe11af26bd	c4f35163-8d08-40c7-867d-ebbe744e3f7e	Type 3
f216bbe8-64f7-414b-aaa6-dafe11af26bd	7fa04f33-f023-40fa-b27d-7bff759b64db	Type 4
2e7e66cd-6acf-459c-b6b9-f330bcab431a	b657f605-2759-4bd3-88dc-f45eb13cbf4b	Type 1
2e7e66cd-6acf-459c-b6b9-f330bcab431a	9c603ae6-5c7d-420e-a2cc-20606b3ed52c	Type 2
2e7e66cd-6acf-459c-b6b9-f330bcab431a	89597612-2573-498a-94e6-64c9e9d081d8	Type 3
2e7e66cd-6acf-459c-b6b9-f330bcab431a	5ba1ff8e-ad58-451e-ace4-6516f5f51f59	Type 4
284de2db-6bdd-4ac3-88ab-4f42533eb675	5c139a2f-dfe0-4727-9298-19a938f74284	Type 1
284de2db-6bdd-4ac3-88ab-4f42533eb675	33ae749c-3978-414a-a53d-7a38af168302	Type 2
284de2db-6bdd-4ac3-88ab-4f42533eb675	ba6c44d5-216a-4614-aaeb-3ec6db3458b2	Type 3
284de2db-6bdd-4ac3-88ab-4f42533eb675	c118e739-97a4-436c-a7f5-16534d7e86b8	Type 4
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	3fcf5099-012b-464f-8cd2-c6dc0e2428c5	Type 1
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	40d673dc-1e50-4e4e-b1de-626b94c19a1a	Type 2
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	34865286-60bb-4ba3-b5eb-ad801d539aa5	Type 3
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	3037d17c-eb80-4798-9366-b5e1cfd875bb	Type 4
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	e0b20d37-0b40-4319-8846-4a13570c6555	Type 1
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	4c90efd8-db30-4d43-87e2-74c91f74a064	Type 2
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	aab2d7d0-57ff-45dd-9b89-c07f18842fd5	Type 3
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	d95cceb4-f3fa-4525-8e25-da4c3ea928be	Type 4
b1116ac2-387f-491d-ab5d-37650f795e73	b1d78d94-118b-4874-b49a-746020a306fb	Type 1
b1116ac2-387f-491d-ab5d-37650f795e73	7d8ac7b5-131a-444c-adbd-d14a5353d5ea	Type 2
b1116ac2-387f-491d-ab5d-37650f795e73	ed99c9b2-629e-4270-8f5b-5b934b3c0969	Type 3
b1116ac2-387f-491d-ab5d-37650f795e73	98666cc7-89da-4185-b401-3a7ecf6a8496	Type 4
29ce550d-f862-4ac7-80b7-225b8e9bc863	9b8eb302-c126-4a6b-8706-e0bd5f07971b	Type 1
29ce550d-f862-4ac7-80b7-225b8e9bc863	d5a4dfc2-e0f2-42a8-990e-df7fe351f55d	Type 2
29ce550d-f862-4ac7-80b7-225b8e9bc863	8622ef01-31a6-4be5-9d69-2634bbee38f7	Type 3
29ce550d-f862-4ac7-80b7-225b8e9bc863	0e6fa6fc-169a-4324-a6a7-e36d4cec2238	Type 4
34a01fa6-de45-48d3-a231-f33062a3ec0a	c554f38e-8176-431d-857b-215c901c106d	Type 1
34a01fa6-de45-48d3-a231-f33062a3ec0a	35b674d2-f896-4f8c-b866-e48a56205cbb	Type 2
34a01fa6-de45-48d3-a231-f33062a3ec0a	c1dff9f7-34dc-46b3-970b-93ed02a9f6f6	Type 3
34a01fa6-de45-48d3-a231-f33062a3ec0a	532936af-049e-43c9-acf2-0ac542016286	Type 4
681c56b0-88ae-46ee-9b4d-223dd6211ab2	2b75a21a-9747-43f6-bcc0-280579544200	Type 1
681c56b0-88ae-46ee-9b4d-223dd6211ab2	ab00ebd1-9e08-4edc-a801-6476ebda3e71	Type 2
681c56b0-88ae-46ee-9b4d-223dd6211ab2	2b679f89-6d08-4d3c-bd63-a965ef44f897	Type 3
681c56b0-88ae-46ee-9b4d-223dd6211ab2	b97c9c58-3d65-4d54-8e8e-d649c68e305f	Type 4
\.


--
-- Data for Name: sequencetypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.sequencetypes (configuuid, typeuuid, name, plcid) FROM stdin;
b1116ac2-387f-491d-ab5d-37650f795e73	6a45acce-1832-4780-a28a-5890241aebb6	Control Module	1
b1116ac2-387f-491d-ab5d-37650f795e73	edd5f574-a16d-419c-981a-52eaa785b0ac	Phase	2
b1116ac2-387f-491d-ab5d-37650f795e73	7207683e-646f-4281-be62-6a811ba8f03d	Operation	3
b1116ac2-387f-491d-ab5d-37650f795e73	b0feafa7-9bf6-4683-ab50-5a433daa614c	Procedure	4
34a01fa6-de45-48d3-a231-f33062a3ec0a	6bcd2b67-9fe9-474d-95d9-c32bb57fad5e	Control Module	1
34a01fa6-de45-48d3-a231-f33062a3ec0a	598ae642-aaf7-4aeb-8a58-13fbd404a3ae	Phase	2
34a01fa6-de45-48d3-a231-f33062a3ec0a	9181e2ae-5a0f-4170-b921-42257d7a92c6	Operation	3
34a01fa6-de45-48d3-a231-f33062a3ec0a	180f9e8e-fe0e-41f6-84cb-cd75176714a6	Procedure	4
57975338-f4f2-401a-99c3-deae730dec68	90b55097-47ce-496a-b11d-27d907b83b9d	Control Module	1
57975338-f4f2-401a-99c3-deae730dec68	8e983e0d-d812-4ce0-aced-085e9a8e8d44	Phase	2
57975338-f4f2-401a-99c3-deae730dec68	a0c571b7-b32a-45cb-b6a4-37bb4a13158d	Operation	3
57975338-f4f2-401a-99c3-deae730dec68	537f571d-259c-466c-9c87-efd509034b6a	Procedure	4
5e13950d-0be4-4c3a-843e-f7c549259a28	3f0670d9-b171-4161-892f-0b93d731e30e	Control Module	1
5e13950d-0be4-4c3a-843e-f7c549259a28	55498365-6cb0-4ecd-9833-38077fbd3c7f	Phase	2
5e13950d-0be4-4c3a-843e-f7c549259a28	2b6ccd89-875b-406e-a82c-6eb1e7e0e282	Operation	3
5e13950d-0be4-4c3a-843e-f7c549259a28	9089823c-02eb-4f5a-8d0b-cc11952ffc5c	Procedure	4
2e7e66cd-6acf-459c-b6b9-f330bcab431a	5cc9e0e6-4916-48cb-8b9f-4799196751ac	Control Module	1
2e7e66cd-6acf-459c-b6b9-f330bcab431a	faadaf83-5a51-40ca-a9a4-3381cc5486fa	Phase	2
2e7e66cd-6acf-459c-b6b9-f330bcab431a	607752d5-3415-45f9-a911-d82d8278ab9b	Operation	3
2e7e66cd-6acf-459c-b6b9-f330bcab431a	288d86e1-a446-453e-8640-9fb21c54d2ed	Procedure	4
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	745085a2-ab2b-4a40-af8b-41d20d0a8cdf	Control Module	1
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	9e74028e-7684-482c-80b8-783ebe8a149f	Phase	2
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	e4edccfb-106d-4a9f-87d3-28b609cc68a7	Operation	3
b2ae2ff1-bfb3-45a1-9eae-523349c9bcfe	21b10de6-f8d8-4ac2-9d6d-e04def5e25cd	Procedure	4
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	6d80a963-b107-4d5a-a01b-a96398c6ae4a	Control Module	1
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	0546c00a-e941-4708-b071-5a921953610f	Phase	2
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	68bf3e2f-079e-47d4-b4cc-5f72b09f08e4	Operation	3
169715f2-ba5f-400d-a5ce-6e1c808ccf8f	1aa827f2-8feb-4acc-816b-894501f29952	Procedure	4
29ce550d-f862-4ac7-80b7-225b8e9bc863	bd6b87cf-92e4-42d0-83ba-a1aaa25c75a1	Control Module	1
29ce550d-f862-4ac7-80b7-225b8e9bc863	40294b6f-07b7-4b7f-8524-1f25fa105a6b	Phase	2
29ce550d-f862-4ac7-80b7-225b8e9bc863	2265e65d-5ac8-46e2-bfa8-86a806819ddc	Operation	3
29ce550d-f862-4ac7-80b7-225b8e9bc863	2ee12152-ef34-4d81-80f5-0ded579109e0	Procedure	4
681c56b0-88ae-46ee-9b4d-223dd6211ab2	a5d84068-471b-47f2-a244-350f2df4bd73	Control Module	1
681c56b0-88ae-46ee-9b4d-223dd6211ab2	abf80b2d-c923-496d-a6b6-5224a990e2e0	Phase	2
681c56b0-88ae-46ee-9b4d-223dd6211ab2	746bbcac-eba7-41f9-9753-d8c38ef6d979	Operation	3
681c56b0-88ae-46ee-9b4d-223dd6211ab2	12022e04-167d-42ed-a0a7-e2f0b7d0bfb9	Procedure	4
efb30bbc-3493-4471-b82c-ed73ee400bd0	66e9a644-653f-494d-9100-172a582b22dc	Control Module	1
efb30bbc-3493-4471-b82c-ed73ee400bd0	6f65b22f-5f24-4d3a-ae20-41036198d42d	Phase	2
efb30bbc-3493-4471-b82c-ed73ee400bd0	b3aef097-977c-4626-9bf0-b9c668ccc34d	Operation	3
efb30bbc-3493-4471-b82c-ed73ee400bd0	12d8e84f-3110-40ae-ba96-f8d44d1a30d8	Procedure	4
9ac841fb-5753-4c6f-8299-a20322750272	36d784b9-fbc9-444d-8646-1183124a2c68	Control Module	1
9ac841fb-5753-4c6f-8299-a20322750272	ebd5980b-8032-49dc-b410-ef0e4f91a101	Phase	2
9ac841fb-5753-4c6f-8299-a20322750272	548ba38e-65d9-4f56-b65c-64ac80aa1483	Operation	3
9ac841fb-5753-4c6f-8299-a20322750272	f0157a54-90c3-4ae0-b8ef-1986f1d06956	Procedure	4
f216bbe8-64f7-414b-aaa6-dafe11af26bd	dbf44b6b-13cc-4416-9f5f-c1bf481ff9f2	Control Module	1
f216bbe8-64f7-414b-aaa6-dafe11af26bd	854622e3-bef5-43cf-b441-458f224aa618	Phase	2
f216bbe8-64f7-414b-aaa6-dafe11af26bd	84d71ef5-0c45-4624-ae37-ef5ede5c8b5b	Operation	3
f216bbe8-64f7-414b-aaa6-dafe11af26bd	5c35e398-0e00-4266-8a8b-9f8c5e379b99	Procedure	4
284de2db-6bdd-4ac3-88ab-4f42533eb675	8b1a5c34-6db0-415b-a7ec-5270a1d46e3d	Control Module	1
284de2db-6bdd-4ac3-88ab-4f42533eb675	1109c1b1-705f-4f62-85c1-c06a395fd22f	Phase	2
284de2db-6bdd-4ac3-88ab-4f42533eb675	2c9cf4ed-882f-4ab9-a4a2-7bf6c9453331	Operation	3
284de2db-6bdd-4ac3-88ab-4f42533eb675	8af1b774-7c2b-4b2f-8ffa-ec1f43f40a7c	Procedure	4
\.


--
-- Name: subsequences subseq_pk; Type: CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT subseq_pk PRIMARY KEY (seqsubsequuid);


--
-- Name: configurations configurations_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_pk PRIMARY KEY (configuuid);


--
-- Name: controlmodules controlmodules_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_pk PRIMARY KEY (cmuuid);


--
-- Name: sequences sequences_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_pk PRIMARY KEY (sequuid);


--
-- Name: steps steps_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_pk PRIMARY KEY (stepuuid);


--
-- Name: topics topics_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.topics
    ADD CONSTRAINT topics_pk PRIMARY KEY (topicuuid);


--
-- Name: alarmtypes alarmtypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_pk PRIMARY KEY (typeuuid);


--
-- Name: controlmoduletypes controlmoduletypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_pk PRIMARY KEY (typeuuid);


--
-- Name: sequencetypes sequencetypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_pk PRIMARY KEY (typeuuid);


--
-- Name: alarms alarm_type_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarm_type_fk FOREIGN KEY (type) REFERENCES types.alarmtypes(typeuuid);


--
-- Name: alarms alarms_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarms_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- Name: subsequences seq_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT seq_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid) ON DELETE CASCADE;


--
-- Name: subsequences subseq_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT subseq_fk FOREIGN KEY (subsequuid) REFERENCES setup.sequences(sequuid) ON DELETE CASCADE;


--
-- Name: configurations configurations_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_fk FOREIGN KEY (topicuuid) REFERENCES setup.topics(topicuuid) ON DELETE CASCADE;


--
-- Name: controlmodules controlmodule_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodule_type_fk FOREIGN KEY (type) REFERENCES types.controlmoduletypes(typeuuid);


--
-- Name: controlmodules controlmodules_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- Name: sequences sequence_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequence_type_fk FOREIGN KEY (type) REFERENCES types.sequencetypes(typeuuid);


--
-- Name: sequences sequences_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- Name: steps steps_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- Name: alarmtypes alarmtypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- Name: controlmoduletypes controlmoduletypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- Name: sequencetypes sequencetypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- PostgreSQL database dump complete
--

