begin
  # Try in the dev directory first.
  require File.join(File.dirname(__FILE__), "..", "..", "rbplusplus", "lib", "rbplusplus")
rescue LoadError
  require 'rubygems'
  require 'rbplusplus'
end

require 'fileutils'

$root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
require File.join($root, 'lib', 'irrklang', 'version')
  
$irrklang_home = File.join($root, "tmp", "irrKlang-#{Irrklang::VERSION::VENDOR}")
$cpp_home = File.join($root, "lib", "cpp")


# This method generates the extension into lib/cpp/generated and compiles it
def generate_rbpp
  e = RbPlusPlus::Extension.new "irrklang"
  e.working_dir=File.join($cpp_home, "generated")
  
  lib_path = ""
  Platform.mac do
    lib_path << File.expand_path("#{$irrklang_home}/bin/macosx-gcc")
  end
  # todo linux/windows
    
  e.sources(File.join($irrklang_home, "include", "*.h"), 
              :include_paths  => [File.join($irrklang_home, "include")],
              :includes       => [File.join($irrklang_home, "include", "irrKlang.h"), File.join($cpp_home, "helper.h")],
              :library_paths  => lib_path,
              :ldflags => "#{lib_path}/libirrklang.dylib" #todo #{lib_path}/ikpMP3.dylib 
            )

  
  e.module "Irrklang" do |m| 
    ns = m.namespace "irrklang"
    filter_namespace(ns)
    ns.functions("createIrrKlangDevice").wrap_as("create_default_device").calls("create_default_device")
  end
  
  puts "creating bindings..."
  e.build
  e.write
  
  FileUtils.cp($cpp_home+'/helper.cpp', $cpp_home+"/generated")
  
  puts "compiling... this may take a while"
  e.compile
  
  FileUtils.rm($cpp_home+"/generated/helper.cpp")
  
  ext = "bundle" if Platform.mac?
  ext = "dll" if Platform.windows?
  ext = "so" if Platform.linux?
  
  if !File.exists?(e.working_dir+"/irrklang.#{ext}")
    puts "Error compiling, check the logs"
  else
    FileUtils.cp(e.working_dir+"/irrklang.#{ext}", $cpp_home)
  
    puts "Testing require"
    require $cpp_home+'/irrklang'
  end
  
end


def filter_namespace(node)
  node.classes.each do |cls|
    
    if(blacklist_name(cls.name))
      puts "Skipped class #{cls.name}"  
      cls.ignore
    else
      methods_hash = {}
      cls.methods.sort_by { |method| method.name}.each do |method|
        # if methods_hash[method.name]
        #   methods_hash[method.name].ignore
        #   method.ignore
        #   puts "  ignoring #{method.name} due to overloading"
        # end
        # methods_hash[method.name] = method
  
        #/[gsGS]et.*Func$/ === method.name
        #  method.ignore 
        #  puts "  ignoring #{method.name} for using void *"
    
  
        if blacklist_name method.attributes["demangled"]
          method.ignore
        else
          #puts "  #{method.name}"
        end
      end
  
      cls.constructors.each do |constructor|
        if blacklist_name(constructor.attributes["demangled"])
          puts "ignoring #{cls.name} constructor for using blacklisted type"
          constructor.ignore
        end
      end
    end
  end
  
  node.structs.each do |struct|
    puts "exporting struct #{struct.name}"
  end
end

# custom ignore an element
def ignore(node)
  puts "ignoring #{node.name} - custom ignore"
  node.ignore
end

# returns true if the cls is blacklisted
def blacklist(cls)
  blacklist_name cls.qualified_name
end

# returns true if the string name contains blacklisted elements
def blacklist_name(name)
  
  {
    :getAudioFormat => "uses 'const irrklang::SAudioStreamFormat&' - FIXABLE",
    :getFormat => "uses 'const irrklang::SAudioStreamFormat&' - FIXABLE",
    :getRecordedAudioData => "uses 'void *'",
    :getPosition => "'typedef float ik_f32;' doesn't seem to get recognized.",
    :getVelocity => "uses 'const const irrklang::vec3d<irrklang::ik_f32>&' - FIXABLE",
#    :play2D => "?overloaded?",
#    :play3D => "?",
#    :getSoundSource => "?",
#    :removeSoundSource => "?",
#    :isCurrentlyPlaying => "?",
    :getStreamMode => "const irrklang::E_STREAM_MODE& FIXABLE",
#    "::set\\(" => "?overloaded?",
    :crossProduct => "const irrklang::vec3d<irrklang::ik_f32>& FIXABLE",
    :normalize => 'const irrklang::vec3d<irrklang::ik_f32>& FIXABLE',
    :getInterpolated => 'const irrklang::vec3d<irrklang::ik_f32>& FIXABLE',
    :getHorizontalAngle => 'const irrklang::vec3d<irrklang::ik_f32>& FIXABLE',
  }.each do |blacklist_name, reason|
    if name =~ /#{blacklist_name}/
      puts "Blacklisting '#{name}' - #{reason}"
      return true
    end
  end
  
  return false
end
