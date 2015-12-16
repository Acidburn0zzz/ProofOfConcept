
require './SortByConfigFile.rb'

def main(list)

  sortByConfigFile = SortByConfigFile.new()
  puts sortByConfigFile.getIgnoreFile()
  puts "--- Ignore File ---"
  puts sortByConfigFile.getListSortWhitoutIgnoredFiles(list)
  puts list
end


list = ["path1/fichier1.c", "path2/fichier16.cpp", "path3/fichier3.java", "path4/fichier4.txt", "path5/fichier5.rb", "path6/fichier6.php", "path7/fichier7.xml", "path8/fichier1.c", "path9/fichier16.cpp", "path10/fichier10.java", "path11/fichier11.java", "path12/fichier12.rb", "path13/fichier13.php", "path14/fichier14.xml", "path15/fichier15.c", "path16/fichier168945.cpp", "/home/edouard/Documents/EIP/Ruby/algorithm/test.c", "/home/edouard/Documents/EIP/Ruby/algorithm/Test/test.c", "/home/edouard/Documents/EIP/Ruby/algorithm/Test/test2.cpp", "/home/edouard/Documents/EIP/Ruby/algorithm/test2.cpp", "toto", "toto", "/test/test/GemFile"]

main(list)
