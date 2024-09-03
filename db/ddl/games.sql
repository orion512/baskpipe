create table if not exists games (
	id serial primary key, 
	
	br_game_id varchar(50),
	br_game_url text,

	game_time timestamp,
	arena_name varchar(100),
	playin_game boolean,
	attendance integer,

	inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
)