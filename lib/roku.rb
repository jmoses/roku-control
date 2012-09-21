require "roku/version"
require 'rubygems'
require 'net/http'
require 'uri'
require 'timeout'

module Roku
  class Server
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
end
