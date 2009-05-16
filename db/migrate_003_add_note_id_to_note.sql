ALTER TABLE note
   ADD note_id INTEGER DEFAULT NULL
;

UPDATE migrate_version set version=3;
