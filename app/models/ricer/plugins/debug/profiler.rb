# Uses RubyProf to profile and build reports.
# Reports send via Core/PasteOut plugin.
# Profiler can be started stopped manually, or a chain command can be used.
# ---
# https://github.com/ruby-prof/ruby-prof
# ---
# RubyProf::FlatPrinter - Creates a flat report in text format
# RubyProf::FlatPrinterWithLineNumbers - same as above but more verbose
# RubyProf::GraphPrinter - Creates a call graph report in text format
# RubyProf::GraphHtmlPrinter - Creates a call graph report in HTML (separate files per thread)
# RubyProf::DotPrinter - Creates a call graph report in GraphViz's DOT format which can be converted to an image
# RubyProf::CallTreePrinter - Creates a call tree report compatible with KCachegrind.
# RubyProf::CallStackPrinter - Creates a HTML visualization of the Ruby stack
# RubyProf::MultiPrinter - Uses the other printers to create several reports in one profiling run
# --more--
#
module Ricer::Plugins::Debug
  class Profiler < Ricer::Plugin
    
    revision_is 1
    author_is :gizmore
    license_is :unlicensed
    
    trigger_is :profiler
    permission_is :responsible
    environment_is :development
    
    def plugin_init
      @@profiler_running = false
      @@profiler_command = nil
      @@profiler_started = @@profiler_stopped = nil
    end

    ##############
    ### Toggle ###
    ##############
    has_usage :execute_toggle, '<boolean>'
    def execute_toggle(bool)
      bool ? execute_enable : execute_disable
    end

    #############
    ### Block ###
    #############
    has_usage '<trigger>'
    has_usage '<trigger> <..command..parameters..>'
    def execute(plugin, parameters=nil)
      return rply :err_already_enabled if profiler_enabled?
      line = plugin.trigger
      line += " #{parameters}" unless parameters.nil?
      rply :msg_capturing, trigger: plugin.trigger
      Ricer::Thread.execute do
        begin
          enable_profiler
          exec_newline(@@profiler_command = line)
        ensure
          disable_profiler
        end
      end
    end
    
    ###########
    ### API ###
    ###########
    def profiler_enabled?
      @@profiler_running||@@profiler_started
    end
    def enable_profiler
      @@profiler_running = true
      RubyProf.start
      @@profiler_started = Time.now
    end

    def disable_profiler(reply_result=true)
      @@profiler_running = false
      @@profiler_stopped = Time.now
      results = RubyProf.stop
      rply :msg_disabled
      reply_results(results) if reply_result
      @@profiler_command = @@profiler_started = @@profiler_stopped = nil
      results
    end
    
    private
    
    def execute_enable
      if profiler_enabled?
        rply :err_already_enabled
      else
        rply :msg_enabled
        enable_profiler
      end
    end
    
    def execute_disable
      unless profiler_enabled?
        rply :err_not_enabled
      else
        Ricer::Thread.execute {
          disable_profiler
        }
      end
    end
    
    ###############
    ### Results ###
    ###############
    def reply_results(result)
      title = profiler_paste_title(result) rescue "-profiler-pastebin-"
      rply :msg_generating
      content = profiler_paste_content(result)
      #rply :msg_profiled, title: title, content: content
      rply :msg_uploading, title: title, size: lib.human_filesize(content.length)
      get_plugin('Core/PasteOut').execute_upload(content, 'text', title)
    end
    
    def profiler_paste_title(result)
      args = {
        started: l(@@profiler_started),
        stopped: l(@@profiler_stopped),
        runtime: lib.human_duration_between(@@profiler_started, @@profiler_stopped),
      }
      if @@profiler_command
        args[:command] = @@profiler_command
        t(:paste_title_s, args)
      else
        t(:paste_title_l, args)
      end
    end
    
    def profiler_paste_content(result)
      content = StringIO.new # the printers will do filestream << graphics
      content << "Ricer profiler output\n\n" # like this
      content << "Date: " << l(Time.now) << "\n\n"
      RubyProf::FlatPrinter.new(result).print(content) # print into content
      content << "\ņ\n--graph--\n\n\n"
      RubyProf::GraphPrinter.new(result).print(content)
      content << "\n\n"
      content.string
    end
    
  end
end
