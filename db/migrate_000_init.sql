CREATE TABLE list (
  id             INTEGER PRIMARY KEY,
  name           CHAR(64) NOT NULL
);

CREATE TABLE task (
  id             INTEGER PRIMARY KEY,
  edit_bits      INTEGER DEFAULT 0,
-- Task begin
  task_id        INTEGER,
  due            CHAR(24), -- date
  completed      CHAR(24), -- date
  priority       INTEGER DEFAULT 0,
  postponed      INTEGER DEFAULT 0,
  estimate       CHAR(24) DEFAULT '',
  has_due_time   INTEGER DEFAULT 0,
  -- added          CHAR (24)
  -- deleted        INTEGER DEFAULT 0,
-- TaskSeries begin
  taskseries_id  INTEGER,
  name           TEXT NOT NULL,
  url            TEXT DEFAULT '',
  location_id    INTEGER DEFAULT '',
  list_id        INTEGER NOT NULL,
  rrule          TEXT DEFAULT ''
  -- created     CHAR(24)
  -- modified    CHAR(24)
  -- source      CHAR(16)
  -- participants TEXT
);

CREATE TABLE note (
  id             INTEGER PRIMARY KEY,
  title          TEXT,
  text           TEXT,
  task_id        INTEGER NOT NULL,
  edit_bits      INTEGER DEFAULT 0
  -- created        TEXT,
  -- modified       TEXT,
);

CREATE TABLE tag (
  id             INTEGER PRIMARY KEY,
  name           TEXT NOT NULL
);

CREATE TABLE task_tag (
  id             INTEGER PRIMARY KEY,
  task_id        INTEGER NOT NULL,
  tag_id         INTEGER NOT NULL
);

CREATE TABLE location (
  id             INTEGER PRIMARY KEY,
  name           TEXT,
  longitude      CHAR(128),
  latitude       CHAR(128),
  zoom           TEXT,
  address        TEXT,
  viewable       TEXT
);

CREATE TABLE last_sync (
  sync_date      CHAR(24)
);

INSERT INTO migrate_version VALUES (0);
