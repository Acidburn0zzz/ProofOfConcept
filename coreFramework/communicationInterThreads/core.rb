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
    loop{ sleep 1 }
  end

  private

  def launch_ui(ui_name)
    socket_ui = @server.init_socket("ui", ui_name)
    puts "*** Lauching UI client"
    @thread_ui = Thread.new { ClientUI.new socket_ui }
  end

  class Server
    include Celluloid::IO
    finalizer :shutdown

    def self.run(host, port)
      instance = new(host, port)
      instance.run
      instance
    end

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

    def init_socket(role, name)
      puts "(DEBUG)(Core::Server) Entering method '%s'." % __callee__
      key = @conn_mngr.expect(role)
      socket = TCPSocket.new(@host, @port)
      socket.puts hello_string(role, name, key)
      puts "(DEBUG)(Core::Server) Leaving method '%s'." % __callee__
      socket
    end

    private

    def hello_string(role, name, key)
      %q{<role: "%s", name: "%s", key: "%s"/>} % [role, name, key]
    end

    def accept_loop
      puts "(DEBUG)(Core::Server) Entering method '%s'." % __callee__
      loop do
        puts "(DEBUG)(Core::Server) New loop round in '%s'." % __callee__
        socket = @server.accept
        puts "(DEBUG)(Core::Server) Just accepted a new connection in '%s'." % __callee__
        case @conn_mngr.role_of(socket)
        when "ui"
          puts "(DEBUG)(Core::Server) New connection is an UI in '%s'." % __callee__
          async.handle_ui_connection(socket)
        when "exec"
          puts "(DEBUG)(Core::Server) New connection is an Exec in '%s'." % __callee__
          async.handle_exec_connection(socket)
        end if @conn_mngr.verify!(socket)
      end
    end

    def handle_ui_connection(socket)
      puts "(DEBUG)(Core::Server) Entering method '%s'." % __callee__
      loop do
        puts "(DEBUG)(Core::Server) New loop round in '%s'." % __callee__
        message = socket.gets
        puts "(DEBUG)(Core::Server) Just got a message in '%s'." % __callee__
        match = message.match /^\/(?<cmd>\w) (?<arg>)$/
        case match[:cmd]
        when "say"
          puts "(CORE) Received '%s' from UI." % match[:arg]
        when "launch"
          @thread_exec = Thread.new { ClientEcho.new @server.init_socket("exec", "echo") }
        when "echo"
          socket_echo = @conn_mngr.get("exec")
          next if socket_echo.nil?
          socket_echo.puts match[:arg]
        end
      end
    end

    def handle_exec_connection(socket)
    end

    class ConnectionManager
      def initialize
        @sockets = []
      end

      def expect(role, key = keygen)
        raise unless ["ui", "exec"].include? role
        @sockets << SocketStatus.new(role, key)
        key
      end

      def verify!(new_socket)
        res = !(new_socket.close unless verify(new_socket))
        puts "(DEBUG)(Core::Server) Result is '#{res}' in '%s'." % __callee__
        res
      end

      def verify(new_socket)
        message = new_socket.gets
        match = message.match(/^<(?:(?:.*role: "(?<r>.{1,16})")|(?:.*name: "(?<n>.{1,32})")|(?:.*key: "(?<k>.{8})")){3}\/>$/)
        match && @sockets.find do |s|
          s.role_ok?(match[:r]) && s.key_ok?(match[:k]) && s.pending?
        end
      end

      def get(role, name = nil)
        socket_status = @sockets.find { |s| s.role_ok?(role) && !s.pending? }
        socket_status.socket if socket_status
      end

      def role_of(socket)
        socket_status = @sockets.find { |s| s.socket == socket }
        socket_status.role if socket_status
      end

      private

      def keygen
        rand(36**8).to_s(36)
      end

      class SocketStatus
        attr_reader :role, :key
        attr_reader :status, :name
        attr_reader :socket

        def initialize(role, key)
          @role, @key = role, key
          @status = :pending
          @socket, @name = nil
        end

        def pending?; @status == :pending end
        def role_ok?(r) @role == r end
        def key_ok?(k) @key == k end
      end # !SocketStatus
    end # !ConnectionManager
  end # !Server
end # !Core

Core.new 'localhost', 4321
