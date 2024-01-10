--Points Tally

SELECT _2223.Round, _2223.Points AS _2223, _2324.Points AS _2324
FROM (
SELECT Round, SUM(PTS) OVER (ORDER BY Round) as Points
FROM (
SELECT TOP 20 *, 
	CASE 
		WHEN GF > GA THEN 3 
		WHEN GF < GA THEN 0
		WHEN GF = GA THEN 1
	END AS PTS
FROM fixtures_22_23
) AS FIRST_20
) AS _2223
JOIN (
SELECT Round, SUM(PTS) OVER (ORDER BY Round) as Points
FROM (
SELECT TOP 20 *, 
	CASE 
		WHEN GF > GA THEN 3 
		WHEN GF < GA THEN 0
		WHEN GF = GA THEN 1
	END AS PTS
FROM fixtures_23_24
) AS FIRST_20
) AS _2324
ON _2223.Round = _2324.Round

--Attack:

--Goal Scoring Efficiency:

--What is the average number of goals scored per game last season and this season?

SELECT Season, 
	Matches, 
	Goals, 
	ROUND(CAST(Goals AS FLOAT)/CAST(Matches AS FLOAT), 2) as 'Goals/Game', 
	Shots, SOT, 
	ROUND(CAST(Shots_Outside_box AS FLOAT)/CAST(Matches AS FLOAT), 2) as 'Shots__OB/Game',
	ROUND(CAST(Shots_Inside_box AS FLOAT)/CAST(Matches AS FLOAT), 2) as 'Shots__IB/Game'
FROM General_data;

--Arsenal's 1.85 Goals/game this season represents a decrease from their rate of 2.32 last season


--How does the total number of goals scored compare between the two seasons?

--At this same stage last season

SELECT '2022/23' as Season, COUNT(*) AS After_20_Games, SUM(GF) AS Goals, ROUND(CAST(SUM(GF) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'Goals/Game'
FROM (
SELECT TOP 20 *
FROM fixtures_22_23
) AS FIRST_20
UNION
SELECT '2023/24' as Season, COUNT(*) AS After_20_Games, SUM(GF) AS Goals, ROUND(CAST(sum(GF) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'Goals/Game'
FROM (
SELECT TOP 20 *
FROM fixtures_23_24
) AS FIRST_20;

--Arsenal's 1.85 Goals/game this season represents a decrease from their rate of 2.25 at this stage last season

--Rate Last season vs This season

SELECT '2022/23' as Season, COUNT(*) AS Games, SUM(GF) AS Goals, ROUND(CAST(SUM(GF) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'Goals/Game'
FROM (
SELECT *
FROM fixtures_22_23
) AS MATCHES
UNION
SELECT '2023/24' as Season, COUNT(*) AS Games, SUM(GF) AS Goals, ROUND(CAST(sum(GF) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'Goals/Game'
FROM (
SELECT *
FROM fixtures_23_24
WHERE GF IS NOT NULL
) AS FIRST_20;

--IN THE LEAGUE: Arsenal's Attack Rank Last season vs This Season

SELECT '22/23' AS Season, 
	ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/38, 2) AS 'G/GAME', 
	ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT))/38, 2) AS 'XG/GAME',
	ROUND(ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/38, 2) - (ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT))/38, 2)), 2) AS XG_OVERPERFORMANCE
FROM (
SELECT Home, SUM(Home_Goals) AS Goals_h, SUM(xG_h) AS xG_h
FROM PL_Fixtures_22_23
WHERE Home LIKE 'Arsenal'
GROUP BY Home
) AS HM
JOIN (
SELECT Away, SUM(Away_Goals) AS Goals_a, SUM(xG_a) AS xG_a
FROM PL_Fixtures_22_23
WHERE Away LIKE 'Arsenal'
GROUP BY Away
) AS AW ON HM.Home = AW.Away
UNION
SELECT '23/24' AS Season, 
	ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/20, 2) AS 'G/GAME',
	ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT))/20, 2) AS 'XG/GAME',
	ROUND(ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/20, 2) - (ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT))/20, 2)), 2) AS XG_OVERPERFORMANCE
FROM (
SELECT Home, SUM(Home_Goals) AS Goals_h, SUM(xG_h) AS xG_h
FROM PL_Fixtures_23_24
WHERE Home LIKE 'Arsenal'
GROUP BY Home
) AS HM
JOIN (
SELECT Away, SUM(Away_Goals) AS Goals_a, SUM(xG_a) AS xG_a
FROM PL_Fixtures_23_24
WHERE Away LIKE 'Arsenal'
GROUP BY Away
) AS AW ON HM.Home = AW.Away;

--Arsenal have gone down in Goals per game, xGoals per game and substantially in the rate at which they overperform their XG

--Compared to the rest of the league

SELECT COUNT(*) OVER (ORDER BY ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT))/(HM.Games + AW.Games), 2) DESC) AS Rank, Home, 
	ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'G/GAME', 
	ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'XG/GAME',
	ROUND(((Goals_h + Goals_a) - (xG_h + xG_a)), 2) AS XG_OVERPERFORMANCE 
FROM (
SELECT Home, COUNT(Home) as Games, SUM(Home_Goals) AS Goals_h, SUM(xG_h) AS xG_h
FROM PL_Fixtures_22_23
GROUP BY Home
) AS HM
JOIN (
SELECT Away, COUNT(Away) as Games, SUM(Away_Goals) AS Goals_a, SUM(xG_a) AS xG_a
FROM PL_Fixtures_22_23
GROUP BY Away
) AS AW ON HM.Home = AW.Away
ORDER BY [XG/GAME] DESC;

--Last season
--Arsenal's 2.32 Goals per game ranked 2nd last season, HOWEVER their XG/Game of 1.89 ranks 5th. They also recorded the highest xG overperformance in the league with an
--overperformance of +0.43 (+22.75%). League Champions Man City ranked 1st for goals per game - 2.47 and XG per game - 2.07. Their XG 
--Overperformance - 0.4 (19.32) was only second to arsenal.

SELECT COUNT(*) OVER (ORDER BY  ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT)) / (HM.Games + AW.Games), 2) DESC) AS Rank, Home, 
	ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT)) / (HM.Games + AW.Games), 2)  AS 'G/GAME',
    ROUND((CAST(xG_h AS FLOAT) + CAST(xG_a AS FLOAT)) / (HM.Games + AW.Games), 2) AS 'XG/GAME',
    ROUND(((Goals_h + Goals_a) - (xG_h + xG_a)), 2) AS XG_OVERPERFORMANCE 
FROM (
SELECT Home, COUNT(Home) as Games, SUM(Home_Goals) AS Goals_h, SUM(xG_h) AS xG_h
FROM PL_Fixtures_23_24
GROUP BY Home
) AS HM
JOIN (
SELECT Away,  COUNT(Home) as Games, SUM(Away_Goals) AS Goals_a, SUM(xG_a) AS xG_a
FROM PL_Fixtures_23_24
GROUP BY Away
) AS AW ON HM.Home = AW.Away
ORDER BY [XG/GAME] desc;

--This season
--Arsenal'S 1.85 Goals per game rank 7th so far this season, BUT their XG per game - 1.82 ranks 5th. This season, they are overperforming by 0.03 which ranks 11th in the league.
--Last seasons champions mancity rank 1st for G/Game - 2.37. They rank 4th for XG/Game with 2.37 and their 0.43 overperformance ranks first. League leaders Liverpool rank
--second for G/Game with 2.15, First for XG/Game  - 2.21 and 14TH for xG overperformance with -0.06

--Biggest Scoring Rate difference among premier league clubs

SELECT LS.Home, G_GAME_24, G_GAME_23,
	(G_GAME_24 - G_GAME_23) AS G_DIFF, 
	ROUND((((G_GAME_24 - G_GAME_23)/G_GAME_23)*100), 2) AS G_DIFF_PERC,
	ROUND((XG_GAME_24 - XG_GAME_23), 2) AS XG_DIFF,
	ROUND((((XG_GAME_24 - XG_GAME_23)/XG_GAME_23)*100), 2) AS XG_DIFF_PERC
FROM (
	SELECT Home, 
		ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/38, 2) AS 'G_GAME_23',
		ROUND((CAST(XG_h AS FLOAT) + CAST(XG_a AS FLOAT))/38, 2) AS 'XG_GAME_23'
	FROM (
		SELECT Home, SUM(Home_Goals) AS Goals_h, SUM(xG_h) AS XG_h
		FROM PL_Fixtures_22_23
		GROUP BY Home
		) AS HM
JOIN (
	SELECT Away, SUM(Away_Goals) AS Goals_a, SUM(xG_a) AS XG_A
	FROM PL_Fixtures_22_23
	GROUP BY Away
	) AS AW ON HM.Home = AW.Away
) AS LS
JOIN (
	SELECT Home,
		ROUND((CAST(Goals_h AS FLOAT) + CAST(Goals_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'G_GAME_24',
		ROUND((CAST(XG_h AS FLOAT) + CAST(XG_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'XG_GAME_24'
	FROM (
		SELECT Home, COUNT(Home) as Games, SUM(Home_Goals) AS Goals_h, SUM(xG_h) AS XG_h
		FROM PL_Fixtures_23_24
		GROUP BY Home
	) AS HM
JOIN (
	SELECT Away, COUNT(Away) as Games, SUM(Away_Goals) AS Goals_a, SUM(xG_a) AS XG_A
	FROM PL_Fixtures_23_24
	GROUP BY Away
	) AS AW ON HM.Home = AW.Away
) AS TS ON LS.Home = TS.Home
ORDER BY G_DIFF_PERC DESC;

--Arsenal's -20.26% drop in goals per game is the SECOND worst DROP OFF in the league. Their XG DROP OFF of -3.7% is 4th WORST in the league.
--Mancity'S -8.91% drop in goals per game is the 4th worst in the league. Their -6.28% drop off in XG is also the 3rd worst in the league.
--Liverpool +9.14 Increase in goals per game is the 9th best in the league. Their +15.71 XG increase is the 8th best in the league,


--Shooting Accuracy:

--What is the team's shot accuracy percentage for both seasons?

SELECT Season, ROUND(Shots, 2) AS Shots, ROUND(SOT, 2) AS SOT, 
	ROUND((SOT/Shots)*100, 2) as Percentage_OF_Shots_OT, 
	ROUND((CAST(Shots_Inside_Box AS FLOAT)/Matches), 2) as Shots_Inside_Box,
	ROUND((CAST(Shots_Outside_box AS FLOAT)/Matches), 2) as Shots_Outside_Box, Conversion
FROM General_data;

--This season, Arsenal's shots, SOT, shots inside the box and shots outside the box have increased. However, the % of their shots that land on target has reduced, along with
--their conversation rate.

--Are there specific players who have improved or declined in their shooting accuracy?

SELECT DISTINCT sh_2223.Player, ROUND(sh_2223.Sh_90, 2) AS SH_23, ROUND(sh_2224.Sh_90, 2) AS SH_24, ROUND(sh_2223.SoT_90, 2) as SOT_23, ROUND(sh_2224.SoT_90, 2) as SOT_24,
	ROUND((CAST(sh_2223.SoT AS FLOAT)/CAST(sh_2223.Sh AS FLOAT))*100, 2)  as 'Shot_Accuracy_Percentage_22/23',
	ROUND((CAST(sh_2224.SoT AS FLOAT)/CAST(sh_2224.Sh AS FLOAT))*100, 2)  as 'Shot_Accuracy_Percentage_23/24',
	ROUND((CAST(sh_2224.SoT AS FLOAT)/CAST(sh_2224.Sh AS FLOAT))*100, 2) - ROUND((CAST(sh_2223.SoT AS FLOAT)/CAST(sh_2223.Sh AS FLOAT))*100, 2)  as 'Shot_Accuracy_Percentage_Diff',
	ROUND((sh_2224.Dist - sh_2223.Dist), 2) as Shot_Dist
FROM Shooting_data_22_23 sh_2223
JOIN Shooting_data_23_24 sh_2224 ON sh_2224.Player = sh_2223.Player
WHERE sh_2223.SoT > 0 AND sh_2224.G_SoT > 0 AND sh_2223.Pos in ('MF', 'FW', 'MF/FW')
ORDER BY Shot_Accuracy_Percentage_Diff;

--Players with at least one shot on target in both seasons.
--Only Trossard and Saka have seen an increase in the amount of shots they take and the amount of shots OT.
--Martinelli and Nketiah are the only ones who have seen their shot accuracy fall.


--Assist and Buildup:

--How many BIG CHANCES did Arsenal record per game in each season?

SELECT Season, ROUND(Big_chances_per_game, 2) AS 'Big_Chances_Created/Game'
FROM General_data;

--Arsenal's Big Chance creation numbers have increased marginally.


--Is there a notable difference in the buildup play leading to goals?

--Progresive Actions (Carries/Passes) Per Game
SELECT '2022/23' as Season, ROUND((SUM(CAST(PrgC AS FLOAT)) + SUM(CAST(PrgP AS FLOAT)))/38, 2) AS 'Progressive_Actions/Game'
FROM Standard_data_22_23
UNION
SELECT '2023/24' as Season, ROUND((SUM(CAST(PrgC AS FLOAT)) + SUM(CAST(PrgP AS FLOAT)))/20, 2) AS 'Progressive_Actions/Game'
FROM Standard_data_23_24;

--Arsenal average more progressive actions this season than they did last season.

--Key Players:

--Who were the top goal scorers and assist providers in each season?

--TOP 6 HIGHEST GOAL SCORERS LAST SEASON VS THIS SEASON

SELECT TOP 6 [Player],
	ROUND([XG/90-24]-[XG/90-23], 2) AS 'XG/90_DIFF',
	ROUND([G/90-24]-[G/90-23], 2) AS 'G/90_DIFF',
	ROUND([GA/90-24]-[GA/90-23], 2) AS 'GA/90_DIFF',
	ROUND(((([XG/90-24] - [XG/90-23])/[XG/90-23])*100), 2) AS 'XG/90_DIFF_PERC', 
	ROUND(((([G/90-24] - [G/90-23])/[G/90-23])*100), 2) AS 'G/90_DIFF_PERC', 
	ROUND(((([GA/90-24] - [GA/90-23])/[GA/90-23])*100), 2) AS 'GA/90_DIFF_PERC'
FROM (
SELECT S23.Player, 
S23.Gls AS 'Goals-23', 
S24.Gls AS 'Goals-24', 
S23.G_A AS 'GA-23', 
S24.G_A AS 'GA-24', 
ROUND(CAST(S23.xG AS FLOAT)/CAST(S23._90s AS FLOAT), 2) AS 'XG/90-23', 
ROUND(CAST(S24.xG AS FLOAT)/CAST(S24._90s AS FLOAT), 2) AS 'XG/90-24', 
ROUND(CAST(S23.Gls AS FLOAT)/CAST(S23._90s AS FLOAT), 2) AS 'G/90-23', 
ROUND(CAST(S24.Gls AS FLOAT)/CAST(S24._90s AS FLOAT), 2) AS 'G/90-24',
ROUND(CAST(S23.G_A AS FLOAT)/CAST(S23._90s AS FLOAT), 2) AS 'GA/90-23', 
ROUND(CAST(S24.G_A AS FLOAT)/CAST(S24._90s AS FLOAT), 2) AS 'GA/90-24'
FROM Standard_data_22_23 S23
JOIN Standard_data_23_24 S24 ON S23.Player = S24.Player
WHERE S23.xG > 0
UNION
SELECT S23.Player, 
S23.Gls AS 'Goals-23', 
S24.Gls AS 'Goals-24', 
S23.G_A AS 'GA-23', 
S24.G_A AS 'GA-24', 
ROUND(CAST(S23.xG AS FLOAT)/CAST(S23._90s AS FLOAT), 2) AS 'XG-23', 
ROUND(CAST(S24.xG AS FLOAT)/CAST(S24._90s AS FLOAT), 2) AS 'XG-24', 
ROUND(CAST(S23.Gls AS FLOAT)/CAST(S23._90s AS FLOAT), 2) AS 'G/90-23', 
ROUND(CAST(S24.Gls AS FLOAT)/CAST(S24._90s AS FLOAT), 2) AS 'G/90-24',
ROUND(CAST(S23.G_A AS FLOAT)/CAST(S23._90s AS FLOAT), 2) AS 'GA/90-23', 
ROUND(CAST(S24.G_A AS FLOAT)/CAST(S24._90s AS FLOAT), 2) AS 'GA/90-24'
FROM Standard_data_22_23 S23
JOIN Standard_data_23_24 S24 ON  S23.Player = 'Granit Xhaka' AND S24.Player = 'Kai Havertz'
WHERE S23.xG > 0
) AS IDK
ORDER BY [Goals-23] DESC;

--Among last season's top 6 goal scorers:
--Martinelli(-43.33%), Odegaard(-20.69%), Jesus (-24.59%) and Nketiah (-44.12) have recorded a significant drop in XG/90.
--As a result, some of them have seen significant drops in their G/90. Martinelli (-70.83%), Odegaard (-44.19), Jesus (-39.58%).
--Nketiah has seen an increase in his G/90. A 39.39% increase.
--Saka (+18.75) and Havertz (+128.57) who represents the Xhaka replacement have both seen significant increase in their xg/90.
--Saka has however seen a -17.5 drop in his g/90 while Havertz has bettered Xhaka's G/90 by 47.62%
--All of them have recorded significant drops in their GA/90. All except Nketiah. 36.59% increase.


--Have there been changes in the key contributors to the team's attack?

--Compare Xhaka AND Havertz

SELECT S23.Player, 
	ROUND(((Gls-PK)/S23._90s), 2) as NPG_90, 
	ROUND((S23.Ast/S23._90s), 2) as Ast_90,
	ROUND((npxG/S23._90s), 2) as NPXG_90,
	ROUND((S23.xAG/S23._90s), 2) as xAst_90,
	ROUND(((S23.PrgC + S23.PrgP)/S23._90s), 2) as prgA_90,
	ROUND((P23.Touches/S23._90s), 2) as Tch_90,
	ROUND((P23.PrgDist/S23._90s), 2) as pDist_90,
	ROUND((P23._1_3/S23._90s), 2) as prG1_3_90,
	ROUND((P23.PrgDist/S23._90s), 2) as pDistC_90,
	ROUND((P23.Rec/S23._90s), 2) as pRec_90,
	ROUND((P23.PrgR/S23._90s), 2) as ppRec_90,
	ROUND((Cmp2/S23._90s), 2) as Comp_Sh,
	ROUND((Att2/S23._90s), 2) as Att_Sh,
	ROUND((Cmp3/S23._90s), 2) as Comp_Md,
	ROUND((Att3/S23._90s), 2) as Att_Md,
	ROUND((Cmp4/S23._90s), 2) as Comp_Lg,
	ROUND((Att4/S23._90s), 2) as Att_Lg,
	ROUND((PPA/S23._90s), 2) as PPA,
	ROUND((Cmp/S23._90s), 2) as Comp,
	ROUND((PS23.Att/S23._90s), 2) as Att
FROM Standard_data_22_23 S23
JOIN Possession_data_22_23 P23 on S23.Player = P23.Player
JOIN Passing_data_22_23 PS23 on S23.Player = PS23.Player
WHERE S23.Player LIKE '%Xhaka'
UNION
SELECT S24.Player, 
	ROUND(((Gls-PK)/S24._90s), 2) as NPG_90, 
	ROUND((S24.Ast/S24._90s), 2) as Ast_90,
	ROUND((npxG/S24._90s), 2) as NPXG_90,
	ROUND((S24.xAG/S24._90s), 2) as xAst_90,
	ROUND(((S24.PrgC + S24.PrgP)/S24._90s), 2) as prgA_90,
	ROUND((P24.Touches/S24._90s), 2) as Tch_90,
	ROUND((P24.PrgDist/S24._90s), 2) as pDist_90,
	ROUND((P24._1_3/S24._90s), 2) as prG1_3_90,
	ROUND((P24.PrgDist/S24._90s), 2) as pDistC_90,
	ROUND((P24.Rec/S24._90s), 2) as pRec_90,
	ROUND((P24.PrgR/S24._90s), 2) as ppRec_90,
	ROUND((Cmp_Short/S24._90s), 2) as Comp_Sh,
	ROUND((Att_Short/S24._90s), 2) as Att_Sh,
	ROUND((Cmp_Medium/S24._90s), 2) as Comp_Md,
	ROUND((Att_Medium/S24._90s), 2) as Att_Md,
	ROUND((Cmp_Long/S24._90s), 2) as Comp_Lg,
	ROUND((Att_Long/S24._90s), 2) as Att_Lg,
	ROUND((PPA/S24._90s), 2) as PPA,
	ROUND((Cmp/S24._90s), 2) as Comp,
	ROUND((PS24.Att/S24._90s), 2) as Att
FROM Standard_data_23_24 S24
JOIN Possession_data_23_24 P24 on S24.Player = P24.Player
JOIN Passing_data_23_24 PS24 on S24.Player = PS24.Player
WHERE S24.Player LIKE 'Kai%';

--Xhaka's numbers remain superior to Havertz in majority of these categories, except non-pen goals/90, non-pen xG/90, carries into the final third and progressive passes received

--Defense:

--Goals Conceded:


--What is the average number of goals conceded per game last season and this season?
SELECT '2022/23' as Season, 
	COUNT(*) AS After_20_Games, 
	SUM(GA) AS GA, 
	ROUND(CAST(SUM(GA) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'GA/Game'
FROM (
SELECT TOP 20 *
FROM fixtures_22_23
) AS FIRST_20
UNION
SELECT '2023/24' as Season, COUNT(*) AS After_20_Games, SUM(GA) AS GA, ROUND(CAST(sum(GA) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'GA/Game'
FROM (
SELECT TOP 20 *
FROM fixtures_23_24
) AS FIRST_20;

--Arsenal are conceding more goals per game this season. They are conceding 1 per game, which is more than the 0.85 they were conceding per game at this stage last season

SELECT '2022/23' as Season, COUNT(*) AS Games, SUM(GA) AS GA, ROUND(CAST(SUM(GA) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'GA/Game'
FROM (
SELECT *
FROM fixtures_22_23
) AS ALL_GAMES
UNION
SELECT '2023/24' as Season, COUNT(*) AS Games, SUM(GA) AS GA, ROUND(CAST(sum(GA) AS FLOAT)/CAST(COUNT(*) AS FLOAT), 2) as 'GA/Game'
FROM (
SELECT TOP 20 *
FROM fixtures_23_24
) AS FIRST_20;

--However, the current rate is lower than the 1.13 goals they conceded per game last season.


--Arsenal's Defence compared to the rest of the league

SELECT '22/23' AS Season, 
	ROUND((CAST(GoalsA_h AS FLOAT) + CAST(GoalsA_a AS FLOAT))/38, 2) AS 'GA/GAME', 
	ROUND((CAST(xGA_h AS FLOAT) + CAST(xGA_a AS FLOAT))/38, 2) AS 'XGA/GAME'
FROM (
SELECT Home, SUM(Away_Goals) AS GoalsA_h, SUM(xG_a) AS xGA_h
FROM PL_Fixtures_22_23
WHERE Home LIKE 'Arsenal'
GROUP BY Home
) AS HM
JOIN (
SELECT Away, SUM(Home_Goals) AS GoalsA_a, SUM(xG_h) AS xGA_a
FROM PL_Fixtures_22_23
WHERE Away LIKE 'Arsenal'
GROUP BY Away
) AS AW ON HM.Home = AW.Away
UNION
SELECT '23/24' AS Season, 
	ROUND((CAST(GoalsA_h AS FLOAT) + CAST(GoalsA_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'GA/GAME', 
	ROUND((CAST(xGA_h AS FLOAT) + CAST(xGA_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'XGA/GAME'
FROM (
SELECT Home, COUNT(Home) as Games, SUM(Away_Goals) AS GoalsA_h, SUM(xG_a) AS xGA_h
FROM PL_Fixtures_23_24
WHERE Home LIKE 'Arsenal'
GROUP BY Home
) AS HM
JOIN (
SELECT Away, COUNT(Away) as Games, SUM(Home_Goals) AS GoalsA_a, SUM(xG_h) AS xGA_a
FROM PL_Fixtures_23_24
WHERE Away LIKE 'Arsenal'
GROUP BY Away
) AS AW ON HM.Home = AW.Away;

--Arsenal are conceding at a rate of 1 per game, which is lower than last season. Their XGA per game is also lower than it was last season.

--Compared to the rest of the league

SELECT COUNT(*) OVER (ORDER BY ROUND((CAST(xGA_h AS FLOAT) + CAST(xGA_a AS FLOAT))/38, 2)) AS Rank, Home as Team, 
	ROUND((CAST(GoalsA_h AS FLOAT) + CAST(GoalsA_a AS FLOAT))/38, 2) AS 'GA/GAME', 
	ROUND((CAST(xGA_h AS FLOAT) + CAST(xGA_a AS FLOAT))/38, 2) AS 'XGA/GAME',
	ROUND(((xGA_h + xGA_a) - (GoalsA_h + GoalsA_a)), 2) AS 'xGA-GA'
FROM (
SELECT Home, SUM(Away_Goals) AS GoalsA_h, SUM(xG_a) AS xGA_h
FROM PL_Fixtures_22_23
GROUP BY Home
) AS HM
JOIN (
SELECT Away, SUM(Home_Goals) AS GoalsA_a, SUM(xG_h) AS xGA_a
FROM PL_Fixtures_22_23
GROUP BY Away
) AS AW ON HM.Home = AW.Away
ORDER BY [XGA/GAME];

--Last season, Arsenal's 1.13 goals conceded per game was the 4th best in the league.
--Their 1.11 xPected GA was the third best in the league
--League champions mcity had the best defence and conceded 0.87 per game
--Their 0.85 xPected GA was also the best in the league

SELECT COUNT(*) OVER (ORDER BY ROUND((CAST(xGA_h AS FLOAT) + CAST(xGA_a AS FLOAT))/(HM.Games + AW.Games), 2)) AS Rank, Home as Team, 
	ROUND((CAST(GoalsA_h AS FLOAT) + CAST(GoalsA_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'GA/GAME', 
	ROUND((CAST(xGA_h AS FLOAT) + CAST(xGA_a AS FLOAT))/(HM.Games + AW.Games), 2) AS 'XGA/GAME',
	ROUND(((xGA_h + xGA_a) - (GoalsA_h + GoalsA_a)), 2) AS 'xGA-GA'
FROM (
SELECT Home, COUNT(Home) as Games, SUM(Away_Goals) AS GoalsA_h, SUM(xG_a) AS xGA_h
FROM PL_Fixtures_23_24
GROUP BY Home
) AS HM
JOIN (
SELECT Away, COUNT(Away) as Games, SUM(Home_Goals) AS GoalsA_a, SUM(xG_h) AS xGA_a
FROM PL_Fixtures_23_24
GROUP BY Away
) AS AW ON HM.Home = AW.Away
ORDER BY [XGA/GAME];

--Arsenal's 1 Goal conceded per game is the second bet in the league this season. 
--Their 0.82 XGA/Game is the best in the league
--Man city's 1.11 per game is the third best in the league
--Their 0.93 XGA/Game is the second best in the league
--Liverpool's 0.9 per game is the best in the league
--Their 1.13 XGA/Game is the third best in the league

--Is there a significant improvement or decline in defensive performance?

--Arsenal's defence has gotten better this season. So far, their defence is the best in the league. However, at this same stage last season their defense was conceding less.

--Clean Sheets:


--How many clean sheets did Arsenal keep in each season?

--At this stage last season
SELECT *
FROM (
	SELECT '2022/23' as Season, COUNT(CASE WHEN GA < 1 THEN 1 ELSE NULL END)/10.00 AS CS_After_20_Games, SUM(GA)/10.00 as GA
	FROM (
		SELECT TOP 20 *
		FROM fixtures_22_23
		) AS TB1
	) AS FIRST_20
UNION
SELECT *
FROM (
	SELECT '2023/24' as Season, COUNT(CASE WHEN GA < 1 THEN 1 ELSE NULL END)/10.00 AS CS_After_20_Games, SUM(GA)/10.00 as GA
	FROM (
		SELECT TOP 20 *
		FROM fixtures_23_24
		) AS TB2
	) AS FIRST_20;

--After 20 games last season, Arsenal had kept 9 clean sheets WHILE conceding 17 goals. 
--This season, they have kept 7 clean sheets while conceding 20 goals.

--Goal Keeper stats

--Why have arsenal conceded more despite their numbers suggesting they should have conceded less?
SELECT '22/23' AS Season, 
	ROUND((SUM(CASE WHEN Home LIKE 'Arsenal' THEN Away_Goals END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN Home_Goals END)), 2) as G_A, 
	ROUND((SUM(CASE WHEN Home LIKE 'Arsenal' THEN xG_a END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN xG_h END)), 2) as XG_A,
	ROUND(((SUM(CASE WHEN Home LIKE 'Arsenal' THEN xG_a END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN xG_h END)) - (SUM(CASE WHEN Home LIKE 'Arsenal' THEN Away_Goals END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN Home_Goals END))), 2) AS XGA_PERFORMANCE
FROM (
SELECT TOP 20 *
FROM PL_Fixtures_22_23
WHERE Home LIKE 'Arsenal' OR Away LIKE 'Arsenal'
) AS TBL
UNION
SELECT '23/24' AS Season,
	ROUND((SUM(CASE WHEN Home LIKE 'Arsenal' THEN Away_Goals END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN Home_Goals END)), 2) as G_A, 
	ROUND((SUM(CASE WHEN Home LIKE 'Arsenal' THEN xG_a END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN xG_h END)), 2) as XG_A,
	ROUND(((SUM(CASE WHEN Home LIKE 'Arsenal' THEN xG_a END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN xG_h END)) - (SUM(CASE WHEN Home LIKE 'Arsenal' THEN Away_Goals END) + SUM(CASE WHEN Away LIKE 'Arsenal' THEN Home_Goals END))), 2) AS XGA_PERFORMANCE
FROM (
SELECT TOP 20 *
FROM PL_Fixtures_23_24
WHERE Home LIKE 'Arsenal' OR Away LIKE 'Arsenal'
) AS TBL;

--At this stage last season, according to xG Arsenal should have conceded +1.7 more than they had conceded.
--On the contrary, this season, Arsenal have conceded -3.7 more than they were expected to concede

SELECT GK.Player, 
	ROUND(GA90, 2) AS GA90, 
	ROUND((CAST(PSxG AS FLOAT)/GK._90s), 2) as PSXG90, 
	ROUND(((CAST(PSxG AS FLOAT)/GK._90s)-GA90), 2) AS PSXG_GA90,
	ROUND([Save], 2) AS SAVE_PERC, 
	ROUND((CAST(SoTA AS FLOAT)/GK._90s), 2) as SOT90, 
	ROUND(PSxG_Sot, 2) AS PSXG_SOT,
	((CAST(PKsv AS FLOAT)/PKatt)*100) as PKSave_Perc,
	ROUND((CAST(PS.Cmp AS FLOAT)/GK._90s), 2) as PS_Cmp, 
	ROUND((CAST(PrgDist AS FLOAT)/GK._90s), 2) as PrgDist, Cmp1
FROM Gk_data_22_23 GK
JOIN Passing_data_22_23 PS ON GK.Player = PS.Player
WHERE GK.Player LIKE 'Aaron%'
UNION
SELECT GK.Player, 
	ROUND(GA90, 2) AS GA90, 
	ROUND((CAST(PSxG AS FLOAT)/GK._90s), 2) as PSXG90, 
	ROUND(((CAST(PSxG AS FLOAT)/GK._90s)-GA90), 2) AS PSXG_GA90,
	ROUND([Save], 2) AS SAVE_PERC, 
	ROUND((CAST(SoTA AS FLOAT)/GK._90s), 2) as SOT90, 
	ROUND(PSxG_Sot, 2) AS PSXG_SOT,
	((CAST(PKsv AS FLOAT)/PKatt)*100) as PKSave_Perc,
	ROUND((CAST(PS.Cmp AS FLOAT)/GK._90s), 2) as PS_Cmp, 
	ROUND((CAST(PrgDist AS FLOAT)/GK._90s), 2) as PrgDist, Cmp1
FROM Gk_data_23_24 GK
JOIN Passing_data_23_24 PS ON GK.Player = PS.Player
WHERE GK.Player LIKE 'David%';

--Raya is conceding less per game AND is according to post shot xG he is also expected to concede less.
--However he is conceding 0.2 more than he should per 90. Higher than Ramsdale's 0.08 from last season.
--Raya also has a save percentage of 61.5%, which is less than the 70.6 Ramsdale managed last season.
--Raya also faces less shots on target per 90. But the post shot xg (0.3) of each shot target is higher per game than Ramsdale's 0.28
--Raya has saved 50% of the two penalties he has faced this season. Ramsdale saved 0 penalties last season, despite facing 5.
--Raya completes more passes/90, the progressive distance of his passes is also higher and he also completes a larger precentage of his passes


--Are there noticeable differences in defensive solidity between the two seasons?

--Overall, Arsenal's defense is more solid compared to last season. However, a slight drop in GK performance means they have conceded more than they are expected to concede


--Defensive Actions:

--What defensive actions, such as tackles, interceptions, and clearances, have changed between the two seasons?

SELECT '22/23' as SEASON,
	ROUND(SUM(CAST(d23.Tkl AS FLOAT))/38, 2) AS Tkl,
    ROUND(SUM(CAST(d23.TklW AS FLOAT))/38, 2) AS Tklw,
    ROUND(SUM(CAST(d23.Blocks AS FLOAT))/38, 2) AS Blks,
    ROUND(SUM(CAST(d23.Int AS FLOAT))/38, 2) AS Ints,
    ROUND(SUM(CAST(d23.Clr AS FLOAT))/38, 2) AS Clr
FROM Defending_data_22_23 d23
UNION
SELECT '23/24' as SEASON,
	ROUND(SUM(CAST(d24.Tkl AS FLOAT))/20, 2) AS Tkl,
	ROUND(SUM(CAST(d24.TklW AS FLOAT))/20, 2) AS Tklw,
	ROUND(SUM(CAST(d24.Blocks AS FLOAT))/20, 2) AS Blks,
	ROUND(SUM(CAST(d24.Int AS FLOAT))/20, 2) AS Ints,
	ROUND(SUM(CAST(d24.Clr AS FLOAT))/20, 2) AS Clr
FROM Defending_data_23_24 d24;

--There is no significant increase in any of arsenal's defensive numbers.
--Per Game, they attempt more tackles, win 0.07 more, they also block more shots and intercept more.
--They clear the ball less this season. 11.9 which is a substancially lower than the 15.76 from last season.

SELECT d23.Player, 
	ROUND((CAST(d23.Tkl AS FLOAT) / d23._90s), 2) AS Tkl,
    ROUND((CAST(d24.Tkl AS FLOAT) / d24._90s), 2) AS Tkl,
    ROUND((CAST(d23.TklW AS FLOAT) / d23._90s), 2) AS Tklw,
    ROUND((CAST(d24.TklW AS FLOAT) / d24._90s), 2) AS Tklw,
    ROUND((CAST(d23.Blocks AS FLOAT) / d23._90s), 2) AS Blks,
    ROUND((CAST(d24.Blocks AS FLOAT) / d24._90s), 2) AS Blks,
    ROUND((CAST(d23.[Int] AS FLOAT) / d23._90s), 2) AS Ints,
    ROUND((CAST(d24.[Int] AS FLOAT) / d24._90s), 2) AS Ints,
    ROUND((CAST(d23.Clr AS FLOAT) / d23._90s), 2) AS Clr,
    ROUND((CAST(d24.Clr AS FLOAT) / d24._90s), 2) AS Clr
FROM Defending_data_22_23 d23
JOIN Defending_data_23_24 d24
ON d23.Player = d24.Player
WHERE d23.Pos NOT LIKE 'GK' AND d23._90s > 0 AND d24._90s > 0 AND d24.Player NOT LIKE 'Thomas%'

--Zinchenko's Defensive numbers have gone up in a lot of categories

SELECT '22/23' as Season, 
	ROUND((CAST(d23.Tkl AS FLOAT) / d23._90s), 2) AS Tkl,
    ROUND((CAST(d23.TklW AS FLOAT) / d23._90s), 2) AS Tklw,
	ROUND(((CAST(d23.TklW AS FLOAT)/CAST(d23.Tkl AS FLOAT))*100), 2) AS TklW_Perc,
    ROUND((CAST(d23.Blocks AS FLOAT) / d23._90s), 2) AS Blks,
    ROUND((CAST(d23.[Int] AS FLOAT) / d23._90s), 2) AS Ints,
    ROUND((CAST(d23.Clr AS FLOAT) / d23._90s), 2) AS Clr,  
	ROUND((CAST(p23.Succ AS FLOAT) / d23._90s), 2) AS Drb_90,
	ROUND(p23.Succ1, 2) AS Drb_sc, 
	ROUND((CAST(p23.PrgDist AS FLOAT) / d23._90s), 2) AS PrgDistCarr, 
	ROUND((CAST(ps23.PrgP AS FLOAT) / d23._90s), 2) AS PrgPass
FROM Defending_data_22_23 d23
JOIN Possession_data_22_23 p23 ON d23.Player = p23.Player
JOIN Passing_data_22_23 ps23 ON d23.Player = ps23.Player
WHERE d23.Player LIKE '%Zinchenko'
UNION
SELECT '23/24' as Season, 
    ROUND((CAST(d24.Tkl AS FLOAT) / d24._90s), 2) AS Tkl,
    ROUND((CAST(d24.TklW AS FLOAT) / d24._90s), 2) AS Tklw,
	ROUND(((CAST(d24.TklW AS FLOAT)/CAST(d24.Tkl AS FLOAT))*100), 2) AS TklW_Perc,
    ROUND((CAST(d24.Blocks AS FLOAT) / d24._90s), 2) AS Blks,
    ROUND((CAST(d24.[Int] AS FLOAT) / d24._90s), 2) AS Ints,
    ROUND((CAST(d24.Clr AS FLOAT) / d24._90s), 2) AS Clr, 
	ROUND((CAST(p24.Succ AS FLOAT) / d24._90s), 2) AS Drb_90,
	ROUND(p24.Succ1, 2) AS Drb_sc, 
	ROUND((CAST(p24.PrgDist AS FLOAT) / d24._90s), 2) AS PrgDistCarr, 
	ROUND((CAST(ps24.PrgP AS FLOAT) / d24._90s), 2) AS PrgPass
FROM Defending_data_23_24 d24
JOIN Possession_data_23_24 p24 ON d24.Player = p24.Player
JOIN Passing_data_23_24 ps24 ON d24.Player = ps24.Player
WHERE d24.Player LIKE '%Zinchenko';

--Zinchenko's Numbers
--Tackles attempted/game have gone up from 1.7 to 2.84. Tackles won/game has also gone up as a result, from 0.77 to 1.72
--He is also winning 60.53% of his tackles this season, an increase from 45% last season
--Blocks and Interceptions have also gone up
--Clearances per game have gone down. From 1.62 last season to 0.9 this season
--Dribbless per game has also gone down, from 0.64 to 0.37 this season. Success rate last season was 60%, this season it is 55.6
--Progressive Distance Carried/90 has also gone down a lot. From 161.15 to 117.99 this season.
--However, he is making more progressive passes/90 than he did last season. 9.66 last season and 12.01 this season

--Declan Rice vs Partey

SELECT d23.Player, 
	ROUND((CAST(d23.Tkl AS FLOAT) / d23._90s), 2) AS Tkl,
    ROUND((CAST(d23.TklW AS FLOAT) / d23._90s), 2) AS Tklw,
	ROUND(((CAST(d23.TklW AS FLOAT)/CAST(d23.Tkl AS FLOAT))*100), 2) AS TklW_Perc,
    ROUND((CAST(d23.Blocks AS FLOAT) / d23._90s), 2) AS Blks,
    ROUND((CAST(d23.[Int] AS FLOAT) / d23._90s), 2) AS Ints,
    ROUND((CAST(d23.Clr AS FLOAT) / d23._90s), 2) AS Clr, 
	ROUND((CAST(p23.Touches AS FLOAT) / d23._90s), 2) AS Tchs, 
	ROUND((CAST(p23.Def_3rd AS FLOAT) / d23._90s), 2) AS Tchs_d3, 
	ROUND((CAST(p23.Mid_3rd AS FLOAT) / d23._90s), 2) AS Tchs_m3, 
	ROUND((CAST(p23.Att_3rd AS FLOAT) / d23._90s), 2) AS Tchs_a3, 
	ROUND((CAST(p23.Succ AS FLOAT) / d23._90s), 2) AS Drb_90,
	ROUND(p23.Succ1, 2) AS Drb_sc, 
	ROUND((CAST(p23.PrgDist AS FLOAT) / d23._90s), 2) AS PrgDistCarr, 
	ROUND((CAST(p23.Dis AS FLOAT) / d23._90s), 2) AS Dispos, 
	ROUND((CAST(p23.Rec AS FLOAT) / d23._90s), 2) AS PssRc,
	ROUND(ps23.Cmp1, 2) AS PssCmp,
	ROUND((CAST(ps23.PrgP AS FLOAT) / d23._90s), 2) AS PrgPass,
	ROUND((CAST(p23.PrgC AS FLOAT) / d23._90s), 2) AS PrgCarr,
	ROUND((CAST(ps23.PrgDist AS FLOAT) / d23._90s), 2) AS PrgDistP
FROM Defending_data_22_23 d23
JOIN Possession_data_22_23 p23 ON d23.Player = p23.Player
JOIN Passing_data_22_23 ps23 ON d23.Player = ps23.Player
WHERE d23.Player LIKE 'Thomas%'
UNION
SELECT d24.Player, 
    ROUND((CAST(d24.Tkl AS FLOAT) / d24._90s), 2) AS Tkl,
    ROUND((CAST(d24.TklW AS FLOAT) / d24._90s), 2) AS Tklw,
	ROUND(((CAST(d24.TklW AS FLOAT)/CAST(d24.Tkl AS FLOAT))*100), 2) AS TklW_Perc,
    ROUND((CAST(d24.Blocks AS FLOAT) / d24._90s), 2) AS Blks,
    ROUND((CAST(d24.[Int] AS FLOAT) / d24._90s), 2) AS Ints,
    ROUND((CAST(d24.Clr AS FLOAT) / d24._90s), 2) AS Clr, 
	ROUND((CAST(p24.Touches AS FLOAT) / d24._90s), 2) AS Tchs, 
	ROUND((CAST(p24.Def_3rd AS FLOAT) / d24._90s), 2) AS Tchs_d3, 
	ROUND((CAST(p24.Mid_3rd AS FLOAT) / d24._90s), 2) AS Tchs_m3, 
	ROUND((CAST(p24.Att_3rd AS FLOAT) / d24._90s), 2) AS Tchs_a3, 
	ROUND((CAST(p24.Succ AS FLOAT) / d24._90s), 2) AS Drb_90,
	ROUND(p24.Succ1, 2) AS Drb_sc, 
	ROUND((CAST(p24.PrgDist AS FLOAT) / d24._90s), 2) AS PrgDistCarr, 
	ROUND((CAST(p24.Dis AS FLOAT) / d24._90s), 2) AS Dispos, 
	ROUND((CAST(p24.Rec AS FLOAT) / d24._90s), 2) AS PssRc,
	ROUND(ps24.Cmp1, 2) AS PssCmp,
	ROUND((CAST(ps24.PrgP AS FLOAT) / d24._90s), 2) AS PrgPass,
	ROUND((CAST(p24.PrgC AS FLOAT) / d24._90s), 2) AS PrgCarr,
	ROUND((CAST(ps24.PrgDist AS FLOAT) / d24._90s), 2) AS PrgDistP
FROM Defending_data_23_24 d24
JOIN Possession_data_23_24 p24 ON d24.Player = p24.Player
JOIN Passing_data_23_24 ps24 ON d24.Player = ps24.Player
WHERE d24.Player LIKE '%Rice';

SELECT *
FROM Possession_data_23_24

--Declan Rice attempts less tackles than Partey and wins less as a result. But they both win tackles at the same rate.
--Declan Rice also blocks more shots/90, intercepts more and Clears the ball more than Partey.
--Partey averages more touches/90 (82.14 for Partey and 81.13 for Rice). Most of them in the middle third where his numbers trump Rice's.
--Rice however, has more touches in the defensive third and the attacking third.
--Rice's dribbles per 90 (0.67) this season are almost half of what Partey managed last season (1.27)
--His dribble success rate is also more than 20% less than what Partey had last season.
--Rice carries the ball farther/90 (164.38 yards), than Partey(139.38 yards) did last season.
--Partey's average progressive pass travels further than Rice's does.


--Gabriel Progression numbers

SELECT '22/23' AS Season, 
	ROUND(((S23.PrgC + S23.PrgP)/S23._90s), 2) as prgA_90,
	ROUND((P23.Touches/S23._90s), 2) as Tch_90,
	ROUND((P23.PrgDist/S23._90s), 2) as pDistC_90,
	ROUND((P23._1_3/S23._90s), 2) as prG1_3_90,
	ROUND((PS23.PrgDist/S23._90s), 2) as pDistP_90,
	ROUND((P23.Rec/S23._90s), 2) as pRec_90,
	ROUND((P23.PrgR/S23._90s), 2) as ppRec_90,
	ROUND((Cmp2/S23._90s), 2) as Comp_Sh,
	ROUND((Att2/S23._90s), 2) as Att_Sh,
	ROUND((Cmp3/S23._90s), 2) as Comp_Md,
	ROUND((Att3/S23._90s), 2) as Att_Md,
	ROUND((Cmp4/S23._90s), 2) as Comp_Lg,
	ROUND((Att4/S23._90s), 2) as Att_Lg,
	ROUND((PPA/S23._90s), 2) as PPA,
	ROUND((Cmp/S23._90s), 2) as Comp,
	ROUND((PS23.Att/S23._90s), 2) as Att
FROM Standard_data_22_23 S23
JOIN Possession_data_22_23 P23 on S23.Player = P23.Player
JOIN Passing_data_22_23 PS23 on S23.Player = PS23.Player
WHERE S23.Player LIKE 'Gabriel%' AND S23.Pos LIKE 'DF'
UNION
SELECT '23/24' AS Season, 
	ROUND(((S24.PrgC + S24.PrgP)/S24._90s), 2) as prgA_90,
	ROUND((P24.Touches/S24._90s), 2) as Tch_90,
	ROUND((P24.PrgDist/S24._90s), 2) as pDistC_90,
	ROUND((P24._1_3/S24._90s), 2) as prG1_3_90,
	ROUND((PS24.PrgDist/S24._90s), 2) as pDistP_90,
	ROUND((P24.Rec/S24._90s), 2) as pRec_90,
	ROUND((P24.PrgR/S24._90s), 2) as ppRec_90,
	ROUND((Cmp_Short/S24._90s), 2) as Comp_Sh,
	ROUND((Att_Short/S24._90s), 2) as Att_Sh,
	ROUND((Cmp_Medium/S24._90s), 2) as Comp_Md,
	ROUND((Att_Medium/S24._90s), 2) as Att_Md,
	ROUND((Cmp_Long/S24._90s), 2) as Comp_Lg,
	ROUND((Att_Long/S24._90s), 2) as Att_Lg,
	ROUND((PPA/S24._90s), 2) as PPA,
	ROUND((Cmp/S24._90s), 2) as Comp,
	ROUND((PS24.Att/S24._90s), 2) as Att
FROM Standard_data_23_24 S24
JOIN Possession_data_23_24 P24 on S24.Player = P24.Player
JOIN Passing_data_23_24 PS24 on S24.Player = PS24.Player
WHERE S24.Player LIKE 'Gabriel%' AND S24.Pos LIKE 'DF';

--Gabriel is having slighly less touches this season. The average progressive distance of his carries has also reduced a lot, from 144.35 yards to 108.16 yards.
--The average progressive distance of his passes has also gone down a lot, from 356.78 yards to 300.61 yards.
--He is also completing slighly less passes


--Martinelli Last Season vs This Season

SELECT '22/23' as Season, Sh, SoT, ROUND(sh._90s, 2) AS _90S, ROUND((Gls/sh._90s), 2) AS G90, ROUND(SoT1, 2) AS SoT1,
ROUND(Sh_90, 2) AS Sh_90,
ROUND(SoT_90, 2) AS SoT_90,
ROUND(G_Sh, 2) AS G_Sh,
ROUND(G_SoT, 2) AS G_SoT,
ROUND(Dist, 2) AS Dist,
ROUND((xG/sh._90s), 2) AS xG,
ROUND((npxG/sh._90s), 2) AS npxG,
ROUND(npxG_Sh, 2) AS npxG_Sh,
ROUND(G_xG, 2) AS G_xG,
ROUND((ps.Att/sh._90s), 2) as Attempts,
ROUND((Succ/sh._90s), 2) as Succ,
ROUND(ps.Succ1, 2) as DrbScc,
ROUND((Mid_3rd/sh._90s), 2) as Mid_3rd,
ROUND((Att_3rd/sh._90s), 2) as Att_3rd,
ROUND((ps.PrgDist/sh._90s), 2) as Prg,
ROUND((ps._1_3/sh._90s), 2) as _1_3,
ROUND((CPA/sh._90s), 2) as CPA,
ROUND((Rec/sh._90s), 2) as PssRc,
ROUND((PrgR/sh._90s), 2) as PrgPR,
ROUND((Ast/sh._90s), 2) as Ast,
ROUND((xAG/sh._90s), 2) as xAG,
ROUND((KP/sh._90s), 2) as KP,
ROUND((pd._1_3/sh._90s), 2) as P_1_3,
ROUND((PPA/sh._90s), 2) as PPA,
ROUND((CrsPA/sh._90s), 2) as PrgP
FROM Shooting_data_22_23 sh
JOIN Possession_data_22_23 ps ON sh.Player = ps.Player
JOIN Passing_data_22_23 pd ON pd.Player = sh.Player
WHERE sh.Player LIKE '%Martinelli'
UNION
SELECT '23/24' as Season, Sh, SoT, ROUND(sh._90s, 2) AS _90S, ROUND((Gls/sh._90s), 2) AS G90, ROUND(SoT1, 2) AS SoT1,
ROUND(Sh_90, 2) AS Sh_90,
ROUND(SoT_90, 2) AS SoT_90,
ROUND(G_Sh, 2) AS G_Sh,
ROUND(G_SoT, 2) AS G_SoT,
ROUND(Dist, 2) AS Dist,
ROUND((xG/sh._90s), 2) AS xG,
ROUND((npxG/sh._90s), 2) AS npxG,
ROUND(npxG_Sh, 2) AS npxG_Sh,
ROUND(G_xG, 2) AS G_xG,
ROUND((ps.Att/sh._90s), 2) as Attempts,
ROUND((Succ/sh._90s), 2) as Succ,
ROUND(ps.Succ1, 2) as DrbScc,
ROUND((Mid_3rd/sh._90s), 2) as Mid_3rd,
ROUND((Att_3rd/sh._90s), 2) as Att_3rd,
ROUND((ps.PrgDist/sh._90s), 2) as Prg,
ROUND((ps._1_3/sh._90s), 2) as _1_3,
ROUND((CPA/sh._90s), 2) as CPA,
ROUND((Rec/sh._90s), 2) as PssRc,
ROUND((PrgR/sh._90s), 2) as PrgPR,
ROUND((Ast/sh._90s), 2) as Ast,
ROUND((xAG/sh._90s), 2) as xAG,
ROUND((KP/sh._90s), 2) as KP,
ROUND((pd._3_Jan/sh._90s), 2) as P_1_3,
ROUND((PPA/sh._90s), 2) as PPA,
ROUND((CrsPA/sh._90s), 2) as PrgP
FROM Shooting_data_23_24 sh
JOIN Possession_data_23_24 ps ON sh.Player = ps.Player
JOIN Passing_data_23_24 pd ON pd.Player = sh.Player
WHERE sh.Player LIKE '%Martinelli';

--Marinelli's Attacking Numbers
--Goals per 90 has gone down from 0.48/90 to 0.14/90
--This season, 33.3% of his shots are on target, compared to 38% from last season
--Martinelli takes 2.31 shots/90 this season. A small drop from 2.51 last season
--Shots on target/90 have also dropped from 0.97 to 0.77. Goals/SoT has also dropped as a result, from 0.5 to 0.18
--Avg Shot distance has also gone up by 0.5 yards
--npxG per game has also gone down by almost half. From 0.3 to 0.17
--He is also underperforming his xG by -0.5, while last season he overperformed by +5.7
--He is also attempting more dribbles, but completing less
--However, he takes more touches in the atacking third than he did last season.
--He also progresses the ball farther per game than he did last season.
--His carries into the penalty area have also increased
--He receives more passes this season and he also receives more progressive passes.
--xGA has gone down this season. Key passes remain around the same number
--Passes into the final third have gone up. Passes into penalty area have also gone up



--Saka Last Season vs This Season

SELECT '22/23' as Season, ROUND(_90s, 2) AS _90S, ROUND((Gls/_90s), 2) AS G90, ROUND(SoT1, 2) AS SoT1,
ROUND(Sh_90, 2) AS Sh_90,
ROUND(SoT_90, 2) AS SoT_90,
ROUND(G_Sh, 2) AS G_Sh,
ROUND(G_SoT, 2) AS G_SoT,
ROUND(Dist, 2) AS Dist,
ROUND((xG/_90s), 2) AS xG,
ROUND((npxG/_90s), 2) AS npxG,
ROUND(npxG_Sh, 2) AS npxG_Sh,
ROUND(G_xG, 2) AS G_xG
FROM Shooting_data_22_23
WHERE Player LIKE '%Saka'
UNION
SELECT '23/24' as Season, ROUND(_90s, 2) AS _90S, ROUND((Gls/_90s), 2) AS G90, ROUND(SoT1, 2) AS SoT1,
ROUND(Sh_90, 2) AS Sh_90,
ROUND(SoT_90, 2) AS SoT_90,
ROUND(G_Sh, 2) AS G_Sh,
ROUND(G_SoT, 2) AS G_SoT,
ROUND(Dist, 2) AS Dist,
ROUND((xG/_90s), 2) AS xG,
ROUND((npxG/_90s), 2) AS npxG,
ROUND(npxG_Sh, 2) AS npxG_Sh,
ROUND(G_xG, 2) AS G_xG
FROM Shooting_data_23_24
WHERE Player LIKE '%Saka';

--Saka's Attacking Numbers
--Goals per 90 has gone down from 0.4 to 0.33
--% Of Shots that land on target has gone up, from 33.7% to 36.2%
--Shots/90 and Shots on target/90 has gone up
--Goals/Sot has dropped by nearly half though. From 0.41 to 0.24
--Avg Shot distance has gone down, from 16.3 yards to 15.8 yards
--npxG/90 has gone up, from 0.26 to 0.29
--He is underperforming his XG this season, by -0.9. While last season he overperformed by +2.8


--Gabriel Jesus Last Season vs This Season

SELECT '22/23' as Season, ROUND(_90s, 2) AS _90S, ROUND((Gls/_90s), 2) AS G90, ROUND(SoT1, 2) AS SoT1,
ROUND(Sh_90, 2) AS Sh_90,
ROUND(SoT_90, 2) AS SoT_90,
ROUND(G_Sh, 2) AS G_Sh,
ROUND(G_SoT, 2) AS G_SoT,
ROUND(Dist, 2) AS Dist,
ROUND((xG/_90s), 2) AS xG,
ROUND((npxG/_90s), 2) AS npxG,
ROUND(npxG_Sh, 2) AS npxG_Sh,
ROUND(G_xG, 2) AS G_xG
FROM Shooting_data_22_23
WHERE Player LIKE '%Jesus'
UNION
SELECT '23/24' as Season, ROUND(_90s, 2) AS _90S, ROUND((Gls/_90s), 2) AS G90, ROUND(SoT1, 2) AS SoT1,
ROUND(Sh_90, 2) AS Sh_90,
ROUND(SoT_90, 2) AS SoT_90,
ROUND(G_Sh, 2) AS G_Sh,
ROUND(G_SoT, 2) AS G_SoT,
ROUND(Dist, 2) AS Dist,
ROUND((xG/_90s), 2) AS xG,
ROUND((npxG/_90s), 2) AS npxG,
ROUND(npxG_Sh, 2) AS npxG_Sh,
ROUND(G_xG, 2) AS G_xG
FROM Shooting_data_23_24
WHERE Player LIKE '%Jesus';

--Jesus' Attacking Numbers
--G/90 has gone down from 0.48 to 0.29
--% of shots on target has gone up, from 40.8% to 43.8%
--Shots/90 has gone down, but Shots on target/90 remains the same
--Goals/Shots on target has gone down from 0.32 to 0.21.
--Avg Shot distance has gone up. From 10.6 yards to 11.5 yards
--npxG/90 has also gone down. From 0.58 to 0.46
--He underperformed his xG by -3 last season. This season he is still underperforming, but by -1.8