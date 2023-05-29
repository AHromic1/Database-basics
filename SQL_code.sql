--1.

SELECT NVL(d.naziv,'Nema drzave') AS Drzava, 
       NVL(g.naziv,'Nema grada')  AS Grad, 
       k.naziv AS Kontinent 
  FROM kontinent k  
  left outer JOIN drzava d  ON k.kontinent_id=d.kontinent_id 
  left outer JOIN grad g ON d.drzava_id=g.drzava_id;


--2.
SELECT DISTINCT pl.naziv

FROM pravno_lice pl, ugovor_za_pravno_lice u

WHERE pl.pravno_lice_id = u.pravno_lice_id AND 

u.datum_potpisivanja <= To_Date('2016', 'yyyy') AND   u.datum_potpisivanja > To_Date('2014', 'yyyy');


--3.
SELECT d.naziv Drzava , p.naziv Proizvod,k.kolicina_proizvoda Kolicina_proizvoda 
FROM kolicina k, skladiste s, lokacija l, grad g, drzava d, kontinent c, proizvod p
WHERE k.proizvod_id = p.proizvod_id
AND k.skladiste_id = s.skladiste_id 
AND s.lokacija_id = l.lokacija_id 
AND l.grad_id = g.grad_id 
AND g.drzava_id = d.drzava_id
AND d.kontinent_id = c.kontinent_id
AND k.kolicina_proizvoda > 50
AND d.naziv NOT LIKE ('%s%s%')
; 


--4.
SELECT DISTINCT p.naziv, p.broj_mjeseci_garancije
FROM narudzba_proizvoda n, proizvod p, popust dis
WHERE p.proizvod_id = n.proizvod_id
AND dis.popust_id = n.popust_id
AND Mod(broj_mjeseci_garancije, 3) = 0
AND dis.postotak IS NOT NULL;


--5.
SELECT fl.ime || ' ' || fl.prezime "ime i prezime", o.naziv "Naziv odjela", '19084' "Indeks"
FROM  fizicko_lice fl, uposlenik u, odjel o,  kupac k
WHERE fl.fizicko_lice_id = u.uposlenik_id 
AND u.odjel_id = o.odjel_id
AND  u.uposlenik_id <> o.sef_id
AND   k.kupac_id = u.uposlenik_id
; 


--6.
SELECT n.narudzba_id  Narudzba_id, p.cijena  Cijena, Nvl( dis.postotak, 0 )  Postotak, Nvl(dis.postotak, 0)/100  PostotakRealni
FROM narudzba_proizvoda n
left OUTER JOIN popust dis ON n.popust_id = dis.popust_id 
JOIN proizvod p ON p.proizvod_id = n.proizvod_id 
AND ((Nvl(dis.postotak, 0) * cijena)/100) < 200;


--7.
   SELECT Decode(Nvl(k1.kategorija_id, 0),
1, 'Komp Oprema',
0, 'Nema kategorije',
k1.naziv 
)  --treba else 

"Kategorija", 

Decode(Nvl(k2.kategorija_id, 0),
1, 'Komp Oprema',
0, 'Nema kategorije',
k2.naziv 
)  --treba else 
"Nadkategorija"

FROM kategorija k1 
left OUTER JOIN  kategorija k2 ON k1.nadkategorija_id = k2.kategorija_id;


--8.
SELECT Trunc(Months_Between(To_Date('10.10.2020.', 'dd.mm.yyyy.'),datum_potpisivanja) /12)  Godina,       

Trunc(Mod(Months_Between(To_Date('10.10.2020','dd.mm.yyyy'), datum_potpisivanja), 12))  Mjeseci,

(To_Date('10.10.2020.', 'dd.mm.yyyy.') - (Add_Months(datum_potpisivanja,      --krajnji - mjeseci - pocetni 
(Months_Between(To_Date('10.10.2020.', 'dd.mm.yyyy.'), datum_potpisivanja)))))  Dana

FROM ugovor_za_pravno_lice 
WHERE (MONTHS_BETWEEN ( To_Date('10.10.2020.', 'dd.mm.yyyy.' ), datum_potpisivanja) ) / 12 > To_Number(SubStr(ugovor_id, 1, 2));


--9.
SELECT fl.ime ime, fl.prezime prezime, 
Decode(o.naziv,
'Managment', 'MANAGER',            
'Human Resources', 'HUMAN',
'OTHER' ) odjel,
o.odjel_id 
FROM fizicko_lice fl, uposlenik u, odjel o 
WHERE fl.fizicko_lice_id = u.uposlenik_id AND u.odjel_id = o.odjel_id
ORDER BY  fl.ime ASC, fl.prezime DESC;


--10.
SELECT k.naziv, pr1.naziv Najskuplji, pr2.naziv Najjeftiniji, (pp.maks + pp.mini) Zcijena
FROM    proizvod pr1, proizvod pr2, kategorija k,   --2 proizvoda za dvije cijene
(
SELECT k2.naziv name, Max(p2.cijena) maks, Min(p2.cijena) mini
FROM kategorija k2, proizvod p2
WHERE k2.kategorija_id = p2.kategorija_id
GROUP BY k2.naziv
) pp
WHERE k.naziv = pp.name
AND pr2.cijena = pp.mini  
AND pr1.cijena = pp.maks
ORDER BY (pp.maks + pp.mini) ASC;



------------------
--1 zadatak
--1
    SELECT DISTINCT  pl.naziv ResNaziv
    FROM pravno_lice pl, fizicko_lice fl
    WHERE pl.lokacija_id = fl.lokacija_id;
--2
SELECT DISTINCT To_Char(u.datum_potpisivanja, 'dd.MM.yyyy') "Datum Potpisivanja", pl.naziv ResNaziv
FROM ugovor_za_pravno_lice u, pravno_lice pl
WHERE u.pravno_lice_id = pl.pravno_lice_id AND   
u.datum_potpisivanja > ANY(
SELECT datum_kupoprodaje
FROM faktura f, narudzba_proizvoda np, proizvod p
WHERE f.faktura_id = np.faktura_id 
AND np.proizvod_id = p.proizvod_id
AND p.broj_mjeseci_garancije IS NOT NULL   
)     ;

--3
SELECT p.naziv naziv
FROM proizvod p
WHERE p.kategorija_id = ANY (
SELECT pr.kategorija_id
FROM proizvod pr, kolicina k
WHERE k.proizvod_id = pr.proizvod_id
AND k.kolicina_proizvoda = (
SELECT Max(k2.kolicina_proizvoda)
FROM kolicina k2
)
)
;

--4
SELECT p.naziv "Proizvod", pl.naziv "Proizvodjac"
FROM proizvod p, proizvodjac pr, pravno_lice pl
WHERE p.proizvodjac_id = pr.proizvodjac_id AND pl.pravno_lice_id = pr.proizvodjac_id
    AND 
pr.proizvodjac_id IN (
SELECT p2.proizvodjac_id
FROM proizvod p2
WHERE p2.cijena > (
SELECT Avg(p3.cijena)
FROM proizvod p3)
) ;

--5
 SELECT Concat(Concat(fl.ime,' '),fl.prezime) "Ime i prezime", Sum(f.iznos) "iznos"
 FROM fizicko_lice fl, uposlenik u, kupac k, faktura f
 WHERE fl.fizicko_lice_id = u.uposlenik_id AND fl.fizicko_lice_id = k.kupac_id  AND f.kupac_id = k.kupac_id
 --AND  k.kupac_id = u.uposlenik_id --kupci su istovremeno i uposlenici 
 GROUP BY fl.ime, fl.prezime
 HAVING  Sum(f.iznos) > (SELECT Round(Avg(Sum(f2.iznos)),2)        --ne prihvata alijas!
 FROM faktura f2, fizicko_lice fl2
 WHERE f2.kupac_id =  fl2.fizicko_lice_id 
 GROUP BY fl2.ime, fl2.prezime
 );

--6
SELECT pl.naziv "naziv" 
FROM kurirska_sluzba ks, pravno_lice pl, faktura f, narudzba_proizvoda np, popust p, isporuka i 
WHERE ks.kurirska_sluzba_id = pl.pravno_lice_id
AND  f.faktura_id = np.faktura_id 
AND np.popust_id = p.popust_id
AND f.isporuka_id = i.isporuka_id
AND i.kurirska_sluzba_id = ks.kurirska_sluzba_id
AND p.postotak IS NOT NULL 
HAVING  Sum(np.kolicina_jednog_proizvoda) = (
SELECT Max(Sum( np2.kolicina_jednog_proizvoda))
FROM kurirska_sluzba ks2, faktura f2, narudzba_proizvoda np2, popust p2, isporuka i2 
WHERE f2.faktura_id = np2.faktura_id 
AND np2.popust_id = p2.popust_id
AND f2.isporuka_id = i2.isporuka_id
AND i2.kurirska_sluzba_id = ks2.kurirska_sluzba_id
AND p2.postotak IS NOT NULL 
GROUP BY ks2.kurirska_sluzba_id
)
GROUP BY naziv;

--7
SELECT fl.ime || ' ' || fl.prezime "Kupac", Sum(((p.cijena * Nvl(pt.postotak, 0))*np.kolicina_jednog_proizvoda)/100) "Usteda" --/100 zbog postotka
FROM fizicko_lice fl, kupac k, faktura f,  proizvod p, popust pt, narudzba_proizvoda np
WHERE k.kupac_id = fl.fizicko_lice_id
AND k.kupac_id = f.kupac_id
AND p.proizvod_id = np.proizvod_id
AND np.popust_id = pt.popust_id
AND np.faktura_id = f.faktura_id
GROUP BY fl.ime || ' ' || fl.prezime; 

--8
SELECT DISTINCT i.isporuka_id idisporuke, i.kurirska_sluzba_id idkurirske
FROM isporuka i, faktura f, narudzba_proizvoda np, proizvod p, popust pt
WHERE f.isporuka_id = i.isporuka_id
AND np.faktura_id = f.faktura_id
AND np.proizvod_id = p.proizvod_id
AND np.popust_id = pt.popust_id
AND 
np.popust_id IS NOT NULL AND p.broj_mjeseci_garancije IS NOT NULL;
 
--9
SELECT p.naziv naziv, p.cijena cijena
FROM proizvod p
WHERE p.cijena > (
SELECT Round(Avg(Max(p2.cijena)),2)
FROM proizvod p2
GROUP BY p2.kategorija_id
) ;

--10
SELECT p.naziv naziv, p.cijena cijena
FROM proizvod p, kategorija k
WHERE p.kategorija_id=k.kategorija_id
AND p.cijena < ALL(
SELECT Avg(p2.cijena)
FROM proizvod p2
                WHERE p2.kategorija_id IN (SELECT k.kategorija_id
                                          FROM kategorija k
                                          WHERE k.nadkategorija_id  != p.kategorija_id)
                GROUP BY p2.kategorija_id 

);


--2 ZADATAK

CREATE TABLE TabelaA (
id INTEGER PRIMARY key,
naziv VARCHAR2(15),
datum DATE,
cijelibroj INTEGER,
realnibroj NUMBER,
CONSTRAINT A_R_BR CHECK (realnibroj > 5),
CONSTRAINT A_C_BR CHECK(cijelibroj NOT BETWEEN 5 AND 15)
);

CREATE TABLE TabelaB (
id INTEGER PRIMARY key,
naziv VARCHAR2(15),
datum DATE,
cijelibroj INTEGER,
realnibroj NUMBER,
fkTabelaA INTEGER NOT NULL,
CONSTRAINT B_C_BR UNIQUE(cijelibroj),
CONSTRAINT FK_TABELAA FOREIGN KEY (fkTabelaA) REFERENCES TabelaA(id)
);

CREATE TABLE TabelaC (
id INTEGER PRIMARY key,
naziv VARCHAR2 (15) NOT NULL,
datum DATE,
cijelibroj INTEGER NOT NULL,
realnibroj NUMBER,
fkTabelaB INTEGER NULL,
CONSTRAINT FkCnst FOREIGN KEY (fkTabelaB) REFERENCES TabelaB(id)
);

--provjera da li je sve ok kreirano
SELECT * FROM TabelaA;
SELECT * FROM TabelaB;
SELECT * FROM TabelaC;

INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (1, 'tekst', NULL, NULL, 6.2);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (2, NULL, NULL, 3, 5.26);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (3, 'tekst', NULL, 1, NULL);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (4, NULL, NULL, NULL, NULL);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (5, 'tekst', NULL, 16, 6.78);

--TABELAB
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (1, NULL, NULL, 1, NULL, 1);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (2, NULL, NULL, 3, NULL, 1);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (3, NULL, NULL, 6, NULL, 2);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (4, NULL, NULL, 11, NULL, 2);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (5, NULL, NULL, 22, NULL, 3);


--TABELAC
INSERT INTO TabelaC (id, naziv, datum, cijelibroj, realnibroj, fkTabelaB) VALUES (1, 'YES', NULL, 33, NULL, 4);
INSERT INTO TabelaC (id, naziv, datum, cijelibroj, realnibroj, fkTabelaB) VALUES (2, 'NO', NULL, 33, NULL, 2);
INSERT INTO TabelaC (id, naziv, datum, cijelibroj, realnibroj, fkTabelaB) VALUES (3, 'NO', NULL, 55, NULL, 1);
--zadatak
INSERT INTO TabelaA (id,naziv,datum,cijeliBroj,realniBroj) VALUES (6,'tekst',null,null,6.20);  --izvrsava se bez problema, sva ogranicenja (constraints) su zadovoljena

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,1,null,1); --NECE se izvrsiti jer je narusen
--unique constraint definisan nad kolonom cijeliBroj, tj. vec postoji cijeliBroj = 1 u tabeli

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,123,null,6); --izvrsava se bez problema, sva ogranicenja (constraints) su zadovoljena


INSERT INTO TabelaC (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaB) VALUES (4,'NO',null,55,null,null);  --izvrsava se bez problema, sva ogranicenja (constraints) su zadovoljena



Update TabelaA set naziv = 'tekst' Where naziv is null and cijeliBroj is not null;   --izvrsava se bez problema, sva ogranicenja (constraints) su zadovoljena


Drop table tabelaB;  --NECE se izvrsiti zbog narusavanja referencijalnog integriteta - TabelaC sadrzi kolonu popunjenu s foreign key vrijednostima koji referenciraju kolonu id u TabelaB


Delete from TabelaA where realniBroj is null;  --NECE se izvrsiti zbog narusavanja referencijalnog integriteta - TabelaB sadrzi kolonu 
--popunjenu s foreign key vrijednostima koji referenciraju kolonu id u TabelaA te u toj koloni se nalazi i id 3, koji bi bio izbrisan ovom komandom (redovi za brsanje bi bili id 3 i 4,
--jer je tu realnibroj null)

Delete from TabelaA where id = 5;    --izvrsava se bez problema, sva ogranicenja (constraints) su zadovoljena te foreign key tabele TabelaB ne referencira ovaj id
 

Update TabelaB set fktabelaA = 4 where fktabelaA = 2;  --izvrsava se bez problema, sva ogranicenja (constraints) su zadovoljena, te postoje i id 2 i 4 u TabelaA

Alter Table tabelaA add Constraint cst Check (naziv like 'tekst'); --izvrsava se bez problema, jer su svi nazivi koji nisu null vec 'tekst' 

               

--Rezultati za provjeru su.
Select Sum(id) From TabelaA ;--Rezultat 16
Select Sum(id) FROM TabelaB; --Rezultat 22
Select Sum(id) From TabelaC; --Rezultat 10

--rezultati su tacni!




--3 ZADATAK

  --brisanje tabela
     
     DROP TABLE TabelaA;
     DROP TABLE TabelaB;
     DROP TABLE TabelaC;
 --ponovo kreiranje i punjenje podacima
CREATE TABLE TabelaA (
id INTEGER PRIMARY key,
naziv VARCHAR2(15),
datum DATE,
cijelibroj INTEGER,
realnibroj NUMBER,
CONSTRAINT A_R_BR CHECK (realnibroj > 5),
CONSTRAINT A_C_BR CHECK(cijelibroj NOT BETWEEN 5 AND 15)
);

CREATE TABLE TabelaB (
id INTEGER PRIMARY key,
naziv VARCHAR2(15),
datum DATE,
cijelibroj INTEGER,
realnibroj NUMBER,
fkTabelaA INTEGER NOT NULL,
CONSTRAINT B_C_BR UNIQUE(cijelibroj),
CONSTRAINT FK_TABELAA FOREIGN KEY (fkTabelaA) REFERENCES TabelaA(id)
);

CREATE TABLE TabelaC (
id INTEGER PRIMARY key,
naziv VARCHAR2 (15) NOT NULL,
datum DATE,
cijelibroj INTEGER NOT NULL,
realnibroj NUMBER,
fkTabelaB INTEGER NULL,
CONSTRAINT "FkCnst" FOREIGN KEY (fkTabelaB) REFERENCES TabelaB(id)     --navodnici!
);

--provjera
SELECT * FROM TabelaA;
SELECT * FROM TabelaB;
SELECT * FROM TabelaC;

--dodavanje vrijednosti
--TABELAA
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (1, 'tekst', NULL, NULL, 6.2);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (2, NULL, NULL, 3, 5.26);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (3, 'tekst', NULL, 1, NULL);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (4, NULL, NULL, NULL, NULL);
INSERT INTO TabelaA (id, naziv, datum, cijelibroj, realnibroj) VALUES (5, 'tekst', NULL, 16, 6.78);

--TABELAB
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (1, NULL, NULL, 1, NULL, 1);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (2, NULL, NULL, 3, NULL, 1);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (3, NULL, NULL, 6, NULL, 2);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (4, NULL, NULL, 11, NULL, 2);
INSERT INTO TabelaB (id, naziv, datum, cijelibroj, realnibroj, fkTabelaA) VALUES (5, NULL, NULL, 22, NULL, 3);


--TABELAC
INSERT INTO TabelaC (id, naziv, datum, cijelibroj, realnibroj, fkTabelaB) VALUES (1, 'YES', NULL, 33, NULL, 4);
INSERT INTO TabelaC (id, naziv, datum, cijelibroj, realnibroj, fkTabelaB) VALUES (2, 'NO', NULL, 33, NULL, 2);
INSERT INTO TabelaC (id, naziv, datum, cijelibroj, realnibroj, fkTabelaB) VALUES (3, 'NO', NULL, 55, NULL, 1);


         

 --sekvence
 CREATE SEQUENCE seq1
INCREMENT BY 1
START WITH 1;

CREATE SEQUENCE seq2
INCREMENT BY 1
START WITH 1
  MINVALUE 0 --radi!
;


 CREATE TABLE TabelaABekap AS SELECT * FROM TabelaA;   --ovako kreirati da bi se i u trigger mogli kasnije redovi ubaciti!
  ALTER TABLE TabelaABekap ADD (cijeliBrojB INTEGER,
                                sekvenca INTEGER );

   --provjera da li je sve ispravno kreirano, moglo je i describe
SELECT *
FROM TabelaABekap;



--trigeri
--prvi
CREATE OR REPLACE TRIGGER t1
AFTER INSERT ON TabelaB
FOR EACH ROW  --svaki red
DECLARE
 Aid NUMBER := NULL;  --inic
 rrA TabelaA%ROWTYPE;
BEGIN
 SELECT id
 INTO Aid
 FROM TabelaABekap
 WHERE id = :new.fktabelaA;

 SELECT *
 INTO rrA
 FROM TabelaA
 WHERE id = :new.fktabelaA;

 IF Aid IS NOT NULL
 THEN
  UPDATE TabelaABekap
  SET cijeliBrojB = Nvl(cijeliBrojB, 0) + :new.cijeliBroj
  WHERE id = Aid;
 ELSIF Aid IS NULL THEN
  INSERT INTO TabelaABekap VALUES(rrA.id, rrA.naziv, rrA.datum, rrA.cijeliBroj, rrA.realniBroj, :new.cijeliBroj, seq1.NEXTVAL);
 END IF;
END;
/

  
 CREATE TABLE TabelaBCheck(sekvenca INTEGER PRIMARY KEY);
--drugi
CREATE OR REPLACE TRIGGER t2  --moglo je i bez replace
AFTER DELETE ON TabelaB
BEGIN
 INSERT INTO TabelaBCheck VALUES (seq2.NEXTVAL - 1);
END;
/

--procedura
CREATE OR REPLACE PROCEDURE p(broj NUMBER)
IS
 n_id NUMBER;  
 sumaCB_A INTEGER;  --moze i number, ali jer su ids nema potrebe    
BEGIN
 SELECT Sum(cijeliBroj)
 INTO sumaCB_A
 FROM TabelaA;  --SUMA

 SELECT Max(id)+1  --maksimalni je ujedno i posljednji po default-u
 INTO n_id
 FROM TabelaC;

 FOR i IN 1 .. sumaCB_A LOOP  --unosi se onoliko puta kolika je suma
  INSERT INTO tabelaC VALUES (n_id, 'naziv', NULL, broj, NULL, 1);  --dodala neke vrijednosti, da se slazu, zbog not null constraints
  n_id:= n_id + 1;
 END LOOP;

END p;
 /

--provjere
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,2,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,4,null,2);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (8,null,null,8,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (9,null,null,5,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (10,null,null,7,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (11,null,null,9,null,5);
Delete From TabelaB where id not in (select FkTabelaB from TabelaC);    
Alter TABLE tabelaC drop constraint "FkCnst";  
Delete from TabelaB where 1=1; 

--izvrsenje procedure 
EXECUTE p(1);    
   

Select SUM(id*3 + cijeliBrojB*3) from TabelaABekap;   --138
Select Sum(id*3 + cijeliBroj*3) from TabelaC;         --1251
Select Sum(MOD(sekvenca,10)*3) from TabelaBCheck;     --9 

Select SUM(id*7 + cijeliBrojB*7) from TabelaABekap;	  --322
Select Sum(id*7 + cijeliBroj*7) from TabelaC;		  --2919
Select Sum(MOD(sekvenca,10)*7) from TabelaBCheck;         --21




