SQLite format 3   @                                                                             �    � �                                                                                                                                 �Z�tablelocationlocationCREATE TABLE location (
  'id'        INTEGER PRIMARY KEY,
  'name'      TEXT,
  'longitude' CHAR(128),
  'latitude'  CHAR(128),
  'zoom'      TEXT,
  'address'   TEXT,
  'viewable'  TEXT
)�N�tabletasktaskCREATE TABLE task (
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
)Z�tablelistlistCREATE TABLE list (
  'id'   INTEGER PRIMARY KEY,
  'name' CHAR(      � ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
 Someday
 Project Sent Inbox   � �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        task one                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                �  �R#&          Z�tablelistlistCREATE TABLE list (
  'id'   INTEGER PRIMARY KEY,
  'name' CHAR(64)
)�N�tabletasktaskCREATE TABLE task (
  'id'             INTEGER PRIMARY KEY,
  'due'            CHAR(24),
  'completed'Z�tablelistlistCREATE TABLE list (
  'id'   INTEGER PRIMARY KEY,
  'name' CHAR(64)
)�N�tabletasktaskCREATE TABLE task (
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
)�Z�tablelocationlocationCREATE TABLE location (
  'id'        INTEGER PRIMARY KEY,
  'name'      TEXT,
  'longitude' CHAR(128),
  'latitude'  CHAR(128),
  'zoom'      TEXT,
  'address'   TEXT,
  'viewable'  TEXT
)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 P �{P                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Ootablelast_synclast_sync	CREATE TABLE last_sync (
  'sync_date' CHAR(24)
)�W�tablenotenoteCREATE TABLE note (
  'id'              INTEGER PRIMARY KEY,
  'title'           TEXT,
  'text'            TEXT,
  'created'         TEXT,
  'modified'        TEXT,
  'task_series_id'  INTEGER
)��ktabletagtagCREATE TABLE tag (
  'id'             INTEGER PRIMARY KEY,
  'name'           TEXT
  'task_series_id' INTEGER
)   � �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        !1990-01-01