#Test of YAML field type.

require 'kirbybase'

# To run local, single-user, uncomment next line.
db = KirbyBase.new

# To run as a client in a multi-user environment, uncomment next line.
# Also, make sure kbserver.rb is running.
#db = KirbyBase.new do |d|
#    d.connect_type = :client
#    d.host = 'localhost'
#    d.port = 44444
#end

# If table exists, delete it.
db.drop_table(:pet) if db.table_exists?(:pet)

# Create a table.
pet_tbl = db.create_table(:pet, :name, :String, :pet_type, :String,
 :born, :Date, :characteristics, :YAML)

pet_tbl.insert('Kirby', 'dog', Date.new(2002, 06, 01),
 ['cute', 'stinky', 4, 55.6])
pet_tbl.insert('Mojo', 'cat', Date.new(2000, 04, 01),
 ['cute', 'soft', '6', 12.25])
pet_tbl.insert('Goldy', 'fish', Date.new(2004, 10, 10),
 [])

pet_tbl.select.each { |r|
    puts '%s %s' % [r.name, r.characteristics[1]]
}

puts

pet_tbl.select { |r| r.characteristics.include?('stinky') }.each { |r|
    puts '%s smells like a dog!' % r.name
}

pet_tbl.update { |r| r.name == 'Goldy' }.set(
 :characteristics => ['small', 'slimy', 2, 0.02])

puts
pet_tbl.select.each { |r|
    puts '%s %s' % [r.name, r.characteristics.join(' ')]
}

