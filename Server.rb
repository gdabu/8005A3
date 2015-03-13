#/*---------------------------------------------------------------------------------------
#-- SOURCE FILE:  Server_EPOLL.rb - A simple TCP server using the eventmachine 
#--               library with epoll
#--
#-- PROGRAM:      Server_EPOLL.rb
#--               ruby Server_EPOLL.rb
#--
#-- FUNCTIONS:    Select Echo Server
#--
#-- DATE:         February 23, 2015
#--
#-- DESIGNERS:    GEOFF DABU
#-- PROGRAMMERS:  GEOFF DABU, CHRIS HUNTER
#--
#-- NOTES:        This server uses eventmachine (with epoll) library to read and write 
#--               messages to and from the client.
#--
#-- REQUIRED:     eventmachine
#--               ruby gem eventmachine
#--
#-- CLIENT: client.rb
#---------------------------------------------------------------------------------------*/
require 'rubygems'
require 'eventmachine'

#------------------------
#-- Variable Declaration
#------------------------
begin
    HOST = ARGV[0]
    $configFile = ARGV[1]
rescue Exception => argException
    puts ">> Illegal Arguments"
    puts ">> Usage: ruby Server.rb (serverIP configFile)"
    exit
end

if ARGV.length != 2
    puts ">> Illegal Arguments"
    puts ">> Usage: ruby Server.rb (serverIP configFile)"
    exit
end

#contains all the variables needed to forward a packet from one socket to another
forwardingPairs = Array.new{Array.new(3)}

File.foreach($configFile).grep /FORWARD/ do |line|
    forwardingInfo = line.split(/[ ,:]/)
    forwardingPairs.push([forwardingInfo[1], forwardingInfo[2], forwardingInfo[3].strip!])
end


#/*---------------------------------------------------------------------------------------
#-- MODULE:       EchoServer
#--
#-- NOTES:        An echo server which is used with event machine
#--
#-- DATE:         February 23, 2015
#--
#-- DESIGNERS:    GEOFF DABU
#-- PROGRAMMERS:  GEOFF DABU, CHRIS HUNTER
#--
#---------------------------------------------------------------------------------------*/
module EchoServer   	

    $maxNumberOfClients = 0
    $numberOfConnectedClients = 0
    $numberOfClientRequests = 0
    $numberOfBytesSent = 0
   	
    #Occurs when clients connect
   	def post_init
      	puts $numberOfConnectedClients += 1


        if $numberOfConnectedClients > $maxNumberOfClients
            $maxNumberOfClients = $numberOfConnectedClients
        end

   	end

   	#Occurs when receiving data
  	def receive_data(data)
        $numberOfClientRequests += 1
        send_data (data)
        $numberOfBytesSent += data.bytesize


        puts (data)
  	end

  	#Occurs when client disconnects
  	def unbind
    	puts $numberOfConnectedClients -= 1
   	end

end #end module EchoServer



#----------------
#-- Server Entry 
#----------------

#Set eventmachine to use EPOLL
EM.epoll

# Increase the number of file descriptors
new_size = EM.set_descriptor_table_size( 1000000 )
puts "Max number of File Descriptors: #{EM.set_descriptor_table_size}"

begin
    # Start Event Machine 
    EM.run { 
        for i in 0..forwardingPairs.length - 1 do
            EM.start_server HOST, forwardingPairs[i][2], EchoServer 
            puts "Echo server listening on #{HOST}:#{forwardingPairs[i][2]}"
        end
    }

rescue Exception => e
    puts ">> #{e.message}"
    puts ">> Server Failure"
ensure
    puts "------------------------------------------------"
    puts "Maximum Number of Concurrent Clients: #{$maxNumberOfClients}"
    puts "Total Number of Client Requests Received: #{$numberOfClientRequests}"
    puts "Total Number of Bytes Sent: #{$numberOfBytesSent}"
    puts "------------------------------------------------"
end