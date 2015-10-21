#!/usr/bin/ruby

require_relative 'copy_peste'

class Bye

  include CopyPeste::Greetings

  def text
    "Bye says 'bye' and its parent says '#{super}'"
  end

  def text2(t)
    "Bye says '#{t}' and its parent says '#{super}'"
  end

end