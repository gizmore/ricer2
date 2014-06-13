class Filewalker
  
  def self.proc_files(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, false, dotfiles, true, false, block)
  end

  def self.traverse_files(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, true, dotfiles, true, false, &block)
  end
  
  def self.proc_dirs(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, false, dotfiles, false, true, block)
  end

  def self.traverse_dirs(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, true, dotfiles, false, true, block)
  end
  
  def self.proc_all(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, false, dotfiles, true, true, block)
  end
 
  def self.traverse_all(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, true, dotfiles, true, true, block)
  end

  private
  
  def self.__traverse(dir, pattern='*', recursive=true, dotfiles=true, files=true, dirs=false, &block)
    
    # Sanity
    raise Exception.new "filewalker(dir) is not a directory: '#{dir}'." unless File.directory?(dir)
    
    _dirs = []
    
    # Files first
    Dir[dir+pattern].each do |path|
      file = path.rsubstr_from('/')
      if file != '.' && file != '..'
        if (file[0] != '.') || dotfiles
          if File.file?(path)
            yield(path, nil) if files
          elsif File.directory?(path)
            _dirs.push(path)
          end
        end
      end
    end

    # Dirs
    if recursive || dirs
      _dirs.each do |path|
        yield(nil, path) if dirs
        if recursive
          __traverse(path+'/', pattern, recursive, dotfiles, files, dirs, &block)
        end
      end
    end
  end
end
