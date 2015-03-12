require "socket"
require "logger"
require_relative "ServerFunctions.rb"

#------------------------
#-- Variable Declaration
#------------------------
begin
	HOST = ARGV[0]
	PORT = ARGV[1]
	READBUFFERSIZE = Integer(ARGV[2])
	$configFile = ARGV[3]
rescue Exception => argException
  	puts ">> Illegal Arguments"
  	puts ">> Usage: ruby forwarder.rb (serverIP serverPort readBufferSize configFile)"
  	exit
end

descriptors = []
listenerSockets = Array.new{Array.new(2)}
$pairArray = Array.new{Array.new(3)}

#fill out the pair array
File.foreach($configFile).grep /FORWARD/ do |line|
	array = line.split(/[ ,:]/)
	$pairArray.push([array[1], array[2], array[3].strip!])
end


#listen on ports specifed from config file
$pairArray.each { |srcPort|
	puts srcPort[2].length
	listenSocket = TCPServer.new( '127.0.0.1', srcPort[0] )
	listenSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

	senderSocket = TCPSocket.open( srcPort[1], srcPort[2] )
	#senderSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

	puts "gfdgfhdh"
	listenerSockets[0].push(listenSocket)
	listenerSockets[1].push(senderSocket)
	puts "listneer socket:: #{listenerSockets}"
}

mutex = Mutex.new
STDOUT.sync = true





#Initialize log files

#----------------
#-- Server Entry 
#----------------
puts "Echo server listening on #{HOST}:#{PORT}"


begin

#for each client side listener socket create a new thread
listenerSockets.each { |clientsock,serversock|
	Thread.new do
		#continuously try to accept new connections on that socket
		while 1
			#create a thread for every new connection
   			Thread.new(clientsock.accept) do |clientSocket| 
   				#if we created a new connection, open a socket with the corresponding forward IP:port
   				#serverSocket = TCPSocket.open(sock[1])

				while 1

					sentMessage = forwardMessage(clientSocket, serversock, READBUFFERSIZE)
					sentMessage = forwardMessage(serversock, clientSocket, READBUFFERSIZE)
					
				end
			end
		end
	end
}




rescue Exception => e
	puts ">> #{e.message}"
	puts ">> Server Failure"
end #end begin rescue ensure





