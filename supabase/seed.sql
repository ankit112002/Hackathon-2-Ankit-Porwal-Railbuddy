-- Safe to re-run: removes the demo trip and every row that belongs to it.
delete from trips;

do $$
declare t uuid; g uuid;
begin
  insert into trips (train_no, train_name, from_station, to_station, depart_time, arrive_time, journey_date)
  values ('12345', 'Demo Express', 'Indore Jn', 'Mumbai', '18:40', '06:15', '2026-11-14')
  returning id into t;

  insert into groups (trip_id, name, join_code) values (t, 'Sharma Family', 'RAIL-7X92')
  returning id into g;

  -- Sharma Family (scattered across 5 coaches)
  insert into passengers (trip_id, group_id, name, coach, seat_no, willing_to_swap) values
    (t, g, 'Aman',   'S1', 23, true),
    (t, g, 'Bhavna', 'S2', 41, true),
    (t, g, 'Chetan', 'S2', 42, true),
    (t, g, 'Disha',  'S3', 56, true),
    (t, g, 'Esha',   'S4', 21, true),
    (t, g, 'Farhan', 'S5', 37, true);

  -- Volunteers in the target bay (S2, seats 41 to 48)
  insert into passengers (trip_id, group_id, name, coach, seat_no, willing_to_swap) values
    (t, null, 'Passenger P', 'S2', 43, true),
    (t, null, 'Passenger Q', 'S2', 44, true),
    (t, null, 'Passenger R', 'S2', 45, true),
    (t, null, 'Passenger S', 'S2', 46, true),
    (t, null, 'Passenger T', 'S2', 47, false),
    (t, null, 'Passenger U', 'S2', 48, false);

  -- Other passengers for the individual swap demo
  insert into passengers (trip_id, group_id, name, coach, seat_no, willing_to_swap) values
    (t, null, 'Rahul',  'S1', 24, true),   -- Lower berth next to Aman
    (t, null, 'Priya',  'S1', 25, true),
    (t, null, 'Karan',  'S1', 22, false),
    (t, null, 'Neha',   'S1', 28, true),
    (t, null, 'Vikas',  'S1', 17, true),
    (t, null, 'Sunita', 'S3', 57, true),
    (t, null, 'Manoj',  'S3', 49, true),
    (t, null, 'Ritu',   'S3', 60, false),
    (t, null, 'Deepak', 'S4', 22, true),
    (t, null, 'Anjali', 'S4', 30, true),
    (t, null, 'Imran',  'S5', 38, true),
    (t, null, 'Pooja',  'S5', 36, false);
end $$;
