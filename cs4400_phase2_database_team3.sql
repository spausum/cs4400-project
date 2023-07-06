DROP DATABASE IF EXISTS sams;
CREATE DATABASE IF NOT EXISTS sams;
USE sams;

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
    airportID char(3),
    airport_name varchar(100) NOT NULL,
    city varchar(50) NOT NULL,
    state varchar(50) NOT NULL,
    PRIMARY KEY (airportID)  
);

DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
    legID char(50),
    departs char(3) NOT NULL,
    arrives char(3) NOT NULL,
    distance smallint,
    PRIMARY KEY (legID),
    FOREIGN KEY (departs) REFERENCES airport (airportID),
	FOREIGN KEY (arrives) REFERENCES airport (airportID)
);

DROP TABLE IF EXISTS route;
CREATE TABLE route (
    routeID char(50),
    PRIMARY KEY (routeID)  
);

DROP TABLE IF EXISTS contain_of;
CREATE TABLE contain_of (
    sequence tinyint,
    legID char(50),
    routeID char(50) NOT NULL,
    PRIMARY KEY (sequence, legID, routeID),
    FOREIGN KEY (legID) REFERENCES leg (legID),
	FOREIGN KEY (routeID) REFERENCES route (routeID)
);

DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
    flightID char(50),
    routeID char(50) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES route (routeID)
);

DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket (
    ticketID char(50),
    cost smallint,
    buys char (50) NOT NULL,
    deplanes char(3) NOT NULL,
    offers char(50) NOT NULL,
    PRIMARY KEY (ticketID),
    FOREIGN KEY (offers) REFERENCES flight (flightID),
    FOREIGN KEY (deplanes) REFERENCES airport (airportID)
);

DROP TABLE IF EXISTS seat;
CREATE TABLE seat (
    seat_num char(3),
    ticketID char(50) NOT NULL,
    PRIMARY KEY (ticketID, seat_num),
    FOREIGN KEY (ticketID) REFERENCES ticket (ticketID)
);

DROP TABLE IF EXISTS person;
CREATE TABLE person (
    personID char(50),
    f_name char(100) NOT NULL,
    l_name char(100),
    occupies char(50) NOT NULL,
    miles int,
    PRIMARY KEY (personID)
);

DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
    personID char(50),
    taxID char(100) NOT NULL,
    experience tinyint NOT NULL,
    flying_tail char(50),
    flying_airline char(50),
    PRIMARY KEY (personID),
    UNIQUE KEY taxID (taxID),
    FOREIGN KEY (personID) REFERENCES person (personID)
);

DROP TABLE IF EXISTS license;
CREATE TABLE license (
    license_type char(50),
    pilotID char(50),
    PRIMARY KEY (license_type, pilotID),
    FOREIGN KEY (pilotID) REFERENCES pilot (personID)
);

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
    personID char(50),
    PRIMARY KEY (personID),
    FOREIGN KEY (personID) REFERENCES person (personID)
);

DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
    airlineID char(50),
    revenue float NOT NULL,
    PRIMARY KEY (airlineID)
);

DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
	tail_num char(50),
	owned_by char(50) NOT NULL,
    speed smallint NOT NULL,
    seat_cap smallint NOT NULL,
    plane_type char(50),
    prop_and_engine_count tinyint,
    skid_count tinyint,
    PRIMARY KEY (tail_num, owned_by),
    FOREIGN KEY (owned_by) REFERENCES airline (airlineID)
);

DROP TABLE IF EXISTS supports;
CREATE TABLE supports (
    flightID char(50),
    owned_by char(50),
    tail_num char(50),
    progress tinyint,
    airplane_status char(50),
    next_time timestamp,
    PRIMARY KEY (flightID, tail_num, owned_by),
    FOREIGN KEY (flightID) REFERENCES flight (flightID),
    FOREIGN KEY (tail_num, owned_by) REFERENCES airplane (tail_num, owned_by)
);

DROP TABLE IF EXISTS location;
CREATE TABLE location (
    locID char(50),
    airportID char(50),
    tail_num char(50),
    owned_by char(50),
    PRIMARY KEY (locID),
    FOREIGN KEY (airportID) REFERENCES airport (airportID),
    FOREIGN KEY (tail_num, owned_by) REFERENCES airplane (tail_num, owned_by)
);

ALTER TABLE ticket ADD FOREIGN KEY (buys) REFERENCES person (personID);
ALTER TABLE person ADD FOREIGN KEY (occupies) REFERENCES location (locID);
ALTER TABLE pilot ADD FOREIGN KEY (flying_tail, flying_airline) REFERENCES airplane (tail_num, owned_by);

INSERT INTO airport VALUES ('ABQ','Albuquerque International Sunport','Albuquerque','NM'), ('ANC','Ted Stevens Anchorage International Airport','Anchorage','AK'), ('ATL','Hartsfield-Jackson Atlanta International Airport','Atlanta','GA'), ('BDL','Bradley International Airport','Hartford','CT'), ('BFI','King County International Airport','Seattle','WA'), ('BHM','Birmingham-Shuttlesworth International Airport','Birmingham','AL'), ('BNA','Nashville International Airport','Nashville','TN'), ('BOI','Boise Airport ','Boise','ID'), ('BOS','General Edward Lawrence Logan International Airport','Boston','MA'), ('BTV','Burlington International Airport','Burlington','VT'), ('BWI','Baltimore_Washington International Airport','Baltimore','MD'), ('BZN','Bozeman Yellowstone International Airport','Bozeman','MT'), ('CHS','Charleston International Airport','Charleston','SC'), ('CLE','Cleveland Hopkins International Airport','Cleveland','OH'), ('CLT','Charlotte Douglas International Airport','Charlotte','NC'), ('CRW','Yeager Airport','Charleston','WV'), ('DAL','Dallas Love Field','Dallas','TX'), ('DCA','Ronald Reagan Washington National Airport','Washington','DC'), ('DEN','Denver International Airport','Denver','CO'), ('DFW','Dallas-Fort Worth International Airport','Dallas','TX'), ('DSM','Des Moines International Airport','Des Moines','IA'), ('DTW','Detroit Metro Wayne County Airport','Detroit','MI'), ('EWR','Newark Liberty International Airport','Newark','NJ'), ('FAR','Hector International Airport','Fargo','ND'), ('FSD','Joe Foss Field','Sioux Falls','SD'), ('GSN','Saipan International Airport','Obyan Saipan Island','MP'), ('GUM','Antonio B_Won Pat International Airport','Agana Tamuning','GU'), ('HNL','Daniel K. Inouye International Airport','Honolulu Oahu','HI'), ('HOU','William P_Hobby Airport','Houston','TX'), ('IAD','Washington Dulles International Airport','Washington','DC'), ('IAH','George Bush Intercontinental Houston Airport','Houston','TX'), ('ICT','Wichita Dwight D_Eisenhower National Airport ','Wichita','KS'), ('ILG','Wilmington Airport','Wilmington','DE'), ('IND','Indianapolis International Airport','Indianapolis','IN'), ('ISP','Long Island MacArthur Airport','New York Islip','NY'), ('JAC','Jackson Hole Airport','Jackson','WY'), ('JAN','Jackson_Medgar Wiley Evers International Airport','Jackson','MS'), ('JFK','John F_Kennedy International Airport ','New York','NY'), ('LAS','Harry Reid International Airport','Las Vegas','NV'), ('LAX','Los Angeles International Airport','Los Angeles','CA'), ('LGA','LaGuardia Airport','New York','NY'), ('LIT','Bill and Hillary Clinton National Airport','Little Rock','AR'), ('MCO','Orlando International Airport','Orlando','FL'), ('MDW','Chicago Midway International Airport','Chicago','IL'), ('MHT','Manchester_Boston Regional Airport','Manchester','NH'), ('MKE','Milwaukee Mitchell International Airport','Milwaukee','WI'), ('MRI','Merrill Field','Anchorage','AK'), ('MSP','Minneapolis_St_Paul International Wold_Chamberlain Airport','Minneapolis Saint Paul','MN'), ('MSY','Louis Armstrong New Orleans International Airport','New Orleans','LA'), ('OKC','Will Rogers World Airport','Oklahoma City','OK'), ('OMA','Eppley Airfield','Omaha','NE'), ('ORD','O_Hare International Airport','Chicago','IL'), ('PDX','Portland International Airport','Portland','OR'), ('PHL','Philadelphia International Airport','Philadelphia','PA'), ('PHX','Phoenix Sky Harbor International Airport','Phoenix','AZ'), ('PVD','Rhode Island T_F_Green International Airport','Providence','RI'), ('PWM','Portland International Jetport','Portland','ME'), ('SDF','Louisville International Airport','Louisville','KY'), ('SEA','Seattle-Tacoma International Airport','Seattle Tacoma','WA'), ('SJU','Luis Munoz Marin International Airport','San Juan Carolina','PR'), ('SLC','Salt Lake City International Airport','Salt Lake City','UT'), ('STL','St_Louis Lambert International Airport','Saint Louis','MO'), ('STT','Cyril E_King Airport','Charlotte Amalie Saint Thomas','VI');
INSERT INTO leg VALUES ('leg_4','ATL','ORD',600), ('leg_18','LAX','DFW',1200), ('leg_24','SEA','ORD',1800), ('leg_23','SEA','JFK',2400), ('leg_25','ORD','ATL',600), ('leg_22','ORD','LAX',800), ('leg_12','IAH','DAL',200), ('leg_3','ATL','JFK',800), ('leg_19','LAX','SEA',1000), ('leg_21','ORD','DFW',800), ('leg_16','JFK','ORD',800), ('leg_17','JFK','SEA',2400), ('leg_27','ATL','LAX',1600), ('leg_20','ORD','DCA',600), ('leg_10','DFW','ORD',800), ('leg_9','DFW','ATL',800), ('leg_26','LAX','ORD',800), ('leg_6','DAL','HOU',200), ('leg_7','DCA','ATL',600), ('leg_8','DCA','JFK',200), ('leg_1','ATL','IAD',600), ('leg_11','IAD','ORD',600), ('leg_13','IAH','LAX',1400), ('leg_14','ISP','BFI',2400), ('leg_15','JFK','ATL',800), ('leg_2','ATL','IAH',600), ('leg_5','BFI','LAX',1000);
INSERT INTO route VALUES ('circle_east_coast'), ('circle_west_coast'), ('eastbound_north_milk_run'), ('eastbound_north_nonstop'), ('eastbound_south_milk_run'), ('hub_xchg_southeast'), ('hub_xchg_southwest'), ('local_texas'), ('northbound_east_coast'), ('northbound_west_coast'), ('southbound_midwest'), ('westbound_north_milk_run'), ('westbound_north_nonstop'), ('westbound_south_nonstop');
INSERT INTO contain_of VALUES (1,'leg_4','circle_east_coast'), (1,'leg_18','circle_west_coast'), (1,'leg_24','eastbound_north_milk_run'), (1,'leg_23','eastbound_north_nonstop'), (1,'leg_18','eastbound_south_milk_run'), (1,'leg_25','hub_xchg_southeast'), (1,'leg_22','hub_xchg_southwest'), (1,'leg_12','local_texas'), (1,'leg_3','northbound_east_coast'), (1,'leg_19','northbound_west_coast'), (1,'leg_21','southbound_midwest'), (1,'leg_16','westbound_north_milk_run'), (1,'leg_17','westbound_north_nonstop'), (1,'leg_27','westbound_south_nonstop'), (2,'leg_20','circle_east_coast'), (2,'leg_10','circle_west_coast'), (2,'leg_20','eastbound_north_milk_run'), (2,'leg_9','eastbound_south_milk_run'), (2,'leg_4','hub_xchg_southeast'), (2,'leg_26','hub_xchg_southwest'), (2,'leg_6','local_texas'), (2,'leg_22','westbound_north_milk_run'), (3,'leg_7','circle_east_coast'), (3,'leg_22','circle_west_coast'), (3,'leg_8','eastbound_north_milk_run'), (3,'leg_1','eastbound_south_milk_run'), (3,'leg_19','westbound_north_milk_run');INSERT INTO flight VALUES ('AM_1523','circle_west_coast'), ('DL_1174','northbound_east_coast'), ('DL_1243','westbound_north_nonstop'), ('DL_3410','circle_east_coast'), ('SP_1880','circle_east_coast'), ('SW_1776','hub_xchg_southwest'), ('SW_610','local_texas'), ('UN_1899','eastbound_north_milk_run'), ('UN_523','hub_xchg_southeast'), ('UN_717','circle_west_coast');
INSERT INTO flight VALUES ('AM_1523','circle_west_coast'), ('DL_1174','northbound_east_coast'), ('DL_1243','westbound_north_nonstop'), ('DL_3410','circle_east_coast'), ('SP_1880','circle_east_coast'), ('SW_1776','hub_xchg_southwest'), ('SW_610','local_texas'), ('UN_1899','eastbound_north_milk_run'), ('UN_523','hub_xchg_southeast');
INSERT INTO airline VALUES ('Air_France',25), ('American',45), ('Delta',46), ('JetBlue',8), ('Lufthansa',31), ('Southwest',22), ('Spirit',4), ('United',40);
INSERT INTO airplane VALUES ('n330ss','American',200,4,'jet',2,NULL), ('n380sd','American',400,5,'jet',2,NULL), ('n106js','Delta',200,4,'jet',2,NULL), ('n110jn','Delta',600,5,'jet',4,NULL), ('n127js','Delta',800,4,NULL,NULL,NULL), ('n156sq','Delta',100,8,NULL,NULL,NULL), ('n161fk','JetBlue',200,4,'jet',2,NULL), ('n337as','JetBlue',400,5,'jet',2,NULL), ('n118fm','Southwest',100,4,'prop',1,1), ('n401fj','Southwest',200,4,'jet',2,NULL), ('n653fk','Southwest',400,6,'jet',2,NULL), ('n815pw','Southwest',200,3,'prop',2,0), ('n256ap','Spirit',400,4,'jet',2,NULL), ('n451fi','United',400,5,'jet',4,NULL), ('n517ly','United',400,4,'jet',2,NULL), ('n616lt','United',400,7,'jet',4,NULL), ('n620la','United',200,4,'prop',2,0);
INSERT INTO location VALUES ('plane_4',NULL,'n330ss','American'), ('plane_1',NULL,'n106js','Delta'), ('plane_2',NULL,'n110jn','Delta'), ('plane_11',NULL,'n118fm','Southwest'), ('plane_9',NULL,'n401fj','Southwest'), ('plane_15',NULL,'n256ap','Spirit'), ('plane_7',NULL,'n517ly','United'), ('plane_8',NULL,'n620la','United'), ('port_1','ATL',NULL,NULL), ('port_10','BFI',NULL,NULL), ('port_7','DAL',NULL,NULL), ('port_9','DCA',NULL,NULL), ('port_3','DEN',NULL,NULL), ('port_2','DFW',NULL,NULL), ('port_18','HOU',NULL,NULL), ('port_11','IAD',NULL,NULL), ('port_13','IAH',NULL,NULL), ('port_14','ISP',NULL,NULL), ('port_15','JFK',NULL,NULL), ('port_5','LAX',NULL,NULL), ('port_4','ORD',NULL,NULL), ('port_17','SEA',NULL,NULL);INSERT INTO person VALUES ('p1','Jeanne','Nelson','plane_1',NULL), ('p10','Lawrence','Morgan','plane_9',NULL), ('p11','Sandra','Cruz','plane_9',NULL), ('p12','Dan','Ball','plane_11',NULL), ('p13','Bryant','Figueroa','plane_2',NULL), ('p14','Dana','Perry','plane_2',NULL), ('p15','Matt','Hunt','plane_2',NULL), ('p16','Edna','Brown','plane_15',NULL), ('p17','Ruby','Burgess','plane_15',NULL), ('p18','Esther','Pittman','port_2',NULL), ('p19','Doug','Fowler','port_4',NULL), ('p2','Roxanne','Byrd','plane_1',NULL), ('p20','Thomas','Olson','port_3',NULL), ('p21','Mona','Harrison','port_4',771), ('p22','Arlene','Massey','port_2',374), ('p23','Judith','Patrick','port_3',414), ('p24','Reginald','Rhodes','plane_1',292), ('p25','Vincent','Garcia','plane_1',390), ('p26','Cheryl','Moore','plane_4',302), ('p27','Michael','Rivera','plane_7',470), ('p28','Luther','Matthews','plane_8',208), ('p29','Moses','Parks','plane_8',292), ('p3','Tanya','Nguyen','plane_4',NULL), ('p30','Ora','Steele','plane_9',686), ('p31','Antonio','Flores','plane_9',547), ('p32','Glenn','Ross','plane_11',257), ('p33','Irma','Thomas','plane_11',564), ('p34','Ann','Maldonado','plane_2',211), ('p35','Jeffrey','Cruz','plane_2',233), ('p36','Sonya','Price','plane_15',293), ('p37','Tracy','Hale','plane_15',552), ('p38','Albert','Simmons','port_1',812), ('p39','Karen','Terry','port_9',541), ('p4','Kendra','Jacobs','plane_4',NULL), ('p40','Glen','Kelley','plane_4',441), ('p41','Brooke','Little','port_4',875), ('p42','Daryl','Nguyen','port_3',691), ('p43','Judy','Willis','port_1',572), ('p44','Marco','Klein','port_2',572), ('p45','Angelica','Hampton','port_5',663), ('p5','Jeff','Burton','plane_4',NULL), ('p6','Randal','Parks','plane_7',NULL), ('p7','Sonya','Owens','plane_7',NULL), ('p8','Bennie','Palmer','plane_8',NULL), ('p9','Marlene','Warner','plane_8',NULL);
INSERT INTO person VALUES ('p1','Jeanne','Nelson','plane_1',NULL), ('p10','Lawrence','Morgan','plane_9',NULL), ('p11','Sandra','Cruz','plane_9',NULL), ('p12','Dan','Ball','plane_11',NULL), ('p13','Bryant','Figueroa','plane_2',NULL), ('p14','Dana','Perry','plane_2',NULL), ('p15','Matt','Hunt','plane_2',NULL), ('p16','Edna','Brown','plane_15',NULL), ('p17','Ruby','Burgess','plane_15',NULL), ('p18','Esther','Pittman','port_2',NULL), ('p19','Doug','Fowler','port_4',NULL), ('p2','Roxanne','Byrd','plane_1',NULL), ('p20','Thomas','Olson','port_3',NULL), ('p21','Mona','Harrison','port_4',771), ('p22','Arlene','Massey','port_2',374), ('p23','Judith','Patrick','port_3',414), ('p24','Reginald','Rhodes','plane_1',292), ('p25','Vincent','Garcia','plane_1',390), ('p26','Cheryl','Moore','plane_4',302), ('p27','Michael','Rivera','plane_7',470), ('p28','Luther','Matthews','plane_8',208), ('p29','Moses','Parks','plane_8',292), ('p3','Tanya','Nguyen','plane_4',NULL), ('p30','Ora','Steele','plane_9',686), ('p31','Antonio','Flores','plane_9',547), ('p32','Glenn','Ross','plane_11',257), ('p33','Irma','Thomas','plane_11',564), ('p34','Ann','Maldonado','plane_2',211), ('p35','Jeffrey','Cruz','plane_2',233), ('p36','Sonya','Price','plane_15',293), ('p37','Tracy','Hale','plane_15',552), ('p38','Albert','Simmons','port_1',812), ('p39','Karen','Terry','port_9',541), ('p4','Kendra','Jacobs','plane_4',NULL), ('p40','Glen','Kelley','plane_4',441), ('p41','Brooke','Little','port_4',875), ('p42','Daryl','Nguyen','port_3',691), ('p43','Judy','Willis','port_1',572), ('p44','Marco','Klein','port_2',572), ('p45','Angelica','Hampton','port_5',663), ('p5','Jeff','Burton','plane_4',NULL), ('p6','Randal','Parks','plane_7',NULL), ('p7','Sonya','Owens','plane_7',NULL), ('p8','Bennie','Palmer','plane_8',NULL), ('p9','Marlene','Warner','plane_8',NULL);
INSERT INTO ticket VALUES ('tkt_dl_1',450,'p24','JFK','DL_1174'), ('tkt_dl_2',225,'p25','JFK','DL_1174'), ('tkt_am_3',250,'p26','LAX','AM_1523'), ('tkt_un_4',175,'p27','DCA','UN_1899'), ('tkt_un_5',225,'p28','ATL','UN_523'), ('tkt_un_6',100,'p29','ORD','UN_523'), ('tkt_sw_7',400,'p30','ORD','SW_1776'), ('tkt_sw_8',175,'p31','ORD','SW_1776'), ('tkt_sw_9',125,'p32','HOU','SW_610'), ('tkt_sw_10',425,'p33','HOU','SW_610'), ('tkt_dl_11',500,'p34','LAX','DL_1243'), ('tkt_dl_12',250,'p35','LAX','DL_1243'), ('tkt_sp_13',225,'p36','ATL','SP_1880'), ('tkt_sp_14',150,'p37','DCA','SP_1880'), ('tkt_un_15',150,'p38','ORD','UN_523'), ('tkt_sp_16',475,'p39','ATL','SP_1880'), ('tkt_am_17',375,'p40','ORD','AM_1523'), ('tkt_am_18',275,'p41','LAX','AM_1523');
INSERT INTO seat VALUES ('1C','tkt_dl_1'), ('2D','tkt_dl_2'), ('3B','tkt_am_3'), ('2B','tkt_un_4'), ('1A','tkt_un_5'), ('3B','tkt_un_6'), ('3C','tkt_sw_7'), ('3E','tkt_sw_8'), ('1C','tkt_sw_9'), ('1D','tkt_sw_10'), ('1E','tkt_dl_11'), ('2A','tkt_dl_12'), ('1A','tkt_sp_13'), ('2B','tkt_sp_14'), ('1B','tkt_un_15'), ('2C','tkt_sp_16'), ('2B','tkt_am_17'), ('2A','tkt_am_18'), ('2F','tkt_dl_1'), ('1B','tkt_dl_11'), ('2E','tkt_sp_16'), ('2F','tkt_dl_11');
INSERT INTO pilot VALUES ('p1','330-12-6907',31,'n106js','Delta'), ('p10','769-60-1266',15,'n401fj','Southwest'), ('p11','369-22-9505',22,'n401fj','Southwest'), ('p12','680-92-5329',24,'n118fm','Southwest'), ('p13','513-40-4168',24,'n110jn','Delta'), ('p14','454-71-7847',13,'n110jn','Delta'), ('p15','153-47-8101',30,'n110jn','Delta'), ('p16','598-47-5172',28,'n256ap','Spirit'), ('p17','865-71-6800',36,'n256ap','Spirit'), ('p18','250-86-2784',23,NULL,NULL), ('p19','386-39-7881',2,NULL,NULL), ('p2','842-88-1257',9,'n106js','Delta'), ('p20','522-44-3098',28,NULL,NULL), ('p21','621-34-5755',2,NULL,NULL), ('p22','177-47-9877',3,NULL,NULL), ('p23','528-64-7912',12,NULL,NULL), ('p24','803-30-1789',34,NULL,NULL), ('p25','986-76-1587',13,NULL,NULL), ('p26','584-77-5105',20,NULL,NULL), ('p3','750-24-7616',11,'n330ss','American'), ('p4','776-21-8098',24,'n330ss','American'), ('p5','933-93-2165',27,'n330ss','American'), ('p6','707-84-4555',38,'n517ly','United'), ('p7','450-25-5617',13,'n517ly','United'), ('p8','701-38-2179',12,'n620la','United'), ('p9','936-44-6941',13,'n620la','United');
INSERT INTO license VALUES ('jet','p1'), ('jet','p10'), ('jet','p11'), ('prop','p12'), ('jet','p13'), ('jet','p14'), ('jet','p15'), ('jet','p16'), ('jet','p17'), ('jet','p18'), ('jet','p19'), ('jet','p2'), ('jet','p20'), ('jet','p21'), ('jet','p22'), ('jet','p23'), ('jet','p24'), ('jet','p25'), ('jet','p26'), ('jet','p3'), ('jet','p4'), ('jet','p5'), ('jet','p6'), ('jet','p7'), ('prop','p8'), ('jet','p9'), ('prop','p11'), ('prop','p15'), ('prop','p17'), ('prop','p2'), ('prop','p21'), ('prop','p24'), ('prop','p4'), ('prop','p6'), ('prop','p9'), ('testing','p15'), ('testing','p24'), ('testing','p9');
INSERT INTO passenger VALUES ('p1'), ('p10'), ('p11'), ('p12'), ('p13'), ('p14'), ('p15'), ('p16'), ('p17'), ('p18'), ('p19'), ('p2'), ('p20'), ('p21'), ('p22'), ('p23'), ('p24'), ('p25'), ('p26'), ('p27'), ('p28'), ('p29'), ('p3'), ('p30'), ('p31'), ('p32'), ('p33'), ('p34'), ('p35'), ('p36'), ('p37'), ('p38'), ('p39'), ('p4'), ('p40'), ('p41'), ('p42'), ('p43'), ('p44'), ('p45'), ('p5'), ('p6'), ('p7'), ('p8'), ('p9');