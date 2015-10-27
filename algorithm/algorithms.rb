require 'ffi'

module Algorithms
  extend FFI::Library
  ffi_lib './libs/algorithms.so'
  attach_function :levenshtein, [:string, :string], :int
end

puts "Levenshtein distance of 'chiens' and 'niche' = #{Algorithms.levenshtein("chiens", "niche")}"
