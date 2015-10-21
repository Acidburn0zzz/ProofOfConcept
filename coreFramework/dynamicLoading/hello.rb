#!/usr/bin/ruby

require_relative 'copy_peste'

class Hello

  include CopyPeste::Greetings

  def text
    "Hello says 'hello'"
  end

  def text2(t)
    "Hello says '#{t}'"
  end

end