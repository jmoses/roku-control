#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'uri'
require 'timeout'
require 'termios'

host = ARGV[0]
@url = "http://#{host}:8060/"

def call(path, method = :post)
  if method == :get
    Net::HTTP.get_response(URI(@url + path))
  else
    Net::HTTP.post_form(URI(@url + path), {})
  end
end

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

def push( command )
  call("keypress/#{command}")
end

unless call("", :get).body =~ /Roku/
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
      push :Up
    when "\e[B"
      push :Down
    when "\e[C"
      push :Right
    when "\e[D"
      push :Left
    when "\n"
      push :Select
    when "\e"
      push :Back
    when " "
      push :Play
    else
      push press
    end
  end
end
