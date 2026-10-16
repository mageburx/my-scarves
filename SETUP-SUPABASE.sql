-- My Scarves v2.1 — tabela + Row Level Security
-- 1) Cria primeiro um projeto no Supabase.
-- 2) No Storage, cria manualmente um bucket PRIVADO com o nome: scarves
-- 3) Depois executa este script no SQL Editor.

create table if not exists public.scarves (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  club text,
  city text,
  country text,
  continent text,
  stadium text,
  founded text,
  lat double precision,
  lng double precision,
  acquired_date date,
  origin text,
  notes text,
  photo_path text,
  crest_path text,
  client_updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.scarves enable row level security;

revoke all on table public.scarves from anon, authenticated;
grant select, insert, update, delete on table public.scarves to authenticated;

drop policy if exists "myscarves_select_own" on public.scarves;
drop policy if exists "myscarves_insert_own" on public.scarves;
drop policy if exists "myscarves_update_own" on public.scarves;
drop policy if exists "myscarves_delete_own" on public.scarves;

create policy "myscarves_select_own"
on public.scarves
for select
to authenticated
using (
  (select auth.uid()) is not null
  and (select auth.uid()) = user_id
);

create policy "myscarves_insert_own"
on public.scarves
for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and (select auth.uid()) = user_id
);

create policy "myscarves_update_own"
on public.scarves
for update
to authenticated
using (
  (select auth.uid()) is not null
  and (select auth.uid()) = user_id
)
with check (
  (select auth.uid()) is not null
  and (select auth.uid()) = user_id
);

create policy "myscarves_delete_own"
on public.scarves
for delete
to authenticated
using (
  (select auth.uid()) is not null
  and (select auth.uid()) = user_id
);

-- Storage: o bucket 'scarves' deve ser PRIVADO.
-- Cada utilizador só pode ler/escrever dentro da sua própria pasta /<uid>/...

drop policy if exists "myscarves_storage_select" on storage.objects;
drop policy if exists "myscarves_storage_insert" on storage.objects;
drop policy if exists "myscarves_storage_update" on storage.objects;
drop policy if exists "myscarves_storage_delete" on storage.objects;

create policy "myscarves_storage_select"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'scarves'
  and owner_id = (select auth.uid()::text)
);

create policy "myscarves_storage_insert"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'scarves'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "myscarves_storage_update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'scarves'
  and owner_id = (select auth.uid()::text)
)
with check (
  bucket_id = 'scarves'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "myscarves_storage_delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'scarves'
  and owner_id = (select auth.uid()::text)
);
