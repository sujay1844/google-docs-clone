def transform(op1, op2):
	if op1['op'] == 'noop':
		return op2
	elif op2['op'] == 'noop':
		return op1
	elif op1['op'] == 'ins' and op2['op'] == 'ins':
		if op1['pos'] < op2['pos']:
			return op1
		else:
			return {
				"op": "ins",
				"pos": op1['pos'] + len(op1['str']),
				"str": op1['str']
			}
	elif op1['op'] == 'ins' and op2['op'] == 'del':
		if op1['pos'] <= op2['pos']:
			return op1
		else:
			return {
				"op": "ins",
				"pos": op1['pos'] - len(op1['str']),
				"str": op1['str']
			}
	elif op1['op'] == 'del' and op2['op'] == 'ins':
		if op1['pos'] < op2['pos']:
			return op1
		else:
			return {
				"op": "del",
				"pos": op1['pos'] + len(op1['str']),
			}
	elif op1['op'] == 'del' and op2['op'] == 'del':
		if op1['pos'] < op2['pos']:
			return op1

		elif op1['pos'] > op2['pos']:
			return {
				"op": "del",
				"pos": op1['pos'] - len(op1['str']),
			}
		else:
			return {
				"op": "noop",
			}
