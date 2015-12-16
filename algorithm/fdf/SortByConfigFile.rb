
require '../config/fileHandler/fileYAMLAccessControl.rb'

class SortByConfigFile
  
  def initialize()
    @fileAccess = FileYAMLAccessControl.new()
    @fileAccess.loadFile()
  end


  #/* Methodes to sort list */
  def getListSortWhitoutIgnoredFiles(listPath)
    newListPath = listPath.clone()
    getIgnoreFile().each do | ignoreFile |
      listPath.each do | path |
        if path.include?(ignoreFile)
          newListPath.delete(path)
        end
      end
    end
    return newListPath
  end

  def getListSortWhitoutIgnoreExtension(listPath)
    newListPath = listPath.clone()
    getIgnoreExtension().each do | ignoreExt |
      listPath.each do | path |
        if path.include?(ignoreExt)
          newListPath.delete(path)
        end
      end
    end
    return newListPath
  end

  def getListSortByCompareExtension(listPath)
    
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
