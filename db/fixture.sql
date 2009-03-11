--------------------------------------------------------------------
-- List
--
INSERT INTO list (id, name) VALUES (1, 'Inbox');
INSERT INTO list (id, name) VALUES (2, 'Sent');
INSERT INTO list (id, name) VALUES (3, 'Project');
INSERT INTO list (id, name) VALUES (4, 'Someday');

--------------------------------------------------------------------
-- Task
--

-- task created at online already
INSERT INTO task (
    id, edit_bits,
    task_id, due, completed, priority, postponed, estimate, has_due_time,
    taskseries_id, name, url, location_id, list_id, rrule)
  VALUES (
    1, 0,
    1, '', '', 0, 0, '', 0,
    1, 'task one', '', 1, 1, '');

--------------------------------------------------------------------
-- Note
--

-- note created at online already
INSERT INTO note (
    id, title, text, task_id, edit_bits)
  VALUES (
    1, 'note one', 'here is a text', 1, 0);

--------------------------------------------------------------------
-- Tag
--
INSERT INTO tag (id, name) VALUES (1, 'tag one');
INSERT INTO tag (id, name) VALUES (2, 'tag two');

--------------------------------------------------------------------
-- Task-Tag
--
INSERT INTO task_tag (id, task_id, tag_id) VALUES (1, 1, 1);


INSERT INTO last_sync (sync_date) VALUES ('1990-01-01');
INSERT INTO migrate_version (version) VALUES (2);
