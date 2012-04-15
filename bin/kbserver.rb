# Multi-user server script for KirbyBase.

require 'kirbybase'
require 'drb'

host = ''
port = 44444

puts 'Initializing database server and indexes...'

# Create an instance of the database.
db = KirbyBase.new(:server) 

DRb.start_service('druby://:44444', db)

puts 'Server ready to receive connections...'

DRb.thread.join 
