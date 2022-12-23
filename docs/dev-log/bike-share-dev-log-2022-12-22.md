[[2022-12-22]]

---
09:35

Getting a bit blocked on what I should be doing with the slices of data. Intuition tells me it's better to profile and process the data all in one giant batch rather than invidually. Part of me was think I would profile each slice of data just to get a characteristic. But when I profile the data as a whole, I'll end up seeing the same characteristics of the data anyways.

There doesnt't seem to be a wrong or right way. May just a more efficient way. And also keeping in mind that this is a recursive process anyways. Not linear...

Anyways, there is going to be some profiling and cleaning as the data needs to fit in the constraints of the destination table, `trips`.

I'll take a look at that first. Re: Load all tables to `trips`

# `trips` DDL

``` sql
-- auto-generated definition
create table {trips
(
    trip_id               varchar,
    trip_duration_seconds integer,
    start_station_id      varchar,
    trip_start_time       timestamp,
    start_station_name    varchar,
    end_station_id        varchar,
    trip_end_time         timestamp,
    end_station_name      varchar,
    bike_id               varchar,
    user_type             varchar
);

alter table trips
    owner to postgres;
```

- In order to load all the slices of data successfully, the data needs to fit within the constraints seen above
- Re: Business rules
- All seem to make sense after a quick review

Quick caution, 