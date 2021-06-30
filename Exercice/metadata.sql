

DROP TABLE metaindexescolumns;

DROP TABLE metaindex;

DROP TABLE metaconstraints;

DROP TABLE metacolumns;

DROP TABLE metatriggers;

DROP TABLE metatables;

 
------------------------------------------------------------
-- Table: MetaTables
------------------------------------------------------------
CREATE TABLE metatables (
    idtable   NUMBER NOT NULL,
    name      VARCHAR2(200) NOT NULL,
    owner     VARCHAR2(200) NOT NULL,
    comments  VARCHAR2(200),
    CONSTRAINT metatables_pk PRIMARY KEY ( idtable ),
    CONSTRAINT name_table_unique UNIQUE ( name )
);

------------------------------------------------------------
-- Table: MetaIndex
------------------------------------------------------------
CREATE TABLE metaindex (
    idindex   NUMBER NOT NULL,
    name      VARCHAR2(200) NOT NULL,
    position  NUMBER(10, 0) NOT NULL,
    CONSTRAINT metaindex_pk PRIMARY KEY ( idindex )
);

------------------------------------------------------------
-- Table: MetaColumns
------------------------------------------------------------
CREATE TABLE metacolumns (
    idcolumn     NUMBER NOT NULL,
    name         VARCHAR2(200) NOT NULL,
    position     NUMBER(10, 0) NOT NULL,
    nullable     CHAR(1) NOT NULL,
    type         VARCHAR2(10),
    datalength   NUMBER(10, 0),
    datadefault  LONG,
    comments     VARCHAR2(200),
    idtable      NUMBER(10, 0) NOT NULL,
    CONSTRAINT metacolumns_pk PRIMARY KEY ( idcolumn ),
    CONSTRAINT metacolumns_metatables_fk FOREIGN KEY ( idtable )
        REFERENCES metatables ( idtable ),
    CONSTRAINT name_column_unique UNIQUE ( idtable,
                                           name,
                                           position )
);

------------------------------------------------------------
-- Table: MetaConstraints
------------------------------------------------------------
CREATE TABLE metaconstraints (
    idconstraint    NUMBER NOT NULL,
    name            VARCHAR2(200) NOT NULL,
    type            VARCHAR2(200) NOT NULL,
    value           VARCHAR2(200),
    idcolumn        NUMBER(10, 0) NOT NULL,
    idcolumnfather  NUMBER(10, 0),
    CONSTRAINT metaconstraints_pk PRIMARY KEY ( idconstraint ),
    CONSTRAINT chk_type_constraint CHECK ( type IN ( 'C', 'P', 'R', 'U' ) ),
    CONSTRAINT metaconstraints_metacolumns_fk FOREIGN KEY ( idcolumn )
        REFERENCES metacolumns ( idcolumn ),
    CONSTRAINT metaconstraints_metacolumns0_fk FOREIGN KEY ( idcolumnfather )
        REFERENCES metacolumns ( idcolumn )
);

------------------------------------------------------------
-- Table: MetaIndexesColumns
------------------------------------------------------------
CREATE TABLE metaindexescolumns (
    idindex   NUMBER(10, 0) NOT NULL,
    idcolumn  NUMBER(10, 0) NOT NULL,
    CONSTRAINT metaindexescolumns_pk PRIMARY KEY ( idindex,
                                                   idcolumn ),
    CONSTRAINT metaindexescolumns_metaindex_fk FOREIGN KEY ( idindex )
        REFERENCES metaindex ( idindex ),
    CONSTRAINT metaindexescolumns_metacolumns0_fk FOREIGN KEY ( idcolumn )
        REFERENCES metacolumns ( idcolumn )
);

CREATE SEQUENCE seq_metatables_idtable START WITH 1 INCREMENT BY 1 NOCYCLE;

CREATE SEQUENCE seq_metaindex_idindex START WITH 1 INCREMENT BY 1 NOCYCLE;

CREATE SEQUENCE seq_metacolumns_idcolumn START WITH 1 INCREMENT BY 1 NOCYCLE;

CREATE SEQUENCE seq_metaconstraints_idconstraint START WITH 1 INCREMENT BY 1 NOCYCLE;

CREATE OR REPLACE TRIGGER metatables_idtable BEFORE
    INSERT ON metatables
    FOR EACH ROW
    WHEN ( new.idtable IS NULL )
BEGIN
    SELECT
        seq_metatables_idtable.NEXTVAL
    INTO :new.idtable
    FROM
        dual;

END;

CREATE OR REPLACE TRIGGER metaindex_idindex BEFORE
    INSERT ON metaindex
    FOR EACH ROW
    WHEN ( new.idindex IS NULL )
BEGIN
    SELECT
        seq_metaindex_idindex.NEXTVAL
    INTO :new.idindex
    FROM
        dual;

END;

CREATE OR REPLACE TRIGGER metacolumns_idcolumn BEFORE
    INSERT ON metacolumns
    FOR EACH ROW
    WHEN ( new.idcolumn IS NULL )
BEGIN
    SELECT
        seq_metacolumns_idcolumn.NEXTVAL
    INTO :new.idcolumn
    FROM
        dual;

END;

CREATE OR REPLACE TRIGGER metaconstraints_idconstraint BEFORE
    INSERT ON metaconstraints
    FOR EACH ROW
    WHEN ( new.idconstraint IS NULL )
BEGIN
    SELECT
        seq_metaconstraints_idconstraint.NEXTVAL
    INTO :new.idconstraint
    FROM
        dual;

END;

CREATE TABLE metatriggers (
    idtrigger  NUMBER NOT NULL,
    idtable    NUMBER NOT NULL,
    name       VARCHAR2(1),
    type       VARCHAR2(200) NOT NULL,
    event      NUMBER(10, 0) NOT NULL,
    CONSTRAINT metatriggers_pk PRIMARY KEY ( idtrigger ),
    CONSTRAINT metatriggers_metatables_fk FOREIGN KEY ( idtable )
        REFERENCES metatables ( idtable )
);

CREATE SEQUENCE seq_metatriggers_idtrigger START WITH 1 INCREMENT BY 1 NOCYCLE;

CREATE OR REPLACE TRIGGER metatriggers_idtrigger BEFORE
    INSERT ON metatriggers
    FOR EACH ROW
    WHEN ( new.idtrigger IS NULL )
BEGIN
    SELECT
        seq_metatriggers_idtrigger.NEXTVAL
    INTO :new.idtrigger
    FROM
        dual;

END;


DECLARE
    indexid NUMBER(10, 0);
BEGIN
    FOR line_query IN (
        SELECT
            ut.table_name    AS tablename,
            utc.comments     AS comments
        FROM
                 user_tables ut
            INNER JOIN user_tab_comments utc ON utc.table_name = ut.table_name
    ) LOOP
        INSERT INTO metatables (
            idtable,
            name,
            owner,
            comments
        ) VALUES (
            NULL,
            line_query.tablename,
            (
                SELECT
                    user
                FROM
                    dual
            ),
            line_query.comments
        );

    END LOOP;

    FOR line_query IN (
        SELECT
            sys_guid()            AS id,
            ut.name               AS tablename,
            ut.idtable,
            utc.column_name       AS columnname,
            utc.column_id         AS columnposition,
            utc.nullable          AS nullable,
            utc.data_type         AS datatype,
            utc.data_length       AS datalength,
            utc.data_precision    AS dataprecision,
            utc.data_scale        AS datascale,
            utc.data_default      AS datadefault,
            ucc.comments          AS comments
        FROM
                 metatables ut
            INNER JOIN user_tab_columns   utc ON utc.table_name = ut.name
            INNER JOIN user_col_comments  ucc ON ucc.table_name = utc.table_name
                                                AND ucc.column_name = utc.column_name
    ) LOOP
        INSERT INTO metacolumns (
            idcolumn,
            name,
            position,
            nullable,
            type,
            datalength,
            datadefault,
            comments,
            idtable,
        ) VALUES (
            NULL,
            line_query.columnname,
            line_query.columnposition,
            line_query.nullable,
            line_query.datatype,
            line_query.datalength,
            line_query.datadefault,
            line_query.comments,
            line_query.idtable
        );

    END LOOP;

    FOR line_query IN (
        SELECT
            uc.constraint_name    AS constraintname,
            uc.constraint_type    AS constrainttype,
            uc.search_condition,
            join_t_c.idtable,
            join_t_c.idcolumn
        FROM
                 user_constraints uc
            INNER JOIN user_cons_columns  ucc ON ucc.constraint_name = uc.constraint_name
            INNER JOIN (
                SELECT
                    metatables.idtable,
                    metatables.name     AS tablename,
                    metacolumns.idcolumn,
                    metacolumns.name    AS columnname
                FROM
                         metatables
                    INNER JOIN metacolumns ON metatables.idtable = metacolumns.idtable
            )                  join_t_c ON join_t_c.tablename = ucc.table_name
                          AND join_t_c.columnname = ucc.column_name
        WHERE
            uc.constraint_type IN ( 'P', 'R', 'U', 'C' )
    ) LOOP
        INSERT INTO metaconstraints (
            idconstraint,
            name,
            type,
            value,
            idcolumn,
            idcolumnfather
        ) VALUES (
            NULL,
            line_query.constraintname,
            line_query.constrainttype,
            line_query.search_condition,
            line_query.idcolumn,
            NULL
        );

    END LOOP;

    FOR line_query IN (
        SELECT
            metaconstraints.idconstraint,
            metaconstraints.name,
            user_constraints.r_constraint_name,
            mc2.idcolumn AS idcolumnfather
        FROM
                 metaconstraints
            INNER JOIN (
                SELECT
                    metatables.idtable,
                    metatables.name     AS tablename,
                    metacolumns.idcolumn,
                    metacolumns.name    AS columnname
                FROM
                         metatables
                    INNER JOIN metacolumns ON metatables.idtable = metacolumns.idtable
            )                  join_t_c ON join_t_c.idcolumn = metaconstraints.idcolumn
            INNER JOIN user_cons_columns  ucc ON join_t_c.tablename = ucc.table_name
                                                AND join_t_c.columnname = ucc.column_name
                                                AND metaconstraints.name = ucc.constraint_name
            INNER JOIN user_constraints ON ucc.constraint_name = user_constraints.constraint_name
                                           AND user_constraints.table_name = ucc.table_name
            INNER JOIN metaconstraints    mc2 ON mc2.name = user_constraints.r_constraint_name
    ) LOOP
        UPDATE metaconstraints
        SET
            idcolumnfather = line_query.idcolumnfather
        WHERE
            idconstraint = line_query.idconstraint;

    END LOOP;

    FOR line_query IN (
        SELECT
            uic.table_name         AS tablename,
            uic.index_name         AS indexname,
            uic.column_position    AS columnindexposition,
            utc.column_id          AS columnposition,
            join_t_c.idcolumn
        FROM
                 user_ind_columns uic
            INNER JOIN user_tab_columns  utc ON utc.table_name = uic.table_name
                                               AND utc.column_name = uic.column_name
            INNER JOIN (
                SELECT
                    metatables.idtable,
                    metatables.name     AS tablename,
                    metacolumns.idcolumn,
                    metacolumns.name    AS columnname,
                    metacolumns.position
                FROM
                         metatables
                    INNER JOIN metacolumns ON metatables.idtable = metacolumns.idtable
            )                 join_t_c ON uic.table_name = join_t_c.tablename
                          AND utc.column_id = join_t_c.position
    ) LOOP
        INSERT INTO metaindex (
            idindex,
            name,
            position
        ) VALUES (
            NULL,
            line_query.indexname,
            line_query.columnindexposition
        ) RETURNING idindex INTO indexid;

        INSERT INTO metaindexescolumns (
            idcolumn,
            idindex
        ) VALUES (
            line_query.idcolumn,
            indexid
        );

    END LOOP;

END;





CREATE OR REPLACE VIEW "VwTable" AS 
SELECT SYS_GUID() AS id,
    UT.TABLE_NAME as TableName, 
    UT.TABLESPACE_NAME as SpaceName, 
    UTC.COMMENTS as Comments
FROM user_tables UT
INNER JOIN user_tab_comments UTC ON UTC.TABLE_NAME = UT.TABLE_NAME;

CREATE OR REPLACE VIEW "VwColumn" AS
SELECT SYS_GUID() AS id,
        UT.TABLE_NAME as TableName, 
        UTC.COLUMN_NAME as ColumnName, 
        UTC.COLUMN_ID as ColumnPosition, 
        UTC.NULLABLE as Nullable, 
        UTC.DATA_TYPE as DataType,
        UTC.DATA_LENGTH as DataLength, 
        UTC.DATA_PRECISION as DataPrecision, 
        UTC.DATA_SCALE as DataScale, 
        UTC.DATA_DEFAULT as DataDefault, 
        UCC.COMMENTS as Comments
FROM user_tables UT
INNER JOIN user_tab_columns UTC ON UTC.TABLE_NAME = UT.TABLE_NAME
INNER JOIN user_col_comments UCC ON UCC.TABLE_NAME = UTC.TABLE_NAME AND UCC.COLUMN_NAME = UTC.COLUMN_NAME;

CREATE OR REPLACE VIEW "VwConstraint" AS 
SELECT SYS_GUID() AS id,
      UCC.TABLE_NAME as TableName,
      UC.CONSTRAINT_NAME as ConstraintName, 
      UC.CONSTRAINT_TYPE as ConstraintType, 
      UC.R_CONSTRAINT_NAME as FatherConstraintName, 
      UC.INDEX_NAME as IndexName,  
      UCC.COLUMN_NAME as ColumnName, 
      UCC.POSITION as ColumnIndexPosition
FROM user_constraints UC 
INNER JOIN user_cons_columns UCC ON UCC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
WHERE UC.CONSTRAINT_TYPE IN ('P','R','U','C');

CREATE OR REPLACE VIEW "VwIndex" AS 
SELECT	SYS_GUID() AS id,
        UIC.TABLE_NAME as TableName, 
        UIC.INDEX_NAME as IndexName, 
        UIC.COLUMN_POSITION as ColumnIndexPosition,
        UTC.COLUMN_ID as ColumnPosition
FROM USER_IND_COLUMNS UIC
INNER JOIN user_tab_columns UTC ON UTC.TABLE_NAME = UIC.TABLE_NAME AND UTC.COLUMN_NAME = UIC.COLUMN_NAME;

CREATE OR REPLACE VIEW "VwTrigger" AS 
SELECT SYS_GUID() AS id,
	UT.TABLE_NAME as TableName,
	UT.TRIGGER_NAME as TriggerName,
	UT.TRIGGER_TYPE as TriggerType,
	UT.TRIGGERING_EVENT as TriggerEvent
FROM user_triggers UT
WHERE UT.BASE_OBJECT_TYPE = 'TABLE';

CREATE OR REPLACE VIEW "VwViewColumn" AS 
select SYS_GUID() AS id,
        V.VIEW_NAME as ViewName,
        UTC.COLUMN_NAME as ColumnName, 
        UTC.COLUMN_ID as ColumnPosition, 
        UTC.NULLABLE as Nullable, 
        UTC.DATA_TYPE as DataType,
        UTC.DATA_LENGTH as DataLength, 
        UTC.DATA_PRECISION as DataPrecision, 
        UTC.DATA_SCALE as DataScale, 
        UTC.DATA_DEFAULT as DataDefault, 
        UCC.COMMENTS as Comments
from user_views V 
INNER JOIN user_tab_columns UTC on UTC.table_name = v.view_name 
INNER JOIN user_col_comments UCC ON UCC.TABLE_NAME = UTC.table_name AND UCC.COLUMN_NAME = UTC.COLUMN_NAME;

CREATE OR REPLACE VIEW "VwView" AS
SELECT
        V.VIEW_NAME as ViewName,
        UTC.COMMENTS
from user_views V 
INNER JOIN user_tab_comments UTC on UTC.table_name = v.view_name;

CREATE OR REPLACE VIEW "VwLinkFKConstraint" AS 
  select 
    sys_guid() as id,
    UC_R.table_name as FkTableName, 
    UC_R.constraint_name as FkConstraintName,
    UC_P.constraint_name as ConstraintName, 
    UC_P.table_name as TableName
from user_constraints UC_R
INNER join user_constraints UC_P on UC_P.constraint_name = UC_R.r_constraint_name
WHERE UC_R.CONSTRAINT_TYPE IN ('R');

CREATE OR REPLACE VIEW "VwViewReference" AS
select DISTINCT UD.name as ViewName,
       UD.referenced_name as ObjectName,
       UD.referenced_type as TypeName
from all_dependencies UD
Inner join user_views ON user_views.VIEW_NAME = UD.name
where UD.referenced_type IN ('VIEW','TABLE','SYNONYM');























