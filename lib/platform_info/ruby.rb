require 'platform_info'
require 'rbconfig'

module PlatformInfo
  # Returns the absolute path to the current Ruby interpreter.
  def self.ruby_command
    @@ruby_command ||= begin
      Config::CONFIG['bindir'] + '/' + Config::CONFIG['RUBY_INSTALL_NAME'] + Config::CONFIG['EXEEXT']
    end
  end
  
  # Returns the Ruby engine name. Absolute path to the current Ruby interpreter.
  def self.ruby_engine
    @@ruby_engine ||=
      if defined?(RUBY_ENGINE)
        RUBY_ENGINE
      else
        "ruby"
      end
  end
  
  # Returns the Ruby major and minor version, e.g. "1.8", "1.9".
  def ruby_major_minor_version
    @@ruby_major_minor_version ||= begin
      Config::CONFIG['MAJOR'] + '.' + Config::CONFIG['MINOR']
    end
  end
  
  # Returns whether the current Ruby interpreter supports process forking.
  def self.ruby_supports_fork?
    # MRI >= 1.9.2's respond_to? returns false for methods
    # that are not implemented.
    Process.respond_to?(:fork) &&
      ruby_engine != "jruby" &&
      ruby_engine != "macruby" &&
      Config::CONFIG['target_os'] !~ /mswin|windows|mingw/
  end
  
  # The correct 'gem' command for the current Ruby interpreter.
  def self.gem_command
    locate_ruby_tool('gem')
  end
  memoize :gem_command
  
  # Returns the absolute path to the Rake executable that
  # belongs to the current Ruby interpreter. Returns nil if it
  # doesn't exist.
  #
  # The return value may not be the actual correct invocation
  # for Rake. Use rake_command for that.
  def self.rake
    locate_ruby_executable('rake')
  end
  memoize :rake
  
  # Returns the correct command string for invoking the Rake executable
  # that belongs to the current Ruby interpreter. Returns nil if Rake is
  # not found.
  def self.rake_command
    filename = rake
    # If the Rake executable is a Ruby program then we need to run
    # it in the correct Ruby interpreter just in case Rake doesn't
    # have the correct shebang line; we don't want a totally different
    # Ruby than the current one to be invoked.
    if filename && is_ruby_program?(filename)
      "#{ruby_command} #{filename}"
    else
      # If it's not a Ruby program then it's probably a wrapper
      # script as is the case with e.g. RVM (~/.rvm/wrappers).
      filename
    end
  end
  memoize :rake_command
  
  # Locate a Ruby tool command, e.g. 'gem', 'rake', 'bundle', etc. Instead of
  # naively looking in $PATH, this function uses a variety of search heuristics
  # to find the command that's really associated with the current Ruby interpreter.
  # It should never locate a command that's actually associated with a different
  # Ruby interpreter.
  def self.locate_ruby_tool(name)
    if RUBY_PLATFORM =~ /darwin/ &&
       ruby_command =~ %r(\A/System/Library/Frameworks/Ruby.framework/Versions/.*?/usr/bin/ruby\Z)
      # On OS X we must look for Ruby binaries in /usr/bin.
      # RubyGems puts executables (e.g. 'rake') in there, not in
      # /System/Libraries/(...)/bin.
      filename = "/usr/bin/#{name}"
    else
      filename = File.dirname(ruby_command) + "/#{name}"
    end
  
    if !File.file?(filename) || !File.executable?(filename)
      # RubyGems might put binaries in a directory other
      # than Ruby's bindir. Debian packaged RubyGems and
      # DebGem packaged RubyGems are the prime examples.
      begin
        require 'rubygems' unless defined?(Gem)
        filename = Gem.bindir + "/#{name}"
      rescue LoadError
        filename = nil
      end
    end
  
    if !filename || !File.file?(filename) || !File.executable?(filename)
      # Looks like it's not in the RubyGems bindir. Search in $PATH, but
      # be very careful about this because whatever we find might belong
      # to a different Ruby interpreter than the current one.
      ENV['PATH'].split(':').each do |dir|
        filename = "#{dir}/#{name}"
        if File.file?(filename) && File.executable?(filename)
          shebang = File.open(filename, 'rb') do |f|
            f.readline.strip
          end
          if shebang == "#!#{ruby_command}"
            # Looks good.
            break
          end
        end
      
        # Not found. Try next path.
        filename = nil
      end
    end
  
    filename
  end

private
  def self.is_ruby_program?(filename)
    File.open(filename, 'rb') do |f|
      f.readline =~ /ruby/
    end
  rescue EOFError
    false
  end
  private_class_method :is_ruby_program?
end