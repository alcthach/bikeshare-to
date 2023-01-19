create table if not exists bst_stations
(
	station_id		varchar,
	name			varchar,
	physical_configuration	varchar,
	lat			float,
	lon			float,
	altitude		float,
	address			varchar,
	capacity		integer,
	is_charging_station	boolean,
	rental_methods		varchar,
	groups			varchar,
	obcn			varchar,
	nearby_distance		float,
	_ride_code_support	boolean
)
