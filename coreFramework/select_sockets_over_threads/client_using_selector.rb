require "socket"
require "./selector"

keep_running = true

client = TCPSocket.new("0.0.0.0", 4242)
selector = Selector.new(5)

messages_to_send = [
  "Hello world!",
  "This is the second message to be displayed",
  "And not the last",
  "Because there's two more after this one",
  "Next message is the last one",
  "Bye world!"
]

# attaching the io to the selector
client_stream = selector.register_io client

# configuring the stream of the client for reads
client_stream.callback_for_read do |client_stream|
  message = client_stream.dequeue
  puts "Received '%s' from server." % message
end

client_stream.callback_for_write do |client_stream|
  puts "Just wrote a message"
  # @buffer_for_writes.each { |m| client_stream.io.puts(m) }
  # client_stream.stop_listening :read
end

client_stream.callback_for_close do |client_stream|
  puts "Connection closed by the server"
  exit
end

# starting the monitoring of the stream
client_stream.listen :read

count = 0
selector.loop(keep_running, client_stream) do |_, client_stream|
  puts nil, "New loop round!"
  count += 1
  puts "#{count} % 2 = #{count % 2}"
  if (count % 2).zero?
    message = messages_to_send.shift
    client_stream.queue message
  end
  puts "End of loop round"
end
