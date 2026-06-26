-- =============================================================================
-- 33_full_content_seed.sql
-- Full lesson + quiz content for "The Psychology of Money" by Morgan Housel
--
-- Path 1 (Foundations):   lessons be1x already inserted; add quiz for lessons 2-5
-- Path 2 (Core Principles): insert 5 lessons + quiz
-- Path 3 (Mastery):          insert 5 lessons + quiz
-- =============================================================================

-- ---------------------------------------------------------------------------
-- PATH 2  ▸  Core Principles — 5 lessons (chapters 6–10)
-- ---------------------------------------------------------------------------
INSERT INTO lessons (
    id, book_id, learning_path_id, title, subtitle,
    sort_order, estimated_minutes, is_published, is_free_preview, xp_reward
)
VALUES
    (
        'be200000-0000-0000-0000-000000000001',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000002',
        'Tails, You Win',
        'A tiny number of events explain the majority of all outcomes. Long tails drive everything.',
        1, 10, true, false, 60
    ),
    (
        'be200000-0000-0000-0000-000000000002',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000002',
        'Freedom',
        'The highest form of wealth is the ability to wake up every morning and do whatever you want.',
        2, 9, true, false, 60
    ),
    (
        'be200000-0000-0000-0000-000000000003',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000002',
        'Man in the Car Paradox',
        'No one is as impressed by your possessions as you think they are.',
        3, 8, true, false, 60
    ),
    (
        'be200000-0000-0000-0000-000000000004',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000002',
        'Wealth is What You Don''t See',
        'Spending money to show people how much you have is the fastest way to have less.',
        4, 9, true, false, 60
    ),
    (
        'be200000-0000-0000-0000-000000000005',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000002',
        'Save Money',
        'Building wealth has little to do with your income or investment returns and everything to do with your savings rate.',
        5, 10, true, false, 60
    )
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 3  ▸  Mastery — 5 lessons (chapters 11–15)
-- ---------------------------------------------------------------------------
INSERT INTO lessons (
    id, book_id, learning_path_id, title, subtitle,
    sort_order, estimated_minutes, is_published, is_free_preview, xp_reward
)
VALUES
    (
        'be300000-0000-0000-0000-000000000001',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000003',
        'Reasonable > Rational',
        'Aiming to be mostly reasonable works better than being coldly rational when it comes to money.',
        1, 10, true, false, 70
    ),
    (
        'be300000-0000-0000-0000-000000000002',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000003',
        'Surprise!',
        'History is mostly the study of surprising events — yet we use it to predict the future.',
        2, 11, true, false, 70
    ),
    (
        'be300000-0000-0000-0000-000000000003',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000003',
        'Room for Error',
        'The most important part of any financial plan is planning on your plan not going according to plan.',
        3, 10, true, false, 70
    ),
    (
        'be300000-0000-0000-0000-000000000004',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000003',
        'You''ll Change',
        'Long-term financial planning is made harder by the fact that your goals will change over time.',
        4, 9, true, false, 70
    ),
    (
        'be300000-0000-0000-0000-000000000005',
        'b1000000-0000-0000-0000-000000000001',
        'a0100000-0000-0000-0000-000000000003',
        'Nothing''s Free',
        'Market returns are never free. The price you pay is volatility, doubt, and uncertainty.',
        5, 11, true, false, 70
    )
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- QUIZ CONTENT
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- PATH 1  ▸  Lesson 2: Luck & Risk
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c1020000-0000-0000-0000-000000000001',
    'be100000-0000-0000-0000-000000000002',
    'quiz',
    '{
        "instructions": "Test your understanding of Luck & Risk.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Bill Gates attended one of the only high schools in the world with a computer terminal in 1968. Housel uses this to illustrate:",
                "options": [
                    "Gates was exceptionally gifted from birth",
                    "Hard work always leads to extraordinary success",
                    "Luck — a single fortunate circumstance — can be the defining factor in extreme success",
                    "Education systems determine your financial destiny"
                ],
                "correct_index": 2,
                "explanation": "Gates''s trillion-dollar outcome was built on a remarkable stroke of luck: access to a computer as a teenager in 1968 was nearly unheard of. Skill mattered enormously — but luck opened the door."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "Housel says luck and risk are ''siblings.'' What does he mean?",
                "options": [
                    "Both can make you extremely wealthy",
                    "Both are invisible forces outside your control that powerfully shape outcomes",
                    "Both can be managed with the right strategy",
                    "They cancel each other out over a lifetime"
                ],
                "correct_index": 1,
                "explanation": "If luck exists — if random good fortune can supercharge an outcome — then risk must equally exist: random bad fortune can destroy an outcome regardless of effort. Both are real, both are invisible, and both humbling."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Why should we be cautious about studying the habits of extremely successful investors like Warren Buffett?",
                "options": [
                    "Their strategies are illegal in most countries",
                    "They refuse to share their real secrets",
                    "Survivorship bias hides the many people who used the same strategies and failed",
                    "Their results cannot be replicated due to market changes"
                ],
                "correct_index": 2,
                "explanation": "We study Buffett because he survived. For every person who made concentrated bets and became wealthy, thousands more used the same strategy and went broke. Focusing only on winners creates a dangerously skewed view of what works."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 1  ▸  Lesson 3: Never Enough
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c1030000-0000-0000-0000-000000000001',
    'be100000-0000-0000-0000-000000000003',
    'quiz',
    '{
        "instructions": "Test your understanding of Never Enough.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel opens with the story of Rajat Gupta, who went to prison for insider trading despite being worth hundreds of millions. What does this illustrate?",
                "options": [
                    "Wealthy people are fundamentally dishonest",
                    "The financial system is rigged against honest people",
                    "Having an enormous amount is not enough when the goalpost keeps moving — the pursuit of more can destroy what you already have",
                    "Success in business always leads to ethical compromises"
                ],
                "correct_index": 2,
                "explanation": "Gupta had $100M+ but was surrounded by billionaires, making him feel poor by comparison. The goalpost moved. He risked — and lost — everything in pursuit of ''enough.'' Enough is a concept that must be defined internally, not by comparison."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "According to Housel, what is the most dangerous financial goal?",
                "options": [
                    "Trying to time the market",
                    "Letting the goalpost keep moving — always wanting just a little more than you currently have",
                    "Investing in individual stocks",
                    "Taking on debt to invest"
                ],
                "correct_index": 1,
                "explanation": "When enough is always just out of reach, people make increasingly risky bets. The antidote is defining enough in advance — deciding what amount of money, status, or comfort would genuinely satisfy you, and stopping there."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Housel argues that social comparison is the root of ''never enough.'' What is his proposed solution?",
                "options": [
                    "Earn more so the comparisons become irrelevant",
                    "Avoid all social media",
                    "Stop comparing yourself to others entirely — the only benchmark that matters is whether you have enough for your own goals",
                    "Move to a smaller community with lower wealth benchmarks"
                ],
                "correct_index": 2,
                "explanation": "Comparison is a game you cannot win because there will always be someone richer. The only winning move is to define enough by your own standards — your goals, your values, your life — and refuse to move the goalpost."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 1  ▸  Lesson 4: Confounding Compounding
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c1040000-0000-0000-0000-000000000001',
    'be100000-0000-0000-0000-000000000004',
    'quiz',
    '{
        "instructions": "Test your understanding of Compounding.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Buffett began serious investing at age 10, and had $84.5 billion of his $84.5 billion net worth accumulated after age 65. What is the key insight Housel draws from this?",
                "options": [
                    "You need to start investing young to become wealthy",
                    "Buffett''s skill is not his returns — it''s that he has been earning good returns for 75+ years. Compounding needs time, not just high returns",
                    "Index funds are better than active management",
                    "Retirement accounts are the best way to build wealth"
                ],
                "correct_index": 1,
                "explanation": "If Buffett had started investing at 30 and retired at 60 like most people, his net worth would be $11.9M — 99.9% less. His secret is duration. $81.5B of his wealth came after age 65 because compounding accelerates exponentially over decades."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "Why is compounding so counterintuitive to most people?",
                "options": [
                    "It only works in bull markets",
                    "Human brains evolved to think linearly, not exponentially — we consistently underestimate how growth accelerates over time",
                    "It requires complex financial instruments",
                    "Most people do not save enough to see the effects"
                ],
                "correct_index": 1,
                "explanation": "Growth that doubles repeatedly becomes astronomical, but our intuition struggles with this. $1 growing 20% for 30 years becomes $237 — 237x the original. Most people''s intuition says ''maybe 6 or 7 times.'' This mismatch leads us to undervalue patience."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Housel argues that the real trick with compounding is not earning the highest returns, but:",
                "options": [
                    "Diversifying across asset classes",
                    "Beating inflation",
                    "Never interrupting it unnecessarily — staying invested and not cashing out during downturns",
                    "Reinvesting dividends automatically"
                ],
                "correct_index": 2,
                "explanation": "''Good investing is not necessarily about earning the highest returns, because the highest returns tend to be one-off hits. It''s about earning pretty good returns that you can stick with for a long period of time.'' Consistency beats brilliance."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 1  ▸  Lesson 5: Getting Wealthy vs Staying Wealthy
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c1050000-0000-0000-0000-000000000001',
    'be100000-0000-0000-0000-000000000005',
    'quiz',
    '{
        "instructions": "Test your understanding of Getting vs Staying Wealthy.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel says getting money and keeping money are two different skills. What is the key difference?",
                "options": [
                    "Getting money requires intelligence; keeping it requires discipline",
                    "Getting money requires optimism and risk-taking; keeping it requires humility, fear, and frugality",
                    "Getting money is easier when young; keeping it becomes easier with age",
                    "Getting money needs external help; keeping it is a solo effort"
                ],
                "correct_index": 1,
                "explanation": "Getting rich often requires boldness, leverage, and concentrated bets. But staying rich requires a completely different mindset: humility about how fast things can change, frugality, and avoiding single points of failure. The same traits that build wealth can destroy it."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "What does Housel mean by ''survival'' as the ultimate financial skill?",
                "options": [
                    "Living below the poverty line to maximize savings",
                    "Avoiding all investment risk",
                    "Staying in the game long enough for compounding to work — not being forced out by bad luck, debt, or panic",
                    "Having enough insurance to cover any loss"
                ],
                "correct_index": 2,
                "explanation": "Compounding only works if you can survive. Being wiped out — by debt, by panic-selling, by over-leverage — ends the compounding chain. The most critical financial skill is not optimizing returns but ensuring you can never be permanently knocked out of the game."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Housel talks about being ''financially unbreakable'' rather than trying to be optimal. What does this mean in practice?",
                "options": [
                    "Keeping all money in cash",
                    "Holding some extra savings, avoiding debt, and leaving room for error — even if it means sacrificing some returns",
                    "Diversifying into at least 50 different assets",
                    "Never spending money on experiences"
                ],
                "correct_index": 1,
                "explanation": "Optimization is fragile. The financially unbreakable person has a cash buffer, modest debt, and a plan that still works if the worst happens. They earn slightly less in good times but can absorb bad times without being forced to sell at the worst moment."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 2  ▸  Lesson 1: Tails, You Win
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c2010000-0000-0000-0000-000000000001',
    'be200000-0000-0000-0000-000000000001',
    'quiz',
    '{
        "instructions": "Test your understanding of Tails, You Win.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel explains that in venture capital, a tiny number of investments produce most of the returns. How does this ''tail'' principle apply to personal investing?",
                "options": [
                    "You should only invest in the top 1% of stocks",
                    "A small number of your investment decisions will account for most of your lifetime returns — so surviving long enough to experience them is critical",
                    "Diversification is a myth and concentrated bets are always better",
                    "The market always recovers within 5 years"
                ],
                "correct_index": 1,
                "explanation": "Heinz Berggruen bought cheap art from starving artists his whole life. Most of it was worthless. A tiny fraction — Picasso, Matisse, Klee — made him a billionaire. The point is not picking winners in advance, but staying in the game long enough for a few massive wins to emerge."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "How does the ''tails'' concept change how we should feel about investment failures?",
                "options": [
                    "Failures are always the result of poor decisions and should be avoided entirely",
                    "Failures are acceptable as long as you learn from them",
                    "Failures are an expected, unavoidable cost of being invested — if you never fail, you''re probably not taking enough long-term risk",
                    "Failures should trigger a review of your entire strategy"
                ],
                "correct_index": 2,
                "explanation": "Amazon made 97% of all its free cash flow from AWS and the marketplace. Everything else was a relative failure. Apple generates nearly all profit from iPhone. Even the most successful businesses are mostly failures — the tail wins pay for everything."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "A fund manager is ''wrong'' 40% of the time. According to Housel, this most likely means:",
                "options": [
                    "They should be fired immediately",
                    "They are one of the best in the world — if the wins are large enough, the loss rate doesn''t matter",
                    "Their strategy needs fundamental revision",
                    "They are no better than a random stock picker"
                ],
                "correct_index": 1,
                "explanation": "Peter Lynch''s Magellan Fund beat the market for 13 years while his best picks were enormous outliers. Being wrong often is compatible with outstanding results when the wins are large. The size of wins matters more than the frequency."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 2  ▸  Lesson 2: Freedom
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c2020000-0000-0000-0000-000000000001',
    'be200000-0000-0000-0000-000000000002',
    'quiz',
    '{
        "instructions": "Test your understanding of Freedom.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel argues that the highest form of wealth is not a dollar amount. What is it?",
                "options": [
                    "Owning a home outright",
                    "Retiring at 40",
                    "Having control over your time — the ability to do what you want, when you want, with who you want, for as long as you want",
                    "Having enough to never worry about money"
                ],
                "correct_index": 2,
                "explanation": "''The ability to do what you want, when you want, with who you want, for as long as you want is priceless. It is the highest dividend money pays.'' A person who earns $100K but fully controls their time is wealthier in the ways that matter than someone earning $500K but constantly stressed and directed by others."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "Research cited by Housel shows that having money correlates with happiness up to about $75,000/year income. What does this suggest about the relationship between money and well-being?",
                "options": [
                    "Money cannot buy happiness above any amount",
                    "Happiness is entirely psychological and money is irrelevant",
                    "Beyond covering genuine needs, additional money improves well-being primarily by buying autonomy and freedom — not luxury goods",
                    "Everyone should aim to earn exactly $75,000 per year"
                ],
                "correct_index": 2,
                "explanation": "The well-being gains from income come from solving real problems: not worrying about rent, feeding your family, getting healthcare. Beyond that threshold, the gains come from what money buys in autonomy — the freedom to say no, to choose your work, to take time."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Someone chooses a lower-paying job that lets them work from home, set their own hours, and spend afternoons with their children. By Housel''s definition, have they made a good financial decision?",
                "options": [
                    "No — they are leaving money on the table and should maximize income",
                    "Yes — if the autonomy and time align with what they truly value, they may be wealthier in the ways that matter",
                    "It depends on whether they can still max out their retirement account",
                    "No — financial decisions should always prioritize income growth when young"
                ],
                "correct_index": 1,
                "explanation": "Housel would say yes. The highest return money pays is control over your time. Trading income for genuine autonomy is a rational, even optimal trade — especially if money beyond a certain threshold delivers diminishing returns on happiness."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 2  ▸  Lesson 3: Man in the Car Paradox
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c2030000-0000-0000-0000-000000000001',
    'be200000-0000-0000-0000-000000000003',
    'quiz',
    '{
        "instructions": "Test your understanding of the Man in the Car Paradox.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel notices a Lamborghini and thinks ''what an impressive car'' rather than ''what an impressive person.'' What paradox does this reveal?",
                "options": [
                    "Expensive cars are always a bad investment",
                    "People buy luxury goods to signal wealth, but observers admire the object not the owner — the status signal mostly fails",
                    "You should never judge someone by their possessions",
                    "Sports cars attract more attention than sedans"
                ],
                "correct_index": 1,
                "explanation": "''When you see someone driving a nice car, you rarely think ''wow, the person driving that car is cool.'' Instead, you think ''wow, if I had that car, people would think I''m cool.'' But you don''t think that about the actual driver.'' The admiration goes to the object, not the person."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "What is the most effective way to earn genuine admiration and respect, according to Housel?",
                "options": [
                    "Drive a luxury car and wear expensive clothes",
                    "Live in an expensive neighborhood",
                    "Humility, kindness, empathy — traits that cost nothing but signal genuine character",
                    "Achieve a very high net worth and let people know about it"
                ],
                "correct_index": 2,
                "explanation": "Housel argues that the traits that earn genuine admiration — intelligence, humility, empathy, kindness — cost nothing and cannot be faked with a car or a house. Trying to signal success through purchases is a expensive strategy that mostly fails."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "How should the Man in the Car Paradox change your spending decisions?",
                "options": [
                    "Never spend money on status goods",
                    "Only buy luxury goods if you can truly afford them",
                    "Before buying something to impress others, recognize that observers will admire the thing, not you — and ask if the purchase still makes sense",
                    "Always choose the cheaper option"
                ],
                "correct_index": 2,
                "explanation": "The paradox doesn''t say never buy nice things. It says: be honest about why you''re buying them. If you genuinely love a car for the experience of driving it, that''s valid. But if you''re buying it to earn admiration and respect — Housel''s observation suggests that goal will mostly fail."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 2  ▸  Lesson 4: Wealth is What You Don't See
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c2040000-0000-0000-0000-000000000001',
    'be200000-0000-0000-0000-000000000004',
    'quiz',
    '{
        "instructions": "Test your understanding of hidden wealth.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel''s central claim in this chapter is that ''wealth is what you don''t see.'' What does he mean?",
                "options": [
                    "Wealthy people hide their assets in offshore accounts",
                    "True wealth is assets not yet spent — savings, investments, options — invisible to outsiders. The cars and houses signal income spent, not wealth retained",
                    "The wealthiest people always live modestly",
                    "Wealth is measured in experiences, not possessions"
                ],
                "correct_index": 1,
                "explanation": "A person who drives a $100,000 car has $100,000 less than they would otherwise. True wealth is the money that hasn''t been converted into visible stuff — it''s the retained assets that give you options, security, and freedom. Wealth is hidden by definition."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "Why is it dangerous to model your financial behavior on what you ''see'' wealthy people doing?",
                "options": [
                    "You might make poor investment decisions copying their portfolio",
                    "What you see is spending, not saving — you''re modeling conspicuous consumption, not the behavior that built the wealth",
                    "Rich people are secretive and mislead imitators on purpose",
                    "Their tax situation is fundamentally different from yours"
                ],
                "correct_index": 1,
                "explanation": "You cannot see someone''s net worth. You can only see what they spend. If you try to ''look wealthy'' by buying what wealthy-looking people buy, you''re adopting the visible portion of their lifestyle without the invisible foundation — the savings and investments — that makes it sustainable."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "According to Housel, someone who genuinely wants to be wealthy should focus on:",
                "options": [
                    "Earning more so they can buy assets and look successful",
                    "Investing in real estate which is the most visible asset class",
                    "Increasing the gap between what they earn and what they spend — and preserving that gap in savings and investments",
                    "Maximizing their credit score to access better investment opportunities"
                ],
                "correct_index": 2,
                "explanation": "Wealth is built in the gap between earning and spending. The wider that gap, and the more consistently it''s directed into assets rather than consumption, the faster true (invisible) wealth accumulates. ''The only way to build wealth is to not spend money you have.'' It''s that simple."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 2  ▸  Lesson 5: Save Money
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c2050000-0000-0000-0000-000000000001',
    'be200000-0000-0000-0000-000000000005',
    'quiz',
    '{
        "instructions": "Test your understanding of saving money.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel argues that savings is less about investment returns and more about your savings rate. Why?",
                "options": [
                    "Investment returns are unpredictable so you should not count on them",
                    "Savings rate is entirely within your control, while returns are not — and a high savings rate creates wealth regardless of market conditions",
                    "Tax advantages make saving more lucrative than investing",
                    "Compound interest only kicks in above a certain threshold that requires high savings first"
                ],
                "correct_index": 1,
                "explanation": "Returns depend on markets, luck, and skill — forces partly outside your control. Your savings rate is fully within your control. Housel argues building a high savings rate is the single most reliable path to wealth because it doesn''t depend on anything external going right."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "What does Housel say is the real value of saving beyond covering obvious needs?",
                "options": [
                    "It lets you retire earlier",
                    "It gives you options and flexibility — the ability to wait for the right opportunity, change jobs, weather bad times, or take risks others cannot",
                    "It generates compound interest that eventually exceeds your salary",
                    "It protects against inflation"
                ],
                "correct_index": 1,
                "explanation": "''Saving money is the gap between your ego and your income.'' Beyond survival, savings buys something priceless: optionality. The ability to say no to a bad job, to weather a recession without selling assets at the wrong time, to take opportunities when they arise."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Housel says you don''t need a specific reason to save. Why is ''no reason'' a valid reason to save?",
                "options": [
                    "It forces good habits regardless of life goals",
                    "The future is unpredictable — saving gives you the ability to respond to events you cannot anticipate today",
                    "Banks reward customers who save consistently",
                    "Tax-deferred growth compounds faster without a specific goal"
                ],
                "correct_index": 1,
                "explanation": "You don''t know what you''ll want in 10 years. You don''t know what will go wrong. You don''t know what opportunity will appear. Savings without a specific goal is a hedge against life''s unpredictability — it gives future-you the maximum number of options."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 3  ▸  Lesson 1: Reasonable > Rational
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c3010000-0000-0000-0000-000000000001',
    'be300000-0000-0000-0000-000000000001',
    'quiz',
    '{
        "instructions": "Test your understanding of Reasonable vs Rational.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel argues that ''reasonable'' financial behavior is often better than ''rational'' financial behavior. What is the key distinction?",
                "options": [
                    "Rational behavior always maximizes returns; reasonable behavior is for amateurs",
                    "Reasonable behavior accounts for human emotions — a strategy you can actually stick to is better than the ''optimal'' strategy you abandon when it gets uncomfortable",
                    "Rational behavior requires expensive financial advisors",
                    "Reasonable means being conservative with investments"
                ],
                "correct_index": 1,
                "explanation": "The ''rational'' advice to hold through a 50% crash is mathematically correct. But if you cannot psychologically bear to do it and panic-sell at the bottom, the rational strategy was useless to you. A slightly sub-optimal strategy you can actually stick to beats an optimal one you''ll abandon."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "An investor holds some cash even though economists say cash is a drag on returns. Housel would most likely say:",
                "options": [
                    "They are making a costly mistake and should be fully invested",
                    "They are reasonable — if the cash helps them sleep at night and prevents panic-selling, it earns its cost by keeping them in the game",
                    "They should invest the cash in bonds instead",
                    "They lack financial literacy and need education"
                ],
                "correct_index": 1,
                "explanation": "The ''cost'' of holding cash is real — you miss some returns. But the benefit is psychological: knowing you have a buffer means you''re less likely to panic-sell your equities when markets crash. A strategy you can maintain through storms beats one you abandon. That''s reasonable over rational."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "Housel uses the example of doctors recommending patients ''fall in love'' with their treatment plan. How does this apply to investing?",
                "options": [
                    "You should only invest in companies whose products you personally use",
                    "Emotional attachment to your portfolio helps you hold through volatility",
                    "The best financial plan is the one you can emotionally commit to and maintain long-term, even if it''s not theoretically optimal",
                    "Loving your investments prevents you from making rational sell decisions"
                ],
                "correct_index": 2,
                "explanation": "A patient who loves their diet plan will stick to it. One who resents it will abandon it. Similarly, a financial plan you genuinely believe in — that fits your psychology, values, and risk tolerance — will be followed through downturns. Adherence over optimization."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 3  ▸  Lesson 2: Surprise!
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c3020000-0000-0000-0000-000000000001',
    'be300000-0000-0000-0000-000000000002',
    'quiz',
    '{
        "instructions": "Test your understanding of Surprise!",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel''s central point in this chapter is that history is used as a guide to the future, but history is mostly a record of surprises. What does this mean for investors?",
                "options": [
                    "Investors should ignore historical data entirely",
                    "The future will likely include events that have no historical precedent — building plans that can only survive ''normal'' conditions is dangerous",
                    "Historical returns are a reliable predictor of future returns",
                    "Market cycles repeat exactly every 10 years"
                ],
                "correct_index": 1,
                "explanation": "2008 was unprecedented. COVID was unprecedented. Every major financial disruption is, almost by definition, a surprise. Financial plans that assume the future will look like history are fragile. Plans that assume surprises will happen — without knowing what they''ll be — are robust."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "The investor who spent the last century building a model based on historical data would have missed which major events?",
                "options": [
                    "Minor economic corrections",
                    "World Wars, the Great Depression, a global pandemic, nuclear weapons, the internet, 9/11 — events that restructured the entire world economy",
                    "The rise of index investing",
                    "Central bank interest rate cycles"
                ],
                "correct_index": 1,
                "explanation": "Every generation experiences events that no prior generation experienced. The investor who extrapolated from 1900-1920 data to plan for 1921 missed the Depression. The investor using 1990s data missed 9/11 and 2008. The most important economic events are, nearly always, surprises."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "What is the correct takeaway from the inevitability of surprises?",
                "options": [
                    "Don''t invest — the risk is too high",
                    "Only invest in inflation-protected assets",
                    "Build portfolios and financial plans that can survive a wide range of outcomes — not just the expected one",
                    "Rely on professional forecasters who can anticipate surprises"
                ],
                "correct_index": 2,
                "explanation": "You cannot predict the specific surprise. But you can build a plan robust enough to survive many kinds of surprises: hold cash for emergencies, avoid dangerous leverage, diversify broadly. The goal is not to predict the storm — it''s to build a ship that can weather many kinds of storms."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 3  ▸  Lesson 3: Room for Error
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c3030000-0000-0000-0000-000000000001',
    'be300000-0000-0000-0000-000000000003',
    'quiz',
    '{
        "instructions": "Test your understanding of Room for Error.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "What does Housel mean by ''room for error'' in financial planning?",
                "options": [
                    "Having a plan B for every investment decision",
                    "Deliberately building in extra savings, lower leverage, and slack so that when things go wrong — which they will — you are not wiped out",
                    "Keeping detailed records so you can learn from mistakes",
                    "Hiring a financial advisor to catch your errors"
                ],
                "correct_index": 1,
                "explanation": "Room for error is the deliberate acceptance of a ''haircut'' in expected returns in exchange for dramatically improved resilience. You hold more cash than you need, take on less debt than you could, and plan for outcomes worse than you expect — so that surprises don''t destroy you."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "Housel argues that the most dangerous investors are those who are supremely confident in their forecasts. Why?",
                "options": [
                    "Confidence leads to overtrading",
                    "They leave no room for error — if they are certain a stock will rise 20%, they borrow to amplify it. When wrong, the consequences are catastrophic",
                    "Confident people ignore advice from professionals",
                    "Overconfidence is correlated with below-average returns"
                ],
                "correct_index": 1,
                "explanation": "The margin of safety principle: if your strategy only works if your prediction is exactly right, you are one surprise away from disaster. Building in a buffer — assuming your forecast might be wrong by 20%, 30%, or more — transforms survivable errors into catastrophes avoided."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "''Room for error'' can seem wasteful — holding extra cash, avoiding maximum leverage, accepting lower returns. Housel''s best argument for it is:",
                "options": [
                    "It improves your credit score over time",
                    "Most people overestimate their risk tolerance until tested by a real crisis",
                    "Ruin is permanent — any strategy with a non-trivial chance of complete loss is irrational, no matter the expected return",
                    "Conservative strategies outperform over 20-year periods"
                ],
                "correct_index": 2,
                "explanation": "Expected value calculations can justify enormous risks. But expected value implicitly assumes you will be around to keep playing. Ruin ends the game permanently. A strategy with a 1% chance of total loss is not ''99% safe'' — it''s one that will probably destroy you eventually if repeated. Avoiding ruin is paramount."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 3  ▸  Lesson 4: You'll Change
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c3040000-0000-0000-0000-000000000001',
    'be300000-0000-0000-0000-000000000004',
    'quiz',
    '{
        "instructions": "Test your understanding of how your goals change over time.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel describes a psychological finding called ''the end of history illusion.'' What is it?",
                "options": [
                    "People underestimate how much the economy has changed in the past",
                    "People readily acknowledge how much they have changed in the past, but believe they will remain largely the same in the future — even though this is almost never true",
                    "Investors focus too much on recent market events",
                    "Young people believe financial history is irrelevant to modern markets"
                ],
                "correct_index": 1,
                "explanation": "Dan Gilbert''s research showed that people at 18, 30, 50 all acknowledge massive change over the prior decade but all believe their future selves will be stable. They dramatically underestimate future change. The 22-year-old who locks in a 40-year financial plan based on today''s values is planning for a person they will no longer be."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "A 25-year-old commits to a plan of maximum savings and minimal spending for 30 years to retire early. Housel would warn:",
                "options": [
                    "This is the optimal strategy and should be pursued",
                    "The math works, but the person who wakes up at 50 may have completely different values, relationships, and goals — the sacrifice may have been for a life they no longer want",
                    "Retirement planning should not start before 35",
                    "Early retirement strategies always fail due to market timing"
                ],
                "correct_index": 1,
                "explanation": "Locking in massive sacrifices based on current preferences is risky when people change so dramatically. Many people who pursue extreme early retirement find they want to work, just differently. The key is building flexibility — a plan that still works if your goals shift."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "How should the ''you''ll change'' insight affect the way you structure financial plans?",
                "options": [
                    "Make 5-year plans only and never look further ahead",
                    "Maximize optionality — avoid locking yourself into irreversible decisions, build in flexibility so your future self can change course",
                    "Invest only in liquid assets",
                    "Get professional advice annually so plans can be updated"
                ],
                "correct_index": 1,
                "explanation": "The antidote to not knowing how you''ll change is building maximum optionality into your finances. Avoiding extreme decisions at either end — starving yourself today for an imagined future, or spending everything today with no thought for tomorrow — leaves the most room for the person you will become."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PATH 3  ▸  Lesson 5: Nothing's Free
-- ---------------------------------------------------------------------------
INSERT INTO lesson_content (id, lesson_id, content_type, content)
VALUES (
    'c3050000-0000-0000-0000-000000000001',
    'be300000-0000-0000-0000-000000000005',
    'quiz',
    '{
        "instructions": "Test your understanding of the price of investing.",
        "pass_score_pct": 70,
        "questions": [
            {
                "id": "q1",
                "type": "multiple_choice",
                "question": "Housel''s key insight in this chapter is that market returns are not free. What is the ''price'' of long-term equity returns?",
                "options": [
                    "Brokerage commissions and fund fees",
                    "Volatility, uncertainty, doubt, and the psychological discomfort of watching your portfolio fall — sometimes dramatically",
                    "The time spent researching investments",
                    "Inflation eroding nominal returns"
                ],
                "correct_index": 1,
                "explanation": "The stock market returned 11.5% annually for decades. But the ''price'' of that return was being willing to watch your portfolio fall 30%, 40%, even 50% periodically — and not selling. Investors who demand the return without paying the price (by selling during crashes) end up with neither."
            },
            {
                "id": "q2",
                "type": "multiple_choice",
                "question": "Housel compares stock market volatility to an amusement park admission fee. What is the point of this analogy?",
                "options": [
                    "Investing should be fun and exciting",
                    "The market should be avoided unless you enjoy risk",
                    "Volatility is the admission price for long-term returns. Investors who refuse to pay it — by selling during crashes — are like trying to sneak into the park. They usually get caught (miss the recovery)",
                    "Lower volatility investments are always better value"
                ],
                "correct_index": 2,
                "explanation": "You don''t resent Disneyland''s admission fee — you accept it as the cost of the experience. Similarly, viewing volatility as a fee rather than a fine changes how you respond to crashes. It''s the cost of a ticket, not a penalty. Accepting this makes it psychologically easier to hold."
            },
            {
                "id": "q3",
                "type": "multiple_choice",
                "question": "An investor switches to bonds after every 10% stock market drop to ''avoid the volatility.'' According to Housel, what mistake are they making?",
                "options": [
                    "Bonds are also volatile in rising rate environments",
                    "They are trying to get the returns without paying the price — by evading the volatility that generates those returns, they''ll likely miss the recovery and earn less in the long run",
                    "This is a rational strategy and Housel would approve of it",
                    "Transaction costs make this approach inefficient"
                ],
                "correct_index": 1,
                "explanation": "Trying to avoid volatility while capturing equity returns is like trying to sneak into the theme park. You might avoid the admission fee sometimes, but you''ll often be caught — missing the recovery bounce that accounts for a huge portion of long-term returns. The price is real. Pay it willingly or don''t enter."
            }
        ]
    }'::jsonb
) ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Update book total_lessons count (denormalized field)
-- ---------------------------------------------------------------------------
UPDATE books
SET total_lessons = (
    SELECT COUNT(*) FROM lessons
    WHERE book_id = 'b1000000-0000-0000-0000-000000000001'
      AND is_published = true
)
WHERE id = 'b1000000-0000-0000-0000-000000000001';
