CREATE TABLE list (
  'id' INTEGER PRIMARY KEY,
  'name'     CHAR(64)
);

CREATE TABLE task_series (
  'id'           INTEGER PRIMARY KEY,
  'created'      CHAR(24),
  'modified'     CHAR(24),
  'name'         TEXT,
  'source'       TEXT,
  'url'          TEXT,
  'location_id'  INTEGER,
  'list_id'      INTEGER
);

CREATE TABLE task (
  'id'             INTEGER PRIMARY KEY,
  'due'            CHAR(24),
  'has_due_time'   INTEGER,
  'added'          CHAR(24),
  'completed'      CHAR(24),
  'deleted'        INTEGER,
  'priority'       INTEGER,
  'postponed'      INTEGER,
  'estimate'       CHAR(24),
  'task_series_id' INTEGER,
  'dirty'          INTEGER
);

CREATE TABLE location (
  'id'             INTEGER PRIMARY KEY,
  'name'           TEXT,
  'longitude'      CHAR(128),
  'latitude'       CHAR(128),
  'zoom'           TEXT,
  'address'        TEXT,
  'viewable'       TEXT,
  'task_series_id' INTEGER
);

CREATE TABLE note (
  'id'             INTEGER PRIMARY KEY,
  'title'          TEXT,
  'text'           TEXT,
  'created'        TEXT,
  'modified'       TEXT,
  'task_series_id' INTEGER
);

CREATE TABLE rrule (
  'id'             INTEGER PRIMARY KEY,
  'every'          CHAR(24),
  'rule'           TEXT,
  'task_series_id' INTEGER
);

CREATE TABLE tag (
  'id'        INTEGER PRIMARY KEY,
  'name'      TEXT
);

CREATE TABLE last_sync (
  'sync_date'      CHAR(24)
);

CREATE TABLE pending_task (
  'id'           INTEGER PRIMARY KEY,
  'name'         TEXT,
  'url'          TEXT,
  'due'          CHAR(24),
  'location_id'  INTEGER,
  'list_id'      INTEGER,
  'priority'     INTEGER,
  'estimate'     CHAR(24)
);
