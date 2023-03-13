# frozen_string_literal: true

require 'cyclone_lariat/messages/v1/event'
require 'cyclone_lariat/messages/v1/command'
require 'cyclone_lariat/messages/builder'
require 'cyclone_lariat/plugins/outbox/mappers/messages'

module CycloneLariat
  module Outbox
    module Repo
      module Sequel
        class Messages
          attr_reader :dataset, :republish_timeout

          def initialize(config)
            @dataset = config.dataset
            @republish_timeout = config.republish_timeout
          end

          def create(msg)
            dataset.returning.insert(Outbox::Mappers::Messages.to_row(msg)).first[:uuid]
          end

          def delete(uuid)
            dataset.where(uuid: uuid).delete
          end

          def update_error(uuid, error_message)
            dataset.where(uuid: uuid).update(sending_error: error_message)
          end

          def each_unpublished
            dataset
              .where(::Sequel.lit('created_at < ?', Time.now - republish_timeout))
              .order(::Sequel.asc(:created_at))
              .each do |row|
              msg = build Outbox::Mappers::Messages.from_row(row)
              yield(msg)
            end
          end

          private

          def build(raw)
            CycloneLariat::Messages::Builder.new(raw_message: raw).call
          end
        end
      end
    end
  end
end
