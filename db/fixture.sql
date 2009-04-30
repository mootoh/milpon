--------------------------------------------------------------------
-- List
--
INSERT INTO list (id, name)        VALUES (1, 'Inbox');
INSERT INTO list (id, name)        VALUES (2, 'Sent');
INSERT INTO list (id, name)        VALUES (3, 'Project');
INSERT INTO list VALUES (4, 'Week', '(dueWithin:"7 days of today")');
INSERT INTO list VALUES (5, '2007List', '(tag:2007)');

--------------------------------------------------------------------
-- Task
--

INSERT INTO task VALUES (1, 0,
    1, NULL, NULL, 0, 0, '', 0,
    1, 'task one', '', 1, 1, '');

-- has due
INSERT INTO task VALUES (2, 0,
    2, '2009-12-31 23:59:59', NULL, 0, 0, '', 0,
    1, 'task two', '', 1, 1, '');

-- has completed
INSERT INTO task VALUES (3, 0,
    3, NULL, '2009-03-31 23:59:59', 0, 0, '', 0,
    1, 'task three', '', 1, 1, '');
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
