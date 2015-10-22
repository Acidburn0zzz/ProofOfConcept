#!/usr/bin/ruby

require './communicationInterThread.rb'

class ModuleAnalyse

	@@nbMA = 0

	def initialize (queue)
		@@nbMA += 1
		@myNb = @@nbMA
		puts "start module analyse nb #{@myNb}"
    
    	@queue = queue
    	@cit = CIT.new(@queue , 2, :slave)
    	@cit.initHandler {
    		puts "slave n°#{@myNb} receive: #{@queue.pop}"
    		@cit.send "coucou"
    	}
	end

  def run
    puts "hey ! I run !"
    sleep 5
    puts "byebye"
    @cit.deleteChannel
  end

end