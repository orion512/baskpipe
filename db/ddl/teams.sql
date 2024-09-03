create table if not exists teams (
	id serial primary key, 

	full_name varchar(100) NOT NULL,
	short_name varchar(5) unique NOT null,
	
	location varchar(100),

	inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
)