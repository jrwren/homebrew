require 'extend/pathname'
require 'extend/ARGV'
require 'extend/string'
require 'utils'

ARGV.extend(HomebrewArgvExtension)

THIS_IS_LINUX = RUBY_PLATFORM.downcase.include?("linux")
THIS_IS_OSX = RUBY_PLATFORM.downcase.include?("darwin")

def on_osx
  yield if THIS_IS_OSX and block_given?
  THIS_IS_OSX
end

def on_linux
  yield if THIS_IS_LINUX and block_given?
  THIS_IS_LINUX
end

def assert_osx
  abort "This is not Mac OS X!" unless on_osx
end

def assert_linux
  abort "This is not Linux!" unless on_linux
end

HOMEBREW_VERSION = '0.7.1'
HOMEBREW_WWW = 'http://mxcl.github.com/homebrew/'

if not defined? HOMEBREW_BREW_FILE
  HOMEBREW_BREW_FILE = ENV['HOMEBREW_BREW_FILE'] || `which brew`.chomp
end

HOMEBREW_PREFIX = Pathname.new(HOMEBREW_BREW_FILE).dirname.parent # Where we link under
HOMEBREW_REPOSITORY = Pathname.new(HOMEBREW_BREW_FILE).realpath.dirname.parent # Where .git is found

if on_osx
  if Process.uid == 0
    # technically this is not the correct place, this cache is for *all users*
    # so in that case, maybe we should always use it, root or not?
    HOMEBREW_CACHE=Pathname.new("/Library/Caches/Homebrew")
  else
    HOMEBREW_CACHE=Pathname.new("~/Library/Caches/Homebrew").expand_path
  end
else
  HOMEBREW_CACHE=Pathname.new(HOMEBREW_REPOSITORY+"Library/Caches")
end

# Where we store built products; /usr/local/Cellar if it exists,
# otherwise a Cellar relative to the Repository.
if (HOMEBREW_PREFIX+'Cellar').exist?
  HOMEBREW_CELLAR = HOMEBREW_PREFIX+'Cellar'
else
  HOMEBREW_CELLAR = HOMEBREW_REPOSITORY+'Cellar'
end

if on_osx
  MACOS_FULL_VERSION = `/usr/bin/sw_vers -productVersion`.chomp
  MACOS_VERSION = /(10\.\d+)(\.\d+)?/.match(MACOS_FULL_VERSION).captures.first.to_f
  HOMEBREW_USER_AGENT = "Homebrew #{HOMEBREW_VERSION} (Ruby #{RUBY_VERSION}-#{RUBY_PATCHLEVEL}; Mac OS X #{MACOS_FULL_VERSION})"

  RECOMMENDED_LLVM = 2326
  RECOMMENDED_GCC_40 = (MACOS_VERSION >= 10.6) ? 5494 : 5493
  RECOMMENDED_GCC_42 = (MACOS_VERSION >= 10.6) ? 5664 : 5577

elsif on_linux
  LINUX_ISSUE = /(.*?) \\n/.match(`cat /etc/issue`.chomp).captures.first
  LINUX_VERSION = `uname -r`.chomp
  LINUX_FULL_VERSION = "#{LINUX_ISSUE} (#{LINUX_VERSION})"
  HOMEBREW_USER_AGENT = "Homebrew #{HOMEBREW_VERSION} (Ruby #{RUBY_VERSION}-#{RUBY_PATCHLEVEL}; #{LINUX_FULL_VERSION})"

else
  abort "I am not sure what OS I'm executing on. Bye!"
end
