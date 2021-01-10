# frozen_string_literal: true

require 'amqp'
require 'websocket-eventmachine-client'
require 'json'

require_relative 'monotest_helper'



class Monotest < MonotestHelper::Async
  a_ws = -> { WebSocket::EventMachine::Client.connect(uri: 'ws://localhost:8080') }
  a_connection = -> { AMQP.connect(host: 'localhost') }
  a_channel = -> { AMQP::Channel.new(a_connection.call) }
  a_queue = -> { a_channel.call.queue('host_request') }

  scenario 'Socket connection' do |success, failture|
    ws = a_ws.call
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
      failture.call 'Timeout'
    end
    queue = a_queue.call
    queue.subscribe do |_metadata, payload|
      data = JSON.parse(payload)
      if data['payload'] == 'any' && !data['client'].nil?
        success.call
      else
        failture.call "Unexpected payload: #{payload}"
      end
    end
    ws = a_ws.call
    ws.onopen do
      request = { target: 'host', action: 'request', payload: 'any' }
      ws.send(JSON.generate(request))
    end
  end
end

Monotest.new.run
