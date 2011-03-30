require 'platform_info/ruby'
require 'platform_info/linux'

module PlatformInfo
  module Depcheck
    @@database = {}
  
    def self.define(name, &block)
      @@database[name.to_s] = block
    end
  
    def self.find(name)
      # We lazy-initialize everything in order to save resources. This also
      # allows blocks to perform relatively expensive checks without hindering
      # startup time.
      result = @@database[name.to_s]
      if result.is_a?(Proc)
        result = Dependency.new(&result)
        @@database[name.to_s] = result
      end
      result
    end
  
    class Dependency
      def initialize(&block)
        instance_eval(&block)
      end
    
      def name(value = nil)
        value ? @name = value : @name
      end
    
      def website(value = nil)
        value ? @website = value : @website
      end
    
      def website_comments(value = nil)
        value ? @website_comments = value : @website_comments
      end
    
      def install_instructions(value = nil)
        if value
          @install_instructions = value
        else
          if @install_instructions
            @install_instructions
          elsif @website
            result = "Please download it from <b>#{@website}</b>"
            result << "\n(#{@website_comments})" if @website_comments
          else
            "Search Google."
          end
        end
      end
    
      def check
        @check_result ||= @checker.call
      end
  
    private
      def define_checker(&block)
        @checker = block
      end
    
      def check_for_command(name)
        result = find_command(name)
        if result
          [true, result]
        else
          [false]
        end
      end
    
      def check_for_ruby_tool(name)
        result = locate_ruby_tool(name)
        if result
          [true, result]
        else
          [false]
        end
      end
    
      def check_for_header(name, language = :c, cflags = nil, linkflags = nil)
        source = %Q{
          #include <#{name}>
          int main() { return 0; }
        }
        check_by_compiling(source, language, clfags, linkflags)
      end
    
      def check_for_library(name)
        check_by_compiling("int main() { return 0; }", :cxx, nil, "-l#{name}")
      end
    
      def check_by_compiling(source, language = :c, cflags = nil, linkflags = nil)
        case language
        when :c
          source_file    = "#{PlatformInfo.tmpexedir}/depcheck-#{Process.pid}-#{Thread.current.object_id}.c"
          compiler       = "gcc"
          compiler_flags = ENV['CFLAGS']
        when :cxx
          source_file    = "#{PlatformInfo.tmpexedir}/depcheck-#{Process.pid}-#{Thread.current.object_id}.cpp"
          compiler       = "g++"
          compiler_flags = "#{ENV['CFLAGS']} #{ENV['CXXFLAGS']}".strip
        else
          raise ArgumentError, "Unknown language '#{language}"
        end
      
        output_file = "#{PlatformInfo.tmpexedir}/depcheck-#{Process.pid}-#{Thread.current.object_id}"
      
        begin
          File.open(source_file, 'w') do |f|
            f.puts(source)
          end
        
          if find_command(compiler)
            command = "#{compiler} #{compiler_flags} #{cflags} " +
              "#{source_file} -o #{output_file} #{linkflags}"
            [!!system(command)]
          else
            [:unknown, "Cannot check: compiler '#{compiler}' not found."]
          end
        ensure
          File.unlink(source_file) rescue nil
          File.unlink(output_file) rescue nil
        end
      end
    
      def check_for_ruby_library(name)
        begin
          require(name)
          [true]
        rescue LoadError
          if defined?(Gem)
            [false]
          else
            begin
              require 'rubygems'
              require(name)
              [true]
            rescue LoadError
              [false]
            end
          end
        end
      end
    
      def on(platform)
        return if @on_invoked
        if linux_distro_tags.include?(platform)
          yield
        else
          case platform
          when :linux
            yield if PlatformInfo.os_name =~ /linux/
          when :freebsd
            yield if PlatformInfo.os_name =~ /freebsd/
          when :macosx
            yield if PlatformInfo.os_name == "macosx"
          when :solaris
            yield if PlatformInfo.os_name =~ /solaris/
          when :other_platforms
            yield
          end
        end
        @on_invoked = true
      end
    
      def apt_get_install(package_name)
        install_instructions("Please install it with <b>apt-get install #{package_name}</b>")
      end
    
      def urpmi(package_name)
        install_instructions("Please install it with <b>urpmi #{package_name}</b>")
      end
    
      def yum_install(package_name)
        install_instructions("Please install it with <b>yum install #{package_name}</b>")
      end
    
      def emerge(package_name)
        install_instructions("Please install it with <b>emerge -av #{package_name}</b>")
      end
    
      def gem_install(package_name)
        install_instructions("Please make sure RubyGems is installed, then run " +
          "<b>#{gem_command || 'gem'} install #{package_name}</b>")
      end
    
    
      def ruby_command
        PlatformInfo.ruby_command
      end
    
      def gem_command
        PlatformInfo.gem_command
      end
    
      def find_command(command)
        PlatformInfo.find_command(command)
      end
    
      def linux_distro_tags
        PlatformInfo.linux_distro_tags
      end
    
      def locate_ruby_tool(name)
        PlatformInfo.locate_ruby_tool(name)
      end
    end # class Dependency
  end # module Depcheck
end # module PlatformInfo