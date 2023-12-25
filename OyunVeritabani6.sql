--
-- PostgreSQL database dump
--

-- Dumped from database version 13.13
-- Dumped by pg_dump version 13.13

-- Started on 2023-12-26 00:02:49

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
-- TOC entry 251 (class 1255 OID 17209)
-- Name: arkadaslikistegigonder(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.arkadaslikistegigonder(p_gonderenkisino integer, p_alankisino integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- ArkadasKayit tablosuna yeni kayıt ekle (DurumID 2, yani Beklemede durumu)
    INSERT INTO ArkadasKayit (Kullanici1ID, Kullanici2ID, ArkadaslikTarihi, DurumID)
    VALUES (p_GonderenKisiNo, p_AlanKisiNo, CURRENT_DATE, 2);

    -- İki kullanıcı da aynı ise eklenen kaydı geri al
    IF p_GonderenKisiNo = p_AlanKisiNo THEN
        DELETE FROM ArkadasKayit WHERE Kullanici1ID = p_GonderenKisiNo AND Kullanici2ID = p_AlanKisiNo AND DurumID = 2;
        RAISE NOTICE 'Arkadaşlık isteği geri alındı (kullanıcılar aynı).';
    ELSE
        -- İşlem başarılı mesajı
        RAISE NOTICE 'Arkadaşlık isteği gönderildi.';
    END IF;
END;
$$;


ALTER FUNCTION public.arkadaslikistegigonder(p_gonderenkisino integer, p_alankisino integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 17174)
-- Name: arkadaslikistegikabulet(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.arkadaslikistegikabulet(p_arkadaslikid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- ArkadasKayit tablosundaki kaydın durumunu güncelle (DurumID 2, yani Kabul edildi durumu)
    UPDATE ArkadasKayit
    SET DurumID = 1
    WHERE ArkadaslikID = p_ArkadaslikID;

    -- İşlem başarılı mesajı
    RAISE NOTICE 'Arkadaşlık isteği kabul edildi.';
END;
$$;


ALTER FUNCTION public.arkadaslikistegikabulet(p_arkadaslikid integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 17230)
-- Name: bakiyearttir(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.bakiyearttir(p_bakiyelimit integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Belirli bir bakiye limitinden düşük olan oyuncuların bakiyelerini arttır
    UPDATE Oyuncu
    SET Bakiye = Bakiye * 2
    WHERE Bakiye < p_BakiyeLimit;

  
END;
$$;


ALTER PROCEDURE public.bakiyearttir(p_bakiyelimit integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 17170)
-- Name: bakiyeuyari(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.bakiyeuyari() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.Bakiye = 0 THEN
        -- Bakiye sıfır olduğunda yapılacak işlemler
        RAISE EXCEPTION 'Bakiyeniz sıfıra düştü.';

        -- İşlemi geçersiz kıl
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.bakiyeuyari() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 17132)
-- Name: kisi_siltrigger_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kisi_siltrigger_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Silinen kişinin bilgilerini log tablosuna ekleme
    INSERT INTO Log (KisiNo, Adi, Soyadi, IlNo, LogTarihi)
    VALUES (OLD.KisiNo, OLD.Adi, OLD.Soyadi, OLD.IlNo, CURRENT_TIMESTAMP);
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.kisi_siltrigger_log() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 17042)
-- Name: kisidenarkadaslikkayitsil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kisidenarkadaslikkayitsil() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Kisi tablosundan silinen kaydın ID'sini kullanarak ArkadasKayit tablosundan ilgili kaydı siliyor
    DELETE FROM ArkadasKayit WHERE Kullanici1ID = OLD.KisiNo OR Kullanici2ID = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.kisidenarkadaslikkayitsil() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 17168)
-- Name: logbakiyeguncelleme(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.logbakiyeguncelleme() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Eski ve yeni bakiyeyi log tablosuna ekle, ancak farklı ise
    IF OLD.Bakiye <> NEW.Bakiye THEN
        INSERT INTO LogBakiye (KisiNo, EskiBakiye, YeniBakiye, LogTarihi)
        VALUES (NEW.KisiNo, OLD.Bakiye, NEW.Bakiye, CURRENT_TIMESTAMP);
    ELSE
        -- Eski ve yeni bakiye aynıysa hata döndür
        RAISE EXCEPTION 'Eski ve yeni bakiyeler aynıdır.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.logbakiyeguncelleme() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 17210)
-- Name: oyuncuistatistikekle(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.oyuncuistatistikekle(p_kisino integer, p_istatistikid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Istatistik tablosuna yeni kayıt ekle
    INSERT INTO Istatistik (KisiNo, IstatistikID)
    VALUES (p_KisiNo, p_IstatistikID);

    -- İşlem başarılı mesajı
    RAISE NOTICE 'Oyuncu istatistikleri eklendi.';
END;
$$;


ALTER FUNCTION public.oyuncuistatistikekle(p_kisino integer, p_istatistikid integer) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 17048)
-- Name: oyunlarmagazasilyapimci(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.oyunlarmagazasilyapimci() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM OyunlarMagaza WHERE KisiID = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.oyunlarmagazasilyapimci() OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 17172)
-- Name: satinalmaislemi(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.satinalmaislemi(p_kisino integer, p_oyunid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- SahipOyunlar tablosuna yeni kayıt ekle
    INSERT INTO SahipOyunlar (KisiNo, OyunID)
    VALUES (p_KisiNo, p_OyunID);

    -- İşlem başarılı mesajı
    RAISE NOTICE 'Oyun satın alma işlemi başarıyla tamamlandı.';
END;
$$;


ALTER FUNCTION public.satinalmaislemi(p_kisino integer, p_oyunid integer) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 16991)
-- Name: silinenkisiyisil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenkisiyisil() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Oyuncu WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenkisiyisil() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 17044)
-- Name: silinenkisiyisilcalisan(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenkisiyisilcalisan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Calisan WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenkisiyisilcalisan() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 17046)
-- Name: silinenkisiyisilyapimci(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenkisiyisilyapimci() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Yapimci WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenkisiyisilyapimci() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16993)
-- Name: silinenoyuncuyusil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenoyuncuyusil() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Basarilar WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenoyuncuyusil() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 17034)
-- Name: silinenoyuncuyusil2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenoyuncuyusil2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Istatistik WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenoyuncuyusil2() OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 17036)
-- Name: silinenoyuncuyusil3(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenoyuncuyusil3() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Basarilar WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenoyuncuyusil3() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 17038)
-- Name: silinenoyuncuyusil4(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silinenoyuncuyusil4() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Istatistik WHERE KisiNo = OLD.KisiNo;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.silinenoyuncuyusil4() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 17188)
-- Name: arkadaskayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arkadaskayit (
    arkadaslikid integer NOT NULL,
    kullanici1id integer,
    kullanici2id integer,
    arkadasliktarihi date,
    durumid integer
);


ALTER TABLE public.arkadaskayit OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17186)
-- Name: arkadaskayit_arkadaslikid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arkadaskayit_arkadaslikid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arkadaskayit_arkadaslikid_seq OWNER TO postgres;

--
-- TOC entry 3200 (class 0 OID 0)
-- Dependencies: 224
-- Name: arkadaskayit_arkadaslikid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arkadaskayit_arkadaslikid_seq OWNED BY public.arkadaskayit.arkadaslikid;


--
-- TOC entry 200 (class 1259 OID 16800)
-- Name: basarilar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.basarilar (
    kisino integer NOT NULL,
    basariid integer NOT NULL,
    kazanmatarihi date
);


ALTER TABLE public.basarilar OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16803)
-- Name: basariref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.basariref (
    basariid integer NOT NULL,
    basariadi character varying(40),
    CONSTRAINT chk_basariadi_notempty CHECK (((basariadi)::text <> ''::text))
);


ALTER TABLE public.basariref OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 16807)
-- Name: basariref_basariid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.basariref_basariid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.basariref_basariid_seq OWNER TO postgres;

--
-- TOC entry 3201 (class 0 OID 0)
-- Dependencies: 202
-- Name: basariref_basariid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.basariref_basariid_seq OWNED BY public.basariref.basariid;


--
-- TOC entry 203 (class 1259 OID 16809)
-- Name: calisan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calisan (
    kisino integer NOT NULL,
    yetkino integer,
    departmanno integer
);


ALTER TABLE public.calisan OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 16812)
-- Name: departman; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departman (
    departmanid integer NOT NULL,
    departmanadi character varying(40),
    CONSTRAINT chk_departmanadi_notempty CHECK (((departmanadi)::text <> ''::text))
);


ALTER TABLE public.departman OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 16816)
-- Name: durumlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.durumlar (
    durumid integer NOT NULL,
    durumadi character varying(20)
);


ALTER TABLE public.durumlar OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 16819)
-- Name: durumlar_durumid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.durumlar_durumid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.durumlar_durumid_seq OWNER TO postgres;

--
-- TOC entry 3202 (class 0 OID 0)
-- Dependencies: 206
-- Name: durumlar_durumid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.durumlar_durumid_seq OWNED BY public.durumlar.durumid;


--
-- TOC entry 207 (class 1259 OID 16821)
-- Name: il; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.il (
    ilplaka integer NOT NULL,
    iladi character varying(40)
);


ALTER TABLE public.il OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 16824)
-- Name: istatistik; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.istatistik (
    kisino integer NOT NULL,
    istatistikid integer NOT NULL
);


ALTER TABLE public.istatistik OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16827)
-- Name: istatistikref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.istatistikref (
    istatistikid integer NOT NULL,
    istatistikadi character varying(40),
    oyunid integer
);


ALTER TABLE public.istatistikref OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16830)
-- Name: istatistikref_istatistikid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.istatistikref_istatistikid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.istatistikref_istatistikid_seq OWNER TO postgres;

--
-- TOC entry 3203 (class 0 OID 0)
-- Dependencies: 210
-- Name: istatistikref_istatistikid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.istatistikref_istatistikid_seq OWNED BY public.istatistikref.istatistikid;


--
-- TOC entry 211 (class 1259 OID 16832)
-- Name: kisi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kisi (
    kisino integer NOT NULL,
    adi character varying(40),
    soyadi character varying(40),
    aktifmi boolean,
    ilno integer
);


ALTER TABLE public.kisi OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16835)
-- Name: kisi_kisino_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kisi_kisino_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kisi_kisino_seq OWNER TO postgres;

--
-- TOC entry 3204 (class 0 OID 0)
-- Dependencies: 212
-- Name: kisi_kisino_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kisi_kisino_seq OWNED BY public.kisi.kisino;


--
-- TOC entry 221 (class 1259 OID 17119)
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    logid integer NOT NULL,
    kisino integer,
    adi character varying(40),
    soyadi character varying(40),
    ilno integer,
    logtarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.log OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17117)
-- Name: log_logid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_logid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_logid_seq OWNER TO postgres;

--
-- TOC entry 3205 (class 0 OID 0)
-- Dependencies: 220
-- Name: log_logid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_logid_seq OWNED BY public.log.logid;


--
-- TOC entry 223 (class 1259 OID 17152)
-- Name: logbakiye; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logbakiye (
    logid integer NOT NULL,
    kisino integer,
    eskibakiye integer,
    yenibakiye integer,
    logtarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.logbakiye OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17150)
-- Name: logbakiye_logid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logbakiye_logid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logbakiye_logid_seq OWNER TO postgres;

--
-- TOC entry 3206 (class 0 OID 0)
-- Dependencies: 222
-- Name: logbakiye_logid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logbakiye_logid_seq OWNED BY public.logbakiye.logid;


--
-- TOC entry 213 (class 1259 OID 16837)
-- Name: oyuncu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oyuncu (
    kisino integer NOT NULL,
    bakiye integer,
    CONSTRAINT chk_bakiye_nonnegative CHECK ((bakiye >= 0))
);


ALTER TABLE public.oyuncu OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16841)
-- Name: oyunlarmagaza; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oyunlarmagaza (
    oyunid integer NOT NULL,
    kisiid integer NOT NULL,
    yapimcinot character varying(255)
);


ALTER TABLE public.oyunlarmagaza OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16844)
-- Name: oyunlarreferans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oyunlarreferans (
    oyunid integer NOT NULL,
    oyunadi character varying(40),
    cikistarihi date,
    CONSTRAINT chk_cikistarihi_future CHECK ((cikistarihi <= CURRENT_DATE)),
    CONSTRAINT chk_oyunadi_notempty CHECK (((oyunadi)::text <> ''::text)),
    CONSTRAINT oyunlarreferans_cikistarihi_check CHECK ((cikistarihi IS NOT NULL)),
    CONSTRAINT oyunlarreferans_oyunid_check CHECK ((oyunid > 0))
);


ALTER TABLE public.oyunlarreferans OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16851)
-- Name: oyunlarreferans_oyunid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oyunlarreferans_oyunid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oyunlarreferans_oyunid_seq OWNER TO postgres;

--
-- TOC entry 3207 (class 0 OID 0)
-- Dependencies: 216
-- Name: oyunlarreferans_oyunid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oyunlarreferans_oyunid_seq OWNED BY public.oyunlarreferans.oyunid;


--
-- TOC entry 217 (class 1259 OID 16853)
-- Name: sahipoyunlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sahipoyunlar (
    kisino integer NOT NULL,
    oyunid integer NOT NULL
);


ALTER TABLE public.sahipoyunlar OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16856)
-- Name: yapimci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yapimci (
    kisino integer NOT NULL
);


ALTER TABLE public.yapimci OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16859)
-- Name: yetkiler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yetkiler (
    yetkiid integer NOT NULL,
    yetkiadi character varying(40),
    CONSTRAINT chk_yetkiadi_notempty CHECK (((yetkiadi)::text <> ''::text))
);


ALTER TABLE public.yetkiler OWNER TO postgres;

--
-- TOC entry 2966 (class 2604 OID 17191)
-- Name: arkadaskayit arkadaslikid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arkadaskayit ALTER COLUMN arkadaslikid SET DEFAULT nextval('public.arkadaskayit_arkadaslikid_seq'::regclass);


--
-- TOC entry 2949 (class 2604 OID 16864)
-- Name: basariref basariid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basariref ALTER COLUMN basariid SET DEFAULT nextval('public.basariref_basariid_seq'::regclass);


--
-- TOC entry 2952 (class 2604 OID 16865)
-- Name: durumlar durumid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.durumlar ALTER COLUMN durumid SET DEFAULT nextval('public.durumlar_durumid_seq'::regclass);


--
-- TOC entry 2953 (class 2604 OID 16866)
-- Name: istatistikref istatistikid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.istatistikref ALTER COLUMN istatistikid SET DEFAULT nextval('public.istatistikref_istatistikid_seq'::regclass);


--
-- TOC entry 2954 (class 2604 OID 16867)
-- Name: kisi kisino; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi ALTER COLUMN kisino SET DEFAULT nextval('public.kisi_kisino_seq'::regclass);


--
-- TOC entry 2962 (class 2604 OID 17122)
-- Name: log logid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN logid SET DEFAULT nextval('public.log_logid_seq'::regclass);


--
-- TOC entry 2964 (class 2604 OID 17155)
-- Name: logbakiye logid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logbakiye ALTER COLUMN logid SET DEFAULT nextval('public.logbakiye_logid_seq'::regclass);


--
-- TOC entry 2956 (class 2604 OID 16868)
-- Name: oyunlarreferans oyunid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyunlarreferans ALTER COLUMN oyunid SET DEFAULT nextval('public.oyunlarreferans_oyunid_seq'::regclass);


--
-- TOC entry 3194 (class 0 OID 17188)
-- Dependencies: 225
-- Data for Name: arkadaskayit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arkadaskayit (arkadaslikid, kullanici1id, kullanici2id, arkadasliktarihi, durumid) FROM stdin;
18	51	8	2023-12-22	2
27	19	8	2023-12-22	2
28	19	8	2023-12-22	2
29	19	8	2023-12-22	2
30	14	8	2023-12-22	2
37	21	8	2023-12-22	2
41	30	8	2023-12-22	2
16	20	8	2023-12-22	1
39	23	8	2023-12-22	1
17	39	8	2023-12-22	1
51	52	19	2023-12-25	1
\.


--
-- TOC entry 3169 (class 0 OID 16800)
-- Dependencies: 200
-- Data for Name: basarilar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.basarilar (kisino, basariid, kazanmatarihi) FROM stdin;
14	8	2023-12-17
16	9	2023-12-17
18	10	2023-12-17
19	11	2023-12-17
23	13	2023-12-17
25	14	2023-12-17
27	15	2023-12-17
29	16	2023-12-17
31	17	2023-12-17
34	19	2023-12-17
36	20	2023-12-17
\.


--
-- TOC entry 3170 (class 0 OID 16803)
-- Dependencies: 201
-- Data for Name: basariref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.basariref (basariid, basariadi) FROM stdin;
1	Custom Achievement 1
2	Custom Achievement 2
3	Custom Achievement 3
4	Custom Achievement 4
5	Custom Achievement 5
6	Custom Achievement 6
7	Custom Achievement 7
8	Custom Achievement 8
9	Custom Achievement 9
10	Custom Achievement 10
11	Custom Achievement 11
12	Custom Achievement 12
13	Custom Achievement 13
14	Custom Achievement 14
15	Custom Achievement 15
16	Custom Achievement 16
17	Custom Achievement 17
18	Custom Achievement 18
19	Custom Achievement 19
20	Custom Achievement 20
\.


--
-- TOC entry 3172 (class 0 OID 16809)
-- Dependencies: 203
-- Data for Name: calisan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calisan (kisino, yetkino, departmanno) FROM stdin;
39	5	10
42	3	3
43	4	4
45	1	6
46	2	7
48	4	9
51	2	2
52	3	3
53	4	4
54	5	5
55	1	6
56	2	7
57	3	8
58	4	9
59	5	10
62	3	3
98	1	1
100	1	1
9000	1	1
1600	2	2
\.


--
-- TOC entry 3173 (class 0 OID 16812)
-- Dependencies: 204
-- Data for Name: departman; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departman (departmanid, departmanadi) FROM stdin;
1	Oyun Geliştirme
2	Grafik Tasarım
3	Yazılım Mühendisliği
4	Test ve Kalite Kontrol
5	Proje Yönetimi
6	Pazarlama
7	Finans
8	İnsan Kaynakları
9	Satış ve Dağıtım
10	Müşteri Hizmetleri
\.


--
-- TOC entry 3174 (class 0 OID 16816)
-- Dependencies: 205
-- Data for Name: durumlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.durumlar (durumid, durumadi) FROM stdin;
1	Aktif
2	Pasif
3	Dondurulmus
\.


--
-- TOC entry 3176 (class 0 OID 16821)
-- Dependencies: 207
-- Data for Name: il; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.il (ilplaka, iladi) FROM stdin;
1	Adana
2	Adıyaman
3	Afyonkarahisar
4	Ağrı
5	Amasya
6	Ankara
7	Antalya
8	Artvin
9	Aydın
10	Balıkesir
11	Bilecik
12	Bingöl
13	Bitlis
14	Bolu
15	Burdur
16	Bursa
17	Çanakkale
18	Çankırı
19	Çorum
20	Denizli
21	Diyarbakır
22	Edirne
23	Elazığ
24	Erzincan
25	Erzurum
26	Eskişehir
27	Gaziantep
28	Giresun
29	Gümüşhane
30	Hakkari
31	Hatay
32	Isparta
33	Mersin
34	İstanbul
35	İzmir
36	Kars
37	Kastamonu
38	Kayseri
39	Kırklareli
40	Kırşehir
41	Kocaeli
42	Konya
43	Kütahya
44	Malatya
45	Manisa
46	Kahramanmaraş
47	Mardin
48	Muğla
49	Muş
50	Nevşehir
51	Niğde
52	Ordu
53	Rize
54	Sakarya
55	Samsun
56	Siirt
57	Sinop
58	Sivas
59	Tekirdağ
60	Tokat
61	Trabzon
62	Tunceli
63	Şanlıurfa
64	Uşak
65	Van
66	Yozgat
67	Zonguldak
68	Aksaray
69	Bayburt
70	Karaman
71	Kırıkkale
72	Batman
73	Şırnak
74	Bartın
75	Ardahan
76	Iğdır
77	Yalova
78	Karabük
79	Kilis
80	Osmaniye
81	Düzce
\.


--
-- TOC entry 3177 (class 0 OID 16824)
-- Dependencies: 208
-- Data for Name: istatistik; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.istatistik (kisino, istatistikid) FROM stdin;
14	8
16	9
19	11
23	13
25	14
27	15
29	16
31	17
34	19
36	20
19	21
23	23
25	24
27	25
29	26
31	27
34	29
29	24
23	22
\.


--
-- TOC entry 3178 (class 0 OID 16827)
-- Dependencies: 209
-- Data for Name: istatistikref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.istatistikref (istatistikid, istatistikadi, oyunid) FROM stdin;
1	Istatistik1	1
2	Istatistik2	2
3	Istatistik3	3
4	Istatistik4	4
5	Istatistik5	5
6	Istatistik6	6
7	Istatistik7	7
8	Istatistik8	8
9	Istatistik9	9
10	Istatistik10	10
11	Istatistik11	11
12	Istatistik12	12
13	Istatistik13	13
14	Istatistik14	14
15	Istatistik15	15
16	Istatistik16	16
17	Istatistik17	17
18	Istatistik18	18
19	Istatistik19	19
20	Istatistik20	20
21	Istatistik21	21
22	Istatistik22	22
23	Istatistik23	23
24	Istatistik24	24
25	Istatistik25	25
26	Istatistik26	26
27	Istatistik27	27
28	Istatistik28	28
29	Istatistik29	29
\.


--
-- TOC entry 3180 (class 0 OID 16832)
-- Dependencies: 211
-- Data for Name: kisi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kisi (kisino, adi, soyadi, aktifmi, ilno) FROM stdin;
8	Merve	Kaya	t	39
11	Can	Aydin	f	77
13	Ayse	Toprak	t	3
14	Mustafa	Yildiz	f	8
19	Selin	Gunes	f	34
20	Eren	Dogan	t	56
21	Duygu	Ozbek	t	1
23	Irem	Celik	t	12
24	Yusuf	Guler	f	39
25	Asli	Aksoy	t	6
27	Melis	Erdem	f	23
28	Berke	Ozkan	t	67
29	Sude	Erdogan	t	10
30	Kerem	Demirtas	f	77
31	Busra	Koc	t	17
32	Yavuz	Kurtulus	f	2
34	Ahmet	Sen	t	39
35	Nazli	Yalin	f	56
36	Onur	Tas	t	1
39	Sema	Kurtulus	t	67
40	Gorkem	Dinc	t	10
42	Mehmet	Yildirim	t	45
43	Beyza	Ozdemir	f	17
45	Selin	Ozturk	t	77
46	Ege	Demir	f	1
48	Oguz	Guner	f	34
51	Ezgi	Gokturk	f	67
52	Mert	Akbulut	t	10
53	Ilayda	Sahin	t	56
54	Kaan	Yilmaz	f	3
55	Nisan	Arslan	t	8
56	Batuhan	Cetin	f	23
57	Zehra	Sen	t	17
58	Oktay	Demir	t	2
59	Elif	Ozkan	f	39
62	Yasin	Akgun	f	6
18	mehmet	Sahin	t	17
17	mehmet	Arslan	f	10
26	ayse	Bas	t	45
97	Ibrahim 	Guldemir	t	54
98	Ibrahim	Guldemir	t	54
100	Baha	Bakan	f	1
9001	Tugra	Yavuz	f	1
9000	Ahmet	Yavuz	f	1
16	Mehmet	Kara	t	67
1500	gözde	bakan	t	50
1600	mehmet	asfasf	f	1
160085	mehmet2	asfasf	f	1
\.


--
-- TOC entry 3190 (class 0 OID 17119)
-- Dependencies: 221
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (logid, kisino, adi, soyadi, ilno, logtarihi) FROM stdin;
1	7	Ahmet	Yilmaz	16	2023-12-20 18:45:54.344075
2	10	mehmet	Ozturk	2	2023-12-20 18:46:21.781807
3	12	Zeynep	Kurt	45	2023-12-20 18:47:10.351121
4	99	Tugra	Yavuz	5	2023-12-20 18:48:35.921656
5	37	Elanur	Kose	12	2023-12-20 19:02:25.306078
6	38	Yigit	Kara	23	2023-12-20 19:02:26.941697
7	15	Gamze	Ozdemir	23	2023-12-20 19:02:30.02058
8	3	Engin	Cavak	6	2023-12-20 19:02:31.936121
9	899	Tugra	Yavuz	1	2023-12-20 21:52:06.212512
10	22	Okan	Turan	28	2023-12-20 22:09:06.254832
11	1000	zehra	sari	1	2023-12-21 19:32:41.993807
12	60	Kerem	Kaya	12	2023-12-25 20:01:14.69605
13	61	Esra	Turk	77	2023-12-25 21:55:18.092316
14	44	Umut	Celik	2	2023-12-25 21:55:20.469501
15	96	Kerem	Kol	5	2023-12-25 21:56:07.364193
\.


--
-- TOC entry 3192 (class 0 OID 17152)
-- Dependencies: 223
-- Data for Name: logbakiye; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logbakiye (logid, kisino, eskibakiye, yenibakiye, logtarihi) FROM stdin;
1	16	600	600	2023-12-20 22:24:02.377478
2	18	8178	600	2023-12-20 22:25:33.034414
4	16	600	6000	2023-12-20 22:43:22.090826
6	14	500	1000	2023-12-22 18:32:54.435541
7	18	600	1200	2023-12-22 18:32:54.435541
8	19	1291	2582	2023-12-22 18:33:17.194069
9	29	1491	2982	2023-12-22 18:33:17.194069
10	14	1000	2000	2023-12-22 18:33:17.194069
11	18	1200	2400	2023-12-22 18:33:17.194069
12	36	2113	4226	2023-12-22 18:33:55.526679
13	14	2000	4000	2023-12-22 18:33:55.526679
14	25	3212	6424	2023-12-23 21:44:27.320994
15	34	4242	8484	2023-12-23 21:44:27.320994
16	19	2582	5164	2023-12-23 21:44:27.320994
17	29	2982	5964	2023-12-23 21:44:27.320994
18	18	2400	4800	2023-12-23 21:44:27.320994
19	36	4226	8452	2023-12-23 21:44:27.320994
20	14	4000	8000	2023-12-23 21:44:27.320994
21	23	5433	6515	2023-12-25 21:12:40.517047
22	27	6428	12856	2023-12-25 21:13:23.988154
23	31	5401	10802	2023-12-25 21:13:23.988154
24	16	6000	12000	2023-12-25 21:13:23.988154
25	25	6424	12848	2023-12-25 21:13:23.988154
26	19	5164	10328	2023-12-25 21:13:23.988154
27	29	5964	11928	2023-12-25 21:13:23.988154
28	18	4800	9600	2023-12-25 21:13:23.988154
29	1500	6000	12000	2023-12-25 21:13:23.988154
\.


--
-- TOC entry 3182 (class 0 OID 16837)
-- Dependencies: 213
-- Data for Name: oyuncu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oyuncu (kisino, bakiye) FROM stdin;
34	8484
36	8452
14	8000
23	6515
27	12856
31	10802
16	12000
25	12848
19	10328
29	11928
18	9600
1500	12000
\.


--
-- TOC entry 3183 (class 0 OID 16841)
-- Dependencies: 214
-- Data for Name: oyunlarmagaza; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oyunlarmagaza (oyunid, kisiid, yapimcinot) FROM stdin;
2	11	Yapimci Not 2
3	21	Yapimci Not 3
4	28	Yapimci Not 4
5	35	Yapimci Not 5
10	20	Yapimci Not 10
11	26	Yapimci Not 11
12	32	Yapimci Not 12
13	40	Yapimci Not 13
16	8	Yapimci Not 16
17	13	Yapimci Not 17
18	17	Yapimci Not 18
19	24	Yapimci Not 19
20	30	Yapimci Not 20
22	30	Yapimci Not 22
23	24	Yapimci Not 23
26	8	Yapimci Not 26
27	13	Yapimci Not 27
28	35	Yapimci Not 28
29	11	Yapimci Not 29
\.


--
-- TOC entry 3184 (class 0 OID 16844)
-- Dependencies: 215
-- Data for Name: oyunlarreferans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oyunlarreferans (oyunid, oyunadi, cikistarihi) FROM stdin;
1	The Witcher 3: Wild Hunt	2015-05-19
2	Red Dead Redemption 2	2018-10-26
3	Cyberpunk 2077	2020-12-10
4	Assassin's Creed Valhalla	2020-11-10
5	FIFA 22	2021-10-01
6	The Legend of Zelda: Breath of the Wild	2017-03-03
7	GTA V	2013-09-17
8	Minecraft	2011-11-18
9	Among Us	2018-11-16
10	Fortnite	2017-07-25
11	Call of Duty: Warzone	2020-03-10
12	Overwatch	2016-05-24
13	Apex Legends	2019-02-04
14	League of Legends	2009-10-27
15	DOTA 2	2013-07-09
16	World of Warcraft	2004-11-23
17	Mortal Kombat 11	2019-04-23
18	Cyber Hunter	2019-04-26
19	Rocket League	2015-07-07
20	The Elder Scrolls V: Skyrim	2011-11-11
21	Destiny 2	2017-09-06
22	Counter-Strike: Global Offensive	2012-08-21
23	Among Us	2018-11-16
24	Rust	2013-12-11
25	Dota Underlords	2020-02-25
26	Valorant	2020-06-02
27	Sea of Thieves	2018-03-20
28	The Last of Us Part II	2020-06-19
29	Hades	2020-09-17
\.


--
-- TOC entry 3186 (class 0 OID 16853)
-- Dependencies: 217
-- Data for Name: sahipoyunlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sahipoyunlar (kisino, oyunid) FROM stdin;
14	8
16	9
18	10
19	11
23	13
25	14
27	15
29	16
31	17
34	19
36	20
19	3
31	25
19	1
16	25
16	22
34	24
27	4
23	22
\.


--
-- TOC entry 3187 (class 0 OID 16856)
-- Dependencies: 218
-- Data for Name: yapimci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yapimci (kisino) FROM stdin;
11
21
28
35
20
26
32
40
8
13
17
24
30
9001
160085
\.


--
-- TOC entry 3188 (class 0 OID 16859)
-- Dependencies: 219
-- Data for Name: yetkiler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yetkiler (yetkiid, yetkiadi) FROM stdin;
1	Oyun Geliştirme
2	Müşteri Hizmetleri
3	Finans
4	Pazarlama
5	Sistem Yönetimi
\.


--
-- TOC entry 3208 (class 0 OID 0)
-- Dependencies: 224
-- Name: arkadaskayit_arkadaslikid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arkadaskayit_arkadaslikid_seq', 51, true);


--
-- TOC entry 3209 (class 0 OID 0)
-- Dependencies: 202
-- Name: basariref_basariid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.basariref_basariid_seq', 20, true);


--
-- TOC entry 3210 (class 0 OID 0)
-- Dependencies: 206
-- Name: durumlar_durumid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.durumlar_durumid_seq', 3, true);


--
-- TOC entry 3211 (class 0 OID 0)
-- Dependencies: 210
-- Name: istatistikref_istatistikid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.istatistikref_istatistikid_seq', 29, true);


--
-- TOC entry 3212 (class 0 OID 0)
-- Dependencies: 212
-- Name: kisi_kisino_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kisi_kisino_seq', 63, true);


--
-- TOC entry 3213 (class 0 OID 0)
-- Dependencies: 220
-- Name: log_logid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_logid_seq', 15, true);


--
-- TOC entry 3214 (class 0 OID 0)
-- Dependencies: 222
-- Name: logbakiye_logid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logbakiye_logid_seq', 29, true);


--
-- TOC entry 3215 (class 0 OID 0)
-- Dependencies: 216
-- Name: oyunlarreferans_oyunid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oyunlarreferans_oyunid_seq', 29, true);


--
-- TOC entry 3000 (class 2606 OID 17193)
-- Name: arkadaskayit arkadaskayit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arkadaskayit
    ADD CONSTRAINT arkadaskayit_pkey PRIMARY KEY (arkadaslikid);


--
-- TOC entry 2968 (class 2606 OID 16870)
-- Name: basarilar basarilar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basarilar
    ADD CONSTRAINT basarilar_pkey PRIMARY KEY (kisino, basariid);


--
-- TOC entry 2972 (class 2606 OID 16872)
-- Name: calisan calisan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_pkey PRIMARY KEY (kisino);


--
-- TOC entry 2974 (class 2606 OID 16874)
-- Name: departman departman_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departman
    ADD CONSTRAINT departman_pkey PRIMARY KEY (departmanid);


--
-- TOC entry 2980 (class 2606 OID 16878)
-- Name: istatistikref istatistikref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.istatistikref
    ADD CONSTRAINT istatistikref_pkey PRIMARY KEY (istatistikid);


--
-- TOC entry 2982 (class 2606 OID 16880)
-- Name: kisi kisi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi
    ADD CONSTRAINT kisi_pkey PRIMARY KEY (kisino);


--
-- TOC entry 2996 (class 2606 OID 17125)
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (logid);


--
-- TOC entry 2998 (class 2606 OID 17158)
-- Name: logbakiye logbakiye_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logbakiye
    ADD CONSTRAINT logbakiye_pkey PRIMARY KEY (logid);


--
-- TOC entry 2986 (class 2606 OID 16882)
-- Name: oyunlarmagaza oyunlarmagaza_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyunlarmagaza
    ADD CONSTRAINT oyunlarmagaza_pkey PRIMARY KEY (oyunid, kisiid);


--
-- TOC entry 2970 (class 2606 OID 16886)
-- Name: basariref pk_basariref; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basariref
    ADD CONSTRAINT pk_basariref PRIMARY KEY (basariid);


--
-- TOC entry 2976 (class 2606 OID 16888)
-- Name: durumlar pk_durumlar; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.durumlar
    ADD CONSTRAINT pk_durumlar PRIMARY KEY (durumid);


--
-- TOC entry 2978 (class 2606 OID 16890)
-- Name: il pk_ilplaka; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.il
    ADD CONSTRAINT pk_ilplaka PRIMARY KEY (ilplaka);


--
-- TOC entry 2984 (class 2606 OID 16892)
-- Name: oyuncu pk_oyuncu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyuncu
    ADD CONSTRAINT pk_oyuncu PRIMARY KEY (kisino);


--
-- TOC entry 2988 (class 2606 OID 16894)
-- Name: oyunlarreferans pk_oyunlarreferans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyunlarreferans
    ADD CONSTRAINT pk_oyunlarreferans PRIMARY KEY (oyunid);


--
-- TOC entry 2992 (class 2606 OID 16896)
-- Name: yapimci pk_yapimci; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yapimci
    ADD CONSTRAINT pk_yapimci PRIMARY KEY (kisino);


--
-- TOC entry 2990 (class 2606 OID 16898)
-- Name: sahipoyunlar sahipoyunlar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahipoyunlar
    ADD CONSTRAINT sahipoyunlar_pkey PRIMARY KEY (kisino, oyunid);


--
-- TOC entry 2994 (class 2606 OID 16900)
-- Name: yetkiler yetkiler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yetkiler
    ADD CONSTRAINT yetkiler_pkey PRIMARY KEY (yetkiid);


--
-- TOC entry 3021 (class 2620 OID 17043)
-- Name: kisi arkadaslik_kayit_sil_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER arkadaslik_kayit_sil_trigger BEFORE DELETE ON public.kisi FOR EACH ROW EXECUTE FUNCTION public.kisidenarkadaslikkayitsil();


--
-- TOC entry 3036 (class 2620 OID 17169)
-- Name: oyuncu bakiye_guncelleme_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bakiye_guncelleme_trigger BEFORE UPDATE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.logbakiyeguncelleme();


--
-- TOC entry 3037 (class 2620 OID 17171)
-- Name: oyuncu bakiye_uyari_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bakiye_uyari_trigger BEFORE UPDATE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.bakiyeuyari();


--
-- TOC entry 3025 (class 2620 OID 17084)
-- Name: kisi kisi_sil_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kisi_sil_trigger BEFORE DELETE ON public.kisi FOR EACH ROW EXECUTE FUNCTION public.silinenkisiyisil();


--
-- TOC entry 3022 (class 2620 OID 17045)
-- Name: kisi kisi_sil_trigger_calisan; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kisi_sil_trigger_calisan BEFORE DELETE ON public.kisi FOR EACH ROW EXECUTE FUNCTION public.silinenkisiyisilcalisan();


--
-- TOC entry 3024 (class 2620 OID 17133)
-- Name: kisi kisi_sil_trigger_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kisi_sil_trigger_log BEFORE DELETE ON public.kisi FOR EACH ROW EXECUTE FUNCTION public.kisi_siltrigger_log();


--
-- TOC entry 3023 (class 2620 OID 17047)
-- Name: kisi kisi_sil_trigger_yapimci; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kisi_sil_trigger_yapimci BEFORE DELETE ON public.kisi FOR EACH ROW EXECUTE FUNCTION public.silinenkisiyisilyapimci();


--
-- TOC entry 3026 (class 2620 OID 16994)
-- Name: oyuncu oyuncu_sil_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3027 (class 2620 OID 16996)
-- Name: oyuncu oyuncu_sil_trigger2; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger2 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3031 (class 2620 OID 17035)
-- Name: oyuncu oyuncu_sil_trigger22; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger22 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil2();


--
-- TOC entry 3028 (class 2620 OID 16997)
-- Name: oyuncu oyuncu_sil_trigger3; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger3 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3032 (class 2620 OID 17037)
-- Name: oyuncu oyuncu_sil_trigger33; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger33 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil3();


--
-- TOC entry 3029 (class 2620 OID 16998)
-- Name: oyuncu oyuncu_sil_trigger4; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger4 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3033 (class 2620 OID 17039)
-- Name: oyuncu oyuncu_sil_trigger44; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger44 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil4();


--
-- TOC entry 3030 (class 2620 OID 17000)
-- Name: oyuncu oyuncu_sil_trigger5; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger5 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3034 (class 2620 OID 17040)
-- Name: oyuncu oyuncu_sil_trigger55; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger55 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3035 (class 2620 OID 17083)
-- Name: oyuncu oyuncu_sil_trigger555; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oyuncu_sil_trigger555 BEFORE DELETE ON public.oyuncu FOR EACH ROW EXECUTE FUNCTION public.silinenoyuncuyusil();


--
-- TOC entry 3038 (class 2620 OID 17049)
-- Name: yapimci yapimci_sil_trigger_oyunlar_magaza; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER yapimci_sil_trigger_oyunlar_magaza BEFORE DELETE ON public.yapimci FOR EACH ROW EXECUTE FUNCTION public.oyunlarmagazasilyapimci();


--
-- TOC entry 3003 (class 2606 OID 16901)
-- Name: calisan calisan_departmanno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_departmanno_fkey FOREIGN KEY (departmanno) REFERENCES public.departman(departmanid);


--
-- TOC entry 3004 (class 2606 OID 16906)
-- Name: calisan calisan_kisino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_kisino_fkey FOREIGN KEY (kisino) REFERENCES public.kisi(kisino);


--
-- TOC entry 3005 (class 2606 OID 16911)
-- Name: calisan calisan_yetkino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_yetkino_fkey FOREIGN KEY (yetkino) REFERENCES public.yetkiler(yetkiid);


--
-- TOC entry 3001 (class 2606 OID 16916)
-- Name: basarilar fk_basariid_basarilar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basarilar
    ADD CONSTRAINT fk_basariid_basarilar FOREIGN KEY (basariid) REFERENCES public.basariref(basariid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3020 (class 2606 OID 17204)
-- Name: arkadaskayit fk_durum; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arkadaskayit
    ADD CONSTRAINT fk_durum FOREIGN KEY (durumid) REFERENCES public.durumlar(durumid);


--
-- TOC entry 3009 (class 2606 OID 16926)
-- Name: kisi fk_il; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi
    ADD CONSTRAINT fk_il FOREIGN KEY (ilno) REFERENCES public.il(ilplaka);


--
-- TOC entry 3016 (class 2606 OID 17126)
-- Name: log fk_il; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_il FOREIGN KEY (ilno) REFERENCES public.il(ilplaka);


--
-- TOC entry 3007 (class 2606 OID 17221)
-- Name: istatistik fk_istatistikid_istatistikref; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.istatistik
    ADD CONSTRAINT fk_istatistikid_istatistikref FOREIGN KEY (istatistikid) REFERENCES public.istatistikref(istatistikid);


--
-- TOC entry 3011 (class 2606 OID 16936)
-- Name: oyunlarmagaza fk_kisiid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyunlarmagaza
    ADD CONSTRAINT fk_kisiid FOREIGN KEY (kisiid) REFERENCES public.kisi(kisino);


--
-- TOC entry 3015 (class 2606 OID 16941)
-- Name: yapimci fk_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yapimci
    ADD CONSTRAINT fk_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(kisino);


--
-- TOC entry 3010 (class 2606 OID 16946)
-- Name: oyuncu fk_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyuncu
    ADD CONSTRAINT fk_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(kisino);


--
-- TOC entry 3002 (class 2606 OID 16951)
-- Name: basarilar fk_kisino_basarilar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basarilar
    ADD CONSTRAINT fk_kisino_basarilar FOREIGN KEY (kisino) REFERENCES public.oyuncu(kisino);


--
-- TOC entry 3006 (class 2606 OID 16956)
-- Name: istatistik fk_kisino_istatistik; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.istatistik
    ADD CONSTRAINT fk_kisino_istatistik FOREIGN KEY (kisino) REFERENCES public.oyuncu(kisino);


--
-- TOC entry 3017 (class 2606 OID 17159)
-- Name: logbakiye fk_kisino_logbakiye; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logbakiye
    ADD CONSTRAINT fk_kisino_logbakiye FOREIGN KEY (kisino) REFERENCES public.oyuncu(kisino);


--
-- TOC entry 3013 (class 2606 OID 16961)
-- Name: sahipoyunlar fk_kisino_sahipoyunlar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahipoyunlar
    ADD CONSTRAINT fk_kisino_sahipoyunlar FOREIGN KEY (kisino) REFERENCES public.oyuncu(kisino) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3018 (class 2606 OID 17194)
-- Name: arkadaskayit fk_kullanici1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arkadaskayit
    ADD CONSTRAINT fk_kullanici1 FOREIGN KEY (kullanici1id) REFERENCES public.kisi(kisino);


--
-- TOC entry 3019 (class 2606 OID 17199)
-- Name: arkadaskayit fk_kullanici2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arkadaskayit
    ADD CONSTRAINT fk_kullanici2 FOREIGN KEY (kullanici2id) REFERENCES public.kisi(kisino);


--
-- TOC entry 3012 (class 2606 OID 16976)
-- Name: oyunlarmagaza fk_oyunid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oyunlarmagaza
    ADD CONSTRAINT fk_oyunid FOREIGN KEY (oyunid) REFERENCES public.oyunlarreferans(oyunid) ON DELETE CASCADE;


--
-- TOC entry 3008 (class 2606 OID 16981)
-- Name: istatistikref fk_oyunid_istatistikref; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.istatistikref
    ADD CONSTRAINT fk_oyunid_istatistikref FOREIGN KEY (oyunid) REFERENCES public.oyunlarreferans(oyunid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3014 (class 2606 OID 16986)
-- Name: sahipoyunlar fk_oyunid_sahipoyunlar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sahipoyunlar
    ADD CONSTRAINT fk_oyunid_sahipoyunlar FOREIGN KEY (oyunid) REFERENCES public.oyunlarreferans(oyunid) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2023-12-26 00:02:49

--
-- PostgreSQL database dump complete
--

