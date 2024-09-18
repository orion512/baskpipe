create table if not exists games (
	id serial primary key, 
	
	br_game_id varchar(50),
	br_game_url text,

	game_time timestamp,
	arena_name varchar(100),
	attendance integer,
	playin_game boolean,

	playoff_game boolean,
	playoff_conference varchar(4) CHECK (playoff_conference IN ('east', 'west')),
	playoff_round varchar(50) CHECK (playoff_round IN ('first round', 'conference semifinals', 'conference finals', 'nba finals')),
	playoff_game_number int CHECK (playoff_game_number BETWEEN 1 AND 7),

	inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
)