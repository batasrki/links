ALTER TABLE links
ADD COLUMN users_id INT REFERENCES users(id);