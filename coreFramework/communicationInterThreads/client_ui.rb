require 'celluloid/io'
require 'celluloid/autostart'

class ClientUI
  include Celluloid::IO

  def initialize(socket)
    puts "(DEBUG)(ClientUI) Initializing new instance."
    @socket = socket
    puts "(DEBUG)(ClientUI) here."
    async.handle_incomming_messages
    puts "(DEBUG)(ClientUI) Initializing new instance done."
    text_loop
  end

  private

  def text_loop
    puts "(DEBUG)(ClientUI) Entering method '%s'." % __callee__
    loop do
      puts "(DEBUG)(ClientUI) New loop round in '%s'." % __callee__
      write gets
    end
  end

  def write(message)
    puts "(DEBUG)(ClientUI) Entering method '%s'." % __callee__
    async.handle_outgoing_messages message
  end

  def handle_outgoing_messages(message)
    puts "(DEBUG)(ClientUI) Entering method '%s'." % __callee__
    @socket.puts message
  end

  def handle_incomming_messages
    puts "(DEBUG)(ClientUI) Entering method '%s'." % __callee__
    loop { puts "(ClientUI) Received '%s' from server." % @socket.gets }
  end
end
