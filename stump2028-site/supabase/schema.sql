-- STUMP 2028: database schema for Supabase
-- Paste this whole file into Supabase → SQL Editor → New query → Run.

-- 1) Player profiles (one per account)
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  username text unique not null check (username ~ '^[A-Za-z0-9_]{3,20}$'),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles are public" on public.profiles;
create policy "profiles are public" on public.profiles for select using (true);
drop policy if exists "create own profile" on public.profiles;
create policy "create own profile" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "update own profile" on public.profiles;
create policy "update own profile" on public.profiles for update using (auth.uid() = id);

-- 2) Finished games
create table if not exists public.games (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  mode text not null check (mode in ('campaign','general','h2h_ai','h2h_local','h2h_online')),
  candidate text check (char_length(candidate) <= 40),
  party text check (party in ('D','R')),
  difficulty text check (difficulty in ('easy','normal','hard')),
  won boolean not null,
  nominated boolean not null default true,
  ev int check (ev between 0 and 538),
  opp_ev int check (opp_ev between 0 and 538),
  opponent text check (char_length(opponent) <= 40),
  created_at timestamptz not null default now()
);
create index if not exists games_user_idx on public.games(user_id, created_at desc);
alter table public.games enable row level security;
drop policy if exists "games are public" on public.games;
create policy "games are public" on public.games for select using (true);
drop policy if exists "insert own games" on public.games;
create policy "insert own games" on public.games for insert with check (auth.uid() = user_id);

-- 3) Achievements
create table if not exists public.achievements (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  ach_id text not null check (char_length(ach_id) <= 20),
  unlocked_at timestamptz not null default now(),
  primary key (user_id, ach_id)
);
alter table public.achievements enable row level security;
drop policy if exists "achievements are public" on public.achievements;
create policy "achievements are public" on public.achievements for select using (true);
drop policy if exists "insert own achievements" on public.achievements;
create policy "insert own achievements" on public.achievements for insert with check (auth.uid() = user_id);

-- 4) Leaderboard view
create or replace view public.leaderboard with (security_invoker = true) as
select
  p.username,
  count(g.id)::int                                                             as games,
  (count(g.id) filter (where g.won))::int                                      as wins,
  (count(g.id) filter (where g.won and g.mode in ('campaign','general')))::int as presidencies,
  (count(g.id) filter (where g.won and g.mode = 'h2h_online'))::int            as h2h_wins,
  (count(g.id) filter (where not g.won and g.mode = 'h2h_online'))::int        as h2h_losses,
  max(g.ev) filter (where g.won)                                               as best_ev
from public.profiles p
left join public.games g on g.user_id = p.id
group by p.username;
grant select on public.leaderboard to anon, authenticated;
