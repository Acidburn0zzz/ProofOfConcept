#!/usr/bin/ruby

require 'colorize'
require './slaveCIT.rb'


class GraphicalModule

	def initialize (queue)
    puts "(GRAPHICAL) Module initialization.".red
    
    @queue = queue

    @cit = SlaveCIT.new(@queue , GRAPHICAL)
    @cit.receiptionHandler {
      puts "(GRAPHICAL) Module receive msg from CORE: #{@cit.receive}".green
    }
  end

  def run
    puts "(GRAPHICAL) Module start running for 5s.".red
    sleep 1
    5.times do 
      @cit.send "Hi Core !"
    end
    sleep 4
    puts "(GRAPHICAL) Module stop.".red
  end

end
