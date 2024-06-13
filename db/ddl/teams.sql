create table if not exists teams (
	id serial primary key, 

	full_name varchar(100) unique NOT NULL,
	short_name varchar(5) unique NOT null,
	
	location varchar(100)
)