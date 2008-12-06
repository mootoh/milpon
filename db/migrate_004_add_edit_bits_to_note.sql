ALTER TABLE note add 'edit_bits' INTEGER;
UPDATE note SET edit_bits=0 where edit_bits is NULL;

UPDATE migrate_version SET version=4;
