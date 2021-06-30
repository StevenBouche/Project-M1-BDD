-------------------------------------------------------------------------------------------------
-- Activite 1 : Connexion et definition  de variables
-------------------------------------------------------------------------------------------------

-- Base1 : pdbl3mia.631174089.oraclecloud.internal : (machine host IP : 144.21.67.201 Port : 1521) 
-- Base2 : pdbm1inf.631174089.oraclecloud.internal : (machine host IP : 144.21.67.201 Port : 1521).

-------------------------------------------------------------------------------------------------
-- Activite 1.1 : connexion sur la Base1
-- definition des variable des bases
-------------------------------------------------------------------------------------------------

define HOSTNAME=144.21.67.201
define PORT_HOSTNAME=1521

--First Database (first terminal sqlplus)

define SERVICEDB2=pdbm1inf.631174089.oraclecloud.internal
define DBLINKNAME2=pdbm1inf
define SERVICEDB1=pdbl3mia.631174089.oraclecloud.internal
define ALIASDB1=pdbl3mia

define DRUSER=BOUCHE1M2021
define DRUSERPASS=BOUCHE1M202101

define SCRIPTPATH=E:\Documents\Scolarite\MIAGE\Master1\SQL\Chap8\Scripts

--Second Database (second terminal sqlplus)

define SERVICEDB1=pdbl3mia.631174089.oraclecloud.internal
define DBLINKNAME1=pdbl3mia
define SERVICEDB2=pdbm1inf.631174089.oraclecloud.internal
define ALIASDB2=pdbm1inf

define DRUSER=BOUCHE1M2021
define DRUSERPASS=BOUCHE1M202101

define SCRIPTPATH=E:\Documents\Scolarite\MIAGE\Master1\SQL\Chap8\Scripts


--Connection databases

--first terminal sqlplus
Connect &DRUSER/&DRUSERPASS@&HOSTNAME:&PORT_HOSTNAME/&SERVICEDB1

--second terminal sqlplus
Connect &DRUSER/&DRUSERPASS@&HOSTNAME:&PORT_HOSTNAME/&SERVICEDB2

-------------------------------------------------------------------------------------------------
-- Activite 2 : Chargment des donnees
-------------------------------------------------------------------------------------------------

-- Sur les 2 terminaux sqlplus : exec les scripts

--first
@&SCRIPTPATH\chap8_demobld.sql

--second
@&SCRIPTPATH\chap8_clientbld.sql

-------------------------------------------------------------------------------------------------
-- Activite 3 .	Creer un database link public pour permettre a l'utilisateur &DRUSER 
-- depuis la Base1 de manipuler des objets a distance sur la Base2

-- Dans le cadre de cet exercice, le Database Link est deja cree par l'adminitrateur
-- Il est contenu dans la variable : DBLINKNAME2 (voir sa valeur)
-------------------------------------------------------------------------------------------------

--DROP PUBLIC DATABASE LINK &DBLINKNAME2; 

--first terminal sqlplus
CREATE PUBLIC DATABASE LINK &DBLINKNAME2
   CONNECT TO &DRUSER IDENTIFIED BY &DRUSERPASS
   USING '(DESCRIPTION=
                (ADDRESS=(PROTOCOL=TCP)(HOST=&HOSTNAME)(PORT=&PORT_HOSTNAME))
                (CONNECT_DATA=(SERVICE_NAME=&SERVICEDB2))
            )';

-------------------------------------------------------------------------------------------------
-- Activite 4 : Consultations et mise a jour distante : requete sur 1 base distante
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- Activite 4.1	Effectuer des consultations distantes
-------------------------------------------------------------------------------------------------

desc &DRUSER..produit@&DBLINKNAME2

 --Name                                      Null?    Type
 ------------------------------------------- -------- ----------------------------
 --PID#                                      NOT NULL NUMBER(6)
 --PNOM                                               VARCHAR2(50)
 --PDESCRIPTION                                       VARCHAR2(100)
 --PPRIXUNIT                                          NUMBER(7,2)

desc &DRUSER..commande@&DBLINKNAME2

 --Name                                      Null?    Type
 ------------------------------------------- -------- ----------------------------
 --PCOMM#                                    NOT NULL NUMBER(6)
 --CDATE                                              DATE
 --PID#                                               NUMBER(6)
 --CID#                                               NUMBER(6)
 --PNBRE                                              NUMBER(4)
 --PPRIXUNIT                                          NUMBER(7,2)
 --EMPNO                                              NUMBER(4)

desc &DRUSER..client@&DBLINKNAME2

 --Name                                      Null?    Type
 ------------------------------------------- -------- ----------------------------
 --CID#                                      NOT NULL NUMBER(6)
 --CNOM                                               VARCHAR2(20)
 --CDNAISS                                            DATE
 --CADR                                               VARCHAR2(50)

 select *
from &DRUSER..commande@&DBLINKNAME2;

--    PCOMM# CDATE             PID#       CID#      PNBRE  PPRIXUNIT      EMPNO
------------ ----------- ---------- ---------- ---------- ---------- ----------
--         1 14-MAY-2021       1000          1          4          2       7369
--         2 14-MAY-2021       1000          1         10          2       7369
--         3 14-MAY-2021       1000          1          9          2       7369

set linesize 200
col CADR format A20
select * from &DRUSER..client@&DBLINKNAME2;

--      CID# CNOM                 CDNAISS     CADR
------------ -------------------- ----------- --------------------
--         1 Akim                 12-DEC-1972 Washington
--         2 Erzulie              12-DEC-1942 Artibonite

set linesize 200
col pnom format A30
col pdescription format A40
select * from &DRUSER..produit@&DBLINKNAME2;

--      PID# PNOM                           PDESCRIPTION                              PPRIXUNIT
------------ ------------------------------ ---------------------------------------- ----------
--      1000 Coca cola 2 litres             Coca cola 2 litres avec caf?in                    2
--      1001 orangina pack de 6 bouteilles  orangina pack de 6 bouteilles de 1,5 lit          6
--           de 1,5 litres                  res

-------------------------------------------------------------------------------------------------
-- Activite 4.2	Effectuer des mises a jour distantes sur la Base1
-------------------------------------------------------------------------------------------------

Update &DRUSER..commande@&DBLINKNAME2
Set empno= 7369;

col pdb_name format a10
col username format a12
col segment_name format a22
col status format A7

select ps.pdb_name, 
vs.username, 
rs.segment_name, 
vt.addr "Id trans", 
vt.status, 
vt.start_time,
vt.START_SCNB "START SCN",
vt.USED_UBLK "Block RBS"
from v$transaction vt, v$session vs, dba_rollback_segs rs, dba_pdbs ps
where vt.SES_ADDR=vs.saddr
and vt.con_id=ps.con_id
and vt.XIDUSN=rs.segment_id;

-- Resultat sur la Base1

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBL3MIA   BOUCHE1M2021 _SYSSMU11_2843521970$  000000007A1B8898 ACTIVE  05/14/21 14:25:03     148300787          1

-- Resultat sur la Base2

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBM1INF   BOUCHE1M2021 _SYSSMU8_563287346$    000000007A196050 ACTIVE  05/14/21 14:25:03     148301112          1


-- Consultation des informations sur les verrous DML sur la Base1 et la Base2

set linesize 200
col OWNER format a12
col NAME  format a15
col BLOCKING_OTHERS format a15

select 
SESSION_ID,
OWNER, 
NAME,
MODE_HELD,
MODE_REQUESTED,
LAST_CONVERT,
BLOCKING_OTHERS
from dba_dml_locks;

-- Resultat sur la Base1

--no rows selected

-- Resultat sur la Base2

--SESSION_ID OWNER        NAME            MODE_HELD     MODE_REQUESTE LAST_CONVERT BLOCKING_OTHERS
------------ ------------ --------------- ------------- ------------- ------------ ---------------
--       313 BOUCHE1M2021 COMMANDE        Row-X (SX)    None                   344 Not Blocking


-- Validation sur la Base 1 uniquement
Commit;

-- Insertion d'une ligne dans une table distante : Base 1

insert into &DRUSER..commande@&DBLINKNAME2 (pcomm#, cdate,pid#,  cid#, pnbre, pprixunit, empno) 
values(4, sysdate, 1000,1, 9, 2, 7369);

--    PCOMM# CDATE             PID#       CID#      PNBRE  PPRIXUNIT      EMPNO
------------ ----------- ---------- ---------- ---------- ---------- ----------
--         1 14-MAY-2021       1000          1          4          2       7369
--         2 14-MAY-2021       1000          1         10          2       7369
--         3 14-MAY-2021       1000          1          9          2       7369
--         4 14-MAY-2021       1000          1          9          2       7369

-- Consultation des informations sur la transaction sur la Base1 et la Base2
col pdb_name format a10
col username format a12
col segment_name format a22
col status format A7

select ps.pdb_name, 
vs.username, 
rs.segment_name, 
vt.addr "Id trans", 
vt.status, 
vt.start_time,
vt.START_SCNB "START SCN",
vt.USED_UBLK "Block RBS"
from v$transaction vt, v$session vs, dba_rollback_segs rs, dba_pdbs ps
where vt.SES_ADDR=vs.saddr
and vt.con_id=ps.con_id
and vt.XIDUSN=rs.segment_id;

-- Resultat sur la Base1

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBL3MIA   BOUCHE1M2021 _SYSSMU5_1473839336$   000000007A1B8898 ACTIVE  05/14/21 14:38:33     148302406          1

-- Resultat sur la Base2

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBM1INF   BOUCHE1M2021 _SYSSMU6_3381045840$   000000007A196050 ACTIVE  05/14/21 14:38:33     148302406          1


-- Consultation des informations sur les verrous DML sur la Base1 et la Base2
set linesize 200
col OWNER format a12
col NAME  format a15
col BLOCKING_OTHERS format a15

select 
SESSION_ID,
OWNER, 
NAME,
MODE_HELD,
MODE_REQUESTED,
LAST_CONVERT,
BLOCKING_OTHERS
from dba_dml_locks;

-- Resultat sur la Base1

--no rows selected

-- Resultat sur la Base2

--SESSION_ID OWNER        NAME            MODE_HELD     MODE_REQUESTE LAST_CONVERT BLOCKING_OTHERS
------------ ------------ --------------- ------------- ------------- ------------ ---------------
--       313 BOUCHE1M2021 CLIENT          Row-X (SX)    None                   195 Not Blocking
--       313 BOUCHE1M2021 PRODUIT         Row-X (SX)    None                   195 Not Blocking
--       313 BOUCHE1M2021 COMMANDE        Row-X (SX)    None                   195 Not Blocking

-- Validation sur la Base1 uniquement
commit ;

-------------------------------------------------------------------------------------------------
-- Activite 5 : Consultaions et mises a jour distribuees : requetes impliquant 
-- plusieurs bases de donnees(ici Base1 et Base2)
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- Activite 5.1 Effectuer des consultations distribuees : ici jointure ... sur la base 1
-------------------------------------------------------------------------------------------------

Select c.pcomm#, c.pid#, e.empno , c.PPRIXUNIT
from &DRUSER..commande@&DBLINKNAME2  c, 
&DRUSER..produit@&DBLINKNAME2 p, 
emp e
where c.pid#=p.pid# and c.empno=e.Empno;

--    PCOMM#       PID#      EMPNO  PPRIXUNIT
------------ ---------- ---------- ----------
--         1       1000       7369          2
--         2       1000       7369          2
--         3       1000       7369          2
--         4       1000       7369          2

-- Consultation des informations sur la transaction sur la Base1 et la Base2
col pdb_name format a10
col username format a12
col segment_name format a22
col status format A7

select ps.pdb_name, 
vs.username, 
rs.segment_name, 
vt.addr "Id trans", 
vt.status, 
vt.start_time,
vt.START_SCNB "START SCN",
vt.USED_UBLK "Block RBS"
from v$transaction vt, v$session vs, dba_rollback_segs rs, dba_pdbs ps
where vt.SES_ADDR=vs.saddr
and vt.con_id=ps.con_id
and vt.XIDUSN=rs.segment_id;

-- Resultat sur la Base1

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBL3MIA   BOUCHE1M2021 _SYSSMU11_2843521970$  000000007A1B8898 ACTIVE  05/14/21 14:44:03     148302794          1

-- Resultat sur la Base2

--no rows selected

-- Consultation des informations sur les verrous DML sur la Base1 et la Base2
set linesize 200
col OWNER format a12
col NAME  format a15
col BLOCKING_OTHERS format a15

select 
SESSION_ID,
OWNER, 
NAME,
MODE_HELD,
MODE_REQUESTED,
LAST_CONVERT,
BLOCKING_OTHERS
from dba_dml_locks;

-- Resultat sur la Base1

--no rows selected

-- Resultat sur la Base2

--no rows selected

-- Validation sur la Base1 uniquement
commit ;

-------------------------------------------------------------------------------------------------
-- Activite 5.2 Effectuer des mises a distribuees sur la Base1
-------------------------------------------------------------------------------------------------

-- Sur la Base1 : Inserer une nouvelle commande pour l'employe 7369 
-- Sur la Base1 : Augmenter la commission de l'employe 7369 de 2 Euros.
-- Verifier les informations sur la transactions
-- Verifier les informations sur les verrous
-- Effectuer un Commit: Ce commit sera un commit a deux phase

set serveroutput on
BEGIN
insert into &DRUSER..commande@&DBLINKNAME2 (pcomm#, cdate,pid#,  cid#, pnbre, pprixunit, empno) 
values(6, sysdate, 1000,1, 9, 2, 7369);

update emp
set comm= nvl(comm, 0) + 2 
WHERE EMPNO=7369;
END ;
/

-------------------------------------------------------------------------------------------------
-- Activite 5.3 : Consultation des informations sur la transaction sur les Base1 et Base2
-------------------------------------------------------------------------------------------------

col pdb_name format a10
col username format a12
col segment_name format a22
col status format A7

select ps.pdb_name, 
vs.username, 
rs.segment_name, 
vt.addr "Id trans", 
vt.status, 
vt.start_time,
vt.START_SCNB "START SCN",
vt.USED_UBLK "Block RBS"
from v$transaction vt, v$session vs, dba_rollback_segs rs, dba_pdbs ps
where vt.SES_ADDR=vs.saddr
and vt.con_id=ps.con_id
and vt.XIDUSN=rs.segment_id;

-- Resultat sur la Base1

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBL3MIA   BOUCHE1M2021 _SYSSMU10_4201072483$  000000007A2D1E68 ACTIVE  05/14/21 14:50:06     148304147          2

-- Resultat sur la Base2

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBM1INF   BOUCHE1M2021 _SYSSMU6_3381045840$   000000007A244D88 ACTIVE  05/14/21 14:50:06     148304152          1

-------------------------------------------------------------------------------------------------
-- Activite 5.4 : Consultation des informations sur les verrous DML sur les Base1 et Base2
-------------------------------------------------------------------------------------------------

set linesize 200
col OWNER format a12
col NAME  format a15
col BLOCKING_OTHERS format a15

select 
SESSION_ID,
OWNER, 
NAME,
MODE_HELD,
MODE_REQUESTED,
LAST_CONVERT,
BLOCKING_OTHERS
from dba_dml_locks;

-- Resultat sur la Base1

--SESSION_ID OWNER        NAME            MODE_HELD     MODE_REQUESTE LAST_CONVERT BLOCKING_OTHERS
------------ ------------ --------------- ------------- ------------- ------------ ---------------
--       280 BOUCHE1M2021 EMP             Row-X (SX)    None                   145 Not Blocking

-- Resultat sur la Base2

--SESSION_ID OWNER        NAME            MODE_HELD     MODE_REQUESTE LAST_CONVERT BLOCKING_OTHERS
------------ ------------ --------------- ------------- ------------- ------------ ---------------
--       286 BOUCHE1M2021 CLIENT          Row-X (SX)    None                   146 Not Blocking
--       286 BOUCHE1M2021 PRODUIT         Row-X (SX)    None                   146 Not Blocking
--       286 BOUCHE1M2021 COMMANDE        Row-X (SX)    None                   146 Not Blocking

-- Validation sur la Base1 uniquement
commit ;-- commit a 2 phases

-------------------------------------------------------------------------------------------------
-- Activite 6: Transparence vis a vis de la localisation via les synonymes
-- Rendre transparent l'acces aux donnees distantes grace au synonymes, 
-- Regle 4 de Chris DATE
-------------------------------------------------------------------------------------------------

drop public synonym commande;
Create public synonym commande for &DRUSER..commande@&DBLINKNAME2;

BEGIN
insert into commande (pcomm#, cdate,pid#,  cid#, pnbre, pprixunit, empno) 
values(7, sysdate, 1000,1, 9, 2, 7369);

update emp
set comm= nvl(comm, 0) + 2 
WHERE EMPNO=7369;

commit ;
END ;
/

-- verification sur Base1
select * from commande;

--    PCOMM# CDATE           PID#       CID#      PNBRE  PPRIXUNIT      EMPNO
------------ --------- ---------- ---------- ---------- ---------- ----------
--         7 14-MAY-21       1000          1          9          2       7369
--         1 14-MAY-21       1000          1          4          2       7369
--         2 14-MAY-21       1000          1         10          2       7369
--         3 14-MAY-21       1000          1          9          2       7369

-- verification sur Base1
select * from emp where empno=7369;

--     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
------------ ---------- --------- ---------- --------- ---------- ---------- ----------
--      7369 SMITH      CLERK           7902 17-DEC-80        800          4         20

-------------------------------------------------------------------------------------------------
-- Activite 7 .	Creer un database link public pour permettre a l'utilisateur &DRUSER 
-- depuis la Base2 de manipuler des objets a distance sur la Base1

-- Dans le cadre de cet exercice, le Database Link est deja cree par l'adminitrateur
-- Il est contenu dans la variable : DBLINKNAME1 (voir sa valeur plus haut)
-------------------------------------------------------------------------------------------------


--second terminal sqlplus
CREATE PUBLIC DATABASE LINK &DBLINKNAME1
   CONNECT TO &DRUSER IDENTIFIED BY &DRUSERPASS
   USING '(DESCRIPTION=
                (ADDRESS=(PROTOCOL=TCP)(HOST=&HOSTNAME)(PORT=&PORT_HOSTNAME))
                (CONNECT_DATA=(SERVICE_NAME=&SERVICEDB1))
            )';



-------------------------------------------------------------------------------------------------
-- Activite 8.	sur la Base2 creer un trigger sur la table COMMANDE qui met a jour la 
-- commission de l'employe (qui gere la commande) de 2 EUROS a chaque fois qu'une 
-- commande est inseree ou supprimee. 
-------------------------------------------------------------------------------------------------

Connect &DRUSER/&DRUSERPASS@&HOSTNAME:&PORT_HOSTNAME/&SERVICEDB2

CREATE OR REPLACE TRIGGER update_employe_comm
	AFTER DELETE OR INSERT ON commande FOR EACH ROW
	DECLARE 

BEGIN
	IF INSERTING THEN
		UPDATE &DRUSER..emp@&DBLINKNAME1 e 
SET e.comm = nvl(e.comm, 0) + 2 
WHERE empno= :new.empno;
	END IF;

	IF DELETING THEN
		UPDATE &DRUSER..emp@&DBLINKNAME1 e 
SET e.comm = decode(e.comm, null, 0, e.comm - 2)
WHERE empno= :old.empno;
	END IF;


END;
/

-------------------------------------------------------------------------------------------------
-- Activite 9.	sur la Base1 verifier le fonctionnement du trigger
-------------------------------------------------------------------------------------------------

Connect &DRUSER/&DRUSERPASS@&HOSTNAME:&PORT_HOSTNAME/&SERVICEDB1

select * from commande;

--    PCOMM# CDATE           PID#       CID#      PNBRE  PPRIXUNIT      EMPNO
------------ --------- ---------- ---------- ---------- ---------- ----------
--         7 14-MAY-21       1000          1          9          2       7369
--         1 14-MAY-21       1000          1          4          2       7369
--         2 14-MAY-21       1000          1         10          2       7369
--         3 14-MAY-21       1000          1          9          2       7369

select * from emp where empno=7369;

--     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
------------ ---------- --------- ---------- --------- ---------- ---------- ----------
--      7369 SMITH      CLERK           7902 17-DEC-80        800          4         20

BEGIN
insert into commande (pcomm#, cdate,pid#,  cid#, pnbre, pprixunit, empno) values(8, sysdate, 1000,1, 9, 2, 7369);
END ;
/

select * from commande;

--    PCOMM# CDATE           PID#       CID#      PNBRE  PPRIXUNIT      EMPNO
------------ --------- ---------- ---------- ---------- ---------- ----------
--         7 14-MAY-21       1000          1          9          2       7369
--         8 14-MAY-21       1000          1          9          2       7369
--         1 14-MAY-21       1000          1          4          2       7369
--         2 14-MAY-21       1000          1         10          2       7369
--         3 14-MAY-21       1000          1          9          2       7369

select * from emp where empno=7369;

--     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
------------ ---------- --------- ---------- --------- ---------- ---------- ----------
--      7369 SMITH      CLERK           7902 17-DEC-80        800          4         20

-- Consultation des informations sur la transaction sur la Base1 et la Base2
col pdb_name format a10
col username format a12
col segment_name format a22
col status format A7

select ps.pdb_name, 
vs.username, 
rs.segment_name, 
vt.addr "Id trans", 
vt.status, 
vt.start_time,
vt.START_SCNB "START SCN",
vt.USED_UBLK "Block RBS"
from v$transaction vt, v$session vs, dba_rollback_segs rs, dba_pdbs ps
where vt.SES_ADDR=vs.saddr
and vt.con_id=ps.con_id
and vt.XIDUSN=rs.segment_id;

-- Resultat sur la Base1

--PDB_NAME   USERNAME     SEGMENT_NAME           Id trans         STATUS  START_TIME            START SCN  Block RBS
------------ ------------ ---------------------- ---------------- ------- -------------------- ---------- ----------
--PDBL3MIA   BOUCHE1M2021 _SYSSMU2_3035727479$   000000007A26B180 ACTIVE  05/14/21 15:05:38     148304563          1

-- Resultat sur la Base2

--no rows selected

-- Consultation des informations sur les verrous DML sur la Base1 et la Base2
set linesize 200
col OWNER format a12
col NAME  format a15
col BLOCKING_OTHERS format a15

select 
SESSION_ID,
OWNER, 
NAME,
MODE_HELD,
MODE_REQUESTED,
LAST_CONVERT,
BLOCKING_OTHERS
from dba_dml_locks;

-- Resultat sur la Base1

--SESSION_ID OWNER        NAME            MODE_HELD     MODE_REQUESTE LAST_CONVERT BLOCKING_OTHERS
------------ ------------ --------------- ------------- ------------- ------------ ---------------
--       280 BOUCHE1M2021 CLIENT          Row-X (SX)    None                   179 Not Blocking
--       280 BOUCHE1M2021 PRODUIT         Row-X (SX)    None                   179 Not Blocking
--       280 BOUCHE1M2021 COMMANDE        Row-X (SX)    None                   179 Not Blocking

-- Resultat sur la Base2

--no rows selected

-- Validation sur la Base1 uniquement

commit ;

-------------------------------------------------------------------------------------------------
-- Activite 10 : Simulation de pannes d'une transaction distribu�es

-- En cas de COMMIT distribue, il est extremement complique pour mettre en evidence des 
-- pannes.
-- Il ne reste plus que la simulation.
-- On utilise pour cela l'ordre SQL :
-- COMMIT COMMENT 'ORA-2PC-CRASH-TEST-N (N etant un des 10 numeros de pannes)
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- Activite 10.1 : Comprendre la Liste des Numeros de Pannes
-- 1	panne d'un site en transaction (commit point site) apres collecte 
-- 2	panne d'un site non en transaction apres collecte 
-- 3	panne avant la phase de preparation
-- 4	panne apres la phase de preparation
-- 5	panne du commit point site avant la phase de validation 
-- 6	panne d'un site en transaction apres le Commit
-- 7	panne d'un site non en transaction avant le Commit*
-- 8	panne d'un site non en transaction apres la phase de validation
-- 9	panne d'un site en transaction apres la phase ignorer
-- 10	panne d'un site non en transaction avant la phase ignorer
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- Activite 10.2 :informations sur les transactions distribuees 
--               Comprendre le role des vues DBA_2PC_PENDING et DBA_2PC_NEIGHBORS
-- Deux vues Oracle contiennent les informations sur les transactions distribuees
-- DBA_2PC_PENDING :
-- 	. Cette vue decrit les informations sur les transactions distribuees en attente 
--    de recouvrement suite a une panne.
-- DBA_2PC_NEIGHBORS
--  . Cette vue decrit les informations sur les connexions entrantes ou sortantes  des 
--    transactions distribuees douteuses.
-------------------------------------------------------------------------------------------------

-- DBA_2PC_PENDING :
-- 	. Cette vue decrit les informations sur les transactions distribuees en attente 
--    de recouvrement suite a une panne.

desc DBA_2PC_PENDING


Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 LOCAL_TRAN_ID                             NOT NULL VARCHAR2(22)
 GLOBAL_TRAN_ID                                     VARCHAR2(169)
 STATE                                     NOT NULL VARCHAR2(16)
 MIXED                                              VARCHAR2(3)
 ADVICE                                             VARCHAR2(1)
 TRAN_COMMENT                                       VARCHAR2(255)
 FAIL_TIME                                 NOT NULL DATE
 FORCE_TIME                                         DATE
 RETRY_TIME                                NOT NULL DATE
 OS_USER                                            VARCHAR2(64)
 OS_TERMINAL                                        VARCHAR2(255)
 HOST                                               VARCHAR2(128)
 DB_USER                                            VARCHAR2(128)
 COMMIT#                                            VARCHAR2(16)


-- DBA_2PC_NEIGHBORS
--  . Cette vue decrit les informations sur les connexions entrantes ou sortantes  des 
--    transactions distribuees douteuses.

-- noeud implique dans des transactions douteuses
desc DBA_2PC_NEIGHBORS

Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 LOCAL_TRAN_ID                                      VARCHAR2(22)
 IN_OUT                                             VARCHAR2(3)
 DATABASE                                           VARCHAR2(128)
 DBUSER_OWNER                                       VARCHAR2(128)
 INTERFACE                                          VARCHAR2(1)
 DBID                                               VARCHAR2(16)
 SESS#                                              NUMBER(38)
 BRANCH                                             VARCHAR2(128)

 -------------------------------------------------------------------------------------------------
-- Activite 10.3 : Consultation des informations sur les transactions douteuses
-- sur les Base1 et Base2 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- Activite 10.3.1 : simulation de panne en cas de transaction distribuees
-- Simulation de la panne 6 sur la Base1 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------

--DB1

select empno, ename, sal from emp where empno=7369;
col pdescription format a40

--     EMPNO ENAME             SAL
------------ ---------- ----------
--      7369 SMITH             800
 
select pid#, pdescription from &DRUSER..produit@&DBLINKNAME2
where pid#=1000;

--      PID# PDESCRIPTION
------------ ----------------------------------------
--      1000 Coca cola 2 litres avec caf?in

update emp 
set sal=sal*1.1
where empno=7369;

update &DRUSER..produit@&DBLINKNAME2
set pdescription =pdescription||'BravoBravo'
where PID#=1000;

COMMIT COMMENT 'ORA-2PC-CRASH-TEST-6';

--ERROR at line 1:
--ORA-02054: transaction 2.1.17612 in-doubt
--ORA-02053: transaction 9.24.13851 committed, some remote DBs may be in-doubt
--ORA-02059: ORA-2PC-CRASH-TEST-6 in commit comment
--ORA-02063: preceding 2 lines from PDBM1INF


select empno, ename, sal from emp where empno=7369;

--ERROR at line 1:
--ORA-01591: lock held by in-doubt distributed transaction 2.1.17612

select pid#, pdescription from &DRUSER..produit@&DBLINKNAME2
where pid#=1000;

--      PID# PDESCRIPTION
------------ ----------------------------------------
--      1000 Coca cola 2 litres avec caf?inBravoBravo


-------------------------------------------------------------------------------------------------
-- Activite 10.3.2 : Consultation des informations sur les transactions en attente 
-- de recouvrement sur la Base1 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------


set linesize 200
col GLOBAL_TRAN_ID format a12
col LOCAL_TRAN_ID format a12
col STATE format a10
col TRAN_COMMENT format a30
col OS_USER format a10
col OS_TERMINAL format a15
col HOST format a15
col DB_USER format a15
col COMMIT# format a10

select GLOBAL_TRAN_ID,
LOCAL_TRAN_ID, 
state ,
ADVICE,
TRAN_COMMENT,
FAIL_TIME,
FORCE_TIME,
RETRY_TIME,
OS_USER,
OS_TERMINAL,
HOST,
DB_USER,
COMMIT#  
from DBA_2PC_PENDING;

--GLOBAL_TRAN_ LOCAL_TRAN_I STATE      A TRAN_COMMENT                   FAIL_TIME   FORCE_TIME  RETRY_TIME  OS_USER    OS_TERMINAL     HOST            DB_USER
--             COMMIT#
-------------- ------------ ---------- - ------------------------------ ----------- ----------- ----------- ---------- --------------- --------------- --------------- ----------
--PDBL3MIA.a1b 2.1.17612    prepared     ORA-2PC-CRASH-TEST-6           14-MAY-2021             14-MAY-2021 steve      DESKTOP-FM1VRG8 WORKGROUP\DESKT BOUCHE1M2021    148317613
--77c8e.2.1.17                                                                                                                         OP-FM1VRG8
--612

-- Que constatez vous ? le commit est dans un etat prepare et est en attente, concernant la table emp

-------------------------------------------------------------------------------------------------
-- Activite 10.3.3 : Consultation des informations sur les noeuds impliques dans des 
-- transactions douteuses sur la Base1 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------

COL LOCAL_TRAN_ID FORMAT A13
COL IN_OUT FORMAT A6
COL DATABASE FORMAT A25
COL DBUSER_OWNER FORMAT A15
COL INTERFACE FORMAT A3
col SESS# format 999999
col BRANCH format A15
SELECT LOCAL_TRAN_ID, IN_OUT, DATABASE, DBUSER_OWNER, INTERFACE, SESS#, BRANCH
   FROM DBA_2PC_NEIGHBORS
/

--LOCAL_TRAN_ID IN_OUT DATABASE                  DBUSER_OWNER    INT   SESS# BRANCH
--------------- ------ ------------------------- --------------- --- ------- ---------------
--2.1.17612     in                               BOUCHE1M2021    N         1 0000
--2.1.17612     out    PDBM1INF                  BOUCHE1M2021    C         1 4


-------------------------------------------------------------------------------------------------
-- Activite 10.3.4 : Consultation des informations sur les transactions douteuses
-- sur la Base2 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- Activite 10.3.4.1 : Consultation des informations sur les transactions en attente 
-- de recouvrement sur la Base2 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-----------

set linesize 200
col GLOBAL_TRAN_ID format a12
col LOCAL_TRAN_ID format a12
col STATE format a10
col TRAN_COMMENT format a30
col OS_USER format a10
col OS_TERMINAL format a15
col HOST format a15
col DB_USER format a15
col COMMIT# format a10

select GLOBAL_TRAN_ID,
LOCAL_TRAN_ID, 
state ,
ADVICE,
TRAN_COMMENT,
FAIL_TIME,
FORCE_TIME,
RETRY_TIME,
OS_USER,
OS_TERMINAL,
HOST,
DB_USER,
COMMIT#  
from DBA_2PC_PENDING;

--GLOBAL_TRAN_ LOCAL_TRAN_I STATE      A TRAN_COMMENT                   FAIL_TIME FORCE_TIM RETRY_TIM OS_USER    OS_TERMINAL     HOST            DB_USER         COMMIT#
-------------- ------------ ---------- - ------------------------------ --------- --------- --------- ---------- --------------- --------------- --------------- ----------
--PDBL3MIA.a1b 9.24.13851   committed    ORA-2PC-CRASH-TEST-6           14-MAY-21           14-MAY-21 oracle     pts/0           MbdsDBONCLOUD   BOUCHE1M2021    148317615
--77c8e.2.1.17
--612

-- Que constatez vous ? le commit est dans un etat commited concernant la table produit

-------------------------------------------------------------------------------------------------
-- Activite 10.3.4.2 : Consultation des informations sur les noeuds impliques dans des 
-- transactions douteuses sur la Base2 SANS DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------

COL LOCAL_TRAN_ID FORMAT A13
COL IN_OUT FORMAT A6
COL DATABASE FORMAT A25
COL DBUSER_OWNER FORMAT A15
COL INTERFACE FORMAT A3
col SESS# format 999999
col BRANCH format A15
SELECT LOCAL_TRAN_ID, IN_OUT, DATABASE, DBUSER_OWNER, INTERFACE, SESS#, BRANCH
   FROM DBA_2PC_NEIGHBORS
/

--no rows selected

-- Que constatez vous ? Aucun noeud impliques dans des transactions douteuses

----------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
-- Activite 10.4 : Consultation des informations sur les transactions douteuses
-- sur les Base1 et Base2 AVEC DESACTIVATION DU RECOUVREMENT DISTRIBUE, PANNE 6
-------------------------------------------------------------------------------------------------

