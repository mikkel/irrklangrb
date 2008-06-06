
%w( cpp/irrklang irrklang/version ).each do |file|
  begin
    require File.join(File.dirname(__FILE__), file)
  rescue LoadError
    puts "#{file} not found."
  end
end
