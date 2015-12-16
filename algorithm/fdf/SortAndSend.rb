
class SortAndSend
  attr_accessor :list, :octe, :fileHash, :rsynctab

  def initialize(list, octe)
    @list = list
    @octe = octe
    @fileHash = Hash.new
    @rsynctab = []
  end


  def getextension(fileName)
    if (extension = fileName.split('.')) == nil
      puts "#{fileName} n'as pas d'extention !!\n\n"
      return nil
    end
    return extension[1]
  end


  def fillHash(tabfile, extension, i)
    if fileHash[:"#{extension}"] == nil
      newHash = Hash.new
      newHash[:"#{octe[i]}"] = tabfile
      fileHash[:"#{extension}"] = newHash
    else
      myHash = fileHash[:"#{extension}"]
      if myHash[:"#{octe[i]}"] == nil
        myHash[:"#{octe[i]}"] = tabfile
      else
        myHash[:"#{octe[i]}"] << tabfile[0]
      end
      fileHash[:"#{extension}"] = myHash
    end
  end


  def start
    i = 0
    # threads = []
    list.each do |fileName|
      # threads = Thread.new {
      if (extension = getextension(fileName)) != nil 
        tabfile = Array.new
        tabfile << fileName
        fillHash(tabfile, extension, i)
      end
      i += 1
      # }
      # threads.each {|thr| thr.join}
      # threads.each do |thr|
      #   thr.exit
      # end
    end
    puts fileHash
    puts "\n"
    puts "\n"
  end
  
  
  def sendLevenshtein(fileToSend)
    tab = []
    i = 0
    j = 1
    firstpass = true
    sizeTab = fileToSend.size()
    while i != fileToSend.size() - 1
      while j != fileToSend.size()
        file1 = fileToSend[i].split('/')
        file2 = fileToSend[j].split('/')
        if (result = Algorithms.levenshtein(file1.last(), file2.last())) == 0
          rsynctab << fileToSend[i]
          rsynctab << fileToSend[j]
        end
        puts "#{file1.last} comparer avec  #{file2.last} pour le lev distance = #{result} \n"
        j += 1
      end
      i += 1
      j = i+1
    end
    fileToSend.delete(fileToSend[0])
  end


  def levenshtein
    if fileHash.empty? == true
      return nil
    end
    fileHash.each_value {|value| value.each{|key, value| sendLevenshtein(value)}}
    if rsynctab.size() > 0
      sendRsync()
    end
  end


  def sendRsync
    i = 0
    puts "\n"
    while i != rsynctab.size()
      puts "#{rsynctab[i]} comparer avec  #{rsynctab[i+1]} pour le rsync\n"
      if (Algorithms.compare_files_match(rsynctab[i], rsynctab[i+1], 512) == 0) then
        puts "SIMILARE"
      else
        puts "DIFFERENT"
      end
      i += 2
    end
    puts "\n"
  end

end
