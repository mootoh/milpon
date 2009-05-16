ALTER TABLE task
   ADD to_list_id INTEGER DEFAULT NULL
;

UPDATE migrate_version set version=2;
