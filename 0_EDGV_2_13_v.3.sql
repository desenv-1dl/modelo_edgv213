-- Modelo Físico EDGV 2.13 em Postgres/PostGIS

--SEQUÊNCIA DOS PROCESSOS
-- 1) Criação dos esquemas;
-- 2) Criação das tabela do domínio;
-- 3) Inserção de dados na tabela do domínio;
-- 4) Criação da modelagem edgv;
-- 5) Setagem dos "defaults" e as "contraints" dos atributos que possuem domínio associado


BEGIN;

SET check_function_bodies = false;

CREATE SCHEMA "HID";
CREATE SCHEMA "REL";
CREATE SCHEMA "VEG";
CREATE SCHEMA "TRA";
CREATE SCHEMA "ENC";
CREATE SCHEMA "ASB";
CREATE SCHEMA "EDU";
CREATE SCHEMA "ECO";
CREATE SCHEMA "LOC";
CREATE SCHEMA "PTO";
CREATE SCHEMA "LIM";
CREATE SCHEMA "ADM";
CREATE SCHEMA "SAU";
CREATE SCHEMA "AUX";
CREATE SCHEMA "DOMINIOS";
CREATE SCHEMA "MOLDURA";
CREATE SCHEMA "AQUISICAO";

--tabela de metadados parar informações relevantes
CREATE TABLE metadados(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "versao_edgv" VARCHAR(20),
	"versao_db" VARCHAR(20),
	"escala" VARCHAR(100),
	"notas"  TEXT,
	"atualizado_em" TIMESTAMP
);

INSERT INTO metadados (versao_edgv,versao_db,atualizado_em)
VALUES ('2.1.3','1.0.0','2016-06-24 10:00:47.581168-03');


--Insercao de dados 


CREATE TABLE "MOLDURA"."EPSG_31982"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"mi" character(200),
	"indice" character(200),
	"nome" character(200),
	"asc" character(200),
	"fuso" character(200),
	"observacoesOperador"  TEXT --campo para observacoes do operador para possivel processamento de relatorio
);
SELECT AddGeometryColumn('MOLDURA', 'EPSG_31982','geom', 31982, 'MULTIPOLYGON', 2 );
GRANT ALL ON TABLE "MOLDURA"."EPSG_31982" TO public;
CREATE INDEX idx_MOLDURA_EPSG_31982_geom ON "MOLDURA"."EPSG_31982" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "MOLDURA"."EPSG_31982" ALTER COLUMN geom SET NOT NULL;

--AUXLIARES
CREATE TABLE "AUX"."Aux_Objeto_Desconhecido_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Objeto_Desconhecido_P','geom', 31982, 'MULTIPOINT', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Objeto_Desconhecido_P" TO public;
CREATE INDEX idx_AUX_Aux_Objeto_Desconhecido_P_geom ON "AUX"."Aux_Objeto_Desconhecido_P" USING gist (geom) WITH (FILLFACTOR=90);

CREATE TABLE "AUX"."Aux_Objeto_Desconhecido_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Objeto_Desconhecido_L','geom', 31982, 'MULTILINESTRING', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Objeto_Desconhecido_L" TO public;
CREATE INDEX idx_AUX_Aux_Objeto_Desconhecido_L_geom ON "AUX"."Aux_Objeto_Desconhecido_L" USING gist (geom) WITH (FILLFACTOR=90);

CREATE TABLE "AUX"."Aux_Objeto_Desconhecido_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Objeto_Desconhecido_A','geom', 31982, 'MULTIPOLYGON', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Objeto_Desconhecido_A" TO public;
CREATE INDEX idx_AUX_Aux_Objeto_Desconhecido_A_geom ON "AUX"."Aux_Objeto_Desconhecido_A" USING gist (geom) WITH (FILLFACTOR=90);


CREATE TABLE "AUX"."Aux_Ponto_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Ponto_P','geom', 31982, 'MULTIPOINT', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Ponto_P" TO public;
CREATE INDEX idx_AUX_Aux_Ponto_P_geom ON "AUX"."Aux_Ponto_P" USING gist (geom) WITH (FILLFACTOR=90);

CREATE TABLE "AUX"."Aux_Valida_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Valida_P','geom', 31982, 'MULTIPOINT', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Valida_P" TO public;
CREATE INDEX idx_AUX_Aux_Valida_P_geom ON "AUX"."Aux_Valida_P" USING gist (geom) WITH (FILLFACTOR=90);

CREATE TABLE "AUX"."Aux_Valida_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Valida_L','geom', 31982, 'MULTILINESTRING', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Valida_L" TO public;
CREATE INDEX idx_AUX_Aux_Valida_L_geom ON "AUX"."Aux_Valida_L" USING gist (geom) WITH (FILLFACTOR=90);

CREATE TABLE "AUX"."Aux_Valida_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Valida_A','geom', 31982, 'MULTIPOLYGON', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Valida_A" TO public;
CREATE INDEX idx_AUX_Aux_Valida_A_geom ON "AUX"."Aux_Valida_A" USING gist (geom) WITH (FILLFACTOR=90);


CREATE TABLE "AUX"."Aux_Erro_Rio_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"observacao" TEXT
);
SELECT AddGeometryColumn('AUX', 'Aux_Erro_Rio_P','geom', 31982, 'MULTIPOINT', 2 );
GRANT ALL ON TABLE "AUX"."Aux_Erro_Rio_P" TO public;
CREATE INDEX idx_AUX_Aux_Erro_Rio_P_geom ON "AUX"."Aux_Erro_Rio_P" USING gist (geom) WITH (FILLFACTOR=90);



-- DOMINIOS - INICIO


CREATE TABLE "DOMINIOS"."tipoCidade" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCidade" TO public;


CREATE TABLE "DOMINIOS"."booleano" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."booleano" TO public;

CREATE TABLE "DOMINIOS"."indice" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."indice" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPonte" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPonte" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoAreaUsoComun" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoAreaUsoComun" TO public;
 
 
CREATE TABLE "DOMINIOS"."causa" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."causa" TO public;
 
 
CREATE TABLE "DOMINIOS"."qualidAgua" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."qualidAgua" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoConteudo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoConteudo" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoDelimFis" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoDelimFis" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoDepAbast" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoDepAbast" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoEspacial" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoEspacial" TO public;
 
 
CREATE TABLE "DOMINIOS"."residuo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."residuo" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPocoMina" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPocoMina" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoBrejoPantano" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoBrejoPantano" TO public;
 
 
CREATE TABLE "DOMINIOS"."cultivoPredominante" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."cultivoPredominante" TO public;
 
 
CREATE TABLE "DOMINIOS"."caracteristicaFloresta" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."caracteristicaFloresta" TO public;
 
 
CREATE TABLE "DOMINIOS"."ocorrenciaEm" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."ocorrenciaEm" TO public;
 
 
CREATE TABLE "DOMINIOS"."espessAlgas" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."espessAlgas" TO public;
 
 
CREATE TABLE "DOMINIOS"."posicaoRelEdific" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."posicaoRelEdific" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTrechoComunic" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTrechoComunic" TO public;
 
 
CREATE TABLE "DOMINIOS"."rede" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."rede" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoRocha" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoRocha" TO public;
 
 
CREATE TABLE "DOMINIOS"."relacionado_Ponto_Drenagem" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."relacionado_Ponto_Drenagem" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifPort" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifPort" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoFonteDagua" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoFonteDagua" TO public;
 
 
CREATE TABLE "DOMINIOS"."multimodal" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."multimodal" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoUnidProtInteg" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoUnidProtInteg" TO public;
 
 
CREATE TABLE "DOMINIOS"."causaExposicao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."causaExposicao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoObst" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoObst" TO public;
 
 
CREATE TABLE "DOMINIOS"."coletiva" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."coletiva" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifTurist" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifTurist" TO public;
 
 
CREATE TABLE "DOMINIOS"."modalidade" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."modalidade" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTrechoRod" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTrechoRod" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoOutLimOfic" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoOutLimOfic" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoUnidUsoSust" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoUnidUsoSust" TO public;
 
 
CREATE TABLE "DOMINIOS"."relacionado_Confluencia" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."relacionado_Confluencia" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTrechoDuto" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTrechoDuto" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEquipAgropec" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEquipAgropec" TO public;
 
 
CREATE TABLE "DOMINIOS"."procExtracao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."procExtracao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoAssociado" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoAssociado" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoOutUnidProt" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoOutUnidProt" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifComunic" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifComunic" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoSecaoCnae" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoSecaoCnae" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEntroncamento" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEntroncamento" TO public;
 
 
CREATE TABLE "DOMINIOS"."posicaoRelativa" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."posicaoRelativa" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoBanco" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoBanco" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoGrutaCaverna" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoGrutaCaverna" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoAtracad" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoAtracad" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTrechoFerrov" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTrechoFerrov" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoJuridica" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoJuridica" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLimMassa" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLimMassa" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTunel" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTunel" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoElemNat" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoElemNat" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTravessia" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTravessia" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdif" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdif" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoCombustivel" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCombustivel" TO public;
 
 
CREATE TABLE "DOMINIOS"."chamine" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."chamine" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoAgua" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoAgua" TO public;
 
 
CREATE TABLE "DOMINIOS"."finalidade_Dep_Abast_Agua" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."finalidade_Dep_Abast_Agua" TO public;
 
 
CREATE TABLE "DOMINIOS"."revestimento" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."revestimento" TO public;
 
 
CREATE TABLE "DOMINIOS"."funcaoEdifMetroFerrov" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."funcaoEdifMetroFerrov" TO public;
 
 
CREATE TABLE "DOMINIOS"."atividade" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."atividade" TO public;
 
 
CREATE TABLE "DOMINIOS"."navegabilidade" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."navegabilidade" TO public;
 
 
CREATE TABLE "DOMINIOS"."situaMare" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situaMare" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoResiduo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoResiduo" TO public;
 
 
CREATE TABLE "DOMINIOS"."proximidade" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."proximidade" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPtoRefGeodTopo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPtoRefGeodTopo" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoCampo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCampo" TO public;
 
 
CREATE TABLE "DOMINIOS"."denso" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."denso" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLimPol" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLimPol" TO public;
 
 
CREATE TABLE "DOMINIOS"."eletrificada" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."eletrificada" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoMassaDagua" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoMassaDagua" TO public;
 
 
CREATE TABLE "DOMINIOS"."nrLinhas" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."nrLinhas" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifAgropec" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifAgropec" TO public;
 
 
CREATE TABLE "DOMINIOS"."homologacao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."homologacao" TO public;
 
 
CREATE TABLE "DOMINIOS"."relacionado_Ponto_Rodoviario_Ferrov" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."relacionado_Ponto_Rodoviario_Ferrov" TO public;
 
 
CREATE TABLE "DOMINIOS"."relacionado_Ponto_Duto" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."relacionado_Ponto_Duto" TO public;
 
 
CREATE TABLE "DOMINIOS"."destinadoA" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."destinadoA" TO public;
 
 
CREATE TABLE "DOMINIOS"."relacionado_Ponto_Hidroviario" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."relacionado_Ponto_Hidroviario" TO public;
 
 
CREATE TABLE "DOMINIOS"."construcao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."construcao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoAreaUmida" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoAreaUmida" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoEmAgua" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoEmAgua" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLimOper" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLimOper" TO public;
 
 
CREATE TABLE "DOMINIOS"."regime" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."regime" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoCerr" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCerr" TO public;
 
 
CREATE TABLE "DOMINIOS"."sistemaGeodesico" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."sistemaGeodesico" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoExposicao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoExposicao" TO public;
 
 
CREATE TABLE "DOMINIOS"."destEnergElet" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."destEnergElet" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoFisica" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoFisica" TO public;
 
 
CREATE TABLE "DOMINIOS"."isolada" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."isolada" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoMaqTermica" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoMaqTermica" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTerrExp" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTerrExp" TO public;
 
 
CREATE TABLE "DOMINIOS"."administracao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."administracao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifLazer" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifLazer" TO public;
 
 
CREATE TABLE "DOMINIOS"."finalidade_Edif_Comerc_Serv" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."finalidade_Edif_Comerc_Serv" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPtoEstMed" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPtoEstMed" TO public;
 
 
CREATE TABLE "DOMINIOS"."jurisdicao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."jurisdicao" TO public;
 
 
CREATE TABLE "DOMINIOS"."geometriaAproximada" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."geometriaAproximada" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPassagViad" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPassagViad" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLocalCrit" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLocalCrit" TO public;
 
 
CREATE TABLE "DOMINIOS"."geracao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."geracao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPtoEnergia" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPtoEnergia" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEstGerad" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEstGerad" TO public;
 
 
CREATE TABLE "DOMINIOS"."materializado" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."materializado" TO public;
 
 
CREATE TABLE "DOMINIOS"."ovgd" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."ovgd" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoSumVert" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoSumVert" TO public;
 
 
CREATE TABLE "DOMINIOS"."nascente" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."nascente" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLimAreaEsp" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLimAreaEsp" TO public;
 
 
CREATE TABLE "DOMINIOS"."especie" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."especie" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoCemiterio" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCemiterio" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoQuebramarMolhe" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoQuebramarMolhe" TO public;
 
 
CREATE TABLE "DOMINIOS"."coincideComDentroDe" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."coincideComDentroDe" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPista" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPista" TO public;
 
 
CREATE TABLE "DOMINIOS"."matTransp" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."matTransp" TO public;
 
 
CREATE TABLE "DOMINIOS"."modalUso" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."modalUso" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifSaneam" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifSaneam" TO public;
 
 
CREATE TABLE "DOMINIOS"."antropizada" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."antropizada" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLavoura" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLavoura" TO public;
 
 
CREATE TABLE "DOMINIOS"."ensino" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."ensino" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoDepSaneam" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoDepSaneam" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoCosta" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoCosta" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoSinal" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoSinal" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoDepGeral" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoDepGeral" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoMacChav" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoMacChav" TO public;
 
 
CREATE TABLE "DOMINIOS"."destinacaoFundeadouro" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."destinacaoFundeadouro" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifRelig" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifRelig" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifEnergia" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifEnergia" TO public;
 
 
CREATE TABLE "DOMINIOS"."referencialAltim" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."referencialAltim" TO public;
 
 
CREATE TABLE "DOMINIOS"."nivelAtencao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."nivelAtencao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoDivisaoCnae" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoDivisaoCnae" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoCampoQuadra" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCampoQuadra" TO public;
 
 
CREATE TABLE "DOMINIOS"."usoPrincipal" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."usoPrincipal" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoAlterAntrop" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoAlterAntrop" TO public;
 
 
CREATE TABLE "DOMINIOS"."referencialGrav" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."referencialGrav" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoUsoEdif" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoUsoEdif" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPlataforma" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPlataforma" TO public;
 
 
CREATE TABLE "DOMINIOS"."usoPista" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."usoPista" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoExtMin" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoExtMin" TO public;
 
 
CREATE TABLE "DOMINIOS"."formaExtracao" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."formaExtracao" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTravessiaPed" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTravessiaPed" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoClasseCnae" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoClasseCnae" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoCaminhoAereo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoCaminhoAereo" TO public;
 
 
CREATE TABLE "DOMINIOS"."terreno" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."terreno" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifComercServ" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifComercServ" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoPtoControle" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoPtoControle" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoUsoCaminhoAer" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoUsoCaminhoAer" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoProdutoResiduo" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoProdutoResiduo" TO public;
 
 
CREATE TABLE "DOMINIOS"."especiePredominante" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."especiePredominante" TO public;
 
 
CREATE TABLE "DOMINIOS"."materialPredominante" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."materialPredominante" TO public;
 
 
CREATE TABLE "DOMINIOS"."combRenovavel" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."combRenovavel" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoRecife" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoRecife" TO public;
 
 
CREATE TABLE "DOMINIOS"."unidadeVolume" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."unidadeVolume" TO public;
 
 
CREATE TABLE "DOMINIOS"."finalidade_Veg_Cultivada" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."finalidade_Veg_Cultivada" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifAbast" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifAbast" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoMarcoLim" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoMarcoLim" TO public;
 
 
CREATE TABLE "DOMINIOS"."setor" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."setor" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoRef" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoRef" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoQueda" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoQueda" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifAero" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifAero" TO public;
 
 
CREATE TABLE "DOMINIOS"."salinidade" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."salinidade" TO public;
 
 
CREATE TABLE "DOMINIOS"."bitola" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."bitola" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoIlha" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoIlha" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoTorre" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoTorre" TO public;
 
 
CREATE TABLE "DOMINIOS"."posicaoPista" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."posicaoPista" TO public;
 
 
CREATE TABLE "DOMINIOS"."situacaoMarco" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."situacaoMarco" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoEdifRod" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoEdifRod" TO public;
 
 
CREATE TABLE "DOMINIOS"."tratamento" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tratamento" TO public;
 
 
CREATE TABLE "DOMINIOS"."denominacaoAssociada" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."denominacaoAssociada" TO public;
 
 
CREATE TABLE "DOMINIOS"."matConstr" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."matConstr" TO public;
 
 
CREATE TABLE "DOMINIOS"."operacional" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."operacional" TO public;
 
 
CREATE TABLE "DOMINIOS"."classificacaoPorte" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."classificacaoPorte" TO public;
 
 
CREATE TABLE "DOMINIOS"."trafego" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."trafego" TO public;
 
 
CREATE TABLE "DOMINIOS"."tipoLimIntraMun" (
   code smallint PRIMARY KEY NOT NULL, 
   valor character varying(175) NOT NULL);
GRANT ALL ON TABLE "DOMINIOS"."tipoLimIntraMun" TO public;

--CREATE TABLE "DOMINIOS"."tipoTrechoMassa" (
--   code smallint PRIMARY KEY NOT NULL, 
--   valor character varying(175) NOT NULL);
--GRANT ALL ON TABLE "DOMINIOS"."tipoLimIntraMun" TO public;


;

INSERT INTO "DOMINIOS"."tipoCidade" (code, valor) VALUES 
(1,'Cidade'),
(2,'Capital Federal'),
(3,'Capital Estadual'),
(4,'Vila'),
(5,'Aglomerado Rural Isolado - Povoado'),
(6,'Aglomerado Rural Isolado - Núcleo'),
(7,'Outros Aglomerados Rurais Isolados'),
(8,'Aglomerado Rural de Extensão Urbana'),
(999,'A ser preenchido')
;
 
INSERT INTO "DOMINIOS"."booleano" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTorre" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Autoportante'),
(2,'Estaiada'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoOutUnidProt" (code, valor) VALUES 
(1,'Área de preservação permanente'),
(2,'Reserva legal'),
(3,'Mosaico'),
(4,'Distrito florestal'),
(5,'Corredor ecológico'),
(6,'Floresta pública'),
(7,'Sítios RAMSAR'),
(8,'Sítios do patrimônio'),
(9,'Reserva da Biosfera'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoJuridica" (code, valor) VALUES 
(1,'Delimitada'),
(2,'Declarada'),
(3,'Homologada ou demarcada'),
(4,'Regularizada'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoSumVert" (code, valor) VALUES 
(1,'Sumidouro'),
(2,'Vertedouro'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoFisica" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Abandonada'),
(2,'Destruída'),
(3,'Em construção'),
(4,'Planejada'),
(5,'Construída'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPtoEnergia" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Estação geradora de energia'),
(2,'Subestação de transmissão'),
(3,'Subestação de distribuição'),
(4,'Ponto de ramificação'),
(7,'Mudança de atributo'),
(9,'Início ou fim de trecho'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."especiePredominante" (code, valor) VALUES 
(10,'Cipó'),
(11,'Bambu'),
(12,'Sororoca'),
(17,'Palmeira'),
(27,'Araucária'),
(41,'Babaçu'),
(96,'Não identificado'),
(98,'Mista'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."nascente" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoRecife" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Arenito'),
(2,'Rochoso'),
(20,'Coral'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoMaqTermica" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Turbina à gás (TBGS)'),
(2,'Turbina à vapor (TBVP)'),
(3,'Ciclo Combinado (CLCB)'),
(4,'Motor de Combustão Interna (NCIA)'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEquipAgropec" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Pivô central'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoProdutoResiduo" (code, valor) VALUES 
(0,'Desconhecido'),
(3,'Petróleo'),
(5,'Gás'),
(6,'Grãos'),
(16,'Vinhoto'),
(17,'Estrume'),
(18,'Cascalho'),
(19,'Semente'),
(20,'Inseticida'),
(21,'Folhagens'),
(22,'Pedra'),
(23,'Granito'),
(24,'Mármore'),
(25,'Bauxita'),
(26,'Manganês'),
(27,'Talco'),
(28,'Óleo diesel'),
(29,'Gasolina'),
(30,'Álcool'),
(31,'Querosene'),
(32,'Cobre'),
(33,'Carvão Mineral'),
(34,'Sal'),
(35,'Ferro'),
(36,'Escória'),
(37,'Ouro'),
(38,'Diamante'),
(39,'Prata'),
(40,'Pedras preciosas'),
(41,'Forragem'),
(42,'Areia'),
(43,'Saibro / Piçarra'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."antropizada" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPocoMina" (code, valor) VALUES 
(0,'Desconhecido'),
(2,'Horizontal'),
(3,'Vertical'),
(97,'Não aplicável'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPtoControle" (code, valor) VALUES 
(9,'Ponto de Controle'),
(12,'Centro Perspectivo'),
(13,'Ponto Fotogramétrico'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTrechoDuto" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Duto'),
(2,'Calha'),
(3,'Correia transportadora'),
(4,'Tubulação'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."atividade" (code, valor) VALUES 
(0,'Desconhecido'),
(9,'Prospecção'),
(10,'Produção'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifPort" (code, valor) VALUES 
(0,'Desconhecido'),
(15,'Administrativa'),
(26,'Terminal de passageiros'),
(27,'Terminal de cargas'),
(32,'Armazém'),
(33,'Estaleiro'),
(34,'Dique de estaleiro'),
(35,'Rampa'),
(36,'Carreira'),
(37,'Terminal privativo'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."denso" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoUnidProtInteg" (code, valor) VALUES 
(1,'Estação ecológica - ESEC'),
(2,'Parque - PAR'),
(3,'Monumento natural - MONA'),
(4,'Reserva biológica - REBIO'),
(5,'Refúgio de vida silvestre - RVS'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifAgropec" (code, valor) VALUES 
(0,'Desconhecido'),
(12,'Sede operacional de fazenda'),
(13,'Aviário'),
(14,'Apiário'),
(15,'Viveiro de plantas'),
(16,'Viveiro para acquicultura'),
(17,'Pocilga'),
(18,'Curral'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."espessAlgas" (code, valor) VALUES 
(1,'Finas'),
(2,'Médias'),
(3,'Grossas'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLimMassa" (code, valor) VALUES 
(1,'Costa visível da carta'),
(2,'Margem de massa d`água'),
(3,'Margem esquerda de trechos de massa d`água'),
(4,'Margem direita de trechos de massa d`água'),
(5,'Limite interno entre massas e/ou trechos'),
(6,'Limite com elemento artificial'),
(7,'Limite interno com foz marítima'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."construcao" (code, valor) VALUES 
(1,'Fechada'),
(2,'Aberta'),
(97,'Não aplicável'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifSaneam" (code, valor) VALUES 
(0,'Desconhecido'),
(3,'Recalque'),
(5,'Tratamento de esgoto'),
(6,'Usina de reciclagem'),
(7,'Incinerador'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoCampoQuadra" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Futebol'),
(2,'Basquete'),
(3,'Vôlei'),
(4,'Pólo'),
(5,'Hipismo'),
(6,'Poliesportiva'),
(7,'Tênis'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoAssociado" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Vila'),
(2,'Cidade'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."modalUso" (code, valor) VALUES 
(4,'Rodoviário'),
(5,'Ferroviário'),
(6,'Metroviário'),
(7,'Dutos'),
(8,'Rodoferroviário'),
(9,'Aeroportuário'),
(14,'Portuário'),
(98,'Misto'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoAreaUsoComun" (code, valor) VALUES 
(1,'Quilombo'),
(2,'Assentamento rural'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."relacionado_Confluencia" (code, valor) VALUES 
(15,'Confluencia'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoBrejoPantano" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Brejo'),
(2,'Pântano'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoCaminhoAereo" (code, valor) VALUES 
(12,'Teleférico'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoMarcoLim" (code, valor) VALUES 
(1,'Internacional'),
(2,'Estadual'),
(3,'Municipal'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoConteudo" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Insumo'),
(2,'Produto'),
(3,'Resíduo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifAero" (code, valor) VALUES 
(0,'Desconhecido'),
(15,'Administrativa'),
(26,'Terminal de passageiros'),
(27,'Terminal de cargas'),
(28,'Torre de controle'),
(29,'Hangar'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."indice" (code, valor) VALUES 
(1,'Mestra'),
(2,'Normal'),
(3,'Auxiliar'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoIlha" (code, valor) VALUES 
(1,'Fluvial'),
(2,'Marítima'),
(3,'Lacustre'),
(98,'Mista'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tratamento" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(97,'Não aplicável'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."regime" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Permanente'),
(2,'Permanente com grande variação'),
(3,'Temporário'),
(4,'Temporário com leito permanente'),
(5,'Seco'),
(6,'Sazonal'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."relacionado_Ponto_Duto" (code, valor) VALUES 
(1,'Ponto inicial'),
(2,'Ponto final'),
(3,'Local crítico'),
(4,'Depósito geral'),
(5,'Ponto de ramificação'),
(17,'Interrupção com a moldura'),
(19,'Ramificação'),
(20,'Cruzamento de Vala'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."terreno" (code, valor) VALUES 
(1,'Seco'),
(2,'Irrigado'),
(3,'Inundado'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."causaExposicao" (code, valor) VALUES 
(4,'Natural'),
(5,'Artificial'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."unidadeVolume" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'L'),
(2,'M3'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEntroncamento" (code, valor) VALUES 
(1,'Entroncamento rodoviário'),
(2,'Círculo rodoviario'),
(3,'Trevo rodoviário'),
(4,'Rótula'),
(5,'Entroncamento ferroviário'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdif" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Policial'),
(2,'Prisional'),
(3,'Cartorial'),
(4,'Gestão'),
(5,'Eleitoral'),
(6,'Produção e/ou pesquisa'),
(7,'Seguridade social'),
(8,'Câmara municipal'),
(9,'Assembléia legislativa'),
(10,'Tributação'),
(11,'Fiscalização'),
(12,'Aquartelamento'),
(13,'Campo de instrução'),
(14,'Campo de tiro'),
(15,'Base aérea'),
(16,'Distrito naval'),
(17,'Hotel de trânsito'),
(18,'Delegacia serviço militar'),
(19,'Posto'),
(20,'Posto PM'),
(21,'Posto PRF'),
(22,'Prefeitura'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."usoPista" (code, valor) VALUES 
(0,'Desconhecido'),
(6,'Particular'),
(11,'Público'),
(12,'Militar'),
(13,'Público/Militar'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoOutLimOfic" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Mar territorial'),
(2,'Zona contígua'),
(3,'Zona econômica exclusiva'),
(4,'Lateral marítima'),
(5,'Faixa de fronteira'),
(6,'Plataforma continental jurídica'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."materializado" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."chamine" (code, valor) VALUES 
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."administracao" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Federal'),
(2,'Estadual'),
(3,'Municipal'),
(4,'Estadual/Municipal'),
(5,'Distrital'),
(6,'Particular'),
(7,'Concessionada'),
(15,'Privada'),
(97,'Não aplicável'),
(98,'Mista'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoUnidUsoSust" (code, valor) VALUES 
(1,'Área de proteção ambiental - APA'),
(2,'Área de relevante interesse ecológico - ARIE'),
(3,'Floresta - FLO'),
(4,'Reserva de desenvolvimento sustentável - RDS'),
(5,'Reserva extrativista - RESEX'),
(6,'Reserva de fauna - REFAU'),
(7,'Reserva particular do patrimônio natural - RPPN'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoRef" (code, valor) VALUES 
(1,'Altimétrico'),
(2,'Planimétrico'),
(3,'Planialtimétrico'),
(4,'Gravimétrico'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTerrExp" (code, valor) VALUES 
(0,'Desconhecido'),
(4,'Pedregoso'),
(12,'Areia'),
(18,'Cascalho'),
(23,'Terra'),
(24,'Saibro'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoAtracad" (code, valor) VALUES 
(0,'Desconhecido'),
(38,'Cais'),
(39,'Cais flutuante'),
(40,'Trapiche'),
(41,'Molhe de atracação'),
(42,'Píer'),
(43,'Dolfim'),
(44,'Desembarcadouro'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPassagViad" (code, valor) VALUES 
(5,'Passagem elevada'),
(6,'Viaduto'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."ocorrenciaEm" (code, valor) VALUES 
(5,'Brejo ou pântano'),
(6,'Caatinga'),
(7,'Estepe'),
(8,'Pastagem'),
(13,'Cerrado ou cerradão'),
(14,'Macega ou chavascal'),
(19,'Campinarana'),
(15,'Floresta'),
(96,'Não identificado'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."ovgd" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(998, 'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPlataforma" (code, valor) VALUES 
(0,'Desconhecido'),
(3,'Petróleo'),
(5,'Gás'),
(98,'Misto'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoMassaDagua" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Rio'),
(2,'Canal'),
(3,'Oceano'),
(4,'Baía'),
(5,'Enseada'),
(6,'Meandro abandonado'),
(7,'Lago'),
(8,'Lagoa'),
(9,'Laguna'),
(10,'Represa/Açude'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLocalCrit" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Subestação de válvulas e/ou bombas'),
(2,'Risco geotécnico'),
(3,'Interferência com localidades'),
(4,'Interferência com hidrografia'),
(5,'Interferência com áreas especiais'),
(6,'Interferência com vias'),
(7,'Outras interferências'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoAlterAntrop" (code, valor) VALUES 
(0,'Desconhecido'),
(24,'Caixa de empréstimo'),
(25,'Área aterrada'),
(26,'Corte'),
(27,'Aterro'),
(28,'Resíduo de bota-fora'),
(29,'Resíduo sólido em geral'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoSinal" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Bóia luminosa'),
(2,'Bóia cega'),
(3,'Bóia de amarração'),
(4,'Farol ou farolete'),
(5,'Barca farol'),
(6,'Sinalização de margem'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."relacionado_Ponto_Hidroviario" (code, valor) VALUES
(12,'Queda d`água'),
(13,'Corredeira'),
(14,'Eclusa'),
(16,'Foz marítima'),
(17,'Interrupção com a moldura'),
(24,'Atracadouro'),
(19,'Barragem'),
(21,'Confluência'),
(22,'Complexo portuário'),
(23,'Entre trechos hidroviários'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."finalidade_Veg_Cultivada" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Exploração econômica'),
(2,'Subsistência'),
(3,'Conservação ambiental'),
(99,'Outras'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLimOper" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Setor censitário'),
(2,'Linha de base normal'),
(3,'Linha de base reta'),
(4,'Costa visível da carta'),
(5,'Linha preamar média - 1831'),
(6,'Linha média de enchente - ORD'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."caracteristicaFloresta" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Floresta'),
(2,'Mata'),
(3,'Bosque'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoEmAgua" (code, valor) VALUES 
(0,'Desconhecido'),
(4,'Emerso'),
(5,'Submerso'),
(7,'Cobre e Descobre'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTunel" (code, valor) VALUES 
(1,'Túnel'),
(2,'Passagem subterrânea sob via'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."finalidade_Dep_Abast_Agua" (code, valor) VALUES 
(0,'Desconhecido'),
(2,'Tratamento'),
(3,'Recalque'),
(4,'Distribuição'),
(8,'Armazenamento'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLimAreaEsp" (code, valor) VALUES 
(1,'Terra pública'),
(2,'Terra indígena'),
(3,'Quilombo'),
(4,'Assentamento Rural'),
(5,'Amazônia legal'),
(6,'Faixa de fronteira'),
(7,'Polígono das secas'),
(8,'Área de preservação permanente'),
(9,'Reserva legal'),
(10,'Mosaico'),
(11,'Distrito florestal'),
(12,'Corredor ecológico'),
(13,'Floresta pública'),
(14,'Sítios RAMSAR'),
(15,'Sítios do patrimônio'),
(16,'Reserva da Biosfera'),
(17,'Reserva Florestal'),
(18,'Reserva ecológica'),
(19,'Estação biológica'),
(20,'Horto florestal'),
(21,'Estrada parque'),
(22,'Floresta de rendimento sustentável'),
(23,'Floresta extrativista'),
(24,'Área de proteção ambiental - APA'),
(25,'Área de relevante interesse ecológico - ARIE'),
(26,'Floresta - FLO'),
(27,'Reserva de desenvolvimento sustentável - RDS'),
(28,'Reserva extrativista - RESEX'),
(29,'Reserva de fauna - REFAU'),
(30,'Reserva particular do patrimônio natural - RPPN'),
(31,'Estação ecológica - ESEC'),
(32,'Parque - PAR'),
(33,'Monumento natural - MONA'),
(34,'Reserva biológica - REBIO'),
(35,'Refúgio de vida silvestre - RVS'),
(36,'Área Militar'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."procExtracao" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Mecanizado'),
(2,'Manual'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTrechoComunic" (code, valor) VALUES 
(0,'Desconhecido'),
(4,'Dados'),
(6,'Telegráfica'),
(7,'Telefônica'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoCerr" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Cerrado'),
(2,'Cerradão'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifAbast" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Captação'),
(2,'Tratamento'),
(3,'Recalque'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."posicaoPista" (code, valor) VALUES 
(0,'Desconhecida'),
(12,'Adjacentes'),
(13,'Superpostas'),
--(16,'Coincidente'), retirado, porem existe no gothic
(97,'Não aplicável'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLimIntraMun" (code, valor) VALUES 
(1,'Distrital'),
(2,'Sub-distrital'),
(3,'Perímetro urbano legal'),
(4,'Região administrativa'),
(5,'Bairro'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."matConstr" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Alvenaria'),
(2,'Concreto'),
(3,'Metal'),
(4,'Rocha'),
(5,'Madeira'),
(6,'Arame'),
(7,'Tela ou Alambrado'),
(8,'Cerca viva'),
(23,'Terra'),
(25,'Fibra Ótica'),
(26,'Fio Metálico'),
(97,'Não aplicável'),
(99,'Outros'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoFonteDagua" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Poço'),
(2,'Poço artesiano'),
(3,'Olho d`água'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."operacional" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."referencialAltim" (code, valor) VALUES 
(1,'Torres'),
(2,'Imbituba'),
(3,'Santana'),
(4,'Local'),
(5,'Outra referência para Marco de Limite'),
(6,'Outra referência'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifComunic" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Centro de operações'),
(2,'Central comutação e transmissão'),
(3,'Estação radio-base'),
(4,'Estação repetidora'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoGrutaCaverna" (code, valor) VALUES 
(19,'Gruta'),
(20,'Caverna'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."destinadoA" (code, valor) VALUES 
(0,'Desconhecido'),
(5,'Madeira'),
(18,'Açaí'),
(34,'Turfa'),
(35,'Látex'),
(36,'Castanha'),
(37,'Carnaúba'),
(38,'Coco'),
(39,'Jaborandi'),
(40,'Palmito'),
(41,'Babaçu'),
(43,'Pecuária'),
(44,'Pesca'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."coincideComDentroDe" (code, valor) VALUES 
(0,'Contorno massa d`água (Margem)'),
(1,'Rio'),
(2,'Canal'),
(3,'Cumeada'),
(4,'Linha seca'),
(5,'Costa visível da carta'),
(6,'Rodovia'),
(7,'Ferrovia'),
(8,'Trecho curso d`água (Centro)'),
(9,'Laguna'),
(10,'Represa/Açude'),
(11,'Vala'),
(12,'Queda d`água'),
(13,'Corredeira'),
(14,'Eclusa'),
(16,'Foz marítima'),
(19,'Barragem'),
(24,'Linha de drenagem'),
(96,'Não identificado'),
(97,'Não aplicável'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."coletiva" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoDepAbast" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Tanque'),
(2,'Caixa d`água'),
(3,'Cisterna'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."funcaoEdifMetroFerrov" (code, valor) VALUES 
(0,'Desconhecido'),
(15,'Administrativa'),
(16,'Estação ferroviária de passageiros'),
(17,'Estação metroviária'),
(18,'Terminal ferroviário de cargas'),
(19,'Terminal ferroviário de passageiros e cargas'),
(20,'Oficina de manutenção'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."navegabilidade" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Navegável'),
(2,'Não navegável'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."finalidade_Edif_Comerc_Serv" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Comercial'),
(2,'Serviço'),
(98,'Mista'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoDepSaneam" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Tanque'),
(4,'Depósito de lixo'),
(5,'Aterro sanitário'),
(6,'Aterro controlado'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."salinidade" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Doce'),
(2,'Salgada'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifRod" (code, valor) VALUES 
(0,'Desconhecido'),
(8,'Terminal interestadual'),
(9,'Terminal urbano'),
(10,'Parada interestadual'),
(11,'Posto de combustível'),
(12,'Posto de pesagem'),
(13,'Posto de pedágio'),
(14,'Posto de fiscalização'),
(15,'Administrativa'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."residuo" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Líquido'),
(2,'Sólido'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLimPol" (code, valor) VALUES 
(1,'Internacional'),
(2,'Estadual'),
(3,'Municipal'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoDelimFis" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Cerca'),
(2,'Muro'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."sistemaGeodesico" (code, valor) VALUES 
(1,'SAD-69'),
(2,'SIRGAS2000'),
(3,'WGS-84'),
(4,'Córrego Alegre'),
(5,'Astro Chuá'),
(6,'Outra referência'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."cultivoPredominante" (code, valor) VALUES 
(1,'Milho'),
(2,'Banana'),
(3,'Laranja'),
(4,'Trigo'),
(42,'Videira'),
(6,'Algodão herbáceo'),
(7,'Cana-de-açúcar'),
(8,'Fumo'),
(9,'Soja'),
(10,'Batata inglesa'),
(11,'Mandioca'),
(12,'Feijão'),
(13,'Arroz'),
(14,'Café'),
(15,'Cacau'),
(16,'Erva-mate'),
(17,'Palmeira'),
(18,'Açaí'),
(19,'Seringueira'),
(20,'Eucalipto'),
(21,'Acácia'),
(22,'Algaroba'),
(23,'Pinus'),
(24,'Pastagem cultivada'),
(25,'Hortaliças'),
(26,'Bracatinga'),
(27,'Araucária'),
(28,'Carnaúba'),
(29,'Pera'),
(30,'Maçã'),
(31,'Pêssego'),
(32,'Juta'),
(33,'Cebola'),
(96,'Não identificado'),
(98,'Misto'),
(99,'Outras'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situaMare" (code, valor) VALUES 
(0,'Desconhecido'),
(7,'Cobre e Descobre'),
(8,'Sempre fora d`água'),
(9,'Sempre submerso'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEstGerad" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Hidrelétrica'),
(2,'Termelétrica'),
(3,'Nuclear'),
(5,'Eólica'),
(6,'Solar'),
(7,'Maré-motriz'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTrechoRod" (code, valor) VALUES 
(1,'Acesso'),
(2,'Estrada/Rodovia'), --atributo modificado por solicit ten Diniz
(3,'Caminho carroçável'),
(4,'Auto-estrada'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoCosta" (code, valor) VALUES 
(10,'Contíguo'),
(11,'Afastado'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoElemNat" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Serra'),
(2,'Morro'),
(3,'Montanha'),
(4,'Chapada'),
(5,'Maciço'),
(6,'Planalto'),
(7,'Planície'),
(9,'Península'),
(10,'Ponta'),
(11,'Cabo'),
(12,'Praia'),
(16,'Escarpa'),
(17,'Talude'),
(18,'Falésia'),
(98,'Mista'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."nrLinhas" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Simples'),
(2,'Dupla'),
(3,'Múltipla'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."geometriaAproximada" (code, valor) VALUES 
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."especie" (code, valor) VALUES 
(0,'Desconhecido'),
(2,'Transmissão'),
(3,'Distribuição'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."nivelAtencao" (code, valor) VALUES 
(5,'Primário'),
(6,'Secundário'),
(7,'Terciário'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoObst" (code, valor) VALUES 
(4,'Naturais'),
(5,'Artificiais'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."rede" (code, valor) VALUES 
(0,'Desconhecida'),
(2,'Estadual'),
(3,'Municipal'),
(14,'Nacional'),
(15,'Privada'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoDivisaoCnae" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Agricultura, Pecuária e serviços Relacionados'),
(2,'Silvicultura, Exploração Florestal e Serviços Relacionados'),
(5,'Pesca, Aqüicultura e Serviços Relacionados'),
(10,'Extração de Carvão Mineral'),
(11,'Extração de Petróleo e Serviços Relacionados'),
(13,'Extração de Minerais Metálicos'),
(14,'Extração de Minerais Não-Metálicos'),
(15,'Fabricação Alimentícia e Bebidas'),
(16,'Fabricação de Produtos do Fumo'),
(17,'Fabricação de Produtos Têxteis'),
(18,'Confecção de artigos do Vestuário e Acessórios'),
(19,'Preparação de Couros e Fabricação de Artefatos de couro, Artigos de Viagem e Calçados'),
(20,'Fabricação de produtos de Madeira e Celulose'),
(21,'Fabricação de Celulose, papel e Produtos de Papel'),
(22,'Edição Impressão e Reprodução de Gravações'),
(23,'Fabricação de Coque, Refino de Petróleo, Elaboração de Combustíveis Nucleares e Produção de Álcool'),
(24,'Fabricação de Produtos Químicos'),
(25,'Fabricação de Artigos de Borracha e Material Plástico'),
(26,'Fabricação de Produtos de Minerais Não-Metálicos'),
(27,'Metalurgia Básica'),
(28,'Fabricação de Produtos de Metal, exclusive Máquinas e Equipamentos'),
(29,'Fabricação de Máquinas e Equipamentos'),
(30,'Fabricação de Máquinas de Escritório e Equipamentos de Informática'),
(31,'Fabricação de Máquinas, Aparelhos e Materiais Elétricos'),
(32,'Fabricação de Material Eletrônico, de Aparelhos e Equipamentos de Comunicações'),
(33,'Fabricação de Equipamentos de Instrumentação Médico-Hospitalares, Instrumentos de Precisão e Ópticos, Equipamentos para Automação Industrial, Cronômetros e Relógios'),
(34,'Fabricação e Montagem de Veículos Automotores, Reboques e Carrocerias'),
(35,'Fabricação de Outros Equipamentos de Transporte'),
(36,'Fabricação de Móveis e Industrias Diversas'),
(37,'Reciclagem'),
(45,'Construção'),
(50,'Comércio e reparação de veículos automotores e motocicletas, e comércio a varejo de combustíveis'),
(51,'Comércio por atacado e representantes comerciais e agentes do comércio'),
(52,'Comércio varejista e reparação de objetos pessoais e domésticos'),
(55,'Alojamento e Alimentação'),
(74,'Serviços Prestados principalmente às empresas (organizações)'),
(92,'Atividades Recreativas, Culturais e Desportivas'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."classificacaoPorte" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Arbórea'),
(2,'Arbustiva'),
(3,'Herbácea'),
(4,'Rasteira'),
(998,'Nulo'),
(98,'Misto'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPtoEstMed" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Pto_Estação Climatológica Principal - CP'),
(2,'Pto_Estação Climatológica Auxiliar - CA'),
(3,'Pto_Estação Agroclimatológica - AC'),
(4,'Pto_Estação Pluviométrica - PL'),
(5,'Pto_Estação Eólica - EO'),
(6,'Pto_Estação Evaporimétrica - EV'),
(7,'Pto_Estação Solarimétrica - SL'),
(8,'Pto_Estação de Radar Meteorológico - RD'),
(9,'Pto_Estação de Radiossonda - RS'),
(10,'Pto_Estação Fluviométrica - FL'),
(11,'Pto_Estação Maregráfica - MA'),
(12,'Pto_Estação de Marés Terrestres - Crosta'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."bitola" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Métrica'),
(2,'Internacional'),
(3,'Larga'),
(4,'Mista métrica internacional'),
(5,'Mista métrica larga'),
(6,'Mista internacional larga'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTravessiaPed" (code, valor) VALUES 
(0,'Desconhecido'),
(7,'Passagem subterrânea'),
(8,'Passarela'),
(9,'Pinguela'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifComercServ" (code, valor) VALUES 
(0,'Desconhecido'),
(3,'Centro Comercial'),
(4,'Mercado'),
(5,'Centro de convenções'),
(6,'Feira'),
(7,'Hotel/motel/pousada'),
(8,'Restaurante'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."formaExtracao" (code, valor) VALUES 
(0,'Desconhecido'),
(5,'A céu aberto'),
(6,'Subterrânea'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."denominacaoAssociada" (code, valor) VALUES 
(5,'Cristã'),
(6,'Israelita'),
(7,'Muçulmana'),
(99,'Outras'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoQuebramarMolhe" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Quebramar'),
(2,'Molhe'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPtoRefGeodTopo" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Vértice de Triangulação - VT'),
(2,'Referência de Nível - RN'),
(3,'Estação Gravimétrica - EG'),
(4,'Estação de Poligonal - EP'),
(5,'Ponto Astronômico - PA'),
(6,'Ponto Barométrico - B'),
(7,'Ponto Trigonométrico - RV'),
(8,'Ponto de Satélite-SAT'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."destEnergElet" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Auto-Produção de Energia (APE)'),
(2,'Auto-Produção com Comercialização de Excedente (APE-COM)'),
(3,'Comercialização de Energia (COM)'),
(4,'Produção Independente de Energia (PIE)'),
(5,'Serviço Público (SP)'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."qualidAgua" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Potável'),
(2,'Não potável'),
(3,'Mineral'),
(4,'Salobra'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoClasseCnae" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'40.11-8 - Produção de Energia Elétrica'),
(2,'40.12-6 - Transmissão de Energia Elétrica'),
(3,'40.14-2 - Distribuição de Energia Elétrica'),
(4,'41.00-9 - Captação, Tratamento e Distribuição de Água'),
(5,'64.20-3 - Telecomunicações'),
(6,'75.11-6 - Administração Pública em geral'),
(7,'75.12-4 - Regulação das Atividades Sociais e Culturais'),
(8,'75.13-2 - Regulação das Atividades Econômicas'),
(9,'75.14-0 - Atividades de Apoio à Administração Pública'),
(10,'75.21-3 - Relações Exteriores'),
(11,'75.22-1 - Defesa'),
(12,'75.23-0 - Justiça'),
(13,'75.24-8 - Segurança e Ordem Pública'),
(14,'75.25-6 - Defesa Civil'),
(15,'75.30-2 - Seguridade Social'),
(16,'80.13-6 - Educação Infantil - Creche'),
(17,'80.14-4 - Educação Infantil - Pré-Escola'),
(18,'80.15-2 - Ensino Fundamental'),
(19,'80.20-9 - Ensino Médio'),
(20,'80.31-4 - Educação Superior - Graduação'),
(21,'80.32-2 - Educação Superior - Graduação e Pós-Graduação'),
(22,'80.33-0 - Educação Superior - Pós-Graduação e Extensão'),
(23,'80.96-9 - Educação Profissional de Nível Técnico'),
(24,'80.97-7 - Educação Profissional de Nível Tecnológico'),
(25,'80.99-3 - Outras Atividades de Ensino'),
(26,'85.11-1 Atendimento hospitalar (Hospital)'),
(27,'85.12-0 Atendimento a urgência e emergências (Pronto Socorro)'),
(28,'85.13-8 Atenção ambulatorial (Posto e Centro de Saúde)'),
(29,'85.14-6 Serviços de complementação diagnóstica ou terapêutica'),
(30,'85.16-2 Outras atividades relacionadas com a atenção à saúde (Instituto de Pesquisa)'),
(31,'85.20-0 Serviços veterinários'),
(32,'85.31-6 Serviços sociais com alojamento'),
(33,'85.32-4 Serviços Sociais sem alojamento'),
(34,'90.00-0 - Limpeza Urbana e Esgoto e Atividades Relacionadas'),
(35,'91.91-0 - Atividades de Organizações Religiosas'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."ensino" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."destinacaoFundeadouro" (code, valor) VALUES 
(0,'Desconhecido'),
(10,'Fundeadouro recomendado sem limite definido'),
(11,'Fundeadouro com designação alfanumérica'),
(12,'Áreas de fundeio com limite definido'),
(13,'Áreas de fundeio proibido'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."setor" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Energético'),
(2,'Econômico'),
(3,'Abastecimento de água'),
(4,'Saneamento básico'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoQueda" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Cachoeira'),
(2,'Salto'),
(3,'Catarata'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoCemiterio" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Crematório'),
(2,'Parque'),
(3,'Vertical'),
(4,'Comum'),
(5,'Túmulo isolado'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."materialPredominante" (code, valor) VALUES 
(0,'Desconhecido'),
(4,'Rocha'),
(12,'Areia'),
(13,'Areia fina'),
(14,'Lama'),
(15,'Argila'),
(16,'Lodo'),
(18,'Cascalho'),
(19,'Seixo'),
(20,'Coral'),
(21,'Concha'),
(22,'Ervas marinhas'),
(24,'Saibro'),
(50,'Pedra'),
(97,'Não aplicável'),
(98,'Misto'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPista" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Atletismo'),
(2,'Ciclismo'),
(3,'Motociclismo'),
(4,'Automobilismo'),
(5,'Corrida de cavalos'),
(9,'Pista de pouso'),
(10,'Pista de táxi'),
(11,'Heliponto'),
(98,'Misto'),
(99,'Outros'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoCampo" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sujo'),
(2,'Limpo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoExtMin" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Poço'),
(4,'Mina'),
(5,'Garimpo'),
(6,'Salina'),
(7,'Pedreira'),
(8,'Ponto de prospecção'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."modalidade" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Radiocomunicação'),
(2,'Radiodifusão/som e imagem'),
(3,'Telefonia'),
(4,'Dados'),
(5,'Radiodifusão/som'),
(99,'Outras'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."revestimento" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Leito natural'),
(2,'Revestimento primário (solto)'),
(3,'Pavimentado'),
(4,'Calçado'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoUsoCaminhoAer" (code, valor) VALUES 
(0,'Desconhecido'),
(21,'Passageiros'),
(22,'Cargas'),
(98,'Misto'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoEspacial" (code, valor) VALUES 
(12,'Adjacentes'),
(13,'Sobrepostos'),
(99,'Outros'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifTurist" (code, valor) VALUES 
(0,'Desconhecido'),
(9,'Cruzeiro'),
(10,'Estátua'),
(11,'Mirante'),
(12,'Monumento'),
(13,'Panteão'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoLavoura" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Perene'),
(2,'Semi-perene'),
(3,'Anual'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoAreaUmida" (code, valor) VALUES 
(0,'Desconhecido'),
(3,'Lamacento'),
(4,'Arenoso'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."geracao" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Eletricidade - GER 0'),
(2,'CoGeração'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoMarco" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Bom'),
(2,'Destruído'),
(3,'Destruído sem chapa'),
(4,'Destruído com chapa danificada'),
(5,'Não encontrado'),
(6,'Não visitado'),
(7,'Não construído'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."trafego" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Permanente'),
(2,'Periódico'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoCombustivel" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Nuclear'),
(3,'Diesel'),
(5,'Gás'),
(33,'Carvão'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoExposicao" (code, valor) VALUES 
(0,'Desconhecido'),
(3,'Fechado'),
(4,'Coberto'),
(5,'Céu aberto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoSecaoCnae" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'C - Indústrias Extrativas'),
(2,'D - Indústrias de Transformação'),
(3,'F - Construção'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifRelig" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Igreja'),
(2,'Templo'),
(3,'Centro'),
(4,'Mosteiro'),
(5,'Convento'),
(6,'Mesquita'),
(7,'Sinagoga'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoMacChav" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Macega'),
(2,'Chavascal'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifEnergia" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Administração'),
(2,'Oficinas'),
(3,'Segurança'),
(4,'Depósito'),
(5,'Chaminé'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoBanco" (code, valor) VALUES 
(1,'Fluvial'),
(2,'Marítimo'),
(3,'Lacustre'),
(4,'Cordão Arenoso'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoResiduo" (code, valor) VALUES 
(0,'Desconhecido'),
(9,'Esgoto'),
(12,'Lixo domiciliar e comercial'),
(13,'Lixo tóxico'),
(14,'Lixo séptico'),
(15,'Chorume'),
(16,'Vinhoto'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."isolada" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."jurisdicao" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Federal'),
(2,'Estadual'),
(3,'Municipal'),
(6,'Particular'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."posicaoRelativa" (code, valor) VALUES 
(0,'Desconhecido'),
(2,'Na superfície'),
(3,'Elevado'),
(4,'Emerso'),
(5,'Submerso'),
(6,'Subterrâneo'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."causa" (code, valor) VALUES 
(0,'Desconhecida'),
(1,'Canalização'),
(2,'Gruta ou Fenda'),
(3,'Absorção'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTrechoFerrov" (code, valor) VALUES 
(0,'Desconhecido'),
(5,'Bonde'),
(6,'Aeromóvel'),
(7,'Ferrovia (Trem)'),
(8,'Metrovia (Metrô)'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoRocha" (code, valor) VALUES 
(21,'Matacão - pedra'),
(22,'Penedo - isolado'),
(23,'Área rochosa - lajedo'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."proximidade" (code, valor) VALUES 
(0,'Desconhecida'),
(14,'Isolado'),
(15,'Adjacente'),
(16,'Coincidente'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."combRenovavel" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(998,'Nulo'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."situacaoAgua" (code, valor) VALUES 
(0,'Desconhecida'),
(6,'Tratada'),
(7,'Não tratada'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."matTransp" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Água'),
(2,'Óleo'),
(3,'Petróleo'),
(4,'Nafta'),
(5,'Gás'),
(6,'Grãos'),
(7,'Minério'),
(8,'Efluentes'),
(9,'Esgoto'),
(29,'Gasolina'),
(30,'Álcool'),
(31,'Querosene'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."referencialGrav" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Postdam 1930'),
(2,'IGSN71'),
(3,'Absoluto'),
(4,'Local'),
(97,'Não aplicável'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."posicaoRelEdific" (code, valor) VALUES 
(14,'Isolado'),
(17,'Adjacente a edificação'),
(18,'Sobre edificação'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoPonte" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Móvel'),
(2,'Pênsil'),
(3,'Fixa'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."multimodal" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoTravessia" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Vau natural'),
(2,'Vau construída'),
(3,'Bote transportador'),
(4,'Balsa'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."relacionado_Ponto_Rodoviario_Ferrov" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Tunel'),
(2,'Passagem elevada ou viaduto'),
(3,'Ponte'),
(4,'Travessia'),
(5,'Edificação rodoviária'),
(6,'Galeria ou bueiro'),
(7,'Mudança de atributo'),
(8,'Entroncamento'),
(9,'Início ou fim de trecho'),
(10,'Edificação Metro Ferroviária'),
(11,'Localidade'),
(12,'Pátio'),
(13,'Passagem de nível'),
(17,'Interrupção com a moldura'),
(19,'Barragem'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."relacionado_Ponto_Drenagem" (code, valor) VALUES 
(1,'Eclusa'),
(2,'Barragem'),
(3,'Comporta'),
(4,'Queda d`água'),
(5,'Corredeira'),
(6,'Foz marítima'),
(7,'Sumidouro'),
(8,'Meandro abandonado'),
(80,'Meandro Abandonado (Jusante)'),
(9,'Lago'),
(90,'Lago (Jusante)'),
(10,'Lagoa'),
(100,'Lagoa (Jusante)'),
(11,'Laguna'),
(110,'Laguna (Jusante)'),
(12,'Represa/Açude'),
(120,'Represa/Açude (Jusante)'),
(13,'Entre trechos de drenagem'),
(16,'Vertedouro'),
(17,'Interrupção à Jusante'),
(18,'Interrupção à Montante'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."homologacao" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoEdifLazer" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Estádio'),
(2,'Ginásio'),
(3,'Museu'),
(4,'Teatro'),
(5,'Anfiteatro'),
(6,'Cinema'),
(7,'Centro cultural'),
(8,'Plataforma de pesca'),
(9,'Chaminé'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."usoPrincipal" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Irrigação'),
(2,'Abastecimento'),
(3,'Energia'),
(97,'Não aplicável'),
(99,'Outros'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoUsoEdif" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Próprio nacional'),
(2,'Uso especial da União'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."eletrificada" (code, valor) VALUES 
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido')
;
INSERT INTO "DOMINIOS"."tipoDepGeral" (code, valor) VALUES 
(0,'Desconhecido'),
(8,'Galpão'),
(9,'Silo'),
(10,'Composteira'),
(11,'Depósito frigorífico'),
(32,'Armazém'),
(99,'Outros'),
(999,'A ser preenchido')
;

--#########DOMINIOS DOS COMPLEXOS - INICIO

CREATE TABLE "DOMINIOS"."tipoEstrut"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoEstrut" TO public;
INSERT INTO "DOMINIOS"."tipoEstrut" (code, valor) VALUES 
(1,'Desconhecido'),
(2,'Estação'),
(3,'Comércio e serviços'),
(4,'Fiscalização'),
(5,'Porto seco'),
(6,'Terminal rodoviário'),
(7,'Terminal urbano'),
(8,'Terminal multimodal'),
(999,'A ser preenchido')
;

CREATE TABLE "DOMINIOS"."tipoComplAero"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoComplAero" TO public;
INSERT INTO "DOMINIOS"."tipoComplAero" (code, valor) VALUES 
(23,'Aeródromo'),
(24,'Aeroporto'),
(25,'Heliporto'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."classificacao"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."classificacao" TO public;
INSERT INTO "DOMINIOS"."classificacao" (code, valor) VALUES 
(0,'Desconhecido'),
(9,'Internacional'),
(10,'Doméstico'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."tipoTransporte"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoTransporte" TO public;
INSERT INTO "DOMINIOS"."tipoTransporte" (code, valor) VALUES
(0,'Desconhecido'),
(21,'Passageiros'),
(22,'Cargas'),
(98,'Misto'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."tipoComplexoPortuario"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoComplexoPortuario" TO public;
INSERT INTO "DOMINIOS"."tipoComplexoPortuario" (code, valor) VALUES
(0,'Desconhecido'),
(30,'Porto Organizado'),
(31,'Instalação Portuária'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."tipoOperativo"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoOperativo" TO public;
INSERT INTO "DOMINIOS"."tipoOperativo" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Elevadora'),
(2,'Abaixadora'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."tipoGrupoCnae"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoGrupoCnae" TO public;
INSERT INTO "DOMINIOS"."tipoGrupoCnae" (code, valor) VALUES
(0,'Desconhecido'),
(1,'80.1 - Educação Infantil e Ensino Fundamental'),
(3,'80.3 - Ensino Superior'),
(4,'80.9 - Educação Profissional e Outras Atividades de Ensino'),
(5,'75-1 - Administração do Estado e da Política Econômica e Social'),
(6,'75-2 - Serviços Coletivos Prestados pela Administração Pública'),
(7,'75-3 - Seguridade Social'),
(8,'85.1 - Atividades de Atenção à Saúde'),
(9,'85.2 - Serviços Veterinários'),
(10,'85.3 - Serviço Social'),
(19,'80.2 - Ensino Médio'),
(98,'Misto'),
(99,'Outros'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."classificSigiloso"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."classificSigiloso" TO public;
INSERT INTO "DOMINIOS"."classificSigiloso" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Sigiloso'),
(2,'Ostensivo'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."tipoComplexoLazer"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoComplexoLazer" TO public;
INSERT INTO "DOMINIOS"."tipoComplexoLazer" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Complexo recreativo'),
(2,'Clube'),
(3,'Autódromo'),
(4,'Parque de diversões'),
(5,'Parque urbano'),
(6,'Parque aquático'),
(7,'Parque temático'),
(8,'Hipódromo'),
(9,'Hípica'),
(10,'Estande de tiro'),
(11,'Campo de golfe'),
(12,'Parque de eventos culturais'),
(13,'Camping'),
(14,'Complexo desportivo'),
(15,'Zoológico'),
(16,'Jardim botânico'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."frigorifico"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."frigorifico" TO public;
INSERT INTO "DOMINIOS"."frigorifico" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Sim'),
(2,'Não'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."tipoCapital"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoCapital" TO public;
INSERT INTO "DOMINIOS"."tipoCapital" (code, valor) VALUES
(1,'Cidade'),
(2,'Capital Estadual'),
(3,'Capital Federal'),
(999,'A ser preenchido');

CREATE TABLE "DOMINIOS"."tipoAglomRurIsol"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoAglomRurIsol" TO public;
INSERT INTO "DOMINIOS"."tipoAglomRurIsol" (code, valor) VALUES
(1,'De extensão urbana'),
(2,'Povoado'),
(3,'Núcleo'),
(4,'Outros aglomerados isolados'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."tipoEstMed"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."tipoEstMed" TO public;
INSERT INTO "DOMINIOS"."tipoEstMed" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Estação Climatológica Principal - CP'),
(2,'Estação Climatológica Auxiliar - CA'),
(3,'Estação Agroclimatológica - AC'),
(4,'Estação Pluviométrica - PL'),
(5,'Estação Eólica - EO'),
(6,'Estação Evaporimétrica - EV'),
(7,'Estação Solarimétrica - SL'),
(8,'Estação de Radar Meteorológico - RD'),
(9,'Estação de Radiossonda - RS'),
(10,'Estação Fluviométrica - FL'),
(11,'Estação Maregráfica - MA'),
(12,'Estação de Marés Terrestres - Crosta'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."poderPublico"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."poderPublico" TO public;
INSERT INTO "DOMINIOS"."poderPublico" (code, valor) VALUES
(0,'Desconhecido'),
(1,'Executivo'),
(2,'Legislativo'),
(3,'Judiciário'),
(999,'A ser preenchido');


CREATE TABLE "DOMINIOS"."instituicao"(
	code SMALLINT NOT NULL PRIMARY KEY,
	valor VARCHAR(200)
);
GRANT ALL ON TABLE "DOMINIOS"."instituicao" TO public;
INSERT INTO "DOMINIOS"."instituicao" (code, valor) VALUES
(0,'Desconhecida'),
(4,'Marinha'),
(5,'Exército'),
(6,'Aeronáutica'),
(7,'Polícia militar'),
(8,'Corpo de bombeiros'),
(99,'Outros'),
(999,'A ser preenchido');



--#########DOMINIOS DOS COMPLEXOS - FIM


--INSERT INTO "DOMINIOS"."tipoTrechoMassa" (code, valor) VALUES 
--(0,'Desconhecido'),
--(1,'Rio'),
--(2,'Canal'),
--(3,'Oceano'),
--(4,'Baía'),
--(5,'Enseada'),
--(6,'Meandro abandonado'),
--(7,'Lago'),
--(8,'Lagoa'),
--(9,'Laguna'),
--(10,'Represa/Açude'),
--(99,'Outros'),
--(999,'A ser preenchido')
--;

-- "DOMINIOS" - FIM
--COMPLEXOS - INICIO
--HIDROGRAFIA
CREATE TABLE "HID"."Curso_Dagua"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL DEFAULT '999',
	"nomeAbrev" VARCHAR(80)
);
CREATE TABLE "HID"."Trecho_Curso_Dagua"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL DEFAULT '999',
	"nomeAbrev" VARCHAR(80),
	"id_cursoDagua" INTEGER REFERENCES "HID"."Curso_Dagua" (id)
);

--ADMINISTRACAO PUBLIC
--CREATE TABLE "ADM"."Instituicao_Publica"(
--	id SERIAL NOT NULL PRIMARY KEY,
--	nome VARCHAR(200),
--	"nomeAbrev" VARCHAR(80),
--	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,5,6,7,99,999))
--);


CREATE TABLE "ADM"."Instituicao_Publica"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,5,6,7,99,999))
);


CREATE TABLE "ADM"."Org_Pub_Civil"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,6,7,8,9,10,12,13,14,15,99,999)),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,999)),
	"poderPublico" SMALLINT NOT NULL REFERENCES "DOMINIOS"."poderPublico" (code) DEFAULT 999 CHECK("poderPublico" IN(0,1,2,3,999)),
	"id_instituicaoPublica" INTEGER REFERENCES "ADM"."Instituicao_Publica" (id)
);


CREATE TABLE "ADM"."Org_Pub_Militar"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,11,13,99,999)),
	instituicao SMALLINT NOT NULL REFERENCES "DOMINIOS"."instituicao" (code) DEFAULT 999 CHECK("instituicao" IN(0,4,5,6,7,8,99,999)),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,999)),
	"classificSigiloso" SMALLINT NOT NULL REFERENCES "DOMINIOS"."classificSigiloso" (code) DEFAULT 999 CHECK("classificSigiloso" IN(0,1,2,999)),
	"id_instituicaoPublica" INTEGER REFERENCES "ADM"."Instituicao_Publica" (id)
);

--ESTRUTURA ECONOMICA
CREATE TABLE "ECO"."Org_Agropec_Ext_Vegetal_Pesca"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoDivisaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code) DEFAULT 999 CHECK("tipoDivisaoCnae" IN(0,1,2,5,99,999))
);


CREATE TABLE "ECO"."Org_Comerc_Serv"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoDivisaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code) DEFAULT 999 CHECK("tipoDivisaoCnae" IN(0,50,51,52,55,74,99,999)),
	finalidade SMALLINT NOT NULL REFERENCES "DOMINIOS"."finalidade_Edif_Comerc_Serv" (code) DEFAULT 999 CHECK("finalidade" IN(0,1,2,98,999))
);


CREATE TABLE "ECO"."Org_Industrial"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoSecaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoSecaoCnae" (code) DEFAULT 999 CHECK("tipoSecaoCnae" IN(0,2,3,99,999))
);



CREATE TABLE "ECO"."Madeireira"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoSecaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoSecaoCnae" (code) DEFAULT 999 CHECK("tipoSecaoCnae" IN(0,2,99,999)),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id)
);


CREATE TABLE "ECO"."Frigorifico_Matadouro"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoSecaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoSecaoCnae" (code) DEFAULT 999 CHECK("tipoSecaoCnae" IN(0,2,99,999)),
	"frigorifico" SMALLINT NOT NULL REFERENCES "DOMINIOS"."booleano" (code) DEFAULT 999 CHECK("frigorifico" IN(0,1,2,999)),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id)
);


CREATE TABLE "ECO"."Org_Ext_Mineral"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoSecaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoSecaoCnae" (code) DEFAULT 999 CHECK("tipoSecaoCnae" IN(0,1,99,999))
);


--TRANSPORTE
CREATE TABLE "TRA"."Via_Rodoviaria"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeabrev" VARCHAR(80),
	sigla VARCHAR(20) NOT NULL DEFAULT '999'
);

CREATE TABLE "TRA"."Estrut_Apoio"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"modalUso" SMALLINT NOT NULL REFERENCES "DOMINIOS"."modalUso" (code) DEFAULT 999 CHECK("modalUso" IN(4,5,6,98,999)),
	"tipoEstrut" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoEstrut" (code) DEFAULT 999 CHECK("tipoEstrut" IN(1,2,3,4,5,6,7,8,999))
);


CREATE TABLE "TRA"."Complexo_Aeroportuario"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	indicador VARCHAR(20) NOT NULL DEFAULT '999',
	"siglaAero" VARCHAR(10),
	"tipoComplAero" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoComplAero" (code) DEFAULT 999 CHECK("tipoComplAero" IN(23,24,25,999)),
	classificacao SMALLINT NOT NULL REFERENCES "DOMINIOS"."classificacao" (code) DEFAULT 999 CHECK("classificacao" IN(0,9,10,999)),
	"latOficial" VARCHAR(20) NOT NULL DEFAULT '999',
	"longOficial" VARCHAR(20) NOT NULL DEFAULT '999',
	altitude INTEGER NOT NULL DEFAULT 999
);


CREATE TABLE "TRA"."Hidrovia"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN (0,1,2,3,6,7,999)),
	"extensaoTotal" REAL DEFAULT 999
);

CREATE TABLE "TRA"."Complexo_Portuario"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoTransporte" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoTransporte" (code) DEFAULT 999 CHECK("tipoTransporte" IN(0,21,22,98,999)),
	"tipoComplexoPortuario" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoComplexoPortuario" (code) DEFAULT 999 CHECK("tipoTransporte" IN(0,30,31,999))
);

--ENERGIA E COMUNICAÇÕES
CREATE TABLE "ENC"."Complexo_Gerador_Energia_Eletrica"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN (0,1,99,999)),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id)
);

CREATE TABLE "ENC"."Subest_Transm_Distrib_Energia_Eletrica"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	nomeAbrev VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999  CHECK("tipoClasseCnae" IN (0,2,3,99,999)),
	"tipoOperativo" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoOperativo" (code) DEFAULT 999 CHECK("tipoOperativo" IN (0,1,2,999)),
	operacional SMALLINT NOT NULL REFERENCES "DOMINIOS"."operacional" (code) DEFAULT 999 CHECK("operacional" IN (0,1,2,999)),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);

CREATE TABLE "ENC"."Complexo_Comunicacao"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN (0,5,99,999))
);

CREATE TABLE "ASB"."Complexo_Abast_Agua"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"organizacao" VARCHAR(200),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999  CHECK("tipoClasseCnae" IN (0,4,99,999)),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id)
);

CREATE TABLE "ASB"."Complexo_Saneamento"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999  CHECK("tipoClasseCnae" IN (0,34,99,999)),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN (0,1,2,3,6,7,999)),
	organizacao VARCHAR(200),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id)
);

--EDUCACAO E CULTURA
CREATE TABLE "EDU"."Org_Religiosa"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,35,99,999))
);
CREATE TABLE "EDU"."Org_Ensino"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL DEFAULT '999',
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN (0,1,2,3,15,999)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN (0,1,3,4,19,98,99,999))
);

CREATE TABLE "EDU"."Org_Ensino_Militar"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL DEFAULT '999',
	"nomeAbrev" VARCHAR(80),
	"administracao" SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN (0,1,2,999)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN (0,1,19,3,4,98,99,999)),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,11,13,99,999)),
	"instituicao" SMALLINT NOT NULL REFERENCES "DOMINIOS"."instituicao" (code) DEFAULT 999 CHECK("instituicao" IN (0,4,5,6,7,8,99,999)),
	"classificSigiloso" SMALLINT NOT NULL REFERENCES "DOMINIOS"."classificSigiloso" (code) DEFAULT 999 CHECK("classificSigiloso" IN(0,1,2,999)),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id)				

);



CREATE TABLE "EDU"."Org_Ensino_Religioso"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL DEFAULT '999',
	"nomeAbrev" VARCHAR(80),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,1,19,3,4,98,99,999)),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,35,99,999)),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id)
);



CREATE TABLE "EDU"."Org_Ensino_Pub"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL DEFAULT '999',
	nomeAbrev VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,15,999)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,1,19,3,4,98,99,999)),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,7,99,999)),
	"poderPublico" VARCHAR(200) NOT NULL DEFAULT '999',
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id)
);





CREATE TABLE "EDU"."Complexo_Lazer"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoComplexoLazer" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoComplexoLazer" (code) DEFAULT 999 CHECK("tipoComplexoLazer" IN(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,999)),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,15,98,999)),
	"tipoDivisaoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code) DEFAULT 999 CHECK("tipoDivisaoCnae" IN(0,92,99,999)),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id), --agrega
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id), --administrado por
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id), --administrado por
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id) --administrado por
	
);




--LOCALIDADES
CREATE TABLE "LOC"."Cidade"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"geometriaAproximada" SMALLINT NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999
);



CREATE TABLE "LOC"."Capital"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"geometriaAproximada" SMALLINT NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999,
	"tipoCapital" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoCapital" (code) DEFAULT 999 CHECK("tipoCapital" IN(2,3,999))
);


CREATE TABLE "LOC"."Vila"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"geometriaAproximada" SMALLINT NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999
);


CREATE TABLE "LOC"."Aglomerado_Rural_De_Extensao_Urbana"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"geometriaAproximada" SMALLINT NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999
);

CREATE TABLE "LOC"."Aglomerado_Rural_Isolado"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"geometriaAproximada" SMALLINT NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999,
	"tipoAglomRurIsol" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoAglomRurIsol" (code) DEFAULT 999 CHECK("tipoAglomRurIsol" IN(1,2,3,4,999))
);


CREATE TABLE "LOC"."Aldeia_Indigena"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"geometriaAproximada" SMALLINT NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999,
	"codigoFunai" VARCHAR(20),
	"terraIndigena" VARCHAR(200),
	etnia VARCHAR(200)
);


CREATE TABLE "LOC"."Complexo_Habitacional"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80)
);


--PONTOS DE REFERENCIA
CREATE TABLE "PTO"."Est_Med_Fenomenos"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	"tipoEstMed" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoEstMed" (code) DEFAULT 999 CHECK("tipoEstMed" IN(0,1,2,3,4,5,6,7,8,9,10,11,12,999)),
	"codigoEst" VARCHAR(50),
	"orgaoEnteResp" VARCHAR(50)
);




--SAUDE E SERVICO SOCIAL
CREATE TABLE "SAU"."Org_Saude"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,15,999)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,8,9,99,999))
);


CREATE TABLE "SAU"."Org_Saude_Militar"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,999)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,8,9,99,999)),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,11,13,99,999)),
	instituicao SMALLINT NOT NULL REFERENCES "DOMINIOS"."instituicao" (code) DEFAULT 999 CHECK("instituicao" IN(0,4,5,6,7,8,99,999)),
	"classificSigiloso" SMALLINT NOT NULL REFERENCES "DOMINIOS"."classificSigiloso" (code) DEFAULT 999 CHECK("classificSigiloso" IN(0,1,2,999))
);


CREATE TABLE "SAU"."Org_Saude_Pub"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,999)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,8,9,99,999)),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,7,99,999))
);


CREATE TABLE "SAU"."Org_Servico_Social"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,15)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,10,99,999))
);

CREATE TABLE "SAU"."Org_Servico_Social_Pub"(
	id SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(200),
	"nomeAbrev" VARCHAR(80),
	administracao SMALLINT NOT NULL REFERENCES "DOMINIOS"."administracao" (code) DEFAULT 999 CHECK("administracao" IN(0,1,2,3,15)),
	"tipoGrupoCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoGrupoCnae" (code) DEFAULT 999 CHECK("tipoGrupoCnae" IN(0,10,99,999)),
	"tipoClasseCnae" SMALLINT NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code) DEFAULT 999 CHECK("tipoClasseCnae" IN(0,7,99,999))
);

--COMPLEXOS - FIM


-- HID - INICIO
--#################################################################################################################
CREATE TABLE "HID"."Bacia_Hidrografica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50) ,
 	"codigoOtto" smallint NOT NULL DEFAULT 999,
 	"nivelOtto" smallint NOT NULL DEFAULT 999,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_cursoDagua" INTEGER REFERENCES "HID"."Curso_Dagua" (id)
);
SELECT AddGeometryColumn('HID', 'Bacia_Hidrografica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Bacia_Hidrografica_A_geom ON "HID"."Bacia_Hidrografica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Bacia_Hidrografica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Bacia_Hidrografica_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Massa_Dagua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoMassaDagua" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMassaDagua" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
 	"salinidade" smallint NOT NULL REFERENCES "DOMINIOS"."salinidade" (code)
);
SELECT AddGeometryColumn('HID', 'Massa_Dagua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Massa_Dagua_A_geom ON "HID"."Massa_Dagua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Massa_Dagua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Massa_Dagua_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Trecho_Massa_Dagua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTrechoMassa" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMassaDagua" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
 	"salinidade" smallint NOT NULL REFERENCES "DOMINIOS"."salinidade" (code),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('HID', 'Trecho_Massa_Dagua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Trecho_Massa_Dagua_A_geom ON "HID"."Trecho_Massa_Dagua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Trecho_Massa_Dagua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Trecho_Massa_Dagua_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Limite_Massa_Dagua_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"alturaMediaMargem" real,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoLimMassa" smallint REFERENCES "DOMINIOS"."tipoLimMassa" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code)
);
SELECT AddGeometryColumn('HID', 'Limite_Massa_Dagua_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Limite_Massa_Dagua_L_geom ON "HID"."Limite_Massa_Dagua_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Limite_Massa_Dagua_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Limite_Massa_Dagua_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Trecho_Drenagem_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
	"caladoMax" real,
	"larguraMedia" real,
	"velocidadeMedCorrente" real,
	"profundidadeMedia" real,
 	"dentroDePoligono" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
 	"compartilhado" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
 	"eixoPrincipal" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
        "navegabilidade" smallint NOT NULL REFERENCES "DOMINIOS"."navegabilidade" (code),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('HID', 'Trecho_Drenagem_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Trecho_Drenagem_L_geom ON "HID"."Trecho_Drenagem_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Trecho_Drenagem_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Trecho_Drenagem_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Ponto_Drenagem_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"relacionado" smallint NOT NULL REFERENCES "DOMINIOS"."relacionado_Ponto_Drenagem" (code)
);
SELECT AddGeometryColumn('HID', 'Ponto_Drenagem_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Ponto_Drenagem_P_geom ON "HID"."Ponto_Drenagem_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Ponto_Drenagem_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Ponto_Drenagem_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Barragem_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"usoPrincipal" smallint NOT NULL REFERENCES "DOMINIOS"."usoPrincipal" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('HID', 'Barragem_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Barragem_P_geom ON "HID"."Barragem_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Barragem_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Barragem_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Barragem_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"usoPrincipal" smallint NOT NULL REFERENCES "DOMINIOS"."usoPrincipal" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('HID', 'Barragem_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Barragem_L_geom ON "HID"."Barragem_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Barragem_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Barragem_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Barragem_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"usoPrincipal" smallint NOT NULL REFERENCES "DOMINIOS"."usoPrincipal" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('HID', 'Barragem_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Barragem_A_geom ON "HID"."Barragem_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Barragem_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Barragem_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Comporta_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Comporta_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Comporta_P_geom ON "HID"."Comporta_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Comporta_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Comporta_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Comporta_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Comporta_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Comporta_L_geom ON "HID"."Comporta_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Comporta_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Comporta_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Sumidouro_Vertedouro_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoSumVert" smallint NOT NULL REFERENCES "DOMINIOS"."tipoSumVert" (code),
 	"causa" smallint NOT NULL REFERENCES "DOMINIOS"."causa" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Sumidouro_Vertedouro_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Sumidouro_Vertedouro_P_geom ON "HID"."Sumidouro_Vertedouro_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Sumidouro_Vertedouro_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Sumidouro_Vertedouro_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Queda_Dagua_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoQueda" smallint NOT NULL REFERENCES "DOMINIOS"."tipoQueda" (code),
	"altura" real,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Queda_Dagua_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Queda_Dagua_P_geom ON "HID"."Queda_Dagua_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Queda_Dagua_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Queda_Dagua_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Queda_Dagua_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoQueda" smallint NOT NULL REFERENCES "DOMINIOS"."tipoQueda" (code),
	"altura" real,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Queda_Dagua_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Queda_Dagua_L_geom ON "HID"."Queda_Dagua_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Queda_Dagua_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Queda_Dagua_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Queda_Dagua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoQueda" smallint NOT NULL REFERENCES "DOMINIOS"."tipoQueda" (code),
	"altura" real,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Queda_Dagua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Queda_Dagua_A_geom ON "HID"."Queda_Dagua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Queda_Dagua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Queda_Dagua_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Fonte_Dagua_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoFonteDagua" smallint NOT NULL REFERENCES "DOMINIOS"."tipoFonteDagua" (code),
 	"qualidAgua" smallint NOT NULL REFERENCES "DOMINIOS"."qualidAgua" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Fonte_Dagua_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Fonte_Dagua_P_geom ON "HID"."Fonte_Dagua_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Fonte_Dagua_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Fonte_Dagua_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Ponto_Inicio_Drenagem_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"nascente" smallint NOT NULL REFERENCES "DOMINIOS"."nascente" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Ponto_Inicio_Drenagem_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Ponto_Inicio_Drenagem_P_geom ON "HID"."Ponto_Inicio_Drenagem_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Ponto_Inicio_Drenagem_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Ponto_Inicio_Drenagem_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Foz_Maritima_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Foz_Maritima_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Ponto_Foz_Maritima_P_geom ON "HID"."Foz_Maritima_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Foz_Maritima_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Foz_Maritima_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Foz_Maritima_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Foz_Maritima_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Ponto_Foz_Maritima_L_geom ON "HID"."Foz_Maritima_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Foz_Maritima_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Foz_Maritima_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Foz_Maritima_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Foz_Maritima_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Ponto_Foz_Maritima_A_geom ON "HID"."Foz_Maritima_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Foz_Maritima_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Foz_Maritima_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Confluencia_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Confluencia_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Confluencia_P_geom ON "HID"."Confluencia_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Confluencia_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Confluencia_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Corredeira_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Corredeira_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Corredeira_P_geom ON "HID"."Corredeira_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Corredeira_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Corredeira_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Corredeira_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Corredeira_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Corredeira_L_geom ON "HID"."Corredeira_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Corredeira_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Corredeira_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Corredeira_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Corredeira_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Corredeira_A_geom ON "HID"."Corredeira_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Corredeira_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Corredeira_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Natureza_Fundo_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code),
 	"espessAlgas" smallint NOT NULL REFERENCES "DOMINIOS"."espessAlgas" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Natureza_Fundo_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Natureza_Fundo_P_geom ON "HID"."Natureza_Fundo_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Natureza_Fundo_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Natureza_Fundo_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Natureza_Fundo_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code),
 	"espessAlgas" smallint NOT NULL REFERENCES "DOMINIOS"."espessAlgas" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Natureza_Fundo_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Natureza_Fundo_L_geom ON "HID"."Natureza_Fundo_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Natureza_Fundo_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Natureza_Fundo_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Natureza_Fundo_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code),
 	"espessAlgas" smallint NOT NULL REFERENCES "DOMINIOS"."espessAlgas" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Natureza_Fundo_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Natureza_Fundo_A_geom ON "HID"."Natureza_Fundo_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Natureza_Fundo_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Natureza_Fundo_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Ilha_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoIlha" smallint NOT NULL REFERENCES "DOMINIOS"."tipoIlha" (code),
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Ilha_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Ilha_P_geom ON "HID"."Ilha_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Ilha_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Ilha_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Ilha_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoIlha" smallint NOT NULL REFERENCES "DOMINIOS"."tipoIlha" (code),
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Ilha_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Ilha_L_geom ON "HID"."Ilha_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Ilha_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Ilha_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Ilha_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoIlha" smallint NOT NULL REFERENCES "DOMINIOS"."tipoIlha" (code),
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Ilha_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Ilha_A_geom ON "HID"."Ilha_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Ilha_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Ilha_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Rocha_Em_Agua_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
	"alturaLamina" real,
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Rocha_Em_Agua_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Rocha_Em_Agua_P_geom ON "HID"."Rocha_Em_Agua_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Rocha_Em_Agua_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Rocha_Em_Agua_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Rocha_Em_Agua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
	"alturaLamina" real,
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Rocha_Em_Agua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Rocha_Em_Agua_A_geom ON "HID"."Rocha_Em_Agua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Rocha_Em_Agua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Rocha_Em_Agua_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Recife_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRecife" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRecife" (code),
 	"situaMare" smallint NOT NULL REFERENCES "DOMINIOS"."situaMare" (code),
 	"situacaoCosta" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoCosta" (code),
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Recife_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_HID_Recife_P_geom ON "HID"."Recife_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Recife_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Recife_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Recife_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRecife" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRecife" (code),
 	"situaMare" smallint NOT NULL REFERENCES "DOMINIOS"."situaMare" (code),
 	"situacaoCosta" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoCosta" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Recife_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Recife_L_geom ON "HID"."Recife_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Recife_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Recife_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Recife_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRecife" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRecife" (code),
 	"situaMare" smallint NOT NULL REFERENCES "DOMINIOS"."situaMare" (code),
 	"situacaoCosta" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoCosta" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Recife_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Recife_A_geom ON "HID"."Recife_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Recife_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Recife_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Banco_Areia_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoBanco" smallint NOT NULL REFERENCES "DOMINIOS"."tipoBanco" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Banco_Areia_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Banco_Areia_L_geom ON "HID"."Banco_Areia_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Banco_Areia_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Banco_Areia_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Banco_Areia_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoBanco" smallint NOT NULL REFERENCES "DOMINIOS"."tipoBanco" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code),
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('HID', 'Banco_Areia_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Banco_Areia_A_geom ON "HID"."Banco_Areia_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Banco_Areia_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Banco_Areia_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Quebramar_Molhe_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoQuebramarMolhe" smallint NOT NULL REFERENCES "DOMINIOS"."tipoQuebramarMolhe" (code),
 	"situaMare" smallint NOT NULL REFERENCES "DOMINIOS"."situaMare" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Quebramar_Molhe_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_HID_Quebramar_Molhe_L_geom ON "HID"."Quebramar_Molhe_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Quebramar_Molhe_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Quebramar_Molhe_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Quebramar_Molhe_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoQuebramarMolhe" smallint NOT NULL REFERENCES "DOMINIOS"."tipoQuebramarMolhe" (code),
 	"situaMare" smallint NOT NULL REFERENCES "DOMINIOS"."situaMare" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Quebramar_Molhe_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Quebramar_Molhe_A_geom ON "HID"."Quebramar_Molhe_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Quebramar_Molhe_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Quebramar_Molhe_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Terreno_Sujeito_Inundacao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"periodicidadeInunda" varchar(20),
	"nomeAbrev" varchar(50)
	
);
SELECT AddGeometryColumn('HID', 'Terreno_Sujeito_Inundacao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Terreno_Sujeito_Inundacao_A_geom ON "HID"."Terreno_Sujeito_Inundacao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Terreno_Sujeito_Inundacao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Terreno_Sujeito_Inundacao_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Area_Umida_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAreaUmida" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAreaUmida" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('HID', 'Area_Umida_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Area_Umida_A_geom ON "HID"."Area_Umida_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Area_Umida_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Area_Umida_A" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "HID"."Reservatorio_Hidrico_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"usoPrincipal" smallint NOT NULL REFERENCES "DOMINIOS"."usoPrincipal" (code),
	"volumeUtil" integer,
	"naMaximoMaximorum" integer,
	"naMaximoOperacional" integer,
	"nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('HID', 'Reservatorio_Hidrico_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_HID_Reservatorio_Hidrico_A_geom ON "HID"."Reservatorio_Hidrico_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "HID"."Reservatorio_Hidrico_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "HID"."Reservatorio_Hidrico_A" TO public;
--#################################################################################################################
-- HID - FIM

--#################################################################################################################
-- REL - INICIO

CREATE TABLE "REL"."Curva_Nivel_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"cota" integer NOT NULL,
 	"depressao" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"indice" smallint NOT NULL REFERENCES "DOMINIOS"."indice" (code)
);
SELECT AddGeometryColumn('REL', 'Curva_Nivel_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_REL_Curva_Nivel_L_geom ON "REL"."Curva_Nivel_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Curva_Nivel_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Curva_Nivel_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Curva_Batimetrica_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "profundidade" SMALLINT
);
SELECT AddGeometryColumn('REL', 'Curva_Batimetrica_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_REL_Curva_Batimetrica_L_geom ON "REL"."Curva_Batimetrica_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Curva_Batimetrica_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Curva_Batimetrica_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Ponto_Cotado_Altimetrico_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"cotaComprovada" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
	"cota" real NOT NULL,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('REL', 'Ponto_Cotado_Altimetrico_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Ponto_Cotado_Altimetrico_P_geom ON "REL"."Ponto_Cotado_Altimetrico_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Ponto_Cotado_Altimetrico_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Ponto_Cotado_Altimetrico_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Ponto_Cotado_Batimetrico_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"profundidade" real NOT NULL
);
SELECT AddGeometryColumn('REL', 'Ponto_Cotado_Batimetrico_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Ponto_Cotado_Batimetrico_P_geom ON "REL"."Ponto_Cotado_Batimetrico_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Ponto_Cotado_Batimetrico_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Ponto_Cotado_Batimetrico_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Elemento_Fisiog_Natural_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80) NOT NULL,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoElemNat" smallint NOT NULL REFERENCES "DOMINIOS"."tipoElemNat" (code)
);
SELECT AddGeometryColumn('REL', 'Elemento_Fisiog_Natural_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Elemento_Fisiog_Natural_P_geom ON "REL"."Elemento_Fisiog_Natural_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Elemento_Fisiog_Natural_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Elemento_Fisiog_Natural_P" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "REL"."Elemento_Fisiog_Natural_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80) NOT NULL,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoElemNat" smallint NOT NULL REFERENCES "DOMINIOS"."tipoElemNat" (code)
);

SELECT AddGeometryColumn('REL', 'Elemento_Fisiog_Natural_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_REL_Elemento_Fisiog_Natural_L_geom ON "REL"."Elemento_Fisiog_Natural_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Elemento_Fisiog_Natural_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Elemento_Fisiog_Natural_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "REL"."Elemento_Fisiog_Natural_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80) NOT NULL,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoElemNat" smallint NOT NULL REFERENCES "DOMINIOS"."tipoElemNat" (code)
);
SELECT AddGeometryColumn('REL', 'Elemento_Fisiog_Natural_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_REL_Elemento_Fisiog_Natural_A_geom ON "REL"."Elemento_Fisiog_Natural_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Elemento_Fisiog_Natural_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Elemento_Fisiog_Natural_A" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Dolina_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('REL', 'Dolina_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Dolina_P_geom ON "REL"."Dolina_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Dolina_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Dolina_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Dolina_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('REL', 'Dolina_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_REL_Dolina_A_geom ON "REL"."Dolina_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Dolina_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Dolina_A" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Duna_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"fixa" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('REL', 'Duna_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Duna_P_geom ON "REL"."Duna_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Duna_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Duna_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Duna_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"fixa" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('REL', 'Duna_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_REL_Duna_A_geom ON "REL"."Duna_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Duna_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Duna_A" TO public;

--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Gruta_Caverna_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoGrutaCaverna" smallint NOT NULL REFERENCES "DOMINIOS"."tipoGrutaCaverna" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('REL', 'Gruta_Caverna_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Gruta_Caverna_P_geom ON "REL"."Gruta_Caverna_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Gruta_Caverna_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Gruta_Caverna_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Pico_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('REL', 'Pico_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Pico_P_geom ON "REL"."Pico_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Pico_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Pico_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Rocha_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRocha" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRocha" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('REL', 'Rocha_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_REL_Rocha_P_geom ON "REL"."Rocha_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Rocha_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE  "REL"."Rocha_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Rocha_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRocha" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRocha" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('REL', 'Rocha_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_REL_Rocha_A_geom ON "REL"."Rocha_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Rocha_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Rocha_A" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Terreno_Exposto_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTerrExp" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTerrExp" (code),
 	"causaExposicao" smallint NOT NULL REFERENCES "DOMINIOS"."causaExposicao" (code)
);
SELECT AddGeometryColumn('REL', 'Terreno_Exposto_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_REL_Terreno_Exposto_A_geom ON "REL"."Terreno_Exposto_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Terreno_Exposto_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Terreno_Exposto_A" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Alteracao_Fisiografica_Antropica_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAlterAntrop" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAlterAntrop" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('REL', 'Alteracao_Fisiografica_Antropica_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_REL_Alteracao_Fisiografica_Antropica_L_geom ON "REL"."Alteracao_Fisiografica_Antropica_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Alteracao_Fisiografica_Antropica_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "REL"."Alteracao_Fisiografica_Antropica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAlterAntrop" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAlterAntrop" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('REL', 'Alteracao_Fisiografica_Antropica_A','geom', 31982,'MULTIPOLYGON', 2 );
CREATE INDEX idx_REL_Alteracao_Fisiografica_Antropica_A_geom ON "REL"."Alteracao_Fisiografica_Antropica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "REL"."Alteracao_Fisiografica_Antropica_A" TO public;

--#################################################################################################################

-- REL - FIM

-- TRA - INICIO
--#################################################################################################################
CREATE TABLE "TRA"."Trecho_Rodoviario_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" VARCHAR (255),
	"sigla" VARCHAR(50),
	"codTrechoRodov" varchar(25),
	"concessionaria" varchar(100),
 	"nrPistas" smallint ,
 	"nrFaixas" smallint NOT NULL DEFAULT 999,
 	"canteiroDivisorio" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
	"capacCarga" real,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTrechoRod" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTrechoRod" (code),
 	"jurisdicao" smallint NOT NULL REFERENCES "DOMINIOS"."jurisdicao" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento"(code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"trafego" smallint NOT NULL REFERENCES "DOMINIOS"."trafego" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"id_viaRodoviaria" INTEGER REFERENCES "TRA"."Via_Rodoviaria" (id)
);
SELECT AddGeometryColumn('TRA', 'Trecho_Rodoviario_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Trecho_Rodoviario_L_geom ON "TRA"."Trecho_Rodoviario_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Trecho_Rodoviario_L" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "TRA"."Identificador_Trecho_Rodoviario_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"sigla" varchar(6) NOT NULL,
        "nomeAbrev" varchar(50),
	"id_viaRodoviaria" INTEGER REFERENCES "TRA"."Via_Rodoviaria" (id)
);
SELECT AddGeometryColumn('TRA', 'Identificador_Trecho_Rodoviario_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Identificador_Trecho_Rodoviario_P_geom ON "TRA"."Identificador_Trecho_Rodoviario_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Identificador_Trecho_Rodoviario_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Identificador_Trecho_Rodoviario_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Ponto_Rodoviario_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"relacionado" smallint NOT NULL REFERENCES "DOMINIOS"."relacionado_Ponto_Rodoviario_Ferrov" (code)
);
SELECT AddGeometryColumn('TRA', 'Ponto_Rodoviario_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Ponto_Rodoviario_P_geom ON "TRA"."Ponto_Rodoviario_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ponto_Rodoviario_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ponto_Rodoviario_P" TO public;
--#################################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Travessia_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTravessia" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTravessia" (code),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Travessia_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Travessia_P_geom ON "TRA"."Travessia_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Travessia_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Travessia_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "TRA"."Travessia_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTravessia" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTravessia" (code),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Travessia_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Travessia_L_geom ON "TRA"."Travessia_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Travessia_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Travessia_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Tunel_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTunel" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTunel" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "largura" real,
 	"nrPistas" smallint ,
 	"nrFaixas" smallint,
 	"posicaoPista" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoPista" (code),
	"altura" real,
	"extensao" real,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Tunel_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Tunel_P_geom ON "TRA"."Tunel_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Tunel_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Tunel_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Tunel_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTunel" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTunel" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "largura" real,
 	"nrPistas" smallint ,
 	"nrFaixas" smallint,
 	"posicaoPista" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoPista" (code),
	"altura" real,
	"extensao" real,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Tunel_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Tunel_L_geom ON "TRA"."Tunel_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Tunel_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Tunel_L" TO public;
--########################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Galeria_Bueiro_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "pesoSuportMaximo" real,
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Galeria_Bueiro_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Galeria_Bueiro_P_geom ON "TRA"."Galeria_Bueiro_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Galeria_Bueiro_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Galeria_Bueiro_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Galeria_Bueiro_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "pesoSuportMaximo" real,
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Galeria_Bueiro_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Galeria_Bueiro_L_geom ON "TRA"."Galeria_Bueiro_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Galeria_Bueiro_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Galeria_Bueiro_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Entroncamento_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEntroncamento" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEntroncamento" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Entroncamento_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Entroncamento_P_geom ON "TRA"."Entroncamento_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Entroncamento_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Entroncamento_P" TO public;
--#################################################################################################################

--#########################################################################################################################################
CREATE TABLE "TRA"."Ponte_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
	"vaoLivreHoriz" real,
	"vaoVertical" real,
	"cargaSuportMaxima" real,
	"nrPistas" smallint,
	"nrFaixas" smallint DEFAULT 999,
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPonte" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPonte" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"posicaoPista" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoPista" (code),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Ponte_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Ponte_P_geom ON "TRA"."Ponte_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ponte_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ponte_P" TO public;
--#########################################################################################################################################

--#########################################################################################################################################
CREATE TABLE "TRA"."Ponte_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
	"vaoLivreHoriz" real,
	"vaoVertical" real,
	"cargaSuportMaxima" real,
	"nrPistas" smallint,
	"nrFaixas" smallint NOT NULL DEFAULT 999,
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPonte" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPonte" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"posicaoPista" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoPista" (code),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Ponte_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Ponte_L_geom ON "TRA"."Ponte_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ponte_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ponte_L" TO public;
--########################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Passag_Elevada_Viaduto_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"vaoLivreHoriz" real,
	"vaoVertical" real,
	"gabHorizSup" real,
	"gabVertSup" real,
	"cargaSuportMaxima" real,
 	"nrPistas" smallint ,
 	"nrFaixas" smallint,
	"extensao" real,
	"largura" real,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPassagViad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPassagViad" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica"(code),
 	"posicaoPista" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoPista" (code)
);
SELECT AddGeometryColumn('TRA', 'Passag_Elevada_Viaduto_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Passag_Elevada_Viaduto_P_geom ON "TRA"."Passag_Elevada_Viaduto_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Passag_Elevada_Viaduto_P" TO public;
--#########################################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Passag_Elevada_Viaduto_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"vaoLivreHoriz" real,
	"vaoVertical" real,
	"gabHorizSup" real,
	"gabVertSup" real,
	"cargaSuportMaxima" real,
 	"nrPistas" smallint ,
 	"nrFaixas" smallint,
	"extensao" real,
	"largura" real,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPassagViad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPassagViad" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica"(code),
 	"posicaoPista" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoPista" (code)
);
SELECT AddGeometryColumn('TRA', 'Passag_Elevada_Viaduto_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Passag_Elevada_Viaduto_L_geom ON "TRA"."Passag_Elevada_Viaduto_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Passag_Elevada_Viaduto_L" TO public;
--#########################################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Area_Estrut_Transportes_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Area_Estrut_Transportes_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Area_Estrut_Transportes_A_geom ON "TRA"."Area_Estrut_Transportes_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Area_Estrut_Transportes_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Area_Estrut_Transportes_A" TO public;
-- ################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Patio_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao"(code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
 	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
 	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),    
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('TRA', 'Patio_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Patio_P_geom ON "TRA"."Patio_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Patio_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Patio_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Patio_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"modalUso" smallint NOT NULL REFERENCES "DOMINIOS"."modalUso" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao"(code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),  
 	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
 	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('TRA', 'Patio_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Patio_A_geom ON "TRA"."Patio_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Patio_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Patio_A" TO public;
--#################################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Rodoviaria_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifRod" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifRod" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Rodoviaria_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Edif_Rodoviaria_P_geom ON "TRA"."Edif_Rodoviaria_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Rodoviaria_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Rodoviaria_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifRod" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifRod" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Rodoviaria_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Edif_Rodoviaria_A_geom ON "TRA"."Edif_Rodoviaria_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Rodoviaria_A" TO public;
--########################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Trilha_Picada_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('TRA', 'Trilha_Picada_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Trilha_Picada_L_geom ON "TRA"."Trilha_Picada_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Trilha_Picada_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Trilha_Picada_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Ciclovia_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao"(code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento"(code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"trafego" smallint NOT NULL REFERENCES "DOMINIOS"."trafego" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Ciclovia_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Ciclovia_L_geom ON "TRA"."Ciclovia_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ciclovia_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ciclovia_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Arruamento_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento"(code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"nrFaixas" SMALLINT,
 	"trafego" smallint NOT NULL REFERENCES "DOMINIOS"."trafego" (code),
 	"canteiroDivisorio" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Arruamento_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Arruamento_L_geom ON "TRA"."Arruamento_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Arruamento_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Arruamento_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Travessia_Pedestre_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTravessiaPed" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTravessiaPed" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Travessia_Pedestre_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Travessia_Pedestre_P_geom ON "TRA"."Travessia_Pedestre_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Travessia_Pedestre_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Travessia_Pedestre_P" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Travessia_Pedestre_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTravessiaPed" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTravessiaPed" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
	"id_trechoCursoDagua" INTEGER REFERENCES "HID"."Trecho_Curso_Dagua" (id)
);
SELECT AddGeometryColumn('TRA', 'Travessia_Pedestre_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Travessia_Pedestre_L_geom ON "TRA"."Travessia_Pedestre_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Travessia_Pedestre_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Travessia_Pedestre_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Via_Ferrea_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Via_Ferrea_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Via_Ferrea_L_geom ON "TRA"."Via_Ferrea_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Via_Ferrea_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Via_Ferrea_L" TO public;
--#################################################################################################################

--#################################################################################################################
CREATE TABLE "TRA"."Trecho_Ferroviario_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"codTrechoFerrov" varchar(25),
 	"emArruamento" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
	"concessionaria" varchar(100),
	"cargaSuportMaxima" real,
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"posicaoRelativa" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoRelativa" (code),
 	"tipoTrechoFerrov" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTrechoFerrov" (code),
 	"bitola" smallint NOT NULL REFERENCES "DOMINIOS"."bitola" (code),
 	"eletrificada" smallint NOT NULL REFERENCES "DOMINIOS"."eletrificada" (code),
 	"nrLinhas" smallint NOT NULL REFERENCES "DOMINIOS"."nrLinhas" (code),
 	"jurisdicao" smallint NOT NULL REFERENCES "DOMINIOS"."jurisdicao" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional"(code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code)
);
SELECT AddGeometryColumn('TRA', 'Trecho_Ferroviario_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Trecho_Ferroviario_L_geom ON "TRA"."Trecho_Ferroviario_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Trecho_Ferroviario_L" TO public;
--#################################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Ponto_Ferroviario_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"relacionado" smallint NOT NULL REFERENCES "DOMINIOS"."relacionado_Ponto_Rodoviario_Ferrov" (code)
);
SELECT AddGeometryColumn('TRA', 'Ponto_Ferroviario_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Ponto_Ferroviario_P_geom ON "TRA"."Ponto_Ferroviario_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ponto_Ferroviario_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ponto_Ferroviario_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Girador_Ferroviario_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Girador_Ferroviario_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Girador_Ferroviario_P_geom ON "TRA"."Girador_Ferroviario_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Girador_Ferroviario_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Girador_Ferroviario_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Metro_Ferroviaria_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"funcaoEdifMetroFerrov" smallint NOT NULL REFERENCES "DOMINIOS"."funcaoEdifMetroFerrov" (code),
 	"multimodal" smallint NOT NULL REFERENCES "DOMINIOS"."multimodal" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Metro_Ferroviaria_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Edif_Metro_Ferroviaria_P_geom ON "TRA"."Edif_Metro_Ferroviaria_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Metro_Ferroviaria_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Metro_Ferroviaria_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"funcaoEdifMetroFerrov" smallint NOT NULL REFERENCES "DOMINIOS"."funcaoEdifMetroFerrov" (code),
 	"multimodal" smallint NOT NULL REFERENCES "DOMINIOS"."multimodal" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Metro_Ferroviaria_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Edif_Metro_Ferroviaria_A_geom ON "TRA"."Edif_Metro_Ferroviaria_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Metro_Ferroviaria_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Caminho_Aereo_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCaminhoAereo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCaminhoAereo" (code),
 	"tipoUsoCaminhoAer" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUsoCaminhoAer" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('TRA', 'Caminho_Aereo_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Caminho_Aereo_L_geom ON "TRA"."Caminho_Aereo_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Caminho_Aereo_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Caminho_Aereo_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Funicular_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('TRA', 'Funicular_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Funicular_P_geom ON "TRA"."Funicular_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Funicular_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Funicular_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Funicular_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('TRA', 'Funicular_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Funicular_L_geom ON "TRA"."Funicular_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Funicular_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Funicular_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Cremalheira_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Cremalheira_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Cremalheira_P_geom ON "TRA"."Cremalheira_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Cremalheira_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Cremalheira_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Cremalheira_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Cremalheira_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Cremalheira_L_geom ON "TRA"."Cremalheira_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Cremalheira_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Cremalheira_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Duto_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Duto_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Duto_L_geom ON "TRA"."Duto_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Duto_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Duto_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Trecho_Duto_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTrechoDuto" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTrechoDuto" (code),
 	"matTransp" smallint NOT NULL REFERENCES "DOMINIOS"."matTransp" (code),
 	"setor" smallint NOT NULL REFERENCES "DOMINIOS"."setor" (code),
 	"posicaoRelativa" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoRelativa" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"nrDutos" smallint ,
 	"situacaoEspacial" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEspacial" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50)
	
);
SELECT AddGeometryColumn('TRA', 'Trecho_Duto_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Trecho_Duto_L_geom ON "TRA"."Trecho_Duto_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Trecho_Duto_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Trecho_Duto_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Ponto_Duto_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"relacionado" smallint NOT NULL REFERENCES "DOMINIOS"."relacionado_Ponto_Duto" (code)
);
SELECT AddGeometryColumn('TRA', 'Ponto_Duto_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Ponto_Duto_P_geom ON "TRA"."Ponto_Duto_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ponto_Duto_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ponto_Duto_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Area_Duto_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('TRA', 'Area_Duto_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Area_Duto_A_geom ON "TRA"."Area_Duto_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Area_Duto_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Area_Duto_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Local_Critico_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoLocalCrit" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLocalCrit" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Local_Critico_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Local_Critico_P_geom ON "TRA"."Local_Critico_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Local_Critico_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Local_Critico_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Local_Critico_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoLocalCrit" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLocalCrit" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Local_Critico_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Local_Critico_L_geom ON "TRA"."Local_Critico_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Local_Critico_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Local_Critico_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Local_Critico_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoLocalCrit" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLocalCrit" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Local_Critico_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Local_Critico_A_geom ON "TRA"."Local_Critico_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Local_Critico_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Local_Critico_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Condutor_Hidrico_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCondutor" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTrechoDuto" (code),
	"nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('TRA', 'Condutor_Hidrico_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Condutor_Hidrico_L_geom ON "TRA"."Condutor_Hidrico_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Condutor_Hidrico_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Condutor_Hidrico_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Pista_Ponto_Pouso_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPista" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPista" (code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento" (code),
 	"usoPista" smallint NOT NULL REFERENCES "DOMINIOS"."usoPista" (code),
 	"homologacao" smallint NOT NULL REFERENCES "DOMINIOS"."homologacao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id)

);
SELECT AddGeometryColumn('TRA', 'Pista_Ponto_Pouso_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Pista_Ponto_Pouso_P_geom ON "TRA"."Pista_Ponto_Pouso_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Pista_Ponto_Pouso_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Pista_Ponto_Pouso_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPista" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPista" (code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento" (code),
 	"usoPista" smallint NOT NULL REFERENCES "DOMINIOS"."usoPista" (code),
 	"homologacao" smallint NOT NULL REFERENCES "DOMINIOS"."homologacao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Pista_Ponto_Pouso_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Pista_Ponto_Pouso_L_geom ON "TRA"."Pista_Ponto_Pouso_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON  TABLE "TRA"."Pista_Ponto_Pouso_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Pista_Ponto_Pouso_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPista" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPista" (code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento" (code),
 	"usoPista" smallint NOT NULL REFERENCES "DOMINIOS"."usoPista" (code),
 	"homologacao" smallint NOT NULL REFERENCES "DOMINIOS"."homologacao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Pista_Ponto_Pouso_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Pista_Ponto_Pouso_A_geom ON "TRA"."Pista_Ponto_Pouso_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Pista_Ponto_Pouso_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Constr_Aeroportuaria_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifAero" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifAero" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Constr_Aeroportuaria_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Edif_Constr_Aeroportuaria_P_geom ON "TRA"."Edif_Constr_Aeroportuaria_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Constr_Aeroportuaria_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Constr_Aeroportuaria_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifAero" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifAero" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Constr_Aeroportuaria_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Edif_Constr_Aeroportuaria_A_geom ON "TRA"."Edif_Constr_Aeroportuaria_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Constr_Aeroportuaria_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Trecho_Hidroviario_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
        "extensaoTrecho" real,
        "caladoMaxSeca" real,
	"nomeAbrev" varchar(50),
	"id_hidrovia" INTEGER REFERENCES "TRA"."Hidrovia",
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Trecho_Hidroviario_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Trecho_Hidroviario_L_geom ON "TRA"."Trecho_Hidroviario_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Trecho_Hidroviario_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Trecho_Hidroviario_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Ponto_Hidroviario_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"relacionado" smallint NOT NULL REFERENCES "DOMINIOS"."relacionado_Ponto_Hidroviario" (code)
);
SELECT AddGeometryColumn('TRA', 'Ponto_Hidroviario_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Ponto_Hidroviario_P_geom ON "TRA"."Ponto_Hidroviario_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Ponto_Hidroviario_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Ponto_Hidroviario_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Eclusa_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "desnivel" real,
        "largura" real,
        "extensao" real,
        "calado" real,
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Eclusa_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Eclusa_P_geom ON "TRA"."Eclusa_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Eclusa_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Eclusa_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Eclusa_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "desnivel" real,
        "largura" real,
        "extensao" real,
        "calado" real,
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Eclusa_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Eclusa_L_geom ON "TRA"."Eclusa_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Eclusa_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Eclusa_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Eclusa_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "desnivel" real,
        "largura" real,
        "extensao" real,
        "calado" real,
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Eclusa_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Eclusa_A_geom ON "TRA"."Eclusa_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Eclusa_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Eclusa_A" TO public;
--########################################################################################################
CREATE TABLE "TRA"."Edif_Constr_Portuaria_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifPort" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifPort" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Constr_Portuaria_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Edif_Constr_Portuaria_P_geom ON "TRA"."Edif_Constr_Portuaria_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Constr_Portuaria_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Edif_Constr_Portuaria_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifPort" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifPort" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Edif_Constr_Portuaria_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Edif_Constr_Portuaria_A_geom ON "TRA"."Edif_Constr_Portuaria_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Edif_Constr_Portuaria_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Atracadouro_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAtracad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAtracad" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Atracadouro_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Atracadouro_P_geom ON "TRA"."Atracadouro_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Atracadouro_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Atracadouro_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Atracadouro_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAtracad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAtracad" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Atracadouro_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Atracadouro_L_geom ON "TRA"."Atracadouro_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Atracadouro_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Atracadouro_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Atracadouro_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAtracad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAtracad" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Atracadouro_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Atracadouro_A_geom ON "TRA"."Atracadouro_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Atracadouro_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Atracadouro_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Fundeadouro_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"destinacaoFundeadouro" smallint NOT NULL REFERENCES "DOMINIOS"."destinacaoFundeadouro" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "nomeAbrev" varchar(50),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Fundeadouro_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Fundeadouro_P_geom ON "TRA"."Fundeadouro_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Fundeadouro_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Fundeadouro_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Fundeadouro_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"destinacaoFundeadouro" smallint NOT NULL REFERENCES "DOMINIOS"."destinacaoFundeadouro" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "nomeAbrev" varchar(50),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Fundeadouro_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Fundeadouro_L_geom ON "TRA"."Fundeadouro_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Fundeadouro_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Fundeadouro_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Fundeadouro_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"destinacaoFundeadouro" smallint NOT NULL REFERENCES "DOMINIOS"."destinacaoFundeadouro" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "nomeAbrev" varchar(50),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id)
);
SELECT AddGeometryColumn('TRA', 'Fundeadouro_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Fundeadouro_A_geom ON "TRA"."Fundeadouro_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Fundeadouro_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Fundeadouro_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Obstaculo_Navegacao_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoObst" smallint NOT NULL REFERENCES "DOMINIOS"."tipoObst" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Obstaculo_Navegacao_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Obstaculo_Navegacao_P_geom ON "TRA"."Obstaculo_Navegacao_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Obstaculo_Navegacao_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Obstaculo_Navegacao_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Obstaculo_Navegacao_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoObst" smallint NOT NULL REFERENCES "DOMINIOS"."tipoObst" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Obstaculo_Navegacao_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_TRA_Obstaculo_Navegacao_L_geom ON "TRA"."Obstaculo_Navegacao_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Obstaculo_Navegacao_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Obstaculo_Navegacao_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Obstaculo_Navegacao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoObst" smallint NOT NULL REFERENCES "DOMINIOS"."tipoObst" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Obstaculo_Navegacao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Obstaculo_Navegacao_A_geom ON "TRA"."Obstaculo_Navegacao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Obstaculo_Navegacao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Obstaculo_Navegacao_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Sinalizacao_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoSinal" smallint NOT NULL REFERENCES "DOMINIOS"."tipoSinal" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_hidrovia" INTEGER REFERENCES "TRA"."Hidrovia",
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario"
);
SELECT AddGeometryColumn('TRA', 'Sinalizacao_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Sinalizacao_P_geom ON "TRA"."Sinalizacao_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Sinalizacao_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Sinalizacao_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Faixa_Seguranca_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"largura" real,
        "extensao" real,
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Faixa_Seguranca_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Faixa_Seguranca_A_geom ON "TRA"."Faixa_Seguranca_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Faixa_Seguranca_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Faixa_Seguranca_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Passagem_Nivel_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('TRA', 'Passagem_Nivel_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Passagem_Nivel_P_geom ON "TRA"."Passagem_Nivel_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Passagem_Nivel_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Passagem_Nivel_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Posto_Combustivel_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Posto_Combustivel_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_TRA_Posto_Combustivel_P_geom ON "TRA"."Posto_Combustivel_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Posto_Combustivel_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Posto_Combustivel_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "TRA"."Posto_Combustivel_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id)
);
SELECT AddGeometryColumn('TRA', 'Posto_Combustivel_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_TRA_Posto_Combustivel_A_geom ON "TRA"."Posto_Combustivel_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "TRA"."Posto_Combustivel_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "TRA"."Posto_Combustivel_A" TO public;
--########################################################################################################


-- ENC - INICIO
--########################################################################################################
CREATE TABLE "ENC"."Area_Energia_Eletrica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id),
	"id_subestTransmDistribEnergiaEletrica" INTEGER REFERENCES "ENC"."Subest_Transm_Distrib_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Area_Energia_Eletrica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Area_Energia_Eletrica_A_geom ON "ENC"."Area_Energia_Eletrica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Area_Energia_Eletrica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Area_Energia_Eletrica_A" TO public;
--################################################################################################################
--################################################################################################################
CREATE TABLE "ENC"."Edif_Energia_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifEnergia" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifEnergia" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id),
	"id_subestTransmDistribEnergiaEletrica" INTEGER REFERENCES "ENC"."Subest_Transm_Distrib_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Edif_Energia_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Edif_Energia_P_geom ON "ENC"."Edif_Energia_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Edif_Energia_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Edif_Energia_P" TO public;
--################################################################################################################
--################################################################################################################
CREATE TABLE "ENC"."Edif_Energia_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifEnergia" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifEnergia" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id),
	"id_subestTransmDistribEnergiaEletrica" INTEGER REFERENCES "ENC"."Subest_Transm_Distrib_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Edif_Energia_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Edif_Energia_A_geom ON "ENC"."Edif_Energia_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Edif_Energia_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Edif_Energia_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Est_Gerad_Energia_Eletrica_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEstGerad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEstGerad" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"destEnergElet" smallint NOT NULL REFERENCES "DOMINIOS"."destEnergElet" (code),
        "codigoEstacao" varchar(30),
        "potenciaOutorgada" integer,
        "potenciaFiscalizada" integer,
        "nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Est_Gerad_Energia_Eletrica_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Est_Gerad_Energia_Eletrica_P_geom ON "ENC"."Est_Gerad_Energia_Eletrica_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Est_Gerad_Energia_Eletrica_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEstGerad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEstGerad" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"destEnergElet" smallint NOT NULL REFERENCES "DOMINIOS"."destEnergElet" (code),
        "codigoEstacao" varchar(30),
        "potenciaOutorgada" integer,
        "potenciaFiscalizada" integer,
        "nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Est_Gerad_Energia_Eletrica_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_ENC_Est_Gerad_Energia_Eletrica_L_geom ON "ENC"."Est_Gerad_Energia_Eletrica_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Est_Gerad_Energia_Eletrica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEstGerad" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEstGerad" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"destEnergElet" smallint NOT NULL REFERENCES "DOMINIOS"."destEnergElet" (code),
        "codigoEstacao" varchar(30),
        "potenciaOutorgada" integer,
        "potenciaFiscalizada" integer,
        "nomeAbrev" varchar(50),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Est_Gerad_Energia_Eletrica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Est_Gerad_Energia_Eletrica_A_geom ON "ENC"."Est_Gerad_Energia_Eletrica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Hidreletrica_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "codigoHidreletrica" varchar(30),
        "potenciaOutorgada" integer,
        "potenciaFiscalizada" integer,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Hidreletrica_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Hidreletrica_P_geom ON "ENC"."Hidreletrica_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Hidreletrica_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Hidreletrica_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Hidreletrica_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "codigoHidreletrica" varchar(30),
        "potenciaOutorgada" integer,
        "potenciaFiscalizada" integer,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Hidreletrica_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_ENC_Hidreletrica_L_geom ON "ENC"."Hidreletrica_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Hidreletrica_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Hidreletrica_L" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Hidreletrica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "codigoHidreletrica" varchar(30),
        "potenciaOutorgada" integer,
        "potenciaFiscalizada" integer,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Hidreletrica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Hidreletrica_A_geom ON "ENC"."Hidreletrica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Hidreletrica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Hidreletrica_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Termeletrica_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoCombustivel" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCombustivel" (code),
 	"combRenovavel" smallint NOT NULL REFERENCES "DOMINIOS"."combRenovavel" (code),
 	"tipoMaqTermica" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMaqTermica" (code),
 	"geracao" smallint NOT NULL REFERENCES "DOMINIOS"."geracao" (code),
        "potenciaOutorgada" real,
        "potenciaFiscalizada" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Termeletrica_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Termeletrica_P_geom ON "ENC"."Termeletrica_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Termeletrica_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Termeletrica_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Termeletrica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoCombustivel" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCombustivel" (code),
 	"combRenovavel" smallint NOT NULL REFERENCES "DOMINIOS"."combRenovavel" (code),
 	"tipoMaqTermica" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMaqTermica" (code),
 	"geracao" smallint NOT NULL REFERENCES "DOMINIOS"."geracao" (code),
        "codigoHidreletrica" varchar(30),
        "potenciaOutorgada" real,
        "potenciaFiscalizada" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Termeletrica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Termeletrica_A_geom ON "ENC"."Termeletrica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Termeletrica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Termeletrica_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Ponto_Trecho_Energia_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPtoEnergia" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPtoEnergia" (code)
);
SELECT AddGeometryColumn('ENC', 'Ponto_Trecho_Energia_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Ponto_Trecho_Energia_P_geom ON "ENC"."Ponto_Trecho_Energia_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Ponto_Trecho_Energia_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Ponto_Trecho_Energia_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Trecho_Energia_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
         "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"especie" smallint NOT NULL REFERENCES "DOMINIOS"."especie" (code),
 	"posicaoRelativa" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoRelativa" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"emDuto" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
        "tensaoEletrica" real,
        "numCircuitos" integer,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Trecho_Energia_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_ENC_Trecho_Energia_L_geom ON "ENC"."Trecho_Energia_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Trecho_Energia_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Trecho_Energia_L" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Zona_Linhas_Energia_Comunicacao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Zona_Linhas_Energia_Comunicacao_A_geom ON "ENC"."Zona_Linhas_Energia_Comunicacao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A"  TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Torre_Energia_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"ovgd" smallint NOT NULL REFERENCES "DOMINIOS"."ovgd" (code),
        "alturaEstimada" real,
 	"tipoTorre" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTorre" (code),
        "arranjoFases" varchar(12),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Torre_Energia_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Torre_Energia_P_geom ON "ENC"."Torre_Energia_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Torre_Energia_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Torre_Energia_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Area_Comunicacao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoComunicacao" INTEGER REFERENCES "ENC"."Complexo_Comunicacao" (id)
);
SELECT AddGeometryColumn('ENC', 'Area_Comunicacao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Area_Comunicacao_A_geom ON "ENC"."Area_Comunicacao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Area_Comunicacao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Area_Comunicacao_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Edif_Comunic_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"modalidade" smallint NOT NULL REFERENCES "DOMINIOS"."modalidade" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoEdifComunic" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifComunic" (code),
        "nomeAbrev" varchar(50),
	"id_complexoComunicacao" INTEGER REFERENCES "ENC"."Complexo_Comunicacao" (id)
);
SELECT AddGeometryColumn('ENC', 'Edif_Comunic_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Edif_Comunic_P_geom ON "ENC"."Edif_Comunic_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Edif_Comunic_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Edif_Comunic_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Edif_Comunic_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"modalidade" smallint NOT NULL REFERENCES "DOMINIOS"."modalidade" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoEdifComunic" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifComunic" (code),
        "nomeAbrev" varchar(50),
	"id_complexoComunicacao" INTEGER REFERENCES "ENC"."Complexo_Comunicacao" (id)
);
SELECT AddGeometryColumn('ENC', 'Edif_Comunic_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Edif_Comunic_A_geom ON "ENC"."Edif_Comunic_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Edif_Comunic_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Edif_Comunic_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Antena_Comunic_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"posicaoRelEdific" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoRelEdific" (code),
        "nomeAbrev" varchar(50),
	"id_complexoComunicacao" INTEGER REFERENCES "ENC"."Complexo_Comunicacao" (id)
);
SELECT AddGeometryColumn('ENC', 'Antena_Comunic_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Antena_Comunic_P_geom ON "ENC"."Antena_Comunic_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Antena_Comunic_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Antena_Comunic_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Torre_Comunic_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"posicaoRelEdific" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoRelEdific" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"ovgd" smallint NOT NULL REFERENCES "DOMINIOS"."ovgd" (code),
        "alturaEstimada" real,
        "nomeAbrev" varchar(50),
	"id_complexoComunicacao" INTEGER REFERENCES "ENC"."Complexo_Comunicacao" (id)
);
SELECT AddGeometryColumn('ENC', 'Torre_Comunic_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Torre_Comunic_P_geom ON "ENC"."Torre_Comunic_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Torre_Comunic_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Torre_Comunic_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Trecho_Comunic_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTrechoComunic" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTrechoComunic" (code),
 	"posicaoRelativa" smallint NOT NULL REFERENCES "DOMINIOS"."posicaoRelativa" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"emDuto" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ENC', 'Trecho_Comunic_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_ENC_Trecho_Comunic_L_geom ON "ENC"."Trecho_Comunic_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Trecho_Comunic_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Trecho_Comunic_L" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Grupo_Transformadores_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50),
	"id_subestTransmDistribEnergiaEletrica" INTEGER REFERENCES "ENC"."Subest_Transm_Distrib_Energia_Eletrica" (id)

);
SELECT AddGeometryColumn('ENC', 'Grupo_Transformadores_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ENC_Grupo_Transformadores_P_geom ON "ENC"."Grupo_Transformadores_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Grupo_Transformadores_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Grupo_Transformadores_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ENC"."Grupo_Transformadores_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50),
	"id_subestTransmDistribEnergiaEletrica" INTEGER REFERENCES "ENC"."Subest_Transm_Distrib_Energia_Eletrica" (id)
);
SELECT AddGeometryColumn('ENC', 'Grupo_Transformadores_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ENC_Grupo_Transformadores_A_geom ON "ENC"."Grupo_Transformadores_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ENC"."Grupo_Transformadores_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ENC"."Grupo_Transformadores_A" TO public;
--################################################################################################################

-- EDUCAÇÃO E CULTURA - INICIO

--################################################################################################################
CREATE TABLE "EDU"."Area_Ensino_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('EDU', 'Area_Ensino_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Area_Ensino_A_geom ON "EDU"."Area_Ensino_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Area_Ensino_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Area_Ensino_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Ensino_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoClasseCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code),
        "nomeAbrev" varchar(50),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Ensino_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Edif_Ensino_P_geom ON "EDU"."Edif_Ensino_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Ensino_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Ensino_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Ensino_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoClasseCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code),
        "nomeAbrev" varchar(50),
	"id_orgEnsino" INTEGER REFERENCES "EDU"."Org_Ensino" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Ensino_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Edif_Ensino_A_geom ON "EDU"."Edif_Ensino_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Ensino_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Ensino_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Area_Religiosa_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id)
);
SELECT AddGeometryColumn('EDU', 'Area_Religiosa_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Area_Religiosa_A_geom ON "EDU"."Area_Religiosa_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Area_Religiosa_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Area_Religiosa_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Religiosa_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifRelig" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifRelig" (code),
 	"ensino" smallint NOT NULL REFERENCES "DOMINIOS"."ensino" (code),
        "religiao" varchar(100),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Religiosa_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Edif_Religiosa_P_geom ON "EDU"."Edif_Religiosa_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Religiosa_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Religiosa_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Religiosa_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifRelig" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifRelig" (code),
 	"ensino" smallint NOT NULL REFERENCES "DOMINIOS"."ensino" (code),
        "religiao" varchar(100),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_orgEnsinoReligioso" INTEGER REFERENCES "EDU"."Org_Ensino_Religioso" (id),
	"id_orgReligiosa" INTEGER REFERENCES "EDU"."Org_Religiosa" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Religiosa_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Edif_Religiosa_A_geom ON "EDU"."Edif_Religiosa_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Religiosa_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Religiosa_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Area_Lazer_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)

);
SELECT AddGeometryColumn('EDU', 'Area_Lazer_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Area_Lazer_A_geom ON "EDU"."Area_Lazer_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Area_Lazer_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Area_Lazer_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Const_Lazer_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoEdifLazer" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifLazer" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Const_Lazer_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Edif_Const_Lazer_P_geom ON "EDU"."Edif_Const_Lazer_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Const_Lazer_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Const_Lazer_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Const_Lazer_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoEdifLazer" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifLazer" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Const_Lazer_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Edif_Const_Lazer_A_geom ON "EDU"."Edif_Const_Lazer_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Const_Lazer_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Const_Lazer_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Piscina_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Piscina_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Piscina_A_geom ON "EDU"."Piscina_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Piscina_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Piscina_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Campo_Quadra_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoCampoQuadra" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCampoQuadra" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Campo_Quadra_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Campo_Quadra_P_geom ON "EDU"."Campo_Quadra_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Campo_Quadra_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Campo_Quadra_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Campo_Quadra_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoCampoQuadra" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCampoQuadra" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Campo_Quadra_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Campo_Quadra_A_geom ON "EDU"."Campo_Quadra_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Campo_Quadra_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Campo_Quadra_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Const_Turistica_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifTurist" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifTurist" (code),
 	"ovgd" smallint NOT NULL REFERENCES "DOMINIOS"."ovgd" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Const_Turistica_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Edif_Const_Turistica_P_geom ON "EDU"."Edif_Const_Turistica_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Const_Turistica_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Edif_Const_Turistica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifTurist" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifTurist" (code),
 	"ovgd" smallint NOT NULL REFERENCES "DOMINIOS"."ovgd" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Edif_Const_Turistica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Edif_Const_Turistica_A_geom ON "EDU"."Edif_Const_Turistica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Edif_Const_Turistica_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Area_Ruinas_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Area_Ruinas_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Area_Ruinas_A_geom ON "EDU"."Area_Ruinas_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Area_Ruinas_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Area_Ruinas_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Ruina_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Ruina_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Ruina_P_geom ON "EDU"."Ruina_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Ruina_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Ruina_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Ruina_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Ruina_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Ruina_A_geom ON "EDU"."Ruina_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Ruina_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Ruina_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Pista_Competicao_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoPista" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPista" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Pista_Competicao_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_EDU_Pista_Competicao_L_geom ON "EDU"."Pista_Competicao_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Pista_Competicao_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Pista_Competicao_L" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Arquibancada_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Arquibancada_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Arquibancada_P_geom ON "EDU"."Arquibancada_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Arquibancada_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Arquibancada_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Arquibancada_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Arquibancada_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Arquibancada_A_geom ON "EDU"."Arquibancada_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Arquibancada_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Arquibancada_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Coreto_Tribuna_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Coreto_Tribuna_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_EDU_Coreto_Tribuna_P_geom ON "EDU"."Coreto_Tribuna_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Coreto_Tribuna_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Coreto_Tribuna_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "EDU"."Coreto_Tribuna_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoLazer" INTEGER REFERENCES "EDU"."Complexo_Lazer" (id)
);
SELECT AddGeometryColumn('EDU', 'Coreto_Tribuna_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_EDU_Coreto_Tribuna_A_geom ON "EDU"."Coreto_Tribuna_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "EDU"."Coreto_Tribuna_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "EDU"."Coreto_Tribuna_A" TO public;
--################################################################################################################

-- EDUCAÇÃO E CULTURA - FIM

-- ESTRUTURA ECONOMICA - INICIO

--################################################################################################################
CREATE TABLE "ECO"."Area_Comerc_Serv_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id)
);
SELECT AddGeometryColumn('ECO', 'Area_Comerc_Serv_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Area_Comerc_Serv_A_geom ON "ECO"."Area_Comerc_Serv_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Area_Comerc_Serv_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Area_Comerc_Serv_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Comerc_Serv_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoEdifComercServ" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifComercServ" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Edif_Comerc_Serv" (code),
	"nomeAbrev" varchar(50),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id)
);
SELECT AddGeometryColumn('ECO', 'Edif_Comerc_Serv_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Edif_Comerc_Serv_P_geom ON "ECO"."Edif_Comerc_Serv_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Comerc_Serv_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Comerc_Serv_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoEdifComercServ" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifComercServ" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Edif_Comerc_Serv" (code),
	"nomeAbrev" varchar(50),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id)
);
SELECT AddGeometryColumn('ECO', 'Edif_Comerc_Serv_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Edif_Comerc_Serv_A_geom ON "ECO"."Edif_Comerc_Serv_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Comerc_Serv_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Deposito_Geral_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoDepGeral" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDepGeral" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoExposicao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoExposicao" (code),
 	"tipoProdutoResiduo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoProdutoResiduo" (code),
 	"tipoConteudo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoConteudo" (code),
 	"unidadeVolume" smallint NOT NULL REFERENCES "DOMINIOS"."unidadeVolume" (code),
        "valorVolume" real,
 	"tratamento" smallint NOT NULL REFERENCES "DOMINIOS"."tratamento" (code),
	"nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Deposito_Geral_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Deposito_Geral_P_geom ON "ECO"."Deposito_Geral_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Deposito_Geral_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Deposito_Geral_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Deposito_Geral_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoDepGeral" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDepGeral" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoExposicao" smallint NOT NULL REFERENCES "DOMINIOS"."tipoExposicao" (code),
 	"tipoProdutoResiduo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoProdutoResiduo" (code),
 	"tipoConteudo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoConteudo" (code),
 	"unidadeVolume" smallint NOT NULL REFERENCES "DOMINIOS"."unidadeVolume" (code),
        "valorVolume" real,
 	"tratamento" smallint NOT NULL REFERENCES "DOMINIOS"."tratamento" (code),
	"nomeAbrev" varchar(50),
	"id_estrutApoio" INTEGER REFERENCES "TRA"."Estrut_Apoio" (id),
	"id_complexoAeroportuario" INTEGER REFERENCES "TRA"."Complexo_Aeroportuario" (id),
	"id_complexoPortuario" INTEGER REFERENCES "TRA"."Complexo_Portuario" (id),
	"id_complexoGeradorEnergiaEletrica" INTEGER REFERENCES "ENC"."Complexo_Gerador_Energia_Eletrica" (id),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Deposito_Geral_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Deposito_Geral_A_geom ON "ECO"."Deposito_Geral_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Deposito_Geral_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Deposito_Geral_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Area_Industrial_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)
);
SELECT AddGeometryColumn('ECO', 'Area_Industrial_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Area_Industrial_A_geom ON "ECO"."Area_Industrial_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Area_Industrial_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Area_Industrial_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Industrial_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"chamine" smallint NOT NULL REFERENCES "DOMINIOS"."chamine" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoDivisaoCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code),
        "nomeAbrev" varchar(50),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)
);
SELECT AddGeometryColumn('ECO', 'Edif_Industrial_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Edif_Industrial_P_geom ON "ECO"."Edif_Industrial_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Industrial_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Industrial_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Industrial_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"chamine" smallint NOT NULL REFERENCES "DOMINIOS"."chamine" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoDivisaoCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code),
        "nomeAbrev" varchar(50),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)
);
SELECT AddGeometryColumn('ECO', 'Edif_Industrial_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Edif_Industrial_A_geom ON "ECO"."Edif_Industrial_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Industrial_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Industrial_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Area_Ext_Mineral_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('ECO', 'Area_Ext_Mineral_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Area_Ext_Mineral_A_geom ON "ECO"."Area_Ext_Mineral_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Area_Ext_Mineral_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Area_Ext_Mineral_A" TO public;
--################################################################################################################
--################################################################################################################
CREATE TABLE "ECO"."Ext_Mineral_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoSecaoCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoSecaoCnae" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoExtMin" smallint NOT NULL REFERENCES "DOMINIOS"."tipoExtMin" (code),
 	"tipoProdutoResiduo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoProdutoResiduo" (code),
 	"tipoPocoMina" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPocoMina" (code),
 	"procExtracao" smallint NOT NULL REFERENCES "DOMINIOS"."procExtracao" (code),
 	"formaExtracao" smallint NOT NULL REFERENCES "DOMINIOS"."formaExtracao" (code),
 	"atividade" smallint NOT NULL REFERENCES "DOMINIOS"."atividade" (code),
    	"nomeAbrev" varchar(50),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('ECO', 'Ext_Mineral_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Ext_Mineral_P_geom ON "ECO"."Ext_Mineral_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Ext_Mineral_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Ext_Mineral_P" TO public;
--################################################################################################################
--################################################################################################################
CREATE TABLE "ECO"."Ext_Mineral_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoSecaoCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoSecaoCnae" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoExtMin" smallint NOT NULL REFERENCES "DOMINIOS"."tipoExtMin" (code),
 	"tipoProdutoResiduo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoProdutoResiduo" (code),
 	"tipoPocoMina" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPocoMina" (code),
 	"procExtracao" smallint NOT NULL REFERENCES "DOMINIOS"."procExtracao" (code),
 	"formaExtracao" smallint NOT NULL REFERENCES "DOMINIOS"."formaExtracao" (code),
 	"atividade" smallint NOT NULL REFERENCES "DOMINIOS"."atividade" (code),
    	"nomeAbrev" varchar(50),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('ECO', 'Ext_Mineral_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Ext_Mineral_A_geom ON "ECO"."Ext_Mineral_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Ext_Mineral_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Ext_Mineral_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Ext_Mineral_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoDivisaoCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code),
	"nomeAbrev" varchar(50),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('ECO', 'Edif_Ext_Mineral_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Edif_Ext_Mineral_P_geom ON "ECO"."Edif_Ext_Mineral_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Ext_Mineral_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Ext_Mineral_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Ext_Mineral_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoDivisaoCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDivisaoCnae" (code),
	"nomeAbrev" varchar(50),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id)
);
SELECT AddGeometryColumn('ECO', 'Edif_Ext_Mineral_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Edif_Ext_Mineral_A_geom ON "ECO"."Edif_Ext_Mineral_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Ext_Mineral_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Ext_Mineral_A" TO public;
--################################################################################################################

--##########################################################
CREATE TABLE "ECO"."Plataforma_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPlataforma" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPlataforma" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ECO', 'Plataforma_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Plataforma_P_geom ON "ECO"."Plataforma_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Plataforma_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Plataforma_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Plataforma_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPlataforma" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPlataforma" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ECO', 'Plataforma_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Plataforma_A_geom ON "ECO"."Plataforma_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Plataforma_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Plataforma_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"destinadoA" smallint NOT NULL REFERENCES "DOMINIOS"."destinadoA" (code),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Area_Agropec_Ext_Vegetal_Pesca_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Area_Agropec_Ext_Vegetal_Pesca_A_geom ON "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoEdifAgropec" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifAgropec" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Edif_Agropec_Ext_Vegetal_Pesca_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Edif_Agropec_Ext_Vegetal_Pesca_P_geom ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoEdifAgropec" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifAgropec" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Edif_Agropec_Ext_Vegetal_Pesca_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Edif_Agropec_Ext_Vegetal_Pesca_A_geom ON "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Equip_Agropec_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoEquipAgropec" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEquipAgropec" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Equip_Agropec_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ECO_Equip_Agropec_P_geom ON "ECO"."Equip_Agropec_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Equip_Agropec_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Equip_Agropec_P" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Equip_Agropec_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoEquipAgropec" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEquipAgropec" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Equip_Agropec_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_ECO_Equip_Agropec_L_geom ON "ECO"."Equip_Agropec_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Equip_Agropec_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Equip_Agropec_L" TO public;
--################################################################################################################

--################################################################################################################
CREATE TABLE "ECO"."Equip_Agropec_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"tipoEquipAgropec" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEquipAgropec" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ECO', 'Equip_Agropec_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ECO_Equip_Agropec_A_geom ON "ECO"."Equip_Agropec_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ECO"."Equip_Agropec_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ECO"."Equip_Agropec_A" TO public;
--################################################################################################################
-- ECO - FIM'

-- LOC - INICIO
--########################################################################################################

CREATE TABLE "LOC"."Localidade_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code) DEFAULT 999,
	"sede" smallint NOT NULL REFERENCES "DOMINIOS"."booleano" (code) DEFAULT 999,
	"identificador" varchar(80),
	"latitude" varchar(15),
	"longitude" varchar(15),
 	"tipoCidade" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCidade" (code) DEFAULT 999,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LOC', 'Localidade_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LOC_Localidade_P_geom ON "LOC"."Localidade_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Localidade_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Localidade_P" TO public;
-- ##############################################################################################################
CREATE TABLE "LOC"."Area_Urbana_Isolada_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAssociado" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAssociado" (code),
	"nomeAbrev" varchar(50),
	"id_capital" INTEGER REFERENCES "LOC"."Capital" (id),
	"id_cidade"  INTEGER REFERENCES "LOC"."Cidade" (id),
	"id_Vila" INTEGER REFERENCES "LOC"."Vila" (id)
);
SELECT AddGeometryColumn('LOC', 'Area_Urbana_Isolada_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LOC_Area_Urbana_Isolada_A_geom ON "LOC"."Area_Urbana_Isolada_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Area_Urbana_Isolada_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Area_Urbana_Isolada_A" TO public;
--################################################################################################################

CREATE TABLE "LOC"."Area_Edificada_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50),
	"id_capital" INTEGER REFERENCES "LOC"."Capital" (id),
	"id_cidade"  INTEGER REFERENCES "LOC"."Cidade" (id),
	"id_Vila" INTEGER REFERENCES "LOC"."Vila" (id),
	"id_aglomeradoRuralDeExtensaoUrbana" INTEGER REFERENCES "LOC"."Aglomerado_Rural_De_Extensao_Urbana" (id),
	"id_aglomeradoRuralIsolado" INTEGER REFERENCES "LOC"."Aglomerado_Rural_Isolado" (id)
);
SELECT AddGeometryColumn('LOC', 'Area_Edificada_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LOC_Area_Edificada_A_geom ON "LOC"."Area_Edificada_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Area_Edificada_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Area_Edificada_A" TO public;
--################################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Hab_Indigena_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coletiva" smallint NOT NULL REFERENCES "DOMINIOS"."coletiva" (code),
 	"isolada" smallint NOT NULL REFERENCES "DOMINIOS"."isolada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
);
SELECT AddGeometryColumn('LOC', 'Hab_Indigena_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LOC_Hab_Indigena_P_geom ON "LOC"."Hab_Indigena_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Hab_Indigena_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Hab_Indigena_P" TO public;
--################################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Hab_Indigena_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coletiva" smallint NOT NULL REFERENCES "DOMINIOS"."coletiva" (code),
 	"isolada" smallint NOT NULL REFERENCES "DOMINIOS"."isolada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
);
SELECT AddGeometryColumn('LOC', 'Hab_Indigena_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LOC_Hab_Indigena_A_geom ON "LOC"."Hab_Indigena_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Hab_Indigena_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Hab_Indigena_A" TO public;
--################################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Area_Habitacional_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
);
SELECT AddGeometryColumn('LOC', 'Area_Habitacional_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LOC_Area_Habitacional_A_geom ON "LOC"."Area_Habitacional_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Area_Habitacional_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Area_Habitacional_A" TO public;
--################################################################################################################
CREATE TABLE "LOC"."Edif_Habitacional_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
);
SELECT AddGeometryColumn('LOC', 'Edif_Habitacional_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LOC_Edif_Habitacional_P_geom ON "LOC"."Edif_Habitacional_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Edif_Habitacional_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Edif_Habitacional_P" TO public;
--################################################################################################################
--################################################################################################################
CREATE TABLE "LOC"."Edif_Habitacional_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
);
SELECT AddGeometryColumn('LOC', 'Edif_Habitacional_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LOC_Edif_Habitacional_A_geom ON "LOC"."Edif_Habitacional_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Edif_Habitacional_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Edif_Habitacional_A" TO public;
--################################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Nome_Local_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LOC', 'Nome_Local_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LOC_Nome_Local_P_geom ON "LOC"."Nome_Local_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Nome_Local_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Nome_Local_P" TO public;
--################################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Posic_Geo_Localidade_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"identificador" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"latitude" varchar(15) NOT NULL DEFAULT '999',
        "longitude" varchar(15) NOT NULL DEFAULT '999',
	"id_capital" INTEGER REFERENCES "LOC"."Capital" (id),
	"id_cidade"  INTEGER REFERENCES "LOC"."Cidade" (id),
	"id_Vila" INTEGER REFERENCES "LOC"."Vila" (id),
	"id_aglomeradoRuralDeExtensaoUrbana" INTEGER REFERENCES "LOC"."Aglomerado_Rural_De_Extensao_Urbana" (id),
	"id_aglomeradoRuralIsolado" INTEGER REFERENCES "LOC"."Aglomerado_Rural_Isolado" (id)
);
SELECT AddGeometryColumn('LOC', 'Posic_Geo_Localidade_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LOC_Posic_Geo_Localidade_P_geom ON "LOC"."Posic_Geo_Localidade_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Posic_Geo_Localidade_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Posic_Geo_Localidade_P" TO public;
--################################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Edificacao_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
	
);
SELECT AddGeometryColumn('LOC', 'Edificacao_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LOC_Edificacao_P_geom ON "LOC"."Edificacao_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Edificacao_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Edificacao_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "LOC"."Edificacao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
	"nomeAbrev" varchar(50),
	"id_complexoHabitacional" INTEGER REFERENCES "LOC"."Complexo_Habitacional" (id),
	"id_aldeiaIndigena" INTEGER REFERENCES "LOC"."Aldeia_Indigena" (id)
	
);
SELECT AddGeometryColumn('LOC', 'Edificacao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LOC_Edificacao_A_geom ON "LOC"."Edificacao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LOC"."Edificacao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LOC"."Edificacao_A" TO public;
--########################################################################################################
-- LOC - FIM
-- PONTOS DE REFERENCIA - INICIO
--########################################################################################################
CREATE TABLE "PTO"."Pto_Ref_Geod_Topo_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"proximidade" smallint NOT NULL REFERENCES "DOMINIOS"."proximidade" (code),
 	"tipoRef" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRef" (code),
 	"tipoPtoRefGeodTopo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPtoRefGeodTopo" (code),
 	"rede" smallint NOT NULL REFERENCES "DOMINIOS"."rede" (code),
	"latitude" varchar(15)  NOT NULL,
        "longitude" varchar(15)  NOT NULL,
        "altitudeOrtometrica" real,
 	"sistemaGeodesico" smallint NOT NULL REFERENCES "DOMINIOS"."sistemaGeodesico" (code),
        "outraRefPlan" varchar(50),
 	"referencialAltim" smallint NOT NULL REFERENCES "DOMINIOS"."referencialAltim" (code),
        "outraRefAlt" varchar(50),
 	"referencialGrav" smallint NOT NULL REFERENCES "DOMINIOS"."referencialGrav" (code),
 	"situacaoMarco" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoMarco" (code),
        "dataVisita" varchar(10),
        "orgaoEnteResp" varchar(30),
        "codPonto" varchar(10),
        "obs" text,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('PTO', 'Pto_Ref_Geod_Topo_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_PTO_Pto_Ref_Geod_Topo_P_geom ON "PTO"."Pto_Ref_Geod_Topo_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "PTO"."Pto_Ref_Geod_Topo_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "PTO"."Pto_Controle_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRef" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRef" (code),
 	"tipoPtoControle" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPtoControle" (code),
 	"materializado" smallint NOT NULL REFERENCES "DOMINIOS"."materializado" (code),
	"latitude" varchar(15)  NOT NULL,
        "longitude" varchar(15)  NOT NULL,
        "altitudeOrtometrica" real,
        "codProjeto" varchar(15),
 	"sistemaGeodesico" smallint NOT NULL REFERENCES "DOMINIOS"."sistemaGeodesico" (code),
        "outraRefPlan" varchar(50),
 	"referencialAltim" smallint NOT NULL REFERENCES "DOMINIOS"."referencialAltim" (code),
        "outraRefAlt" varchar(50),
        "orgaoEnteResp" varchar(30),
        "codPonto" varchar(10),
        "obs" text,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('PTO', 'Pto_Controle_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_PTO_Pto_Controle_P_geom ON "PTO"."Pto_Controle_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "PTO"."Pto_Controle_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "PTO"."Pto_Controle_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "PTO"."Pto_Est_Med_Fenomenos_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPtoEstMed" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPtoEstMed" (code),
        "codEstacao" varchar(50),
        "orgaoEnteResp" varchar(15),
        "nomeAbrev" varchar(50),
	"id_estMedFenomenos" INTEGER REFERENCES "PTO"."Pto_Est_Med_Fenomenos_P" (id)
);
SELECT AddGeometryColumn('PTO', 'Pto_Est_Med_Fenomenos_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_PTO_Pto_Est_Med_Fenomenos_P_geom ON "PTO"."Pto_Est_Med_Fenomenos_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "PTO"."Pto_Est_Med_Fenomenos_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "PTO"."Pto_Est_Med_Fenomenos_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "PTO"."Edif_Constr_Est_Med_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(100),
	"id_estMedFenomenos" INTEGER REFERENCES "PTO"."Pto_Est_Med_Fenomenos_P" (id)
);
SELECT AddGeometryColumn('PTO', 'Edif_Constr_Est_Med_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_PTO_Edif_Constr_Est_Med_P_geom ON "PTO"."Edif_Constr_Est_Med_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "PTO"."Edif_Constr_Est_Med_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "PTO"."Edif_Constr_Est_Med_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(100),
	"id_estMedFenomenos" INTEGER REFERENCES "PTO"."Pto_Est_Med_Fenomenos_P" (id)

);
SELECT AddGeometryColumn('PTO', 'Edif_Constr_Est_Med_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_PTO_Edif_Constr_Est_Med_A_geom ON "PTO"."Edif_Constr_Est_Med_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "PTO"."Edif_Constr_Est_Med_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "PTO"."Area_Est_Med_Fenomenos_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_estMedFenomenos" INTEGER REFERENCES "PTO"."Pto_Est_Med_Fenomenos_P" (id)
);
SELECT AddGeometryColumn('PTO', 'Area_Est_Med_Fenomenos_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_PTO_Area_Est_Med_Fenomenos_A_geom ON "PTO"."Area_Est_Med_Fenomenos_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "PTO"."Area_Est_Med_Fenomenos_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "PTO"."Area_Est_Med_Fenomenos_A" TO public;
--########################################################################################################
-- PONTOS DE REFERENCIA - FIM
-- LIM - INICIO

--########################################################################################################
CREATE TABLE "LIM"."Marco_De_Limite_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoMarcoLim" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMarcoLim" (code),
       	"latitude" varchar(15),
        "longitude" varchar(15),
        "altitudeOrtometrica" real,
 	"sistemaGeodesico" smallint NOT NULL REFERENCES "DOMINIOS"."sistemaGeodesico" (code),
        "outraRefPlan" varchar(50),
 	"referencialAltim" smallint NOT NULL REFERENCES "DOMINIOS"."referencialAltim" (code),
        "outraRefAlt" varchar(50),
        "orgResp" varchar(30),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Marco_De_Limite_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Marco_De_Limite_P_geom ON "LIM"."Marco_De_Limite_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Marco_De_Limite_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Marco_De_Limite_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Linha_De_Limite_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
        "extensao" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Linha_De_Limite_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Linha_De_Limite_L_geom ON "LIM"."Linha_De_Limite_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Linha_De_Limite_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Linha_De_Limite_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Limite_Politico_Administrativo_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
 	"tipoLimPol" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLimPol" (code),
        "obsSituacao" varchar(255),
        "extensao" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Limite_Politico_Administrativo_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Limite_Politico_Administrativo_L_geom ON "LIM"."Limite_Politico_Administrativo_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Limite_Politico_Administrativo_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Limite_Politico_Administrativo_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
 	"tipoLimIntraMun" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLimIntraMun" (code),
        "obsSituacao" varchar(255),
        "extensao" real,
        "nomeAbrev" varchar(50),
	"id_cidade"  INTEGER REFERENCES "LOC"."Cidade" (id),
	"id_Vila" INTEGER REFERENCES "LOC"."Vila" (id)
);
SELECT AddGeometryColumn('LIM', 'Limite_Intra_Municipal_Administrativo_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Limite_Intra_Municipal_Administrativo_L_geom ON "LIM"."Limite_Intra_Municipal_Administrativo_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Limite_Operacional_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
 	"tipoLimOper" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLimOper" (code),
        "obsSituacao" varchar(255),
        "extensao" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Limite_Operacional_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Limite_Operacional_L_geom ON "LIM"."Limite_Operacional_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Limite_Operacional_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Limite_Operacional_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Outros_Limites_Oficiais_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
 	"tipoOutLimOfic" smallint NOT NULL REFERENCES "DOMINIOS"."tipoOutLimOfic" (code),
        "obsSituacao" varchar(255),
        "extensao" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Outros_Limites_Oficiais_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Outros_Limites_Oficiais_L_geom ON "LIM"."Outros_Limites_Oficiais_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Outros_Limites_Oficiais_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Outros_Limites_Oficiais_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Limite_Particular_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
        "obsSituacao" varchar(255),
        "extensao" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Limite_Particular_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Limite_Particular_L_geom ON "LIM"."Limite_Particular_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Limite_Particular_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Limite_Particular_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Area_De_Propriedade_Particular_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Area_De_Propriedade_Particular_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Area_De_Propriedade_Particular_A_geom ON "LIM"."Area_De_Propriedade_Particular_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Area_De_Propriedade_Particular_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Area_De_Propriedade_Particular_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Limite_Area_Especial_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"coincideComDentroDe" smallint NOT NULL REFERENCES "DOMINIOS"."coincideComDentroDe" (code),
 	"tipoLimAreaEsp" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLimAreaEsp" (code),
        "obsSituacao" varchar(255),
        "extensao" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Limite_Area_Especial_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Limite_Area_Especial_L_geom ON "LIM"."Limite_Area_Especial_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Limite_Area_Especial_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Limite_Area_Especial_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Pais_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "sigla" varchar(3),
        "codIso3166" varchar(3),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Pais_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Pais_A_geom ON "LIM"."Pais_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Pais_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Pais_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Federacao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "geocodigo" varchar(15) NOT NULL DEFAULT '999',
        "sigla" varchar(3),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Federacao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Unidade_Federacao_A_geom ON "LIM"."Unidade_Federacao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Federacao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Federacao_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Municipio_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "geocodigo" varchar(15) NOT NULL DEFAULT '999',
 	"anoDeReferencia" smallint NOT NULL DEFAULT 00,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Municipio_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Municipio_A_geom ON "LIM"."Municipio_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Municipio_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Municipio_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Distrito_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "geocodigo" varchar(15) NOT NULL DEFAULT '999',
 	"anoDeReferencia" smallint,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Distrito_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Distrito_A_geom ON "LIM"."Distrito_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Distrito_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Distrito_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Sub_Distrito_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "geocodigo" varchar(15) NOT NULL DEFAULT '999',
 	"anoDeReferencia" smallint ,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Sub_Distrito_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Sub_Distrito_A_geom ON "LIM"."Sub_Distrito_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Sub_Distrito_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Sub_Distrito_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Regiao_Administrativa_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoDeReferencia" smallint ,
        "nomeAbrev" varchar(50),
	"id_cidade"  INTEGER REFERENCES "LOC"."Cidade" (id)
);
SELECT AddGeometryColumn('LIM', 'Regiao_Administrativa_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Regiao_Administrativa_A_geom ON "LIM"."Regiao_Administrativa_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Regiao_Administrativa_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Regiao_Administrativa_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Bairro_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoDeReferencia" smallint ,
        "nomeAbrev" varchar(50),
	"id_cidade"  INTEGER REFERENCES "LOC"."Cidade" (id)
);
SELECT AddGeometryColumn('LIM', 'Bairro_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Bairro_A_geom ON "LIM"."Bairro_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Bairro_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Bairro_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Area_De_Litigio_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "descricao" varchar(255),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Area_De_Litigio_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Area_De_Litigio_A_geom ON "LIM"."Area_De_Litigio_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Area_De_Litigio_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Area_De_Litigio_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Delimitacao_Fisica_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoDelimFis" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDelimFis" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"eletrificada" smallint NOT NULL REFERENCES "DOMINIOS"."eletrificada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Delimitacao_Fisica_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_LIM_Delimitacao_Fisica_L_geom ON "LIM"."Delimitacao_Fisica_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Delimitacao_Fisica_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Delimitacao_Fisica_L" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Uso_SustentaveL_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoCriacao" smallint ,
        "sigla" varchar(6),
        "areaOficial" varchar(15),
        "atoLegal" varchar(100),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"tipoUnidUsoSust" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUnidUsoSust" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Uso_SustentaveL_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Unidade_Uso_SustentaveL_P_geom ON "LIM"."Unidade_Uso_SustentaveL_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Uso_SustentaveL_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Uso_SustentaveL_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoCriacao" smallint ,
        "Sigla" varchar(6),
        "areaOficial" varchar(15),
        "atoLegal" varchar(100),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"tipoUnidUsoSust" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUnidUsoSust" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Uso_SustentaveL_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Unidade_Uso_SustentaveL_A_geom ON "LIM"."Unidade_Uso_SustentaveL_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Uso_SustentaveL_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Protecao_Integral_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoCriacao" smallint ,
        "sigla" varchar(6),
        "areaOficial" varchar(15),
        "atoLegal" varchar(100),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"tipoUnidProtInteg" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUnidProtInteg" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Protecao_Integral_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Unidade_Protecao_Integral_P_geom ON "LIM"."Unidade_Protecao_Integral_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Protecao_Integral_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Protecao_Integral_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Protecao_Integral_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoCriacao" smallint ,
        "sigla" varchar(6),
        "areaOficial" varchar(15),
        "atoLegal" varchar(100),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
 	"tipoUnidProtInteg" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUnidProtInteg" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Protecao_Integral_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Unidade_Protecao_Integral_A_geom ON "LIM"."Unidade_Protecao_Integral_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Protecao_Integral_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Protecao_Integral_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoCriacao" smallint ,
        "sigla" varchar(6),
        "areaOficial" varchar(15),
        "atoLegal" varchar(100),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "classificacao" varchar(100),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Conservacao_Nao_Snuc_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Unidade_Conservacao_Nao_Snuc_P_geom ON "LIM"."Unidade_Conservacao_Nao_Snuc_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"anoCriacao" smallint ,
        "sigla" varchar(6),
        "areaOficial" varchar(15),
        "atoLegal" varchar(100),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "classificacao" varchar(100),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Unidade_Conservacao_Nao_Snuc_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Unidade_Conservacao_Nao_Snuc_A_geom ON "LIM"."Unidade_Conservacao_Nao_Snuc_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Outras_Unid_Protegidas_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoOutUnidProt" smallint NOT NULL REFERENCES "DOMINIOS"."tipoOutUnidProt" (code),
 	"anoCriacao" smallint ,
        "historicoModificacao" varchar(255),
        "sigla" varchar(6),
        "areaOficial" varchar(15),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Outras_Unid_Protegidas_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Outras_Unid_Protegidas_P_geom ON "LIM"."Outras_Unid_Protegidas_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Outras_Unid_Protegidas_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Outras_Unid_Protegidas_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Outras_Unid_Protegidas_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoOutUnidProt" smallint NOT NULL REFERENCES "DOMINIOS"."tipoOutUnidProt" (code),
 	"anoCriacao" smallint ,
        "historicoModificacao" varchar(255),
        "sigla" varchar(6),
        "areaOficial" varchar(15),
 	"administracao" smallint NOT NULL REFERENCES "DOMINIOS"."administracao" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Outras_Unid_Protegidas_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Outras_Unid_Protegidas_A_geom ON "LIM"."Outras_Unid_Protegidas_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Outras_Unid_Protegidas_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Outras_Unid_Protegidas_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Terra_Publica_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "classificacao" varchar(100),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Terra_Publica_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Terra_Publica_P_geom ON "LIM"."Terra_Publica_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Terra_Publica_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Terra_Publica_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Terra_Publica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "classificacao" varchar(100),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Terra_Publica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Terra_Publica_A_geom ON "LIM"."Terra_Publica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Terra_Publica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Terra_Publica_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Area_Uso_Comunitario_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAreaUsoComun" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAreaUsoComun" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Area_Uso_Comunitario_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Area_Uso_Comunitario_P_geom ON "LIM"."Area_Uso_Comunitario_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Area_Uso_Comunitario_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Area_Uso_Comunitario_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Area_Uso_Comunitario_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAreaUsoComun" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAreaUsoComun" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Area_Uso_Comunitario_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Area_Uso_Comunitario_A_geom ON "LIM"."Area_Uso_Comunitario_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Area_Uso_Comunitario_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Area_Uso_Comunitario_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Area_Desenvolvimento_Controle_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "classificacao" varchar(200) NOT NULL DEFAULT '999',
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Area_Desenvolvimento_Controle_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Area_Desenvolvimento_Controle_P_geom ON "LIM"."Area_Desenvolvimento_Controle_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Area_Desenvolvimento_Controle_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Area_Desenvolvimento_Controle_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "classificacao" varchar(200) NOT NULL DEFAULT '999',
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Area_Desenvolvimento_Controle_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Area_Desenvolvimento_Controle_A_geom ON "LIM"."Area_Desenvolvimento_Controle_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Area_Desenvolvimento_Controle_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Terra_Indigena_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeTi" varchar(100),
 	"situacaoJuridica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoJuridica" (code),
        "dataSituacaoJuridica" varchar(10),
        "grupoEtnico" varchar(100),
        "areaOficialHa" real,
        "perimetroOficial" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Terra_Indigena_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_LIM_Terra_Indigena_P_geom ON "LIM"."Terra_Indigena_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Terra_Indigena_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Terra_Indigena_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "LIM"."Terra_Indigena_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeTi" varchar(100),
 	"situacaoJuridica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoJuridica" (code),
        "dataSituacaoJuridica" varchar(10),
        "grupoEtnico" varchar(100),
        "areaOficialHa" real,
        "perimetroOficial" real,
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('LIM', 'Terra_Indigena_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_LIM_Terra_Indigena_A_geom ON "LIM"."Terra_Indigena_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "LIM"."Terra_Indigena_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "LIM"."Terra_Indigena_A" TO public;
--########################################################################################################
-- LIM - FIM
-- ADM - INICIO
--########################################################################################################
CREATE TABLE "ADM"."Area_Pub_Civil_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code)
);
SELECT AddGeometryColumn('ADM', 'Area_Pub_Civil_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ADM_Area_Pub_Civil_P_geom ON "ADM"."Area_Pub_Civil_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Area_Pub_Civil_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Area_Pub_Civil_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Area_Pub_Civil_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('ADM', 'Area_Pub_Civil_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ADM_Area_Pub_Civil_A_geom ON "ADM"."Area_Pub_Civil_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Area_Pub_Civil_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Area_Pub_Civil_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Edif_Pub_Civil_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifCivil" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoUsoEdif" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUsoEdif" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('ADM', 'Edif_Pub_Civil_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ADM_Edif_Pub_Civil_P_geom ON "ADM"."Edif_Pub_Civil_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Edif_Pub_Civil_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Edif_Pub_Civil_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifCivil" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoUsoEdif" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUsoEdif" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('ADM', 'Edif_Pub_Civil_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ADM_Edif_Pub_Civil_A_geom ON "ADM"."Edif_Pub_Civil_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Edif_Pub_Civil_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Edif_Pub_Civil_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Posto_Fiscal_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPostoFisc" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('ADM', 'Posto_Fiscal_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ADM_Posto_Fiscal_P_geom ON "ADM"."Posto_Fiscal_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Posto_Fiscal_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Posto_Fiscal_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Posto_Fiscal_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPostoFisc" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
);
SELECT AddGeometryColumn('ADM', 'Posto_Fiscal_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ADM_Posto_Fiscal_A_geom ON "ADM"."Posto_Fiscal_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Posto_Fiscal_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Posto_Fiscal_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Area_Pub_Militar_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id)
);
SELECT AddGeometryColumn('ADM', 'Area_Pub_Militar_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ADM_Area_Pub_Militar_A_geom ON "ADM"."Area_Pub_Militar_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Area_Pub_Militar_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Area_Pub_Militar_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Edif_Pub_Militar_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifMil" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoUsoEdif" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUsoEdif" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id)
);
SELECT AddGeometryColumn('ADM', 'Edif_Pub_Militar_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ADM_Edif_Pub_Militar_P_geom ON "ADM"."Edif_Pub_Militar_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Edif_Pub_Militar_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Edif_Pub_Militar_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifMil" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"tipoUsoEdif" smallint NOT NULL REFERENCES "DOMINIOS"."tipoUsoEdif" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id)
);
SELECT AddGeometryColumn('ADM', 'Edif_Pub_Militar_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ADM_Edif_Pub_Militar_A_geom ON "ADM"."Edif_Pub_Militar_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Edif_Pub_Militar_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Posto_Pol_Rod_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPostoPol" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id)
);
SELECT AddGeometryColumn('ADM', 'Posto_Pol_Rod_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ADM_Posto_Pol_Rod_P_geom ON "ADM"."Posto_Pol_Rod_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Posto_Pol_Rod_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Posto_Pol_Rod_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "ADM"."Posto_Pol_Rod_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPostoPol" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdif" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id)
);
SELECT AddGeometryColumn('ADM', 'Posto_Pol_Rod_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ADM_Posto_Pol_Rod_A_geom ON "ADM"."Posto_Pol_Rod_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ADM"."Posto_Pol_Rod_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ADM"."Posto_Pol_Rod_A" TO public;
--########################################################################################################
-- ADM - FIM

-- SAU - INICIO

--########################################################################################################
CREATE TABLE "SAU"."Area_Saude_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgSaude" INTEGER REFERENCES "SAU"."Org_Saude" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id)

);
SELECT AddGeometryColumn('SAU', 'Area_Saude_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_SAU_Area_Saude_A_geom ON "SAU"."Area_Saude_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "SAU"."Area_Saude_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "SAU"."Area_Saude_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "SAU"."Edif_Saude_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoClasseCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"nivelAtencao" smallint NOT NULL REFERENCES "DOMINIOS"."nivelAtencao" (code),
        "nomeAbrev" varchar(50),
	"id_orgSaude" INTEGER REFERENCES "SAU"."Org_Saude" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id)

);
SELECT AddGeometryColumn('SAU', 'Edif_Saude_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_SAU_Edif_Saude_P_geom ON "SAU"."Edif_Saude_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "SAU"."Edif_Saude_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "SAU"."Edif_Saude_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "SAU"."Edif_Saude_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoClasseCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"nivelAtencao" smallint NOT NULL REFERENCES "DOMINIOS"."nivelAtencao" (code),
        "nomeAbrev" varchar(50),
	"id_orgSaude" INTEGER REFERENCES "SAU"."Org_Saude" (id),
	"id_orgSaudeMilitar" INTEGER REFERENCES "SAU"."Org_Saude_Militar" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgPubMilitar" INTEGER REFERENCES "ADM"."Org_Pub_Militar" (id),
	"id_orgEnsinoMilitar" INTEGER REFERENCES "EDU"."Org_Ensino_Militar" (id)

);
SELECT AddGeometryColumn('SAU', 'Edif_Saude_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_SAU_Edif_Saude_A_geom ON "SAU"."Edif_Saude_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "SAU"."Edif_Saude_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "SAU"."Edif_Saude_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "SAU"."Area_Servico_Social_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_orgSaude" INTEGER REFERENCES "SAU"."Org_Saude" (id),
	"id_orgServicoSocial" INTEGER REFERENCES "SAU"."Org_Servico_Social" (id),
	"id_orgServicoSocialPub" INTEGER REFERENCES "SAU"."Org_Servico_Social_Pub" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id)
	
);
SELECT AddGeometryColumn('SAU', 'Area_Servico_Social_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_SAU_Area_Servico_Social_A_geom ON "SAU"."Area_Servico_Social_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "SAU"."Area_Servico_Social_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "SAU"."Area_Servico_Social_A" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "SAU"."Edif_Servico_Social_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoClasseCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_orgServicoSocial" INTEGER REFERENCES "SAU"."Org_Servico_Social" (id),
	"id_orgServicoSocialPub" INTEGER REFERENCES "SAU"."Org_Servico_Social_Pub" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgSaude" INTEGER REFERENCES "SAU"."Org_Saude" (id)
);
SELECT AddGeometryColumn('SAU', 'Edif_Servico_Social_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_SAU_Edif_Servico_Social_P_geom ON "SAU"."Edif_Servico_Social_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "SAU"."Edif_Servico_Social_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "SAU"."Edif_Servico_Social_P" TO public;
--########################################################################################################

--########################################################################################################
CREATE TABLE "SAU"."Edif_Servico_Social_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoClasseCnae" smallint NOT NULL REFERENCES "DOMINIOS"."tipoClasseCnae" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_orgServicoSocial" INTEGER REFERENCES "SAU"."Org_Servico_Social" (id),
	"id_orgServicoSocialPub" INTEGER REFERENCES "SAU"."Org_Servico_Social_Pub" (id),
	"id_orgPubCivil" INTEGER REFERENCES "ADM"."Org_Pub_Civil" (id),
	"id_orgSaudePub" INTEGER REFERENCES "SAU"."Org_Saude_Pub" (id),
	"id_orgEnsinoPub" INTEGER REFERENCES "EDU"."Org_Ensino_Pub" (id),
	"id_orgSaude" INTEGER REFERENCES "SAU"."Org_Saude" (id)
);
SELECT AddGeometryColumn('SAU', 'Edif_Servico_Social_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_SAU_Edif_Servico_Social_A_geom ON "SAU"."Edif_Servico_Social_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "SAU"."Edif_Servico_Social_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "SAU"."Edif_Servico_Social_A" TO public;
--########################################################################################################

-- SAU - FIM
-- ASB - INICIO
--########################################################################################################
CREATE TABLE "ASB"."Area_Abast_Agua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoAbastAgua" INTEGER REFERENCES "ASB"."Complexo_Abast_Agua" (id)
);
SELECT AddGeometryColumn('ASB', 'Area_Abast_Agua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Area_Abast_Agua_A_geom ON "ASB"."Area_Abast_Agua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Area_Abast_Agua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Area_Abast_Agua_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Edif_Abast_Agua_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifAbast" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifAbast" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoAbastAgua" INTEGER REFERENCES "ASB"."Complexo_Abast_Agua" (id)
);
SELECT AddGeometryColumn('ASB', 'Edif_Abast_Agua_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ASB_Edif_Abast_Agua_P_geom ON "ASB"."Edif_Abast_Agua_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Edif_Abast_Agua_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Edif_Abast_Agua_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Edif_Abast_Agua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifAbast" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifAbast" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoAbastAgua" INTEGER REFERENCES "ASB"."Complexo_Abast_Agua" (id)
);
SELECT AddGeometryColumn('ASB', 'Edif_Abast_Agua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Edif_Abast_Agua_A_geom ON "ASB"."Edif_Abast_Agua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Edif_Abast_Agua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Edif_Abast_Agua_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Dep_Abast_Agua_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoDepAbast" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDepAbast" (code),
 	"situacaoAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoAgua" (code),
 	"construcao" smallint NOT NULL REFERENCES "DOMINIOS"."construcao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Dep_Abast_Agua" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoAbastAgua" INTEGER REFERENCES "ASB"."Complexo_Abast_Agua" (id),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ASB', 'Dep_Abast_Agua_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Dep_Abast_Agua_A_geom ON "ASB"."Dep_Abast_Agua_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Dep_Abast_Agua_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Dep_Abast_Agua_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoDepAbast" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDepAbast" (code),
 	"situacaoAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoAgua" (code),
 	"construcao" smallint NOT NULL REFERENCES "DOMINIOS"."construcao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Dep_Abast_Agua" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
        "nomeAbrev" varchar(50),
	"id_complexoAbastAgua" INTEGER REFERENCES "ASB"."Complexo_Abast_Agua" (id),
	"id_orgComercServ" INTEGER REFERENCES "ECO"."Org_Comerc_Serv" (id),
	"id_orgExtMineral" INTEGER REFERENCES "ECO"."Org_Ext_Mineral" (id),
	"id_orgIndustrial" INTEGER REFERENCES "ECO"."Org_Industrial" (id),
	"id_orgAgropecExtVegetalPesca" INTEGER REFERENCES "ECO"."Org_Agropec_Ext_Vegetal_Pesca" (id),
	"id_frigorificoMatadouro" INTEGER REFERENCES "ECO"."Frigorifico_Matadouro" (id),
	"id_Madeireira" INTEGER REFERENCES "ECO"."Madeireira" (id)	
);
SELECT AddGeometryColumn('ASB', 'Dep_Abast_Agua_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ASB_Dep_Abast_Agua_P_geom ON "ASB"."Dep_Abast_Agua_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Dep_Abast_Agua_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Area_Saneamento_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"id_complexoSaneamento" INTEGER REFERENCES "ASB"."Complexo_Saneamento" (id)
);
SELECT AddGeometryColumn('ASB', 'Area_Saneamento_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Area_Saneamento_A_geom ON "ASB"."Area_Saneamento_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Area_Saneamento_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Area_Saneamento_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Edif_Saneamento_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifSaneam" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifSaneam" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoSaneamento" INTEGER REFERENCES "ASB"."Complexo_Saneamento" (id)
);
SELECT AddGeometryColumn('ASB', 'Edif_Saneamento_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ASB_Edif_Saneamento_P_geom ON "ASB"."Edif_Saneamento_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Edif_Saneamento_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Edif_Saneamento_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Edif_Saneamento_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoEdifSaneam" smallint NOT NULL REFERENCES "DOMINIOS"."tipoEdifSaneam" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
        "nomeAbrev" varchar(50),
	"id_complexoSaneamento" INTEGER REFERENCES "ASB"."Complexo_Saneamento" (id)
);
SELECT AddGeometryColumn('ASB', 'Edif_Saneamento_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Edif_Saneamento_A_geom ON "ASB"."Edif_Saneamento_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Edif_Saneamento_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Edif_Saneamento_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Dep_Saneamento_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoDepSaneam" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDepSaneam" (code),
 	"construcao" smallint NOT NULL REFERENCES "DOMINIOS"."construcao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Dep_Abast_Agua" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"residuo" smallint NOT NULL REFERENCES "DOMINIOS"."residuo" (code),
 	"tipoResiduo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoResiduo" (code),
        "nomeAbrev" varchar(50),
	"id_complexoSaneamento" INTEGER REFERENCES "ASB"."Complexo_Saneamento" (id)
);
SELECT AddGeometryColumn('ASB', 'Dep_Saneamento_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ASB_Dep_Saneamento_P_geom ON "ASB"."Dep_Saneamento_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Dep_Saneamento_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Dep_Saneamento_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Dep_Saneamento_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoDepSaneam" smallint NOT NULL REFERENCES "DOMINIOS"."tipoDepSaneam" (code),
 	"construcao" smallint NOT NULL REFERENCES "DOMINIOS"."construcao" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Dep_Abast_Agua" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
 	"residuo" smallint NOT NULL REFERENCES "DOMINIOS"."residuo" (code),
 	"tipoResiduo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoResiduo" (code),
        "nomeAbrev" varchar(50),
	"id_complexoSaneamento" INTEGER REFERENCES "ASB"."Complexo_Saneamento" (id)
);
SELECT AddGeometryColumn('ASB', 'Dep_Saneamento_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Dep_Saneamento_A_geom ON "ASB"."Dep_Saneamento_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Dep_Saneamento_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Dep_Saneamento_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Cemiterio_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCemiterio" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCemiterio" (code),
 	"denominacaoAssociada" smallint NOT NULL REFERENCES "DOMINIOS"."denominacaoAssociada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ASB', 'Cemiterio_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_ASB_Cemiterio_P_geom ON "ASB"."Cemiterio_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Cemiterio_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Cemiterio_P" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "ASB"."Cemiterio_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCemiterio" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCemiterio" (code),
 	"denominacaoAssociada" smallint NOT NULL REFERENCES "DOMINIOS"."denominacaoAssociada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('ASB', 'Cemiterio_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_ASB_Cemiterio_A_geom ON "ASB"."Cemiterio_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "ASB"."Cemiterio_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "ASB"."Cemiterio_A" TO public;
--########################################################################################################
-- ASB - FIM

--VEG - INICIO
--########################################################################################################
CREATE TABLE "VEG"."Veg_Area_Contato_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Veg_Area_Contato_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Veg_Area_Contato_A_geom ON "VEG"."Veg_Area_Contato_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Veg_Area_Contato_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Veg_Area_Contato_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Veg_Cultivada_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoLavoura" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLavoura" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Veg_Cultivada" (code),
 	"terreno" smallint NOT NULL REFERENCES "DOMINIOS"."terreno" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
        "espacamentoIndividuos" real,
        "espessuraDAP" real,
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"cultivoPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."cultivoPredominante" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Veg_Cultivada_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Veg_Cultivada_A_geom ON "VEG"."Veg_Cultivada_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Veg_Cultivada_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Veg_Cultivada_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Mangue_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Mangue_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Mangue_A_geom ON "VEG"."Mangue_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Mangue_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Mangue_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Brejo_Pantano_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoBrejoPantano" smallint NOT NULL REFERENCES "DOMINIOS"."tipoBrejoPantano" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Brejo_Pantano_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Brejo_Pantano_A_geom ON "VEG"."Brejo_Pantano_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Mangue_A" ALTER COLUMN geom SET NOT NULL;
ALTER TABLE "VEG"."Brejo_Pantano_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Brejo_Pantano_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Veg_Restinga_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Veg_Restinga_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Veg_Restinga_A_geom ON "VEG"."Veg_Restinga_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Veg_Restinga_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Veg_Restinga_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Campinarana_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Campinarana_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Campinarana_A_geom ON "VEG"."Campinarana_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Campinarana_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Campinarana_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Floresta_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"caracteristicaFloresta" smallint NOT NULL REFERENCES "DOMINIOS"."caracteristicaFloresta" (code),
 	"especiePredominante" smallint NOT NULL REFERENCES "DOMINIOS"."especiePredominante" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Floresta_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Floresta_A_geom ON "VEG"."Floresta_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Floresta_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Floresta_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Macega_Chavascal_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoMacChav" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMacChav" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Macega_Chavascal_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Macega_Chavascal_A_geom ON "VEG"."Macega_Chavascal_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Macega_Chavascal_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Macega_Chavascal_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Cerrado_Cerradao_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCerr" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCerr" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Cerrado_Cerradao_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Cerrado_Cerradao_A_geom ON "VEG"."Cerrado_Cerradao_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Cerrado_Cerradao_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Cerrado_Cerradao_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Caatinga_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Caatinga_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Caatinga_A_geom ON "VEG"."Caatinga_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Caatinga_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Caatinga_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Estepe_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Estepe_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Estepe_A_geom ON "VEG"."Estepe_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Estepe_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Estepe_A" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "VEG"."Campo_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCampo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCampo" (code),
 	"ocorrenciaEm" smallint NOT NULL REFERENCES "DOMINIOS"."ocorrenciaEm" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('VEG', 'Campo_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_VEG_Campo_A_geom ON "VEG"."Campo_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "VEG"."Campo_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "VEG"."Campo_A" TO public;
--########################################################################################################
--VEG - FIM

-- AUXILIARES DE AQUISICAO GEOMETRICA - INICIO

CREATE TABLE "AQUISICAO"."Barragem_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"matConstr" smallint NOT NULL REFERENCES "DOMINIOS"."matConstr" (code),
 	"usoPrincipal" smallint NOT NULL REFERENCES "DOMINIOS"."usoPrincipal" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Barragem_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Barragem_C_geom ON "AQUISICAO"."Barragem_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Barragem_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Barragem_C" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "AQUISICAO"."Massa_Dagua_C"(
	id serial NOT NULL PRIMARY KEY,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoMassaDagua" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMassaDagua" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
 	"salinidade" smallint NOT NULL REFERENCES "DOMINIOS"."salinidade" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Massa_Dagua_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Massa_Dagua_C_geom ON "AQUISICAO"."Massa_Dagua_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Massa_Dagua_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Massa_Dagua_C" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "AQUISICAO"."Trecho_Massa_Dagua_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
	"nomeAbrev" varchar(50),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTrechoMassa" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMassaDagua" (code),
 	"regime" smallint NOT NULL REFERENCES "DOMINIOS"."regime" (code),
 	"salinidade" smallint NOT NULL REFERENCES "DOMINIOS"."salinidade" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Trecho_Massa_Dagua_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Trecho_Massa_Dagua_C_geom ON "AQUISICAO"."Trecho_Massa_Dagua_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Trecho_Massa_Dagua_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Trecho_Massa_Dagua_C" TO public;
--#################################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Area_Edificada_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Area_Edificada_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Area_Edificada_C_geom ON "AQUISICAO"."Area_Edificada_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Area_Edificada_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Area_Edificada_C" TO public;
--################################################################################################################
--#################################################################################################################
CREATE TABLE "AQUISICAO"."Alteracao_Fisiografica_Antropica_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoAlterAntrop" smallint NOT NULL REFERENCES "DOMINIOS"."tipoAlterAntrop" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Alteracao_Fisiografica_Antropica_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Alteracao_Fisiografica_Antropica_C_geom ON "AQUISICAO"."Alteracao_Fisiografica_Antropica_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Alteracao_Fisiografica_Antropica_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Alteracao_Fisiografica_Antropica_C" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "AQUISICAO"."Rocha_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80) NOT NULL,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoRocha" smallint NOT NULL REFERENCES "DOMINIOS"."tipoRocha" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Rocha_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Rocha_C_geom ON "AQUISICAO"."Rocha_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Rocha_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE  "AQUISICAO"."Rocha_C" TO public;
--#################################################################################################################
--#################################################################################################################
CREATE TABLE "AQUISICAO"."Terreno_Exposto_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoTerrExp" smallint NOT NULL REFERENCES "DOMINIOS"."tipoTerrExp" (code),
 	"causaExposicao" smallint NOT NULL REFERENCES "DOMINIOS"."causaExposicao" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Terreno_Exposto_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Terreno_Exposto_C_geom ON "AQUISICAO"."Terreno_Exposto_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Terreno_Exposto_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Terreno_Exposto_C" TO public;
--#################################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Pista_Ponto_Pouso_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoPista" smallint NOT NULL REFERENCES "DOMINIOS"."tipoPista" (code),
 	"revestimento" smallint NOT NULL REFERENCES "DOMINIOS"."revestimento" (code),
 	"usoPista" smallint NOT NULL REFERENCES "DOMINIOS"."usoPista" (code),
 	"homologacao" smallint NOT NULL REFERENCES "DOMINIOS"."homologacao" (code),
 	"operacional" smallint NOT NULL REFERENCES "DOMINIOS"."operacional" (code),
 	"situacaoFisica" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoFisica" (code),
	"largura" real,
	"extensao" real,
	"nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Pista_Ponto_Pouso_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Pista_Ponto_Pouso_C_geom ON "AQUISICAO"."Pista_Ponto_Pouso_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Brejo_Pantano_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoBrejoPantano" smallint NOT NULL REFERENCES "DOMINIOS"."tipoBrejoPantano" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Brejo_Pantano_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Brejo_Pantano_C_geom ON "AQUISICAO"."Brejo_Pantano_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Brejo_Pantano_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Brejo_Pantano_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Caatinga_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Caatinga_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Caatinga_C_geom ON "AQUISICAO"."Caatinga_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Caatinga_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Caatinga_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Campinarana_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Campinarana_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Campinarana_C_geom ON "AQUISICAO"."Campinarana_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Campinarana_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Campinarana_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Campo_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCampo" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCampo" (code),
 	"ocorrenciaEm" smallint NOT NULL REFERENCES "DOMINIOS"."ocorrenciaEm" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Campo_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Campo_C_geom ON "AQUISICAO"."Campo_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Campo_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Campo_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Cerrado_Cerradao_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoCerr" smallint NOT NULL REFERENCES "DOMINIOS"."tipoCerr" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Cerrado_Cerradao_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Cerrado_Cerradao_C_geom ON "AQUISICAO"."Cerrado_Cerradao_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Cerrado_Cerradao_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Cerrado_Cerradao_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Estepe_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Estepe_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Estepe_C_geom ON "AQUISICAO"."Estepe_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Estepe_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Estepe_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Floresta_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"caracteristicaFloresta" smallint NOT NULL REFERENCES "DOMINIOS"."caracteristicaFloresta" (code),
 	"especiePredominante" smallint NOT NULL REFERENCES "DOMINIOS"."especiePredominante" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Floresta_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Floresta_C_geom ON "AQUISICAO"."Floresta_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Floresta_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Floresta_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Macega_Chavascal_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoMacChav" smallint NOT NULL REFERENCES "DOMINIOS"."tipoMacChav" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Macega_Chavascal_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Macega_Chavascal_C_geom ON "AQUISICAO"."Macega_Chavascal_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Macega_Chavascal_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Mangue_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Mangue_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Mangue_C_geom ON "AQUISICAO"."Mangue_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Mangue_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Veg_Restinga_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Veg_Restinga_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Veg_Restinga_C_geom ON "AQUISICAO"."Veg_Restinga_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Veg_Restinga_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Veg_Restinga_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Veg_Area_Contato_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"antropizada" smallint NOT NULL REFERENCES "DOMINIOS"."antropizada" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Veg_Area_Contato_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Veg_Area_Contato_C_geom ON "AQUISICAO"."Veg_Area_Contato_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Veg_Area_Contato_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Veg_Area_Contato_C" TO public;
--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."Veg_Cultivada_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
        "nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoLavoura" smallint NOT NULL REFERENCES "DOMINIOS"."tipoLavoura" (code),
 	"finalidade" smallint NOT NULL REFERENCES "DOMINIOS"."finalidade_Veg_Cultivada" (code),
 	"terreno" smallint NOT NULL REFERENCES "DOMINIOS"."terreno" (code),
 	"classificacaoPorte" smallint NOT NULL REFERENCES "DOMINIOS"."classificacaoPorte" (code),
        "espacamentoIndividuos" real,
        "espessuraDAP" real,
 	"denso" smallint NOT NULL REFERENCES "DOMINIOS"."denso" (code),
        "alturaMediaIndividuos" real,
 	"cultivoPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."cultivoPredominante" (code),
        "nomeAbrev" varchar(50)
);
SELECT AddGeometryColumn('AQUISICAO', 'Veg_Cultivada_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Veg_Cultivada_C_geom ON "AQUISICAO"."Veg_Cultivada_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Veg_Cultivada_C" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."limite"(
 	code smallint NOT NULL PRIMARY KEY UNIQUE,
	valor varchar(200) NOT NULL
);
GRANT ALL ON TABLE "AQUISICAO"."limite" TO public;

INSERT INTO "AQUISICAO"."limite" VALUES (0,'Bacia Hidrográfica');
INSERT INTO "AQUISICAO"."limite" VALUES (13,'Barragem de Terra');
INSERT INTO "AQUISICAO"."limite" VALUES (14,'Barragem de Concreto');
INSERT INTO "AQUISICAO"."limite" VALUES (15,'Queda d`água');
INSERT INTO "AQUISICAO"."limite" VALUES (16,'Foz Marítima');
INSERT INTO "AQUISICAO"."limite" VALUES (17,'Corredeira');
INSERT INTO "AQUISICAO"."limite" VALUES (18,'Natureza do Fundo');
INSERT INTO "AQUISICAO"."limite" VALUES (23,'Rocha em água');
INSERT INTO "AQUISICAO"."limite" VALUES (24,'Recife');
INSERT INTO "AQUISICAO"."limite" VALUES (26,'Banco de Areia');
INSERT INTO "AQUISICAO"."limite" VALUES (30,'Quebramar');
INSERT INTO "AQUISICAO"."limite" VALUES (31,'Molhe');
INSERT INTO "AQUISICAO"."limite" VALUES (32,'Terreno Sujeito a Inundação');
INSERT INTO "AQUISICAO"."limite" VALUES (33,'Área Úmida');
INSERT INTO "AQUISICAO"."limite" VALUES (36,'Reservatório Hídrico');
INSERT INTO "AQUISICAO"."limite" VALUES (501,'Delimitador Genérico HD');
INSERT INTO "AQUISICAO"."limite" VALUES (207,'Vila - Área Urbana Isolada');
INSERT INTO "AQUISICAO"."limite" VALUES (208,'Cidade - Área Urbana Isolada');
INSERT INTO "AQUISICAO"."limite" VALUES (209,'Área Edificada');
INSERT INTO "AQUISICAO"."limite" VALUES (210,'Habitação Indígena');
INSERT INTO "AQUISICAO"."limite" VALUES (211,'Área Habitacional');
INSERT INTO "AQUISICAO"."limite" VALUES (212,'Edificação Habitacional');
INSERT INTO "AQUISICAO"."limite" VALUES (213,'Edificação');
INSERT INTO "AQUISICAO"."limite" VALUES (509,'Delimitador Genérico LOC');
INSERT INTO "AQUISICAO"."limite" VALUES (37,'Serra, Morro, Montanha, Chapada, Maciço, Planalto, Planície, Península, Ponta e Cabo');
INSERT INTO "AQUISICAO"."limite" VALUES (47,'Praia, Falésia, Talude e Escarpa');
INSERT INTO "AQUISICAO"."limite" VALUES (51,'Dolina');
INSERT INTO "AQUISICAO"."limite" VALUES (52,'Duna');
INSERT INTO "AQUISICAO"."limite" VALUES (54,'Pedra ou Penedo Isolado');
INSERT INTO "AQUISICAO"."limite" VALUES (56,'Área Rochosa, Lajeado');
INSERT INTO "AQUISICAO"."limite" VALUES (57,'Terreno Exposto');
INSERT INTO "AQUISICAO"."limite" VALUES (60,'Resíduo Sólido ou Bota-fora');
INSERT INTO "AQUISICAO"."limite" VALUES (61,'Caixa de Empréstimo');
INSERT INTO "AQUISICAO"."limite" VALUES (62,'Área Aterrada');
INSERT INTO "AQUISICAO"."limite" VALUES (63,'Corte');
INSERT INTO "AQUISICAO"."limite" VALUES (64,'Aterro');
INSERT INTO "AQUISICAO"."limite" VALUES (502,'Delimitador Genérico REL');
INSERT INTO "AQUISICAO"."limite" VALUES (71,'Culturas');
INSERT INTO "AQUISICAO"."limite" VALUES (77,'Reflorestamento');
INSERT INTO "AQUISICAO"."limite" VALUES (78,'Mangue');
INSERT INTO "AQUISICAO"."limite" VALUES (82,'Brejo ou Pântano');
INSERT INTO "AQUISICAO"."limite" VALUES (97,'Mata');

INSERT INTO "AQUISICAO"."limite" VALUES (503,'Delimitador Genérico VEG');
INSERT INTO "AQUISICAO"."limite" VALUES (126,'Pátio');
INSERT INTO "AQUISICAO"."limite" VALUES (132,'Edificação Sistema Transporte');
INSERT INTO "AQUISICAO"."limite" VALUES (134,'Área de Dutos');
INSERT INTO "AQUISICAO"."limite" VALUES (135,'Local Crítico');
INSERT INTO "AQUISICAO"."limite" VALUES (136,'Pista de Pouso');
INSERT INTO "AQUISICAO"."limite" VALUES (143,'Eclusa');
INSERT INTO "AQUISICAO"."limite" VALUES (145,'Atracadouro');
INSERT INTO "AQUISICAO"."limite" VALUES (146,'Fundeadouro');
INSERT INTO "AQUISICAO"."limite" VALUES (147,'Obstáculo Navegação');
INSERT INTO "AQUISICAO"."limite" VALUES (148,'Faixa Segurança');
INSERT INTO "AQUISICAO"."limite" VALUES (149,'Posto Combustível');
INSERT INTO "AQUISICAO"."limite" VALUES (242,'Área Estrutura de Transporte');
INSERT INTO "AQUISICAO"."limite" VALUES (504,'Delimitador Genérico TRA');
--########################################################################################################
CREATE TABLE "AQUISICAO"."motivoDescontinuidade"(
 	code smallint NOT NULL PRIMARY KEY UNIQUE,
	valor varchar(200) NOT NULL
);
GRANT ALL ON TABLE "AQUISICAO"."motivoDescontinuidade" TO public;

INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (1,'Descontinuidade Temporal');
INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (2,'Descontinuidade devido a transformação');
INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (3,'Descontinuidade por escala de insumo');
INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (4,'Descontinuidade por falta de acurácia');
INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (5,'Descontinuidade por diferente interpretação das classes');
INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (6,'Descontinuidade por omissão');
INSERT INTO "AQUISICAO"."motivoDescontinuidade" VALUES (7,'Descontinuidade por excesso');

--########################################################################################################
--########################################################################################################
CREATE TABLE "AQUISICAO"."categoria"(
 	code smallint NOT NULL PRIMARY KEY UNIQUE,
	valor varchar(200) NOT NULL
);
GRANT ALL ON TABLE "AQUISICAO"."categoria" TO public;

INSERT INTO "AQUISICAO"."categoria" VALUES (1,'Hidrografia');
INSERT INTO "AQUISICAO"."categoria" VALUES (2,'Relevo');
INSERT INTO "AQUISICAO"."categoria" VALUES (3,'Vegetação');
INSERT INTO "AQUISICAO"."categoria" VALUES (4,'Sistema de Transporte');
INSERT INTO "AQUISICAO"."categoria" VALUES (5,'Energia e Comunicações');
INSERT INTO "AQUISICAO"."categoria" VALUES (6,'Abastecimento de Água e Saneamento Básico');
INSERT INTO "AQUISICAO"."categoria" VALUES (7,'Educação e Cultura');
INSERT INTO "AQUISICAO"."categoria" VALUES (8,'Estrutura Econômica');
INSERT INTO "AQUISICAO"."categoria" VALUES (9,'Localidades');
INSERT INTO "AQUISICAO"."categoria" VALUES (10,'Pontos de Referência');
INSERT INTO "AQUISICAO"."categoria" VALUES (11,'Limites');
INSERT INTO "AQUISICAO"."categoria" VALUES (12,'Administração Pública');
INSERT INTO "AQUISICAO"."categoria" VALUES (13,'Saúde e Serviço Social');
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."HID_D"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"limite" smallint NOT NULL REFERENCES "AQUISICAO"."limite" (code) DEFAULT 501
);
SELECT AddGeometryColumn('AQUISICAO', 'HID_D','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_AQUISICAO_HID_D_geom ON "AQUISICAO"."HID_D" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."HID_D" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."HID_D" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."LOC_D"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"limite" smallint NOT NULL REFERENCES "AQUISICAO"."limite" (code) DEFAULT 213
);
SELECT AddGeometryColumn('AQUISICAO', 'LOC_D','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_AQUISICAO_LOC_D_geom ON "AQUISICAO"."LOC_D" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."LOC_D" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."LOC_D" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."REL_D"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"limite" smallint NOT NULL REFERENCES "AQUISICAO"."limite" (code) DEFAULT 56
);
SELECT AddGeometryColumn('AQUISICAO', 'REL_D','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_AQUISICAO_REL_D_geom ON "AQUISICAO"."REL_D" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."REL_D" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."REL_D" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."TRA_D"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"limite" smallint NOT NULL REFERENCES "AQUISICAO"."limite" (code) DEFAULT 504
);
SELECT AddGeometryColumn('AQUISICAO', 'TRA_D','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_AQUISICAO_TRA_D_geom ON "AQUISICAO"."TRA_D" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."TRA_D" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."TRA_D" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."VEG_D"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"limite" smallint NOT NULL REFERENCES "AQUISICAO"."limite" (code) DEFAULT 97
);
SELECT AddGeometryColumn('AQUISICAO', 'VEG_D','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_AQUISICAO_VEG_D_geom ON "AQUISICAO"."VEG_D" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."VEG_D" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."VEG_D" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."Descontinuidade_Geometrica_P"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"motivoDescontinuidade" smallint NOT NULL REFERENCES "AQUISICAO"."motivoDescontinuidade" (code),
 	"categoria" smallint NOT NULL REFERENCES "AQUISICAO"."categoria" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Descontinuidade_Geometrica_P','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Descontinuidade_Geometrica_P_geom ON "AQUISICAO"."Descontinuidade_Geometrica_P" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Descontinuidade_Geometrica_P" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Descontinuidade_Geometrica_P" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."Descontinuidade_Geometrica_L"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"motivoDescontinuidade" smallint NOT NULL REFERENCES "AQUISICAO"."motivoDescontinuidade" (code),
 	"categoria" smallint NOT NULL REFERENCES "AQUISICAO"."categoria" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Descontinuidade_Geometrica_L','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_AQUISICAO_Descontinuidade_Geometrica_L_geom ON "AQUISICAO"."Descontinuidade_Geometrica_L" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Descontinuidade_Geometrica_L" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Descontinuidade_Geometrica_L" TO public;
--########################################################################################################
--########################################################################################################

CREATE TABLE "AQUISICAO"."Descontinuidade_Geometrica_A"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
 	"motivoDescontinuidade" smallint NOT NULL REFERENCES "AQUISICAO"."motivoDescontinuidade" (code),
 	"categoria" smallint NOT NULL REFERENCES "AQUISICAO"."categoria" (code)
);
SELECT AddGeometryColumn('AQUISICAO', 'Descontinuidade_Geometrica_A','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_AQUISICAO_Descontinuidade_Geometrica_A_geom ON "AQUISICAO"."Descontinuidade_Geometrica_A" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Descontinuidade_Geometrica_A" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Descontinuidade_Geometrica_A" TO public;
--########################################################################################################

-- AUXILIARES DE AQUISICAO GEOMETRICA - FIM


--ESTABELECENDO PRIVILEGIOS PARA OS GRUPOS DENTRO DAS CATEGORIAS
GRANT ALL ON SCHEMA "HID" TO public;
GRANT ALL ON SCHEMA "AUX" TO public;
GRANT ALL ON SCHEMA "REL" TO public;
GRANT ALL ON SCHEMA "VEG" TO public;
GRANT ALL ON SCHEMA "TRA" TO public;
GRANT ALL ON SCHEMA "ENC" TO public;
GRANT ALL ON SCHEMA "ASB" TO public;
GRANT ALL ON SCHEMA "EDU" TO public;
GRANT ALL ON SCHEMA "ECO" TO public;
GRANT ALL ON SCHEMA "LOC" TO public;
GRANT ALL ON SCHEMA "PTO" TO public;
GRANT ALL ON SCHEMA "LIM" TO public;
GRANT ALL ON SCHEMA "ADM" TO public;
GRANT ALL ON SCHEMA "SAU" TO public;
GRANT ALL ON SCHEMA "DOMINIOS" TO public;
GRANT ALL ON SCHEMA "MOLDURA" TO public;
GRANT ALL ON SCHEMA "AQUISICAO" TO public;
GRANT ALL ON SCHEMA topology TO public;


-- ESTABELECENDO PRIVILEGIOS NAS SEQUENCIAS
GRANT ALL ON ALL SEQUENCES IN SCHEMA "AUX" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "HID" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "REL" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "VEG" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "TRA" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "ENC" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "ASB" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "EDU" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "ECO" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "LOC" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "PTO" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "LIM" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "ADM" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "SAU" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "DOMINIOS" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "MOLDURA" TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "AQUISICAO" TO public;

--########################################################################################################
-- Início - Cria as restrições e default de cada classe
ALTER TABLE "LOC"."Localidade_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Localidade_P" ADD CHECK ("tipoCidade" IN(1,2,3,4,5,6,7,8,999)), ALTER COLUMN "tipoCidade" SET DEFAULT 999;
ALTER TABLE "HID"."Bacia_Hidrografica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Massa_Dagua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Massa_Dagua_A" ADD CHECK ("tipoMassaDagua" IN(0,3,4,5,6,7,8,10,99,999)), ALTER COLUMN "tipoMassaDagua" SET DEFAULT 999;
ALTER TABLE "HID"."Massa_Dagua_A" ADD CHECK ("regime" IN(1,2,3,4,5,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "HID"."Massa_Dagua_A" ADD CHECK ("salinidade" IN(0,1,2,999)), ALTER COLUMN "salinidade" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Massa_Dagua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Massa_Dagua_A" ADD CHECK ("regime" IN(1,2,3,4,5,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Massa_Dagua_A" ADD CHECK ("salinidade" IN(0,1,2,999)), ALTER COLUMN "salinidade" SET DEFAULT 999;
ALTER TABLE "HID"."Limite_Massa_Dagua_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Limite_Massa_Dagua_L" ADD CHECK ("tipoLimMassa" IN(1,2,3,4,5,6,7,998,999)), ALTER COLUMN "tipoLimMassa" SET DEFAULT 999;
ALTER TABLE "HID"."Limite_Massa_Dagua_L" ADD CHECK ("materialPredominante" IN(0,4,12,13,14,15,16,18,19,20,21,50,97,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("dentroDePoligono" IN(1,2,999)), ALTER COLUMN "dentroDePoligono" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("compartilhado" IN(1,2,999)), ALTER COLUMN "compartilhado" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("eixoPrincipal" IN(1,2,999)), ALTER COLUMN "eixoPrincipal" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("navegabilidade" IN(0,1,2,999)), ALTER COLUMN "navegabilidade" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("coincideComDentroDe" IN(1,2,9,10,11,12,13,14,16,19,24,97,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "HID"."Trecho_Drenagem_L" ADD CHECK ("regime" IN(1,2,3,4,5,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "HID"."Ponto_Drenagem_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ponto_Drenagem_P" ADD CHECK ("relacionado" IN(1,2,3,4,5,6,7,8,80,9,90,10,100,11,110,12,120,13,16,17,18,999)), ALTER COLUMN "relacionado" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_P" ADD CHECK ("matConstr" IN(0,1,2,4,23,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_P" ADD CHECK ("usoPrincipal" IN(0,1,2,3,97,99,999)), ALTER COLUMN "usoPrincipal" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_L" ADD CHECK ("matConstr" IN(0,1,2,4,23,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_L" ADD CHECK ("usoPrincipal" IN(0,1,2,3,97,99,999)), ALTER COLUMN "usoPrincipal" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_A" ADD CHECK ("matConstr" IN(0,1,2,4,23,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_A" ADD CHECK ("usoPrincipal" IN(0,1,2,3,97,99,999)), ALTER COLUMN "usoPrincipal" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Barragem_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Comporta_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Comporta_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Comporta_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Comporta_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Comporta_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Comporta_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Sumidouro_Vertedouro_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Sumidouro_Vertedouro_P" ADD CHECK ("tipoSumVert" IN(1,2,999)), ALTER COLUMN "tipoSumVert" SET DEFAULT 999;
ALTER TABLE "HID"."Sumidouro_Vertedouro_P" ADD CHECK ("causa" IN(0,1,2,3,999)), ALTER COLUMN "causa" SET DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_P" ADD CHECK ("tipoQueda" IN(0,1,2,3,998,999)), ALTER COLUMN "tipoQueda" SET DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_L" ADD CHECK ("tipoQueda" IN(0,1,2,3,998,999)), ALTER COLUMN "tipoQueda" SET DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Queda_Dagua_A" ADD CHECK ("tipoQueda" IN(0,1,2,3,998,999)), ALTER COLUMN "tipoQueda" SET DEFAULT 999;
ALTER TABLE "HID"."Fonte_Dagua_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Fonte_Dagua_P" ADD CHECK ("tipoFonteDagua" IN(0,1,2,3,999)), ALTER COLUMN "tipoFonteDagua" SET DEFAULT 999;
ALTER TABLE "HID"."Fonte_Dagua_P" ADD CHECK ("qualidAgua" IN(0,1,2,3,4,999)), ALTER COLUMN "qualidAgua" SET DEFAULT 999;
ALTER TABLE "HID"."Fonte_Dagua_P" ADD CHECK ("regime" IN(0,1,3,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "HID"."Ponto_Inicio_Drenagem_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ponto_Inicio_Drenagem_P" ADD CHECK ("nascente" IN(0,1,2,999)), ALTER COLUMN "nascente" SET DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Foz_Maritima_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Confluencia_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Corredeira_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Corredeira_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Corredeira_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_P" ADD CHECK ("materialPredominante" IN(0,4,12,13,14,15,16,18,19,20,21,22,50,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_P" ADD CHECK ("espessAlgas" IN(1,2,3,998,999)), ALTER COLUMN "espessAlgas" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_L" ADD CHECK ("materialPredominante" IN(0,4,12,13,14,15,16,18,19,20,21,22,50,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_L" ADD CHECK ("espessAlgas" IN(1,2,3,998,999)), ALTER COLUMN "espessAlgas" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_A" ADD CHECK ("materialPredominante" IN(0,4,12,13,14,15,16,18,19,20,21,22,50,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;
ALTER TABLE "HID"."Natureza_Fundo_A" ADD CHECK ("espessAlgas" IN(1,2,3,998,999)), ALTER COLUMN "espessAlgas" SET DEFAULT 999;
ALTER TABLE "HID"."Ilha_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ilha_P" ADD CHECK ("tipoIlha" IN(1,2,3,98,998,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ilha_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ilha_L" ADD CHECK ("tipoIlha" IN(1,2,3,98,998,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ilha_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Ilha_A" ADD CHECK ("tipoIlha" IN(1,2,3,98,998,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_P" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Rocha_Em_Agua_A" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_P" ADD CHECK ("tipoRecife" IN(0,1,2,20,999)), ALTER COLUMN "tipoRecife" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_P" ADD CHECK ("situaMare" IN(0,7,8,9,999)), ALTER COLUMN "situaMare" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_P" ADD CHECK ("situacaoCosta" IN(10,11,999)), ALTER COLUMN "situacaoCosta" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_L" ADD CHECK ("tipoRecife" IN(0,1,2,20,999)), ALTER COLUMN "tipoRecife" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_L" ADD CHECK ("situaMare" IN(0,7,8,9,999)), ALTER COLUMN "situaMare" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_L" ADD CHECK ("situacaoCosta" IN(10,11,999)), ALTER COLUMN "situacaoCosta" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_A" ADD CHECK ("tipoRecife" IN(0,1,2,20,999)), ALTER COLUMN "tipoRecife" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_A" ADD CHECK ("situaMare" IN(0,7,8,9,999)), ALTER COLUMN "situaMare" SET DEFAULT 999;
ALTER TABLE "HID"."Recife_A" ADD CHECK ("situacaoCosta" IN(10,11,999)), ALTER COLUMN "situacaoCosta" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_L" ADD CHECK ("tipoBanco" IN(1,2,3,4,998,999)), ALTER COLUMN "tipoBanco" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_L" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_L" ADD CHECK ("materialPredominante" IN(0,12,18,19,24,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_A" ADD CHECK ("tipoBanco" IN(1,2,3,4,998,999)), ALTER COLUMN "tipoBanco" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_A" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "HID"."Banco_Areia_A" ADD CHECK ("materialPredominante" IN(0,12,18,19,24,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L" ADD CHECK ("tipoQuebramarMolhe" IN(0,1,2,999)), ALTER COLUMN "tipoQuebramarMolhe" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L" ADD CHECK ("situaMare" IN(7,8,9,998,999)), ALTER COLUMN "situaMare" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L" ADD CHECK ("matConstr" IN(0,1,2,4,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A" ADD CHECK ("tipoQuebramarMolhe" IN(0,1,2,999)), ALTER COLUMN "tipoQuebramarMolhe" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A" ADD CHECK ("situaMare" IN(7,8,9,998,999)), ALTER COLUMN "situaMare" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A" ADD CHECK ("matConstr" IN(0,1,2,4,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "HID"."Quebramar_Molhe_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "HID"."Terreno_Sujeito_Inundacao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Area_Umida_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Area_Umida_A" ADD CHECK ("tipoAreaUmida" IN(0,3,4,999)), ALTER COLUMN "tipoAreaUmida" SET DEFAULT 999;
ALTER TABLE "HID"."Reservatorio_Hidrico_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "HID"."Reservatorio_Hidrico_A" ADD CHECK ("usoPrincipal" IN(0,1,2,3,97,99,999)), ALTER COLUMN "usoPrincipal" SET DEFAULT 999;
ALTER TABLE "REL"."Curva_Nivel_L" ADD CHECK ("depressao" IN(1,2,999)), ALTER COLUMN "depressao" SET DEFAULT 999;
ALTER TABLE "REL"."Curva_Nivel_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Curva_Nivel_L" ADD CHECK ("indice" IN(1,2,3,999)), ALTER COLUMN "indice" SET DEFAULT 999;
ALTER TABLE "REL"."Ponto_Cotado_Altimetrico_P" ADD CHECK ("cotaComprovada" IN(1,2,999)), ALTER COLUMN "cotaComprovada" SET DEFAULT 999;
ALTER TABLE "REL"."Ponto_Cotado_Altimetrico_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_P" ADD CHECK ("tipoElemNat" IN(0,1,2,3,4,5,6,7,9,10,11,12,16,17,18,99,999)), ALTER COLUMN "tipoElemNat" SET DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_L" ADD CHECK ("tipoElemNat" IN(0,1,2,3,4,5,6,7,9,10,11,12,16,17,18,99,999)), ALTER COLUMN "tipoElemNat" SET DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Elemento_Fisiog_Natural_A" ADD CHECK ("tipoElemNat" IN(0,1,2,3,4,5,6,7,9,10,11,12,16,17,18,99,999)), ALTER COLUMN "tipoElemNat" SET DEFAULT 999;
ALTER TABLE "REL"."Dolina_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Dolina_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Duna_P" ADD CHECK ("fixa" IN(1,2,999)), ALTER COLUMN "fixa" SET DEFAULT 999;
ALTER TABLE "REL"."Duna_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Duna_A" ADD CHECK ("fixa" IN(1,2,999)), ALTER COLUMN "fixa" SET DEFAULT 999;
ALTER TABLE "REL"."Duna_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Gruta_Caverna_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Gruta_Caverna_P" ADD CHECK ("tipoGrutaCaverna" IN(19,20,999)), ALTER COLUMN "tipoGrutaCaverna" SET DEFAULT 999;
ALTER TABLE "REL"."Pico_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Rocha_P" ADD CHECK ("tipoRocha" IN(21,22,23,998,999)), ALTER COLUMN "tipoRocha" SET DEFAULT 999;
ALTER TABLE "REL"."Rocha_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Rocha_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Rocha_A" ADD CHECK ("tipoRocha" IN(21,22,23,998,999)), ALTER COLUMN "tipoRocha" SET DEFAULT 999;
ALTER TABLE "REL"."Terreno_Exposto_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Terreno_Exposto_A" ADD CHECK ("tipoTerrExp" IN(0,4,12,18,23,24,999)), ALTER COLUMN "tipoTerrExp" SET DEFAULT 999;
ALTER TABLE "REL"."Terreno_Exposto_A" ADD CHECK ("causaExposicao" IN(4,5,998,999)), ALTER COLUMN "causaExposicao" SET DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_L" ADD CHECK ("tipoAlterAntrop" IN(0,24,25,26,27,28,29,999)), ALTER COLUMN "tipoAlterAntrop" SET DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "REL"."Alteracao_Fisiografica_Antropica_A" ADD CHECK ("tipoAlterAntrop" IN(0,24,25,26,27,28,29,999)), ALTER COLUMN "tipoAlterAntrop" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("canteiroDivisorio" IN(1,2,999)), ALTER COLUMN "canteiroDivisorio" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("tipoTrechoRod" IN(1,2,3,4,999)), ALTER COLUMN "tipoTrechoRod" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("jurisdicao" IN(0,1,2,3,6,999)), ALTER COLUMN "jurisdicao" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("trafego" IN(0,1,2,999)), ALTER COLUMN "trafego" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Rodoviario_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Rodoviario_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Rodoviario_P" ADD CHECK ("relacionado" IN(0,1,2,3,4,5,6,7,8,9,10,11,12,13,17,19,999)), ALTER COLUMN "relacionado" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_P" ADD CHECK ("tipoTravessia" IN(0,1,2,3,4,999)), ALTER COLUMN "tipoTravessia" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_L" ADD CHECK ("tipoTravessia" IN(0,1,2,3,4,999)), ALTER COLUMN "tipoTravessia" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P" ADD CHECK ("tipoTunel" IN(1,2,998,999)), ALTER COLUMN "tipoTunel" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_P" ADD CHECK ("posicaoPista" IN(0,12,13,97,999)), ALTER COLUMN "posicaoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L" ADD CHECK ("tipoTunel" IN(1,2,998,999)), ALTER COLUMN "tipoTunel" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Tunel_L" ADD CHECK ("posicaoPista" IN(0,12,13,97,999)), ALTER COLUMN "posicaoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_L" ADD CHECK ("matConstr" IN(0,1,2,3,4,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Galeria_Bueiro_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Entroncamento_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Entroncamento_P" ADD CHECK ("tipoEntroncamento" IN(1,2,3,4,5,99,999)), ALTER COLUMN "tipoEntroncamento" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("tipoPonte" IN(0,1,2,3,999)), ALTER COLUMN "tipoPonte" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("modalUso" IN(4,5,8,9,999)), ALTER COLUMN "modalUso" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_P" ADD CHECK ("posicaoPista" IN(0,12,13,97,999)), ALTER COLUMN "posicaoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("tipoPonte" IN(0,1,2,3,999)), ALTER COLUMN "tipoPonte" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("modalUso" IN(4,5,8,9,999)), ALTER COLUMN "modalUso" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponte_L" ADD CHECK ("posicaoPista" IN(0,12,13,97,999)), ALTER COLUMN "posicaoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("tipoPassagViad" IN(5,6,999)), ALTER COLUMN "tipoPassagViad" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("modalUso" IN(4,5,8,9,999)), ALTER COLUMN "modalUso" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_P" ADD CHECK ("posicaoPista" IN(0,12,13,97,999)), ALTER COLUMN "posicaoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("tipoPassagViad" IN(5,6,999)), ALTER COLUMN "tipoPassagViad" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("modalUso" IN(4,5,8,9,999)), ALTER COLUMN "modalUso" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Passag_Elevada_Viaduto_L" ADD CHECK ("posicaoPista" IN(0,12,13,97,999)), ALTER COLUMN "posicaoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Area_Estrut_Transportes_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_P" ADD CHECK ("modalUso" IN(4,5,6,9,14,98,999)), ALTER COLUMN "modalUso" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_A" ADD CHECK ("modalUso" IN(4,5,6,9,14,98,999)), ALTER COLUMN "modalUso" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Patio_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ADD CHECK ("tipoEdifRod" IN(0,8,9,10,12,13,14,15,99,999)), ALTER COLUMN "tipoEdifRod" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ADD CHECK ("tipoEdifRod" IN(0,8,9,10,12,13,14,15,99,999)), ALTER COLUMN "tipoEdifRod" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Rodoviaria_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Trilha_Picada_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L" ADD CHECK ("administracao" IN(0,2,3,4,6,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Ciclovia_L" ADD CHECK ("trafego" IN(0,1,2,999)), ALTER COLUMN "trafego" SET DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L" ADD CHECK ("trafego" IN(0,1,2,999)), ALTER COLUMN "trafego" SET DEFAULT 999;
ALTER TABLE "TRA"."Arruamento_L" ADD CHECK ("canteiroDivisorio" IN(1,2,999)), ALTER COLUMN "canteiroDivisorio" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P" ADD CHECK ("tipoTravessiaPed" IN(0,7,8,9,999)), ALTER COLUMN "tipoTravessiaPed" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L" ADD CHECK ("tipoTravessiaPed" IN(0,7,8,9,999)), ALTER COLUMN "tipoTravessiaPed" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Travessia_Pedestre_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("emArruamento" IN(0,1,2,999)), ALTER COLUMN "emArruamento" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("posicaoRelativa" IN(0,2,3,6,999)), ALTER COLUMN "posicaoRelativa" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("tipoTrechoFerrov" IN(0,5,6,7,8,999)), ALTER COLUMN "tipoTrechoFerrov" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("bitola" IN(0,1,2,3,4,5,6,999)), ALTER COLUMN "bitola" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("eletrificada" IN(0,1,2,999)), ALTER COLUMN "eletrificada" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("nrLinhas" IN(0,1,2,3,999)), ALTER COLUMN "nrLinhas" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("jurisdicao" IN(0,1,2,3,6,97,999)), ALTER COLUMN "jurisdicao" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("administracao" IN(0,1,2,3,6,7,97,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Ferroviario_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Ferroviario_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Ferroviario_P" ADD CHECK ("relacionado" IN(0,8,9,12,999)), ALTER COLUMN "relacionado" SET DEFAULT 999;
ALTER TABLE "TRA"."Girador_Ferroviario_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Girador_Ferroviario_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Girador_Ferroviario_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Girador_Ferroviario_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("funcaoEdifMetroFerrov" IN(0,15,16,17,18,19,20,99,999)), ALTER COLUMN "funcaoEdifMetroFerrov" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("multimodal" IN(0,1,2,999)), ALTER COLUMN "multimodal" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("funcaoEdifMetroFerrov" IN(0,15,16,17,18,19,20,99,999)), ALTER COLUMN "funcaoEdifMetroFerrov" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("multimodal" IN(0,1,2,999)), ALTER COLUMN "multimodal" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Metro_Ferroviaria_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L" ADD CHECK ("tipoCaminhoAereo" IN(12,99,999)), ALTER COLUMN "tipoCaminhoAereo" SET DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L" ADD CHECK ("tipoUsoCaminhoAer" IN(0,21,22,98,999)), ALTER COLUMN "tipoUsoCaminhoAer" SET DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Caminho_Aereo_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Funicular_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Funicular_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Funicular_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Funicular_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Funicular_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Funicular_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Cremalheira_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("tipoTrechoDuto" IN(0,1,2,3,999)), ALTER COLUMN "tipoTrechoDuto" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("matTransp" IN(0,1,2,3,4,5,6,7,8,9,29,30,31,99,999)), ALTER COLUMN "matTransp" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("setor" IN(0,1,2,3,4,999)), ALTER COLUMN "setor" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("posicaoRelativa" IN(2,3,4,5,6,999)), ALTER COLUMN "posicaoRelativa" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("matConstr" IN(0,1,2,3,4,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("situacaoEspacial" IN(12,13,99,998,999)), ALTER COLUMN "situacaoEspacial" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Duto_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Duto_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Duto_P" ADD CHECK ("relacionado" IN(1,2,3,4,5,17,999)), ALTER COLUMN "relacionado" SET DEFAULT 999;
ALTER TABLE "TRA"."Area_Duto_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_P" ADD CHECK ("tipoLocalCrit" IN(0,1,2,3,4,5,6,7,999)), ALTER COLUMN "tipoLocalCrit" SET DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_L" ADD CHECK ("tipoLocalCrit" IN(0,1,2,3,4,5,6,7,999)), ALTER COLUMN "tipoLocalCrit" SET DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Local_Critico_A" ADD CHECK ("tipoLocalCrit" IN(0,1,2,3,4,5,6,7,999)), ALTER COLUMN "tipoLocalCrit" SET DEFAULT 999;
ALTER TABLE "TRA"."Condutor_Hidrico_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Condutor_Hidrico_L" ADD CHECK ("tipoCondutor" IN(0,2,4,999)), ALTER COLUMN "tipoCondutor" SET DEFAULT 999;

ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("tipoPista" IN(9,10,11,999)), ALTER COLUMN "tipoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("usoPista" IN(0,6,11,12,13,999)), ALTER COLUMN "usoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("homologacao" IN(0,1,2,999)), ALTER COLUMN "homologacao" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("tipoPista" IN(9,10,11,999)), ALTER COLUMN "tipoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("usoPista" IN(0,6,11,12,13,999)), ALTER COLUMN "usoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("homologacao" IN(0,1,2,999)), ALTER COLUMN "homologacao" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("tipoPista" IN(9,10,11,999)), ALTER COLUMN "tipoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("usoPista" IN(0,6,11,12,13,999)), ALTER COLUMN "usoPista" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("homologacao" IN(0,1,2,999)), ALTER COLUMN "homologacao" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Pista_Ponto_Pouso_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ADD CHECK ("tipoEdifAero" IN(0,15,26,27,28,29,99,999)), ALTER COLUMN "tipoEdifAero" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ADD CHECK ("tipoEdifAero" IN(0,15,26,27,28,29,99,999)), ALTER COLUMN "tipoEdifAero" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Aeroportuaria_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Hidroviario_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Hidroviario_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Hidroviario_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Trecho_Hidroviario_L" ADD CHECK ("regime" IN(0,1,6,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Hidroviario_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Ponto_Hidroviario_P" ADD CHECK ("relacionado" IN(12,13,14,16,17,24,19,21,22,23,999)), ALTER COLUMN "relacionado" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_L" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Eclusa_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ADD CHECK ("tipoEdifPort" IN(0,15,26,27,32,33,34,35,36,37,99,999)), ALTER COLUMN "tipoEdifPort" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ADD CHECK ("tipoEdifPort" IN(0,15,26,27,32,33,34,35,36,37,99,999)), ALTER COLUMN "tipoEdifPort" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Edif_Constr_Portuaria_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P" ADD CHECK ("tipoAtracad" IN(0,38,39,40,41,42,43,44,999)), ALTER COLUMN "tipoAtracad" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L" ADD CHECK ("tipoAtracad" IN(0,38,39,40,41,42,43,44,999)), ALTER COLUMN "tipoAtracad" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A" ADD CHECK ("tipoAtracad" IN(0,38,39,40,41,42,43,44,999)), ALTER COLUMN "tipoAtracad" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Atracadouro_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_P" ADD CHECK ("destinacaoFundeadouro" IN(0,10,11,12,13,99,999)), ALTER COLUMN "destinacaoFundeadouro" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_L" ADD CHECK ("destinacaoFundeadouro" IN(0,10,11,12,13,99,999)), ALTER COLUMN "destinacaoFundeadouro" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_L" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_A" ADD CHECK ("destinacaoFundeadouro" IN(0,10,11,12,13,99,999)), ALTER COLUMN "destinacaoFundeadouro" SET DEFAULT 999;
ALTER TABLE "TRA"."Fundeadouro_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_P" ADD CHECK ("tipoObst" IN(4,5,998,999)), ALTER COLUMN "tipoObst" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_P" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_L" ADD CHECK ("tipoObst" IN(4,5,998,999)), ALTER COLUMN "tipoObst" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_L" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_A" ADD CHECK ("tipoObst" IN(4,5,998,999)), ALTER COLUMN "tipoObst" SET DEFAULT 999;
ALTER TABLE "TRA"."Obstaculo_Navegacao_A" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "TRA"."Sinalizacao_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Sinalizacao_P" ADD CHECK ("tipoSinal" IN(0,1,2,3,4,5,6,999)), ALTER COLUMN "tipoSinal" SET DEFAULT 999;
ALTER TABLE "TRA"."Sinalizacao_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Sinalizacao_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Faixa_Seguranca_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Passagem_Nivel_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A" ADD CHECK ("administracao" IN(0,1,2,3,6,7,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "TRA"."Posto_Combustivel_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ENC"."Area_Energia_Eletrica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P" ADD CHECK ("tipoEdifEnergia" IN(0,1,2,3,4,5,99,999)), ALTER COLUMN "tipoEdifEnergia" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A" ADD CHECK ("tipoEdifEnergia" IN(0,1,2,3,4,5,99,999)), ALTER COLUMN "tipoEdifEnergia" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Energia_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" ADD CHECK ("tipoEstGerad" IN(0,5,6,7,99,999)), ALTER COLUMN "tipoEstGerad" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_P" ADD CHECK ("destEnergElet" IN(0,1,2,3,4,5,999)), ALTER COLUMN "destEnergElet" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" ADD CHECK ("tipoEstGerad" IN(0,5,6,7,99,999)), ALTER COLUMN "tipoEstGerad" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_L" ADD CHECK ("destEnergElet" IN(0,1,2,3,4,5,999)), ALTER COLUMN "destEnergElet" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" ADD CHECK ("tipoEstGerad" IN(0,5,6,7,99,999)), ALTER COLUMN "tipoEstGerad" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Est_Gerad_Energia_Eletrica_A" ADD CHECK ("destEnergElet" IN(0,1,2,3,4,5,999)), ALTER COLUMN "destEnergElet" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Hidreletrica_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("tipoCombustivel" IN(0,1,3,5,33,98,99,999)), ALTER COLUMN "tipoCombustivel" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("combRenovavel" IN(0,1,2,998,999)), ALTER COLUMN "combRenovavel" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("tipoMaqTermica" IN(0,1,2,3,4,998,999)), ALTER COLUMN "tipoMaqTermica" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_P" ADD CHECK ("geracao" IN(0,1,2,998,999)), ALTER COLUMN "geracao" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("tipoCombustivel" IN(0,1,3,5,33,98,99,999)), ALTER COLUMN "tipoCombustivel" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("combRenovavel" IN(0,1,2,998,999)), ALTER COLUMN "combRenovavel" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("tipoMaqTermica" IN(0,1,2,3,4,998,999)), ALTER COLUMN "tipoMaqTermica" SET DEFAULT 999;
ALTER TABLE "ENC"."Termeletrica_A" ADD CHECK ("geracao" IN(0,1,2,998,999)), ALTER COLUMN "geracao" SET DEFAULT 999;
ALTER TABLE "ENC"."Ponto_Trecho_Energia_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Ponto_Trecho_Energia_P" ADD CHECK ("tipoPtoEnergia" IN(0,1,2,3,4,7,9,999)), ALTER COLUMN "tipoPtoEnergia" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L" ADD CHECK ("especie" IN(0,2,3,999)), ALTER COLUMN "especie" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L" ADD CHECK ("posicaoRelativa" IN(2,3,4,5,6,999)), ALTER COLUMN "posicaoRelativa" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Energia_L" ADD CHECK ("emDuto" IN(1,2,998,999)), ALTER COLUMN "emDuto" SET DEFAULT 999;
ALTER TABLE "ENC"."Zona_Linhas_Energia_Comunicacao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P" ADD CHECK ("ovgd" IN(0,1,2,998,999)), ALTER COLUMN "ovgd" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Energia_P" ADD CHECK ("tipoTorre" IN(0,1,2,998,999)), ALTER COLUMN "tipoTorre" SET DEFAULT 999;
ALTER TABLE "ENC"."Area_Comunicacao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P" ADD CHECK ("modalidade" IN(0,1,2,3,4,5,99,999)), ALTER COLUMN "modalidade" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_P" ADD CHECK ("tipoEdifComunic" IN(0,1,2,3,4,999)), ALTER COLUMN "tipoEdifComunic" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A" ADD CHECK ("modalidade" IN(0,1,2,3,4,5,99,999)), ALTER COLUMN "modalidade" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ENC"."Edif_Comunic_A" ADD CHECK ("tipoEdifComunic" IN(0,1,2,3,4,999)), ALTER COLUMN "tipoEdifComunic" SET DEFAULT 999;
ALTER TABLE "ENC"."Antena_Comunic_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Antena_Comunic_P" ADD CHECK ("posicaoRelEdific" IN(14,17,18,999)), ALTER COLUMN "posicaoRelEdific" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P" ADD CHECK ("posicaoRelEdific" IN(14,17,18,999)), ALTER COLUMN "posicaoRelEdific" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Torre_Comunic_P" ADD CHECK ("ovgd" IN(0,1,2,998,999)), ALTER COLUMN "ovgd" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("tipoTrechoComunic" IN(0,4,6,7,99,999)), ALTER COLUMN "tipoTrechoComunic" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("posicaoRelativa" IN(0,2,3,4,5,6,998,999)), ALTER COLUMN "posicaoRelativa" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("matConstr" IN(0,25,26,99,998,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ENC"."Trecho_Comunic_L" ADD CHECK ("emDuto" IN(1,2,998,999)), ALTER COLUMN "emDuto" SET DEFAULT 999;
ALTER TABLE "ENC"."Grupo_Transformadores_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ENC"."Grupo_Transformadores_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Area_Ensino_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_P" ADD CHECK ("tipoClasseCnae" IN(0,16,17,18,19,20,21,22,23,24,25,98,99,999)), ALTER COLUMN "tipoClasseCnae" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Ensino_A" ADD CHECK ("tipoClasseCnae" IN(0,16,17,18,19,20,21,22,23,24,25,98,99,999)), ALTER COLUMN "tipoClasseCnae" SET DEFAULT 999;
ALTER TABLE "EDU"."Area_Religiosa_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P" ADD CHECK ("tipoEdifRelig" IN(0,1,2,3,4,5,6,7,99,999)), ALTER COLUMN "tipoEdifRelig" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P" ADD CHECK ("ensino" IN(0,1,2,999)), ALTER COLUMN "ensino" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A" ADD CHECK ("tipoEdifRelig" IN(0,1,2,3,4,5,6,7,99,999)), ALTER COLUMN "tipoEdifRelig" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A" ADD CHECK ("ensino" IN(0,1,2,999)), ALTER COLUMN "ensino" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Religiosa_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Area_Lazer_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_P" ADD CHECK ("tipoEdifLazer" IN(0,1,2,3,4,5,6,7,8,9,99,999)), ALTER COLUMN "tipoEdifLazer" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Lazer_A" ADD CHECK ("tipoEdifLazer" IN(0,1,2,3,4,5,6,7,8,9,99,999)), ALTER COLUMN "tipoEdifLazer" SET DEFAULT 999;
ALTER TABLE "EDU"."Piscina_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Piscina_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Piscina_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_P" ADD CHECK ("tipoCampoQuadra" IN(0,1,2,3,4,5,6,7,99,999)), ALTER COLUMN "tipoCampoQuadra" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Campo_Quadra_A" ADD CHECK ("tipoCampoQuadra" IN(0,1,2,3,4,5,6,7,99,999)), ALTER COLUMN "tipoCampoQuadra" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ADD CHECK ("tipoEdifTurist" IN(0,9,10,11,12,13,99,999)), ALTER COLUMN "tipoEdifTurist" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ADD CHECK ("ovgd" IN(0,1,2,998,999)), ALTER COLUMN "ovgd" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ADD CHECK ("tipoEdifTurist" IN(0,9,10,11,12,13,99,999)), ALTER COLUMN "tipoEdifTurist" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ADD CHECK ("ovgd" IN(0,1,2,998,999)), ALTER COLUMN "ovgd" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Edif_Const_Turistica_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Area_Ruinas_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Ruina_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Ruina_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Pista_Competicao_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Pista_Competicao_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Pista_Competicao_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Pista_Competicao_L" ADD CHECK ("tipoPista" IN(0,1,2,3,4,5,98,99,998,999)), ALTER COLUMN "tipoPista" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Arquibancada_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "EDU"."Coreto_Tribuna_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Area_Comerc_Serv_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ADD CHECK ("tipoEdifComercServ" IN(0,3,4,5,6,7,8,99,999)), ALTER COLUMN "tipoEdifComercServ" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_P" ADD CHECK ("finalidade" IN(0,1,2,98,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ADD CHECK ("tipoEdifComercServ" IN(0,3,4,5,6,7,8,99,999)), ALTER COLUMN "tipoEdifComercServ" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Comerc_Serv_A" ADD CHECK ("finalidade" IN(0,1,2,98,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("tipoDepGeral" IN(0,8,9,10,11,32,99,999)), ALTER COLUMN "tipoDepGeral" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("tipoExposicao" IN(0,3,4,5,99,999)), ALTER COLUMN "tipoExposicao" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("tipoProdutoResiduo" IN(0,3,5,6,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,41,98,99,999)), ALTER COLUMN "tipoProdutoResiduo" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("tipoConteudo" IN(0,1,2,3,999)), ALTER COLUMN "tipoConteudo" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("unidadeVolume" IN(0,1,2,999)), ALTER COLUMN "unidadeVolume" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_P" ADD CHECK ("tratamento" IN(0,1,2,97,999)), ALTER COLUMN "tratamento" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("tipoDepGeral" IN(0,8,9,10,11,32,99,999)), ALTER COLUMN "tipoDepGeral" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("tipoExposicao" IN(0,3,4,5,99,999)), ALTER COLUMN "tipoExposicao" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("tipoProdutoResiduo" IN(0,3,5,6,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,41,98,99,999)), ALTER COLUMN "tipoProdutoResiduo" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("tipoConteudo" IN(0,1,2,3,999)), ALTER COLUMN "tipoConteudo" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("unidadeVolume" IN(0,1,2,999)), ALTER COLUMN "unidadeVolume" SET DEFAULT 999;
ALTER TABLE "ECO"."Deposito_Geral_A" ADD CHECK ("tratamento" IN(0,1,2,97,999)), ALTER COLUMN "tratamento" SET DEFAULT 999;
ALTER TABLE "ECO"."Area_Industrial_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P" ADD CHECK ("chamine" IN(1,2,999)), ALTER COLUMN "chamine" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_P" ADD CHECK ("tipoDivisaoCnae" IN(0,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,45,99,999)), ALTER COLUMN "tipoDivisaoCnae" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A" ADD CHECK ("chamine" IN(1,2,999)), ALTER COLUMN "chamine" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Industrial_A" ADD CHECK ("tipoDivisaoCnae" IN(0,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,45,99,999)), ALTER COLUMN "tipoDivisaoCnae" SET DEFAULT 999;
ALTER TABLE "ECO"."Area_Ext_Mineral_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("tipoSecaoCnae" IN(0,1,99,999)), ALTER COLUMN "tipoSecaoCnae" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("tipoExtMin" IN(0,1,4,5,6,7,8,99,999)), ALTER COLUMN "tipoExtMin" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("tipoProdutoResiduo" IN(0,3,5,18,22,23,24,25,26,27,32,33,34,35,37,38,39,40,42,43,99,999)), ALTER COLUMN "tipoProdutoResiduo" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("tipoPocoMina" IN(0,2,3,97,999)), ALTER COLUMN "tipoPocoMina" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("procExtracao" IN(0,1,2,999)), ALTER COLUMN "procExtracao" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("formaExtracao" IN(0,5,6,999)), ALTER COLUMN "formaExtracao" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_P" ADD CHECK ("atividade" IN(0,9,10,999)), ALTER COLUMN "atividade" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("tipoSecaoCnae" IN(0,1,99,999)), ALTER COLUMN "tipoSecaoCnae" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("tipoExtMin" IN(0,1,4,5,6,7,8,99,999)), ALTER COLUMN "tipoExtMin" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("tipoProdutoResiduo" IN(0,3,5,18,22,23,24,25,26,27,32,33,34,35,37,38,39,40,42,43,99,999)), ALTER COLUMN "tipoProdutoResiduo" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("tipoPocoMina" IN(0,2,3,97,999)), ALTER COLUMN "tipoPocoMina" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("procExtracao" IN(0,1,2,999)), ALTER COLUMN "procExtracao" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("formaExtracao" IN(0,5,6,999)), ALTER COLUMN "formaExtracao" SET DEFAULT 999;
ALTER TABLE "ECO"."Ext_Mineral_A" ADD CHECK ("atividade" IN(0,9,10,999)), ALTER COLUMN "atividade" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_P" ADD CHECK ("tipoDivisaoCnae" IN(0,10,11,13,14,99,999)), ALTER COLUMN "tipoDivisaoCnae" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Ext_Mineral_A" ADD CHECK ("tipoDivisaoCnae" IN(0,10,11,13,14,99,999)), ALTER COLUMN "tipoDivisaoCnae" SET DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_P" ADD CHECK ("tipoPlataforma" IN(0,3,5,98,999)), ALTER COLUMN "tipoPlataforma" SET DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Plataforma_A" ADD CHECK ("tipoPlataforma" IN(0,3,5,98,999)), ALTER COLUMN "tipoPlataforma" SET DEFAULT 999;
ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Area_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("destinadoA" IN(0,5,18,34,35,36,37,38,39,40,41,43,44,99,999)), ALTER COLUMN "destinadoA" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" ADD CHECK ("tipoEdifAgropec" IN(0,12,13,14,15,16,17,18,99,999)), ALTER COLUMN "tipoEdifAgropec" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_P" ADD CHECK ("matConstr" IN(0,1,3,4,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("tipoEdifAgropec" IN(0,12,13,14,15,16,17,18,99,999)), ALTER COLUMN "tipoEdifAgropec" SET DEFAULT 999;
ALTER TABLE "ECO"."Edif_Agropec_Ext_Vegetal_Pesca_A" ADD CHECK ("matConstr" IN(0,1,3,4,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P" ADD CHECK ("tipoEquipAgropec" IN(0,1,99,999)), ALTER COLUMN "tipoEquipAgropec" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_P" ADD CHECK ("matConstr" IN(0,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L" ADD CHECK ("tipoEquipAgropec" IN(0,1,99,999)), ALTER COLUMN "tipoEquipAgropec" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_L" ADD CHECK ("matConstr" IN(0,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A" ADD CHECK ("tipoEquipAgropec" IN(0,1,99,999)), ALTER COLUMN "tipoEquipAgropec" SET DEFAULT 999;
ALTER TABLE "ECO"."Equip_Agropec_A" ADD CHECK ("matConstr" IN(0,3,5,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LOC"."Area_Urbana_Isolada_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Area_Urbana_Isolada_A" ADD CHECK ("tipoAssociado" IN(0,1,2,3,999)), ALTER COLUMN "tipoAssociado" SET DEFAULT 999;
ALTER TABLE "LOC"."Area_Edificada_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_P" ADD CHECK ("coletiva" IN(0,1,2,999)), ALTER COLUMN "coletiva" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_P" ADD CHECK ("isolada" IN(0,1,2,999)), ALTER COLUMN "isolada" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_A" ADD CHECK ("coletiva" IN(0,1,2,999)), ALTER COLUMN "coletiva" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_A" ADD CHECK ("isolada" IN(0,1,2,999)), ALTER COLUMN "isolada" SET DEFAULT 999;
ALTER TABLE "LOC"."Hab_Indigena_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LOC"."Area_Habitacional_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "LOC"."Edif_Habitacional_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LOC"."Nome_Local_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Posic_Geo_Localidade_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "LOC"."Edificacao_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("proximidade" IN(0,14,15,16,999)), ALTER COLUMN "proximidade" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("tipoRef" IN(1,2,3,4,999)), ALTER COLUMN "tipoRef" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("tipoPtoRefGeodTopo" IN(0,1,2,3,4,5,6,7,8,99,999)), ALTER COLUMN "tipoPtoRefGeodTopo" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("rede" IN(0,2,3,14,15,999)), ALTER COLUMN "rede" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("sistemaGeodesico" IN(1,2,3,4,5,6,999)), ALTER COLUMN "sistemaGeodesico" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("referencialAltim" IN(1,2,3,4,6,999)), ALTER COLUMN "referencialAltim" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("referencialGrav" IN(0,1,2,3,4,97,999)), ALTER COLUMN "referencialGrav" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Ref_Geod_Topo_P" ADD CHECK ("situacaoMarco" IN(0,1,2,3,4,5,6,7,999)), ALTER COLUMN "situacaoMarco" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P" ADD CHECK ("tipoRef" IN(1,2,3,999)), ALTER COLUMN "tipoRef" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P" ADD CHECK ("tipoPtoControle" IN(9,12,13,99,999)), ALTER COLUMN "tipoPtoControle" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P" ADD CHECK ("materializado" IN(0,1,2,999)), ALTER COLUMN "materializado" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P" ADD CHECK ("sistemaGeodesico" IN(1,2,3,4,5,6,999)), ALTER COLUMN "sistemaGeodesico" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Controle_P" ADD CHECK ("referencialAltim" IN(1,2,3,4,6,999)), ALTER COLUMN "referencialAltim" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Est_Med_Fenomenos_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "PTO"."Pto_Est_Med_Fenomenos_P" ADD CHECK ("tipoPtoEstMed" IN(0,1,2,3,4,5,6,7,8,9,10,11,12,999)), ALTER COLUMN "tipoPtoEstMed" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "PTO"."Edif_Constr_Est_Med_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "PTO"."Area_Est_Med_Fenomenos_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Marco_De_Limite_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Marco_De_Limite_P" ADD CHECK ("tipoMarcoLim" IN(1,2,3,99,999)), ALTER COLUMN "tipoMarcoLim" SET DEFAULT 999;
ALTER TABLE "LIM"."Marco_De_Limite_P" ADD CHECK ("sistemaGeodesico" IN(1,2,3,4,5,6,999)), ALTER COLUMN "sistemaGeodesico" SET DEFAULT 999;
ALTER TABLE "LIM"."Marco_De_Limite_P" ADD CHECK ("referencialAltim" IN(1,2,3,4,5,999)), ALTER COLUMN "referencialAltim" SET DEFAULT 999;
ALTER TABLE "LIM"."Linha_De_Limite_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Linha_De_Limite_L" ADD CHECK ("coincideComDentroDe" IN(0,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Politico_Administrativo_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Politico_Administrativo_L" ADD CHECK ("coincideComDentroDe" IN(0
,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Politico_Administrativo_L" ADD CHECK ("tipoLimPol" IN(1,2,3,999)), ALTER COLUMN "tipoLimPol" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L" ADD CHECK ("coincideComDentroDe" IN(0,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Intra_Municipal_Administrativo_L" ADD CHECK ("tipoLimIntraMun" IN(1,2,3,4,5,999)), ALTER COLUMN "tipoLimIntraMun" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Operacional_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Operacional_L" ADD CHECK ("coincideComDentroDe" IN(2,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Operacional_L" ADD CHECK ("tipoLimOper" IN(0,1,2,3,4,5,6,999)), ALTER COLUMN "tipoLimOper" SET DEFAULT 999;
ALTER TABLE "LIM"."Outros_Limites_Oficiais_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Outros_Limites_Oficiais_L" ADD CHECK ("coincideComDentroDe" IN(0,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Outros_Limites_Oficiais_L" ADD CHECK ("tipoOutLimOfic" IN(0,1,2,3,4,5,6,99,999)), ALTER COLUMN "tipoOutLimOfic" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Particular_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Particular_L" ADD CHECK ("coincideComDentroDe" IN(0,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_De_Propriedade_Particular_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Area_Especial_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Area_Especial_L" ADD CHECK ("coincideComDentroDe" IN(0,3,4,5,6,7,8,96,999)), ALTER COLUMN "coincideComDentroDe" SET DEFAULT 999;
ALTER TABLE "LIM"."Limite_Area_Especial_L" ADD CHECK ("tipoLimAreaEsp" IN(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,99,999)), ALTER COLUMN "tipoLimAreaEsp" SET DEFAULT 999;
ALTER TABLE "LIM"."Pais_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Federacao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Municipio_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Distrito_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Sub_Distrito_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Regiao_Administrativa_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Bairro_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_De_Litigio_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Delimitacao_Fisica_L" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Delimitacao_Fisica_L" ADD CHECK ("tipoDelimFis" IN(0,1,2,999)), ALTER COLUMN "tipoDelimFis" SET DEFAULT 999;
ALTER TABLE "LIM"."Delimitacao_Fisica_L" ADD CHECK ("matConstr" IN(0,1,4,5,6,7,8,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "LIM"."Delimitacao_Fisica_L" ADD CHECK ("eletrificada" IN(0,1,2,999)), ALTER COLUMN "eletrificada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_P" ADD CHECK ("tipoUnidUsoSust" IN(1,2,3,4,5,6,7,999)), ALTER COLUMN "tipoUnidUsoSust" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Uso_SustentaveL_A" ADD CHECK ("tipoUnidUsoSust" IN(1,2,3,4,5,6,7,999)), ALTER COLUMN "tipoUnidUsoSust" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_P" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_P" ADD CHECK ("tipoUnidProtInteg" IN(1,2,3,4,5,999)), ALTER COLUMN "tipoUnidProtInteg" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_A" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Protecao_Integral_A" ADD CHECK ("tipoUnidProtInteg" IN(1,2,3,4,5,999)), ALTER COLUMN "tipoUnidProtInteg" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_P" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Unidade_Conservacao_Nao_Snuc_A" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_P" ADD CHECK ("tipoOutUnidProt" IN(1,2,3,4,5,6,7,8,9,999)), ALTER COLUMN "tipoOutUnidProt" SET DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_P" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_A" ADD CHECK ("tipoOutUnidProt" IN(1,2,3,4,5,6,7,8,9,999)), ALTER COLUMN "tipoOutUnidProt" SET DEFAULT 999;
ALTER TABLE "LIM"."Outras_Unid_Protegidas_A" ADD CHECK ("administracao" IN(0,1,2,3,5,999)), ALTER COLUMN "administracao" SET DEFAULT 999;
ALTER TABLE "LIM"."Terra_Publica_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Terra_Publica_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_P" ADD CHECK ("tipoAreaUsoComun" IN(1,2,999)), ALTER COLUMN "tipoAreaUsoComun" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_Uso_Comunitario_A" ADD CHECK ("tipoAreaUsoComun" IN(1,2,999)), ALTER COLUMN "tipoAreaUsoComun" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Area_Desenvolvimento_Controle_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_P" ADD CHECK ("situacaoJuridica" IN(1,2,3,4,998,999)), ALTER COLUMN "situacaoJuridica" SET DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "LIM"."Terra_Indigena_A" ADD CHECK ("situacaoJuridica" IN(1,2,3,4,998,999)), ALTER COLUMN "situacaoJuridica" SET DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Civil_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Civil_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("tipoEdifCivil" IN(0,1,2,3,4,5,6,7,8,9,22,99,999)), ALTER COLUMN "tipoEdifCivil" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("tipoUsoEdif" IN(0,1,2,999)), ALTER COLUMN "tipoUsoEdif" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_P" ADD CHECK ("tipoEdifCivil" IN(0,1,2,3,4,5,6,7,8,9,22,99,999)), ALTER COLUMN "tipoEdifCivil" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Civil_A" ADD CHECK ("tipoUsoEdif" IN(0,1,2,999)), ALTER COLUMN "tipoUsoEdif" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_P" ADD CHECK ("tipoPostoFisc" IN(0,10,11,98,99,999)), ALTER COLUMN "tipoPostoFisc" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_A" ADD CHECK ("tipoPostoFisc" IN(0,10,11,98,99,999)), ALTER COLUMN "tipoPostoFisc" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Fiscal_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Area_Pub_Militar_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ADD CHECK ("tipoEdifMil" IN(0,12,13,14,15,16,17,18,19,99,999)), ALTER COLUMN "tipoEdifMil" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_P" ADD CHECK ("tipoUsoEdif" IN(0,1,2,999)), ALTER COLUMN "tipoUsoEdif" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ADD CHECK ("tipoEdifMil" IN(0,12,13,14,15,16,17,18,19,99,999)), ALTER COLUMN "tipoEdifMil" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ADM"."Edif_Pub_Militar_A" ADD CHECK ("tipoUsoEdif" IN(0,1,2,999)), ALTER COLUMN "tipoUsoEdif" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_P" ADD CHECK ("tipoPostoPol" IN(0,20,21,999)), ALTER COLUMN "tipoPostoPol" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_A" ADD CHECK ("tipoPostoPol" IN(0,20,21,999)), ALTER COLUMN "tipoPostoPol" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ADM"."Posto_Pol_Rod_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "SAU"."Area_Saude_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P" ADD CHECK ("tipoClasseCnae" IN(0,26,27,28,29,30,31,98,99,999)), ALTER COLUMN "tipoClasseCnae" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P" ADD CHECK ("matConstr" IN(0,1,2,3,5,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_P" ADD CHECK ("nivelAtencao" IN(5,6,7,998,999)), ALTER COLUMN "nivelAtencao" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A" ADD CHECK ("tipoClasseCnae" IN(0,26,27,28,29,30,31,98,99,999)), ALTER COLUMN "tipoClasseCnae" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A" ADD CHECK ("matConstr" IN(0,1,2,3,5,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Saude_A" ADD CHECK ("nivelAtencao" IN(5,6,7,998,999)), ALTER COLUMN "nivelAtencao" SET DEFAULT 999;
ALTER TABLE "SAU"."Area_Servico_Social_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P" ADD CHECK ("tipoClasseCnae" IN(0,32,33,98,99,999)), ALTER COLUMN "tipoClasseCnae" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A" ADD CHECK ("tipoClasseCnae" IN(0,32,33,98,99,999)), ALTER COLUMN "tipoClasseCnae" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "SAU"."Edif_Servico_Social_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Area_Abast_Agua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P" ADD CHECK ("tipoEdifAbast" IN(0,1,2,3,98,99,999)), ALTER COLUMN "tipoEdifAbast" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A" ADD CHECK ("tipoEdifAbast" IN(0,1,2,3,98,99,999)), ALTER COLUMN "tipoEdifAbast" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Abast_Agua_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("tipoDepAbast" IN(0,1,2,3,99,999)), ALTER COLUMN "tipoDepAbast" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("situacaoAgua" IN(0,6,7,999)), ALTER COLUMN "situacaoAgua" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("construcao" IN(1,2,998,999)), ALTER COLUMN "construcao" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("finalidade" IN(2,3,4,998,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("tipoDepAbast" IN(0,1,2,3,99,999)), ALTER COLUMN "tipoDepAbast" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("situacaoAgua" IN(0,6,7,999)), ALTER COLUMN "situacaoAgua" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("construcao" IN(1,2,998,999)), ALTER COLUMN "construcao" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("finalidade" IN(2,3,4,998,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Abast_Agua_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Area_Saneamento_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P" ADD CHECK ("tipoEdifSaneam" IN(0,3,5,6,7,99,999)), ALTER COLUMN "tipoEdifSaneam" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;

ALTER TABLE "ASB"."Edif_Saneamento_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_A" ADD CHECK ("tipoEdifSaneam" IN(0,3,5,6,7,99,999)), ALTER COLUMN "tipoEdifSaneam" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Edif_Saneamento_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,5,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;

ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("tipoDepSaneam" IN(0,1,4,5,6,99,999)), ALTER COLUMN "tipoDepSaneam" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("construcao" IN(1,2,97,999)), ALTER COLUMN "construcao" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("matConstr" IN(0,1,2,3,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("finalidade" IN(0,2,8,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("residuo" IN(0,1,2,999)), ALTER COLUMN "residuo" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_P" ADD CHECK ("tipoResiduo" IN(0,9,12,13,14,15,16,98,99,999)), ALTER COLUMN "tipoResiduo" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("tipoDepSaneam" IN(0,1,4,5,6,99,999)), ALTER COLUMN "tipoDepSaneam" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("construcao" IN(1,2,97,999)), ALTER COLUMN "construcao" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("matConstr" IN(0,1,2,3,4,97,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("finalidade" IN(0,2,8,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("situacaoFisica" IN(0,1,2,3,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("residuo" IN(0,1,2,999)), ALTER COLUMN "residuo" SET DEFAULT 999;
ALTER TABLE "ASB"."Dep_Saneamento_A" ADD CHECK ("tipoResiduo" IN(0,9,12,13,14,15,16,98,99,999)), ALTER COLUMN "tipoResiduo" SET DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_P" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_P" ADD CHECK ("tipoCemiterio" IN(0,1,2,3,4,5,98,99,999)), ALTER COLUMN "tipoCemiterio" SET DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_P" ADD CHECK ("denominacaoAssociada" IN(5,6,7,99,998,999)), ALTER COLUMN "denominacaoAssociada" SET DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_A" ADD CHECK ("tipoCemiterio" IN(0,1,2,3,4,5,98,99,999)), ALTER COLUMN "tipoCemiterio" SET DEFAULT 999;
ALTER TABLE "ASB"."Cemiterio_A" ADD CHECK ("denominacaoAssociada" IN(5,6,7,99,998,999)), ALTER COLUMN "denominacaoAssociada" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Area_Contato_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Area_Contato_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Area_Contato_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Area_Contato_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("tipoLavoura" IN(0,1,2,3,999)), ALTER COLUMN "tipoLavoura" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("finalidade" IN(0,1,2,3,99,998,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("terreno" IN(1,2,3,998,999)), ALTER COLUMN "terreno" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,3,4,98,998,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Cultivada_A" ADD CHECK ("cultivoPredominante" IN(1,2,3,4,42,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,96,98,99,999)), ALTER COLUMN "cultivoPredominante" SET DEFAULT 999;
ALTER TABLE "VEG"."Mangue_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Mangue_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Mangue_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Mangue_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A" ADD CHECK ("tipoBrejoPantano" IN(0,1,2,999)), ALTER COLUMN "tipoBrejoPantano" SET DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Brejo_Pantano_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Restinga_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Restinga_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Restinga_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Veg_Restinga_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Campinarana_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Campinarana_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Campinarana_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Campinarana_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A" ADD CHECK ("caracteristicaFloresta" IN(0,1,2,3,999)), ALTER COLUMN "caracteristicaFloresta" SET DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A" ADD CHECK ("especiePredominante" IN(10,11,12,17,27,41,96,98,999)), ALTER COLUMN "especiePredominante" SET DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Floresta_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A" ADD CHECK ("tipoMacChav" IN(0,1,2,999)), ALTER COLUMN "tipoMacChav" SET DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Macega_Chavascal_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A" ADD CHECK ("tipoCerr" IN(0,1,2,999)), ALTER COLUMN "tipoCerr" SET DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Cerrado_Cerradao_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Caatinga_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Caatinga_A" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "VEG"."Caatinga_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Caatinga_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Estepe_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Estepe_A" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "VEG"."Estepe_A" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "VEG"."Campo_A" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "VEG"."Campo_A" ADD CHECK ("tipoCampo" IN(0,1,2,999)), ALTER COLUMN "tipoCampo" SET DEFAULT 999;
ALTER TABLE "VEG"."Campo_A" ADD CHECK ("ocorrenciaEm" IN(5,6,7,8,13,14,19,15,96,998,999)), ALTER COLUMN "ocorrenciaEm" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Barragem_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Barragem_C" ADD CHECK ("matConstr" IN(0,1,2,4,23,99,999)), ALTER COLUMN "matConstr" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Barragem_C" ADD CHECK ("usoPrincipal" IN(0,1,2,3,97,99,999)), ALTER COLUMN "usoPrincipal" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Barragem_C" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Barragem_C" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Massa_Dagua_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Massa_Dagua_C" ADD CHECK ("tipoMassaDagua" IN(0,3,4,5,6,7,8,10,99,999)), ALTER COLUMN "tipoMassaDagua" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Massa_Dagua_C" ADD CHECK ("regime" IN(1,2,3,4,5,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Massa_Dagua_C" ADD CHECK ("salinidade" IN(0,1,2,999)), ALTER COLUMN "salinidade" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Trecho_Massa_Dagua_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Trecho_Massa_Dagua_C" ADD CHECK ("regime" IN(1,2,3,4,5,999)), ALTER COLUMN "regime" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Trecho_Massa_Dagua_C" ADD CHECK ("salinidade" IN(0,1,2,999)), ALTER COLUMN "salinidade" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Area_Edificada_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Alteracao_Fisiografica_Antropica_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Alteracao_Fisiografica_Antropica_C" ADD CHECK ("tipoAlterAntrop" IN(0,24,25,26,27,28,29,999)), ALTER COLUMN "tipoAlterAntrop" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Rocha_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Terreno_Exposto_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Terreno_Exposto_C" ADD CHECK ("tipoTerrExp" IN(0,4,12,18,23,24,999)), ALTER COLUMN "tipoTerrExp" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Terreno_Exposto_C" ADD CHECK ("causaExposicao" IN(4,5,998,999)), ALTER COLUMN "causaExposicao" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("tipoPista" IN(9,10,11,999)), ALTER COLUMN "tipoPista" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("revestimento" IN(0,1,2,3,4,999)), ALTER COLUMN "revestimento" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("usoPista" IN(0,6,11,12,13,999)), ALTER COLUMN "usoPista" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("homologacao" IN(0,1,2,999)), ALTER COLUMN "homologacao" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("operacional" IN(0,1,2,999)), ALTER COLUMN "operacional" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Pista_Ponto_Pouso_C" ADD CHECK ("situacaoFisica" IN(0,1,2,3,4,5,999)), ALTER COLUMN "situacaoFisica" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Brejo_Pantano_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Brejo_Pantano_C" ADD CHECK ("tipoBrejoPantano" IN(0,1,2,999)), ALTER COLUMN "tipoBrejoPantano" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Brejo_Pantano_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Brejo_Pantano_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Brejo_Pantano_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Caatinga_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Caatinga_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Caatinga_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Caatinga_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campinarana_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campinarana_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campinarana_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campinarana_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campo_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campo_C" ADD CHECK ("tipoCampo" IN(0,1,2,999)), ALTER COLUMN "tipoCampo" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Campo_C" ADD CHECK ("ocorrenciaEm" IN(5,6,7,8,13,14,19,15,96,998,999)), ALTER COLUMN "ocorrenciaEm" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Cerrado_Cerradao_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Cerrado_Cerradao_C" ADD CHECK ("tipoCerr" IN(0,1,2,999)), ALTER COLUMN "tipoCerr" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Cerrado_Cerradao_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Cerrado_Cerradao_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Cerrado_Cerradao_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Estepe_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Estepe_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Estepe_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Floresta_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Floresta_C" ADD CHECK ("caracteristicaFloresta" IN(0,1,2,3,999)), ALTER COLUMN "caracteristicaFloresta" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Floresta_C" ADD CHECK ("especiePredominante" IN(10,11,12,17,27,41,96,98,999)), ALTER COLUMN "especiePredominante" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Floresta_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Floresta_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Floresta_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ADD CHECK ("tipoMacChav" IN(0,1,2,999)), ALTER COLUMN "tipoMacChav" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Macega_Chavascal_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Mangue_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Mangue_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Mangue_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Mangue_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Restinga_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Restinga_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Restinga_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Restinga_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Area_Contato_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Area_Contato_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,98,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Area_Contato_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Area_Contato_C" ADD CHECK ("antropizada" IN(0,1,2,999)), ALTER COLUMN "antropizada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("tipoLavoura" IN(0,1,2,3,999)), ALTER COLUMN "tipoLavoura" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("finalidade" IN(0,1,2,3,99,998,999)), ALTER COLUMN "finalidade" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("terreno" IN(1,2,3,999)), ALTER COLUMN "terreno" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("classificacaoPorte" IN(0,1,2,3,4,98,998,999)), ALTER COLUMN "classificacaoPorte" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("denso" IN(0,1,2,999)), ALTER COLUMN "denso" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Veg_Cultivada_C" ADD CHECK ("cultivoPredominante" IN(1,2,3,4,42,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,96,98,99,999)), ALTER COLUMN "cultivoPredominante" SET DEFAULT 999;

-- Fim - Cria as restrições e default de cada classe
--########################################################################################################
-- atualizacao na producao
BEGIN;
DROP TABLE "AQUISICAO"."Banco_Areia_C";

CREATE TABLE "AQUISICAO"."Banco_Areia_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
 	"tipoBanco" smallint NOT NULL REFERENCES "DOMINIOS"."tipoBanco" (code),
 	"situacaoEmAgua" smallint NOT NULL REFERENCES "DOMINIOS"."situacaoEmAgua" (code),
 	"materialPredominante" smallint NOT NULL REFERENCES "DOMINIOS"."materialPredominante" (code),
	"nomeAbrev" varchar(50)
);

SELECT AddGeometryColumn('AQUISICAO', 'Banco_Areia_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Banco_Areia_C_geom ON "AQUISICAO"."Banco_Areia_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Banco_Areia_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Banco_Areia_C" TO public;
--#################################################################################################################


ALTER TABLE "AQUISICAO"."Banco_Areia_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Banco_Areia_C" ADD CHECK ("tipoBanco" IN(1,2,3,4,998,999)), ALTER COLUMN "tipoBanco" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Banco_Areia_C" ADD CHECK ("situacaoEmAgua" IN(0,4,5,7,999)), ALTER COLUMN "situacaoEmAgua" SET DEFAULT 999;
ALTER TABLE "AQUISICAO"."Banco_Areia_C" ADD CHECK ("materialPredominante" IN(0,12,18,19,24,98,999)), ALTER COLUMN "materialPredominante" SET DEFAULT 999;


--#################################################################################################################
DROP TABLE "AQUISICAO"."Terreno_Sujeito_Inundacao_C";
CREATE TABLE "AQUISICAO"."Terreno_Sujeito_Inundacao_C"(
	id serial NOT NULL PRIMARY KEY UNIQUE,
	"nome" varchar(80),
 	"geometriaAproximada" smallint NOT NULL REFERENCES "DOMINIOS"."geometriaAproximada" (code),
	"periodicidadeInunda" varchar(20),
	"nomeAbrev" varchar(50)
	
);
SELECT AddGeometryColumn('AQUISICAO', 'Terreno_Sujeito_Inundacao_C','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_AQUISICAO_Terreno_Sujeito_Inundacao_C_geom ON "AQUISICAO"."Terreno_Sujeito_Inundacao_C" USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE "AQUISICAO"."Terreno_Sujeito_Inundacao_C" ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE "AQUISICAO"."Terreno_Sujeito_Inundacao_C" TO public;

ALTER TABLE "AQUISICAO"."Terreno_Sujeito_Inundacao_C" ADD CHECK ("geometriaAproximada" IN(1,2,999)), ALTER COLUMN "geometriaAproximada" SET DEFAULT 999;
COMMIT;
--fim
--####################################################################################################
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


SET search_path TO pg_catalog,public,"HID","REL","VEG","TRA","ENC","ASB","EDU","ECO","LOC","PTO","LIM","ADM","SAU","DOMINIOS","MOLDURA","AQUISICAO","AUX";

COMMIT;
