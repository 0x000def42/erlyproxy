# frozen_string_literal: true

require 'rspec'
require 'eventmachine'
module MonotestHelper
  class Async
    @scenarios = []
    def self.instance
      @instance ||= new
    end

    def self.scenarios
      @scenarios ||= Scenarios.new
    end

    def self.scenario(name, &block)
      scenarios.push Scenario.new(scenarios, name, block)
    end

    def run
      EM.run do
        self.class.scenarios.run
      end
    end
  end

  class Scenarios
    def initialize
      @scenarios = []
      @counter = 0
    end

    def decrement
      @counter -= 1
      stop if @counter.zero?
    end

    def stop
      EM.stop_event_loop
      specs
    end

    def specs
      @scenarios.each do |scenario|
        RSpec.describe(scenario.name) do
          it do
            expect(scenario.error).to eq(nil)
          end
        end
      end
    end

    def run
      @counter = @scenarios.size
      @scenarios.each(&:call)
    end

    def push(scenario)
      @scenarios << scenario
    end
  end

  class Scenario
    @runned = false
    @is_success = nil
    @ref = nil
    @error = nil

    attr_reader :error, :name

    def callback(val)
      @runned = true
      @is_success = val
      @ref.decrement
    end

    def call
      @block.call(
        proc do
          callback true
        end,
        proc do |error|
          @error = error || 'Unexpected error'
          callback false
        end
      )
    end

    def initialize(ref, name, block)
      @name = name
      @block = block
      @ref = ref
    end
  end
end
