module LilServer
  require 'socket'

  class Server
    attr_reader :host, :port, :address, :domain

    SERVER_PROTOCOL_VERSION = "HTTP/1.1"
    DEFAULT_CONTENT_TYPE = "text/plain"

    METHODS = {
      get: "GET",
      post: "POST",
      put: "PUT",
      patch: "PATCH",
      delete: "DELETE",
      options: "OPTIONS",
      connect: "CONNECT",
      head: "HEAD"
    }

    # Stolen from Thin stolen from Mongrel
    STATUS_CODES = {
      100  => 'Continue', 
      101  => 'Switching Protocols', 
      200  => 'OK', 
      201  => 'Created', 
      202  => 'Accepted', 
      203  => 'Non-Authoritative Information', 
      204  => 'No Content', 
      205  => 'Reset Content', 
      206  => 'Partial Content', 
      300  => 'Multiple Choices', 
      301  => 'Moved Permanently', 
      302  => 'Moved Temporarily', 
      303  => 'See Other', 
      304  => 'Not Modified', 
      305  => 'Use Proxy', 
      400  => 'Bad Request', 
      401  => 'Unauthorized', 
      402  => 'Payment Required', 
      403  => 'Forbidden', 
      404  => 'Not Found', 
      405  => 'Method Not Allowed', 
      406  => 'Not Acceptable', 
      407  => 'Proxy Authentication Required', 
      408  => 'Request Time-out', 
      409  => 'Conflict', 
      410  => 'Gone', 
      411  => 'Length Required', 
      412  => 'Precondition Failed', 
      413  => 'Request Entity Too Large', 
      414  => 'Request-URI Too Large', 
      415  => 'Unsupported Media Type',
      422  => 'Unprocessable Entity',   
      500  => 'Internal Server Error', 
      501  => 'Not Implemented', 
      502  => 'Bad Gateway', 
      503  => 'Service Unavailable', 
      504  => 'Gateway Time-out', 
      505  => 'HTTP Version not supported'
    }

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

      STDERR.puts "\nStarted server on #{bold(@address)} with PID #{bold(pid)}"

      loop do
        initial_time = Time.now
        client = tcp_server.accept
        request = Request.new client
      
        STDERR.puts "[#{bold(request.method)}] call to #{bold(request.resource)} --- for #{bold(@address)} --- at #{bold(initial_time)} --- (#{request.protocol})"

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

def bold string
  "\e[1m#{string}\e[0m"
end

LilServer::Server.new.start
