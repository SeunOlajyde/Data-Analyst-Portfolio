-- ANALYZING KICKSTARTER PROJECT FOR A STARTUP
-- In this project, I am exploring the possibility of launching a Kickstarter campaign. 
-- My mission is to analyze relevant data and uncover insights that will guide the product team in understanding the key factors contributing to a successful campaign. 
-- The product team want to know the market potential of some new products and I have been tasked with analyzing relevant data to identify factors that could contribute to a successful campaign.

-- As a result, I will answer 2 questions with the analysis below:
-- 1. What types of projects are most likely to be successful?
-- 2. Which projects fail?

-- The database consists of one table, ksprojects
-- The definitions of the columns in this data are listed below:
  -- ID: Kickstarter project ID
  -- name: Name of project
  -- category: Category of project
  -- main_category: Main category of project
  -- goal: Fundraising goal
  -- pledged: Amount pledged
  -- state: State of project (successful, canceled, etc.)
  -- backers: Number of project backers

-- Tool used: SQLite
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- RETRIEVING COLUMN DATA TYPES
-- Here I want to understand the data type and name of each column on the table

PRAGMA table_info(ksprojects); 

-- ASSESSMENT OF PROJECT RESULTS
-- To do this, I queried the table to pull the following columns: main_category, goal, backers, and pledged.

SELECT main_category, goal, backers, pledged 
FROM ksprojects
LIMIT 10;

-- COMMENT: The above query showed the main category, amount of money set as a goal, number of backers, and amount of money pledged.

-- STATE OF THE CAMPAIGN PROJECT
-- My goal here is to understand the project state is either 'failed', 'canceled', or 'suspended'.

SELECT main_category, goal, backers, pledged, state 
FROM ksprojects
WHERE state IN ('failed', 'canceled', 'suspended')
LIMIT 10;

-- COMMENT: The results revealed film & video projects struggled the most, while low backer engagement and funding levels characterized unsuccessful campaigns.

-- Expanding the above result, I wanted to know projects with at least 100 backers and at least $20,000 pledged.

SELECT main_category, goal, backers, pledged, state
FROM ksprojects
WHERE state IN ('failed', 'canceled', 'suspended') 
    AND backers >= 100 AND pledged >= 20000
LIMIT 10;

-- COMMENT: The analysis reveals that technology and film/video projects on Kickstarter face challenges, often failing or being canceled. These projects typically have low backer engagement and struggle to reach funding goals. This suggests that factors beyond just the number of backers and funds raised, such as effective marketing and realistic goal setting, are crucial for campaign success on the platform.

-- PERCENTAGE OF GOAL FUNDED

SELECT main_category, backers, pledged, goal, state, pledged/goal AS pct_pledged
FROM ksprojects
WHERE state ='failed' AND backers >= 100 AND pledged >= 20000
ORDER BY main_category ASC, pct_pledged DESC
LIMIT 10

-- COMMENT: The query results highlight 10 failed art projects on Kickstarter, despite having at least 100 backers and raising $20,000 or more. These projects were close to their funding goals, indicating that failure was due to factors beyond financial support (pledged funds), such as time constraints, marketing challenges, or unexpected expenses.

-- DETERMINING THE FUNDING STATUS

SELECT main_category, backers, pledged, goal, pledged / goal AS pct_pledged,
  CASE
    WHEN pledged/goal >= 1 THEN 'Fully funded'
    WHEN pledged/goal BETWEEN .75 AND 1 THEN 'Nearly funded'
    ELSE 'Not nearly funded'
  END AS funding_status
FROM ksprojects
WHERE state IN ('failed') AND backers >= 100 AND pledged >= 20000
ORDER BY main_category, pct_pledged DESC
LIMIT 10;

-- COMMENTS: Looking at the 10 failed art projects in this campaign, revealed that despite significant backing and pledges, couldn't reach their funding goals. These projects were mostly "nearly funded," suggesting failure was due to factors beyond financial support.


-- RECOMMENDATION:
-- Research and understand your target audience to effectively tailor your marketing message and build a community of engaged backers through various platforms and collaborations with influencers.

-- Set an ambitious yet achievable funding goal based on thorough research, detailed budgeting, and realistic projections, considering potential challenges and risks.

-- Craft a compelling project narrative with clear language, high-quality visuals, and engaging video pitches to effectively communicate the problem, solution, and impact. Offer attractive tiered rewards to incentivize various levels of backing.

-- Maintain transparent communication by sharing regular updates on progress, challenges, and milestones, addressing backer questions promptly, and fostering a positive relationship with your community.

-- Explore alternative crowdfunding platforms or funding options like grants and angel investors. Develop a comprehensive business plan for long-term sustainability, including securing distribution channels and establishing partnerships.










