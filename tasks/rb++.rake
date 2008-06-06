require File.dirname(__FILE__)+'/rbpp_bindings'
  
desc "compile and link the irrklangrb c++ bindings"
namespace :"rb++" do
  task :build do
    sh "ruby lib/cpp/extconf.rb"
    sh "make"
    if(Platform.linux?)
      mv "irrklang.so", "lib/cpp"
    elsif(Platform.mac?)
      mv "irrklang.bundle", "lib/cpp"
    else
      #Windows
    end
    puts "mv irrklang lib/cpp"
  end
  
  desc "Update the rb++ bindings"
  task :generate => [:clean, :generate_rbpp]
  
  task :clean do
    target = File.dirname(__FILE__)+"/../lib/cpp/generated"
    FileUtils.rm_r target if File.directory?(target) 
  end
  
  task :generate_rbpp do
    generate_rbpp
  end
  
  task :rebuild => [:generate, :build]
  task :default => :build
end

