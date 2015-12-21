
require_relative '../SortByConfigFile.rb'

Given /^step ccbTestSortByConfigFile loading$/ do

  list = ["path1/fichier1.c",
          "path6/testIgnoreExtension.php",
          "path2/fichier16.cpp",
          "path3/fichier3.java",
          "path4/fichier4.txt",
          "path5/fichier5.rb",
          "path7/fichier7.xml",
          "path8/fichier1.c.b",
          "path9/fichier16.cpp",
          "path11/fichier11.java",
          "path12/fichier12.rb",
          "path13/fichier13.php",
          "path14/fichier14.xml",
          "path15/testIgnoreFile.c",
          "path16/fichier168945.cpp",
          "/test/test/GemFile"]
  
  if (run_test(list) == 1)
    pending
  end

end

def ignore_file_test(sortByConfigFile, list)

  sortByConfigFile.addIgnoreFile("testIgnoreFile.c")
  sortByConfigFile.addIgnoreFile("testIgnoreExtension.php")
  sortByConfigFile.addIgnoreFile("fichier3.java")
  sortByConfigFile.addIgnoreFile("fichier7.xml")
  sortByConfigFile.addIgnoreFile("fichier12.rb")
  sortByConfigFile.addIgnoreFile("fichier168945.cpp")
  ignoreFile = sortByConfigFile.getIgnoreFile()


  if ignoreFile[0].eql? "testIgnoreFile.c" and ignoreFile[1].eql? "testIgnoreExtension.php" and ignoreFile[2].eql? "fichier3.java" and ignoreFile[3].eql? "fichier7.xml" and ignoreFile[4].eql? "fichier12.rb" and ignoreFile[5].eql? "fichier168945.cpp"
    puts "OK [1/6] Check addIgnoreFile function"
  else
    puts "FAIL [1/6] Check addIgnoreFile function"
    return 1
  end

  listWtIgnoreFile = sortByConfigFile.getListSortWhitoutIgnoredFiles(list)

  if listWtIgnoreFile[0].eql? "path1/fichier1.c" and listWtIgnoreFile[1].eql? "path2/fichier16.cpp" and listWtIgnoreFile[2].eql? "path4/fichier4.txt" and listWtIgnoreFile[3].eql? "path5/fichier5.rb" and listWtIgnoreFile[4].eql?  "path8/fichier1.c.b" and listWtIgnoreFile[5].eql? "path9/fichier16.cpp" and listWtIgnoreFile[6].eql? "path11/fichier11.java" and listWtIgnoreFile[7].eql? "path13/fichier13.php" and listWtIgnoreFile[8].eql? "path14/fichier14.xml" and listWtIgnoreFile[9].eql? "/test/test/GemFile"
    puts "OK [2/6] Check getListSortWhitoutIgnoredFiles function"
  else
    puts "FAIL [2/6] Check getListSortWhitoutIgnoredFiles function"
    return 1
  end
  return 0
end

def ignore_ext_test(sortByConfigFile, list)

  sortByConfigFile.addIgnoreExtension(".c")
  sortByConfigFile.addIgnoreExtension(".xml")
  sortByConfigFile.addIgnoreExtension(".java")
  
  ignoreExt = sortByConfigFile.getIgnoreExtension()
  if ignoreExt[0].eql? ".c" and ignoreExt[1].eql? ".xml" and ignoreExt[2].eql? ".java"
    puts "OK [3/6] check getIgnoreExtension function"
  else
    puts "FAIL [3/6] check getIgnoreExtension function"
    return 1
  end

  listComp = sortByConfigFile.getListSortWhitoutIgnoredExtension(list)

  if listComp[0].eql? "path6/testIgnoreExtension.php" and listComp[1].eql? "path2/fichier16.cpp" and listComp[2].eql? "path4/fichier4.txt" and listComp[3].eql? "path5/fichier5.rb" and listComp[4].eql? "path8/fichier1.c.b" and listComp[5].eql? "path9/fichier16.cpp" and listComp[6].eql? "path12/fichier12.rb" and listComp[7].eql? "path13/fichier13.php" and listComp[8].eql? "path16/fichier168945.cpp" and listComp[9].eql? "/test/test/GemFile"
    puts "OK [4/6] check getListSortWhitoutIgnoredExtension function"
  else
    puts "FAIL [4/6] check getListSortWhitoutIgnoredExtension function"
    return 1
  end

  return 0
end

def compare_ext_test(sortByConfigFile, list)
  sortByConfigFile.addCompareExtension([".c", ".java"])
  sortByConfigFile.addCompareExtension([".rb"])
  sortByConfigFile.addCompareExtension([".toto", ".tata"])
  compareExt = sortByConfigFile.getCompareExtension()

  if compareExt[0].eql? [".c", ".java"] and compareExt[1].eql? [".rb"] and compareExt[2].eql? [".toto", ".tata"]
    puts "OK [5/6] check addCompareExtension function"
  else
    puts "FAIL [5/6] check addCompareExtension function"
    return 1
  end
  
  listComp = sortByConfigFile.getListSortByCompareExtension(list)
  if listComp[0].eql? ["path1/fichier1.c", "path15/testIgnoreFile.c", "path3/fichier3.java", "path11/fichier11.java"] and listComp[1].eql? ["path5/fichier5.rb", "path12/fichier12.rb"] and listComp[2].eql? []
    puts "OK [6/6] check getListSortByCompareExtension function"
  else
    puts "FAIL [6/6] check getListSortByCompareExtension function"
    return 1
  end

  return 0
end

def run_test(list)

  puts "Run test sort by config file"
  sortByConfigFile = SortByConfigFile.new("test_config.yml", false)
  
  puts "--- Ignore File New List ---"
  if ignore_file_test(sortByConfigFile, list) == 1
    return 1
  end

  puts "--- Ignore Extension New List ---"
  if ignore_ext_test(sortByConfigFile, list) == 1
    return 1
  end

  puts "--- List compare extension New List ---"
  if compare_ext_test(sortByConfigFile, list) == 1
    return 1
  end

  return 0
end

