require './lib/trapper'

class Loop
  def initialize(sleep_amount)
    @sleep_amount = sleep_amount
    @i = 0
  end

  def run
    while true do
      #c="cee"
      #q="quu"

      print "," unless @i == 0
      print "#{@i}"
      @i += 1
      sleep @sleep_amount
    end
  end
end

sleep_amount = if ARGV[0]
  ARGV[0].to_f
else
  0.5
end

l = Loop.new sleep_amount
Trapper.trap! l
l.run
