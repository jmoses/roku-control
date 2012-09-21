#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'uri'
require 'timeout'
require 'termios'

class Roku
  attr_accessor :url

  KEYS = [
    :Up, :Down, :Left, :Right, :Select, :Back, :Play
  ]

  LETTERS = ('A'..'Z').to_a

  def initialize(ip)
    self.url = "http://#{ip}:8060/"
  end

  def valid?
    call("", :get).body =~ /Roku/
  end

  KEYS.each do |key|
    define_method(key.to_s.downcase) do
      push key
    end
  end

  LETTERS.each do |letter|
    define_method("letter_#{letter.downcase}") do
      push "Lit_#{letter}"
    end
  end

  private
    def call(path, method = :post)
      if method == :get
        Net::HTTP.get_response(URI(@url + path))
      else
        Net::HTTP.post_form(URI(@url + path), {})
      end
    end

    def push(command)
      call("keypress/#{command}")
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

roku = Roku.new(ARGV[0])

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
