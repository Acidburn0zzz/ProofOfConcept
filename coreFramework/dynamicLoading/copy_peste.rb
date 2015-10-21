#!/usr/bin/ruby

module CopyPeste

  module Application

    def self.load_greetings_module(class_name)
      load "./#{class_name.downcase}.rb"
      klass = eval(class_name)
      (@@klasses ||= {})[class_name] = klass
    end

    def self.run_greetings_module(class_name)
      puts (@@klasses ||= {})[class_name].nil? ? 'Not found' : @@klasses[class_name].new.text
    end

  end

  module Greetings

    def text
      "Greetings fucks your mum"
    end

    def text2(t)
      "Greetings says '#{t}'"
    end

  end



end
