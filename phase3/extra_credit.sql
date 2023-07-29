-- Index to improve the performance of checking if passengers can disembark in the passengers_disembark stored procedure.
-- This index will be used to efficiently check if the passengers are on the flight, the flight is on the ground, and the flight is located at the destination airport referenced by the ticket.

CREATE INDEX idx_ticket_carrier_customer_deplane_at
ON ticket (carrier, customer, deplane_at);

-- Benefited Part of Procedure: In passengers_disembark, the index can be used to check if passengers can disembark efficiently.
-- The index allows the database engine to efficiently check if the passengers are on the flight, the flight is on the ground, and the flight is located at the destination airport referenced by the ticket.
-- It also helps to speed up the joins between the flight, ticket, person, route_path, and leg tables.

-- Potential Negative Effects: Since this index only includes columns used in the WHERE clause of the specific query in passengers_disembark,
-- the impact on insert, update, or delete operations on the ticket table will be minimal.
-- However, there might be a small overhead during insert or update operations on the Ticket table, especially when updating the deplane_at values, as the index needs to be updated accordingly.

-- Why this a net positive:
-- Passengers disembarking a flight is a fairly common operation. By creating this index, this procedure is optimized
-- The main drawback would be if the ticket table is getting updated more often than the passengers disembarking a flight.
-- However, considering that a ticket provides passengers access to multiple legs of a flight, so multiple disembarking opportunities for
-- one ticket, this index would have a net positive



-- Index to improve the performance of updating person's location in various stored procedures.
-- This index will be used to efficiently update the location of passengers, pilots, and flight crew in different scenarios.
CREATE INDEX idx_person_locationID
ON person (locationID);

-- Benefited Part of Procedures:
-- 1. In passengers_disembark, the index can be used to update the location of passengers after disembarking.
-- 2. In assign_pilot, the index can be used to check if the pilot and airplane locations are the same.
-- 3. In remove_passenger_role, the index can be used to check if the person is a passenger and is at the ground location.
-- 4. In remove_pilot_role, the index can be used to check if the pilot is not assigned to a flight or at the start/end of a flight.
-- 5. In people_on_the_ground, the index is used to efficiently retrieve airport details and counts of pilots and passengers.
-- The index allows the database engine to efficiently filter and join the person, pilot, and passenger tables based on the locationID.
-- This improves the performance of updating the person's location and querying the count of pilots and passengers on the ground.

-- Negative Effects:
-- Since this index only includes the locationID column used in various where and join clauses in the procedures, the impact on insert, update, or delete operations on the person table will be minimal.
-- However, there might be a small overhead during these operations due to maintaining the index.
-- In the passengers_board procedure, when updating the locationID of passengers who are boarding the flight,
-- the index will have a positive impact by allowing efficient filtering of passengers based on their current location.
-- However, it may have a minor negative effect during passenger boarding, as the index needs to be updated for each passenger boarding the flight.
-- In assign_pilot, the index is used to check if the pilot and airplane locations are the same before assigning a pilot to a flight.
-- While the index improves the efficiency of this check, there might be a minor negative impact during pilot assignment, as the index needs to be accessed for each pilot being assigned.
-- In remove_passenger_role, the index is used to check if a person is a passenger and is at the ground location before removing their passenger role.

-- Overall, the potential inefficiencies listed will likely be minor and not noticeable in most scenarios. The benefits of the index outweigh the minor overheads as it will significantly improve the performance of updating person locations and querying the count of pilots and passengers at various locations – making this a net positive index. 



-- Index to improve the performance of finding the next flight to process in simulation_cycle.
-- This index will be used to efficiently retrieve the flight with the smallest next time in chronological order,
-- giving priority to flights that are landing and then sorting by flightID in alphabetical order.
CREATE INDEX idx_flight_airplane_status_next_time
ON flight (flightID, airplane_status, next_time)

-- Benefited Part of Procedure: In simulation_cycle, the index can be used to find the next flight to process efficiently.
-- The index allows the database engine to quickly find the flight with the smallest next time that is either in flight or on the ground.
-- The ordering by airplane_status helps to prioritize landing flights over taking off flights.
-- The index also ensures that the flights are sorted alphabetically by flightID in case of a tie in next_time values.
–  In flights_in_the_air, the index is also used to efficiently retrieve flights in the air, and this index helps with quick filtering of airplane_status.
–  In flights_on _the_ground, the index is used very similarly to flights_in_the_air.
–  In flights_in_the_air, the index is also used to efficiently retrieve flights in the air, and this index helps with quick filtering of airplane_status.


-- Potential Negative Effects: While the index provides significant performance improvement in the `simulation_cycle` procedure,
-- it introduces some overhead during insert, update, and delete operations on the flight table.
-- Specifically:
-- 1. Insert Operations: When a new row is inserted into the flight table and the indexed columns (flightID, airplane_status, next_time) are modified,
--    The overhead on insert operations should be relatively low due to the limited column coverage of the index.
-- 2. Update Operations: When an existing row in the flight table is updated and the indexed columns (`flightID`, `next_time`, or `flightID`) are modified, the index needs to be updated as well to reflect the changes. Similar to insert operations, the overhead on update operations will be relatively low due to the limited column coverage.
-- 3. Delete Operations: When a row is deleted from the flight table, the index needs to be updated to remove the corresponding entry for that row. As with insert and update operations,
--    the overhead on delete operations for the `idx_flight_airplane_status_next_time` index should be minimal due to its limited column coverage.

-- Overall, the performance benefit of efficiently retrieving the next flight to process in `simulation_cycle` outweighs the potential overhead during data modification operations.
