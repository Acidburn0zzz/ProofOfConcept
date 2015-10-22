  #!/usr/bin/ruby

  class CIT

    attr_reader :channel
    attr_reader :threadType
    attr_reader :sigReceiver
    attr_reader :sigSender

    @@channelSchedule = {} 
    @@errorMsgIndispChan = "Asked channel isn't available for thread communication."
    @@errorMsgIndispChan = "Asked channel is currently full for thread communication."
    @@errorMsgIndispSlot = "Asked slot isn't available for this channel."

    def initialize (queue, channel, threadType=:master)

      #puts "-----------------------------------------------------------"

      #puts "channel available ? #{isAvailableChannel? channel}"
      #puts "channel full ? #{isFullChannel? channel}"
      #puts "slot available ? #{isAvailableSlot?(channel, threadType)}"


      @@channelSchedule[channel] = [] if isAvailableChannel? channel
      raise @@errorMsgFullChan if isFullChannel? channel
      raise @@errorMsgIndispSlot if !isAvailableSlot?(channel, threadType)
      @@channelSchedule[channel].push threadType

      @channel = channel
      @queue = queue
      @threadType = threadType

      @sigReceiver = getReceiverSignal
      @sigSender = getSenderSignal
    end

    def initHandler (&block)
      return if @sigSender.nil?
      Signal.trap(getSenderSignal) do
          block.call if @queue.pop == @channel
        end
    end

    def send (*args)
      @queue.push @channel
      @queue.push args
      Process.kill(@sigReceiver, Process.pid) if !@sigReceiver.nil?
    end

    def deleteChannel
      @@channelSchedule.delete(channel) if !isAvailableChannel? @channel
    end

    def displayChannelList
      @@channelSchedule.each do |channel, slots|
        puts "n°#{channel} -> #{slots}"
      end
    end

    def displayParameters
      puts "CIT parameters:\n"
      puts "Queue address\t#{@queue}\n"
      puts "Channel number\t#{@channel}\n"
      puts "Thread type\t#{@threadType}"
    end

    private

    def getSenderSignal
      sig = nil
      if @threadType == :master
        sig = "USR2"
      elsif @threadType == :slave
        sig = "USR1"
      end
    sig    
    end

    def getReceiverSignal
      sig = nil
      if @threadType == :master
        sig = "USR1"
      elsif @threadType == :slave
        sig = "USR2"
      end
    sig
    end

    def isAvailableChannel? (askedChannel)
      return !@@channelSchedule.has_key?(askedChannel) 
    end

    def isAvailableSlot? (askedChannel, threadType)
      if ((@@channelSchedule[askedChannel] == []) || 
        @@channelSchedule[askedChannel].nil? ||
        !@@channelSchedule[askedChannel].include?(threadType))
          return true 
        end
      false
    end

    def isFullChannel? (askedChannel)
      if ((@@channelSchedule[askedChannel] == []) || 
        @@channelSchedule[askedChannel].nil?)
        return false
      end
        
      if (@@channelSchedule[askedChannel].include?(:master) &&
        @@channelSchedule[askedChannel].include?(:slave))
          return true
      end
      false
    end
  end
