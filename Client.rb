#/*---------------------------------------------------------------------------------------
#--	SOURCE FILE: 	client.rb - A simple multithreaded echo client 
#--
#--	PROGRAM:		client.rb
#--					ruby client.rb
#--
#--	FUNCTIONS:		Select Echo Client
#--
#--	DATE:			February 23, 2015
#--
#--	DESIGNERS:		GEOFF DABU
#--	PROGRAMMERS:	GEOFF DABU, CHRIS HUNTER
#--
#--	NOTES: 			A simple multithreaded echo client		
#--
#--	Servers: 		Server_EPOLL.rb
#--					Server_SELECT.rb
#--					Server_MT.rb		
#---------------------------------------------------------------------------------------*/
require "socket"
require 'thread'
require 'thwait'

begin
	HOST = ARGV[0]
	PORT = ARGV[1]
	TOTALCLIENTS = Integer(ARGV[2])
	TOTALMESSAGES = Integer(ARGV[3])
	MESSAGESIZEBYTES = Integer(ARGV[4])
	message = ""
rescue Exception => argException
	puts ">> Illegal Arguments"
	puts ">> Usage: ruby client.rb (serverIP serverPort totalClients totalMessages messageSize)"
	exit
end

$currentNumberOfConnections = 0
threads = []
STDOUT.sync = true

#Generate a message w/ a length equaling the amount specified by the user
for c in 0...MESSAGESIZEBYTES do
	message << "g"
end

#----------------
#-- Client Entry 
#----------------
begin
while $currentNumberOfConnections < TOTALCLIENTS
	
	threads = Thread.new($currentNumberOfConnections += 1) do |currentConnectionNumber_threadLocal|
			
			serverSocket = TCPSocket.open(HOST, PORT)

			puts currentConnectionNumber_threadLocal
			
			startTime = Time.new

			#Start sending/receiving messages
			#messageNumber = 0
			TOTALMESSAGES.times do
				serverSocket.write( message )
				line = serverSocket.read( message.bytesize )

				STDOUT.puts line
			end

			#calculate the average RTT for the sent messages
			totalRTT = Time.new - startTime
			avgRTT = totalRTT / TOTALMESSAGES
			
			#sleep to prevent thread from closing the connection
			sleep
			#serverSocket.close
	end
	sleep(0.005)
end

STDIN.gets
puts "Connections Complete"
ThreadsWait.all_waits(*threads)

rescue Exception => e 
	puts "Exception:: " + e.message + "\n"
	exit
end

