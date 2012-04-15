$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'kirbybase'
require 'base_test'

class TestDatabaseLocal < Test::Unit::TestCase

	include BaseTest

    def test_version
        assert_equal('2.6', KirbyBase::VERSION)
    end
    
	def test_local?
		assert(@db.local?)
	end

	def test_extension
		assert_equal('.table', @db.ext)
	end

	def test_create_table_001
		tbl = @db.create_table(:empty) { |t| t.encrypt = @encrypted }
		assert_instance_of(KBTable, tbl)
	end

	def test_create_table_002
		@db.create_table(:empty) { |t| t.encrypt = @encrypted }

        if @encrypted
            data = "Zp8&1dg|;4p8&1t_tJyMBmsCDnG_;vKfEFrn\n"
        else
		    data = "000000|000000|Struct|recno:Integer|\n"
        end

		assert_equal(data, File.read(table_fname('empty')))
	end

	def test_create_table_003
		assert_raise(RuntimeError) { @db.create_table(:empty, :name,
         :String, :name, :Integer) { |t| t.encrypt = @encrypted } }
	end

	def test_drop_table
		@db.create_table(:empty) { |t| t.encrypt = @encrypted }
		@db.drop_table(:empty)
		assert(!@db.table_exists?(:empty))
	end

	def test_tables
		@db.create_table(:empty1) { |t| t.encrypt = @encrypted }
		@db.create_table(:empty2) { |t| t.encrypt = @encrypted }
		tables = @db.tables.collect { |sym| sym.to_s }
		assert_equal(%w(empty1 empty2), tables.sort)
	end

	def test_table_exists?
		@db.create_table(:empty) { |t| t.encrypt = @encrypted }
		assert(@db.table_exists?(:empty))
	end

	def test_get_table
		@db.create_table(:empty) { |t| t.encrypt = @encrypted }
		table = @db.get_table(:empty)
		assert_instance_of(KBTable, table)
	end

	def test_rename_table_001
		@db.create_table(:empty) { |t| t.encrypt = @encrypted }
		@db.rename_table(:empty, :new_empty)
		assert(@db.table_exists?(:new_empty))
    end

	def test_rename_table_002
		@db.create_table(:empty) { |t| t.encrypt = @encrypted }
		@db.create_table(:new_empty) { |t| t.encrypt = @encrypted }
		assert_raise(RuntimeError) {@db.rename_table(:empty, :new_empty)}
    end
end
