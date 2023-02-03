--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

-- Started on 2023-01-27 15:33:42

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
-- TOC entry 6 (class 2615 OID 16404)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16405)
-- Name: configjson; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.configjson (
    json jsonb,
    name character varying NOT NULL,
    cid uuid DEFAULT gen_random_uuid()
);


ALTER TABLE public.configjson OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16411)
-- Name: testing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testing (
    json jsonb,
    name character varying NOT NULL,
    cid uuid DEFAULT gen_random_uuid()
);


ALTER TABLE public.testing OWNER TO postgres;

--
-- TOC entry 3309 (class 0 OID 16405)
-- Dependencies: 210
-- Data for Name: configjson; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.configjson (json, name, cid) FROM stdin;
{"edges": [{"id": "reactflow__edge-sequence_aedcd3d5-580d-42ea-920b-835c46726916-sequence_48307f6f-9000-4e76-a19f-a337c84ebc80", "type": "step", "source": "sequence_aedcd3d5-580d-42ea-920b-835c46726916", "target": "sequence_48307f6f-9000-4e76-a19f-a337c84ebc80", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "sequence_aedcd3d5-580d-42ea-920b-835c46726916", "data": {"color": "#14a997", "label": "sequence node", "opcid": 45, "seqType": "2"}, "type": "sequence", "width": 300, "height": 181, "dragging": false, "position": {"x": 801.2311886123224, "y": -344.4451632431593}, "selected": false, "positionAbsolute": {"x": 801.2311886123224, "y": -344.4451632431593}}, {"id": "sequence_48307f6f-9000-4e76-a19f-a337c84ebc80", "data": {"label": "controlModule node", "opcid": 45, "seqType": 1}, "type": "controlModule", "width": 300, "height": 181, "dragging": false, "position": {"x": 898.1781280699774, "y": -101.28284758629792}, "selected": true, "positionAbsolute": {"x": 898.1781280699774, "y": -101.28284758629792}}], "viewport": {"x": -1071.9093166823, "y": 748.2280108294572, "zoom": 2}}	test2	b6add044-ccd3-4183-9416-6c39f01a12ea
null	test45	d31c2596-39f3-4f94-b9c4-cfa5baf87bcf
{"edges": [{"id": "reactflow__edge-sequence_51d712ae-42fd-4243-ad88-fac20b10a4fb-sequence_6f5630fe-ea8f-477e-b508-c25af01d3d98", "type": "step", "source": "sequence_51d712ae-42fd-4243-ad88-fac20b10a4fb", "target": "sequence_6f5630fe-ea8f-477e-b508-c25af01d3d98", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "sequence_51d712ae-42fd-4243-ad88-fac20b10a4fb", "data": {"color": "#c90d0d", "label": "sequence node", "opcid": 45, "seqType": "5"}, "type": "sequence", "width": 300, "height": 181, "dragging": false, "position": {"x": -160, "y": -104}, "selected": false, "positionAbsolute": {"x": -160, "y": -104}}, {"id": "sequence_6f5630fe-ea8f-477e-b508-c25af01d3d98", "data": {"color": "#160e0e", "label": "controlModule node", "opcid": 45, "seqType": 1}, "type": "controlModule", "width": 300, "height": 181, "dragging": false, "position": {"x": 153.25, "y": 123.75}, "selected": true, "positionAbsolute": {"x": 153.25, "y": 123.75}}], "viewport": {"x": 533.75, "y": 283.75, "zoom": 2}}	test5	d9ccb65a-a1db-47d2-8033-a8a45a14595c
{"edges": [], "nodes": [{"id": "sequence_ef1a44a3-6afd-4d59-a107-ff68b6435d23", "data": {"color": "#258f24", "label": "sequence node", "opcid": 45, "seqType": "3"}, "type": "sequence", "width": 300, "height": 181, "dragging": false, "position": {"x": 437.443413729128, "y": 58.61317254174401}, "selected": true, "positionAbsolute": {"x": 437.443413729128, "y": 58.61317254174401}}], "viewport": {"x": -865.0686456400742, "y": 189.13729128014836, "zoom": 2}}	test3	bd9c1e73-a10f-4710-9853-e5eb774da56d
{"edges": [], "nodes": [{"id": "sequence_c944dab4-8232-4a27-a201-0dc664afe183", "data": {"color": "#7f1a1a", "label": "sequence node", "opcid": 45}, "type": "sequence", "width": 300, "height": 181, "dragging": false, "position": {"x": 706, "y": 64}, "selected": true, "positionAbsolute": {"x": 706, "y": 64}}, {"id": "sequence_36339b80-d21e-42dd-ba68-21bae473e5bd", "data": {"label": "controlModule node", "opcid": 45, "seqType": 1}, "type": "controlModule", "width": 300, "height": 181, "dragging": false, "position": {"x": 706.75, "y": 256.25}, "selected": false, "positionAbsolute": {"x": 706.75, "y": 256.25}}], "viewport": {"x": -1073.5, "y": -106.5, "zoom": 2}}	test6	1d150009-23ac-4349-a3f4-e1f18b58330d
{"edges": [{"id": "reactflow__edge-sequence_a7ef31ba-01ac-4056-96af-a78559c9070b-sequence_708ce557-058a-4f01-8fdf-c6fdc685a4fb", "type": "step", "source": "sequence_a7ef31ba-01ac-4056-96af-a78559c9070b", "target": "sequence_708ce557-058a-4f01-8fdf-c6fdc685a4fb", "animated": true, "sourceHandle": null, "targetHandle": null}], "nodes": [{"id": "sequence_a7ef31ba-01ac-4056-96af-a78559c9070b", "data": {"color": "#000000", "label": "sequence node", "opcid": 45, "seqType": "2"}, "type": "sequence", "width": 300, "height": 181, "dragging": false, "position": {"x": 733.6828426771503, "y": -11.809089994024816}, "selected": false, "positionAbsolute": {"x": 733.6828426771503, "y": -11.809089994024816}}, {"id": "sequence_708ce557-058a-4f01-8fdf-c6fdc685a4fb", "data": {"color": "#3c2525", "label": "sequence node", "opcid": 45, "seqType": 1}, "type": "sequence", "width": 300, "height": 181, "dragging": false, "position": {"x": 1101.5782965951666, "y": 194.48803856891624}, "selected": true, "positionAbsolute": {"x": 1101.5782965951666, "y": 194.48803856891624}}], "viewport": {"x": -387.5475717941531, "y": 128.99642576014293, "zoom": 1.1486983549970349}}	test	2325975b-54ec-4119-9129-79315f0b3df8
null	test7]	401509a7-a5aa-4baa-aaff-c8881ca8bb81
\.


--
-- TOC entry 3310 (class 0 OID 16411)
-- Dependencies: 211
-- Data for Name: testing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.testing (json, name, cid) FROM stdin;
{"viewportInitialized": true}	test	221194d7-c8f7-476a-9eb2-9d67e21477ed
\.


-- Completed on 2023-01-27 15:33:43

--
-- PostgreSQL database dump complete
--

