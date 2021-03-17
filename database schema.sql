-- CS4400: Introduction to Database Systems
-- Summer 2020
-- Phase II Create Table and Insert Statements Template

-- Team 24
-- John Taylor (jtaylor362)
-- Alexandre Andrade (aandrade32)
-- Alexis Rugg (arugg3)
-- Hanna Hamilton (hhamilton33)

-- Directions:
-- Please follow all instructions from the Phase II assignment PDF.
-- This file must run without error for credit.
-- Create Table statements should be manually written, not taken from an SQL Dump.
-- Rename file to cs4400_phase2_teamX.sql before submission

-- CREATE TABLE STATEMENTS BELOW

DROP DATABASE IF EXISTS phase2_team24;
CREATE DATABASE IF NOT EXISTS phase2_team24;
USE phase2_team24;

DROP DATABASE IF EXISTS phase2_team24;
CREATE DATABASE IF NOT EXISTS phase2_team24;
USE phase2_team24;

DROP TABLE IF EXISTS product;
CREATE TABLE product (
	pid char(5) NOT NULL,
	ptype char(15) NOT NULL,
	color char(10) NOT NULL,
	PRIMARY KEY (pid),
    KEY (color, ptype)
);

DROP TABLE IF EXISTS business;
CREATE TABLE business (
	bname char(40) NOT NULL,
	street char(30) NOT NULL,
	city char(20) NOT NULL,
	state char(10) NOT NULL,
	zip decimal(5,0) NOT NULL,
	PRIMARY KEY (bname),
    KEY (street, city, state, zip)
);

DROP TABLE IF EXISTS manufacturer;
CREATE TABLE manufacturer (
	mname char(40) NOT NULL,
	catalogcapacity int NOT NULL,
	PRIMARY KEY (mname),
	CONSTRAINT fk1 FOREIGN KEY (mname) REFERENCES business (bname)
);

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
	iname char(40) NOT NULL,
	street char(30) NOT NULL,
	city char(20) NOT NULL,
	state char(10) NOT NULL,
	zip decimal(5,0) NOT NULL,
	PRIMARY KEY (iname),
	CONSTRAINT fk2 FOREIGN KEY (iname) REFERENCES business (bname)
);

DROP TABLE IF EXISTS catalogitem;
CREATE TABLE catalogitem (
	ciid char(5) NOT NULL,
	manname char(40) NOT NULL,
	price decimal(5,2),
	PRIMARY KEY (ciid, manname),
	CONSTRAINT fk3 FOREIGN KEY (ciid) REFERENCES product (pid),
	CONSTRAINT fk4 FOREIGN KEY (manname) REFERENCES manufacturer (mname)
);

DROP TABLE IF EXISTS hospital;
CREATE TABLE hospital (
	hname char(40) NOT NULL,
	maxdoctors int NOT NULL,
	budget int NOT NULL,
	PRIMARY KEY (hname),
	CONSTRAINT fk5 FOREIGN KEY (hname) REFERENCES business (bname)
);

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
	tid decimal(4,0) NOT NULL,
	tdate date NOT NULL,
	buys char(40),
	PRIMARY KEY (tid),
	CONSTRAINT fk6 FOREIGN KEY (buys) REFERENCES hospital (hname)
);

DROP TABLE IF EXISTS tcontains;
CREATE TABLE tcontains (
	prodid char(5) NOT NULL,
	manid char(40) NOT NULL,
	transid decimal(4,0) NOT NULL,
	transcount int NOT NULL,
	PRIMARY KEY (transid, manid, prodid),
	CONSTRAINT fk7 FOREIGN KEY (prodid, manid) REFERENCES catalogitem (ciid, manname),
	CONSTRAINT fk8 FOREIGN KEY (transid) REFERENCES transactions (tid)
);

DROP TABLE IF EXISTS has;
CREATE TABLE has (
	prodid char(5) NOT NULL,
	invname char(40) NOT NULL,
	pcount int NOT NULL,
	PRIMARY KEY (prodid, invname),
	CONSTRAINT fk9 FOREIGN KEY (prodid) REFERENCES product (pid),
	CONSTRAINT fk10 FOREIGN KEY (invname) REFERENCES inventory (iname)
);

DROP TABLE IF EXISTS sysuser;
CREATE TABLE sysuser (
	username char(20) NOT NULL,
	email char(30) NOT NULL UNIQUE,
	upassword char(10) NOT NULL,
	fname char(10) NOT NULL,
	lname char(20) NOT NULL,
	PRIMARY KEY (username),
    KEY (email)
);

DROP TABLE IF EXISTS doctor;
CREATE TABLE doctor (
	docusername char(20) NOT NULL,
	reportsto char(20),
	worksat char(40) NOT NULL,
	PRIMARY KEY (docusername),
	CONSTRAINT fk11 FOREIGN KEY (docusername) REFERENCES sysuser (username),
	CONSTRAINT fk12 FOREIGN KEY (reportsto) REFERENCES doctor (docusername),
	CONSTRAINT fk13 FOREIGN KEY (worksat) REFERENCES hospital (hname)
);

DROP TABLE IF EXISTS usagelog;
CREATE TABLE usagelog (
	ulid decimal(5,0) NOT NULL,
	ultimestamp timestamp NOT NULL,
	usedby char(20) NOT NULL,
	PRIMARY KEY (ulid),
	CONSTRAINT fk14 FOREIGN KEY (usedby) REFERENCES doctor (docusername)
);

DROP TABLE IF EXISTS used;
CREATE TABLE used (
	logid decimal(5,0) NOT NULL,
	prodid char(5) NOT NULL,
	usecount int NOT NULL,
	PRIMARY KEY (logid, prodid),
	CONSTRAINT fk15 FOREIGN KEY (logid) REFERENCES usagelog (ulid),
	CONSTRAINT fk16 FOREIGN KEY (prodid) REFERENCES product (pid)
);


DROP TABLE IF EXISTS administrator;
CREATE TABLE administrator (
	adminusername char(20) NOT NULL,
	manages char(40) NOT NULL,
	PRIMARY KEY (adminusername),
	CONSTRAINT fk17 FOREIGN KEY (adminusername) REFERENCES sysuser (username),
	CONSTRAINT fk18 FOREIGN KEY (manages) REFERENCES business (bname)
);

-- INSERT STATEMENTS BELOW

INSERT INTO product VALUES ('WHMSK','mask','white'),('BLMSK','mask','blue'),('RDMSK','mask','red'),('GRMSK','mask','green'),('WHRES','respirator','white'),('YLRES','respirator','yellow'),('ORRES','repirator','orange'),('CLSHD','shield','clear'),('GRGOG','goggles','green'),('ORGOG','goggles','orange'),('WHGOG','goggles','white'),('BKGOG','goggles','black'),('BLSHC','shoe cover','blue'),('BLHOD','hood','blue'),('BLGWN','gown','blue'),('GRSHC','shoe cover','green'),('GRHOD','hood','green'),('GRGWN','gown','green'),('GYSHC','shoe cover','grey'),('GYHOD','hood','grey'),('GYGWN','gown','grey'),('WHSHC','shoe cover','white'),('WHHOD','hood','white'),('WHGWN','gown','white'),('BKSTE','stethoscope','black'),('WHSTE','stethoscope','white'),('SISTE','stethoscope','silver'),('BKGLO','gloves','black'),('WHGLO','gloves','white'),('GRGLO','gloves','green');

INSERT INTO business VALUES ("Children's Healthcare of Atlanta", 'Clifton Rd NE', 'Atlanta', 'Georgia', 30332),('Piedmont Hospital', 'Peachtree Rd NW', 'Atlanta', 'Georgia', 30309),('Northside Hospital', 'Johnson Ferry Road NE', 'Sandy Springs', 'Georgia', 30342),('Emory Midtown', 'Peachtree St NE', 'Atlanta', 'Georgia', 30308),('Grady Hospital', 'Jesse Hill Jr Dr SE', 'Atlanta', 'Georgia', 30303),('PPE Empire', 'Ponce De Leon Ave', 'Atlanta', 'Georgia', 30308),('Buy Personal Protective Equipment, Inc', 'Spring St', 'Atlanta', 'Georgia', 30313),('Healthcare Supplies of Atlanta', 'Peachstree St', 'Atlanta', 'Georgia', 30308),('Georgia Tech Protection Lab', 'North Ave NW', 'Atlanta', 'Georgia', 30332),('Marietta Mask Production Company', 'Appletree Way', 'Marietta', 'Georgia', 30061),('S&J Corporation', 'Juniper St', 'Atlanta', 'Georgia', 30339);

INSERT INTO manufacturer VALUES ('PPE Empire', 20),('Buy Personal Protective Equipment, Inc', 25),('Healthcare Supplies of Atlanta', 20),('Georgia Tech Protection Lab', 27),('Marietta Mask Production Company', 15),('S&J Corporation', 22);

INSERT INTO inventory VALUES("Children's Healthcare of Atlanta", "Storage St", 'Atlanta', 'Georgia', 30309),('Piedmont Hospital', 'Warehouse Way', 'Atlanta', 'Georgia', 30332),('Northside Hospital', 'Depot Dr', 'Dunwoody', 'Georgia', 30338),('Emory Midtown', 'Inventory Ct', 'Atlanta', 'Georgia',30308 ),('Grady Hospital', 'Storehouse Pkwy', 'Atlanta', 'Georgia', 30313 ), ('PPE Empire', 'Cache Ct', 'Lawrenceville', 'Georgia', 30043),('Buy Personal Protective Equipment, Inc', 'Stockpile St', 'Decatur', 'Georgia', 30030),('Healthcare Supplies of Atlanta', 'Depository Dr', 'Atlanta', 'Georgia', 30303),('Georgia Tech Protection Lab', 'Storehouse St', 'Atlanta', 'Georgia', 30332),('Marietta Mask Production Company', 'Repository Way', 'Marietta', 'Georgia', 30008),('S&J Corporation', 'Stash St', 'Suwanee', 'Georgia', 30024);


INSERT INTO catalogitem VALUES ('WHMSK', 'PPE Empire', 1.25),('BLMSK', 'PPE Empire', 1.35),('RDMSK', 'PPE Empire', 1.3),('GRMSK', 'PPE Empire', 1.45),('WHRES', 'PPE Empire', 4.8),('YLRES', 'PPE Empire', 5.1),('ORRES', 'PPE Empire', 4.5),('BLSHC', 'Buy Personal Protective Equipment, Inc', 0.9),('BLHOD', 'Buy Personal Protective Equipment, Inc', 2.1),('BLGWN', 'Buy Personal Protective Equipment, Inc', 3.15),('GRSHC', 'Buy Personal Protective Equipment, Inc', 0.9),('GRHOD', 'Buy Personal Protective Equipment, Inc', 2.1),('GRGWN', 'Buy Personal Protective Equipment, Inc', 3.15),('GYSHC', 'Buy Personal Protective Equipment, Inc', 0.9),('GYHOD', 'Buy Personal Protective Equipment, Inc', 2.1),('GYGWN', 'Buy Personal Protective Equipment, Inc', 3.15),('WHSHC', 'Buy Personal Protective Equipment, Inc', 0.9),('WHHOD', 'Buy Personal Protective Equipment, Inc', 2.1),('WHGWN', 'Buy Personal Protective Equipment, Inc', 3.15),('ORGOG', 'Healthcare Supplies of Atlanta', 3),('RDMSK', 'Healthcare Supplies of Atlanta', 1.45),('CLSHD', 'Healthcare Supplies of Atlanta', 6.05),('BLSHC', 'Healthcare Supplies of Atlanta', 1),('BLHOD', 'Healthcare Supplies of Atlanta', 2),('BLGWN', 'Healthcare Supplies of Atlanta', 3),('YLRES', 'Healthcare Supplies of Atlanta', 5.5),('WHMSK', 'Healthcare Supplies of Atlanta', 1.1),('BLMSK', 'Healthcare Supplies of Atlanta', 1.05),('CLSHD', 'Georgia Tech Protection Lab', 5.95),('ORGOG', 'Georgia Tech Protection Lab', 3.2),('WHGOG', 'Georgia Tech Protection Lab', 3.2),('BKGOG', 'Georgia Tech Protection Lab', 3.2),('GYSHC', 'Georgia Tech Protection Lab', 0.75),('GYHOD', 'Georgia Tech Protection Lab', 1.8),('GYGWN', 'Georgia Tech Protection Lab', 3.25),('GRSHC', 'Marietta Mask Production Company', 0.8),('GRHOD', 'Marietta Mask Production Company', 1.65),('GRGWN', 'Marietta Mask Production Company', 2.95),('GRMSK', 'Marietta Mask Production Company', 1.25),('GRGOG', 'Marietta Mask Production Company', 3.25),('BKSTE', 'S&J Corporation', 5.2),('WHSTE', 'S&J Corporation', 5),('SISTE', 'S&J Corporation', 5.1),('BKGLO', 'S&J Corporation', 0.3),('WHGLO', 'S&J Corporation', 0.3),('GRGLO', 'S&J Corporation', 0.3);

INSERT INTO hospital VALUES ("Children's Healthcare of Atlanta", 6, 80000),('Piedmont Hospital', 7, 95000), ('Northside Hospital', 9, 72000),('Emory Midtown', 13, 120000),('Grady Hospital', 10, 81000);

INSERT INTO transactions VALUES (0001, '2020-03-10', "Children's Healthcare of Atlanta"),(0002, '2020-03-10', "Children's Healthcare of Atlanta"),(0003, '2020-03-10', 'Emory Midtown'),(0004, '2020-03-10', 'Grady Hospital'),(0005, '2020-03-10', 'Northside Hospital'),(0006, '2020-03-10', "Children's Healthcare of Atlanta"),(0007, '2020-03-10', 'Piedmont Hospital'),(0008, '2020-05-01', 'Northside Hospital'),(0009, '2020-05-01', "Children's Healthcare of Atlanta"),(0010, '2020-05-01', 'Northside Hospital'), (0011, '2020-05-01', 'Northside Hospital'),(0012, '2020-05-25', 'Emory Midtown'),(0013, '2020-05-25', "Children's Healthcare of Atlanta"),(0014, '2020-05-25', 'Emory Midtown'),(0015, '2020-05-25', 'Emory Midtown'),(0016, '2020-05-25', 'Northside Hospital'),(0017, '2020-06-03', 'Grady Hospital'),(0018, '2020-06-03', 'Grady Hospital'), (0019, '2020-06-03', 'Grady Hospital'),(0020, '2020-06-03', 'Piedmont Hospital'),(0021, '2020-06-04', 'Piedmont Hospital');

INSERT INTO tcontains VALUES ('WHMSK', 'PPE Empire', 0001, 500), ('BLMSK', 'PPE Empire',0001, 500),('BLSHC', 'Buy Personal Protective Equipment, Inc', 0002, 300),('BLMSK','Healthcare Supplies of Atlanta' , 0003, 500),('ORGOG', 'Healthcare Supplies of Atlanta' ,0004, 150),('RDMSK', 'Healthcare Supplies of Atlanta',0004, 150), ('CLSHD', 'Healthcare Supplies of Atlanta',0004, 200),('BLSHC', 'Healthcare Supplies of Atlanta',0004, 100), ('WHMSK','Healthcare Supplies of Atlanta', 0005, 300), ('BLSHC','Buy Personal Protective Equipment, Inc', 0006, 400), ('GRMSK', 'Marietta Mask Production Company',0007,  100), ('GRGOG','Marietta Mask Production Company', 0007, 300), ('ORGOG','Georgia Tech Protection Lab', 0008, 200), ('WHGOG', 'Georgia Tech Protection Lab',0008, 200), ('GRSHC', 'Marietta Mask Production Company' ,0009, 500), ('GRHOD','Marietta Mask Production Company' , 0009, 500), ('WHGLO', 'S&J Corporation',0010, 500),('WHHOD','Buy Personal Protective Equipment, Inc' , 0011, 200),('WHGWN','Buy Personal Protective Equipment, Inc' ,  0011, 200), ('BLSHC','Buy Personal Protective Equipment, Inc' , 0012,  50),('BLHOD','Healthcare Supplies of Atlanta', 0013, 100), ('BLGWN','Healthcare Supplies of Atlanta', 0013, 100),('WHRES', 'PPE Empire',0014, 300), ('YLRES', 'PPE Empire',0014, 200), ('ORRES', 'PPE Empire',0014, 300 ),('GYGWN', 'Buy Personal Protective Equipment, Inc',0015, 50), ('CLSHD', 'Healthcare Supplies of Atlanta',0016, 20), ('ORGOG', 'Healthcare Supplies of Atlanta',0016, 300), ('BLHOD', 'Healthcare Supplies of Atlanta', 0016, 100), ('RDMSK', 'Healthcare Supplies of Atlanta',0017, 200), ('CLSHD', 'Healthcare Supplies of Atlanta',0017, 180), ('WHHOD', 'Buy Personal Protective Equipment, Inc',0018, 500), ('GYGWN','Buy Personal Protective Equipment, Inc', 0019, 300),('BKSTE', 'S&J Corporation',0020, 50), ('WHSTE','S&J Corporation', 0020, 50), ('CLSHD', 'Georgia Tech Protection Lab', 0021, 100),('ORGOG', 'Georgia Tech Protection Lab',0021, 200);

INSERT INTO has VALUES ('WHMSK', "Children's Healthcare of Atlanta", 5),('BLMSK', "Children's Healthcare of Atlanta", 220), ('WHRES', "Children's Healthcare of Atlanta", 280),('CLSHD', "Children's Healthcare of Atlanta",  100),('GRGOG', "Children's Healthcare of Atlanta", 780),('ORGOG', "Children's Healthcare of Atlanta", 100),('BLSHC', "Children's Healthcare of Atlanta", 460),('BLHOD', "Children's Healthcare of Atlanta", 100),('BLGWN', "Children's Healthcare of Atlanta",  80),('GRSHC', "Children's Healthcare of Atlanta", 5),('WHSTE', "Children's Healthcare of Atlanta", 330),('BKGLO',"Children's Healthcare of Atlanta", 410), ('BLSHC','Piedmont Hospital', 3000),('BLHOD','Piedmont Hospital', 3000),('BLGWN', 'Piedmont Hospital',420),('GRSHC', 'Piedmont Hospital',740),('GRHOD', 'Piedmont Hospital',560),('GRGWN', 'Piedmont Hospital',840),('SISTE', 'Piedmont Hospital',460),('BKGLO', 'Piedmont Hospital',4210),('WHRES', 'Northside Hospital',110),('YLRES','Northside Hospital', 170),('ORRES','Northside Hospital', 350),('CLSHD','Northside Hospital', 410),('GRGOG','Northside Hospital', 1),('ORGOG', 'Northside Hospital',100), ('WHMSK', 'Emory Midtown',80),('BLMSK','Emory Midtown', 210),('RDMSK','Emory Midtown', 320),('GRMSK','Emory Midtown', 40),('WHRES', 'Emory Midtown',760),('YLRES', 'Emory Midtown',140),('ORRES','Emory Midtown', 20),('CLSHD', 'Emory Midtown',50),('GRGOG','Emory Midtown', 70),('ORGOG','Emory Midtown', 320),('WHGOG', 'Emory Midtown',140),('BKGOG', 'Emory Midtown',210),('BLSHC','Emory Midtown', 630),('BLHOD','Grady Hospital', 970),('BLGWN', 'Grady Hospital',310),('GRSHC', 'Grady Hospital',340),('GRHOD', 'Grady Hospital',570),('GRGWN', 'Grady Hospital',10),('GYSHC','Grady Hospital', 20),('GYHOD', 'Grady Hospital',280),('GYGWN', 'Grady Hospital',240),('WHSHC', 'Grady Hospital',180),('WHHOD', 'Grady Hospital',140),('WHGWN', 'Grady Hospital',150),('BKSTE', 'Grady Hospital',210),('WHSTE', 'Grady Hospital',170),('SISTE', 'Grady Hospital',180),('BKGLO', 'Grady Hospital',70),('WHGLO', 'Grady Hospital',140),('GRGLO', 'Grady Hospital',80),('WHMSK','PPE Empire', 850),('BLMSK', 'PPE Empire',1320),('RDMSK', 'PPE Empire',540),('GRMSK', 'PPE Empire',870),('WHRES', 'PPE Empire',500),('ORRES', 'PPE Empire',320),('BLSHC', 'Buy Personal Protective Equipment, Inc',900),('BLGWN', 'Buy Personal Protective Equipment, Inc',820),('GRSHC', 'Buy Personal Protective Equipment, Inc',700),('GRHOD', 'Buy Personal Protective Equipment, Inc',770),('GYSHC', 'Buy Personal Protective Equipment, Inc',250),('GYHOD', 'Buy Personal Protective Equipment, Inc',350),('GYGWN', 'Buy Personal Protective Equipment, Inc',850),('WHSHC', 'Buy Personal Protective Equipment, Inc',860),('WHHOD', 'Buy Personal Protective Equipment, Inc',700),('WHGWN', 'Buy Personal Protective Equipment, Inc',500),('ORGOG', 'Healthcare Supplies of Atlanta',860),('RDMSK', 'Healthcare Supplies of Atlanta',370),('CLSHD', 'Healthcare Supplies of Atlanta',990),('BLSHC', 'Healthcare Supplies of Atlanta',1370),('BLHOD', 'Healthcare Supplies of Atlanta',210),('BLGWN', 'Healthcare Supplies of Atlanta',680),('YLRES', 'Healthcare Supplies of Atlanta',890),('WHMSK', 'Healthcare Supplies of Atlanta',980),('BLMSK', 'Healthcare Supplies of Atlanta',5000),('CLSHD', 'Georgia Tech Protection Lab',620),('ORGOG', 'Georgia Tech Protection Lab',970),('WHGOG', 'Georgia Tech Protection Lab',940),('BKGOG', 'Georgia Tech Protection Lab',840),('GYSHC', 'Georgia Tech Protection Lab',610),('GYHOD', 'Georgia Tech Protection Lab',940),('GYGWN', 'Georgia Tech Protection Lab',700),('GRSHC', 'Marietta Mask Production Company',970),('GRHOD', 'Marietta Mask Production Company',750),('GRMSK', 'Marietta Mask Production Company',750),('GRGOG','Marietta Mask Production Company', 320),('BKSTE', 'S&J Corporation',200),('WHSTE', 'S&J Corporation',860),('WHGLO','S&J Corporation', 500),('GRGLO', 'S&J Corporation',420),('BKGLO', 'S&J Corporation',740) ;

INSERT INTO sysuser VALUES ('drCS4400', 'cs4400@gatech.edu', '30003000', 'Computer', 'Science'),('doctor_moss', 'mmoss7@gatech.edu', '12341234', 'Mark', 'Moss'),('drmcdaniel', 'mcdaniel@cc.gatech.edu', '12345678', 'Melinda', 'McDaniel'),('musaev_doc', 'aibek.musaev@gatech.edu', '87654321', 'Aibek', 'Musaev'), ('doctor1', 'doctor1@gatech.edu', '10001000', 'Doctor', 'One'),('doctor2', 'doctor2@gatech.edu', '20002000', 'Doctor', 'Two'), ('fantastic', 'ninth_doctor@gatech.edu', '99999999', 'Chris', 'Eccleston'), ('allons_y', 'tenth_doctor@gatech.edu', '10101010', 'David', 'Tennant'),('bow_ties _are_cool', 'eleventh_doctor@gatech.edu', '11111111', 'Matt', 'Smith'), ('sonic_shades', 'twelfth_doctor@gatech.edu', '12121212', 'Peter', 'Capaldi'), ('mcdreamy', 'dr_shepard@gatech.edu', '13311332', 'Derek', 'Shepard'), ('grey_jr', 'dr_grey@gatech.edu', '87878787', 'Meredith', 'Shepard'), ('young_doc', 'howser@gatech.edu', '80088008', 'Doogie', 'Howser'), ('dr_dolittle', 'dog_doc@gatech.edu', '37377373', 'John', 'Dolittle'), ('bones', 'doctor_mccoy@gatech.edu', '11223344', 'Leonard', 'McCoy'), ('doc_in_da_house', 'tv_doctor@gatech.edu', '30854124', 'Gregory', 'House'), ('jekyll_not_hyde', 'jekyll1886@gatech.edu', '56775213', 'Henry', 'Jekyll'), ('drake_remoray',  'f_r_i_e_n_d_s@gatech.edu', '24598543', 'Joey', 'Tribbiani'), ('Jones01', 'jones01@gatech.edu', '52935481', 'Johnes', 'Boys'), ('hannah_hills', 'managerEHH@gatech.edu', '13485102', 'Hannah', 'Hills'), ('henryjk', 'HenryJK@gatech.edu', '54238912', 'Henry', 'Kims'), ('aziz_01', 'ehh01@gatech.edu', '90821348', 'Amit', 'Aziz'), ('dr_mory', 'JackMM@gatech.edu', '12093015', 'Jack', 'Mory'), ('ppee_admin', 'ppee_admin@gatech.edu', '27536292', 'Admin', 'One'),('bppe_admin', 'bppe_admin@gatech.edu', '35045790', 'Admin', 'Two'), ('hsa_admin', 'hsa_admin@gatech.edu', '75733271', 'Jennifer', 'Tree'),('gtpl_admin', 'gtpl_admin@gatech.edu', '14506524', 'Shaundra', 'Apple'),('mmpc_admin', 'mmpc_admin@gatech.edu', '22193897', 'Nicholas', 'Cage'), ('sjc_admin', 'sjc_admin@gatech.edu', '74454118', 'Trey', 'Germs'), ('choa_admin', 'choa_admin@gatech.edu', '62469488', 'Addison', 'Ambulance'), ('piedmont_admin', 'piedmont_admin@gatech.edu', '36846830', 'Rohan', 'Right'), ('northside_admin', 'northside_admin@gatech.edu', '38613312', 'Johnathan', 'Smith'), ('emory_admin', 'emory_admin@gatech.edu', '33202257', 'Elizabeth', 'Tucker'), ('grady_admin', 'grady_admin@gatech.edu', '67181125', 'Taylor', 'Booker'),('Burdell', 'GeorgeBurdell@gatech.edu', '12345678', 'George', 'Burdell'), ('Buzz', 'THWG@gatech.edu', '98765432', 'Buzz', 'Tech');

INSERT INTO doctor VALUES ('drCS4400', NULL, "Children's Healthcare of Atlanta"),( 'doctor_moss', NULL, 'Piedmont Hospital'),('drmcdaniel', NULL, 'Northside Hospital'),( 'musaev_doc', NULL, 'Emory Midtown'), ('doctor1', NULL, 'Grady Hospital'), ('doctor2', 'drCS4400', "Children's Healthcare of Atlanta"),( 'fantastic', 'doctor_moss', 'Piedmont Hospital'),( 'allons_y', 'drmcdaniel', 'Northside Hospital'),( 'bow_ties _are_cool', 'musaev_doc', 'Emory Midtown'), ('sonic_shades', 'doctor1', 'Grady Hospital'), ('mcdreamy', 'drCS4400', "Children's Healthcare of Atlanta"),( 'grey_jr', 'doctor_moss', 'Piedmont Hospital'),( 'young_doc', 'drmcdaniel', 'Northside Hospital'), ('dr_dolittle', 'musaev_doc', 'Emory Midtown'), ('bones', 'doctor1', 'Grady Hospital'), ('doc_in_da_house', 'drCS4400', "Children's Healthcare of Atlanta"),( 'jekyll_not_hyde', 'doctor_moss', 'Piedmont Hospital'),( 'drake_remoray', 'drmcdaniel' ,'Northside Hospital'),( 'Jones01', 'musaev_doc', 'Emory Midtown'),('hannah_hills', 'doctor1', 'Grady Hospital'),( 'henryjk', 'drCS4400', "Children's Healthcare of Atlanta"),( 'aziz_01', 'doctor_moss', 'Piedmont Hospital'),( 'dr_mory', 'drmcdaniel', 'Northside Hospital'),('Burdell', 'drmcdaniel', 'Northside Hospital'),( 'Buzz', 'doctor_moss', 'Piedmont Hospital');

INSERT INTO usagelog VALUES (10000,  '2020-06-11 16:30', 'fantastic'),(10001,  '2020-06-11 17:00','jekyll_not_hyde'),(10002, '2020-06-11 17:03', 'young_doc'),(10003, '2020-06-12 8:23',	'fantastic'),(10004,  '2020-06-12 8:42',	'hannah_hills'),(10005,  '2020-06-12 9:00',	'mcdreamy'),(10006,	'2020-06-12 9:43',   'fantastic'),(10007,	'2020-06-12 10:11',	'doctor1'),(10008,	'2020-06-12 10:12' ,   'Jones01'),(10009,	'2020-06-12 10:23' ,  'henryjk'),(10010,	'2020-06-12 10:32',	'bones'),(10011,	'2020-06-12 11:00' ,   'dr_dolittle'),(10012,	'2020-06-12 11:14' ,   'drake_remoray'),(10013,	'2020-06-12 12:11' ,   'allons_y'),(10014,	'2020-06-12 13:23' ,   'dr_mory'),(10015,	'2020-06-12 13:52' ,'Jones01');

INSERT INTO administrator VALUES ('ppee_admin', 'PPE Empire'), ('bppe_admin', 'Buy Personal Protective Equipment, Inc'),( 'hsa_admin', 'Healthcare Supplies of Atlanta'),( 'gtpl_admin', 'Georgia Tech Protection Lab'),( 'mmpc_admin', 'Marietta Mask Production Company' ),('sjc_admin', 'S&J Corporation'),( 'choa_admin', "Children's Healthcare of Atlanta"), ('piedmont_admin', 'Piedmont Hospital'), ('northside_admin', 'Northside Hospital' ),('emory_admin', 'Emory Midtown'),( 'grady_admin', 'Grady Hospital'), ('Burdell', 'Northside Hospital'),( 'Buzz', 'Piedmont Hospital');

INSERT INTO used VALUES (10000,'GRMSK', 3), (10000,'GRGOG', 3), (10000,'WHSTE', 1), (10001, 'GRMSK', 5), (10001, 'BKSTE', 1), (10002, 'WHMSK', 4), (10003,'CLSHD', 2), (10003,'ORGOG', 1), (10003,'GRMSK', 2), (10003,'GRGOG', 1), (10003,'BKSTE', 1) ,(10004, 'ORGOG', 2), (10004, 'RDMSK', 4), (10004, 'CLSHD', 2), (10004, 'BLSHC', 4) ,(10005,'WHMSK', 4), (10005,'BLMSK', 4), (10005,'BLSHC', 8) ,(10006,'GRMSK', 2) ,(10007,'RDMSK', 3), (10007,'CLSHD', 3) ,(10008,'BLMSK', 5) ,(10009, 'GRSHC', 4), (10009, 'GRHOD', 4), (10009, 'WHMSK', 4) ,(10010,'RDMSK', 3), (10010,'BLSHC', 3) ,(10011 ,'BLMSK', 8) ,(10012,'ORGOG', 1), (10012,'WHGOG', 1), (10012,'WHGLO', 2) ,(10013,'WHHOD', 2) ,(10014,'WHGOG', 2), (10014,'WHGWN', 2) ,(10015 ,'BLMSK', 4) ;

