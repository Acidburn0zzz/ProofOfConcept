require './cit.rb'

class MasterCIT < CIT
	def initialize (graphicalQueue, analyseQueue)
		super()
		@gQueue = graphicalQueue
		@aQueue = analyseQueue
	end

	def send (channel, *args)
		sig = (channel == GRAPHICAL ? GRAPHICAL : ANALYSE)
		queue = (channel == GRAPHICAL ? @gQueue : @aQueue)
		queue << {:slave => args}
		Process.kill(sig, Process.pid)
	end

	def receive (channel)
		receivedElems = []
		wrongDest = []
		queue = (channel == GRAPHICAL ? @gQueue : @aQueue)		

		until queue.empty? do
			elem = queue.pop
			if elem.has_key? :master
				receivedElems.push elem[:master]
			else
				wrongDest.push elem
			end				 	 
		end

		wrongDest.each do |elem|
			queue << elem
		end
		receivedElems
	end

end