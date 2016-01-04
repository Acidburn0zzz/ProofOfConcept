require "thread"

class Selector
  MONITORABLE_EVENT_TYPES = [:read, :write]

  def initialize(timeout = 1)
    @streams = []
    @timeout = timeout
    MONITORABLE_EVENT_TYPES.each do |event_type|
      self.instance_variable_set "@looking_to_#{event_type}", []
    end
  end

  # Creates a new stream from the IO and add it to the selector
  #
  # @param [IO] io
  # @return [Selector::Stream] the created one, or nil if already registered
  def register_io(io)
    unless find_stream_from_io(io)
      stream = Stream.new(io, self)
      @streams << stream
      stream
    end
  end

  # Update the way to listen at events for a stream
  #
  # @param [Selector::Stream] stream
  # @param [Array] *args
  # @example listen(stream, :write)
  #  will monitor 'write' events
  # @example listen(stream, read: false, :write)
  #  will monitor 'write' events but un-monitor 'read' events
  def listen(stream, *args)
    unless @streams.include? stream
      raise "Stream not registered for this selector."
    end

    args.each do |arg|
      event_type, status = (arg.kind_of?(Hash) ? arg.flatten : [arg, true])
      ensure_valid_event_type!(event_type)
      if status # monitor it
        # ... unless already done
        unless stream_listening?(stream, event_type)
          looking_to_(event_type) << stream.io
        end
      else # un-monitor it
        looking_to_(event_type).delete stream.io
      end
    end
    nil
  end

  # Loop until the first value passed is evaluated to false (or nil)
  # over the 'select' method, calling the given block and trigger the callbacks
  # associated to the registered streams in case of monitored events happen.
  #
  # @param [Boolean] running condition for the loop
  #  Passed in the same array of the optional parameters, the original variable
  #  value is used every round since arrays are passed by reference.
  # @param [Array] *args passed as parameters to the block
  # @param [Lambda] block (optional) first parameter sent is the stream
  def loop(*args, &block)
    return if args.size.zero? || (block_given? && block.arity.zero?)

    while args.first
      all_events = select(@looking_to_read, @looking_to_write, [], @timeout)
      # if events are registered
      unless all_events.nil?
        # for every types of event monitored
        read_events, write_events = all_events

        # iterates over the ios that received events and call the
        # associated callback

        read_events.each do |io|
          stream = find_stream_from_io(io)
          action = stream.eof? ? :close : :read
          stream.got(action)
        end

        write_events.each do |io|
          stream = find_stream_from_io(io)
          action = stream.eof? ? :close : :write
          stream.got(action)
        end
      end

      yield(stream, args[1..-1]) if block_given?
    end

    nil
  end

  # TODO: comment, add buffers, use constant CALLBACKABLE_EVENTS
  #
  class Stream
    CALLBACKABLE_EVENTS = (Selector::MONITORABLE_EVENT_TYPES << :close).uniq

    attr_reader :io

    def initialize(io, selector)
      @on_read, @on_write, @on_close = nil
      @io = io
      @selector = selector
    end

    # Define the behavior to adopt on an event
    #
    # @param [Symbole] action in :read, :write, :close
    # @param [Array] args passed to the block
    # @return [NilClass]
    def on(action, *args, &block)
      instance_variable_set "@on_#{action}", [block, args]
      nil
    end

    # Defining helpers #on_read, #on_write and #on_close using #on method
    #
    # @see #on
    %W{read write close}.each do |action|
      define_method "on_#{action}" do |*args, &block|
        self.on(action.to_sym, *args, &block)
      end
    end

    # TODO: comment
    def listen(*event_types)
      event_types.each { |e_t| self.update_selector_listening(e_t, true) }
    end

    # TODO: comment
    def stop_listening(*event_types)
      event_types.each { |e_t| self.update_selector_listening(e_t, false) }
    end

    # TODO: comment & improve
    def got(action)
      case action
      when :read
        @on_read.first.call(*@on_read.last) unless @on_read.nil?
      when :write
        @on_write.first.call(*@on_write.last) unless @on_write.nil?
      when :close
        @on_read.first.call(*@on_read.last) unless @on_close.nil?
      end

      nil
    end

    # TODO
    def <<(message)
      @selector.listen(self, w: true)
    end

    private

    # TODO: comment
    def update_selector_listening(event_type, status)
      @selector.listen(event_type => status)
    end
  end # !Stream

  private

  # Find the registered stream from it's wrapped IO
  #
  # @param [IO] io
  # @return [Selector::Stream] or nil class if not found
  def find_stream_from_io(io)
    @streams.find { |stream| stream.io == io }
  end

  # Tell if a stream is listening at a given event
  #
  # @param [Selector::Stream] stream
  # @param [Symbole] event_type
  # @return [Boolean]
  def stream_listening?(stream, event_type)
    looking_to_(event_type).include? stream.io
  end

  # Return the array of monitored ios dedicated for this type of events
  #
  # @param [Symbole] event_type
  # @return [Array]
  def looking_to_(event_type)
    self.instance_variable_get("@looking_to_#{event_type}")
  end

  # Ensure validity of the type of event passed.
  # It throws an exception otherwise.
  #
  def ensure_valid_event_type!(event_type)
    unless MONITORABLE_EVENT_TYPES.include? event_type
      raise "Unvalid event type '#{event_type}' for '#{__callee__}'."
    end
  end
end

# pseudo code

# core
server = TCPServer.new
should_continue = true
stream_ui = nil
stream_analysis = []

stream_server = selector.register_io(server)
stream_server.listen(:read)
stream_server.on_read(selector) do |selector|
  # accept the connection
  # save it correctly
end
selector.loop(should_continue)

# ui(socket_server)
client = TCPClient.new
selector = Selector.new
stream_std_entry = selector.register_io(STDIN)
stream_ui = selector.register_io(client)
stream_ui.listen(:read)
