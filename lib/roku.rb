require "roku/version"
require 'net/http'
require 'uri'
require 'timeout'
require 'nokogiri'

module Roku
  class Server
    attr_accessor :url

    KEYS = [
      :Up, :Down, :Left, :Right, :Select, :Back, :Play, :Home,
      :Rev, :Fwd, :InstantReply, :Info, :Backspace, :Search,
      :Enter
    ]

    LETTERS = ('A'..'Z').to_a

    def initialize(ip)
      self.url = "http://#{ip}:8060/"
    end

    def apps
      @apps ||= begin
        doc = Nokogiri::XML(call("query/apps", :get).body)

        (doc/"//app").each_with_object({}) do |app, apps|
          apps[app.text] = app['id']
        end
      end
    end

    def icon_for(app_id)
      call("query/icon/#{app_id}", :get)
    end

    def url_for_icon(app_id)
      "#{url}query/icon/#{app_id}"
    end

    def launch(app_id)
      call("launch/#{app_id}")
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
