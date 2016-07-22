Signal.trap("INT") do
  exit 1 if $trapper_exit # subsequent ^C pressed traps INT again

  print "\n\n"
  only_c_unless_defined = if (eval "defined? c")
    puts "WARN: you have defined `c`, use c!! to continue"
    nil
  else
    "c"
  end

  only_q_unless_defined = if (eval "defined? q")
    puts "WARN: you have defined `q`, use q!! to quit"
    nil
  else
    "q"
  end

  while true do
    print "trapper> "
    input = $stdin.gets.chomp

    case input
    when "q!!", only_q_unless_defined
      $trapper_exit = true
      puts "bye."
      exit 1
    when "c!!", only_c_unless_defined
      break
    end

    output = nil
    begin
      output = eval input
    rescue SyntaxError => se
      output = se.to_s
    rescue => ex
      output = "#{ex.class}: #{ex.to_s}"
    end

    puts output
  end
end

i = 0
while true do
  #c="cee"
  #q="quu"

  print "," if i > 0
  print "#{i}"
  i += 1
  sleep 0.5
end
