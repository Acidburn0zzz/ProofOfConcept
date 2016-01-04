require "socket"

# This doesn't employ Selector for now.

socket = TCPSocket.new("0.0.0.0", 4242)
