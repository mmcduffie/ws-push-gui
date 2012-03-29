require 'rubygems'
require 'eventmachine'
require 'em-websocket'

socket = nil

Thread.new do
  EventMachine::WebSocket.start(:host => 'localhost', :port => 8080) do |ws|
    ws.onopen do
      socket = ws
    end
  end
end

Thread.new do
  until socket != nil
    sleep(0.1)
  end
  loop do
    sleep(0.5)
    socket.send "#{rand(8900) + 1000}"
  end
end

sleep