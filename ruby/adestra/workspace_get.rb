#!/usr/bin/env ruby

# Tested with "ruby 1.9.2p290 (2011-07-09 revision 32553) [x86_64-darwin11.1.0]"
require "xmlrpc/client"

account_name = "***"
user_name = "***"
password = "***"

server = XMLRPC::Client.new3(
  :host => "app.adestra.com",
  :path => "/api/xmlrpc",
  :user => "#{account_name}.#{user_name}",
  :password => password
)

begin
  param = server.call("workspace.get", 157)
  puts "Workspace name is #{param['name']}"
rescue XMLRPC::FaultException => e
  puts "Error:"
  puts e.faultCode
  puts e.faultString
end
