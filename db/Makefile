migrate:
	rm -f rtm.sql test.sql
	for i in migrate_*.sql; do \
		sqlite3 rtm.sql < $$i; \
		sqlite3 test.sql < $$i; \
	done
