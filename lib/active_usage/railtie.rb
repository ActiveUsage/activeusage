# frozen_string_literal: true

module ActiveUsage
  class Railtie < Rails::Railtie
    initializer "activeusage.middleware" do |app|
      app.middleware.use ActiveUsage::Middleware
    end

    initializer "activeusage.active_job_hooks" do
      ActiveSupport.on_load(:active_job) do
        include ActiveUsage::Instrumentation::ActiveJobHooks
      end
    end

    config.after_initialize do
      ActiveUsage::Instrumentation::Subscriber.new.call
    end
  end
end
