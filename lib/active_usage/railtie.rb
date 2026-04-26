# frozen_string_literal: true

module ActiveUsage
  class Railtie < Rails::Railtie
    initializer "activeusage.context_middleware" do |app|
      app.middleware.use ActiveUsage::Instrumentation::ContextMiddleware
    end

    initializer "activeusage.active_job_hooks" do
      ActiveSupport.on_load(:active_job) do
        include ActiveUsage::Instrumentation::ActiveJobHooks
      end
    end

    config.after_initialize do
      ActiveUsage.attach_subscribers!
    end
  end
end
