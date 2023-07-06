DROP DATABASE IF EXISTS sams;
CREATE DATABASE IF NOT EXISTS sams;
USE sams;

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
    airportID char(3),
    airport_name varchar(50) NOT NULL,
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
    sequence char(50),
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
    offers char(50) NOT NULL,
    deplanes char(3) NOT NULL,
    buys char (50) NOT NULL,
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
    miles int NOT NULL,
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


