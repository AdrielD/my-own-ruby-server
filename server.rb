module LilServer
  require 'socket'

  class Server
    attr_reader :host, :port, :address, :domain

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

      STDERR.puts "\nStarted server on #{bold(@address)} with PID #{bold(pid)}"

      loop do
        initial_time = Time.now
        client = tcp_server.accept
        request = Request.new client
      
        STDERR.puts "[#{bold(request.method)}] call to #{bold(request.resource)} --- for #{bold(@address)} --- at #{bold(initial_time)} --- (#{request.protocol})"

        response = Response.new
        response.body = "<p>Hello World</p>"
        response.headers = ["HTTP/1.1 200 OK", 
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

def bold string
  "\e[1m#{string}\e[0m"
end

LilServer::Server.new.start
