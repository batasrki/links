CREATE TABLE links(
    id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    url VARCHAR(100),
    client VARCHAR(50),
    added_at TIMESTAMPZ,
    archive BOOLEAN DEFAULT FALSE,
    inserted_at TIMESTAMPZ,
    updated_at TIMESTAMPZ
);

CREATE INDEX added_at_archived_idx
ON links (added_at, archive);