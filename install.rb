# Basic installer for fsm
require 'mkmf'
require 'fileutils'
sitedir = Config::CONFIG['sitedir']
bindir = Config::CONFIG['bindir']

Dir.chdir('lib')
FileUtils.install('kirbybase.rb', sitedir, :mode => 0644, :verbose => true)
