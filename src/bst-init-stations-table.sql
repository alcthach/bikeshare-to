create table if not exists bst_stations
(
	physical_configuration	varchar,
	rental_uris		varchar,
	lon			float,
	cross_street		varchar,
	groups			varchar,
	nearby_distance		float,
	name			varchar,
	altitude		float,
	address			varchar,
	is_charging_station	boolean,
	capacity		integer,
	lat			float,
	_ride_code_support	boolean,
	rental_methods		varchar,
	post_code		varchar,
	obcn			varchar,
	station_id		varchar
)
