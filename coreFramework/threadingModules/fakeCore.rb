#!/usr/bin/ruby

require 'thread'
require 'colorize'
require './fakeAnalyseModule.rb'
require './fakeGraphicalModule.rb'
require './masterCIT.rb'

class Core
	def initialize
		@gQueue = Queue.new
		@aQueue = Queue.new

		@gModule = GraphicalModule.new @gQueue
		@aModule = AnalyseModule.new @aQueue

		@gThread = Thread.new {@gModule.run}
		@aThread = Thread.new {@aModule.run}

		@masterCIT = MasterCIT.new(@gQueue, @aQueue)
	end


	def sayHelloToSlavesThreads
		sleep 1
		@masterCIT.send(GRAPHICAL, "Hello graphical module !")
		@masterCIT.send(ANALYSE, "Hello analyse module !")
	end

	def run
		sleep 1
		5.times do
			sleep 1
			rGraphic = @masterCIT.receive(GRAPHICAL)
			rAnalyse = @masterCIT.receive(ANALYSE)
			puts "(Core) Object receive msg from GRAPHICAL module: #{rGraphic}".blue if !rGraphic.empty?
			puts "(Core) Object receive msg from ANALYSE module: #{rAnalyse}".blue if !rAnalyse.empty?
		end
	end

	def joinThreads
		@gThread.join
		@aThread.join
	end

end

if __FILE__ == $0
	core = Core.new

	core.sayHelloToSlavesThreads

	core.run
end
