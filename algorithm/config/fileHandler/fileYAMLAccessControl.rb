
require 'yaml'
require_relative 'objectYAML.rb'

class FileYAMLAccessControl

 def initialize(nameFile = "./file_cmp_config.yml")
    @NameFile = File.expand_path(File.join(File.dirname(__FILE__), "../" + nameFile))
  end

  def deleteFile()
    File.delete(@NameFile) if File.exist?(@NameFile)
  end
  
  def finish()
    if !@LoadingFile.nil?
      File.open(@NameFile, 'w') do | f |
        YAML.dump(@LoadingFile, f)
      end
    end
  end
  
  def loadFile(fillIn = true)
    if !File.exists? (@NameFile)
      outFile = File.new(@NameFile, "w")

      ignore = IgnoreObj.new()
      files = FilesObj.new(ignore)
      if (fillIn)
        fillInExampleFile(ignore)
      else
        fillInExampleFileEmpty(ignore)
      end

      ignore = IgnoreObj.new()
      compare = CompareObj.new()
      extentions = ExtensionsObj.new(ignore, compare)
      if (fillIn)
        fillInExampleExt(ignore, compare)
      else
        fillInExampleExtEmpty(ignore, compare)        
      end

      global = Globalobj.new(files, extentions);

      serialized_object = YAML::dump(global)
      # puts serialized_object
      outFile.puts YAML::load(serialized_object)
      outFile.close
    end
    @LoadingFile = YAML::load_file(@NameFile)

    begin
      @IgnoreFile = @LoadingFile["files"]["ignore"]
      @IgnoreExt = @LoadingFile["extensions"]["ignore"]
      @CompareExt = @LoadingFile["extensions"]["compare"]
    rescue Exception => msg
      STDERR.puts "Error load: " + msg.to_s
    end
  end


  #/* Get elements */
  def getIgnoreFile()
    return @IgnoreFile
  end

  def getIgnoreExtension()
    return @IgnoreExt
  end
  
  def getCompareExtension()
    return @CompareExt
  end
  
  #/* Add elements */
  def addIgnoreFile(fileName)
    if !@IgnoreFile.nil? and !@IgnoreFile.include? fileName
      @IgnoreFile.push(fileName)
      if @IgnoreFile[0] == nil
        @IgnoreFile.delete_at(0)
      end
    elsif !@IgnoreFile.nil? and @IgnoreFile.include? fileName
      STDERR.puts "Error: '#{fileName}' already contained into '#{@NameFile}' 'compare extension'"
    else
      STDERR.puts "Error: '#{@NameFile}' does not contain 'ignore file'"      
    end
  end

  def addIgnoreExtension(extName)
    if !@IgnoreExt.nil? and !@IgnoreExt.include? extName
      @IgnoreExt.push(extName)
      if @IgnoreExt[0] == nil
        @IgnoreExt.delete_at(0)
      end
    elsif !@IgnoreExt.nil? and @IgnoreExt.include? extName
      STDERR.puts "Error: '#{extName}' already contained into '#{@NameFile}' 'ignore extension'"
    else
      STDERR.puts "Error: '#{@NameFile}' does not contain 'ignore extension'"      
    end
  end

  def addCompareExtension(extName)
    if !@CompareExt.nil? and !@CompareExt.include? extName
      @CompareExt.push(extName)
      if @CompareExt[0] == nil
        @CompareExt.delete_at(0)
      end
    elsif !@CompareExt.nil? and @CompareExt.include? extName
      STDERR.puts "Error: '#{extName}' already contained into '#{@NameFile}' 'compare extension'"
    else
      STDERR.puts "Error: '#{@NameFile}' does not contain 'compare extension'"      
    end
  end

  #/* Delete elements */
  def deleteIgnoreFile(fileName)
    if @IgnoreFile
      @IgnoreFile.delete(fileName)
    else
      STDERR.puts "Error: '#{@NameFile}' does not contain 'ignore file'"      
    end
  end

  def deleteIgnoreExtension(extName)
    if @IgnoreExt
      @IgnoreExt.delete(extName)
    else
      STDERR.puts "Error: '#{@NameFile}' does not contain 'ignore file'"      
    end
  end

  def deleteCompareExtension(extName)
    if @CompareExt
      @CompareExt.delete(extName)
    else
      STDERR.puts "Error: '#{@NameFile}' does not contain 'ignore file'"      
    end
  end

  #/* Methodes for tests */
  def displayFile()
    puts @LoadingFile
  end

  def displayElementsFile()
    @LoadingFile.each do |elem|
      puts elem
      puts "\n"
    end
  end

  def fillInExampleFile(ignore)
    ignore.addElement("GemFile")
    ignore.addElement("Rakefile")
    ignore.addElement(".gitignore")
  end

  def fillInExampleFileEmpty(ignore)
    ignore.addElement("~")
  end

  def fillInExampleExt(ignore, compare)
    ignore.addElement(".trash")
    ignore.addElement(".old")

    compare.addElements([".h", ".hh"])
    compare.addElements([".text", ".text.old", ".old"])
  end

  def fillInExampleExtEmpty(ignore, compare)
    ignore.addElement("~")
    compare.addElements([])
  end
end
