import xmlrpclib

server = xmlrpclib.Server("https://account.username:password@app.adestra.com/api/xmlrpc")

workspaces = server.workspace.all()

# display all the workspaces in the account
for workspace in workspaces:
        print workspace['id'], '-', workspace['name']
