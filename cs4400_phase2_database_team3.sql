DROP DATABASE IF EXISTS sams;
CREATE DATABASE IF NOT EXISTS sams;
USE sams;

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
    airportID char(3),
    airport_name varchar(50),
    city varchar(50),
    state varchar(50),
    PRIMARY KEY (airportID)  
);

DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
    legID char(50),
    distance smallint,
    PRIMARY KEY (legID)  
);

DROP TABLE IF EXISTS route;
CREATE TABLE route (
    routeID char(50),
    PRIMARY KEY (routeID)  
);

DROP TABLE IF EXISTS contain_of;
CREATE TABLE contain_of (
    sequence char(50),
    PRIMARY KEY (sequence)  
);

DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
    flightID char(50),
    PRIMARY KEY (flightID)  
);

DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket (
    ticketID char(50),
    cost smallint,
    PRIMARY KEY (ticektID)  
);

DROP TABLE IF EXISTS seat;
CREATE TABLE seat (
    seat_num char(3),
    PRIMARY KEY (seat_num)  
);
