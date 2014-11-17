require 'active_support/core_ext/module/attr_internal'

module Tire
  module Rails
    module ControllerRuntime
      extend ActiveSupport::Concern

    protected

      attr_internal :tire_runtime
      attr_internal :tire_count

      def cleanup_view_runtime
        tire_rt_before_render, ct_before = Tire::Rails::LogSubscriber.reset_runtime
        runtime = super
        tire_rt_after_render, ct_after = Tire::Rails::LogSubscriber.reset_runtime
        self.tire_runtime = tire_rt_before_render + tire_rt_after_render
        self.tire_count = ct_after + ct_before
        runtime - tire_rt_after_render
      end

      def append_info_to_payload(payload)
        super
        runtime, count = Tire::Rails::LogSubscriber.reset_runtime
        payload[:tire_runtime] = (tire_runtime || 0) + runtime
        payload[:tire_count] = (tire_count || 0) + count
      end

      module ClassMethods
        def log_process_action(payload)
          messages, tire_runtime, tire_count = super, payload[:tire_runtime], payload[:tire_count]
          messages << ("Search: %.1fms (%d queries)" % [tire_runtime.to_f, tire_count.to_i]) if tire_runtime
          messages
        end
      end
    end
  end
end
