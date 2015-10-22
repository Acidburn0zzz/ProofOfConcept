#!/usr/bin/ruby

require 'thread'
require './communicationInterThread.rb'
require './moduleAnalyse.rb'

if __FILE__ == $0
	q = Queue.new

	ma1 = ModuleAnalyse.new q
	#ma2 = ModuleAnalyse.new q

	cit = CIT.new(q , 2, :master)
	cit.initHandler {puts "master receive: #{q.pop[0]}"}


	t1 = Thread.new { ma1.run }
	#t2 = Thread.new { ma2.run }

	sleep 1
	
	1.times do
		cit.send({"toto" => 25, "titi" => 42}, 3)
	end

	cit.initHandler {puts "master receiveddd: #{q.pop[0]}"}

	cit.send({"toto" => 25, "titi" => 42}, 3)

	t1.join
	#t2.join

	cit.displayChannelList
end