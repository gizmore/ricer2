class Filewalker
  
  def self.proc_files(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, false, dotfiles, true, false, &block)
  end

  def self.traverse_files(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, true, dotfiles, true, false, &block)
  end
  
  def self.proc_dirs(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, false, dotfiles, false, true, &block)
  end

  def self.traverse_dirs(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, true, dotfiles, false, true, &block)
  end
  
  def self.proc_all(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, false, dotfiles, true, true, &block)
  end
 
  def self.traverse_all(dir, pattern='*', dotfiles=true, &block)
    __traverse(dir, pattern, true, dotfiles, true, true, &block)
  end

  private
  
  def self.__traverse(dir, pattern='*', recursive=true, dotfiles=true, files=true, dirs=false, &block)
    
    dir = File.dirname(dir) if File.file?(dir)
    
    dir = dir.rtrim('/') + '/'
    
    # Sanity
    raise Exception.new "filewalker(dir) is not a directory: '#{dir}'." unless File.directory?(dir)
    
    # Files first
    Dir[dir+pattern].each do |path|
      file = path.rsubstr_from('/')
      if (file != '.') && (file != '..')
        if (file[0] != '.') || dotfiles
          if File.file?(path)
            yield(path, nil) if files
          end
        end
      end
    end
    
    # Dirs
    if recursive || dirs
      Dir[dir+'*'].each do |path|
        file = path.rsubstr_from('/')
        if (file != '.') && (file != '..')
          if (file[0] != '.') || dotfiles
            if File.directory?(path)
              yield(nil, path) if dirs
              if recursive
                __traverse(path+'/', pattern, recursive, dotfiles, files, dirs, &block)
              end
            end
          end
        end
      end
    end
    
    ###
    ### Same for classes :)
    ###
    def self.classes_do(module_const, recursive=true, &block)
      # Yield all classes
      module_const.constants.
        select{|c| Class === module_const.const_get(c) }.
        each{|c| yield(module_const.const_get(c)) }
      # Call myself recursively for all modules
      if recursive
        module_const.constants.
          select{|m| m = module_const.const_get(m); m === Module and m.name.start_with?(module_const.name) }.
          each{|m| classes_do(module_const.const_get(m), recursive, &block) }
      end
      nil
    end
    
  end
end
