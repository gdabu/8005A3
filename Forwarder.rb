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
rescue Exception => argException
  	puts ">> Illegal Arguments"
  	puts ">> Usage: ruby forwarder.rb (serverIP serverPort readBufferSize)"
  	exit
end

descriptors = []
serverSocket = TCPServer.new( PORT )
serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
mutex = Mutex.new
STDOUT.sync = true

forwardInfo1 = [8005, 127.0.0.1, 8500]
forwardInfo2 = [8006, 127.0.0.1, 8600]
forwardInfo3 = [8007, 127.0.0.1, 8700]

forwardPairs 

#Initialize log files

#----------------
#-- Server Entry 
#----------------
puts "Echo server listening on #{HOST}:#{PORT}"

begin


#client disconnects when thread dies
while 1
	#create a thread for every new connection
   	Thread.new(serverSocket.accept) do |clientSocket| 
		
		descriptors.push(clientSocket)
		puts descriptors.length

		puts "geoff"
		serverSocket = TCPSocket.open("127.0.0.1", 8006)
		puts "geoff1"

		while 1

			sentMessage = forwardMessage(clientSocket, serverSocket, READBUFFERSIZE)
			sentMessage = forwardMessage(serverSocket, clientSocket, READBUFFERSIZE)
			
			#Client kills connection
			if clientSocket.eof?
				#killConnection is put into a mutex so that disconnections are made 1-by-1
				mutex.synchronize do
					killConnection( clientSocket, descriptors )
				end
				break #break here to leave thread block, hence ending thread
			end #end if
	    end #end while
    end #end connection
end #end 

rescue Exception => e
	puts ">> #{e.message}"
	puts ">> Server Failure"
end #end begin rescue ensure





