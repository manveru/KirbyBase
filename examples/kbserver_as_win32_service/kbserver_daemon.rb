# Modified version of kbserver.rb for use as Windows Service.

require 'kirbybase'
require 'drb'
require 'win32/service'
include Win32

OPTIONS = {}

class KBServerDaemon < Daemon
    def initialize
        # NOTE:  Change this line to reflect where you want the log file to
        #        reside.
        @log = 'C:\logs\db_server_log.txt'
        begin
            # NOTE:  Change this line to reflect where the database tables
            #        are located.
            @db = KirbyBase.new do |x|
                x.connect_type = :server
                x.path = 'C:\data'
            end 
        rescue Exception => e
            File.open(@log, "a+") { |fh| ft.puts "Error: #{e}" }
            service_stop
        end    
    end
    
    def service_main
        begin
            # NOTE:  Change this line to reflect what port you want to 
            #        listen on.
            DRb.start_service('druby://:44444', @db)
            DRb.thread.join
        rescue StandardError, InterrupError => e
            File.open(@log, "a+") { |fh| fh.puts "Error: #{e}" }
            service_stop
        end     
    end
    
    def service_stop
        DRb.stop_service
        exit
    end
end

d = KBServerDaemon.new
d.mainloop
