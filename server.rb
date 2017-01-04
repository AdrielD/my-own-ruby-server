module LilServer
  require 'socket'

  class Server
    attr_reader :host, :port, :address, :domain

    SERVER_PROTOCOL_VERSION = "HTTP/1.1"
    DEFAULT_CONTENT_TYPE = "text/plain"

    # Stolen from Thin stolen from Mongrel
    def initialize host='localhost', port=4567
      @port = port
      @host = host
      @domain = "#{@host}:#{@port}"
      @protocol = "http://"
      @address = "#{@protocol}#{@domain}"
    end

    def start
      pid = Process.pid
      # tcp_server = nil
      
      begin
        tcp_server = TCPServer.open @host, @port
      rescue Exception => e
        STDERR.puts "Could not start server:\n"
        STDERR.puts e
      end

      Signal.trap("INT") {
        STDERR.puts "\nShutting server down..."
        # sleep 1
        exit
      }

      STDERR.puts "\nStarted server on #{@address.bold} with PID #{pid.bold}"

      loop do
        initial_time = Time.now
        client = tcp_server.accept
        request = Request.new client
      
        STDERR.puts "[#{request.method.bold}] call to #{request.resource.bold} --- for #{@address.bold} --- at #{initial_time.bold} --- (#{request.protocol})"

        response = Response.new
        response.body = "<p>Hello World</p>"
        response.headers = ["#{SERVER_PROTOCOL_VERSION} 200 OK", 
                            "Content-Type: text/html",
                            "Content-Length: #{response.body.bytesize}",
                            "Connection: close"]

        client.puts response.format
        client.close
      end
    end
  end

  class Request
    attr_reader :method, :resource, :protocol

    def initialize data
      @method, @resource, @protocol = data.gets.split(" ")
    end
  end

  class Response
    attr_accessor :headers, :body

    def initialize body="", headers=[]
      @headers = body
      @body = headers
    end

    def headers= header_list
      @headers = (header_list << "\r\n").join("\r\n")
    end

    def format
      "#{@headers}#{@body}"
    end
  end
end

module ColorOutput
  def bold
    "\e[1m#{self}\e[0m"
  end
end

class String
  include ColorOutput
end

class Fixnum
  include ColorOutput
end

class Time
  include ColorOutput
end

LilServer::Server.new.start
