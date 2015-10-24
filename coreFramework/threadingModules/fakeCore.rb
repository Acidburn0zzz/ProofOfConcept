#!/usr/bin/ruby

require 'thread'
require 'colorize'
require './communicationInterThread.rb'
require './fakeModuleAnalyse.rb'

class Core

  @@amCpt = 0 # Analyse Modules cpt
  @@allAm = {} # All Analyse Modules

  def initialize
    @@allAm = {}
  end

  def startAnalyseModule
    @@allAm[@@amCpt.to_s] = {
      "Queue" => nil,
      "MA" => nil,
      "CIT" => nil,
      "Thread" => nil
    }

    strAmCpt = @@amCpt.to_s

    @@allAm[strAmCpt]["Queue"] = Queue.new
    @@allAm[strAmCpt]["MA"] = ModuleAnalyse.new @@allAm[strAmCpt]["Queue"]

    @@allAm[strAmCpt]["CIT"] = CIT.new(@@allAm[strAmCpt]["Queue"] , @@amCpt, :master)
    @@allAm[strAmCpt]["CIT"].initHandler {
      puts "master receive"
      #puts "master receive: #{@@allAm[strAmCpt]["Queue"].pop[0]}"
    }

    maInstance = @@allAm[strAmCpt]["MA"]
    @@allAm[strAmCpt]["Thread"] = Thread.new {
      maInstance.run
    }

    @@amCpt += 1
  end

  def sendToAnalyseModule (analyseModuleNb, *args)
    @@allAm[analyseModuleNb.to_s]["CIT"].send("toto")
  end

  def joinAll
    @@allAm.each do |key, array|
      array["Thread"].join
    end
  end

end

if __FILE__ == $0
  fakeCore = Core.new

  fakeCore.startAnalyseModule

  fakeCore.sendToAnalyseModule(0, "toto")

  fakeCore.joinAll
end
