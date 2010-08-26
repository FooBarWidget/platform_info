require 'platform_info/depcheck'

PlatformInfo::Depcheck.define('bundler >= 0.9.26') do
  name "Bundler >= 0.9.26"
  website "http://gembundler.com/"
  define_checker do
    found, message = check_for_ruby_library('bundler')
    if found
      begin
        require 'bundler/version'
        if Bundler::VERSION >= '0.9.26'
          [true]
        else
          [false, "only found older version #{Bundler::VERSION}"]
        end
      rescue LoadError
        [false]
      end
    else
      [false]
    end
  end
  
  gem_install "bundler"
end