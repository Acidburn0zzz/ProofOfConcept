#!/usr/bin/ruby

require 'colorize'
require './communicationInterThread.rb'


class ModuleAnalyse

	@@nbMA = 0

	def initialize (queue)
          @myNb = @@nbMA
          puts "Analyse module number #{@myNb} initialization.".red
    
    	@queue = queue
    	@cit = CIT.new(@queue , @myNb, :slave)
    	@cit.initHandler {
            puts "(chan#{@cit.channel}/#{@cit.threadType}) Analyse module number #{@myNb}, receive: #{@queue.pop}".green
    	}
          @@nbMA += 1
	end



        def run
          puts "Analyse module number #{@myNb} start running for 10s.".red
          sleep 2
          puts "Analyse module number #{@myNb} stop.".red
          @cit.deleteChannel
        end

end
