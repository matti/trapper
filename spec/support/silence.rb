require './lib/trapper'

class Silence
  def initialize
    @silent = true
  end

  def be_silent
    puts "ssssh..."
    while @silent
      sleep 1
    end
  end
end

s = Silence.new
Trapper.trap! s

s.be_silent
