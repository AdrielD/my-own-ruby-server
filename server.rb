require 'socket'

port = ARGV[0] || 4567
host = 'localhost'
address = "http://#{host}:#{port}"
server = TCPServer.new host, port
process = Process.pid

Signal.trap("INT") {
  STDERR.puts "\nShutting server down..."
  sleep 1
  exit
}

if server
  STDERR.puts "\nStarted server on #{address} with PID #{process}"

  loop do
    socket = server.accept
    request = socket.gets.split(" ")
    method = request[0]
    resource = request[1]
    request_protocol = request[2]
  
    STDERR.puts "[#{method}] call to #{resource}  |  for #{address}  |  at #{Time.now}  |  (#{request_protocol})"

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
