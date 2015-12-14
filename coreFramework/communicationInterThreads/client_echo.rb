require 'celluloid/io'
require 'celluloid/autostart'

class ClientEcho
  include Celluloid::IO

  def initialize(socket)
    @socket = socket
    async.handle_incomming_messages
    sleep
  end

  private

  def handle_incomming_messages
    loop { puts "(ClientEcho) Received '%s' from server." % @socket.gets }
  end
end
