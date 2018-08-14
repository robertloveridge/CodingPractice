import xmlrpclib

server = xmlrpclib.Server("https://account.username:password@app.adestra.com/api/xmlrpc")

# create a new contact on Core Table ID 1
new_contact = server.contact.create(1, {"email":"email@domain.com"})

print 'Your new or existing Contact ID', new_contact
