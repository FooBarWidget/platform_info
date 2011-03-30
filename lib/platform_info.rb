# encoding: binary

module PlatformInfo
private
  @@memoize = true
  @@cache_dir = nil
  
  def self.private_class_method(name)
    metaclass = class << self; self; end
    metaclass.send(:private, name)
  end
  private_class_method :private_class_method
  
  # Turn the specified class method into a memoized one. If the given
  # class method is called without arguments, then its result will be
  # memoized, frozen, and returned upon subsequent calls without arguments.
  # Calls with arguments are never memoized.
  #
  # If +cache_to_disk+ is true and a cache directory has been set with
  # <tt>PlatformInfo.cache_dir=</tt> then result is cached to a file on disk,
  # so that memoized results persist over multiple process runs. This
  # cache file expires in +cache_time+ seconds (1 hour by default) after
  # it has been written.
  #
  #   def self.foo(max = 10)
  #     rand(max)
  #   end
  #   memoize :foo
  #   
  #   foo        # => 3
  #   foo        # => 3
  #   foo(100)   # => 49
  #   foo(100)   # => 26
  #   foo        # => 3
  def self.memoize(method, cache_to_disk = false, cache_time = 3600)
    # We use class_eval here because Ruby 1.8.5 doesn't support class_variable_get/set.
    metaclass = class << self; self; end
    metaclass.send(:alias_method, "_unmemoized_#{method}", method)
    variable_name = "@@memoized_#{method}".sub(/\?/, '')
    check_variable_name = "@@has_memoized_#{method}".sub(/\?/, '')
    eval(%Q{
      #{variable_name} = nil
      #{check_variable_name} = false
    })
    line = __LINE__ + 1
    source = %Q{
      def self.#{method}(*args)                                           # def self.httpd(*args)
        if @@memoize && args.empty?                                       #   if @@memoize && args.empty?
          if !#{check_variable_name}                                      #     if !@@has_memoized_httpd
            if @@cache_dir                                                #       if @@cache_dir
              cache_file = File.join(@@cache_dir, "#{method}")            #         cache_file = File.join(@@cache_dir, "httpd")
            end                                                           #       end
            read_from_cache_file = false                                  #       read_from_cache_file = false
            if #{cache_to_disk} && cache_file && File.exist?(cache_file)  #       if #{cache_to_disk} && File.exist?(cache_file)
              cache_file_stat = File.stat(cache_file)                     #         cache_file_stat = File.stat(cache_file)
              read_from_cache_file =                                      #         read_from_cache_file =
                Time.now - cache_file_stat.mtime < #{cache_time}          #           Time.now - cache_file_stat.mtime < #{cache_time}
            end                                                           #       end
            if read_from_cache_file                                       #       if read_from_cache_file
              data = File.read(cache_file)                                #         data = File.read(cache_file)
              #{variable_name} = Marshal.load(data).freeze                #         @@memoized_httpd = Marshal.load(data).freeze
              #{check_variable_name} = true                               #         @@has_memoized_httpd = true
            else                                                          #       else
              #{variable_name} = _unmemoized_#{method}.freeze             #         @@memoized_httpd = _unmemoized_httpd.freeze
              #{check_variable_name} = true                               #         @@has_memoized_httpd = true
              if cache_file && #{cache_to_disk}                           #         if cache_file && #{cache_to_disk}
                begin                                                     #           begin
                  if !File.directory?(@@cache_dir)                        #             if !File.directory?(@@cache_dir)
                    Dir.mkdir(@@cache_dir)                                #               Dir.mkdir(@@cache_dir)
                  end                                                     #             end
                  File.open(cache_file, "wb") do |f|                      #             File.open(cache_file, "wb") do |f|
                    f.write(Marshal.dump(#{variable_name}))               #               f.write(Marshal.dump(@@memoized_httpd))
                  end                                                     #             end
                rescue Errno::EACCES                                      #           rescue Errno::EACCES
                  # Ignore permission error.                              #             # Ignore permission error.
                end                                                       #           end
              end                                                         #         end
            end                                                           #       end
          end                                                             #     end
          #{variable_name}                                                #     @@memoized_httpd
        else                                                              #   else
          _unmemoized_#{method}(*args)                                    #     _unmemoized_httpd(*args)
        end                                                               #   end
      end                                                                 # end
    }
    class_eval(source, __FILE__, line)
  end
  private_class_method :memoize
  
  # Look in the directory +dir+ and check whether there's an executable
  # whose base name is equal to one of the elements in +possible_names+.
  # If so, returns the full filename. If not, returns nil.
  def self.select_executable(dir, *possible_names)
    possible_names.each do |name|
      filename = "#{dir}/#{name}"
      if File.file?(filename) && File.executable?(filename)
        return filename
      end
    end
    nil
  end
  private_class_method :select_executable
  
  def self.read_file(filename)
    File.read(filename)
  rescue
    ""
  end
  private_class_method :read_file

public
  def self.memoize?
    @@memoize
  end

  def self.memoize=(enabled)
    @@memoize = enabled
  end

  def self.cache_dir
    @@cache_dir
  end
  
  def self.cache_dir=(value)
    @@cache_dir = value
  end
  
  # Check whether the specified command is in $PATH, and return its
  # absolute filename. Returns nil if the command is not found.
  #
  # This function exists because system('which') doesn't always behave
  # correctly, for some weird reason.
  def self.find_command(name)
    name = name.to_s
    ENV['PATH'].to_s.split(File::PATH_SEPARATOR).detect do |directory|
      path = File.join(directory, name.to_s)
      if File.file?(path) && File.executable?(path)
        return path
      end
    end
    nil
  end
end
