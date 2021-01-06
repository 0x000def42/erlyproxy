# frozen_string_literal: true

require_relative 'monotest_helper'
class Monotest < MonotestHelper::Websocket
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
      p error
      failture.call error
    end
  end
end

Monotest.new.run
