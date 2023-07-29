-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	-- make sure that the airplane exists in the airline table
	if ip_airlineID not in (select airlineId from airline) or ip_airlineID is null then
		leave sp_main; end if;
    -- make sure that tail number is unique
    if (ip_airlineID, ip_tail_num) in (select airlineId, tail_num from airplane) then 
		leave sp_main; end if;
    -- make sure that the seat capacity and speed is greater than or equal to zero
    if (ip_seat_capacity <= 0) or (ip_speed <= 0) then
		leave sp_main; end if;
    -- make sure that jets can't have propellors or skids
    if (ip_plane_type = 'jet') and (ip_jet_engines is null or ip_propellers is not null or ip_skids is not null) then 
		leave sp_main; end if;
	-- make sure that props have propellors and skids
    if (ip_plane_type = 'prop') and (ip_jet_engines is not null or ip_propellers is null or ip_skids is null) then 
		leave sp_main; end if;
        
    -- still need to check location constraint here
    if ip_locationID is not null and ip_locationID in (select distinct locationID from airplane) then
		leave sp_main; end if;
    
    insert into airplane values (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed,
    ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state char(2), in ip_locationID varchar(50))
sp_main: begin
	-- make sure that airportID is unique and also not NULL 
	if ip_airportID in (select airportID from airport) or ip_airportID is null then
		leave sp_main; end if;
    
    -- New airports may or may not have a database-wide unique 
    -- location identifier but will be given an identifier before people can go there to catch flights.
    
    if (ip_city is null or ip_state is null) then
		leave sp_main; end if;
        
    -- we should look at adjusting to (select locationID from location where locationID like 'port%'   
	if ip_locationID is not null and ip_locationID not in (select locationID from location)
		then insert into location(locationID) values (ip_locationID); end if;
    
    insert into airport values (ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);
    
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_flying_airline varchar(50), in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin
	-- make that the new person has a unique id
    if ip_personID is null or ip_personID in (select personID from person) then
		leave sp_main; end if;
    
    -- make sure that the new person has locationID either at the airport or in the airpolane
    if ip_locationID is null or ip_locationID not in (select locationID from location) then
		leave sp_main;
	end if;
    
	insert into person values (ip_personID, ip_first_name, ip_last_name, ip_locationID);
    
    -- insert into pilot if taxID is not null
    if ip_taxID is not null then
		insert into pilot values (ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail); end if;
    
    -- insert into passenger if they have flyer miles 
    if ip_miles is not null then
		insert into passenger values (ip_personID, ip_miles); end if;

end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
	/* This stored procedure creates a new pilot license.  The license must reference
	a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	-- make sure that the person is a pilot
	if ip_personID not in (select personID from pilot) then
		leave sp_main; end if;
    
    -- make sure that the pilot doesn't have that license already
    if ip_license in 
		(select license from pilot_licenses where ip_personID = personID)
	then
		leave sp_main; end if;
        
	insert into pilot_licenses values (ip_personID, ip_license);

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin
	-- make sure that the flight has a routeID
    if ip_routeID is null then 
		leave sp_main; end if;
        
	insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail,
    ip_progress, ip_airplane_status, ip_next_time);

end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin
	if(ip_carrier in (select flightID from flight) 
		and ip_deplane_at is not null and ip_customer in (select personID from person)
		-- ticket must list destination airport
        and ip_deplane_at not in 
        (select flightID from flight where routeID in 
			(select routeID from route_path where legID in 
				(select legID from leg where ip_deplane_at = arrival )))) then 
		insert into ticket (ticketID, cost, carrier, customer, deplane_at)
		values (ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
	end if;
    
	if(ip_seat_number in (select seat_number from ticket_seats)) then 
		leave sp_main;
	end if;
    
	insert into ticket_seats (ticketID, seat_number)
	values (ip_ticketID, ip_seat_number);
end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin
	if exists (select * from leg where ip_departure = departure and ip_arrival = arrival) then
		update leg set distance = ip_distance where ip_departure = departure and ip_arrival = arrival;
	else
		insert into leg values (ip_legID, ip_distance, ip_departure, ip_arrival);
	end if;
    
    if exists (select * from leg where ip_departure = arrival and ip_arrival = departure) then
		update leg set distance = ip_distance where ip_departure = arrival and ip_arrival = departure;
	end if;
end //
delimiter ;

-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
	if (ip_routeID in (select routeID from route_path)) then
		leave sp_main; end if;
    
    insert into route values (ip_routeID);
    insert into route_path values (ip_routeID, ip_legID, 1);
end //
delimiter ;

-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
 drop procedure if exists extend_route;
 delimiter //
 create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
 sp_main: begin

    -- Check if input parameters are not null
    if ip_routeID is null or ip_legID is null 
		then leave sp_main; end if;

    -- Check if the ip_routeID exists in the route table
    if not exists (select 1 from route where routeID = ip_routeID) 
		then leave sp_main; end if;

    -- Check if the ip_legID exists in the leg table
    if not exists (select 1 from leg where legID = ip_legID) 
		then leave sp_main; end if;

    -- Check if the route is empty or if the ip_legID has the same departure airport as the last leg's arrival airport
    if exists (select 1 from route_path rp join leg l on rp.legID = l.legID where routeID = ip_routeID
        having COUNT(*) > 0 and MAX(l.arrival) <> (select departure from leg where legID = ip_legID)) 
        then leave sp_main; end if;

    -- Insert the new leg into the route_path table with the correct sequence
    insert into route_path (select ip_routeID, ip_legID, ifnull(max(sequence), 0) + 1 from route_path
    where routeID = ip_routeID);

end //
delimeter ;


-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	if ip_flightID not in (select flightID from flight) then 
		leave sp_main; end if;
	if ip_flightID in (select flightID from flight where airplane_status = 'on_ground') then
		leave sp_main; end if;
	
	update pilot
	set experience = experience + 1
	where flying_tail in 
	(select f.support_tail from route_path as rp 
    join flight as f on rp.routeID = f.routeID where flightID = ip_flightID and progress = sequence);

	update passenger
	set miles = miles + (
	select distance
	from leg
	where legID in (
	select rp.legID
	from route_path as rp
	join flight as f on rp.routeID = f.routeID
	where flightID = ip_flightID and progress = sequence))
	where personID in (select personID from (
	select personID
	from person 
	join location on person.locationID = location.locationID
	join airplane on location.locationID = airplane.locationID 
	where tail_num in (
	select support_tail 
	from route_path as rp 
	join flight as f on rp.routeID = f.routeID 
	where flightID = ip_flightID and progress = sequence) 
	and personID in (select personID from passenger)) as subquery);
    
    update flight 
    set next_time = TIMESTAMPADD(hour, 1, next_time), airplane_status = 'on_ground' 
    where flightID = ip_flightID;


end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
    declare sp int;
    declare pl_type varchar(100);
    declare dist int;
    declare num_pilot int;
    
    if ip_flightID not in (select flightID from flight) then
		leave sp_main;
	end if;
    
    if (select airplane_status from flight where flightID = ip_flightID) like 'in_flight' then
		leave sp_main;
	end if;
    
    if (select progress from flight where ip_flightID = flightID) = 
    (select max(sequence) from flight as f join route_path as rp on f.routeID = rp.routeID 
    join leg as l on l.legID = rp.legID where f.flightID = ip_flightID) then
		leave sp_main;
	end if;
    
    if (select progress from flight where ip_flightID = flightID) is null then
		leave sp_main;
	end if;


-- correct version
	select distance into dist from flight as f join route_path as rp on f.routeID = rp.routeID 
	join leg as l on l.legID = rp.legID where f.flightID = ip_flightID and progress + 1 = sequence;

--     select airplane.speed, plane_type into sp, pl_type from airplane,flight
--     where airplane.tail_num = flight.support_tail and flight.flightid = ip_flightid;

	select a.speed, a.plane_type into sp, pl_type from flight as f 
    join airplane as a on f.support_tail = a.tail_num where f.flightID = ip_flightID;


	select count(*) into num_pilot from pilot as p join airplane as a on p.flying_tail = a.tail_num 
	join flight as f on a.tail_num = f.support_tail where f.flightID = ip_flightID;
    
	if pl_type ='jet' and num_pilot < 2 then
		update flight set next_time = next_time + interval 30 minute
			where flight.flightid = ip_flightid;
		leave sp_main;
    end if;
    
	if pl_type ='prop' and num_pilot < 1 then
		update flight set next_time = next_time + interval 30 minute
			where flight.flightID = ip_flightID;
		leave sp_main;
    end if;

    update flight
    set airplane_status = 'in_flight', next_time = next_time + interval (dist/sp) hour,progress=progress+1
    where flight.flightID = ip_flightID;

--     if pl_type ='jet' and num_pilot < 2 then
-- 	update flight
-- 	set airplane_status = 'in_flight' , next_time = date_add(next_time, interval 0.5 hour)
-- 	where flight.flightid = ip_flightid;
--     end if;

end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	declare boarding_location varchar(10);
    
	if (ip_flightID not in (select flightID from flight)) then
		leave sp_main;
	end if;
    
    if exists (
				select flight.flightID
                from flight
					join ticket on ticket.carrier = flight.flightID
                    -- checking for ticket being valid 
					join person on ticket.customer = person.personID
                    -- matching ticket holders to people 
				where flightID = ip_flightID and person.locationID = (
					-- making sure passengers are at the right airport of the flight 
                    select airport.locationID
                    from flight join route_path on route_path.routeID = flight.routeID
								join leg on route_path.legID = leg.legID 
                                join airport on leg.departure = airport.airportID
					where flightID = ip_flightID and flight.progress = route_path.sequence - 1)
				)
	-- once checked that everything is valid to change, then go to implementing 
	then set boarding_location = (
			select airplane.locationID
            from flight join airplane on flight.support_airline = airplane.airlineID and flight.support_tail = airplane.tail_num
            where flightID = ip_flightID
		);
        
        update person
        -- changing value for people only on flight
        set locationID = boarding_location
        where personID in (
			select *
            from (
				select ticket.customer
                from flight
					join ticket on ticket.carrier = flight.flightID
					join person on ticket.customer = person.personID
				where flightID = ip_flightID and person.locationID = (
					select airport.locationID
                    from flight join route_path on route_path.routeID = flight.routeID
								join leg on route_path.legID = leg.legID
                                join airport on leg.departure = airport.airportID
					where flightID = ip_flightID and flight.progress = route_path.sequence - 1
				)
                -- assign to subq for functionality - won't call again
			) as temp_var
		);
                                            
		end if;

end //
delimiter ;

-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	-- make sure the passengers are in the flight, the flight is on the ground, and the flight is located at the destination airport
if not exists (select personID from flight as f join ticket as t on t.carrier = f.flightID 
				join person as p on t.customer=p.personID 
				join route_path as r on f.routeID = r.routeID and f.progress = r.sequence 
				join leg as l on r.legID = l.legID
				where flightID = ip_flightID
				and airplane_status = 'on_ground' 
				and p.locationID = (select locationID from flight as f 
				join airplane as a on f.support_airline = a.airlineID and f.support_tail = a.tail_num where flightID = ip_flightID)
				and t.deplane_at = l.arrival) then
		leave sp_main; end if;
-- set where the deplane airport is to locationID
update person
set locationID = (select distinct a.locationID from flight as f 
					join ticket as t on t.carrier = f.flightID join route_path as r on f.routeID = r.routeID and f.progress=r.sequence 
					join leg as l on r.legID = l.legID 
					join airport as a on a.airportID = l.arrival where flightID = ip_flightID and t.deplane_at = l.arrival)
					where personID in (select * from (select t.customer from flight as f 
					join ticket as t on t.carrier = f.flightID join person as p on t.customer=p.personID 
					join route_path as r on f.routeID = r.routeID and f.progress=r.sequence 
					join leg as l on r.legID=l.legID where flightID =ip_flightID
					and airplane_status='on_ground' 
					and p.locationID = (select locationID from flight as f 
					join airplane as a on f.support_airline=a.airlineID and f.support_tail=a.tail_num where flightID = ip_flightID)
					and t.deplane_at=l.arrival) as temp);
end //
delimiter ;

-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
	-- make sure locations of pilot and plane are the same
    if (select locationID from pilot as pil 
    join person as per on pil.personID=per.personID where pil.personID=ip_personID) <> 
    (select a.locationID from flight as f join route_path as r on r.routeID=f.routeID 
    join leg as l on r.legID = l.legID join airport as a on l.arrival=a.airportID where flightID=ip_flightID and f.progress=r.sequence) then
		leave sp_main; end if;
        
	-- make sure that pilot's license is valid for the flight
    if (select a.plane_type from flight as f 
		join airplane as a on f.support_airline=a.airlineID and f.support_tail=a.tail_num where flightID=ip_flightID) not in (select license from pilot as p 
        join pilot_licenses as pl on p.personID=pl.personID where p.personID=ip_personID) then
		leave sp_main; end if;
    
    -- make sure that pilot only assigned to one flight
    if (select flying_airline from pilot where personID=ip_personID) is not null or (select flying_tail from pilot where personID=ip_personID) is not null then
		leave sp_main; end if;
    
    -- update the flying_airline and flying_tail in pilot table
	update pilot
	set flying_airline = (select support_airline from flight where flightID=ip_flightID), 
		flying_tail = (select support_tail from flight where flightID=ip_flightID)
		where personID = ip_personID;
    
    -- update locationID in person table
    update person
	set locationID = (select a.locationID from flight as f join airplane as a on f.support_airline=a.airlineID and f.support_tail=a.tail_num where flightID=ip_flightID)
	where personID=ip_personID;
end //
delimiter ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
-- GROUP NEEDS TO WORK ON THIS ONE
-- jet vs prop test case potentially
	declare route_name varchar(50);
    declare end_leg int default 0;
    declare loc varchar(50);
    declare arrive varchar(50);
-- check if flight is on ground
	if ip_flightID in (select flightID from flight where airplane_status='in_air') then
		leave sp_main;
        end if;
	
    -- is progress last in the route
	set route_name = (select routeID from flight where flightID = ip_flightID);
	set end_leg = (select max(sequence) from route_path where route_name = routeID group by routeID);
    if end_leg != (select progress from flight where ip_flightID = flightID) then
    leave sp_main;
        end if;
	
    -- check if passengers on board
    
    set loc = (select locationID from airplane where tail_num in (select support_tail from flight where flightID = ip_flightID));
    if 0 != (select count(personID) from person where locationID = loc and personID in (select personID from passenger)) then
    leave sp_main;
        end if;
     
	set arrive = (select locationID from airport where airportID in (select arrival from leg
    where legID in (select legID from route_path where sequence = end_leg and route_name = routeID)));
    
	update person
    set locationID = arrive
    where locationID = loc and personID in (select personID from pilot);
    
    update pilot
    set flying_airline=null, flying_tail=null
    where flying_tail in (select support_tail from flight where flightID = ip_flightID);


end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

if ip_flightID not in (select flightID from flight where airplane_status = 'on_ground') or ip_flightID is null then
leave sp_main; end if;

if ip_flightID in (select flightID from flight where progress = 0 or progress = 
(select max(rp.sequence) from flight as f join route_path as rp on rp.routeID = f.routeID where f.flightID = ip_flightID)) 
then delete from flight where flightID = ip_flightID; end if;
    
end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin
-- in 'port' means they are on the ground (only way to see) we can just remove them
-- on a plane -> check ticket
	-- checks that the person is a passenger and is their locationID joined with flight is not "inflight"
    if (ip_personID in (
		select pr.personID from person as pr 
		join passenger pas on pr.personID = pas.personID 
		join airplane as a on pr.locationID = a.locationID join flight as f on a.tail_num = f.support_tail 
		where f.airplane_status = 'in_flight')
)	then 
		leave sp_main;
    end if;
    
	-- check if ID maps to a real person's ID in database 
    if (ip_personID not in (
		select personID
        from passenger))then
		leave sp_main;
    end if;
    
	-- remove from passenger, person, and ticket where the ID matches
    if (ip_personID not in (
		select personID
        from pilot
	))	then
        delete from passenger where ip_personID = personID;
		delete from ticket where ip_personID = customer;
        delete from person where ip_personID = personID;
    end if;

end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin
-- make sure that the pilot exists
    if (ip_personID not in (select personID from pilot)) then
		leave sp_main;
    end if;
    
    -- make sure that the pilot is not assigned to a flight or at start/end 
    -- this checks if ip_personID is fly airline or at the start or end of flight
    
    -- it should check if ip_personID is flying airplane and true airplane must be at start or end of route

	if (ip_personID in (select personID from pilot where flying_tail is not null)) then
		if (select progress from pilot 
			join flight on pilot.flying_tail = flight.support_tail where personID = ip_personID) !=
            (select flying_tail, max(sequence), min(sequence) from pilot as pi join airplane as a on pi.flying_tail = a.tail_num 
				join flight as f on a.tail_num = f.support_tail 
                join route_path as rp on f.routeID = rp.routeID where personID = ip_personID)
		or (select progress from pilot join flight on pilot.flying_tail = flight.support_tail where personID = ip_personID) != 1 then
			leave sp_main;
		end if;
    end if;
    
    -- only delete pilot and pilot_license
    delete from pilot_licenses where ip_personID = personID;
    delete from pilot where ip_personID = personID;
    
    if (ip_personID not in (select personID from passenger)) then
		delete from person where personID = ip_personID;
	end if;
end //
delimiter ;
-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
    
    -- select the columns needed and name accordingly
	select l.departure as departing_from, l.arrival as arriving_at, count(f.flightID) as num_flights, 
		group_concat(f.flightID) as flight_list, min(f.next_time) as earliest_arrival, 
		max(f.next_time) as latest_arrival, group_concat(a.locationID) as airplane_list
	from flight as f
    
		-- join with route_path, leg, and airplane in order to get the legID, airlineID, and sequence/progress
		join route_path as rp on f.routeID = rp.routeiD
		join leg as l on rp.legID=l.legID
		join airplane as a on f.support_airline = a.airlineID and f.support_tail = a.tail_num
    
    -- progress = sequence to make sure that we are checking flights on the path that are in the air
	where f.progress = rp.sequence and airplane_status = 'in_flight'
	group by departing_from, arriving_at;
    
select null, null, 0, null, null, null	, null;

-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
    
    -- select the columns needed and name accordingly
    select l.departure as departing_from, count(f.flightID) as num_flights, group_concat(flightID SEPARATOR ', ') as flight_list, 
		min(f.next_time) as earliest_arrival, max(f.next_time) as latest_arrival, group_concat(a.locationID SEPARATOR ', ') as airplane_list
	from flight as f 
		join route_path as rp on f.routeID = rp.routeID
		join leg as l on rp.legID = l.legID
		join airplane as a on f.support_airline = a.airlineID and f.support_tail = a.tail_num
    
	-- make sure that we are only getting flights on the ground and where progress and sequence is the same
	where f.progress + 1 = rp.sequence and airplane_status = 'on_ground'
	group by l.departure;
    
select null, 0, null, null, null, null;

-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
    
    -- reuse some code from flights_in_the_air to select the columns needed and name accordingly
    select l.departure as departing_from, l.arrival as arriving_at, 
		count(distinct concat(a.airlineID, '-', a.tail_num)) as num_airplane, 
        group_concat(distinct a.locationID) as airplane_list, 
		group_concat(distinct f.flightID) as flight_list, 
        min(f.next_time) as earliest_arrival, 
		max(f.next_time) as latest_arrival, 
        count(pilot.personID) as num_pilots, 
        count(passenger.personID) as num_passengers, 
		count(p.personID) as joint_pilots_passengers, 
        group_concat(p.personID) as person_list

	from person as p 
    join airplane as a on p.locationID = a.locationID
    join flight as f on a.airlineID = f.support_airline and a.tail_num = f.support_tail
    join route_path as rp on f.routeID = rp.routeID
    join leg as l on rp.legID=l.legID
    left join passenger on p.personID = passenger.personID
    left join pilot on p.personID = pilot.personID
    -- in flight at where progress and sequence is the same, 
	-- so currently in flight
	where airplane_status='in_flight' and f.progress=rp.sequence
	group by l.departure, l.arrival, f.flightID;
    
select null, null, 0, null, null, null, null, 0, 0, null, null;

-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
    select apt.airportID as departing_from, p.locationID as airport, apt.airport_name, 
    apt.city, apt.state,count(pilot.personID) as num_pilots, count(passenger.personID) as num_passengers, 
    count(p.personID) as joint_pilots_passengers, group_concat(p.personID) as person_list
	from person as p
    join airport as apt on p.locationID=apt.locationID
	left join pilot on p.personID=pilot.personID
	left join passenger on p.personID=passenger.personID
    -- we need all these columns in select statement so we should gropu by all of them
	group by apt.airportID, p.locationID, apt.airport_name, apt.city, apt.state
    -- the use-case result table looks ordered by airportID
	order by apt.airportID;

select null, null, null, null, null, 0, 0, null, null;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
    
	select r.routeID AS route, count(distinct rp.legID) AS num_legs, 
		group_concat(distinct rp.legID order by rp.sequence) as leg_sequence,
		route_total_distance.total_distance AS route_length, count(distinct f.flightID) as num_flights,
        group_concat(distinct f.flightID) AS flight_list,
        group_concat(distinct concat(l.departure, '->', l.arrival) order by rp.sequence) as airport_sequence
	from route r
    
    -- join on route_path, leg, and flight to get sequence, flightIDs, distance
	join route_path rp on r.routeID = rp.routeID
	join leg l on rp.legID = l.legID
	left join flight f on r.routeID = f.routeID
    
    -- join subquery to get the correct total distance for each route 
	join (select routeID, sum(distance) as total_distance from route_path rp join leg l on rp.legID = l.legID group by routeID) 
			as route_total_distance on r.routeID = route_total_distance.routeID
	group by r.routeID;
select null, 0, null, 0, 0, null, null;

-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
	airport_code_list, airport_name_list) as
    select city, 
		state, 
		count(*) as num_airports, 
		group_concat(airportID order by airportID ASC separator ', ') as airport_code_list, 
		group_concat(airport_name order by airportID ASC separator ', ') as airport_name_list 
	from airport
   	 group by city, state
   	 having count(airportID) > 1
   	 order by city;

select null, null, 0, null, null;

-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin
	declare testCase VARCHAR(50);
    -- selects the flight with the min next_time sequence
	set testCase = (select flightID
	from flight where next_time = (select min(next_time) from flight)
	group by flightID
	order by airplane_status = 'in_flight', flightID
	limit 1);

	-- if flight is "in_flight" or flying then land the plane and passengers should leave the flight
	if exists (select flightID from flight where airplane_status = 'in_flight' and flightID = testCase)
	then
	call flight_landing(testCase);
	call passengers_disembark(testCase); 
	end if;
	
    -- if flight is on ground passengers should board and the plane should take off
	if exists (select flightID from flight where airplane_status = 'on_ground' and flightID = testCase)
	then
	call passengers_board(testCase);
	call flight_takeoff(testCase);
	end if;

	-- if the flight has ended,
    -- then crew should get recycled
    -- flight should be recycled
	if exists(select fli.flightID from flight fli, route_path rou where fli.airplane_status = 'on_ground' and 
    fli.routeID = rou.routeID and fli.flightID = testCase 
	and fli.progress = rou.sequence) then 
	call recycle_crew(testCase);
	call retire_flight(testCase);
	end if;
end //
delimiter ;
