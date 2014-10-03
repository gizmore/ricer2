require 'fileutils'
#
# Automatically creates a folder in files/ directory. (thx roun512)
# Addes file helper functions
#
module Ricer::Plug::Extender::HasFiles
  def has_files
    class_eval do |klass|
      
      klass.add_hook('plugin_install') do |plugin|
        puts 123
        byebug
        # Create files directory
        plugin.plugin_dir_path 
        byebug
        puts 123
      end

      def plugin_file_base
        "#{Rails.root}/files/#{plugin_name}"
      end
      
      def plugin_file_read(path)
        IO.binread(plugin_file_path!(path))
      end
      
      def plugin_file_exists?(path)
        File.exists?(plugin_file_path!(path)) && File.file?
      end
      
      def plugin_dir_path!(path='')
        plugin_dir_path(path, false)
      end
  
      def plugin_dir_path(path='', create=true)
        path.trim!('/'); path = '/' + path unless path.empty?
        dir = "#{plugin_file_base}#{path}"
        if create
          bot.log_info("Creating plugin file dir: #{dir}")
          FileUtils.mkdir_p(dir) unless File.exists?(dir) && File.directory?(dir)
        end
        dir
      end
  
      def plugin_file_path!(path)
        plugin_file_path(path, false)
      end

      def plugin_file_path(path, create=true)
        dir = path.trim!('/').rsubstr_to('/')||''
        dir_path = plugin_dir_path(dir, create)
        name = path.rsubstr_from('/') || path
        path = dir_path + '/' + name
        if create
          bot.log_info("Creating plugin file path: #{path}")
          FileUtils.touch(path) unless File.exists?(path) && File.file?(path)
        end
        path
      end
      
    end
  end
end
