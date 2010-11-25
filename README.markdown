= Platform information querying library

`platform_info` provides many functions for querying information about the current platform, such as (but not limited to):

 * Information about the currently running Ruby interpreter.
   * Executable filename.
   * Version information.
   * Whether it's managed by RVM.
 * Information about the OS and hardware.
   * OS name and version.
   * Standard file extensions (e.g. shared loadable library extensions,
     .so on most Unices and .bundle on OS X).
   * CPU architecture information.
   * Linux distribution name.
 * Compilation and build information.
   * Location of C and C++ compilers.
   * Whether certain system libraries are available and what compiler flags should be passed in order to link to them (whether -lm is available, -pthread vs -lpthread, etc).
 * Application and library information.
   * Location of Rake, RubyGems, Bundler, etc. Location detection code tries to find the application that's associated with the currently running Ruby interpreter and not those associated with other parallel installed Ruby interpreters.

`platform_info` is extracted from Phusion Passenger, the awesome Ruby web application server. It goes into great lengths to make installation practically any platform easy and straightfoward by detecting platform-specific features and quirks and warning the user appropriately. Now the same power can be in your hands as well.

== Installation and usage

First install it:

    gem install platform_info

`platform_info` is split into different parts. You need to explicitly require the parts that you want. This is in order to save resources in case you don't need everything.

For example, to query the name of the Linux distribution:

    require 'platform_info/linux'
    puts PlatformInfo.linux_distro

Please read the source files in `lib` to discover all of `platform_info`'s functionality.