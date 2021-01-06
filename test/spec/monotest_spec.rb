# frozen_string_literal: true

require 'amqp'
require 'websocket-eventmachine-client'
require 'json'

require_relative 'monotest_helper'
class Monotest < MonotestHelper::Async
  scenario 'Socket connection' do |success, failture|
    ws = WebSocket::EventMachine::Client.connect(uri: 'ws://localhost:8080')
    ws.onopen do
      ws.close
    end
    ws.onclose do |code, _reason|
      if code == 1000
        success.call
      else
        failture.call code
      end
    end
    ws.onerror do |error|
      failture.call error
    end
  end

  scenario 'Passing message from ws to amqp' do |success, failture|
    EventMachine::Timer.new(1) do
      # failture.call 'Timeout'
    end
    connection = AMQP.connect(host: 'localhost')
    ch  = AMQP::Channel.new(connection)
    q   = ch.queue('host_request', auto_delete: true)

    q.subscribe do |_metadata, payload|
      data = JSON.parse(payload)
      if data['payload'] == 'any' && !data['id'].nil?
        success.call
      else
        failture.call "Unexpected payload: #{payload}"
      end
    end

    ws = WebSocket::EventMachine::Client.connect(uri: 'ws://localhost:8080')
    ws.onopen do
      request = { target: 'host', action: 'request', payload: 'any' }
      ws.send(JSON.generate(request))
    end
  end
end

Monotest.new.run
