require 'thread'
require './client_ui'
require './client_echo'

require 'celluloid/io'
require 'celluloid/autostart'

class Core
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "*** Starting echo server on #{host}:#{port}"
    @server = Server.run(host, port)
    puts "(DEBUG)(Core) Server started."
    launch_ui("client_ui")
    puts "(DEBUG)(Core) UI started."
    loop { sleep 1 }
  end

  private

  # Connects a new socket to the server, initialize UI with the socket and then
  # call its #run() method inside a new thread
  #
  # @param [String] ui_name
  def launch_ui(ui_name)
    socket_ui = @server.init_socket("ui", ui_name)
    client_ui = ClientUI.new socket_ui
    puts "*** Lauching UI client"
    @thread_ui = Thread.new do
      puts "(DEBUG)(Core) Starting new thread in '%s'." % __callee__
      client_ui.run
    end
  end

  class Server
    include Celluloid::IO
    finalizer :shutdown

    def self.run(host, port)
      instance = new(host, port)
      instance.run
      instance
    end

    # Instantiate a new Server object, and a Celluloid::IO::TCPServer
    #
    # @param [String] host
    # @param [String] port
    def initialize(host, port)
      @host, @port = host, port
      @server = TCPServer.new(@host, @port)
      @conn_mngr = ConnectionManager.new
      @socket_ui, @socket_wr = nil
    end

    def run
      async.accept_loop
    end

    def shutdown
      @server.close if @server
    end

    # Instantiate a new TCPSocket, connect it to the server and then authentify
    # itself to the server.
    #
    # @param [String] role
    # @param [String] name
    # @return [Celluloid::IO::TCPSocket]
    def init_socket(role, name)
      puts "(DEBUG)(Core::Server#%s) Entering method." % __callee__
      key = @conn_mngr.expect(role)
      socket = TCPSocket.new(@host, @port)
      socket.puts hello_string(role, name, key)
      puts "(DEBUG)(Core::Server#%s) Leaving method." % __callee__
      socket
    end

    private

    def hello_string(role, name, key)
      %q{<role: "%s", name: "%s", key: "%s"/>} % [role, name, key]
    end

    def accept_loop
      puts "(DEBUG)(Core::Server#%s) Entering method." % __callee__
      loop do
        puts "(DEBUG)(Core::Server#%s) New loop round." % __callee__
        socket = @server.accept
        puts "(DEBUG)(Core::Server#%s) Just accepted a new connection." % __callee__
        role = @conn_mngr.verify!(socket)
        puts "(DEBUG)(Core::Server#%s) role of new socket: #{role}." % __callee__
        case role
        when "ui"
          puts "(DEBUG)(Core::Server#%s) New connection is an UI." % __callee__
          async.handle_ui_connection(socket)
        when "exec"
          puts "(DEBUG)(Core::Server#%s) New connection is an Exec." % __callee__
          async.handle_exec_connection(socket)
        else
          puts "(DEBUG)(Core::Server#%s) New connection has been regected." % __callee__
        end
      end
    end

    def handle_ui_connection(socket)
      puts "(DEBUG)(Core::Server#%s) Entering method." % __callee__
      loop do
        puts "(DEBUG)(Core::Server#%s) New loop round." % __callee__
        puts "(DEBUG)(Core::Server#%s) Wait readable." % __callee__
        socket.wait_readable
        puts "(DEBUG)(Core::Server#%s) Readable OK." % __callee__
        # maybe something is still on the socket...
        message = socket.gets
        puts "(DEBUG)(Core::Server#%s) Just got a message." % __callee__
        match = message.match /^\/(?<cmd>\w) (?<arg>.*)$/
        case match[:cmd]
        when "say"
          puts "(DEBUG)(Core::Server#%s) Command say." % __callee__
          puts "(CORE::Server) Received '%s' from UI." % match[:arg]
        when "launch"
          puts "(DEBUG)(Core::Server#%s) Command launch." % __callee__
          @thread_exec = Thread.new { ClientEcho.new @server.init_socket("exec", "echo") }
        when "echo"
          puts "(DEBUG)(Core::Server#%s) Command echo." % __callee__
          socket_echo = @conn_mngr.get("exec")
          next if socket_echo.nil?
          socket_echo.puts match[:arg]
        else
          puts "(DEBUG)(Core::Server#%s) Something else." % __callee__
        end
      end
    end

    def handle_exec_connection(socket)
    end

    class ConnectionManager
      def initialize
        @sockets = []
      end

      # Regiter a new pending connection
      #
      # @param [String] role
      # @param [String] key (optional)
      # @return [String] key
      def expect(role, key = keygen)
        @sockets << SocketStatus.new(role, key)
        key
      end

      # Close the socket if it was not expected
      #
      # @see #verify
      def verify!(new_socket)
        verify(new_socket) || new_socket.close
      end

      # Verify if a new socket was expected and set it used if it pass the verification
      #
      # @param [Celluloid::IO::TCPSocket] new_socket
      # @return [Symbole] role of the socket, or nil if access not granted
      def verify(new_socket)
        message = new_socket.gets
        match = message.match(/^<(?:(?:.*role: "(?<r>.{1,16})")|(?:.*name: "(?<n>.{1,32})")|(?:.*key: "(?<k>.{8})")){3}\/>$/)
        @sockets.inject(nil) { |role, s| role ||= s.set_used(match[:r], match[:k], match[:n], new_socket) } if match
      end

      private

      def keygen
        rand(36**8).to_s(36)
      end

      class SocketStatus
        def initialize(role, key)
          @role, @key = role, key
          @status = :pending
          @socket, @name = nil
        end

        # Check if the status of the instance is :pending and if the parameters
        # are matching the attributes
        #
        # @param [String] role
        # @param [String] key
        # @param [String] name, not checked for now
        # @return [Boolean]
        def match_pending?(role, key, name)
          role_ok?(role) && key_ok?(key) && pending?
        end

        # If #match_pending? returns true, update the instance and set the
        # status to :used
        #
        # @see #match_pending?
        #
        # @param [String] role
        # @param [String] key
        # @param [String] name
        # @return [Symbole] the role or nil if not matching
        def set_used(role, key, name, socket)
          if self.match_pending?(role, key, name)
            update(:used, socket)
            @role
          end
        end

        private

        def update(status, socket)
          @status, @socket = status, socket
          nil
        end

        def pending?; @status == :pending end
        def role_ok?(r) @role == r end
        def key_ok?(k) @key == k end
      end # !SocketStatus
    end # !ConnectionManager
  end # !Server
end # !Core

Core.new 'localhost', 4321
