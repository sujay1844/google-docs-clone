doc = []
revision_log = []
def apply_change(data):
	current_revision = len(revision_log)
	if current_revision > data["revision"]:
		transformed = data
		for change in revision_log[data["revision"]]:
			transformed = transform(data, change)
		data = transformed

	if data["action"] == 1:
		doc.insert(data['position'], data['character'])
	elif data["action"] == -1:
		doc.pop(data['position'])
	revision_log.append(data)
	current_revision += 1
	return current_revision
def transform(existing, incoming):
	return incoming