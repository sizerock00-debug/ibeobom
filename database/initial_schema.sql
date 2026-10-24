-- 입어봄 전용 Supabase 프로젝트에서만 실행할 초기 스키마
-- 겜허브 데이터베이스에는 적용하지 마세요.
create table if not exists public.ibeobom_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 2 and 30),
  created_at timestamptz not null default now()
);
create table if not exists public.ibeobom_posts (
  id bigint generated always as identity primary key,
  author_id uuid not null references auth.users(id) on delete cascade,
  board text not null check (board in ('consult','closet')),
  category text not null check (char_length(category) between 1 and 40),
  title text not null check (char_length(title) between 1 and 100),
  body text not null check (char_length(body) between 1 and 10000),
  created_at timestamptz not null default now()
);
create table if not exists public.ibeobom_comments (
  id bigint generated always as identity primary key,
  post_id bigint not null references public.ibeobom_posts(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 3000),
  created_at timestamptz not null default now()
);
create index if not exists ibeobom_posts_created_idx on public.ibeobom_posts(created_at desc);
create index if not exists ibeobom_comments_post_idx on public.ibeobom_comments(post_id,created_at);
alter table public.ibeobom_profiles enable row level security;
alter table public.ibeobom_posts enable row level security;
alter table public.ibeobom_comments enable row level security;
create policy "profiles_read" on public.ibeobom_profiles for select to anon, authenticated using (true);
create policy "profiles_insert_own" on public.ibeobom_profiles for insert to authenticated with check ((select auth.uid())=id);
create policy "profiles_update_own" on public.ibeobom_profiles for update to authenticated using ((select auth.uid())=id) with check ((select auth.uid())=id);
create policy "posts_read" on public.ibeobom_posts for select to anon, authenticated using (true);
create policy "posts_insert_own" on public.ibeobom_posts for insert to authenticated with check ((select auth.uid())=author_id);
create policy "posts_update_own" on public.ibeobom_posts for update to authenticated using ((select auth.uid())=author_id) with check ((select auth.uid())=author_id);
create policy "posts_delete_own" on public.ibeobom_posts for delete to authenticated using ((select auth.uid())=author_id);
create policy "comments_read" on public.ibeobom_comments for select to anon, authenticated using (true);
create policy "comments_insert_own" on public.ibeobom_comments for insert to authenticated with check ((select auth.uid())=author_id);
create policy "comments_update_own" on public.ibeobom_comments for update to authenticated using ((select auth.uid())=author_id) with check ((select auth.uid())=author_id);
create policy "comments_delete_own" on public.ibeobom_comments for delete to authenticated using ((select auth.uid())=author_id);
