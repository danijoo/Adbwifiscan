#!/usr/bin/env ruby
require 'ADB'
require 'ipaddr'
require 'thread'

ip_range = IPAddr.new(ARGV[0]).to_range.to_a 
abort "Please pass an ip range as first arg" unless ip_range

port = ARGV[1].to_i
port = 5555 if port == 0
timeout = 2

if(ip_range.size == 1)
	puts "Scanning for device with IP #{ip_range.first.to_s}:#{port}"
else
	puts "Scanning for devices in IP range #{ip_range.first.to_s} - #{ip_range.last.to_s}, Port: #{port}"
end

puts "Starting server"
adb = Class.new { include ADB }.new
begin
	adb.start_server
rescue
	puts "Cant start server. Already started?"
end

puts "Connected devices: #{adb.devices}"
puts "Scan started..."

queue = Queue.new
ip_range.each { |ip| queue << ip}
threads = Array.new

# (queue.size / 10).times do
	# threads << Thread.new do
		begin
			ip = queue.pop(true)
			print "#{ip}\r"
			adb.connect(ip.to_s, port, timeout)
			puts "Device found! #{ip}"
		rescue ThreadError
			nil
		rescue
			retry	
		end	
	# end
# end
puts "\nScan complete"
puts "Connected devices: #{adb.devices}"

