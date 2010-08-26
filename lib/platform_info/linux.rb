require 'platform_info'
require 'platform_info/operating_system'

module PlatformInfo
  # An identifier for the current Linux distribution. nil if the operating system
  # is not Linux.
  def self.linux_distro
    tags = linux_distro_tags
    if tags
      return tags.first
    else
      return nil
    end
  end
  
  # Autodetects the current Linux distribution and returns a number
  # of identifier tags. The first tag identifies the distribution
  # while the other tags indicate which distributions it is likely
  # compatible with.
	# Returns [] if the operating system is not Linux.
  def self.linux_distro_tags
    return [] if os_name != "linux"
    @@linux_distro_tags ||= begin
      lsb_release = read_file("/etc/lsb-release")
      if lsb_release =~ /Ubuntu/
        [:ubuntu, :debian]
      elsif File.exist?("/etc/debian_version")
        [:debian]
      elsif File.exist?("/etc/redhat-release")
        redhat_release = read_file("/etc/redhat-release")
        if redhat_release =~ /CentOS/
          [:centos, :redhat]
        elsif redhat_release =~ /Fedora/
          [:fedora, :redhat]
        elsif redhat_release =~ /Mandriva/
          [:mandriva, :redhat]
        else
          # On official RHEL distros, the content is in the form of
          # "Red Hat Enterprise Linux Server release 5.1 (Tikanga)"
          [:rhel, :redhat]
        end
      elsif File.exist?("/etc/suse-release")
        [:suse]
      elsif File.exist?("/etc/gentoo-release")
        [:gentoo]
      else
        []
      end
    end
  end
end