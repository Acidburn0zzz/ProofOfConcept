require 'ffi'

module Algorithms
  extend FFI::Library
  ffi_lib './libs/algorithms.so'
  attach_function :levenshtein, [:string, :string], :int
  attach_function :compare_files_match, [:string, :string, :int], :int

end

puts "Levenshtein distance of 'chiens' and 'niche' = #{Algorithms.levenshtein("chiens", "niche")}"

puts "Rsync compare file of 'algorithms.so' and 'algorithms.so' = #{Algorithms.compare_files_match("./libs/algorithms.so", "./libs/algorithms.so", 512)}"
