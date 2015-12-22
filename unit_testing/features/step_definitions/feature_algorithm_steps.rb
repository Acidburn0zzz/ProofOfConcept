# ruby
Given /^step algorithm loading$/ do

  Dir["./path_test/algorithm/*.rb"].each do | file |
    puts "Check file: "
    puts File.basename file
    puts "---"
    
    nameFile = File.basename(file,File.extname(file))
    steps %{
  Given step #{nameFile} loading
  # Given step woupi test
  # When A correct username and password are entered, Native (Core)
  # Then I should be logged in, Native (Core)
}
  

    
    end

end


