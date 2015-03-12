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
require 'logger'
require 'eventmachine'

#------------------------
#-- Variable Declaration
#------------------------
begin
    HOST = ARGV[0]
    PORT = ARGV[1]
rescue Exception => argException
    puts ">> Illegal Arguments"
    puts ">> Usage: ruby client.rb (serverIP serverPort)"
    exit
end

#Initialize log files
file = File.new('Server_EPOLL.log', 'w')
$logger = Logger.new(file)

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

        $logger.info('NEW_CONNECTION') { "  #{Socket.unpack_sockaddr_in(get_peername)}" }

        if $numberOfConnectedClients > $maxNumberOfClients
            $maxNumberOfClients = $numberOfConnectedClients
        end

   	end

   	#Occurs when receiving data
  	def receive_data(data)
        $numberOfClientRequests += 1
        send_data (data)
        $numberOfBytesSent += data.bytesize

        $logger.info('CLIENT_REQUEST') { " #{Socket.unpack_sockaddr_in(get_peername)}: #{$numberOfClientRequests}" }
        $logger.info('SENDING_DATA') { " #{Socket.unpack_sockaddr_in(get_peername)}: #{data.bytesize}" }

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
        puts "Echo server listening on #{HOST}:#{PORT}"
        EM.start_server HOST, 7000, EchoServer
        EM.start_server HOST, 8000, EchoServer 
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

    $logger.info('FINAL_RESULTS'){"------------------------------------------------"}
    $logger.info('FINAL_RESULTS'){"Maximum Number of Concurrent Clients: #{$maxNumberOfClients}"}
    $logger.info('FINAL_RESULTS'){"Total Number of Client Requests Received: #{$numberOfClientRequests}"}
    $logger.info('FINAL_RESULTS'){"Total Number of Bytes Sent: #{$numberOfBytesSent}"}
    $logger.info('FINAL_RESULTS'){"------------------------------------------------"}

    $logger.close
end