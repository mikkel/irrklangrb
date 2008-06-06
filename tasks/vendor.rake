require 'rubygems'
require 'pmsrb'

include PMS

desc "Update the vendor headers/lib for irrklang"
namespace :vendor do
  work = File.dirname(__FILE__)+"/../tmp"
  irrklang_extensions="irrklang-extensions-#{Irrklang::VERSION::STRING}-#{Platform.short_name}.#{Platform.preferred_archive}"
  
  desc "Download the irrklang SDK from google code."
  task :download do
    PMS::vendor do
      working_directory work
      download "http://irrlicht.piskernig.at/irrKlang-#{Irrklang::VERSION::VENDOR}.zip"
      extract
    end
  end
  
  #desc "Upload the built, platform-specific SDK to the shatteredruby site."
  #task :upload do
    # todo
  #end
  
  desc "Clear out the intermediate built vendor files."
  task :clean do
    FileUtils.mkdir_p work
    FileUtils.rm_r work
    FileUtils.mkdir_p work
  end
  
  desc "Download the Irrklang SDK."  
  task :update =>[:clean, :download]
  
  desc "Upload the platform specific irrklangrb binaries."
  task :upload_extensions => [:clean] do
    # In our extension, we grab the binaries from our website.
    vendor do
      working_directory File.join(File.dirname(__FILE__),'..','lib','cpp')
      archive "*.bundle", irrklang_extensions
      upload irrklang_extensions do
        host "ftp.shatteredruby.com"
        credentials ".shattered_pms"
        target_directory "web/shatteredruby.com/public/vendor"
      end
    end
  end
  
  desc "Download the platform specific irrklangrb binaries."
  task :download_extensions do
    # In our extension, we grab the binaries from our website.
    vendor do
      working_directory File.join(File.dirname(__FILE__),'..','lib','cpp')
      download "http://shatteredruby.com/vendor/#{irrklang_extensions}"
      extract
      rm irrklang_extensions
    end
    
  end
  task :default => :update  
end
