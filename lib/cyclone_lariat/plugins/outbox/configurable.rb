# frozen_string_literal: true

module CycloneLariat
  class Outbox
    module Configurable
      CONFIG_ATTRS = %i[dataset resend_timeout on_sending_error]

      def config
        @config ||= Struct.new(*CONFIG_ATTRS).new
      end

      def configure
        yield(config) if block_given?
        config
      end
    end
  end
end
