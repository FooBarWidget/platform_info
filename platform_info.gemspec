Gem::Specification.new do |s|
  s.name = "platform_info"
  s.version = "1.0.0"
  s.summary = "Provides functions for querying platform-specific information"
  s.email = "info@phusion.nl"
  s.homepage = "http://github.com/FooBarWidget/platform_info"
  s.authors = ["Hongli Lai"]
  s.files = ['platform_info.gemspec',
    'LICENSE.TXT', 'README.markdown',
    'lib/platform_info.rb',
    'lib/platform_info/binary_compatibility.rb',
    'lib/platform_info/linux.rb',
    'lib/platform_info/operating_system.rb',
    'lib/platform_info/ruby.rb',
    'lib/platform_info/depcheck.rb',
    'lib/platform_info/depcheck/bundler.rb',
    'lib/platform_info/depcheck/compiler_toolchain.rb',
    'lib/platform_info/depcheck/rake.rb',
    'lib/platform_info/depcheck/ruby.rb',
    'lib/platform_info/depcheck/rubygems.rb'
  ]
end
