module Tire
  module Rails
    module Instrumentation

      def perform
        # Wrapper around the Search.perform method that logs search times.
        ActiveSupport::Notifications.instrument("search.tire", :name => 'Search', :search => self.to_json) do
          super
        end
      end
    end
  end
end
