#!/usr/bin/ruby

require 'colorize'
require './slaveCIT.rb'


class AnalyseModule

  def initialize (queue)
    puts "(ANALYSE) Module initialization.".red
    
    @queue = queue

    @cit = SlaveCIT.new(@queue , ANALYSE)
    @cit.receiptionHandler {
      puts "(ANALYSE) Module receive msg from CORE: #{@cit.receive}".green
    }
  end

  def run
    puts "(ANALYSE) Module start running for 5s.".red
    sleep 1
    5.times do 
      @cit.send "Hi Core !"
    end
    sleep 4
    puts "(ANALYSE) Module stop.".red
  end

end
