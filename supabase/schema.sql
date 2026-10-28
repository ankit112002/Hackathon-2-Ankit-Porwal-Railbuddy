create extension if not exists "pgcrypto";

create table trips (
  id uuid primary key default gen_random_uuid(),
  train_no text not null,
  train_name text not null,
  from_station text not null,
  to_station text not null,
  depart_time text,
  arrive_time text,
  journey_date date not null
);

create table groups (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  name text not null,
  join_code text not null unique
);

create table passengers (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  group_id uuid references groups(id) on delete set null,
  name text not null,
  coach text not null,          -- 'S1'..'S5'
  seat_no int not null,         -- 1..72 (sleeper berths)
  willing_to_swap boolean not null default true,
  constraint uq_seat unique (trip_id, coach, seat_no) deferrable initially deferred
);

create table swap_requests (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  requester_id uuid not null references passengers(id) on delete cascade,
  target_id uuid not null references passengers(id) on delete cascade,
  requester_seat text not null,   -- snapshot like 'S1/23'
  target_seat text not null,      -- snapshot like 'S2/43'
  plan_id uuid,                   -- groups the requests of one optimizer plan
  message text,
  status text not null default 'pending'
    check (status in ('pending','accepted','rejected','cancelled','invalid')),
  created_at timestamptz not null default now(),
  responded_at timestamptz
);

create index on passengers (trip_id);
create index on swap_requests (target_id, status);
create index on swap_requests (requester_id, status);
create index on swap_requests (plan_id);

-- Demo mode: no auth, so RLS stays off.
alter table trips disable row level security;
alter table groups disable row level security;
alter table passengers disable row level security;
alter table swap_requests disable row level security;

-- Realtime. Replica identity full lets filtered streams see seat changes.
alter table passengers replica identity full;
alter table swap_requests replica identity full;

alter publication supabase_realtime add table passengers;
alter publication supabase_realtime add table swap_requests;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on trips, groups, passengers, swap_requests to anon, authenticated;

-- Accept a swap atomically (swaps the two passengers' seats).
create or replace function accept_swap(req_id uuid) returns text
language plpgsql
set search_path = public
as $$
declare r swap_requests; a passengers; b passengers;
begin
  select * into r from swap_requests where id = req_id and status = 'pending' for update;
  if not found then return 'not_pending'; end if;

  select * into a from passengers where id = r.requester_id for update;
  select * into b from passengers where id = r.target_id for update;

  -- If either seat changed since the request was made, mark it invalid.
  if (a.coach || '/' || a.seat_no) <> r.requester_seat
     or (b.coach || '/' || b.seat_no) <> r.target_seat then
    update swap_requests set status = 'invalid', responded_at = now() where id = req_id;
    return 'invalid';
  end if;

  update passengers set coach = b.coach, seat_no = b.seat_no where id = a.id;
  update passengers set coach = a.coach, seat_no = a.seat_no where id = b.id;
  update swap_requests set status = 'accepted', responded_at = now() where id = req_id;
  return 'accepted';
end $$;

create or replace function reject_swap(req_id uuid) returns text
language plpgsql
set search_path = public
as $$
begin
  update swap_requests set status = 'rejected', responded_at = now()
  where id = req_id and status = 'pending';
  return 'rejected';
end $$;

create or replace function cancel_swap(req_id uuid) returns text
language plpgsql
set search_path = public
as $$
begin
  update swap_requests set status = 'cancelled', responded_at = now()
  where id = req_id and status = 'pending';
  return 'cancelled';
end $$;

grant execute on function accept_swap(uuid), reject_swap(uuid), cancel_swap(uuid) to anon, authenticated;
