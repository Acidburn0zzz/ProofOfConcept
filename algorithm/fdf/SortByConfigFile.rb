
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
        if path.match(ignoreFile + "$")
          newListPath.delete(path)
        end
      end
    end
    return newListPath
  end

  def getListSortWhitoutIgnoredExtension(listPath)
    newListPath = listPath.clone()
    getIgnoreExtension().each do | ignoreExt |
      listPath.each do | path |
        if path.match(ignoreExt + "$")
          newListPath.delete(path)
        end
      end
    end
    return newListPath
  end

  def getListSortByCompareExtension(listPath)
    listContainPath = Array.new()
    getCompareExtension().each do | compareExt |
      newListPath = Array.new()
      compareExt.each do | ext |
        listPath.each do | path |
          if path.match(ext + "$")
            newListPath.push(path)
          end
        end
      end
      listContainPath.push(newListPath)
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
