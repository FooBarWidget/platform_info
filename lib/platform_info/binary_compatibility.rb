require 'platform_info'
require 'platform_info/operating_system'
require 'platform_info/ruby'

module PlatformInfo
  # Returns an array of identifiers that describe the current Ruby
  # interpreter's extension binary compatibility. A Ruby extension
  # compiled for a certain Ruby interpreter can also be loaded on
  # a different Ruby interpreter with the same binary compatibility
  # identifiers.
  #
  # The identifiers depend on the following factors:
  # - Ruby engine name.
  # - Ruby extension version.
  #   This is not the same as the Ruby language version, which
  #   identifies language-level compatibility. This is rather about
  #   binary compatibility of extensions.
  #   MRI seems to break source compatibility between tiny releases,
  #   though patchlevel releases tend to be source and binary
  #   compatible.
  # - Ruby extension architecture.
  #   This is not necessarily the same as the operating system
  #   runtime architecture or the CPU architecture.
  #   For example, in case of JRuby, the extension architecture is
  #   just "java" because all extensions target the Java platform;
  #   the architecture the JVM was compiled for has no effect on
  #   compatibility.
  #   On systems with universal binaries support there may be multiple
  #   architectures. In this case the architecture is "universal"
  #   because extensions must be able to support all of the Ruby
  #   executable's architectures.
  # - The operating system for which the Ruby interpreter was compiled.
  def self.ruby_extension_binary_compatibility_ids
    ruby_ext_version = RUBY_VERSION
    if RUBY_PLATFORM =~ /darwin/
      if RUBY_PLATFORM =~ /universal/
        ruby_arch = "universal"
      else
        # Something like:
        # "/opt/ruby-enterprise/bin/ruby: Mach-O 64-bit executable x86_64"
        ruby_arch = `file -L "#{ruby_executable}"`.strip
        ruby_arch.sub!(/.* /, '')
      end
    elsif RUBY_PLATFORM == "java"
      ruby_arch = "java"
    else
      # In theory the Ruby interpreter's architecture may be different
      # from the OS's main architecture even on operating systems other
      # than MacOS X. For example people running on x86_64 Linux having
      # compiled Ruby for x86. But does this really happen in practice?
      # I don't want to bother writing more code to detect that. If
      # somebody has a problem he should file a bug report.
      ruby_arch = cpu_architectures[0]
    end
    [ruby_engine, ruby_ext_version, ruby_arch, os_name]
  end
  memoize :ruby_extension_binary_compatibility_ids
end