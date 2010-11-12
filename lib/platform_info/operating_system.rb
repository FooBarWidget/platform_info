require 'platform_info'
require 'rbconfig'

module PlatformInfo
  # Returns the operating system's name. This name is in lowercase and contains no spaces,
  # and thus is suitable to be used in some kind of ID. E.g. "linux", "macosx".
  def self.os_name
    if Config::CONFIG['target_os'] =~ /darwin/ && (sw_vers = find_command('sw_vers'))
      "macosx"
    elsif RUBY_PLATFORM == "java"
      Config::CONFIG['target_os']
    else
      RUBY_PLATFORM.sub(/.*?-/, '')
    end
  end
  memoize :os_name
  
  # The current platform's shared library extension ('so' on most Unices).
  def self.library_extension
    if os_name == "macosx"
      "bundle"
    else
      "so"
    end
  end
  
  # Returns a list of all CPU architecture names that the current machine CPU
  # supports. If there are multiple such architectures then the first item in
  # the result denotes that OS runtime's main/preferred architecture.
  #
  # This function normalizes some names. For example x86 is always reported
  # as "x86" regardless of whether the OS reports it as "i386" or "i686".
  # x86_64 is always reported as "x86_64" even if the OS reports it as "amd64".
  #
  # Please note that even if the CPU supports multiple architectures, the
  # operating system might not. For example most x86 CPUs nowadays also
  # support x86_64, but x86_64 Linux systems require various x86 compatibility
  # libraries to be installed before x86 executables can be run. This function
  # does not detect whether these compatibility libraries are installed.
  # The only guarantee that you have is that the OS can run executables in
  # the architecture denoted by the first item in the result.
  #
  # For example, on x86_64 Linux this function can return ["x86_64", "x86"].
  # This indicates that the CPU supports both of these architectures, and that
  # the OS's main/preferred architecture is x86_64. Most executables on the
  # system are thus be x86_64. It is guaranteed that the OS can run x86_64
  # executables, but not x86 executables per se.
  #
  # Another example: on MacOS X this function can return either
  # ["x86_64", "x86"] or ["x86", "x86_64"]. The former result indicates
  # OS X 10.6 (Snow Leopard) and beyond because starting from that version
  # everything is 64-bit by default. The latter result indicates an OS X
  # version older than 10.6.
  def self.cpu_architectures
    if os_name == "macosx"
      arch = `uname -p`.strip
      if arch == "i386"
        # Macs have been x86 since around 2007. I think all of them come with
        # a recent enough Intel CPU that supports both x86 and x86_64, and I
        # think every OS X version has both the x86 and x86_64 runtime installed.
        major, minor, *rest = `sw_vers -productVersion`.strip.split(".")
        major = major.to_i
        minor = minor.to_i
        if major >= 10 || (major == 10 && minor >= 6)
          # Since Snow Leopard x86_64 is the default.
          ["x86_64", "x86"]
        else
          # Before Snow Leopard x86 was the default.
          ["x86", "x86_64"]
        end
      else
        arch
      end
    else
      arch = `uname -p`.strip
      # On some systems 'uname -p' returns something like
      # 'Intel(R) Pentium(R) M processor 1400MHz'.
      if arch == "unknown" || arch =~ / /
        arch = `uname -m`.strip
      end
      if arch =~ /^i.86$/
        arch = "x86"
      elsif arch == "amd64"
        arch = "x86_64"
      end
      
      if arch == "x86"
        # Most x86 operating systems nowadays are probably running on
        # a CPU that supports both x86 and x86_64, but we're not gonna
        # go through the trouble of checking that. The main architecture
        # is what we usually care about.
        ["x86"]
      elsif arch == "x86_64"
        # I don't think there's a single x86_64 CPU out there
        # that doesn't support x86 as well.
        ["x86_64", "x86"]
      else
        [arch]
      end
    end
  end
  memoize :cpu_architectures
end
