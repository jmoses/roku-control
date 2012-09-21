#!/usr/bin/env ruby

$: << 'lib'

require 'termios'
require 'roku'

def with_unbuffered_input
  old_attrs = Termios.tcgetattr(STDOUT)

  new_attrs = old_attrs.dup

  new_attrs.lflag &= ~Termios::ECHO
  new_attrs.lflag &= ~Termios::ICANON

  Termios::tcsetattr(STDOUT, Termios::TCSANOW, new_attrs)

  yield
ensure
  Termios::tcsetattr(STDOUT, Termios::TCSANOW, old_attrs)
end

roku = Roku::Server.new(ARGV[0])

unless roku.valid?
  puts "That doesn't look like a roku player."
  exit 1
end

require "highline/system_extensions"
include HighLine::SystemExtensions

puts "Ready."
with_unbuffered_input do
  loop do
    press = STDIN.getc
    
    if press == "\e"
      begin
        Timeout::timeout(0.1) do
          press += STDIN.getc
          press += STDIN.getc
        end
      rescue Timeout::Error
      end
    end

    case press
    when "\e[A"
      roku.up
    when "\e[B"
      roku.down
    when "\e[C"
      roku.right
    when "\e[D"
      roku.left
    when "\n"
      roku.select
    when "\e"
      roku.back
    when " "
      roku.play
    else
      roku.send "letter_#{press}"
    end
  end
end
