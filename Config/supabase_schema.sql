-- ============================================
-- DailyMath — Supabase Database Schema
-- Run this SQL in the Supabase SQL Editor
-- ============================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. PROFILES (extends auth.users)
-- ============================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  email TEXT NOT NULL,
  university TEXT,
  avatar_url TEXT,
  points INT DEFAULT 0,
  level INT DEFAULT 1,
  study_streak INT DEFAULT 0,
  last_study_date DATE,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'moderator')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 2. EXERCISES
-- ============================================
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'trigonometria', 'calculo_diferencial', 'calculo_integral',
    'ecuaciones_diferenciales', 'algebra_lineal', 'probabilidad'
  )),
  statement TEXT NOT NULL,
  solution TEXT NOT NULL,
  image_url TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected', 'archived')),
  rejection_reason TEXT,
  verified_by UUID REFERENCES profiles(id),
  votes_count INT DEFAULT 0,
  is_preloaded BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 3. USER FLASHCARDS (Spaced Repetition Deck)
-- ============================================
CREATE TABLE user_flashcards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
  easiness_factor FLOAT DEFAULT 2.5,
  interval INT DEFAULT 0,
  repetitions INT DEFAULT 0,
  next_review_date DATE DEFAULT CURRENT_DATE,
  last_review_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, exercise_id)
);

-- ============================================
-- 4. VOTES
-- ============================================
CREATE TABLE votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, exercise_id)
);

-- ============================================
-- 5. COMMENTS
-- ============================================
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 6. USER BADGES
-- ============================================
CREATE TABLE user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  badge_key TEXT NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, badge_key)
);

-- ============================================
-- 7. NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 8. DUELS
-- ============================================
CREATE TABLE duels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player1_id UUID REFERENCES profiles(id),
  player2_id UUID REFERENCES profiles(id),
  category TEXT,
  status TEXT DEFAULT 'waiting' CHECK (status IN ('waiting', 'active', 'finished', 'cancelled')),
  player1_score INT DEFAULT 0,
  player2_score INT DEFAULT 0,
  winner_id UUID REFERENCES profiles(id),
  current_question INT DEFAULT 0,
  total_questions INT DEFAULT 5,
  invite_code TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  finished_at TIMESTAMPTZ
);

-- ============================================
-- 9. DUEL QUESTIONS
-- ============================================
CREATE TABLE duel_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  duel_id UUID REFERENCES duels(id) ON DELETE CASCADE,
  question_index INT NOT NULL,
  num1 INT NOT NULL,
  num2 INT NOT NULL,
  operation TEXT NOT NULL,
  correct_answer INT NOT NULL,
  player1_answer INT,
  player1_time_ms INT,
  player2_answer INT,
  player2_time_ms INT
);

-- ============================================
-- 10. TOURNAMENTS
-- ============================================
CREATE TABLE tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('upcoming', 'active', 'finished')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 11. TOURNAMENT PARTICIPANTS
-- ============================================
CREATE TABLE tournament_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  score INT DEFAULT 0,
  duels_won INT DEFAULT 0,
  duels_played INT DEFAULT 0,
  UNIQUE(tournament_id, user_id)
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE duels ENABLE ROW LEVEL SECURITY;
ALTER TABLE duel_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;

-- PROFILES: Users can read all profiles, update own
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can delete own profile" ON profiles FOR DELETE USING (auth.uid() = id);

-- EXERCISES: Everyone can read verified, authors can CRUD own
CREATE POLICY "Verified exercises are viewable by everyone" ON exercises FOR SELECT USING (
  status = 'verified' OR status = 'pending' OR author_id = auth.uid()
);
CREATE POLICY "Authenticated users can create exercises" ON exercises FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Authors can update own exercises" ON exercises FOR UPDATE USING (
  author_id = auth.uid() OR 
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'moderator')
);
CREATE POLICY "Authors can delete own exercises" ON exercises FOR DELETE USING (author_id = auth.uid());

-- USER_FLASHCARDS: Users can manage own flashcards
CREATE POLICY "Users can read own flashcards" ON user_flashcards FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can create flashcards" ON user_flashcards FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update own flashcards" ON user_flashcards FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete own flashcards" ON user_flashcards FOR DELETE USING (user_id = auth.uid());

-- VOTES: Users can manage own votes, read all
CREATE POLICY "Votes are viewable by everyone" ON votes FOR SELECT USING (true);
CREATE POLICY "Users can create votes" ON votes FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can delete own votes" ON votes FOR DELETE USING (user_id = auth.uid());

-- COMMENTS: Everyone can read, users manage own
CREATE POLICY "Comments are viewable by everyone" ON comments FOR SELECT USING (true);
CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (user_id = auth.uid());

-- USER_BADGES: Users can read own
CREATE POLICY "Users can read own badges" ON user_badges FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "System can insert badges" ON user_badges FOR INSERT WITH CHECK (user_id = auth.uid());

-- NOTIFICATIONS: Users can manage own
CREATE POLICY "Users can read own notifications" ON notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Anyone can insert notifications" ON notifications FOR INSERT WITH CHECK (true);

-- DUELS: Players can see their duels, waiting duels are public
CREATE POLICY "Duels are viewable" ON duels FOR SELECT USING (
  status = 'waiting' OR player1_id = auth.uid() OR player2_id = auth.uid()
);
CREATE POLICY "Users can create duels" ON duels FOR INSERT WITH CHECK (player1_id = auth.uid());
CREATE POLICY "Players can update their duels" ON duels FOR UPDATE USING (
  player1_id = auth.uid() OR player2_id = auth.uid()
);

-- DUEL_QUESTIONS: Visible to duel participants
CREATE POLICY "Duel questions are viewable by participants" ON duel_questions FOR SELECT USING (
  EXISTS (SELECT 1 FROM duels WHERE duels.id = duel_id AND (player1_id = auth.uid() OR player2_id = auth.uid()))
);
CREATE POLICY "Users can insert duel questions" ON duel_questions FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update duel questions" ON duel_questions FOR UPDATE USING (true);

-- TOURNAMENTS: Viewable by everyone
CREATE POLICY "Tournaments are viewable by everyone" ON tournaments FOR SELECT USING (true);

-- TOURNAMENT_PARTICIPANTS: Viewable by everyone, users manage own
CREATE POLICY "Tournament participants are viewable" ON tournament_participants FOR SELECT USING (true);
CREATE POLICY "Users can join tournaments" ON tournament_participants FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update own participation" ON tournament_participants FOR UPDATE USING (user_id = auth.uid());

-- ============================================
-- REALTIME: Enable for tables that need it
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE duels;
ALTER PUBLICATION supabase_realtime ADD TABLE duel_questions;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE comments;

-- ============================================
-- SEED: Initial moderator
-- ============================================
-- NOTE: First create the user via Supabase Auth, then update their role:
-- UPDATE profiles SET role = 'moderator' WHERE email = 'moderador@dailymath.com';

-- ============================================
-- STORAGE: Create bucket for exercise images
-- ============================================
-- Run this in the Supabase dashboard > Storage > Create Bucket:
-- Bucket name: exercise-images
-- Public: true
