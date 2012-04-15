# This script is an example of how to change a column type.
#
require 'kirbybase'

db = KirbyBase.new

# If table exists, delete it.
db.drop_table(:log) if db.table_exists?(:log)

log_tbl = db.create_table(:log, :log_timestamp, :DateTime, :msg, :String)

log_tbl.insert(DateTime.now, 'This is a log message')
log_tbl.insert(DateTime.now, 'This is a another log message')
log_tbl.insert(DateTime.now, 'This is the final log message')

p log_tbl.select
puts;puts

log_tbl.change_column_type(:log_timestamp, :String)

p log_tbl.select
puts;puts

p log_tbl.field_types

