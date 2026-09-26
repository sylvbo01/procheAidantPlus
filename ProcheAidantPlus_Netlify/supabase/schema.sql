-- Exécuter dans Supabase SQL Editor.
create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade,email text,caregiver_name text,care_recipient_name text,care_recipient_age int check(care_recipient_age between 0 and 120),updated_at timestamptz default now());
create table if not exists public.tasks (id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,title text not null,category text default 'administratif',completed boolean default false,created_at timestamptz default now());
create table if not exists public.alerts (id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,title text not null,due_date date,created_at timestamptz default now());
create table if not exists public.documents (id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,name text not null,path text not null unique,size bigint default 0,mime_type text,created_at timestamptz default now());
alter table public.profiles enable row level security;alter table public.tasks enable row level security;alter table public.alerts enable row level security;alter table public.documents enable row level security;
drop policy if exists "profiles own" on public.profiles;
create policy "profiles own" on public.profiles for all to authenticated using ((select auth.uid())=id) with check ((select auth.uid())=id);
drop policy if exists "tasks own" on public.tasks;
create policy "tasks own" on public.tasks for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
drop policy if exists "alerts own" on public.alerts;
create policy "alerts own" on public.alerts for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
drop policy if exists "documents own" on public.documents;
create policy "documents own" on public.documents for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
grant select,insert,update,delete on public.profiles,public.tasks,public.alerts,public.documents to authenticated;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('documents','documents',false,10485760,array['application/pdf','image/jpeg','image/png','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document']) on conflict(id) do update set public=false,file_size_limit=10485760;
drop policy if exists "storage insert own" on storage.objects;
create policy "storage insert own" on storage.objects for insert to authenticated with check (bucket_id='documents' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "storage select own" on storage.objects;
create policy "storage select own" on storage.objects for select to authenticated using (bucket_id='documents' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "storage delete own" on storage.objects;
create policy "storage delete own" on storage.objects for delete to authenticated using (bucket_id='documents' and (storage.foldername(name))[1]=(select auth.uid())::text);

-- Création automatique du profil après une inscription par courriel ou Google.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,email,caregiver_name)
  values(new.id,new.email,trim(coalesce(new.raw_user_meta_data->>'first_name','')||' '||coalesce(new.raw_user_meta_data->>'last_name',new.raw_user_meta_data->>'full_name','')))
  on conflict(id) do nothing;
  return new;
end;$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
