--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0
-- Dumped by pg_dump version 15.0

-- Started on 2023-04-17 12:55:33

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

DROP DATABASE "LAP_PG";
--
-- TOC entry 3444 (class 1262 OID 16444)
-- Name: LAP_PG; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "LAP_PG" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


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
-- TOC entry 11 (class 2615 OID 24802)
-- Name: login; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA login;


ALTER SCHEMA login OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 16596)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 5 (class 2615 OID 16445)
-- Name: reactflow; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA reactflow;


ALTER SCHEMA reactflow OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 16446)
-- Name: sequenceconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sequenceconfig;


ALTER SCHEMA sequenceconfig OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 16447)
-- Name: setup; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA setup;


ALTER SCHEMA setup OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 16448)
-- Name: stepconfig; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stepconfig;


ALTER SCHEMA stepconfig OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 16449)
-- Name: types; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA types;


ALTER SCHEMA types OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16608)
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
-- TOC entry 253 (class 1255 OID 16599)
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
	   	insert into types.controlmoduletypes (configuuid,name,plcid) values (config,'Type 1',1);         
	    insert into types.controlmoduletypes (configuuid,name,plcid) values (config,'Type 2',2);         
	    insert into types.controlmoduletypes (configuuid,name,plcid) values (config,'Type 3',3);         
	    insert into types.controlmoduletypes (configuuid,name,plcid) values (config,'Type 4',4); 
	    return config;    
    END;$$;


ALTER FUNCTION setup.add_config(topic uuid, name character varying, rfdata jsonb) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16607)
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
-- TOC entry 250 (class 1255 OID 16625)
-- Name: add_sub_seq(uuid, uuid, uuid); Type: FUNCTION; Schema: setup; Owner: postgres
--

CREATE FUNCTION setup.add_sub_seq(parent uuid, child uuid, configuuid uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
	    insert into sequenceconfig.subsequences (sequuid, subsequuid, plcid, configuuid) values (parent,child, (select setup.find_missing_id_for_subseq()), configuuid);
    END;$$;


ALTER FUNCTION setup.add_sub_seq(parent uuid, child uuid, configuuid uuid) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16603)
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
-- TOC entry 235 (class 1255 OID 16613)
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
-- TOC entry 236 (class 1255 OID 16614)
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
-- TOC entry 237 (class 1255 OID 16626)
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
-- TOC entry 234 (class 1259 OID 24803)
-- Name: users; Type: TABLE; Schema: login; Owner: postgres
--

CREATE TABLE login.users (
    username character varying,
    password character varying,
    email character varying
);


ALTER TABLE login.users OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16453)
-- Name: reactflowdata; Type: TABLE; Schema: reactflow; Owner: postgres
--

CREATE TABLE reactflow.reactflowdata (
    json jsonb,
    name character varying NOT NULL,
    cid uuid NOT NULL
);


ALTER TABLE reactflow.reactflowdata OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16459)
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
-- TOC entry 222 (class 1259 OID 16465)
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
-- TOC entry 223 (class 1259 OID 16469)
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
-- TOC entry 224 (class 1259 OID 16475)
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
-- TOC entry 225 (class 1259 OID 16481)
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
-- TOC entry 226 (class 1259 OID 16487)
-- Name: steps; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.steps (
    sequuid uuid,
    stepuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    type integer,
    name character varying,
    description character varying,
    restart uuid
);


ALTER TABLE setup.steps OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16493)
-- Name: topics; Type: TABLE; Schema: setup; Owner: postgres
--

CREATE TABLE setup.topics (
    topicuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE setup.topics OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16633)
-- Name: step_condition; Type: TABLE; Schema: stepconfig; Owner: postgres
--

CREATE TABLE stepconfig.step_condition (
    condition uuid NOT NULL,
    type uuid,
    nextstep uuid,
    step uuid
);


ALTER TABLE stepconfig.step_condition OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16641)
-- Name: step_condition_definition; Type: TABLE; Schema: stepconfig; Owner: postgres
--

CREATE TABLE stepconfig.step_condition_definition (
    condition uuid NOT NULL,
    "Group" character varying,
    setpoint numeric,
    operation character varying,
    timer boolean
);


ALTER TABLE stepconfig.step_condition_definition OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16499)
-- Name: alarmtypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.alarmtypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying
);


ALTER TABLE types.alarmtypes OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16505)
-- Name: controlmoduletypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.controlmoduletypes (
    configuuid uuid,
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    plcid smallint
);


ALTER TABLE types.controlmoduletypes OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16511)
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
-- TOC entry 231 (class 1259 OID 16627)
-- Name: steptypes; Type: TABLE; Schema: types; Owner: postgres
--

CREATE TABLE types.steptypes (
    typeuuid uuid DEFAULT gen_random_uuid() NOT NULL,
    configuuid uuid,
    name character varying,
    plcid integer NOT NULL
);


ALTER TABLE types.steptypes OWNER TO postgres;

--
-- TOC entry 3438 (class 0 OID 24803)
-- Dependencies: 234
-- Data for Name: users; Type: TABLE DATA; Schema: login; Owner: postgres
--

COPY login.users (username, password, email) FROM stdin;
wjgib	pass	wjg@email.com
\.


--
-- TOC entry 3424 (class 0 OID 16453)
-- Dependencies: 220
-- Data for Name: reactflowdata; Type: TABLE DATA; Schema: reactflow; Owner: postgres
--

COPY reactflow.reactflowdata (json, name, cid) FROM stdin;
{"edges": [{"id": "reactflow__edge-80100499-bbac-4e74-8ea3-79488007c8dc-95e80786-d6c3-4f63-9921-38a3632319ab", "type": "step", "source": "80100499-bbac-4e74-8ea3-79488007c8dc", "target": "95e80786-d6c3-4f63-9921-38a3632319ab", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "80100499-bbac-4e74-8ea3-79488007c8dc", "data": {"type": "abbd1cfc-f523-43a6-bee7-b7e0a1930516", "isNew": true, "label": "sequence node", "configId": "4bc3f138-e5dc-4325-953c-ce6a2792fc1b"}, "type": "sequence", "width": 300, "height": 191, "dragging": false, "position": {"x": 286, "y": -49}, "selected": true, "positionAbsolute": {"x": 286, "y": -49}}, {"id": "95e80786-d6c3-4f63-9921-38a3632319ab", "data": {"type": "e172f2e8-53ef-46be-8a20-9c614e5c6f6a", "isNew": true, "label": "controlModule node", "configId": "4bc3f138-e5dc-4325-953c-ce6a2792fc1b"}, "type": "controlModule", "width": 300, "height": 191, "dragging": false, "position": {"x": 352.75, "y": 188.75}, "selected": false, "positionAbsolute": {"x": 352.75, "y": 188.75}}], "viewport": {"x": -510.2124620437503, "y": 137.26575571667598, "zoom": 1.9061783478961392}}	test 2	4bc3f138-e5dc-4325-953c-ce6a2792fc1b
null	hey	fade26f2-627a-49d2-8885-8a491704d9d7
{"edges": [{"id": "reactflow__edge-5ef22080-43e7-410d-8e67-bd9c3137aed0-96544717-1d28-43c7-afb6-0fde8955d94f", "type": "step", "source": "5ef22080-43e7-410d-8e67-bd9c3137aed0", "target": "96544717-1d28-43c7-afb6-0fde8955d94f", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-96544717-1d28-43c7-afb6-0fde8955d94f-30b7d30c-51d9-47bf-971d-5909ecc5ff1f", "type": "step", "source": "96544717-1d28-43c7-afb6-0fde8955d94f", "target": "30b7d30c-51d9-47bf-971d-5909ecc5ff1f", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "5ef22080-43e7-410d-8e67-bd9c3137aed0", "data": {"type": "e910dd1f-5cd6-444e-b53c-641a3bc9c2fb|3", "label": "sequence node", "configId": "3ab20e59-2ae9-496a-8f20-86895eb7e882"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 172.5, "y": -106}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 172.5, "y": -106}}, {"id": "96544717-1d28-43c7-afb6-0fde8955d94f", "data": {"type": "45c5d773-ecbb-48e0-8203-f655e4d97ccc|2", "label": "sequence node", "configId": "3ab20e59-2ae9-496a-8f20-86895eb7e882"}, "type": "sequence", "width": 300, "height": 207, "dragging": false, "position": {"x": 340, "y": 153.75}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 340, "y": 153.75}}, {"id": "30b7d30c-51d9-47bf-971d-5909ecc5ff1f", "data": {"type": "3b275ec1-d74e-486d-bd2d-b77168a01308|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "3ab20e59-2ae9-496a-8f20-86895eb7e882"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 127.10773124702001, "y": 418.7898582580907}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 127.10773124702001, "y": 418.7898582580907}}], "viewport": {"x": 247.48209544770373, "y": 116.80634854067694, "zoom": 0.9245535531108884}}	test	3ab20e59-2ae9-496a-8f20-86895eb7e882
null	pre-prod test 2	8a616d3a-339a-4db3-969b-bb5aaa3985db
{"edges": [], "nodes": [{"id": "384fd8f9-f92e-4948-ac32-0e6c060c5e13", "data": {"name": "", "type": "27872a3b-a355-4131-8618-5de092d703ae|4", "color": "#16ac34", "label": "sequence node", "configId": "ecd8ca26-3d08-405d-9937-f7430e64a028"}, "type": "sequence", "width": 173, "height": 207, "dragging": false, "position": {"x": -281.1217395445116, "y": -236.82583090975646}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": -281.1217395445116, "y": -236.82583090975646}}, {"id": "50d0b5a2-474a-44e1-bd1d-92175aae2f4b", "data": {"name": "", "type": "4419cc56-7021-4c3d-a588-728e569191cf|1|1", "color": "#675656", "label": "controlModule node", "seqType": "c|1", "configId": "ecd8ca26-3d08-405d-9937-f7430e64a028"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": -63.27798954451163, "y": -217.57583090975646}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": -63.27798954451163, "y": -217.57583090975646}}], "viewport": {"x": 450.581057614056, "y": 634.0463283884665, "zoom": 1.4676241626938626}}	pre-prod test 1	ecd8ca26-3d08-405d-9937-f7430e64a028
{"edges": [], "nodes": [{"id": "c04f7f59-8d8c-43bf-a0c7-a6833ed5f2da", "data": {"name": "hey", "type": "Type 4", "label": "controlModule node", "seqType": "c|1", "configId": "06e259a5-855a-411b-9a96-ff7456778902"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 520.171875, "y": 308}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 520.171875, "y": 308}}], "viewport": {"x": -922.34375, "y": -370.5, "zoom": 2}}	test 2	06e259a5-855a-411b-9a96-ff7456778902
{"edges": [{"id": "reactflow__edge-d2342bb7-d3e1-4d76-8147-c284f62cb6ab-a74abff7-f3ad-48b8-a287-ce82a099fefa", "type": "step", "source": "d2342bb7-d3e1-4d76-8147-c284f62cb6ab", "target": "a74abff7-f3ad-48b8-a287-ce82a099fefa", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "d2342bb7-d3e1-4d76-8147-c284f62cb6ab", "data": {"name": "test", "type": "2891d0d7-23fa-4b34-b9cc-4facf4dd7c34|2", "label": "sequence node", "configId": "ff74939d-4200-4a16-a9b9-917c08e77fbb"}, "type": "sequence", "width": 146, "height": 207, "dragging": false, "position": {"x": 319.171875, "y": 70.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 319.171875, "y": 70.5}}, {"id": "a74abff7-f3ad-48b8-a287-ce82a099fefa", "data": {"name": "hey", "type": "Type 2", "label": "controlModule node", "seqType": "c|1", "configId": "ff74939d-4200-4a16-a9b9-917c08e77fbb"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 459.1724257596685, "y": 111.24654696132598}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 459.1724257596685, "y": 111.24654696132598}}], "viewport": {"x": -474.75322624931357, "y": -86.2711547101992, "zoom": 1.8071988417952174}}	blah	ff74939d-4200-4a16-a9b9-917c08e77fbb
{"edges": [{"id": "reactflow__edge-3c8da99d-7d0e-4415-ae8c-ea9a15fea2ec-11d3dba1-817c-439a-a286-fb1f54c1dd49", "type": "step", "source": "3c8da99d-7d0e-4415-ae8c-ea9a15fea2ec", "target": "11d3dba1-817c-439a-a286-fb1f54c1dd49", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-7a05e241-72ad-4fd1-b67e-a6d9dad292a8-3c8da99d-7d0e-4415-ae8c-ea9a15fea2ec", "type": "step", "source": "7a05e241-72ad-4fd1-b67e-a6d9dad292a8", "target": "3c8da99d-7d0e-4415-ae8c-ea9a15fea2ec", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-e1f3741a-dc3e-485d-ade3-0364060ea927-0d866e1c-9e51-4aaa-bca3-68d26326e3f3", "type": "step", "source": "e1f3741a-dc3e-485d-ade3-0364060ea927", "target": "0d866e1c-9e51-4aaa-bca3-68d26326e3f3", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "3c8da99d-7d0e-4415-ae8c-ea9a15fea2ec", "data": {"name": "", "type": "07800a68-e41c-4069-baa5-675fad96e6e2|2", "color": "#9c3535", "label": "sequence node", "configId": "4e6a4154-8945-4622-83af-33e4203730de"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 151.671875, "y": 53.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 151.671875, "y": 53.5}}, {"id": "11d3dba1-817c-439a-a286-fb1f54c1dd49", "data": {"name": "", "type": "c4f6369a-5df6-4c9c-bacd-8b4e0b34c079|1|1", "label": "controlModule node", "seqType": "c|1", "configId": "4e6a4154-8945-4622-83af-33e4203730de"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 189.7578125, "y": 302.75}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 189.7578125, "y": 302.75}}, {"id": "7a05e241-72ad-4fd1-b67e-a6d9dad292a8", "data": {"name": "", "type": "4be86370-8c40-4ea9-a47a-6117edfb9725|3", "label": "sequence node", "configId": "4e6a4154-8945-4622-83af-33e4203730de"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": -90.17647671117885, "y": -176.49200955348067}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": -90.17647671117885, "y": -176.49200955348067}}, {"id": "e1f3741a-dc3e-485d-ade3-0364060ea927", "data": {"name": "", "type": "07800a68-e41c-4069-baa5-675fad96e6e2|2", "label": "sequence node", "configId": "4e6a4154-8945-4622-83af-33e4203730de"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 292.2201835786373, "y": -139.90507368502165}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 292.2201835786373, "y": -139.90507368502165}}, {"id": "0d866e1c-9e51-4aaa-bca3-68d26326e3f3", "data": {"name": "Test", "type": "Type 2", "label": "controlModule node", "seqType": "c|1", "configId": "4e6a4154-8945-4622-83af-33e4203730de"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 344.76888110577136, "y": 81.9672047628772}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 344.76888110577136, "y": 81.9672047628772}}], "viewport": {"x": 342.348244570347, "y": 252.7305063099837, "zoom": 1.198887945176366}}	test	4e6a4154-8945-4622-83af-33e4203730de
null	ben	77b160c1-5e33-4b90-8d29-b823728af400
{"edges": [], "nodes": [{"id": "686188b5-f7d0-47dd-b326-2e70cd70ef35", "data": {"name": "", "type": "81b2ff02-0164-4780-8957-8da903344341|2", "label": "sequence node", "configId": "126e6d28-71e3-4cb2-a7f9-deace6f04fc8"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 698.6875, "y": 9.5}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 698.6875, "y": 9.5}}], "viewport": {"x": -1287.375, "y": 67.5, "zoom": 2}}	blah 2	126e6d28-71e3-4cb2-a7f9-deace6f04fc8
{"edges": [{"id": "reactflow__edge-9028d051-324f-427d-86d0-543163f6071d-ec065ce2-0d13-40ae-8374-c37e613f39d8", "type": "step", "source": "9028d051-324f-427d-86d0-543163f6071d", "target": "ec065ce2-0d13-40ae-8374-c37e613f39d8", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-38fa2ac6-814b-4697-9ffc-1f5bbaeb22b9-ec065ce2-0d13-40ae-8374-c37e613f39d8", "type": "step", "source": "38fa2ac6-814b-4697-9ffc-1f5bbaeb22b9", "target": "ec065ce2-0d13-40ae-8374-c37e613f39d8", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "9028d051-324f-427d-86d0-543163f6071d", "data": {"name": "", "type": "e76f8b05-ae45-4089-8b81-a003ed314b3b|2", "color": "#262f59", "label": "sequence node", "configId": "616fdfc1-a665-408e-a2c7-dd80dfb3450c"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 1029.609375, "y": 88.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1029.609375, "y": 88.5}}, {"id": "ec065ce2-0d13-40ae-8374-c37e613f39d8", "data": {"name": "", "type": "Type 3", "color": "#943838", "label": "controlModule node", "seqType": "c|1", "configId": "616fdfc1-a665-408e-a2c7-dd80dfb3450c"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 1049.3737327723122, "y": 2.185979171065128}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1049.3737327723122, "y": 2.185979171065128}}, {"id": "38fa2ac6-814b-4697-9ffc-1f5bbaeb22b9", "data": {"name": "", "type": "0010b4b3-71d8-45f3-a523-c2c569db8502|3", "color": "#3a8350", "label": "sequence node", "configId": "616fdfc1-a665-408e-a2c7-dd80dfb3450c"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 1253.8526317561093, "y": -39.412519325826295}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 1253.8526317561093, "y": -39.412519325826295}}], "viewport": {"x": -1663.0741083656135, "y": 119.33741386166764, "zoom": 1.668842541908121}}	test	616fdfc1-a665-408e-a2c7-dd80dfb3450c
{"edges": [], "nodes": [{"id": "703ced9a-b3ed-4f2f-9fd4-2c7fa5e1ff7e", "data": {"name": "", "type": "65281d7e-a302-428f-8930-1f9065c240f5|3", "color": "#a05454", "label": "sequence node", "configId": "10e4bb09-dc9b-4165-8786-3bb303d1227f"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 622.6875, "y": 114}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 622.6875, "y": 114}}], "viewport": {"x": -999.375, "y": -46.5, "zoom": 2}}	test	10e4bb09-dc9b-4165-8786-3bb303d1227f
{"edges": [{"id": "reactflow__edge-c100e5fd-e541-4e84-b75a-a4dc12f814ec-6e18f319-95bd-4c46-960f-6e6cbe169eab", "type": "step", "source": "c100e5fd-e541-4e84-b75a-a4dc12f814ec", "target": "6e18f319-95bd-4c46-960f-6e6cbe169eab", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "c100e5fd-e541-4e84-b75a-a4dc12f814ec", "data": {"name": "", "type": "1c6b08e0-1ece-49ba-bc15-eb17c055ad07|2", "color": "#bb2a2a", "label": "sequence node", "configId": "760c3438-e001-45df-8fe5-94fb3db4e7e9"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 432.6875, "y": 92}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 432.6875, "y": 92}}, {"id": "6e18f319-95bd-4c46-960f-6e6cbe169eab", "data": {"name": "", "type": "Type 3", "color": "#3a288f", "label": "controlModule node", "seqType": "c|1", "configId": "760c3438-e001-45df-8fe5-94fb3db4e7e9"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 501.53125, "y": 329.75}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 501.53125, "y": 329.75}}], "viewport": {"x": -546.7374163217332, "y": -129.0511778833869, "zoom": 1.8498645817364197}}	blah	760c3438-e001-45df-8fe5-94fb3db4e7e9
{"edges": [], "nodes": [{"id": "282473bc-c326-483e-9a67-e75afce26a04", "data": {"name": "ahh", "type": "8d415884-b0d7-49aa-8521-044c4d99baa9|3", "color": "#3d0a0a", "label": "sequence node", "configId": "24055362-c4f6-45d4-855c-b5227b05011f"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 353.6875, "y": 182}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 353.6875, "y": 182}}], "viewport": {"x": -355.375, "y": -119.5, "zoom": 2}}	hye	24055362-c4f6-45d4-855c-b5227b05011f
{"edges": [{"id": "reactflow__edge-6e00b7cd-a981-4fe2-9b93-0a441a449d8e-57a3a382-cf28-4f7d-bd93-542668522729", "type": "step", "source": "6e00b7cd-a981-4fe2-9b93-0a441a449d8e", "target": "57a3a382-cf28-4f7d-bd93-542668522729", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-066165d5-37ea-41c4-9695-6aa4113023ee-6e00b7cd-a981-4fe2-9b93-0a441a449d8e", "type": "step", "source": "066165d5-37ea-41c4-9695-6aa4113023ee", "target": "6e00b7cd-a981-4fe2-9b93-0a441a449d8e", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "066165d5-37ea-41c4-9695-6aa4113023ee", "data": {"name": "", "type": "ef06c470-c464-466d-bd86-abdafaba8b9b|3", "label": "sequence node", "configId": "ba05c7cb-dd7f-4fd9-9721-01c84ccfc0ac"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 500.1875, "y": 8.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 500.1875, "y": 8.5}}, {"id": "6e00b7cd-a981-4fe2-9b93-0a441a449d8e", "data": {"name": "", "type": "07efa389-137d-40e3-817f-10000be9bc75|2", "label": "sequence node", "configId": "ba05c7cb-dd7f-4fd9-9721-01c84ccfc0ac"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 930.2491050493904, "y": 205.08712615533167}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 930.2491050493904, "y": 205.08712615533167}}, {"id": "57a3a382-cf28-4f7d-bd93-542668522729", "data": {"name": "", "type": "Type 2", "label": "controlModule node", "seqType": "c|1", "configId": "ba05c7cb-dd7f-4fd9-9721-01c84ccfc0ac"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 446.265738479853, "y": 371.58843207922143}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 446.265738479853, "y": 371.58843207922143}}], "viewport": {"x": -627.9654940860657, "y": 51.582459639148965, "zoom": 1.3657824561147252}}	test	ba05c7cb-dd7f-4fd9-9721-01c84ccfc0ac
{"edges": [], "nodes": [{"id": "8089a2ea-7ee4-4e46-94a7-f40f9b4565bf", "data": {"name": "", "label": "sequence node", "configId": "7d760560-2a2c-4ba6-ba64-0d60afda5581"}, "type": "sequence", "width": 251, "height": 207, "dragging": false, "position": {"x": 359.1875, "y": 181}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 359.1875, "y": 181}}], "viewport": {"x": -529.375, "y": -240.5, "zoom": 2}}	test	7d760560-2a2c-4ba6-ba64-0d60afda5581
null	test 2	247ea7c8-630e-4ca8-bd91-ff7e41c94274
{"edges": [{"id": "reactflow__edge-a11e1c99-14bd-4c4e-a568-f8587a35ca62-d8e50344-6429-441e-895b-226b28c0fbbb", "type": "step", "source": "a11e1c99-14bd-4c4e-a568-f8587a35ca62", "target": "d8e50344-6429-441e-895b-226b28c0fbbb", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-a11e1c99-14bd-4c4e-a568-f8587a35ca62-22c878eb-52da-4083-a341-c06e80775a68", "type": "step", "source": "a11e1c99-14bd-4c4e-a568-f8587a35ca62", "target": "22c878eb-52da-4083-a341-c06e80775a68", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "a11e1c99-14bd-4c4e-a568-f8587a35ca62", "data": {"name": "", "type": "a73c8b23-ec87-466e-9b2d-6c23dfe3b8a4|3", "color": "#d93030", "label": "sequence node", "configId": "073638ff-d501-4e1a-9cc2-503691d67265", "nodeType": "Sequence"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 346.0089490673512, "y": -190.13651886096943}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 346.0089490673512, "y": -190.13651886096943}}, {"id": "d8e50344-6429-441e-895b-226b28c0fbbb", "data": {"name": "Control", "type": "Type 2", "color": "#1a2299", "label": "controlModule node", "seqType": "c|1", "configId": "073638ff-d501-4e1a-9cc2-503691d67265", "nodeType": "Control Module"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 573.429926632897, "y": -26.695012880083567}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 573.429926632897, "y": -26.695012880083567}}, {"id": "22c878eb-52da-4083-a341-c06e80775a68", "data": {"name": "", "type": "7acf2e78-848d-4c71-b3e2-aefa236da73a|2", "color": "#8f0000", "label": "sequence node", "configId": "073638ff-d501-4e1a-9cc2-503691d67265", "nodeType": "Sequence"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 242.3610616432507, "y": 88.14138264766318}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 242.3610616432507, "y": 88.14138264766318}}], "viewport": {"x": -8.580633892778451, "y": 236.56893469223803, "zoom": 1.1033977516592526}}	test	073638ff-d501-4e1a-9cc2-503691d67265
{"edges": [{"id": "reactflow__edge-52259016-52b4-4c1b-aa5b-874d977223c2-c0013639-b3c7-4716-9583-da60962365ad", "type": "step", "source": "52259016-52b4-4c1b-aa5b-874d977223c2", "target": "c0013639-b3c7-4716-9583-da60962365ad", "animated": true, "sourceHandle": null, "targetHandle": null}, {"id": "reactflow__edge-3da69a23-0438-4179-bbad-a6431690b115-52259016-52b4-4c1b-aa5b-874d977223c2", "type": "step", "source": "3da69a23-0438-4179-bbad-a6431690b115", "target": "52259016-52b4-4c1b-aa5b-874d977223c2", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "52259016-52b4-4c1b-aa5b-874d977223c2", "data": {"name": "", "type": "e500b239-3f1d-416a-a7f9-28382fb8fcf8|2", "color": "#433687", "label": "sequence node", "configId": "5375afb4-856d-4493-81d6-54d99309662d", "nodeType": "Sequence"}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 604.4392032132314, "y": 272.4949386306299}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 604.4392032132314, "y": 272.4949386306299}}, {"id": "c0013639-b3c7-4716-9583-da60962365ad", "data": {"name": "", "type": "Type 3", "color": "#0b4c2e", "label": "controlModule node", "seqType": "c|1", "configId": "5375afb4-856d-4493-81d6-54d99309662d", "nodeType": "Control Module"}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 453.7488494040142, "y": 643.133470850243}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 453.7488494040142, "y": 643.133470850243}}, {"id": "3da69a23-0438-4179-bbad-a6431690b115", "data": {"name": "", "type": "4c511b00-f702-4360-aacb-cfc4beeaa062|3", "color": "#982f2f", "label": "sequence node", "configId": "5375afb4-856d-4493-81d6-54d99309662d", "nodeType": "Sequence"}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 782.159055225167, "y": 59.1390961748765}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 782.159055225167, "y": 59.1390961748765}}], "viewport": {"x": -230.24687692073735, "y": -20.375258778752425, "zoom": 1.0401177291114487}}	demonstration	5375afb4-856d-4493-81d6-54d99309662d
null	null	067d5c82-a3e7-417d-b91c-ded12581bf6e
{"edges": [], "nodes": [{"id": "8c3ff05d-b728-4053-969b-082afba2e3e7", "data": {"name": "", "type": "efcf2fa0-dd90-452e-b4a3-2795c63bb018|1", "label": "sequence node", "configId": "7062b718-df4d-47ed-9fc6-f47d313135d2", "nodeType": "Sequence", "colorInteracted": false}, "type": "sequence", "width": 208, "height": 207, "position": {"x": 526.6875, "y": 203}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 526.6875, "y": 203}}], "viewport": {"x": -697.375, "y": -318.5, "zoom": 2}}	test	7062b718-df4d-47ed-9fc6-f47d313135d2
null	test 1	ac32f1ff-64dc-434e-8c6d-ed4ba28ec95d
{"edges": [], "nodes": [{"id": "9efed140-24d6-496c-97b3-8d7b1e2ba115", "data": {"name": "Test Control Module", "type": "f1856b11-8313-42d2-9f2c-e6370536e635", "color": "#8a1919", "label": "controlModule node", "seqType": "c|1", "configId": "9655ec39-fcb1-4536-b37e-eadcfc1d9814", "nodeType": "Control Module", "colorInteracted": true}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 401.77136620265617, "y": 159.74832736613092}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 401.77136620265617, "y": 159.74832736613092}}, {"id": "76aa37da-4725-47d1-a33b-324ff72f90f7", "data": {"name": "Test Sequence", "type": "a5036ddb-7e71-47fe-a00e-ab88edf8a576", "color": "#901414", "label": "sequence node", "configId": "9655ec39-fcb1-4536-b37e-eadcfc1d9814", "nodeType": "Sequence", "colorInteracted": true}, "type": "sequence", "width": 192, "height": 207, "dragging": false, "position": {"x": 107.75030830596612, "y": 33.26805124849274}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 107.75030830596612, "y": 33.26805124849274}}], "viewport": {"x": -145.00832130676383, "y": 80.90322273052362, "zoom": 1.8579078114572563}}	test 2	9655ec39-fcb1-4536-b37e-eadcfc1d9814
{"edges": [{"id": "7b863b58-be98-4e95-87c1-26d89ea3cd27-8d4d6225-9379-43aa-a8b1-68ff4055cf0d", "type": "step", "label": "", "source": "7b863b58-be98-4e95-87c1-26d89ea3cd27", "target": "8d4d6225-9379-43aa-a8b1-68ff4055cf0d", "animated": true, "labelStyle": {"fontWeight": "bold"}, "labelBgStyle": {"fill": "#f8f4f4"}}], "nodes": [{"id": "7b863b58-be98-4e95-87c1-26d89ea3cd27", "data": {"name": "Milk", "type": "5a6b1a31-81bb-4abc-b919-f13d5730a7fc|2", "color": "green", "label": "sequence node", "configId": "305514a7-0159-4350-bebb-486e133625d6", "nodeType": "Sequence", "colorInteracted": false}, "type": "sequence", "width": 146, "height": 207, "dragging": false, "position": {"x": 242.6875, "y": 52}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 242.6875, "y": 52}}, {"id": "8d4d6225-9379-43aa-a8b1-68ff4055cf0d", "data": {"name": "Stir", "type": "49320f6c-8fcf-4da5-abde-abdc7fbb529a|3", "color": "blue", "label": "controlModule node", "seqType": "c|1", "configId": "305514a7-0159-4350-bebb-486e133625d6", "nodeType": "Control Module", "colorInteracted": false}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 517.53125, "y": 187.25}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 517.53125, "y": 187.25}}, {"id": "5b251c16-9dba-4565-9d26-f8b85894f369", "data": {"name": "Chocolate", "type": "22d499e0-edc0-43a4-9da3-868d32099214|3", "color": "#811d1d", "label": "sequence node", "configId": "305514a7-0159-4350-bebb-486e133625d6", "nodeType": "Sequence", "colorInteracted": true}, "type": "sequence", "width": 172, "height": 207, "dragging": false, "position": {"x": 405.50795660745905, "y": -83.2431947293034}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 405.50795660745905, "y": -83.2431947293034}}], "viewport": {"x": 364.15245986226046, "y": 128.2264689318496, "zoom": 0.8436301509116442}}	test 2	305514a7-0159-4350-bebb-486e133625d6
{"edges": [{"id": "0753a1b4-0c35-4daf-8021-249e9f3f0cfb-070903ac-4ece-4973-9e6f-e84096fcb70d", "type": "step", "label": "", "source": "0753a1b4-0c35-4daf-8021-249e9f3f0cfb", "target": "070903ac-4ece-4973-9e6f-e84096fcb70d", "animated": true, "labelStyle": {"fontWeight": "bold"}, "labelBgStyle": {"fill": "#f8f4f4"}}], "nodes": [{"id": "0753a1b4-0c35-4daf-8021-249e9f3f0cfb", "data": {"name": "", "type": "65957d7e-0fbd-4d30-aa7d-aa795abad4af|2", "color": "green", "label": "sequence node", "configId": "bedbdd53-cbbc-4176-822a-cc7b9a8e9ab6", "nodeType": "Sequence", "colorInteracted": false}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 344.081381114381, "y": 64.5285947194318}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 344.081381114381, "y": 64.5285947194318}}, {"id": "070903ac-4ece-4973-9e6f-e84096fcb70d", "data": {"name": "", "type": "73a96cd3-1d0a-4bed-b67d-cc297465bc2d|3", "color": "blue", "label": "controlModule node", "seqType": "c|1", "configId": "bedbdd53-cbbc-4176-822a-cc7b9a8e9ab6", "nodeType": "Control Module", "colorInteracted": false}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 691.8131784963695, "y": 286.40842394354445}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 691.8131784963695, "y": 286.40842394354445}}], "viewport": {"x": -531.0804678181814, "y": -22.819866111334022, "zoom": 1.7038477470105011}}	test	bedbdd53-cbbc-4176-822a-cc7b9a8e9ab6
{"edges": [{"id": "38e4284a-0ffa-4b71-9256-9f28b4379066-8168cfa6-3133-4230-8940-ab0a1b411429", "type": "step", "label": "Yeet", "style": {"stroke": "Red"}, "source": "38e4284a-0ffa-4b71-9256-9f28b4379066", "target": "8168cfa6-3133-4230-8940-ab0a1b411429", "animated": true, "selected": false, "labelStyle": {"fontWeight": "bold"}, "labelBgStyle": {"fill": "#f8f4f4"}}], "nodes": [{"id": "38e4284a-0ffa-4b71-9256-9f28b4379066", "data": {"name": "", "type": "4e5ff3f6-353b-42d0-87d3-8ec321e899a9|2", "color": "#17446d", "label": "sequence node", "configId": "c4660409-8e4f-441f-9200-912d2b27173e", "nodeType": "Sequence", "colorInteracted": true}, "type": "sequence", "width": 152, "height": 207, "dragging": false, "position": {"x": 563.6875, "y": 103.5}, "selected": false, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 563.6875, "y": 103.5}}, {"id": "8168cfa6-3133-4230-8940-ab0a1b411429", "data": {"name": "", "type": "e8afcb0d-3240-4daa-8c74-630b39d5a0e3|1", "color": "red", "label": "controlModule node", "seqType": "c|1", "configId": "c4660409-8e4f-441f-9200-912d2b27173e", "nodeType": "Control Module", "colorInteracted": false}, "type": "controlModule", "width": 300, "height": 207, "dragging": false, "position": {"x": 755.8486512627015, "y": 356.22207722228325}, "selected": true, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 755.8486512627015, "y": 356.22207722228325}}], "viewport": {"x": -842.176172767673, "y": -144.08918228863706, "zoom": 1.7896188012077359}}	test 3	c4660409-8e4f-441f-9200-912d2b27173e
{"edges": [], "nodes": [{"id": "446f97c0-9a25-4638-acda-eb05f617a799", "data": {"name": "", "type": "cbf77a9e-cedc-43a0-9242-5346f2024755|4", "color": "blue", "label": "sequence node", "configId": "3998d952-7d09-4f53-8383-1cbaf781ac04", "nodeType": "Sequence", "colorInteracted": false}, "type": "sequence", "width": 173, "height": 207, "position": {"x": 612.609375, "y": 16}, "dragHandle": ".drag-handle", "positionAbsolute": {"x": 612.609375, "y": 16}}], "viewport": {"x": -892.21875, "y": 213.5, "zoom": 2}}	test	3998d952-7d09-4f53-8383-1cbaf781ac04
\.


--
-- TOC entry 3425 (class 0 OID 16459)
-- Dependencies: 221
-- Data for Name: alarms; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.alarms (sequuid, alarmuuid, name, description, type) FROM stdin;
\.


--
-- TOC entry 3426 (class 0 OID 16465)
-- Dependencies: 222
-- Data for Name: subsequences; Type: TABLE DATA; Schema: sequenceconfig; Owner: postgres
--

COPY sequenceconfig.subsequences (sequuid, subsequuid, plcid, seqsubsequuid, configuuid) FROM stdin;
\.


--
-- TOC entry 3427 (class 0 OID 16469)
-- Dependencies: 223
-- Data for Name: configurations; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.configurations (topicuuid, configuuid, name, description, plcid) FROM stdin;
14f38f2c-97c2-46af-b79a-07672eb2f94e	3998d952-7d09-4f53-8383-1cbaf781ac04	test		1
\.


--
-- TOC entry 3428 (class 0 OID 16475)
-- Dependencies: 224
-- Data for Name: controlmodules; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.controlmodules (configuuid, cmuuid, type, name, description) FROM stdin;
\.


--
-- TOC entry 3429 (class 0 OID 16481)
-- Dependencies: 225
-- Data for Name: sequences; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.sequences (configuuid, sequuid, name, description, typeuuid) FROM stdin;
3998d952-7d09-4f53-8383-1cbaf781ac04	446f97c0-9a25-4638-acda-eb05f617a799		to be implemented in the future	cbf77a9e-cedc-43a0-9242-5346f2024755
\.


--
-- TOC entry 3430 (class 0 OID 16487)
-- Dependencies: 226
-- Data for Name: steps; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.steps (sequuid, stepuuid, type, name, description, restart) FROM stdin;
\.


--
-- TOC entry 3431 (class 0 OID 16493)
-- Dependencies: 227
-- Data for Name: topics; Type: TABLE DATA; Schema: setup; Owner: postgres
--

COPY setup.topics (topicuuid, name, description) FROM stdin;
14f38f2c-97c2-46af-b79a-07672eb2f94e	bsu	ball state topic
\.


--
-- TOC entry 3436 (class 0 OID 16633)
-- Dependencies: 232
-- Data for Name: step_condition; Type: TABLE DATA; Schema: stepconfig; Owner: postgres
--

COPY stepconfig.step_condition (condition, type, nextstep, step) FROM stdin;
\.


--
-- TOC entry 3437 (class 0 OID 16641)
-- Dependencies: 233
-- Data for Name: step_condition_definition; Type: TABLE DATA; Schema: stepconfig; Owner: postgres
--

COPY stepconfig.step_condition_definition (condition, "Group", setpoint, operation, timer) FROM stdin;
\.


--
-- TOC entry 3432 (class 0 OID 16499)
-- Dependencies: 228
-- Data for Name: alarmtypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.alarmtypes (configuuid, typeuuid, name) FROM stdin;
\.


--
-- TOC entry 3433 (class 0 OID 16505)
-- Dependencies: 229
-- Data for Name: controlmoduletypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.controlmoduletypes (configuuid, typeuuid, name, plcid) FROM stdin;
3998d952-7d09-4f53-8383-1cbaf781ac04	ce9e7a28-6d20-485f-a54d-1a12f9400c29	Type 1	1
3998d952-7d09-4f53-8383-1cbaf781ac04	f7b08349-b391-4d0c-a996-78bc3f00055a	Type 2	2
3998d952-7d09-4f53-8383-1cbaf781ac04	198a11c1-891d-43ed-b097-9b108a2234a6	Type 3	3
3998d952-7d09-4f53-8383-1cbaf781ac04	ebdd4a8f-b527-4fd5-97a6-73dc3e775d13	Type 4	4
\.


--
-- TOC entry 3434 (class 0 OID 16511)
-- Dependencies: 230
-- Data for Name: sequencetypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.sequencetypes (configuuid, typeuuid, name, plcid) FROM stdin;
3998d952-7d09-4f53-8383-1cbaf781ac04	e271904d-a7c4-4af8-ad56-680be0701784	Phase	2
3998d952-7d09-4f53-8383-1cbaf781ac04	d4c1bb29-b769-4df1-8bd2-5e95f7f86ee3	Operation	3
3998d952-7d09-4f53-8383-1cbaf781ac04	cbf77a9e-cedc-43a0-9242-5346f2024755	Procedure	4
\.


--
-- TOC entry 3435 (class 0 OID 16627)
-- Dependencies: 231
-- Data for Name: steptypes; Type: TABLE DATA; Schema: types; Owner: postgres
--

COPY types.steptypes (typeuuid, configuuid, name, plcid) FROM stdin;
\.


--
-- TOC entry 3253 (class 2606 OID 16617)
-- Name: subsequences subsequences_pk; Type: CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT subsequences_pk PRIMARY KEY (seqsubsequuid);


--
-- TOC entry 3255 (class 2606 OID 16518)
-- Name: configurations configurations_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_pk PRIMARY KEY (configuuid);


--
-- TOC entry 3257 (class 2606 OID 16611)
-- Name: controlmodules controlmodules_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_pk PRIMARY KEY (cmuuid);


--
-- TOC entry 3259 (class 2606 OID 16520)
-- Name: sequences sequences_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_pk PRIMARY KEY (sequuid);


--
-- TOC entry 3261 (class 2606 OID 16522)
-- Name: steps steps_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_pk PRIMARY KEY (stepuuid);


--
-- TOC entry 3263 (class 2606 OID 16524)
-- Name: topics topics_pk; Type: CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.topics
    ADD CONSTRAINT topics_pk PRIMARY KEY (topicuuid);


--
-- TOC entry 3265 (class 2606 OID 16526)
-- Name: alarmtypes alarmtypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3267 (class 2606 OID 16528)
-- Name: controlmoduletypes controlmoduletypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3269 (class 2606 OID 16530)
-- Name: sequencetypes sequencetypes_pk; Type: CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_pk PRIMARY KEY (typeuuid);


--
-- TOC entry 3270 (class 2606 OID 16531)
-- Name: alarms alarm_type_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarm_type_fk FOREIGN KEY (type) REFERENCES types.alarmtypes(typeuuid);


--
-- TOC entry 3271 (class 2606 OID 16536)
-- Name: alarms alarms_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.alarms
    ADD CONSTRAINT alarms_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- TOC entry 3272 (class 2606 OID 24797)
-- Name: subsequences subsequences_fk; Type: FK CONSTRAINT; Schema: sequenceconfig; Owner: postgres
--

ALTER TABLE ONLY sequenceconfig.subsequences
    ADD CONSTRAINT subsequences_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid) ON DELETE CASCADE;


--
-- TOC entry 3273 (class 2606 OID 16551)
-- Name: configurations configurations_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.configurations
    ADD CONSTRAINT configurations_fk FOREIGN KEY (topicuuid) REFERENCES setup.topics(topicuuid) ON DELETE CASCADE;


--
-- TOC entry 3274 (class 2606 OID 16556)
-- Name: controlmodules controlmodule_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodule_type_fk FOREIGN KEY (type) REFERENCES types.controlmoduletypes(typeuuid);


--
-- TOC entry 3275 (class 2606 OID 16561)
-- Name: controlmodules controlmodules_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.controlmodules
    ADD CONSTRAINT controlmodules_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- TOC entry 3276 (class 2606 OID 16566)
-- Name: sequences sequence_type_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequence_type_fk FOREIGN KEY (typeuuid) REFERENCES types.sequencetypes(typeuuid);


--
-- TOC entry 3277 (class 2606 OID 16571)
-- Name: sequences sequences_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.sequences
    ADD CONSTRAINT sequences_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid) ON DELETE CASCADE;


--
-- TOC entry 3278 (class 2606 OID 16576)
-- Name: steps steps_fk; Type: FK CONSTRAINT; Schema: setup; Owner: postgres
--

ALTER TABLE ONLY setup.steps
    ADD CONSTRAINT steps_fk FOREIGN KEY (sequuid) REFERENCES setup.sequences(sequuid);


--
-- TOC entry 3279 (class 2606 OID 16581)
-- Name: alarmtypes alarmtypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.alarmtypes
    ADD CONSTRAINT alarmtypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3280 (class 2606 OID 16586)
-- Name: controlmoduletypes controlmoduletypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.controlmoduletypes
    ADD CONSTRAINT controlmoduletypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3281 (class 2606 OID 16591)
-- Name: sequencetypes sequencetypes_fk; Type: FK CONSTRAINT; Schema: types; Owner: postgres
--

ALTER TABLE ONLY types.sequencetypes
    ADD CONSTRAINT sequencetypes_fk FOREIGN KEY (configuuid) REFERENCES setup.configurations(configuuid);


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2023-04-17 12:55:34

--
-- PostgreSQL database dump complete
--

