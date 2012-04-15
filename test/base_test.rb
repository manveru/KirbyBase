require "tmpdir"

module BaseTest
	def setup
		@db = KirbyBase.new(:local, nil, nil, Dir.tmpdir, '.table')
		@encrypted = false
	end

	def teardown
		@db.tables.each { |table| @db.drop_table table }
        File.unlink('test.txt') if File.exists?('test.txt')
	end

	def table_fname(table_name)
		File.join @db.path, table_name + @db.ext
	end
end
