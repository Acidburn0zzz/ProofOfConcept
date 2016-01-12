require "socket"
require "./selector"

keep_running = true
activ_sockets = []

server = TCPServer.new("0.0.0.0", 4242)
selector = Selector.new(5)


# attaching the io to the selector
server_stream = selector.register_io server

# disabling readability of the stream since it's a server
server_stream.cannot_read!

# configuring the stream of the server for reads
server_stream.callback_for_read(selector) do |server_stream, selector|
  puts "A peer connected"
  peer, _ = server_stream.io.accept
  activ_sockets << peer

  # attaching the io to the selector
  peer_stream = selector.register_io peer

  # configuring the stream of the peer for reads
  peer_stream.callback_for_read do |peer_stream|
    # retrieving message on the socket
    message = peer_stream.dequeue
    puts "Received '%s' from the client." % message

    # sending back the message
    peer_stream.queue message
  end

  # configuring the stream of the peer for writes
  peer_stream.callback_for_write do |peer_stream|
    puts "Just wrote a message."
    # @buffer_of_writes.each { |m| peer_stream.io.puts(m) }
    # peer_stream.stop_listening(:write)
    # It's not the right way to do it...
    # This closure is supposed to be called after a write, not to do it :S
    # Rename the method from "on_" to "after_" and create a new one
    # "on_writeable" prenant un deuxieme parametre le message le plus vieux ?
  end

  # configuring the stream of the peer for closes
  peer_stream.callback_for_close do |peer_stream|
    puts "A peer closed its connection"
    activ_sockets.delete peer_stream.io
  end

  # starting the monitoring of the stream
  peer_stream.listen :read
end

# starting the monitoring of the stream
server_stream.listen(:read)

puts "Ok, looping now"
# loop
selector.loop(keep_running) do |selector|
  puts nil, nil, nil, nil, "New round loop.", "Activ sockets are:", activ_sockets
  puts "Selector's status:", selector.status
end
