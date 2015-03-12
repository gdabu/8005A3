#/*---------------------------------------------------------------------------------------
#--	SOURCE FILE: 	ServerFunctions.rb - Consists of all the functions needed for basic 
#--										 socket functions
#--
#--	PROGRAM:		ServerFunctions.rb
#--					
#--	FUNCTIONS:		Mainly just a place holder for all client function functions
#--
#--	DATE:			February 23, 2015
#--
#--	DESIGNERS:		GEOFF DABU
#--	PROGRAMMERS:	GEOFF DABU, CHRIS HUNTER
#--
#--	NOTES: 			There is no need to run this file, this file is mainly required by 
#--						- Server_SELECT.rb 
#--						- Server_MT.rb
#---------------------------------------------------------------------------------------*/

#/*---------------------------------------------------------------------------------------
#-- FUNCTION: 		acceptNewConnectionNonBlock
#--
#-- NOTES: 			accepts a new socket connection, from @arg [serverSocket] and adds it 
#--					to @arg [connections] - a list of all current client connections. The
#-- 				total number of connections are then printed out.
#--					The accept call is non blocking.
#--
#-- USED IN: 		Server_SELECT.rb
#---------------------------------------------------------------------------------------*/
def acceptNewConnectionNonBlock(serverSocket, connections)
	newSock = serverSocket.accept_nonblock() 
	connections.push( newSock )
	puts connections.length
	return newSock
end

#/*---------------------------------------------------------------------------------------
#-- FUNCTION: 		acceptNewConnectionBlock
#--
#-- NOTES: 			accepts a new socket connection, from @arg [serverSocket] and adds it 
#--					to @arg [connections] - a list of all current client connections. The
#-- 				total number of sockets in @arg [connections] is then printed out.
#--					The accept call is blocking.
#--
#-- USED IN: 		N/A
#---------------------------------------------------------------------------------------*/
def acceptNewConnectionBlock(serverSocket, connections)
	newSock = serverSocket.accept() 
	connections.push( newSock )
	puts connections.length
	return newSock
end

#/*---------------------------------------------------------------------------------------
#-- FUNCTION: 		killConnection
#--
#-- NOTES: 			Takes the connected socket @arg [clientSocket] and closes the connection.
#--					The socket @arg [clientSocket] is then deleted from @arg [connections]
#--					- the list of all current client connections. The total number of sockets
#--					in @arg [connections] is then printed out.
#--
#-- USED IN: 		Server_SELECT.rb
#--					Server_MT.rb
#---------------------------------------------------------------------------------------*/
def killConnection( clientSocket, connections )
	clientSocket.close
	connections.delete(clientSocket)
	puts connections.length
end

#/*---------------------------------------------------------------------------------------
#-- FUNCTION: 		echoMessage
#-- 
#-- NOTES: 			Takes the connected socket @arg [clientSocket] and reads from the input
#--					buffer, followed by writing to the output buffer. The received data is
#--					then printed out.
#--
#-- USED IN: 		Server_SELECT.rb
#--					Server_MT.rb
#---------------------------------------------------------------------------------------*/
def echoMessage( clientSocket, readBufferSize )
	data = clientSocket.read( readBufferSize )
	clientSocket.write data
	clientSocket.flush
	#puts (data)
	return data
end


def forwardMessage( readSocket, writeSocket, readBufferSize )
	data = readSocket.read( readBufferSize )
	writeSocket.write data
	writeSocket.flush
	puts (data)
	return data
end


def forwardMessage_nonblock( readSocket, writeSocket, readBufferSize )
	data = readSocket.recv_nonblock(readBufferSize)
	if(data.length != 0) then 
		writeSocket.write data
		writeSocket.flush
		puts (data)
	end
	return data
end
