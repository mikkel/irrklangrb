require File.dirname(__FILE__)+'/../lib/irrklangrb'

puts "Irrklang starting up using version #{Irrklang::VERSION::VENDOR}"

engine = Irrklang::create_default_device()#Irrklang::E_SOUND_OUTPUT_DRIVER::ESOD_AUTO_DETECT, 0xFFFFFF, "", Irrklang::VERSION::VENDOR	)
puts engine.inspect

#engine.play2_d_0(soundFileName,playLooped,startPaused,track,streamMode,enableSoundEffects)
song = File.expand_path(File.dirname(__FILE__)+"/media/getout.ogg")

song = engine.play2_d_0(song, true, false, true, Irrklang::E_STREAM_MODE::ESM_AUTO_DETECT, false)
puts song.is_finished.inspect
#puts engine.get_default_3_d_sound_min_distance.inspect
loop do
end

se.close
