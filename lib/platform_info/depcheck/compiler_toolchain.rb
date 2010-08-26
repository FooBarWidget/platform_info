require 'platform_info/depcheck'

PlatformInfo::Depcheck.define('gcc') do
  name "GNU C compiler"
  website "http://gcc.gnu.org/"
  define_checker do
    check_for_command('gcc')
  end
  
  on :debian do
    apt_get_install "build-essential"
  end
  on :mandriva do
    urpmi "gcc"
  end
  on :redhat do
    yum_install "gcc"
  end
  on :gentoo do
    emerge "gcc"
  end
  on :macosx do
    install_instructions "Please install the Apple Development Tools: http://developer.apple.com/tools/"
  end
end

PlatformInfo::Depcheck.define('g++') do
  name "GNU C++ compiler"
  website "http://gcc.gnu.org/"
  define_checker do
    check_for_command('g++')
  end
  
  on :debian do
    apt_get_install "build-essential"
  end
  on :mandriva do
    urpmi "gcc-c++"
  end
  on :redhat do
    yum_install "gcc-c++"
  end
  on :gentoo do
    emerge "gcc"
  end
  on :macosx do
    install_instructions "Please install the Apple Development Tools: http://developer.apple.com/tools/"
  end
end

PlatformInfo::Depcheck.define('make') do
  name "The 'make' tool"
  website "http://www.gnu.org/software/make/"
  define_checker do
    check_for_command('make')
  end
  
  on :debian do
    apt_get_install "build-essential"
  end
  on :mandriva do
    urpmi "make"
  end
  on :redhat do
    yum_install "make"
  end
  on :macosx do
    install_instructions "Please install the Apple Development Tools: http://developer.apple.com/tools/"
  end
end