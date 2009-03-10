INSERT into list
  (name) VALUES ('Inbox');

INSERT into list
  (name) VALUES ('Sent');

INSERT into list
  (name) VALUES ('Project');

INSERT into list
  (name) VALUES ('Someday');

INSERT into task
  (id, name, due, completed, deleted, priority, postponed, estimate, dirty, task_series_id, url, location_id, list_id, rrule) VALUES
  (1, 'task one', '2009-03-31 13:00:00', 'not yet', 0, 1, 3, '30m', 7, 1, 'http://localhost/', 1, 1, '');

-- INSERT into task (name, list_id, id) VALUES ('task two', 2, 2);

INSERT into tag
   (id, name, task_series_id) VALUES (1, 'tag one', 1);

INSERT into tag
   (id, name, task_series_id) VALUES (2, 'tag two', 1);

INSERT into note
   (id, title, text, created, modified, task_series_id) VALUES
   (1, 'note one', 'note one text', '2009-03-31 13:00:00', '2009-03-31 13:00:00', 1);

INSERT into last_sync (sync_date) VALUES ('1990-01-01');
