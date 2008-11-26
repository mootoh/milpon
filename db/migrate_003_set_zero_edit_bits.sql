UPDATE task SET edit_bits=0 where edit_bits is NULL;

UPDATE migrate_version SET version=3;
