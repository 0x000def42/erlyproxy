# frozen_string_literal: true

require 'monotest_helper'

class Monotest < MonotestHelper::Websocket
  scenario 'Socket connection' do |success, failture|
    ws = WebSocket::EventMachine::Client.connect(uri: 'ws://localhost:8080')
    ws.onopen do
      success.call
      ws.close
    end
    ws.onclose do |code, _reason|
      failture.call code unless code == 1000
    end
    ws.onerror do |error|
      failture.call error
    end
  end
end

Monotest.new.run
