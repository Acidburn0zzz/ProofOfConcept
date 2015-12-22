# ruby
Given /^step framework loading$/ do

  Dir["./../../path_test/framework"].each do | files |
    puts files
    puts "---"
    # ARGV = ["cmd_line_arg_#{i}","cmd_line_arg2"]
    # load 'program1.rb'
  end
end

