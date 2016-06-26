-- Modelo Físico EDGV 2.13 em Postgres/PostGIS - extensões, funções e triggers de producao 1DL


BEGIN;
--TABELA PARA EXTENSÃO DO BANCO

CREATE TABLE "DOMINIOS"."reambular" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."reambular" TO public;

INSERT INTO "DOMINIOS"."reambular" (code, valor) VALUES 
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."tipoComprovacao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoComprovacao" TO public;

INSERT INTO "DOMINIOS"."tipoComprovacao" (code, valor) VALUES 
(1,'Confirmado em campo'),
(2,'Fotointerpretado'),
(3,'Insumo externo'),
(4,'Extração automática'),
(999,'A ser preenchido');


--FUNCAO PARA ESTILOS QGIS
CREATE OR REPLACE FUNCTION estilo()
  RETURNS integer AS
$BODY$
    UPDATE layer_styles
        SET f_table_catalog = (select current_catalog)
        WHERE f_table_catalog<>(SELECT current_catalog);
    SELECT 1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION estilo()
  OWNER TO postgres;

--ALTERACOES NA BASE - INICIO
--CAMPOS EXTENDIDOS

CREATE TABLE "LIM"."Bairro_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80)
);
SELECT AddGeometryColumn('LIM', 'Bairro_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Bairro_P_geom ON "LIM"."Bairro_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Bairro_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Bairro_P" TO public;


--TRIGGERS
CREATE EXTENSION hstore;
--VALIDA GEOMETRIA - INICIO
CREATE OR REPLACE FUNCTION geom_valid()
  RETURNS trigger AS
$BODY$
    DECLARE empty boolean;
    DECLARE geometrytype text;
    DECLARE npoints integer;
    BEGIN

	empty := ST_IsEmpty(NEW.geom::Geometry);

	IF empty THEN
		RETURN NULL;
	ELSE
		geometrytype := st_geometrytype(NEW.geom::Geometry);
		npoints := ST_NPoints(NEW.geom::Geometry);
		IF geometrytype = 'ST_MultiLineString' AND npoints < 2 THEN
			RETURN NULL;
		END IF;

		IF geometrytype = 'ST_MultiPolygon' AND npoints < 3 THEN
			RETURN NULL;
		END IF;

		IF geometrytype = 'ST_MultiPoint'  AND npoints < 1 THEN
			RETURN NULL;
		END IF;

		RETURN NEW;
	END IF;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION geom_valid()
  OWNER TO postgres;
--VALIDA GEOMETRIA - FIM


--CALCULA AREA LENGTH  - INICIO
CREATE OR REPLACE FUNCTION calc_area_length()
  RETURNS trigger AS
$BODY$
    DECLARE geometrytype text;
    BEGIN
	geometrytype := st_geometrytype(NEW.geom::Geometry);

	IF geometrytype = 'ST_MultiLineString' THEN
		NEW.shape_length := ST_Length(NEW.geom::Geometry);
	END IF;

	IF geometrytype = 'ST_MultiPolygon' THEN
		NEW.shape_area := ST_Area(NEW.geom::Geometry);
	END IF;

	RETURN NEW;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION calc_area_length()
  OWNER TO postgres;
--CALCULA AREA LENGTH - FIM


--EXPLODE GEOMETRIA - INICIO
CREATE OR REPLACE FUNCTION explode_geometries()
  RETURNS trigger AS
$BODY$
    DECLARE querytext1 text;
    DECLARE querytext2 text;
    DECLARE r record;
    BEGIN
        IF pg_trigger_depth() <> 1 AND ST_NumGeometries(NEW.geom) =1 THEN
		RETURN NEW;
	END IF;
	IF ST_NumGeometries(NEW.geom) > 1 THEN

		querytext1 := 'INSERT INTO "' || TG_TABLE_SCHEMA || '"."' || TG_TABLE_NAME || '"(';
		querytext2 := 'geom) SELECT ';

		FOR r IN SELECT (each(hstore(NEW))).* 
		LOOP
			IF r.key <> 'geom' AND r.key <> 'id' THEN
				querytext1 := querytext1 || r.key || ',';
				IF r.value <> '' THEN
					querytext2 := querytext2 || '''' || r.value || ''',';
				ELSE
					querytext2 := querytext2 || 'NULL' || ',';					
				END IF;
			END IF;
		END LOOP;

		IF TG_OP = 'UPDATE' THEN
			EXECUTE 'DELETE FROM "' || TG_TABLE_NAME || '" WHERE id = ' || OLD.id;
		END IF;


		querytext1 := querytext1  || querytext2;
		EXECUTE querytext1 || 'ST_Multi((ST_Dump(ST_AsEWKT(''' || NEW.geom::text || '''))).geom);';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
	RETURN NULL;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION explode_geometries()
  OWNER TO postgres;

--APLICACAO DE TRIGGER NAS TABELAS - INICIO
ALTER TABLE "ADM"."Area_Pub_Civil_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Civil_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Civil_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Civil_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Civil_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Civil_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Area_Pub_Civil_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ADM"."Area_Pub_Civil_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Civil_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Civil_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Civil_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Civil_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Civil_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Area_Pub_Militar_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Militar_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Militar_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Militar_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Militar_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Area_Pub_Militar_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Area_Pub_Militar_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ADM"."Edif_Pub_Civil_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Civil_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Civil_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Civil_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Edif_Pub_Civil_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ADM"."Edif_Pub_Civil_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Civil_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Civil_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Civil_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Edif_Pub_Militar_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Militar_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Militar_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Militar_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Edif_Pub_Militar_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ADM"."Edif_Pub_Militar_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Militar_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Militar_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Edif_Pub_Militar_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Instituicao_Publica"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Instituicao_Publica"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Instituicao_Publica"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Instituicao_Publica"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Instituicao_Publica"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Instituicao_Publica"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Posto_Fiscal_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Fiscal_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Fiscal_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Fiscal_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Posto_Fiscal_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ADM"."Posto_Fiscal_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Fiscal_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Fiscal_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Fiscal_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Posto_Pol_Rod_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Pol_Rod_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Pol_Rod_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Pol_Rod_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ADM"."Posto_Pol_Rod_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ADM"."Posto_Pol_Rod_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Pol_Rod_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Pol_Rod_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ADM"."Posto_Pol_Rod_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Area_Abast_Agua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Area_Abast_Agua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Area_Abast_Agua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Area_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Area_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Area_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Area_Abast_Agua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Area_Saneamento_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Area_Saneamento_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Area_Saneamento_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Area_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Area_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Area_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Area_Saneamento_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Cemiterio_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Cemiterio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Cemiterio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Cemiterio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Cemiterio_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Cemiterio_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Cemiterio_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Cemiterio_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Cemiterio_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Dep_Abast_Agua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Dep_Abast_Agua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Dep_Abast_Agua_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Abast_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Abast_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Abast_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Dep_Saneamento_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Dep_Saneamento_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Dep_Saneamento_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Saneamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Saneamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Dep_Saneamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Edif_Abast_Agua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Abast_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Edif_Abast_Agua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Edif_Abast_Agua_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Abast_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Abast_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Abast_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Edif_Saneamento_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Saneamento_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ASB"."Edif_Saneamento_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ASB"."Edif_Saneamento_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Saneamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Saneamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ASB"."Edif_Saneamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Objeto_Desconhecido_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Objeto_Desconhecido_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Ponto_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Ponto_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Ponto_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Ponto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Ponto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Ponto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Valida_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Valida_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Valida_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Valida_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "AUX"."Aux_Valida_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Valida_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Valida_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "AUX"."Aux_Valida_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "AUX"."Aux_Valida_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Valida_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "AUX"."Aux_Valida_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "AUX"."Aux_Valida_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Area_Comerc_Serv_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Area_Comerc_Serv_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Area_Comerc_Serv_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Comerc_Serv_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Comerc_Serv_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Comerc_Serv_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Area_Comerc_Serv_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Area_Ext_Mineral_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Area_Ext_Mineral_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Area_Ext_Mineral_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Area_Ext_Mineral_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Area_Industrial_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Area_Industrial_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Area_Industrial_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Industrial_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Industrial_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Area_Industrial_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Area_Industrial_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Deposito_Geral_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Deposito_Geral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Deposito_Geral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Deposito_Geral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Deposito_Geral_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Deposito_Geral_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Deposito_Geral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Deposito_Geral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Deposito_Geral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Comerc_Serv_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Comerc_Serv_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Comerc_Serv_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Comerc_Serv_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Comerc_Serv_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Edif_Comerc_Serv_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Comerc_Serv_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Comerc_Serv_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Comerc_Serv_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Ext_Mineral_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Ext_Mineral_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Edif_Ext_Mineral_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Ext_Mineral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Ext_Mineral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Ext_Mineral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Industrial_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Industrial_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Industrial_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Industrial_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Edif_Industrial_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Edif_Industrial_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Industrial_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Industrial_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Edif_Industrial_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Equip_Agropec_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Equip_Agropec_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Equip_Agropec_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Equip_Agropec_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "ECO"."Equip_Agropec_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Equip_Agropec_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Ext_Mineral_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Ext_Mineral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Ext_Mineral_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Ext_Mineral_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Ext_Mineral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Ext_Mineral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Ext_Mineral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Plataforma_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Plataforma_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Plataforma_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Plataforma_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ECO"."Plataforma_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ECO"."Plataforma_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ECO"."Plataforma_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ECO"."Plataforma_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ECO"."Plataforma_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Area_Ensino_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Area_Ensino_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Area_Ensino_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Ensino_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Ensino_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Ensino_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Area_Ensino_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Area_Lazer_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Area_Lazer_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Area_Lazer_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Lazer_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Lazer_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Lazer_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Area_Lazer_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Area_Religiosa_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Area_Religiosa_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Area_Religiosa_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Religiosa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Religiosa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Religiosa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Area_Religiosa_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Area_Ruinas_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Area_Ruinas_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Area_Ruinas_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Ruinas_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Ruinas_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Area_Ruinas_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Area_Ruinas_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Arquibancada_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Arquibancada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Arquibancada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Arquibancada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Arquibancada_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Arquibancada_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Arquibancada_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Arquibancada_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Arquibancada_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Campo_Quadra_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Campo_Quadra_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Campo_Quadra_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Campo_Quadra_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Campo_Quadra_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Campo_Quadra_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Campo_Quadra_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Campo_Quadra_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Campo_Quadra_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Coreto_Tribuna_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Coreto_Tribuna_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Coreto_Tribuna_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Coreto_Tribuna_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Coreto_Tribuna_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Coreto_Tribuna_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Coreto_Tribuna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Coreto_Tribuna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Coreto_Tribuna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Const_Lazer_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Lazer_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Lazer_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Lazer_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Const_Lazer_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Edif_Const_Lazer_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Lazer_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Lazer_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Lazer_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Const_Turistica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Turistica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Turistica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Turistica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Const_Turistica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Edif_Const_Turistica_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Turistica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Turistica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Const_Turistica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Ensino_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Ensino_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Ensino_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Ensino_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Ensino_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Edif_Ensino_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Ensino_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Ensino_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Ensino_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Religiosa_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Religiosa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Religiosa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Religiosa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Edif_Religiosa_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Edif_Religiosa_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Religiosa_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Religiosa_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Edif_Religiosa_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Piscina_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Piscina_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Piscina_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Piscina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Piscina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Piscina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Piscina_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Pista_Competicao_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Pista_Competicao_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Pista_Competicao_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Pista_Competicao_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Pista_Competicao_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Pista_Competicao_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Pista_Competicao_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "EDU"."Ruina_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Ruina_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Ruina_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Ruina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Ruina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Ruina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "EDU"."Ruina_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "EDU"."Ruina_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "EDU"."Ruina_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "EDU"."Ruina_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "EDU"."Ruina_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "EDU"."Ruina_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "EDU"."Ruina_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Antena_Comunic_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Antena_Comunic_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Antena_Comunic_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Antena_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Antena_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Antena_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Area_Comunicacao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Area_Comunicacao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Area_Comunicacao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Area_Comunicacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Area_Comunicacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Area_Comunicacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Area_Comunicacao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Area_Energia_Eletrica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Area_Energia_Eletrica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Area_Energia_Eletrica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Area_Energia_Eletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Area_Energia_Eletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Area_Energia_Eletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Area_Energia_Eletrica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Edif_Comunic_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Comunic_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Comunic_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Comunic_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Edif_Comunic_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Edif_Comunic_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Edif_Energia_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Energia_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Energia_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Energia_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Edif_Energia_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Edif_Energia_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Edif_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Est_Gerad_Energia_Eletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Grupo_Transformadores_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Grupo_Transformadores_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Grupo_Transformadores_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Grupo_Transformadores_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Grupo_Transformadores_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Grupo_Transformadores_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Grupo_Transformadores_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Grupo_Transformadores_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Grupo_Transformadores_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Grupo_Transformadores_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Grupo_Transformadores_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Grupo_Transformadores_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Grupo_Transformadores_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Hidreletrica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Hidreletrica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Hidreletrica_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Hidreletrica_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "ENC"."Hidreletrica_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Hidreletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Ponto_Trecho_Energia_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Ponto_Trecho_Energia_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Ponto_Trecho_Energia_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Ponto_Trecho_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Ponto_Trecho_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Ponto_Trecho_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Termeletrica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Termeletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Termeletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Termeletrica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Termeletrica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "ENC"."Termeletrica_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Termeletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Termeletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Termeletrica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Torre_Comunic_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Torre_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Torre_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Torre_Comunic_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Torre_Energia_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Torre_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Torre_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Torre_Energia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Trecho_Comunic_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Trecho_Comunic_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Trecho_Comunic_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Trecho_Comunic_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Trecho_Comunic_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "ENC"."Trecho_Energia_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Trecho_Energia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Trecho_Energia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Trecho_Energia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Trecho_Energia_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Area_Umida_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Area_Umida_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Area_Umida_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Area_Umida_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Area_Umida_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Area_Umida_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Area_Umida_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Bacia_Hidrografica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Bacia_Hidrografica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Bacia_Hidrografica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Bacia_Hidrografica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Bacia_Hidrografica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Bacia_Hidrografica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Bacia_Hidrografica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Banco_Areia_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Banco_Areia_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Banco_Areia_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Banco_Areia_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Banco_Areia_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Banco_Areia_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Banco_Areia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Banco_Areia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Banco_Areia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Banco_Areia_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Barragem_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Barragem_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Barragem_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Barragem_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Barragem_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Barragem_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Barragem_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Barragem_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Barragem_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Barragem_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Barragem_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Barragem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Comporta_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Comporta_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Comporta_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Comporta_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Comporta_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Comporta_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Comporta_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Comporta_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Comporta_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Comporta_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Comporta_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Comporta_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Comporta_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Confluencia_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Confluencia_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Confluencia_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Confluencia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Confluencia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Confluencia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Corredeira_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Corredeira_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Corredeira_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Corredeira_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Corredeira_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Corredeira_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Corredeira_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Corredeira_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Corredeira_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Corredeira_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Corredeira_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Corredeira_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Fonte_Dagua_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Fonte_Dagua_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Fonte_Dagua_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Fonte_Dagua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Fonte_Dagua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Fonte_Dagua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Foz_Maritima_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Foz_Maritima_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Foz_Maritima_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Foz_Maritima_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Foz_Maritima_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Foz_Maritima_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Ilha_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Ilha_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Ilha_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Ilha_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Ilha_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Ilha_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Ilha_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Ilha_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Ilha_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Ilha_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Ilha_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Ilha_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Limite_Massa_Dagua_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Limite_Massa_Dagua_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Limite_Massa_Dagua_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Limite_Massa_Dagua_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Limite_Massa_Dagua_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Limite_Massa_Dagua_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Limite_Massa_Dagua_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Massa_Dagua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Massa_Dagua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Massa_Dagua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Massa_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Massa_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Massa_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Massa_Dagua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Natureza_Fundo_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Natureza_Fundo_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Natureza_Fundo_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Natureza_Fundo_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Natureza_Fundo_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Natureza_Fundo_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Ponto_Drenagem_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Ponto_Drenagem_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Ponto_Drenagem_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Ponto_Drenagem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Ponto_Drenagem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Ponto_Drenagem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Ponto_Inicio_Drenagem_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Ponto_Inicio_Drenagem_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Ponto_Inicio_Drenagem_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Ponto_Inicio_Drenagem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Ponto_Inicio_Drenagem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Ponto_Inicio_Drenagem_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Quebramar_Molhe_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Quebramar_Molhe_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Quebramar_Molhe_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Quebramar_Molhe_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Quebramar_Molhe_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Quebramar_Molhe_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Quebramar_Molhe_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Quebramar_Molhe_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Quebramar_Molhe_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Quebramar_Molhe_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Queda_Dagua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Queda_Dagua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Queda_Dagua_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Queda_Dagua_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Queda_Dagua_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Queda_Dagua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Recife_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Recife_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Recife_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Recife_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Recife_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Recife_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Recife_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Recife_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Recife_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Recife_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Recife_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Recife_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Reservatorio_Hidrico_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Reservatorio_Hidrico_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Reservatorio_Hidrico_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Reservatorio_Hidrico_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Reservatorio_Hidrico_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Reservatorio_Hidrico_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Reservatorio_Hidrico_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Rocha_Em_Agua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Rocha_Em_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Rocha_Em_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Rocha_Em_Agua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Rocha_Em_Agua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Rocha_Em_Agua_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Rocha_Em_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Rocha_Em_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Rocha_Em_Agua_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Sumidouro_Vertedouro_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Sumidouro_Vertedouro_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Sumidouro_Vertedouro_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Sumidouro_Vertedouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Sumidouro_Vertedouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Sumidouro_Vertedouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Terreno_Sujeito_Inundacao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Terreno_Sujeito_Inundacao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Terreno_Sujeito_Inundacao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Terreno_Sujeito_Inundacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Terreno_Sujeito_Inundacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Terreno_Sujeito_Inundacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Terreno_Sujeito_Inundacao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "HID"."Trecho_Drenagem_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Trecho_Drenagem_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Trecho_Drenagem_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Trecho_Drenagem_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Trecho_Drenagem_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "HID"."Trecho_Massa_Dagua_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "HID"."Trecho_Massa_Dagua_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "HID"."Trecho_Massa_Dagua_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "HID"."Trecho_Massa_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "HID"."Trecho_Massa_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "HID"."Trecho_Massa_Dagua_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "HID"."Trecho_Massa_Dagua_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Area_De_Litigio_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Area_De_Litigio_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Area_De_Litigio_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_De_Litigio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_De_Litigio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_De_Litigio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Area_De_Litigio_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Area_De_Propriedade_Particular_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Area_De_Propriedade_Particular_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Area_De_Propriedade_Particular_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_De_Propriedade_Particular_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_De_Propriedade_Particular_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_De_Propriedade_Particular_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Area_De_Propriedade_Particular_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Desenvolvimento_Controle_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Desenvolvimento_Controle_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Desenvolvimento_Controle_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Desenvolvimento_Controle_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Desenvolvimento_Controle_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Desenvolvimento_Controle_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Area_Uso_Comunitario_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Uso_Comunitario_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Uso_Comunitario_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Uso_Comunitario_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Area_Uso_Comunitario_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Area_Uso_Comunitario_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Uso_Comunitario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Uso_Comunitario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Area_Uso_Comunitario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Bairro_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Bairro_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Bairro_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Bairro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Bairro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Bairro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Bairro_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Delimitacao_Fisica_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Delimitacao_Fisica_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Delimitacao_Fisica_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Delimitacao_Fisica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Delimitacao_Fisica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Delimitacao_Fisica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Delimitacao_Fisica_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Distrito_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Distrito_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Distrito_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Distrito_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Distrito_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Distrito_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Distrito_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Limite_Area_Especial_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Area_Especial_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Area_Especial_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Area_Especial_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Area_Especial_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Area_Especial_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Limite_Area_Especial_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Intra_Municipal_Administrativo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Intra_Municipal_Administrativo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Intra_Municipal_Administrativo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Limite_Operacional_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Operacional_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Operacional_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Operacional_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Operacional_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Operacional_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Limite_Operacional_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Limite_Particular_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Particular_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Particular_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Particular_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Particular_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Particular_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Limite_Particular_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Limite_Politico_Administrativo_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Politico_Administrativo_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Limite_Politico_Administrativo_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Politico_Administrativo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Politico_Administrativo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Limite_Politico_Administrativo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Limite_Politico_Administrativo_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Linha_De_Limite_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Linha_De_Limite_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Linha_De_Limite_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Linha_De_Limite_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Linha_De_Limite_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Linha_De_Limite_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Linha_De_Limite_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Marco_De_Limite_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Marco_De_Limite_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Marco_De_Limite_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Marco_De_Limite_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Marco_De_Limite_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Marco_De_Limite_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Municipio_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Municipio_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Municipio_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Municipio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Municipio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Municipio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Municipio_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Outras_Unid_Protegidas_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outras_Unid_Protegidas_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outras_Unid_Protegidas_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outras_Unid_Protegidas_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Outras_Unid_Protegidas_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Outras_Unid_Protegidas_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outras_Unid_Protegidas_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outras_Unid_Protegidas_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outras_Unid_Protegidas_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Outros_Limites_Oficiais_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Outros_Limites_Oficiais_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Outros_Limites_Oficiais_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outros_Limites_Oficiais_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outros_Limites_Oficiais_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Outros_Limites_Oficiais_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Outros_Limites_Oficiais_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "LIM"."Pais_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Pais_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Pais_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Pais_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Pais_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Pais_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Pais_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Regiao_Administrativa_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Regiao_Administrativa_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Regiao_Administrativa_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Regiao_Administrativa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Regiao_Administrativa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Regiao_Administrativa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Regiao_Administrativa_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Sub_Distrito_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Sub_Distrito_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Sub_Distrito_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Sub_Distrito_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Sub_Distrito_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Sub_Distrito_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Sub_Distrito_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Terra_Indigena_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Indigena_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Indigena_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Indigena_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Terra_Indigena_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Terra_Indigena_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Indigena_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Indigena_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Indigena_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Terra_Publica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Publica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Publica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Publica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Publica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Publica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Terra_Publica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Terra_Publica_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Publica_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Terra_Publica_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Publica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Publica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Terra_Publica_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Conservacao_Nao_Snuc_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Conservacao_Nao_Snuc_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Conservacao_Nao_Snuc_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Federacao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Federacao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Federacao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Federacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Federacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Federacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Federacao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Unidade_Protecao_Integral_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Protecao_Integral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Protecao_Integral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Protecao_Integral_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Protecao_Integral_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Unidade_Protecao_Integral_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Protecao_Integral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Protecao_Integral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Protecao_Integral_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Uso_SustentaveL_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Uso_SustentaveL_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Uso_SustentaveL_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Uso_SustentaveL_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Uso_SustentaveL_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LIM"."Unidade_Uso_SustentaveL_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Area_Edificada_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Area_Edificada_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Area_Edificada_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Edificada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Edificada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Edificada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Area_Edificada_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LOC"."Area_Habitacional_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Area_Habitacional_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Area_Habitacional_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Habitacional_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Habitacional_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Habitacional_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Area_Habitacional_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LOC"."Area_Urbana_Isolada_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Area_Urbana_Isolada_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Area_Urbana_Isolada_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Urbana_Isolada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Urbana_Isolada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Area_Urbana_Isolada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Area_Urbana_Isolada_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LOC"."Complexo_Habitacional"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Complexo_Habitacional"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Complexo_Habitacional"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Complexo_Habitacional"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Complexo_Habitacional"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Complexo_Habitacional"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Edif_Habitacional_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edif_Habitacional_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edif_Habitacional_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edif_Habitacional_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Edif_Habitacional_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LOC"."Edif_Habitacional_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edif_Habitacional_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edif_Habitacional_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edif_Habitacional_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Edificacao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edificacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edificacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edificacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Edificacao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LOC"."Edificacao_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edificacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edificacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Edificacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Hab_Indigena_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Hab_Indigena_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Hab_Indigena_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Hab_Indigena_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Hab_Indigena_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "LOC"."Hab_Indigena_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Hab_Indigena_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Hab_Indigena_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Hab_Indigena_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Localidade_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Localidade_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Localidade_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Localidade_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Localidade_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Localidade_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Nome_Local_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Nome_Local_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Nome_Local_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Nome_Local_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Nome_Local_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Nome_Local_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "LOC"."Posic_Geo_Localidade_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "LOC"."Posic_Geo_Localidade_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "LOC"."Posic_Geo_Localidade_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "LOC"."Posic_Geo_Localidade_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "LOC"."Posic_Geo_Localidade_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "LOC"."Posic_Geo_Localidade_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "PTO"."Area_Est_Med_Fenomenos_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "PTO"."Area_Est_Med_Fenomenos_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "PTO"."Area_Est_Med_Fenomenos_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "PTO"."Area_Est_Med_Fenomenos_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "PTO"."Area_Est_Med_Fenomenos_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "PTO"."Area_Est_Med_Fenomenos_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "PTO"."Area_Est_Med_Fenomenos_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "PTO"."Edif_Constr_Est_Med_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "PTO"."Edif_Constr_Est_Med_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "PTO"."Edif_Constr_Est_Med_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "PTO"."Edif_Constr_Est_Med_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "PTO"."Edif_Constr_Est_Med_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "PTO"."Edif_Constr_Est_Med_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "PTO"."Edif_Constr_Est_Med_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "PTO"."Edif_Constr_Est_Med_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "PTO"."Edif_Constr_Est_Med_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "PTO"."Pto_Controle_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Controle_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Controle_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Controle_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "PTO"."Pto_Est_Med_Fenomenos_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "PTO"."Pto_Est_Med_Fenomenos_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "PTO"."Pto_Est_Med_Fenomenos_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Est_Med_Fenomenos_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Est_Med_Fenomenos_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Est_Med_Fenomenos_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Ref_Geod_Topo_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Ref_Geod_Topo_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "PTO"."Pto_Ref_Geod_Topo_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Alteracao_Fisiografica_Antropica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Alteracao_Fisiografica_Antropica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Alteracao_Fisiografica_Antropica_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Alteracao_Fisiografica_Antropica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Alteracao_Fisiografica_Antropica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Alteracao_Fisiografica_Antropica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "REL"."Curva_Batimetrica_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Curva_Batimetrica_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Curva_Batimetrica_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Curva_Batimetrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Curva_Batimetrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Curva_Batimetrica_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Curva_Batimetrica_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "REL"."Curva_Nivel_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Curva_Nivel_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Curva_Nivel_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Curva_Nivel_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Curva_Nivel_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Curva_Nivel_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Curva_Nivel_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "REL"."Dolina_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Dolina_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Dolina_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Dolina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Dolina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Dolina_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Dolina_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "REL"."Dolina_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Dolina_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Dolina_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Dolina_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Dolina_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Dolina_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Duna_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Duna_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Duna_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Duna_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Duna_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Duna_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Duna_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "REL"."Duna_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Duna_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Duna_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Duna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Duna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Duna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Elemento_Fisiog_Natural_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Elemento_Fisiog_Natural_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "REL"."Elemento_Fisiog_Natural_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Elemento_Fisiog_Natural_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "REL"."Elemento_Fisiog_Natural_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Elemento_Fisiog_Natural_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Gruta_Caverna_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Gruta_Caverna_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Gruta_Caverna_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Gruta_Caverna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Gruta_Caverna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Gruta_Caverna_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Pico_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Pico_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Pico_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Pico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Pico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Pico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Ponto_Cotado_Altimetrico_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Ponto_Cotado_Altimetrico_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Ponto_Cotado_Altimetrico_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Ponto_Cotado_Altimetrico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Ponto_Cotado_Altimetrico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Ponto_Cotado_Altimetrico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Ponto_Cotado_Batimetrico_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Ponto_Cotado_Batimetrico_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Ponto_Cotado_Batimetrico_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Ponto_Cotado_Batimetrico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Ponto_Cotado_Batimetrico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Ponto_Cotado_Batimetrico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Rocha_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Rocha_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Rocha_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Rocha_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Rocha_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Rocha_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Rocha_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "REL"."Rocha_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Rocha_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Rocha_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Rocha_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Rocha_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Rocha_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Terreno_Exposto_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "REL"."Terreno_Exposto_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "REL"."Terreno_Exposto_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "REL"."Terreno_Exposto_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "REL"."Terreno_Exposto_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "REL"."Terreno_Exposto_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "REL"."Terreno_Exposto_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "SAU"."Area_Saude_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "SAU"."Area_Saude_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "SAU"."Area_Saude_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "SAU"."Area_Saude_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "SAU"."Area_Saude_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "SAU"."Area_Saude_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "SAU"."Area_Saude_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "SAU"."Area_Servico_Social_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "SAU"."Area_Servico_Social_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "SAU"."Area_Servico_Social_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "SAU"."Area_Servico_Social_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "SAU"."Area_Servico_Social_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "SAU"."Area_Servico_Social_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "SAU"."Area_Servico_Social_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "SAU"."Edif_Saude_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Saude_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Saude_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Saude_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "SAU"."Edif_Saude_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "SAU"."Edif_Saude_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Saude_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Saude_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Saude_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "SAU"."Edif_Servico_Social_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Servico_Social_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Servico_Social_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Servico_Social_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "SAU"."Edif_Servico_Social_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "SAU"."Edif_Servico_Social_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Servico_Social_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Servico_Social_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "SAU"."Edif_Servico_Social_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Area_Duto_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Area_Duto_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Area_Duto_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Area_Duto_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Area_Duto_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Area_Duto_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Area_Duto_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Area_Estrut_Transportes_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Area_Estrut_Transportes_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Area_Estrut_Transportes_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Area_Estrut_Transportes_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Area_Estrut_Transportes_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Area_Estrut_Transportes_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Area_Estrut_Transportes_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Arruamento_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Arruamento_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Arruamento_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Arruamento_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Arruamento_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Atracadouro_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Atracadouro_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Atracadouro_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Atracadouro_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Atracadouro_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Atracadouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Caminho_Aereo_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Caminho_Aereo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Caminho_Aereo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Caminho_Aereo_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Caminho_Aereo_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Ciclovia_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ciclovia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ciclovia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ciclovia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ciclovia_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Complexo_Aeroportuario"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Complexo_Aeroportuario"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Complexo_Aeroportuario"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Complexo_Aeroportuario"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Complexo_Aeroportuario"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Complexo_Aeroportuario"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Complexo_Portuario"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Complexo_Portuario"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Complexo_Portuario"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Complexo_Portuario"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Complexo_Portuario"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Complexo_Portuario"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Condutor_Hidrico_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Condutor_Hidrico_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Condutor_Hidrico_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Condutor_Hidrico_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Condutor_Hidrico_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Condutor_Hidrico_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Condutor_Hidrico_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Cremalheira_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Cremalheira_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Cremalheira_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Cremalheira_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Cremalheira_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Cremalheira_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Cremalheira_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Cremalheira_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Cremalheira_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Duto_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Duto_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Duto_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Duto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Duto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Duto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Duto_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Eclusa_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Eclusa_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Eclusa_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Eclusa_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Eclusa_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Eclusa_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Aeroportuaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Aeroportuaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Aeroportuaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Aeroportuaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Aeroportuaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Aeroportuaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Constr_Portuaria_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Portuaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Portuaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Portuaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Constr_Portuaria_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Edif_Constr_Portuaria_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Portuaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Portuaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Constr_Portuaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Metro_Ferroviaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Metro_Ferroviaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Metro_Ferroviaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Metro_Ferroviaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Metro_Ferroviaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Metro_Ferroviaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Rodoviaria_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Rodoviaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Rodoviaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Rodoviaria_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Edif_Rodoviaria_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Edif_Rodoviaria_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Rodoviaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Rodoviaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Edif_Rodoviaria_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Entroncamento_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Entroncamento_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Entroncamento_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Entroncamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Entroncamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Entroncamento_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Faixa_Seguranca_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Faixa_Seguranca_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Faixa_Seguranca_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Faixa_Seguranca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Faixa_Seguranca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Faixa_Seguranca_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Faixa_Seguranca_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Fundeadouro_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Fundeadouro_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Fundeadouro_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Fundeadouro_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Fundeadouro_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Fundeadouro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Funicular_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Funicular_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Funicular_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Funicular_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Funicular_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Funicular_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Funicular_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Funicular_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Funicular_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Funicular_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Funicular_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Funicular_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Funicular_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Galeria_Bueiro_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Galeria_Bueiro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Galeria_Bueiro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Galeria_Bueiro_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Galeria_Bueiro_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Galeria_Bueiro_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Galeria_Bueiro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Galeria_Bueiro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Galeria_Bueiro_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Girador_Ferroviario_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Girador_Ferroviario_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Girador_Ferroviario_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Girador_Ferroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Girador_Ferroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Girador_Ferroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Identificador_Trecho_Rodoviario_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Identificador_Trecho_Rodoviario_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Identificador_Trecho_Rodoviario_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Identificador_Trecho_Rodoviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Identificador_Trecho_Rodoviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Identificador_Trecho_Rodoviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Local_Critico_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Local_Critico_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Local_Critico_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Local_Critico_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Local_Critico_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Local_Critico_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Obstaculo_Navegacao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Obstaculo_Navegacao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Obstaculo_Navegacao_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Obstaculo_Navegacao_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Obstaculo_Navegacao_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Obstaculo_Navegacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passag_Elevada_Viaduto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passag_Elevada_Viaduto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passag_Elevada_Viaduto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passag_Elevada_Viaduto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passag_Elevada_Viaduto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passag_Elevada_Viaduto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Passagem_Nivel_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Passagem_Nivel_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Passagem_Nivel_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passagem_Nivel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passagem_Nivel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Passagem_Nivel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Patio_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Patio_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Patio_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Patio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Patio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Patio_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Patio_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Patio_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Patio_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Patio_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Patio_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Patio_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Patio_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Pista_Ponto_Pouso_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Pista_Ponto_Pouso_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Pista_Ponto_Pouso_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Pista_Ponto_Pouso_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Pista_Ponto_Pouso_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Pista_Ponto_Pouso_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ponte_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponte_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponte_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponte_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ponte_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Ponte_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponte_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponte_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponte_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ponto_Duto_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Duto_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Duto_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Duto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Duto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Duto_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ponto_Ferroviario_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Ferroviario_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Ferroviario_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Ferroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Ferroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Ferroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ponto_Hidroviario_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Hidroviario_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Hidroviario_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Hidroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Hidroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Hidroviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Ponto_Rodoviario_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Rodoviario_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Rodoviario_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Rodoviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Rodoviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Ponto_Rodoviario_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Posto_Combustivel_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Posto_Combustivel_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Posto_Combustivel_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Posto_Combustivel_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Posto_Combustivel_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "TRA"."Posto_Combustivel_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Posto_Combustivel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Posto_Combustivel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Posto_Combustivel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Sinalizacao_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Sinalizacao_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Sinalizacao_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Sinalizacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Sinalizacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Sinalizacao_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Travessia_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Travessia_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Travessia_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Travessia_Pedestre_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_Pedestre_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_Pedestre_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_Pedestre_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Travessia_Pedestre_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Travessia_Pedestre_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_Pedestre_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_Pedestre_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Travessia_Pedestre_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Trecho_Duto_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Duto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Duto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Duto_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Trecho_Duto_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Trecho_Ferroviario_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Ferroviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Ferroviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Ferroviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Trecho_Ferroviario_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Trecho_Hidroviario_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Hidroviario_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Hidroviario_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Hidroviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Hidroviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Hidroviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Trecho_Hidroviario_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Trecho_Rodoviario_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Rodoviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Rodoviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trecho_Rodoviario_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Trecho_Rodoviario_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Trilha_Picada_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Trilha_Picada_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Trilha_Picada_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trilha_Picada_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trilha_Picada_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Trilha_Picada_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Trilha_Picada_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Tunel_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Tunel_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Tunel_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Tunel_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Tunel_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Tunel_P"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Tunel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Tunel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Tunel_P"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Via_Ferrea_L"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Via_Ferrea_L"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Via_Ferrea_L"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Via_Ferrea_L"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Via_Ferrea_L"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Via_Ferrea_L"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "TRA"."Via_Ferrea_L"
 ADD COLUMN shape_length REAL;

ALTER TABLE "TRA"."Via_Rodoviaria"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "TRA"."Via_Rodoviaria"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "TRA"."Via_Rodoviaria"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "TRA"."Via_Rodoviaria"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "TRA"."Via_Rodoviaria"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "TRA"."Via_Rodoviaria"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Brejo_Pantano_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Brejo_Pantano_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Brejo_Pantano_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Brejo_Pantano_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Brejo_Pantano_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Caatinga_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Caatinga_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Caatinga_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Caatinga_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Caatinga_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Caatinga_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Caatinga_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Campinarana_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Campinarana_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Campinarana_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Campinarana_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Campinarana_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Campinarana_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Campinarana_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Campo_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Campo_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Campo_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Campo_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Campo_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Campo_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Campo_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Cerrado_Cerradao_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Cerrado_Cerradao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Cerrado_Cerradao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Cerrado_Cerradao_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Cerrado_Cerradao_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Estepe_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Estepe_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Estepe_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Estepe_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Estepe_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Estepe_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Estepe_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Floresta_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Floresta_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Floresta_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Floresta_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Floresta_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Macega_Chavascal_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Macega_Chavascal_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Macega_Chavascal_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Macega_Chavascal_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Macega_Chavascal_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Mangue_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Mangue_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Mangue_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Mangue_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Mangue_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Mangue_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Mangue_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Veg_Area_Contato_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Veg_Area_Contato_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Veg_Area_Contato_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Area_Contato_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Area_Contato_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Area_Contato_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Veg_Area_Contato_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Veg_Cultivada_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Cultivada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Cultivada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Cultivada_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Veg_Cultivada_A"
 ADD COLUMN shape_area REAL;

ALTER TABLE "VEG"."Veg_Restinga_A"
 ADD COLUMN reambular smallint NOT NULL REFERENCES "DOMINIOS"."reambular" DEFAULT 999;
ALTER TABLE "VEG"."Veg_Restinga_A"
 ADD COLUMN "tipoComprovacao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoComprovacao" DEFAULT 999;
ALTER TABLE "VEG"."Veg_Restinga_A"
 ADD COLUMN metadado VARCHAR(255);
CREATE TRIGGER a_explode_geometry
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Restinga_A"
 FOR EACH ROW
            EXECUTE PROCEDURE explode_geometries();

CREATE TRIGGER b_geom_valid
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Restinga_A"
 FOR EACH ROW
            EXECUTE PROCEDURE geom_valid();

CREATE TRIGGER c_shape_geom
            BEFORE INSERT OR UPDATE
            ON "VEG"."Veg_Restinga_A"
 FOR EACH ROW
            EXECUTE PROCEDURE calc_area_length();

ALTER TABLE "VEG"."Veg_Restinga_A"
 ADD COLUMN shape_area REAL;


SET search_path TO pg_catalog,public,"HID","REL","VEG","TRA","ENC","ASB","EDU","ECO","LOC","PTO","LIM","ADM","SAU","DOMINIOS","MOLDURA","AQUISICAO","AUX";

COMMIT;
