CREATE TABLE stats(
    id SERIAL PRIMARY KEY,
    click_count INTEGER NOT NULL,
    links_id INTEGER REFERENCES links(id),
    inserted_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);