module Trapper
end

require_relative "trapper/version"

$stdout.sync=true

module Trapper

  def self.trap!(__trapper_obj)
    __trapper_obj.instance_eval {
      Signal.trap("INT") do
        exit 1 if $__trapper_exit # subsequent ^C pressed traps INT again

        print "\n\n"

        while true do
          print "trapper> "
          __trapper_input = $stdin.gets.chomp

          case __trapper_input.downcase
          when "q"
            $__trapper_exit = true
            puts "bye."
            exit 1
          when "c"
            break
          end

          __trapper_output = nil
          begin
            __trapper_output = eval __trapper_input
          rescue SyntaxError => __trapper_se
            puts "#{__trapper_se.class}: #{__trapper_se.message}"
          rescue => __trapper_ex
            puts "#{__trapper_ex.class}: #{__trapper_ex.to_s}"
          end

          puts " => #{__trapper_output}" if __trapper_output
        end
      end
    }

    true
  end
end
