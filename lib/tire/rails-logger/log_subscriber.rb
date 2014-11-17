module Tire
  module Rails
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        Thread.current["tire_search_runtime"] = value
      end

      def self.runtime
        Thread.current["tire_search_runtime"] ||= 0
      end

      def self.count=(value)
        Thread.current["tire_search_count"] = value
      end

      def self.count
        Thread.current["tire_search_count"] ||= 0
      end



      def self.reset_runtime
        rt, self.runtime = runtime, 0
        ct, self.count = count, 0
        return rt,ct
      end

      def search(event)
        self.class.runtime += event.duration
        self.class.count += 1
        return unless logger.debug?

        payload = event.payload

        name    = "%s (%.1fms)" % [payload[:name], event.duration]
        query   = payload[:search].to_s.squeeze ' '

        debug "  #{color(name, YELLOW, true)}  #{query}"
      end
    end
  end
end

# Register with namespace 'tire', so event names look like '*.tire',
# e.g. 'search.tire' will invoke the search method in the LogSubscriber above.
#
Tire::Rails::LogSubscriber.attach_to :tire
