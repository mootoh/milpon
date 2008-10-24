INSERT into list
  (name) VALUES ('Inbox');

INSERT into list
  (name) VALUES ('Sent');

INSERT into list
  (name) VALUES ('Project');

INSERT into list
  (name) VALUES ('Someday');

INSERT into task_series
  (created, modified, name, source, url, location_id, list_id) VALUES
  ('2008-10-15T15:00:00', '2008-10-15T15:00:00', 'Buy Milk', 'mail','http://www.rememberthemilk.com/', 0, 1);

INSERT into task_series
  (created, modified, name, source, url, location_id, list_id) VALUES
  ('2008-10-16T16:00:00', '2008-10-16T16:00:00','Forget about it', 'web', 'localhost', 0, 2);

INSERT into task_series
  (created, modified, name, source, url, location_id, list_id) VALUES
  ('2008-10-17T17:00:00', '2008-10-17T17:00:00','Buy Jam', 'js', 'localhost', 0, 1);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('2008-10-15T15:00:00', 1, '2008-10-15T15:00:00', '', 0, 0, 0, '1m', 1);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('2008-10-16T16:00:00', 1, '2008-10-16T16:00:00', '', 0, 0, 0, '2h', 1);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('2008-10-19T09:00:00', 1, '2008-10-19T09:00:00', '', 0, 0, 0, '2h', 2);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('2008-10-18T10:00:00', 1, '2008-10-18T10:00:00', '2008-10-18T10:00:00', 0, 0, 0, '2s', 2);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('2008-10-18T10:00:00', 1, '2008-10-18T10:00:00', '2008-10-18T10:00:00', 1, 0, 0, '2s', 1);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('2008-10-18T10:00:00', 1, '2008-10-18T10:00:00', '', 0, 1, 0, '2s', 1);

INSERT into task (due, has_due_time, added, completed, deleted, priority, postponed, estimate, task_series_id) VALUES
  ('', 0, '2008-10-20T11:00:00', '', 1, 0, 0, '2s', 1);


INSERT into last_sync (sync_date) VALUES ('1990-01-01');
