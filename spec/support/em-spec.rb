require 'eventmachine'
require File.dirname(__FILE__) + '/../ext/fiber18'

module EventMachine
  module SpecHelper
    
    SpecTimeoutExceededError = Class.new(RuntimeError)
    
    def self.included(cls)
      ::Spec::Example::ExampleGroup.instance_eval "
      @@_em_default_time_to_finish = nil
      def self.default_timeout(timeout)
        @@_em_default_time_to_finish = timeout
      end
      "
    end
    
    def timeout(time_to_run)
      EM.cancel_timer(@_em_timer) if @_em_timer
      @_em_timer = EM.add_timer(time_to_run) { done; raise SpecTimeoutExceededError.new }
    end
    
    def em(time_to_run = @@_em_default_time_to_finish, &block)
      EM.run do
        timeout(time_to_run) if time_to_run
        em_spec_exception = nil
        @_em_spec_fiber = Fiber.new do
          begin
            block.call
          rescue Exception => em_spec_exception
            done
          end
          Fiber.yield
        end  

        @_em_spec_fiber.resume

        raise em_spec_exception if em_spec_exception
      end
    end

    def done
      EM.next_tick{
        finish_em_spec_fiber
      }
    end

    private

    def finish_em_spec_fiber
      EM.stop_event_loop if EM.reactor_running?
      @_em_spec_fiber.resume if @_em_spec_fiber.alive?
    end
    
  end
  
  module Spec

    include SpecHelper

    def instance_eval(&block)
      em do
        super(&block)
      end
    end

  end
  
end


