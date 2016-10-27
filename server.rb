require 'socket'

port = ARGV[0] || 4567
host = 'localhost'
address = "http://#{host}:#{port}"
server = TCPServer.new host, port
process = Process.pid

Signal.trap("INT") {
  STDERR.puts "\nShutting server down..."
  # sleep 1
  exit
}

def bold string
  "\e[1m#{string}\e[0m"
end

if server
  STDERR.puts "\nStarted server on #{bold(address)} with PID #{bold(process)}"

  loop do
    initial_time = Time.now
    socket = server.accept
    request = socket.gets.split(" ")
    method = request[0]
    resource = request[1]
    request_protocol = request[2]
  
    STDERR.puts "[#{bold(method)}] call to #{bold(resource)} --- for #{bold(address)} --- at #{bold(initial_time)} --- (#{request_protocol})"

    response = "Hello World\n"

    socket.print "HTTP/1.1 200 OK\r\n"
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{response.bytesize}\r\n" +
                 "Connection: close\r\n"
    socket.print "\r\n"
    socket.print response
    socket.close
  end

else
  STDERR.puts "Could not start server."
end
