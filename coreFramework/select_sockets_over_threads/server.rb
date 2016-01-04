require "socket"

# This doesn't employ Selector for now.

up = true
server = TCPServer.open("0.0.0.0", 4242)
puts "server: #{server}, class: #{server.class.name}"

fds_read = [server, STDIN]
fds_write = []
fds_error = []

while up
  puts nil, "new loop round"

  puts "fds_read: [#{fds_read.join(",")}]"
  puts "fds_write: [#{fds_write.join(",")}]"
  events_all = select(fds_read, fds_write, [], 5)
  puts "events_all: #{events_all}"

  if events_all.nil?
    puts "no event"

  else
    events_read, events_write, events_error = events_all

    events_error.each_with_index do |client, index|
      puts "events_error"
      puts "client: #{client}, index: #{index}"
    end

    events_read.each_with_index do |client, index|
      puts "events_read"
      puts "client: #{client}, index: #{index}"
      if client == server
        puts "server's fd concerned, we got a new peer"
        new_peer, _ = server.accept
        fds_read << new_peer
        fds_error << new_peer

      elsif client.eof?
        puts "client closed the connection"
        fds_read -= [client]
        fds_write -= [client]
        client.close

      else
        puts "Got something to read"
        puts "client: #{client}"
        puts "read '%s' from %s", client.gets, client.inspect
      end

    end
  end

end
