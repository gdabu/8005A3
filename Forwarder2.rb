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

    def initialize *args
        super
    end

    def create_client(client)
        puts client
        @client = client
    end

    def post_init
        EM.connect "localhost", 2000, VirtualPort, self
    end

    def receive_data data
        if(@client)
            @client.send_data(data)
        end
    end
end

EM.epoll

EM.run {
    puts "starting server"
    EM.start_server "localhost", 2222, Server
}