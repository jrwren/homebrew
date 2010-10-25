require 'set'

class Hardware
  # These methods use info spewed out by sysctl.
  # Look in <mach/machine.h> for decoding info.

  @@cpuinfo = nil
  
  def self.cpu_type
    # TODO: do better
    :intel
  end

  def self.intel_family
    # TODO: do better
    :dunno
  end

  def self.processor_count
    Hardware.proc_cpuinfo[:processor].size
  end
  
  def self.cores_as_words
    case Hardware.processor_count
    when 1 then 'single'
    when 2 then 'dual'
    when 4 then 'quad'
    else
      Hardware.processor_count
    end
  end

  def self.is_32_bit?
    not self.is_64_bit?
  end

  def self.is_64_bit?
    Hardware.proc_cpuinfo[:flags].each do |core_flags|
      if core_flags.include? 'lm' # "Long mode" => 64-bit
        return true
      end
    end
    false
  end
  
  def self.bits
    Hardware.is_64_bit? ? 64 : 32
  end

protected
  def self.proc_cpuinfo
    if @@cpuinfo.nil?
      info = Hash.new()
      cpu_dump = `cat /proc/cpuinfo`.chomp
      cpu_dump.split(/\n/).each do |x|
        if x.size != 0
          k, v = x.split(/\s*:\s*/)
          if k == 'processor'
            info[:processor] ||= []
            info[:processor] << v.to_i
          elsif k == 'flags'
            info[:flags] ||= []
            info[:flags] << Set.new(v.split)
          end
        end
      end
      @@cpuinfo = info
    end
    @@cpuinfo
  end
end

def snow_leopard_64?
  on_osx and MACOS_VERSION >= 10.6 and Hardware.is_64_bit?
end
