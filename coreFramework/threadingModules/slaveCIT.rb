require './cit.rb'

class SlaveCIT < CIT

	def initialize(queue, receiptionChannel)
		super()
		@rChan = receiptionChannel
		@queue = queue
	end

	def receiptionHandler (&block)
		Signal.trap(@rChan) do
			block.call
		end
	end

	def send (*args)
		@queue << {:master => args}
	end

	def receive
		receivedElems = []
		wrongDest = []

		until @queue.empty? do
			elem = @queue.pop
			if elem.has_key? :slave
				receivedElems.push elem[:slave]
			else
				wrongDest.push elem
			end				 	 
		end

		wrongDest.each do |elem|
			@queue << elem
		end
		receivedElems
	end
end