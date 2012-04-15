# Control script for the KBServer service.

require 'optparse'
require 'win32/service'
include Win32

# You will want to change these values.
kbserver_home = 'C:\kbserver'
kbserver_prog = kbserver_home + '\kbserver_daemon.rb'
kbserver_svc = 'KirbyBaseServerSvc'
kbserver_name = 'KirbyBase Database Server'

OPTIONS = {}

ARGV.options do |opts|
    opts.on("-d",     "--delete",      "Delete the service") { 
     OPTIONS[:delete] = true }
    opts.on("-s",     "--start",       "Start the service") { 
     OPTIONS[:start] = true }
    opts.on("-x",     "--stop",        "Stop the service") { 
     OPTIONS[:stop] = true }
    opts.on("-i",     "--install",     "Install the service") { 
     OPTIONS[:install] = true }
    opts.on("-h",     "--help",        "Show this help message") { 
     puts opts; exit }
    opts.parse!
end

# Install the service.
if OPTIONS[:install]
    svc = Service.new
    svc.create_service do |s|
        s.service_name = kbserver_svc
        s.display_name = kbserver_name
        s.binary_path_name = 'c:\ruby\bin\ruby.exe ' + kbserver_prog
        # This is required for now - bug in win32-service
        s.dependencies = [] 
    end
    svc.close
    puts "KirbyBase Server service installed"
end    

# Start the service.
if OPTIONS[:start]
    Service.start(kbserver_svc)
    started = false
    while started == false
        s = Service.status(kbserver_svc)
        started = true if s.current_state == "running"
        break if started == true
        puts "One moment, " + s.current_state
        sleep 1
    end
    puts "KirbyBase Server service started"
end

# Stop the service.
if OPTIONS[:stop]
    begin
        Service.stop(kbserver_svc)
    rescue
    end    
    puts "KirbyBase Server service stopped"
end

# Delete the service.  Stop it first.
if OPTIONS[:delete]
    begin
        Service.stop(kbserver_svc)
    rescue
    end
    Service.delete(kbserver_svc)    
    puts "KirbyBase Server service deleted"
end

