require 'celluloid/io'
require 'celluloid/autostart'

class ClientUI
  include Celluloid::IO

  def initialize(socket)
    puts "(DEBUG)(ClientUI#%s) Initializing new instance." % __callee__
    @socket = socket
    @socket.wait_writable
    puts "(DEBUG)(ClientUI#%s) Initializing new instance done." % __callee__
    self
  end

  def run
    puts "(DEBUG)(ClientUI#%s) here." % __callee__
    # async.handle_incomming_messages
    puts "(DEBUG)(ClientUI#%s) Initializing new instance done." % __callee__
    text_loop    
  end

  private

  def text_loop
    puts "(DEBUG)(ClientUI#%s) Entering method." % __callee__
    loop do
      puts "(DEBUG)(ClientUI#%s) New loop round." % __callee__
      write gets
    end
  end

  def write(message)
    puts "(DEBUG)(ClientUI#%s) Entering method." % __callee__
    # async.handle_outgoing_messages message
    handle_outgoing_messages message
  end

  def handle_outgoing_messages(message)
    puts "(DEBUG)(ClientUI#%s) Entering method." % __callee__
    puts "(DEBUG)(ClientUI#%s) wait_writable." % __callee__
    @socket.wait_writable
    puts "(DEBUG)(ClientUI#%s) wait_writable OK." % __callee__
    @socket.puts message
    puts "(DEBUG)(ClientUI#%s) Message wrote." % __callee__
  end

  def handle_incomming_messages
    puts "(DEBUG)(ClientUI#%s) Entering method." % __callee__
    @socket.wait_readable
    puts "(DEBUG)(ClientUI#%s) wait_readable." % __callee__
    loop do
      puts "(DEBUG)(ClientUI#%s) wait_readable OK." % __callee__
      puts "(ClientUI) Received '%s' from server." % @socket.gets
    end
  end
end
