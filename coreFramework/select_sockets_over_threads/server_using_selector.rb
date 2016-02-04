require "socket"
require "./selector"

activ_sockets = []

server = TCPServer.new("0.0.0.0", 4242)
selector = Selector.new(5)


# attaching the io to the selector
server_stream = selector.register_io server

# disabling readability of the stream since it's a server
server_stream.is_accepting!

# configuring the callback used when the stream of the server accepts a new one
server_stream.callback_for_read(selector) do |server_stream, selector|
  puts "A peer connected"
  peer, _ = server_stream.io.accept
  activ_sockets << peer

  # attaching the new io to the selector
  peer_stream = selector.register_io peer

  # configuring the callback used after the stream read something
  peer_stream.callback_for_read do |peer_stream|
    # retrieving message on the socket
    message = peer_stream.dequeue
    puts "Received '%s' from the client." % message

    # sending back the message
    peer_stream.queue message
  end

  # configuring the callback used after the stream write something
  peer_stream.callback_for_write do |peer_stream|
    puts "Just wrote a message."
  end

  # configuring the callback used after the stream is closed
  peer_stream.callback_for_close do |peer_stream|
    puts "A peer closed its connection"
    activ_sockets.delete peer_stream.io
  end

  # starting the monitoring of the new stream
  peer_stream.listen :read
end

# starting the monitoring of the server's stream
server_stream.listen(:read)

puts "Ok, looping now"
# loop
selector.loop() do |selector|
  puts nil, nil, nil, nil, "New round loop.", "Activ sockets are:", activ_sockets
  puts "Selector's status:", selector.status # DEBUG
end
