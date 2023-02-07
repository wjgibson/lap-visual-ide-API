--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

-- Started on 2023-02-06 21:04:31

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
-- TOC entry 8 (class 2615 OID 17288)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 6 (class 2615 OID 17289)
-- Name: reactflow; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA reactflow;


ALTER SCHEMA reactflow OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 17290)
-- Name: sequenceconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sequenceconfig;


ALTER SCHEMA sequenceconfig OWNER TO postgres;

--
-- TOC entry 4 (class 2615 OID 17291)
-- Name: setup; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA setup;


ALTER SCHEMA setup OWNER TO postgres;

--
-- TOC entry 5 (class 2615 OID 17292)
-- Name: stepconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stepconfig;


ALTER SCHEMA stepconfig OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 17293)
-- Name: types; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA types;


ALTER SCHEMA types OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 17294)
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
-- TOC entry 423 (class 1255 OID 17295)
-- Name: add_config(uuid, character varying, jsonb); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.add_config(topic uuid, name character varying, rfdata jsonb) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
    declare        config uuid;    
    BEGIN         
	    insert into setup.configurations (topicuuid,"name" ,description, plcid) values (topic,name,'', (select setup.find_missing_id_for_config())) returning configuuid into config;         
	    insert into reactflow.reactflowdata (json, "name", cid) values (rfdata, name, config);        
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
-- TOC entry 238 (class 1255 OID 17296)
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
-- TOC entry 242 (class 1255 OID 17297)
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
-- TOC entry 239 (class 1255 OID 17298)
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
-- TOC entry 240 (class 1255 OID 17299)
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
-- TOC entry 241 (class 1255 OID 17300)
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
-- TOC entry 422 (class 1255 OID 18088)
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
-- TOC entry 215 (class 1259 OID 17301)
-- Name: reactflowdata; Type: TABLE; Schema: reactflow; Owner: postgres
--

CREATE TABLE reactflow.reactflowdata (
    json jsonb,
    name character varying NOT NULL,
    cid uuid NOT NULL
);


ALTER TABLE reactflow.reactflowdata OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17306)
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
-- TOC entry 225 (class 1259 OID 18064)
-- Name: subsequences; Type: TABLE; Schema: sequenceconfig; Owner: postgres
--

CREATE TABLE sequenceconfig.subsequences (
    sequuid uuid NOT NULL,
    subsequuid uuid NOT NULL,
    plcid integer NOT NULL,
    seqsubsequuid uuid DEFAULT gen_random_uuid() NOT NULL,
    configuuid uuid NOT NULL
);


ALTER TABLE sequenceconfig.subsequences OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17316)
-- Name: configurations; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.configurations (
    topicuuid uuid NOT NULL,
    configuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    description character varying,
    plcid integer
);


ALTER TABLE setup.configurations OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17322)
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
-- TOC entry 219 (class 1259 OID 17328)
-- Name: sequences; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.sequences (
    configuuid uuid,
    sequuid uuid NOT NULL,
    name character varying,
    description character varying,
    typeuuid uuid
);


ALTER TABLE setup.sequences OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17333)
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
-- TOC entry 221 (class 1259 OID 17339)
-- Name: topics; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.topics (
    topicuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE setup.topics OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17345)
-- Name: alarmtypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.alarmtypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.alarmtypes OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17351)
-- Name: controlmoduletypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.controlmoduletypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.controlmoduletypes OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17357)
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
-- TOC entry 3651 (class 0 OID 17301)
-- Dependencies: 215
-- Data for Name: reactflowdata; Type: TABLE DATA; Schema: reactflow; Owner: postgres
--

COPY reactflow.reactflowdata (json, name, cid) FROM stdin;
{"edges": [], "nodes": [{"id": "1aeea8bc-22ad-4cb4-a6b4-6195f3f76d23", "data": {"type": "134afa44-4506-4b32-b5f5-53f2f1f64827|2", "isNew": true, "label": "sequence node", "configId": "0e9ab823-fd81-40fc-b594-8ba957dc870e"}, "type": "sequence", "width": 300, "height": 191, "dragging": false, "position": {"x": 41.5, "y": -645}, "selected": true, "positionAbsolute": {"x": 41.5, "y": -645}}, {"id": "e8616554-16dc-4da1-a6e4-e954ad7b47ec", "data": {"type": "ae384eab-c5f3-4b97-a903-ee1839e7e6de", "isNew": true, "label": "controlModule node", "configId": "0e9ab823-fd81-40fc-b594-8ba957dc870e"}, "type": "controlModule", "width": 300, "height": 191, "dragging": false, "position": {"x": 216.5, "y": -407.25}, "selected": false, "positionAbsolute": {"x": 216.5, "y": -407.25}}], "viewport": {"x": -32, "y": 1345.75, "zoom": 2}}	test	0e9ab823-fd81-40fc-b594-8ba957dc870e
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
null	d1	ef1c29b4-d0e2-4e86-a000-eccf79ec8e16
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
\.


--
-- TOC entry 3652 (class 0 OID 17306)
-- Dependencies: 216
-- Data for Name: alarms; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.alarms (sequuid, alarmuuid, name, description, type) FROM stdin;
\.


--
-- TOC entry 3661 (class 0 OID 18064)
-- Dependencies: 225
-- Data for Name: subsequences; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.subsequences (sequuid, subsequuid, plcid, seqsubsequuid, configuuid) FROM stdin;
\.


--
-- TOC entry 3653 (class 0 OID 17316)
-- Dependencies: 217
-- Data for Name: configurations; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.configurations (topicuuid, configuuid, name, description, plcid) FROM stdin;
\.


--
-- TOC entry 3654 (class 0 OID 17322)
-- Dependencies: 218
-- Data for Name: controlmodules; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.controlmodules (configuuid, cmuuid, type, name, description) FROM stdin;
\.


--
-- TOC entry 3655 (class 0 OID 17328)
-- Dependencies: 219
-- Data for Name: sequences; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.sequences (configuuid, sequuid, name, description, typeuuid) FROM stdin;
\.


--
-- TOC entry 3656 (class 0 OID 17333)
-- Dependencies: 220
-- Data for Name: steps; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.steps (sequuid, stepuuid, type, name, description) FROM stdin;
\.


--
-- TOC entry 3657 (class 0 OID 17339)
-- Dependencies: 221
-- Data for Name: topics; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.topics (topicuuid, name, description) FROM stdin;
14f38f2c-97c2-46af-b79a-07672eb2f94e	bsu	ball state
\.


--
-- TOC entry 3658 (class 0 OID 17345)
-- Dependencies: 222
-- Data for Name: alarmtypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.alarmtypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- TOC entry 3659 (class 0 OID 17351)
-- Dependencies: 223
-- Data for Name: controlmoduletypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.controlmoduletypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- TOC entry 3660 (class 0 OID 17357)
-- Dependencies: 224
-- Data for Name: sequencetypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.sequencetypes (configuuid, typeuuid, name, plcid) FROM stdin;
\.


--
-- TOC entry 3499 (class 2606 OID 18087)
-- Name: subsequences subsequences_pk; Type: CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT subsequences_pk PRIMARY KEY (sequuid, subsequuid);


--
-- TOC entry 3483 (class 2606 OID 17364)
-- Name: configurations configurations_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_pk PRIMARY KEY (configuuid);


--
-- TOC entry 3485 (class 2606 OID 17366)
-- Name: controlmodules controlmodules_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_pk PRIMARY KEY (cmuuid);


--
-- TOC entry 3487 (class 2606 OID 17368)
-- Name: sequences sequences_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_pk PRIMARY KEY (sequuid);


--
-- TOC entry 3489 (class 2606 OID 17370)
-- Name: steps steps_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_pk PRIMARY KEY (stepuuid);


--
-- TOC entry 3491 (class 2606 OID 17372)
-- Name: topics topics_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.topics
    ADD CONSTRAINT topics_pk PRIMARY KEY (topicuuid);


--
-- TOC entry 3493 (class 2606 OID 17374)
-- Name: alarmtypes alarmtypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3495 (class 2606 OID 17376)
-- Name: controlmoduletypes controlmoduletypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3497 (class 2606 OID 17378)
-- Name: sequencetypes sequencetypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3500 (class 2606 OID 17379)
-- Name: alarms alarm_type_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarm_type_fk FOREIGN KEY (type) REFERENCES types.alarmtypes(typeuuid);


--
-- TOC entry 3501 (class 2606 OID 17384)
-- Name: alarms alarms_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarms_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- TOC entry 3511 (class 2606 OID 18070)
-- Name: subsequences seq_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT seq_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid) ON DELETE CASCADE;


--
-- TOC entry 3502 (class 2606 OID 17394)
-- Name: configurations configurations_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_fk FOREIGN KEY (topicuuid) REFERENCES setup.topics(topicuuid) ON DELETE CASCADE;


--
-- TOC entry 3503 (class 2606 OID 17399)
-- Name: controlmodules controlmodule_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodule_type_fk FOREIGN KEY (type) REFERENCES types.controlmoduletypes(typeuuid);


--
-- TOC entry 3504 (class 2606 OID 17404)
-- Name: controlmodules controlmodules_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- TOC entry 3505 (class 2606 OID 17409)
-- Name: sequences sequence_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequence_type_fk FOREIGN KEY (typeuuid) REFERENCES types.sequencetypes(typeuuid);


--
-- TOC entry 3506 (class 2606 OID 17414)
-- Name: sequences sequences_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- TOC entry 3507 (class 2606 OID 17419)
-- Name: steps steps_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- TOC entry 3508 (class 2606 OID 17424)
-- Name: alarmtypes alarmtypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3509 (class 2606 OID 17429)
-- Name: controlmoduletypes controlmoduletypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3510 (class 2606 OID 17434)
-- Name: sequencetypes sequencetypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


-- Completed on 2023-02-06 21:04:31

--
-- PostgreSQL database dump complete
--

