CREATE TABLE IF NOT EXISTS player_stats
(
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "player_name" TEXT NOT NULL,
    "player_id"	TEXT NOT NULL UNIQUE,
    "mp" TIME,
    "fg" INT,
    "fga" INT,
    "fg_pct" FLOAT,
    "fg3" INT,
    "fg3a" INT,
    "fg3_pct" FLOAT,
    "ft" INT,
    "fta" INT,
    "ft_pct" FLOAT,
    "orb" INT,
    "drb" INT,
    "trb" INT,
    "ast" INT,
    "stl" INT,
    "blk" INT,
    "tov" INT,
    "pf" INT,
    "pts" INT,
    "plsmin" INT,
    "team" TEXT,
    "ts_pct" FLOAT,
    "efg_pct" FLOAT,
    "fg3a_per_fga_pct" FLOAT,
    "fta_per_fga_pct" FLOAT,
    "orb_pct" FLOAT,
    "drb_pct" FLOAT,
    "trb_pct" FLOAT,
    "ast_pct" FLOAT,
    "stl_pct" FLOAT,
    "blk_pct" FLOAT,
    "tov_pct" FLOAT,
    "usg_pct" FLOAT,
    "off_rtg" FLOAT,
    "def_rtg" FLOAT,
    "game_id" TEXT NOT NULL,
    "game_url" TEXT
);