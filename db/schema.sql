CREATE TABLE list (
  'id'   INTEGER PRIMARY KEY,
  'name' CHAR(64)
);

CREATE TABLE task (
  'id'             INTEGER PRIMARY KEY,
  'due'            CHAR(24),
  'completed'      CHAR(24),
  'deleted'        INTEGER,
  'priority'       INTEGER,
  'postponed'      INTEGER,
  'estimate'       CHAR(24),
  'dirty'          INTEGER,
-- TaskSeries begin
  'task_series_id' INTEGER,
  'name'        TEXT,
  'url'         TEXT,
  'location_id' INTEGER,
  'list_id'     INTEGER,
  'rrule'       TEXT
-- TaskSeries end
);

CREATE TABLE location (
  'id'        INTEGER PRIMARY KEY,
  'name'      TEXT,
  'longitude' CHAR(128),
  'latitude'  CHAR(128),
  'zoom'      TEXT,
  'address'   TEXT,
  'viewable'  TEXT
);

CREATE TABLE note (
  'id'              INTEGER PRIMARY KEY,
  'title'           TEXT,
  'text'            TEXT,
  'created'         TEXT,
  'modified'        TEXT,
  'task_series_id'  INTEGER
);

CREATE TABLE tag (
  'id'             INTEGER PRIMARY KEY,
  'name'           TEXT,
  'task_series_id' INTEGER
);

CREATE TABLE last_sync (
  'sync_date' CHAR(24)
);
