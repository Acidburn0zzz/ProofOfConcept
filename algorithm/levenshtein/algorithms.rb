require 'ffi'

module Algorithms
  extend FFI::Library
  ffi_lib './algorithms.so'
  attach_function :levenshtein, [:string, :string], :int
end

puts "Levenshtein distance of 'chien' and 'niche' = #{Algorithms.levenshtein("chien", "niche")}"
