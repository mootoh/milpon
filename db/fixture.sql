INSERT into list
  (name) VALUES ('Inbox');

INSERT into list
  (name) VALUES ('Sent');

INSERT into list
  (name) VALUES ('Project');

INSERT into list
  (name) VALUES ('Someday');

INSERT into task
  (name, list_id) VALUES ('task one', 1);

INSERT into task
  (name, list_id, id) VALUES ('task two', 2, 2);

INSERT into last_sync (sync_date) VALUES ('1990-01-01');
