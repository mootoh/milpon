ALTER TABLE list
   ADD filter TEXT
;

UPDATE migrate_version set version=1;
