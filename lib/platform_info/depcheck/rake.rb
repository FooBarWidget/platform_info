require 'platform_info/depcheck'

# This checker looks for a Rake instance that's installed for the same
# Ruby interpreter as the one that's currently running.
# For example if you're running this 'rake.rb' file with Ruby 1.8, then
# this checker will not find Ruby 1.9's Rake or JRuby's Rake. Use
# 'rake-any' for that.
PlatformInfo::Depcheck.define('rake') do
  name "Rake (associated with #{ruby_command})"
  website "http://rake.rubyforge.org/"
  define_checker do
    check_for_ruby_tool('rake')
  end
  
  if ruby_command =~ %r(^/usr/bin/ruby)
    # Only tell user to install Rake with the system's package manager
    # if Ruby itself was installed with the package manager.
    on :debian do
      apt_get_install "rake"
    end
    on :mandriva do
      urpmi "rake"
    end
    on :redhat do
      yum_install "rake"
    end
  end
  on :other_platforms do
    gem_install "rake"
  end
end

PlatformInfo::Depcheck.define('rake-any') do
  name "Rake"
  website "http://rake.rubyforge.org/"
  define_checker do
    check_for_command('rake')
  end
  
  on :debian do
    apt_get_install "rake"
  end
  on :mandriva do
    urpmi "rake"
  end
  on :redhat do
    yum_install "rake"
  end
  on :other_platforms do
    gem_install "rake"
  end
end