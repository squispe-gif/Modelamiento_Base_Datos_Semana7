/* =========================================================================
   PRY2204 - Modelamiento de Bases de Datos
   Semana 7 - Actividad formativa: "Realizando el poblamiento y consultas
   en la base de datos con sentencias SQL"
   Caso: Holding Carpenter SPA
   ========================================================================= */


/* =========================================================================
   BLOQUE 0: Eliminación de objetos (orden inverso a la creación)
   ========================================================================= */
DROP TABLE titulacion   CASCADE CONSTRAINTS PURGE;
DROP TABLE dominio      CASCADE CONSTRAINTS PURGE;
DROP TABLE personal     CASCADE CONSTRAINTS PURGE;
DROP TABLE compania     CASCADE CONSTRAINTS PURGE;
DROP TABLE comuna       CASCADE CONSTRAINTS PURGE;
DROP TABLE idioma       CASCADE CONSTRAINTS PURGE;
DROP TABLE titulo       CASCADE CONSTRAINTS PURGE;
DROP TABLE estado_civil CASCADE CONSTRAINTS PURGE;
DROP TABLE genero       CASCADE CONSTRAINTS PURGE;
DROP TABLE region       CASCADE CONSTRAINTS PURGE;

DROP SEQUENCE seq_comuna;
DROP SEQUENCE seq_compania;


/* =========================================================================
   CASO 1: Implementación del modelo relacional
   Creación de tablas en orden secuencial (tablas fuertes a más débiles).
   Se definen tipos de datos, precisiones y restricciones según Figura 1.
   - Identificador de regiones: inicia en 7 e incrementa en 2 (identity).
   - Identificador de idiomas: inicia en 25 e incrementa en 3 (identity).
   ========================================================================= */

-- 1. Tabla REGION (Tabla fuerte - Identificador autoincremental con identity)
CREATE TABLE region (
    id_region     NUMBER(2) GENERATED ALWAYS AS IDENTITY (START WITH 7 INCREMENT BY 2) NOT NULL,
    nombre_region VARCHAR2(25) NOT NULL
);
ALTER TABLE region ADD CONSTRAINT region_pk PRIMARY KEY (id_region);


-- 2. Tabla GENERO (Tabla fuerte)
CREATE TABLE genero (
    id_genero          VARCHAR2(3)  NOT NULL,
    descripcion_genero VARCHAR2(25) NOT NULL
);
ALTER TABLE genero ADD CONSTRAINT genero_pk PRIMARY KEY (id_genero);


-- 3. Tabla ESTADO_CIVIL (Tabla fuerte)
CREATE TABLE estado_civil (
    id_estado_civil       VARCHAR2(2)  NOT NULL,
    descripcion_est_civil VARCHAR2(25) NOT NULL
);
ALTER TABLE estado_civil ADD CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil);


-- 4. Tabla TITULO (Tabla fuerte)
CREATE TABLE titulo (
    id_titulo          VARCHAR2(3)  NOT NULL,
    descripcion_titulo VARCHAR2(60) NOT NULL
);
ALTER TABLE titulo ADD CONSTRAINT titulo_pk PRIMARY KEY (id_titulo);


-- 5. Tabla IDIOMA (Tabla fuerte - Identificador autoincremental con identity)
CREATE TABLE idioma (
    id_idioma     NUMBER(3) GENERATED ALWAYS AS IDENTITY (START WITH 25 INCREMENT BY 3) NOT NULL,
    nombre_idioma VARCHAR2(30) NOT NULL
);
ALTER TABLE idioma ADD CONSTRAINT idioma_pk PRIMARY KEY (id_idioma);


-- 6. Tabla COMUNA (Depende de REGION)
CREATE TABLE comuna (
    id_comuna     NUMBER(5)    NOT NULL,
    comuna_nombre VARCHAR2(25) NOT NULL,
    cod_region    NUMBER(2)    NOT NULL
);
ALTER TABLE comuna ADD CONSTRAINT comuna_pk PRIMARY KEY (id_comuna, cod_region);
ALTER TABLE comuna ADD CONSTRAINT comuna_fk_region
    FOREIGN KEY (cod_region) REFERENCES region (id_region);


-- 7. Tabla COMPANIA (Depende de COMUNA mediante clave foránea compuesta)
CREATE TABLE compania (
    id_empresa     NUMBER(2)    NOT NULL,
    nombre_empresa VARCHAR2(25) NOT NULL,
    calle          VARCHAR2(50) NOT NULL,
    numeracion     NUMBER(5)    NOT NULL,
    renta_promedio NUMBER(10)   NOT NULL,
    pct_aumento    NUMBER(4,3),
    cod_comuna     NUMBER(5)    NOT NULL,
    cod_region     NUMBER(2)    NOT NULL
);
ALTER TABLE compania ADD CONSTRAINT compania_pk PRIMARY KEY (id_empresa);
ALTER TABLE compania ADD CONSTRAINT compania_un_nombre UNIQUE (nombre_empresa);
ALTER TABLE compania ADD CONSTRAINT compania_fk_comuna
    FOREIGN KEY (cod_comuna, cod_region) REFERENCES comuna (id_comuna, cod_region);


-- 8. Tabla PERSONAL (Depende de COMPANIA, COMUNA, ESTADO_CIVIL, GENERO y recursiva)
CREATE TABLE personal (
    rut_persona        NUMBER(8)     NOT NULL,
    dv_persona         CHAR(1)       NOT NULL,
    primer_nombre      VARCHAR2(25)  NOT NULL,
    segundo_nombre     VARCHAR2(25),
    primer_apellido    VARCHAR2(25)  NOT NULL,
    segundo_apellido   VARCHAR2(25),
    fecha_contratacion DATE          NOT NULL,
    fecha_nacimiento   DATE          NOT NULL,
    email              VARCHAR2(100),
    calle              VARCHAR2(50)  NOT NULL,
    numeracion         NUMBER(5)     NOT NULL,
    sueldo             NUMBER(8)     NOT NULL,
    cod_comuna         NUMBER(5)     NOT NULL,
    cod_region         NUMBER(2)     NOT NULL,
    cod_genero         VARCHAR2(3),
    cod_estado_civil   VARCHAR2(2),
    cod_empresa        NUMBER(2)     NOT NULL,
    encargado_rut      NUMBER(8)
);
ALTER TABLE personal ADD CONSTRAINT personal_pk PRIMARY KEY (rut_persona);
ALTER TABLE personal ADD CONSTRAINT personal_fk_compania
    FOREIGN KEY (cod_empresa) REFERENCES compania (id_empresa);
ALTER TABLE personal ADD CONSTRAINT personal_fk_comuna
    FOREIGN KEY (cod_comuna, cod_region) REFERENCES comuna (id_comuna, cod_region);
ALTER TABLE personal ADD CONSTRAINT personal_fk_estado_civil
    FOREIGN KEY (cod_estado_civil) REFERENCES estado_civil (id_estado_civil);
ALTER TABLE personal ADD CONSTRAINT personal_fk_genero
    FOREIGN KEY (cod_genero) REFERENCES genero (id_genero);
ALTER TABLE personal ADD CONSTRAINT personal_personal_fk
    FOREIGN KEY (encargado_rut) REFERENCES personal (rut_persona);


-- 9. Tabla DOMINIO (Tabla asociativa N:M entre IDIOMA y PERSONAL)
CREATE TABLE dominio (
    id_idioma   NUMBER(3)    NOT NULL,
    persona_rut NUMBER(8)    NOT NULL,
    nivel       VARCHAR2(25) NOT NULL
);
ALTER TABLE dominio ADD CONSTRAINT dominio_pk PRIMARY KEY (id_idioma, persona_rut);
ALTER TABLE dominio ADD CONSTRAINT dominio_fk_idioma
    FOREIGN KEY (id_idioma) REFERENCES idioma (id_idioma);
ALTER TABLE dominio ADD CONSTRAINT dominio_fk_personal
    FOREIGN KEY (persona_rut) REFERENCES personal (rut_persona);


-- 10. Tabla TITULACION (Tabla asociativa N:M entre TITULO y PERSONAL)
CREATE TABLE titulacion (
    cod_titulo       VARCHAR2(3) NOT NULL,
    persona_rut      NUMBER(8)   NOT NULL,
    fecha_titulacion DATE        NOT NULL
);
ALTER TABLE titulacion ADD CONSTRAINT titulacion_pk PRIMARY KEY (cod_titulo, persona_rut);
ALTER TABLE titulacion ADD CONSTRAINT titulacion_fk_titulo
    FOREIGN KEY (cod_titulo) REFERENCES titulo (id_titulo);
ALTER TABLE titulacion ADD CONSTRAINT titulacion_fk_personal
    FOREIGN KEY (persona_rut) REFERENCES personal (rut_persona);


/* =========================================================================
   CASO 2: Modificación del modelo
   Incorporación de reglas de negocio solicitadas mediante ALTER TABLE.
   ========================================================================= */

-- 1. Aunque el email de una persona es opcional, no se debe repetir (Clave Única).
ALTER TABLE personal ADD CONSTRAINT personal_email_un UNIQUE (email);

-- 2. El dígito verificador del RUN del PERSONAL debe estar en: 0,1,2,3,4,5,6,7,8,9,'K'.
ALTER TABLE personal ADD CONSTRAINT personal_dv_ck
    CHECK (dv_persona IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- 3. Debes considerar que el sueldo mínimo del personal es de 450.000 pesos.
ALTER TABLE personal ADD CONSTRAINT personal_sueldo_ck
    CHECK (sueldo >= 450000);


/* =========================================================================
   CASO 3: Poblamiento del modelo
   Secuencias e inserción de datos en orden de dependencias (fuerte a débil).
   ========================================================================= */

-- Objeto Secuencia para COMUNA: inicia en 1101, incrementa en 6.
CREATE SEQUENCE seq_comuna
    START WITH 1101
    INCREMENT BY 6
    NOCACHE
    NOCYCLE;

-- Objeto Secuencia para COMPANIA: inicia en 10, incrementa en 5.
CREATE SEQUENCE seq_compania
    START WITH 10
    INCREMENT BY 5
    NOCACHE
    NOCYCLE;


-- 1. Poblamiento de REGION (usa identity: autoincrementa de 7 en 2)
INSERT INTO region (nombre_region) VALUES ('ARICA Y PARINACOTA');
INSERT INTO region (nombre_region) VALUES ('METROPOLITANA');
INSERT INTO region (nombre_region) VALUES ('LA ARAUCANIA');


-- 2. Poblamiento de COMUNA (usa secuencia seq_comuna)
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region) VALUES (seq_comuna.NEXTVAL, 'Arica', 7);
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region) VALUES (seq_comuna.NEXTVAL, 'Santiago', 9);
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region) VALUES (seq_comuna.NEXTVAL, 'Temuco', 11);


-- 3. Poblamiento de COMPANIA (usa secuencia seq_compania)
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'CCyRojas', 'Amapolas', 506, 1857000, 0.5, 1101, 7);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'SenTTy', 'Los Alamos', 3490, 897000, 0.025, 1101, 7);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'Praxia LTDA', 'Las Camelias', 11098, 2157000, 0.035, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'TIC spa', 'FLORES S.A.', 4357, 857000, NULL, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'SANTANA LTDA', 'AVDA VIC. MACKENA', 106, 757000, 0.015, 1101, 7);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'FLORES Y ASOCIADOS', 'PEDRO LATORRE', 557, 589000, 0.015, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'J.A. HOFFMAN', 'LATINA D.32', 509, 1857000, 0.025, 1113, 11);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'CAGLIARI D.', 'ALAMEDA', 206, 1857000, NULL, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'Rojas HNOS LTDA', 'SUCRE', 106, 957000, 0.005, 1113, 11);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'FRIENDS P. S.A', 'SUECIA', 506, 857000, 0.015, 1113, 11);


-- 4. Poblamiento de IDIOMA (usa identity: autoincrementa de 25 en 3)
INSERT INTO idioma (nombre_idioma) VALUES ('Ingles');
INSERT INTO idioma (nombre_idioma) VALUES ('Chino');
INSERT INTO idioma (nombre_idioma) VALUES ('Aleman');
INSERT INTO idioma (nombre_idioma) VALUES ('Espanol');
INSERT INTO idioma (nombre_idioma) VALUES ('Frances');

-- Confirmación definitiva de transacciones DML
COMMIT;


/* =========================================================================
   CASO 4: Recuperación de Datos
   ========================================================================= */

-- INFORME 1: Simulación de Renta Promedio
-- Requerimientos:
-- - Nombre de la empresa
-- - Dirección completa (calle y numeración)
-- - Renta promedio de cada una
-- - Simulación de renta promedio aplicando el porcentaje de aumento correspondiente.
-- Orden: "Renta Promedio" descendente; en empate, "Nombre Empresa" ascendente.
SELECT
    nombre_empresa AS "Nombre Empresa",
    calle || ' ' || numeracion AS "Dirección",
    renta_promedio AS "Renta Promedio",
    renta_promedio + (renta_promedio * pct_aumento) AS "Simulación de Renta"
FROM compania
ORDER BY "Renta Promedio" DESC, "Nombre Empresa" ASC;


-- INFORME 2: Nueva Simulación de Renta Promedio (+15% adicional)
-- Requerimientos:
-- - ID de la empresa (CODIGO)
-- - Nombre de la empresa (EMPRESA)
-- - Renta promedio actual (PROM RENTA ACTUAL)
-- - Porcentaje aumentado en 15% (PCT AUMENTADO EN 15%)
-- - Renta promedio incrementada tras aplicar el porcentaje adicional (RENTA AUMENTADA)
-- Orden: Renta promedio actual ascendente; en empate, nombre de la empresa descendente.
SELECT
    id_empresa AS CODIGO,
    nombre_empresa AS EMPRESA,
    renta_promedio AS "PROM RENTA ACTUAL",
    pct_aumento + 0.15 AS "PCT AUMENTADO EN 15%",
    renta_promedio * (pct_aumento + 0.15) AS "RENTA AUMENTADA"
FROM compania
ORDER BY renta_promedio ASC, nombre_empresa DESC;
-- NOTA: Si se requiere ordenar con el criterio visual de la Figura 4 (desempate por CODIGO DESC), usar:
-- ORDER BY renta_promedio ASC, id_empresa DESC;