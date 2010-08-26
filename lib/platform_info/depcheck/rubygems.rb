require 'platform_info/depcheck'

PlatformInfo::Depcheck.define('rubygems') do
  name "RubyGems"
  website "http://rubyforge.org/frs/?group_id=126"
  define_checker do
    begin
      require 'rubygems'
      [true]
    rescue LoadError
      [false]
    end
  end
  
  # Debian has totally messed up RubyGems by patching it to install binaries
  # to /var/lib/gems/bin instead of /usr/bin or even /usr/local/bin. That
  # wouldn't be so much of a problem were it not for the fact that
  # /var/lib/gems/bin is not in $PATH by default, so on a regular basis people
  # ask various Ruby/Rails support forums why they get a 'foo: command not found'
  # after typing 'gem install foo'. Because of this I cannot recommend people
  # to install RubyGems through apt-get. If they want to do it anyway that's
  # their choice but I'm not gonna provide the option in the instructions.
  on :other_platforms do
    install_instructions "Please download it from <b>#{website}</b>. " +
  		"Extract the tarball, and run <b>ruby setup.rb</b>"
  end
end

PlatformInfo::Depcheck.define('rubygems >= 1.3.6') do
  name "RubyGems >= 1.3.6"
  website "http://rubyforge.org/frs/?group_id=126"
  define_checker do
    begin
      require 'rubygems'
      [Gem::VERSION >= '1.3.6']
    rescue LoadError
      [false]
    end
  end
  
  # See comment for the 'rubygems' depcheck.
  on :other_platforms do
    install_instructions "Please download it from <b>#{website}</b>. " +
  		"Extract the tarball, and run <b>ruby setup.rb</b>"
  end
end