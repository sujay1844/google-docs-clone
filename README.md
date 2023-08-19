# google-docs-clone

- only one change at a time
# Client
# on getting change
- transform the incoming change with pending changes and sent changes
- update the document
- update revision number

# on creating change
- add change to pending changes
- send change to server
- transfer change to sent changes
- wait for server to acknowledge change
- if server acknowledges change, remove change from sent changes
- if server does not acknowledge change, maintain current revision number and add new changes to pending changes
- update revision number

# Server
# on getting change
- add to pending changes
- transform the incoming change with changes applied after the revision number of the incoming change
- apply the change to the document
- add change to revision log
- send acknowledgement to client
- send change to all other clients with new revision number