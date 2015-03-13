require 'rubygems'
require 'eventmachine'

module VirtualPort
    attr_accessor :sender

    def initialize *args
        super

        @sender = args.first
        @sender.create_client(self)
    end

    def receive_data data
        @sender.send_data(data)
    end
end

module Server
    attr_accessor :client
    @ServerIP
    @ServerPort

    def initialize *args
        super
        @ServerIP = args[0]
        @ServerPort = args[1]
    end

    def create_client(client)
        @client = client
    end

    def post_init
        EM.connect @ServerIP, @ServerPort, VirtualPort, self
    end

    def receive_data data
        if(@client)
            @client.send_data(data)
        end
    end
end

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

EM.epoll

EM.run {
    for i in 0..forwardingPairs.length - 1 do
        EM.start_server HOST, forwardingPairs[i][0], Server, forwardingPairs[i][1], forwardingPairs[i][2]
        puts "Echo server listening on #{HOST}:#{forwardingPairs[i][0]}"
    end
}