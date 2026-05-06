

𝗤1. 𝗛𝗼𝘄 𝗺𝗮𝗻𝘆 𝘂𝗻𝗶𝗾𝘂𝗲 𝗽𝗼𝘀𝘁 𝘁𝘆𝗽𝗲𝘀 𝗮𝗿𝗲 𝗳𝗼𝘂𝗻𝗱 𝗶𝗻 𝗳𝗮𝗰𝘁_𝗰𝗼𝗻𝘁𝗲𝗻𝘁?
SELECT COUNT(DISTINCT post_type) AS unique_post_types
FROM fact_content;

𝗤2. 𝗪𝗵𝗮𝘁 𝗮𝗿𝗲 𝘁𝗵𝗲 𝗵𝗶𝗴𝗵𝗲𝘀𝘁 𝗮𝗻𝗱 𝗹𝗼𝘄𝗲𝘀𝘁 𝗿𝗲𝗰𝗼𝗿𝗱𝗲𝗱 𝗶𝗺𝗽𝗿𝗲𝘀𝘀𝗶𝗼𝗻𝘀 𝗳𝗼𝗿 𝗲𝗮𝗰𝗵 𝗽𝗼𝘀𝘁 𝘁𝘆𝗽𝗲?

SELECT 
    post_type,
    MAX(impressions) AS highest_impressions,
    MIN(impressions) AS lowest_impressions
FROM fact_content
GROUP BY post_type;

𝗤3. 𝗙𝗶𝗹𝘁𝗲𝗿 𝗮𝗹𝗹 𝗽𝗼𝘀𝘁𝘀 𝗽𝘂𝗯𝗹𝗶𝘀𝗵𝗲𝗱 𝗼𝗻 𝘄𝗲𝗲𝗸𝗲𝗻𝗱𝘀 𝗶𝗻 𝗠𝗮𝗿𝗰𝗵 & 𝗔𝗽𝗿𝗶𝗹 𝗮𝗻𝗱 𝗲𝘅𝗽𝗼𝗿𝘁 𝘁𝗼 𝗖𝗦𝗩

SELECT fc.*
FROM fact_content fc
JOIN dim_dates dd 
ON fc.date = dd.date
WHERE dd.weekday_or_weekend = 'Weekend'
AND dd.month_name IN ('March','April');

𝗤4. 𝗠𝗼𝗻𝘁𝗵𝗹𝘆 𝗔𝗰𝗰𝗼𝘂𝗻𝘁 𝗦𝘁𝗮𝘁𝗶𝘀𝘁𝗶𝗰𝘀

SELECT 
    dd.month_name,
    SUM(fa.profile_visits) AS total_profile_visits,
    SUM(fa.new_followers) AS total_new_followers
FROM fact_account fa
JOIN dim_dates dd 
ON fa.date = dd.date
GROUP BY dd.month_name;

𝗤5. 𝗖𝗧𝗘 – 𝗟𝗶𝗸𝗲𝘀 𝗶𝗻 𝗝𝘂𝗹𝘆

WITH july_likes AS (
    SELECT 
        post_category,
        SUM(likes) AS total_likes
    FROM fact_content fc
    JOIN dim_dates dd 
    ON fc.date = dd.date
    WHERE dd.month_name = 'July'
    GROUP BY post_category
)
SELECT *
FROM july_likes
ORDER BY total_likes DESC;

𝗤6. 𝗨𝗻𝗶𝗾𝘂𝗲 𝗽𝗼𝘀𝘁 𝗰𝗮𝘁𝗲𝗴𝗼𝗿𝗶𝗲𝘀 𝗽𝗲𝗿 𝗺𝗼𝗻𝘁𝗵
SELECT 
    dd.month_name,
    GROUP_CONCAT(DISTINCT fc.post_category ORDER BY fc.post_category) AS post_category_names,
    COUNT(DISTINCT fc.post_category) AS post_category_count
FROM fact_content fc
JOIN dim_dates dd 
ON fc.date = dd.date
GROUP BY dd.month_name;

𝗤7. 𝗣𝗲𝗿𝗰𝗲𝗻𝘁𝗮𝗴𝗲 𝗼𝗳 𝘁𝗼𝘁𝗮𝗹 𝗿𝗲𝗮𝗰𝗵 𝗯𝘆 𝗽𝗼𝘀𝘁 𝘁𝘆𝗽𝗲

SELECT 
    post_type,
    SUM(reach) AS total_reach,
    ROUND(SUM(reach) * 100 / SUM(SUM(reach)) OVER (),2) AS reach_percentage
FROM fact_content
GROUP BY post_type;

𝗤8. 𝗤𝘂𝗮𝗿𝘁𝗲𝗿-𝘄𝗶𝘀𝗲 𝗰𝗼𝗺𝗺𝗲𝗻𝘁𝘀 & 𝘀𝗮𝘃𝗲𝘀
SELECT 
    fc.post_category,
    CASE 
        WHEN dd.month_name IN ('January','February','March') THEN 'Q1'
        WHEN dd.month_name IN ('April','May','June') THEN 'Q2'
        WHEN dd.month_name IN ('July','August','September') THEN 'Q3'
    END AS quarter,
    SUM(fc.comments) AS total_comments,
    SUM(fc.saves) AS total_saves
FROM fact_content fc
JOIN dim_dates dd 
ON fc.date = dd.date
GROUP BY fc.post_category, quarter;

𝗤9. 𝗧𝗼𝗽 𝟯 𝗱𝗮𝘁𝗲𝘀 𝗽𝗲𝗿 𝗺𝗼𝗻𝘁𝗵 (𝗳𝗼𝗹𝗹𝗼𝘄𝗲𝗿𝘀)

WITH ranked_data AS (
    SELECT 
        dd.month_name AS month,
        fa.date,
        fa.new_followers,
        ROW_NUMBER() OVER (PARTITION BY dd.month_name ORDER BY fa.new_followers DESC) AS rn
    FROM fact_account fa
    JOIN dim_dates dd 
    ON fa.date = dd.date
)
SELECT *
FROM ranked_data
WHERE rn <= 3;

𝗤10. 𝗦𝘁𝗼𝗿𝗲𝗱 𝗣𝗿𝗼𝗰𝗲𝗱𝘂𝗿𝗲

DELIMITER $$

CREATE PROCEDURE get_total_shares_by_week(IN week_input INT)
BEGIN
    SELECT 
        fc.post_type,
        SUM(fc.shares) AS total_shares
    FROM fact_content fc
    JOIN dim_dates dd 
    ON fc.date = dd.date
    WHERE dd.week_no = week_input
    GROUP BY fc.post_type;
END $$

DELIMITER ;
