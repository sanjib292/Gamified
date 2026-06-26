-- =============================================================================
-- 32_seed_data.sql
-- Seed data: The Psychology of Money book, learning paths, lessons,
-- quiz content, achievements, and badges
-- =============================================================================

-- Use explicit UUIDs so seeds are idempotent across environments
-- and foreign keys can be established inline.

-- ---------------------------------------------------------------------------
-- 1. Book: The Psychology of Money
-- ---------------------------------------------------------------------------
INSERT INTO books (
    id, title, author, description,
    cover_url, difficulty, is_published, is_featured,
    total_lessons
)
VALUES (
    'b1000000-0000-0000-0000-000000000001',
    'The Psychology of Money',
    'Morgan Housel',
    'Timeless lessons on wealth, greed, and happiness. Morgan Housel explores how our relationship with money is shaped by emotions, personal history, and cognitive biases — and why doing well with money has less to do with IQ than with behaviour.',
    'https://placeholder.mindquest.app/covers/psychology-of-money.jpg',
    'beginner',
    true,
    true,
    5  -- updated by trigger; set here for accuracy on first insert
)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. Learning Paths
-- ---------------------------------------------------------------------------
INSERT INTO learning_paths (id, book_id, title, description, sort_order)
VALUES
    (
        'a0100000-0000-0000-0000-000000000001',
        'b1000000-0000-0000-0000-000000000001',
        'Foundations',
        'Core ideas about how people think about and interact with money.',
        1
    ),
    (
        'a0100000-0000-0000-0000-000000000002',
        'b1000000-0000-0000-0000-000000000001',
        'Core Principles',
        'Deep dives into the mental models that drive financial decisions.',
        2
    ),
    (
        'a0100000-0000-0000-0000-000000000003',
        'b1000000-0000-0000-0000-000000000001',
        'Mastery',
        'Applying the psychology of money to long-term financial wellbeing.',
        3
    )
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 3. Lessons (Path 1: Foundations — 5 lessons)
-- ---------------------------------------------------------------------------
INSERT INTO lessons (
    id, book_id, learning_path_id, title, subtitle,
    sort_order, estimated_minutes,
    is_published, is_free_preview, xp_reward
)
VALUES
    (
        'be100000-0000-0000-0000-000000000001',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000001',
        'No One''s Crazy',
        'Everyone has a unique experience of money shaped by their generation, upbringing, and luck.',
        1, 8, true, true, 50
    ),
    (
        'be100000-0000-0000-0000-000000000002',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000001',
        'Luck & Risk',
        'Nothing is as good or as bad as it seems. Luck and risk are siblings — invisible forces that shape every financial outcome.',
        2, 9, true, false, 50
    ),
    (
        'be100000-0000-0000-0000-000000000003',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000001',
        'Never Enough',
        'The hardest financial skill is getting the goalpost to stop moving.',
        3, 7, true, false, 50
    ),
    (
        'be100000-0000-0000-0000-000000000004',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000001',
        'Confounding Compounding',
        'Warren Buffett''s secret is not just his returns — it''s time. The power of compounding only becomes visible across decades.',
        4, 10, true, false, 60
    ),
    (
        'be100000-0000-0000-0000-000000000005',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000001',
        'Getting Wealthy vs Staying Wealthy',
        'Getting money and keeping money are two different skills. Keeping it requires humility and frugality.',
        5, 11, true, false, 60
    )
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 4. Quiz content for Lesson 1: No One's Crazy
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (
    id, lesson_id, content_type, content
)
VALUES (
    'ac100000-0000-0000-0000-000000000001',
    'be100000-0000-0000-0000-000000000001',
    'quiz',
    '{
        "instructions": "Test your understanding of the No One''s Crazy chapter.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "According to Housel, why do people who grew up during periods of high inflation tend to invest less in stocks?",
                "options": [
                    "They lack financial education",
                    "Their personal experiences shaped their beliefs about money more than any textbook could",
                    "Stocks were illegal in their era",
                    "They prefer real estate"
                ],
                "correct_index": 1,
                "explanation": "Housel argues that personal history — especially formative financial experiences — shapes financial worldviews more powerfully than objective data. Living through high inflation creates lasting risk-aversion."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "What is the central point of the ''No One''s Crazy'' chapter?",
                "options": [
                    "Rich people make rational decisions; poor people do not",
                    "Financial decisions that look irrational often make complete sense given the individual''s personal experience",
                    "Everybody should read the same investing books",
                    "Emotions should be removed from financial decisions"
                ],
                "correct_index": 1,
                "explanation": "The chapter argues that every financial decision seems reasonable to the person making it based on their unique life experience — so judging others'' financial choices as ''crazy'' ignores the invisible context behind them."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "A person who grew up in poverty buys lottery tickets regularly. Housel would most likely say this is:",
                "options": [
                    "Irrational and financially illiterate",
                    "A rational response given their experience — the lottery represents the only realistic path to life-changing wealth they have ever seen",
                    "Evidence of poor upbringing",
                    "A sign of gambling addiction"
                ],
                "correct_index": 1,
                "explanation": "Housel explicitly uses the lottery as an example: for someone who has never seen wealth built through investing, buying a lottery ticket is the only tangible shot at a different life — making it psychologically rational even if statistically poor."
            }
        ]
    }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5. Achievements (15 total)
-- ---------------------------------------------------------------------------
INSERT INTO achievements (
    id, slug, title, description, icon_name, category,
    condition_type, condition_value, xp_reward, sort_order
)
VALUES
    -- Lesson milestones
    ('ac100000-0000-0000-0000-000000000001', 'first_step',       'First Step',       'Complete your very first lesson.',            'star',           'learning', 'lessons_completed', '{"count": 1}',   25,  1),
    ('ac100000-0000-0000-0000-000000000002', 'on_a_roll',        'On a Roll',        'Complete 5 lessons.',                         'bolt',           'learning', 'lessons_completed', '{"count": 5}',   50,  2),
    ('ac100000-0000-0000-0000-000000000003', 'double_digits',    'Double Digits',    'Complete 10 lessons.',                        'local_fire_department', 'learning', 'lessons_completed', '{"count": 10}',  100, 3),
    -- Streak milestones
    ('ac100000-0000-0000-0000-000000000004', 'hat_trick',        'Hat-trick',        'Maintain a 3-day learning streak.',           'whatshot',       'streak',   'streak_days',       '{"days": 3}',    30,  4),
    ('ac100000-0000-0000-0000-000000000005', 'week_warrior',     'Week Warrior',     'Maintain a 7-day learning streak.',           'emoji_events',   'streak',   'streak_days',       '{"days": 7}',    75,  5),
    ('ac100000-0000-0000-0000-000000000006', 'monthly_devotion', 'Monthly Devotion', 'Maintain a 30-day learning streak.',          'military_tech',  'streak',   'streak_days',       '{"days": 30}',   300, 6),
    -- Quiz achievements
    ('ac100000-0000-0000-0000-000000000007', 'quiz_ace',         'Quiz Ace',         'Score 100% on your first quiz.',              'grade',          'mastery',  'quiz_perfect_count','{"count": 1}',   50,  7),
    ('ac100000-0000-0000-0000-000000000008', 'quiz_master',      'Quiz Master',      'Score 100% on 10 quizzes.',                   'workspace_premium', 'mastery', 'quiz_perfect_count','{"count": 10}',  200, 8),
    -- Book completions
    ('ac100000-0000-0000-0000-000000000009', 'bookworm',         'Bookworm',         'Complete your first book.',                   'menu_book',      'mastery',  'books_completed',   '{"count": 1}',   150, 9),
    -- Level milestones
    ('ac100000-0000-0000-0000-000000000010', 'rising_scholar',   'Rising Scholar',   'Reach Level 5.',                              'school',         'learning', 'level',             '{"level": 5}',   100, 10),
    ('ac100000-0000-0000-0000-000000000011', 'knowledge_seeker', 'Knowledge Seeker', 'Reach Level 10.',                             'psychology',     'learning', 'level',             '{"level": 10}',  200, 11),
    ('ac100000-0000-0000-0000-000000000012', 'sage',             'Sage',             'Reach Level 25.',                             'auto_awesome',   'mastery',  'level',             '{"level": 25}',  500, 12),
    -- Behavioural / time-of-day achievements
    ('ac100000-0000-0000-0000-000000000013', 'early_bird',       'Early Bird',       'Complete a lesson before 8 AM.',              'wb_sunny',       'learning', 'early_bird',        '{"count": 1}',   40,  13),
    ('ac100000-0000-0000-0000-000000000014', 'night_owl',        'Night Owl',        'Complete a lesson after 9 PM.',               'nightlight',     'learning', 'night_owl',         '{"count": 1}',   40,  14),
    ('ac100000-0000-0000-0000-000000000015', 'weekend_warrior',  'Weekend Warrior',  'Complete a lesson on a Saturday or Sunday.',  'weekend',        'learning', 'weekend_warrior',   '{"count": 1}',   40,  15)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 6. Badges (5 total)
-- ---------------------------------------------------------------------------
INSERT INTO badges (
    id, slug, title, description, icon_url, color_hex, tier
)
VALUES
    ('ba100000-0000-0000-0000-000000000001', 'rookie_reader',   'Rookie Reader',   'Awarded to learners who complete their first lesson. Every great journey starts with a single page.', 'https://placeholder.mindquest.app/badges/rookie-reader.svg',   '#27AE60', 1),
    ('ba100000-0000-0000-0000-000000000002', 'quiz_champion',   'Quiz Champion',   'Awarded to learners who score 100% on 5 or more quizzes. Precision is a skill, not luck.',           'https://placeholder.mindquest.app/badges/quiz-champion.svg',   '#2980B9', 2),
    ('ba100000-0000-0000-0000-000000000003', 'streak_warrior',  'Streak Warrior',  'Awarded for maintaining a 14-day learning streak. Consistency compounds.',                           'https://placeholder.mindquest.app/badges/streak-warrior.svg',  '#E67E22', 2),
    ('ba100000-0000-0000-0000-000000000004', 'book_sage',       'Book Sage',       'Awarded for completing 3 full books on MindQuest. Depth of knowledge defines wisdom.',               'https://placeholder.mindquest.app/badges/book-sage.svg',       '#8E44AD', 3),
    ('ba100000-0000-0000-0000-000000000005', 'ai_explorer',     'AI Explorer',     'Awarded for having 10 or more AI tutor conversations. Curiosity is the engine of learning.',         'https://placeholder.mindquest.app/badges/ai-explorer.svg',     '#F39C12', 3)
ON CONFLICT (id) DO NOTHING;
