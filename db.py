TABLE_NAME = "operations"

create_table_query = f"""
CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
	op TEXT CHECK (op IN ('ins', 'del', 'noop')),
	pos INTEGER,
	str TEXT,
	revision INTEGER
)
"""
insert_table_query = f" INSERT INTO {TABLE_NAME} VALUES (?, ?, ?, ?)"
select_all_query = f"SELECT * FROM {TABLE_NAME}"
reset_table_query = f"DELETE FROM {TABLE_NAME}"

def create_table(cursor, connection):
	cursor.execute("DROP TABLE IF EXISTS operations")
	cursor.execute(create_table_query)
	connection.commit()


def insert_operation(cursor, connection, operation):
	if operation['op'] == 'noop':
		return
	if operation['op'] == 'del':
		operation['str'] == ''
	cursor.execute(insert_table_query, (operation['op'], operation['pos'], operation['str'], operation['revision']))
	connection.commit()

def get_all_operations(cursor):
	cursor.execute(select_all_query)
	raw = cursor.fetchall()
	operations = []
	for entry in raw:
		operations.append({
			"op": entry[0],
			"pos": entry[1],
			"str": entry[2],
			"revision": entry[3]
		})
	return operations

def get_all_operations_since(cursor, revision):
	cursor.execute(f"SELECT * FROM {TABLE_NAME} WHERE revision > ?", (revision,))
	raw = cursor.fetchall()
	operations = []
	for entry in raw:
		operations.append({
			"op": entry[0],
			"pos": entry[1],
			"str": entry[2],
			"revision": entry[3]
		})
	return operations 

def reset_table(cursor, connection):
	cursor.execute(reset_table_query)
	connection.commit()