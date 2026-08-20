-- Band of Eden — Admin CMS schema
--
-- Reference copy only. This is NOT run automatically by the site or by
-- Vercel — it is meant to be pasted once into the Supabase project's
-- SQL Editor (Dashboard → SQL Editor → New query → Run) as part of the
-- one-time setup. Keeping a copy here is just for disaster recovery /
-- documentation.
--
-- The Project URL below is already filled in for the "band of eden
-- website admin" Supabase project — nothing to replace, just run it.

-- ═══ TABLES ══════════════════════════════════════════
create table if not exists site_content (
  id smallint primary key default 1,
  about_text text not null default '',
  featured_track_name text not null default '',
  featured_track_url text not null default '',
  updated_at timestamptz not null default now(),
  constraint site_content_singleton check (id = 1)
);

create table if not exists socials (
  platform text primary key,             -- 'facebook' | 'instagram' | 'spotify' | 'apple_music'
  label text not null,
  url text not null default '',
  handle text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists members (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text not null,
  bio text not null default '',
  instagram_url text,
  photo_url text,
  sort_order int not null default 0,
  updated_at timestamptz not null default now()
);

-- ═══ ROW LEVEL SECURITY ══════════════════════════════
alter table site_content enable row level security;
alter table socials      enable row level security;
alter table members      enable row level security;

create policy "Public read" on site_content for select using (true);
create policy "Public read" on socials      for select using (true);
create policy "Public read" on members      for select using (true);

create policy "Admin insert" on site_content for insert to authenticated with check (true);
create policy "Admin update" on site_content for update to authenticated using (true) with check (true);
create policy "Admin insert" on socials for insert to authenticated with check (true);
create policy "Admin update" on socials for update to authenticated using (true) with check (true);
create policy "Admin insert" on members for insert to authenticated with check (true);
create policy "Admin update" on members for update to authenticated using (true) with check (true);
create policy "Admin delete" on members for delete to authenticated using (true);

-- ═══ STORAGE: member bio photos ══════════════════════
insert into storage.buckets (id, name, public)
values ('member-photos', 'member-photos', true)
on conflict (id) do nothing;

create policy "Public read member photos" on storage.objects
  for select using (bucket_id = 'member-photos');
create policy "Admin upload member photos" on storage.objects
  for insert to authenticated with check (bucket_id = 'member-photos');
create policy "Admin update member photos" on storage.objects
  for update to authenticated using (bucket_id = 'member-photos') with check (bucket_id = 'member-photos');
create policy "Admin delete member photos" on storage.objects
  for delete to authenticated using (bucket_id = 'member-photos');

-- ═══ SEED DATA (real current content) ════════════════
insert into site_content (id, about_text, featured_track_name, featured_track_url) values (
  1,
  'Eden is a rock, blues, and pop band from the Pacific Northwest, bringing an energetic and impactful sound to every performance. Led by Savanna Woods, their music combines original songs with dynamic covers from the 60s through today.',
  'Already Gone',
  'https://open.spotify.com/track/2xYmQCepznOmb9noqwPyTX?si=c32e0573ff1b47ea'
) on conflict (id) do update set
  about_text = excluded.about_text,
  featured_track_name = excluded.featured_track_name,
  featured_track_url = excluded.featured_track_url;

insert into socials (platform, label, url, handle) values
  ('facebook',    'Facebook',    'https://www.facebook.com/bandofeden', '@bandofeden'),
  ('instagram',   'Instagram',   'https://www.instagram.com/bandofeden/', '@bandofeden'),
  ('spotify',     'Spotify',     'https://open.spotify.com/artist/3MVi8s3VCXBQfafggFGbsp?si=CHlYRIBcQAWkZBNVidS4CQ', 'Eden'),
  ('apple_music', 'Apple Music', 'https://music.apple.com/us/album/eden/1692618266', 'Eden')
on conflict (platform) do update set label = excluded.label, url = excluded.url, handle = excluded.handle;

insert into members (name, role, bio, instagram_url, photo_url, sort_order) values
  ('Savanna Woods', 'Vocals & Guitar',
   'Savanna is a full-time singer-songwriter and performer from Stanwood, Washington, known for her unique and powerful voice — emotional, raspy, and masterfully controlled. She began her music career at the age of 20 but has been singing and performing her entire life, growing up singing with her dad & sisters.
Savanna was a top 20 artist on Season 20 of The Voice, and continues to grow her career. With raw, relatable original music and a captivating stage presence, she has been commanding stages across the country and globe, creating meaningful connection and community with her performances. She records and produces her own music, and performs solo, with Eden, and with a few other bands spanning genres.
Her loves are: traveling, music, gardening, and spending time in her cliff-side tiny home with her dog and two cats.',
   null, 'https://ogwjcorzsurisujvmwpp.supabase.co/storage/v1/object/public/member-photos/savanna.jpg', 0),

  ('Aaron Hiebert', 'Lead Guitar & Vocals',
   'Aaron Hiebert is a born and raised Pacific Northwest guitarist whose passion for six strings has fueled decades of playing in clubs, festivals and venues throughout Washington and the surrounding region. Influenced by guitar legends such as Stevie Ray Vaughan, Eric Johnson, and Joe Bonamassa, Aaron blends blues, rock, and soulful lead work into a style that is both expressive and unmistakably his own.
A true guitar enthusiast, Aaron lives and breathes the instrument. When he''s not playing in Eden, he''s often hunting for the next great guitar, buying, selling, and exploring new gear in an endless pursuit of tone. Whether performing on stage, jamming with fellow musicians, or talking shop with other guitar lovers, his dedication to the craft is evident in everything he does.
For Aaron, guitar isn''t just a hobby or a profession. It''s a lifelong obsession, a creative outlet, and a way of life.',
   'https://www.instagram.com/aaron_hiebert/', 'https://ogwjcorzsurisujvmwpp.supabase.co/storage/v1/object/public/member-photos/aaron.jpg', 1),

  ('Jason Edwards', 'Drums',
   'Jason Edwards held drumsticks for the first time at age 15. Prompted by a school project to learn a new skill over the next three months, he found himself at a local music store taking a drum lesson, and quickly discovered a dormant passion for music and drumming that altered his life''s direction. In addition to playing professionally, Jason records and mixes music at his home studio and teaches drum lessons. When he''s not making music, Jason enjoys trying new restaurants, movies, and family time.',
   'https://www.instagram.com/jasonedwardsdrummer/', 'https://ogwjcorzsurisujvmwpp.supabase.co/storage/v1/object/public/member-photos/jason.jpg', 2),

  ('Ethan Gibbons', 'Bass',
   'Ethan started playing guitar at 10 after discovering Green Day, then found his way to bass a few years later when a friend''s high school band needed a fill-in.
Raised on a mix of pop and heavy music, he approaches bass by serving the song, leaning into dynamics, and chasing the gnarliest tone possible. He loves Eden''s creative process and the community that''s grown around the band. Outside of music, he''s usually nerding out about bourbon, baseball, or MMA.',
   'https://www.instagram.com/ethanpatrickgibbons/', 'https://ogwjcorzsurisujvmwpp.supabase.co/storage/v1/object/public/member-photos/ethan.jpg', 3);
