require 'platform_info/depcheck'

PlatformInfo::Depcheck.define('ruby-dev') do
  name "Ruby development headers"
  website "http://www.ruby-lang.org/"
  define_checker do
    require 'rbconfig'
    begin
      require 'mkmf'
      header_dir = ::Config::CONFIG['rubyhdrdir'] || ::Config::CONFIG['archdir']
      filename = "#{header_dir}/ruby.h"
      if File.exist?(filename)
        [true, filename]
      else
        [false]
      end
    rescue LoadError, SystemExit
      # On RedHat/Fedora/CentOS, if ruby-devel is not installed then
      # mkmf.rb will print an error and call 'exit'. So here we
      # catch SystemExit as well.
      [false]
    end
  end
  
  if ruby_command =~ %r(^/usr/bin/ruby)
    # Only tell user to install the headers with the system's package manager
    # if Ruby itself was installed with the package manager.
    on :debian do
      apt_get_install "ruby-dev"
    end
    on :mandriva do
      urpmi "ruby-devel"
    end
    on :redhat do
      yum_install "ruby-devel"
    end
  end
  on :other_platforms do
    install_instructions "Please reinstall Ruby by downloading it from <b>#{website}</b>"
  end
end
