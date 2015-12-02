#!/usr/bin/ruby

require 'celluloid/io'
require 'celluloid/autostart'

HOST = 'localhost'
PORT = 4321

class EchoServer
	include Celluloid::IO
	finalizer :shutdown

  def initialize(host, port)
    puts "*** Starting echo server on #{host}:#{port}"
    @server = TCPServer.new(host, port)
    async.run
  end
  
  def shutdown
    @server.close if @server
  end
  
  def run
    loop { async.handle_connection @server.accept }
  end
  
  def handle_connection(socket)
    _, port, host = socket.peeraddr
    puts "*** Received connection from #{host}:#{port}"
    loop {
      msg = socket.readpartial(4096)
      puts "Client said: #{msg}"
      socket.write "Server said: #{msg}" 
    }
  rescue EOFError
    puts "*** #{host}:#{port} disconnected"
    socket.close
  end
end


if __FILE__ == $0
  server = EchoServer.new(HOST, PORT)
  loop do
  end
end
