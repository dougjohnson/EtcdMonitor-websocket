#!/usr/bin/env ruby
require 'em-websocket'
require_relative 'etcdwatcher'

etcd_server = ARGV.shift || "10.1.42.1"

EventMachine.run {
  @channel = EM::Channel.new

  URL="http://#{etcd_server}:4001/v2/keys/services"

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|

    sid = 0

    ws.onopen {
      sid = @channel.subscribe { |msg| ws.send msg }
      @channel.push "#{sid} connected!"
    }

    ws.onmessage { |msg|
      @channel.push "<#{sid}>: #{msg}"
    }

    ws.onclose {
      @channel.unsubscribe(sid)
    }

  end

  etcd_watcher = EtcdWatcher.new(URL)
  etcd_watcher.onchange do |change|
    @channel.push change
  end 

  puts "Server started"
}

