
require_relative './../config/fileHandler/fileYAMLAccessControl.rb'

class SortByConfigFile
  
  def initialize(nameFile = "./file_cmp_config.yml", fillIn = true)
    @fileAccess = FileYAMLAccessControl.new(nameFile)
    @fileAccess.loadFile(fillIn)
  end

  def finish()
    if !@fileAccess.nil?
      @fileAccess.finish()
    end
  end

  def deleteFile()
    if !@fileAccess.nil?
      @fileAccess.deleteFile()
    end
  end

  #/* Methodes to sort list */
  def getListSortWhitoutIgnoredFiles(listPath)
    newListPath = listPath.clone()
    if (!getIgnoreFile().nil?)
      getIgnoreFile().each do | ignoreFile |
        listPath.each do | path |
          if !ignoreFile.nil? and path.match(ignoreFile + "$")
            newListPath.delete(path)
          end
        end
      end
    end
    return newListPath
  end

  def getListSortWhitoutIgnoredExtension(listPath)
    newListPath = listPath.clone()
    if (!getIgnoreExtension().nil?)
      getIgnoreExtension().each do | ignoreExt |
        listPath.each do | path |
          if !ignoreExt.nil? and path.match(ignoreExt + "$")
            newListPath.delete(path)
          end
        end
      end
    end
    return newListPath
  end

  def getListSortByCompareExtension(listPath)
    listContainPath = Array.new()
    if (!getCompareExtension().nil?)
      getCompareExtension().each do | compareExt |
        containPath = Array.new()
        compareExt.each do | ext |
          listPath.each do | path |
            if !ext.nil? and path.match(ext + "$")
              containPath.push(path)
            end
          end
        end
        listContainPath.push(containPath)
      end
    end
    return listContainPath
  end

  #/* Methodes to get elements */
  def getIgnoreFile()
    return @fileAccess.getIgnoreFile()
  end
  def getIgnoreExtension()
    return @fileAccess.getIgnoreExtension()
  end
  def getCompareExtension()
    return @fileAccess.getCompareExtension()
  end

  #/* Methodes to add */
  def addIgnoreFile(fileName)
    @fileAccess.addIgnoreFile(fileName)
  end
  def addIgnoreExtension(extName)
    @fileAccess.addIgnoreExtension(extName)
  end
  def addCompareExtension(extName)
    @fileAccess.addCompareExtension(extName)
  end

  #/* Methodes to delete */
  def deleteIgnoreFile(fileName)
    @fileAccess.deleteIgnoreFile(fileName)
  end
  def deleteIgnoreExtension(extName)
    @fileAccess.deleteIgnoreExtension(extName)
  end
  def deleteCompareExtension(extName)
    @fileAccess.deleteCompareExtension(extName)    
  end


end
