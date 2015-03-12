require "socket"
require "logger"
require 'thread'
require 'thwait'

require_relative "ServerFunctions.rb"

#------------------------
#-- Variable Declaration
#------------------------
begin
	READBUFFERSIZE = Integer(ARGV[0])
	$configFile = ARGV[1]
rescue Exception => argException
  	puts ">> Illegal Arguments"
  	puts ">> Usage: ruby forwarder.rb (readBufferSize configFile)"
  	exit
end

#contains all the variables needed to forward a packet from one socket to another
forwardingPairs = Array.new{Array.new(3)}

#Parse the log file for all the IP:PORT combinations, and add them to the forwardingPairs Array
File.foreach($configFile).grep /FORWARD/ do |line|
	forwardingInfo = line.split(/[ ,:]/)
	forwardingPairs.push([forwardingInfo[1], forwardingInfo[2], forwardingInfo[3].strip!])
end


#Iterate through every forwarding combination
for i in 0..forwardingPairs.length - 1 do
	
	#forwardingPairs[i][0] => listeningPort // The port which listens for connections
	#forwardingPairs[i][1] => serverIP 		// IP of the server to which you are sending to
	#forwardingPairs[i][2] => serverPort 	// Port of the server to which you are sending to

	#Start a thread for every TCP Server Accepting Socket 
	threads = Thread.new(forwardingPairs[i][0], forwardingPairs[i][1], forwardingPairs[i][2]) do |listeningPort_threadlocal, serverIP_threadlocal, serverPort_threadlocal|


		puts "Starting Server on Port #{listeningPort_threadlocal}"
		#initialize TCP Server Accepting Socket
		clientListenerSocket = TCPServer.new( listeningPort_threadlocal )
		clientListenerSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

		#This infinite loop allows 
		while 1

			Thread.new(clientListenerSocket.accept) do |clientTransmitterSocket|

				puts "new connection"
				serverTransmitterSocket = TCPSocket.open(serverIP_threadlocal, serverPort_threadlocal)
				puts "connected to server"

				while 1

					sentMessage = forwardMessage(clientTransmitterSocket, serverTransmitterSocket, READBUFFERSIZE)
					puts "rx from client tx to server"
					sentMessage = forwardMessage(serverTransmitterSocket, clientTransmitterSocket, READBUFFERSIZE)
					puts "rx from server tx to client"

					#Client kills connection
					if clientTransmitterSocket.eof?


						clientTransmitterSocket.close
						serverTransmitterSocket.close
						puts "closed connection"


						break #break here to leave thread block, hence ending thread
					end #end if

				end #end while 1

			end #end thread 

		end


	end
end

ThreadsWait.all_waits(*threads)
