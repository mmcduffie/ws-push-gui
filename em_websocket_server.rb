require 'rubygems'
require 'webrick'
require 'rack'
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

Thread.new do
  class HelloWorld
    def call(env)
      [200, {"Content-Type" => "text/html"}, [ <<-eos
<html>
  <head>
    <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js'></script>
    <script>
      $(document).ready(function(){
        function debug(str){ $("#debug").append("<p>"+str+"</p>"); };

        ws = new WebSocket("ws://localhost:8080");
        ws.onmessage = function(evt) { $("#msg").append("<p>"+evt.data+"</p>"); };
        ws.onclose = function() { debug("socket closed"); };
        ws.onopen = function() {
          debug("connected...");
          ws.send("hello server");
        };
      });
    </script>
  </head>
  <body>
    <div id="debug"></div>
    <div id="msg"></div>
  </body>
</html>
      eos
      ]]
    end
  end

  Rack::Handler::WEBrick.run HelloWorld.new, :Port => 80
end

sleep