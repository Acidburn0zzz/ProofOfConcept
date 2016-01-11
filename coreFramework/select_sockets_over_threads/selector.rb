# require "thread"

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
  # @example listen(stream, :read => false, :write)
  #  will monitor 'write' events but un-monitor 'read' events
  def listen(stream, *args)
    unless @streams.include? stream
      raise "Stream not registered for this selector."
    end

    args.each do |event|
      if event.kind_of? Hash
        event.each do |event_type, status|
          update_stream_monitoring_status(stream, event_type, status)
        end

      else
        update_stream_monitoring_status(stream, event, true)
      end
    end

    nil
  end

  # @TODO it seems that the boolean value apssed by reference isn't working that
  #  much. Maybe try using lambdas?
  #  http://ruby-doc.org/docs/ruby-doc-bundle/UsersGuide/rg/localvars.html
  #
  # Loop until the first value passed is evaluated to false (or nil)
  # over the 'select' method, calling the given block and trigger the callbacks
  # associated to the registered streams in case of monitored events happen.
  #
  # @param [Boolean] running condition for the loop
  #  Passed in the same array of the optional parameters, the original variable
  #  value is used every round since arrays are passed by reference.
  # @param [Array] *args passed as parameters to the block
  # @param [Proc] block (optional) first parameter sent is the stream
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
          puts "got something"
          stream = find_stream_from_io(io)
          action = (io.eof? rescue false) ? :close : :read
          stream.trigger_callback_for(action)
        end

        write_events.each do |io|
          stream = find_stream_from_io(io)
          # action = io.eof? ? :close : :write
          stream.trigger_callback_for(:write)
        end
      end

      puts "%s: 4" % __callee__

      # first param was "stream", not "self", but doesn't make sense...
      yield(self, *args[1..-1]) if block_given?
    end

    nil
  end

  class Stream
    CALLBACKABLE_EVENTS = (Selector::MONITORABLE_EVENT_TYPES << :close).uniq

    attr_reader :io

    # Initialize a new Selector::Stream object
    #
    # @param [IO] io
    # @param [Selector] selector handling the stream
    def initialize(io, selector)
      @io, @selector = io, selector
      CALLBACKABLE_EVENTS.each do |event_type|
        self.instance_variable_set "@on_#{event_type}", []
        self.instance_variable_set "@buffer_of_#{event_type}s", []
      end
    end

    def cannot_read!
      @cannot_read = true
    end

    # Define the behavior to adopt on an event
    #
    # @param [Symbole] action in :read, :write, :close
    # @param [Array] args passed to the block
    # @param [Proc] block, arity >= 1, first parameter send is the instance
    # @return [NilClass]
    def callback_for(action, *args, &block)
      instance_variable_set "@on_#{action}", [block, args]
      nil
    end

    # Defining helpers #callback_for_read, #callback_for_write and
    # #callback_for_close using #callback_for method
    #
    # @see #callback_for
    CALLBACKABLE_EVENTS.each do |action|
      define_method "callback_for_#{action}" do |*args, &block|
        self.callback_for(action.to_sym, *args, &block)
      end
    end

    # Tell the selector to listen for these types of event
    #
    # @note 'write' events are unlistened once all queued messages are sent
    # @param [Array] *event_types
    def listen(*event_types)
      event_types.each { |e_t| update_selector_listening(e_t, true) }
      nil
    end

    # Tell the selector to stop listening at these types of event
    #
    # @param [Array] *event_types
    def stop_listening(*event_types)
      event_types.each { |e_t| update_selector_listening(e_t, false) }
      nil
    end

    # Trigger the callbacks when an event happened
    #
    # @param [Symbole] event_type
    def trigger_callback_for(event_type)
      ensure_valid_event_type! event_type
      send("handle_#{event_type}")
      block, args = on_(event_type)
      block.call(self, *args) unless block.nil?
      nil
    end

    # Queue message that will be send when the io will be open for writes
    #
    # @param [String] message
    def queue(message)
      unless @buffer_of_writes.nil?
        @buffer_of_writes << message
        @selector.listen(self, :write)
        nil
      end
    end

    # Retrieve the oldest element available from the read side of the io
    #
    # @return [String] nil if empty
    def dequeue
      @buffer_of_writes.shift unless @buffer_of_writes.nil?
    end

    private

    # Update the monitoring status of events for the instance in the
    # selector handling it
    #
    # @param [Symbole] event_type
    # @status [Boolean]
    def update_selector_listening(event_type, status)
      @selector.listen(self, event_type => status)
    end

    # Ensure validity of the type of event passed.
    # It throws an exception otherwise.
    #
    # @param [Symbole] event_type
    def ensure_valid_event_type!(event_type)
      unless CALLBACKABLE_EVENTS.include? event_type
        raise "Unvalid event type '#{event_type}' for '#{__callee__}'."
      end
    end

    # Return the instance variable dedicated for this type of events
    #
    # @param [Symbole] event_type
    # @return [Array]
    def on_(event_type)
      self.instance_variable_get("@on_#{event_type}")
    end

    # Get line from the io and insert it back in the buffer of read messages
    #
    def handle_read
      unless @cannot_read || @buffer_of_reads.nil?
        message = io.readline
        @buffer_of_reads << message
        nil
      end
    end

    # Puts queued message in the io and unlisten
    #
    # @note will stop listening 'write' events if queue is empty
    def handle_write
      unless @buffer_of_writes.nil?
        message = @buffer_of_writes.shift
        io.puts message
        stop_listening(:write) if @buffer_of_writes.empty?
        nil
      end
    end
  end # !Stream

  private

  # Find the registered stream from its wrapped IO
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

  # Add or remove a stream from the array of listening streams
  # monitored for an event depending its status
  #
  # @param [Selector::Stream] stream
  # @param [Symbole] event_type
  # @param [Boolean] status
  def update_stream_monitoring_status(stream, event_type, status)
    ensure_valid_event_type!(event_type)
    if status # monitor it
      # ... unless already done
      unless stream_listening?(stream, event_type)
        looking_to_(event_type) << stream.io
      end

    else # un-monitor it
      looking_to_(event_type).delete stream.io
    end

    nil
  end

  # Ensure validity of the type of event passed.
  # It throws an exception otherwise.
  #
  # @param [Symbole] event_type
  def ensure_valid_event_type!(event_type)
    unless MONITORABLE_EVENT_TYPES.include? event_type
      raise "Unvalid event type '#{event_type}' for '#{__callee__}'."
    end
  end
end
