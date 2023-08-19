import { diff_match_patch } from "diff-match-patch";
const dmp = new diff_match_patch();

export enum Action {
	INSERT = 1,
	DELETE = -1,
	SAME = 0
}
export interface Change {
	action: Action;
	position: number;
	character: string;
	timestamp: number;
	revision: number;
}

export function getChange(doc: string, newDoc: string): Change | null {

	const diffs = dmp.diff_main(doc, newDoc);

	let index = 0;
	let change: Change | null = null;

	for(const diff of diffs) {

		const action: Action = diff[0];

		if (action !== Action.SAME){
			change = {
				action: action,
				position: index,
				character: diff[1],
				timestamp: Date.now(),
				revision: 0
			};
			break;
		}
		index += diff[1].length;
	}
	return change;
}

export function applyChange(doc: string, change: Change): string {
	let newdoc:string;
	const { action, position, character } = change;
	switch(action) {
		case Action.INSERT:
			newdoc =  doc.slice(0, position) + character + doc.slice(position);
			break;
		case Action.DELETE:
			newdoc =  doc.slice(0, position) + doc.slice(position + 1);
			break;
		default:
			newdoc = doc;
	}
	return newdoc;
}

export function ChangeToString(change: Change): string {
	const date = new Date(change.timestamp).toISOString();
	return `${date} ${Action[change.action]} ${change.character} at ${change.position}`;
}