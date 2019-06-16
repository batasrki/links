CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    email VARCHAR(100),
    username VARCHAR(100),
    inserted_at TIMESTAMPZ,
    updated_at TIMESTAMPZ
);
CREATE INDEX email_idx
ON users (email);

CREATE INDEX username_idx
ON users (username);