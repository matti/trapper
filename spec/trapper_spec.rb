require 'spec_helper'

describe "CHANGELOG" do
  describe 'version' do
    it 'matches Trapper::VERSION' do
      changelog_contents = File.read "CHANGELOG.md"
      changelog_topmost_version = changelog_contents.match(/## (\d+\.\d+\.\d+)/)[1]

      expect(changelog_topmost_version).to eq Trapper::VERSION
    end
  end
end

describe Trapper do
  it 'has a version number' do
    expect(Trapper::VERSION).not_to be nil
  end

  describe 'inject!' do
    it 'injects and returns true' do
      value = Trapper.trap! @silence

      expect(value).to eq true
    end
  end

  describe 'running' do
    before :each do
      @silence = Kommando.new "ruby spec/support/silence.rb", {
        timeout: 1,
        output: false
      }

      @silence.when :timeout do
        fail "silence timeouted."
      end

      @loop = Kommando.new "ruby spec/support/loop.rb 0.0001", {
        timeout: 1,
        output: false
      }

      @loop.when :timeout do
        fail "loop timeouted."
      end
    end

    describe 'prompt' do
      it 'opens the prompt and quits with exit code 1' do
        prompt_opened = false

        @silence.out.on /^ssssh\.\.\.$/ do
          @silence.in << "\x03"
        end

        @silence.out.on /\r\n\r\ntrapper>\s$/ do
          prompt_opened = true
          @silence.in << "q\n"
        end

        @silence.run

        expect(prompt_opened).to be true
        expect(@silence.code).to eq 1
      end

      it 'opens the prompt multiple times' do
        actions = []

        @silence.out.on /^ssssh/ do
          actions << :first
          @silence.in << "\x03"
        end

        @silence.out.on /^trapper> / do
          actions << :continue

          @silence.in << "c\n"
          @silence.in << "\x03"

          @silence.out.on /^trapper>/ do
            actions << :again
            @silence.in << "q\n"
          end
        end

        @silence.run

        expect(actions).to eq [:first, :continue, :again]
      end

      it 'quits when double ^C' do
        opens = 0

        @loop.out.on /^0/ do
          @loop.in << "\x03"
          @loop.in << "\x03"
        end

        @loop.out.on /trapper>/ do
          opens += 1

          @loop.in << "q\n"
        end

        @loop.run
        expect(opens).to eq 1
      end
    end

    describe 'instance' do
      it 'modifies the state' do
        state_modified = false

        @loop.out.on /^0,1,2,3/ do
          @loop.in << "\x03"
          @loop.in << "@i=-100\n"
          @loop.in << "c\n"
        end

        @loop.out.on /-99,-98,-97/ do
          state_modified = true
          @loop.in << "\x03"
          @loop.in << "q\n"
        end

        @loop.run

        expect(@loop.out).to match /bye.\r\n$/
        expect(state_modified).to be true
      end

      it 'exposes only __trapper_ local variables' do
        @silence.out.on /^ssssh/ do
          @silence.in << "\x03"
          @silence.in << "([:start] + local_variables + [:end]).join(',')\n"
          @silence.in << "q\n"
        end

        @silence.run

        expect(@silence.out).to match /start,__trapper_input,__trapper_output,__trapper_se,__trapper_ex,__trapper_obj,end/
      end
    end

    describe 'evaluation' do
      it 'prefixes with hashrocket' do
        @silence.out.on /^ssssh/ do
          @silence.in << "\x03"
          @silence.in << "1+2\n"
          @silence.in << "q\n"
        end

        @silence.run

        expect(@silence.out).to match /\s=>\s3/
      end

      it 'SyntaxError is detected' do
        @silence.out.on /^ssssh/ do
          @silence.in << "\x03"
          @silence.in << "1+\n"
          @silence.in << "q\n"
        end

        @silence.run

        expect(@silence.out).to match /SyntaxError: \(eval\):1: syntax error, unexpected end-of-input/
      end

      it 'NameError is detected' do
        @silence.out.on /^ssssh/ do
          @silence.in << "\x03"
          @silence.in << "asdfasdf\n"
          @silence.in << "q\n"
        end

        @silence.run

        expect(@silence.out).to match /NameError: undefined local variable or method `asdfasdf'/
      end

      it 'NoMethodError is detected' do
        @silence.out.on /^ssssh/ do
          @silence.in << "\x03"
          @silence.in << "abbaasdf()\n"
          @silence.in << "q\n"
        end

        @silence.run

        expect(@silence.out).to match /NoMethodError: undefined method `abbaasdf' for/
      end
    end

  end
end
