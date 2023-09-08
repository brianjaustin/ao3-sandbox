# frozen_string_literal: true

require_relative "../../migration_helpers"

module RuboCop
  module Cop
    module Migration
      # Checks that migrations updating the schema of large tables,
      # as defined in the configuration, do so safely. As of writing,
      # this involves utilizing the `uses_departure!` helper.
      #
      # @example `LargeTables` configuration
      #   # .rubocop.yml
      #   # Migration/LargeTableSchemaUpdate:
      #   #   Tables:
      #   #     - :users
      #   #     - :works
      #
      # @example
      #  # good
      #  class ExampleMigration < ActiveRecord::Migration[6.1]
      #    uses_departure! if Rails.env.staging? || Rails.env.production?
      #
      #    add_column :users, :new_field, :integer, nullable: true
      #  end
      #
      # @example
      #  # bad
      #  class ExampleMigration < ActiveRecord::Migration[6.1]
      #    add_column :users, :new_field, :integer, nullable: true
      #  end
      class LargeTableSchemaUpdate < RuboCop::Cop::Base
        include MigrationHelpers

        MSG = "Use departure to change the schema of large table `%s`"

        def_node_search :uses_departure?, <<~PATTERN
          (send nil? :uses_departure!)
        PATTERN

        def_node_search :schema_changes, <<~PATTERN
          $(send nil? _ (sym $_) ...)
        PATTERN

        def on_class(node)
          return unless in_migration?(node)
          return if uses_departure?(node)

          schema_changes(node).each do |change_node, table_name|
            next unless large_tables&.include?(table_name)

            add_offense(change_node.loc.expression, message: format(MSG, table_name))
          end
        end

        def large_tables
          @large_tables ||= cop_config["Tables"]
        end
      end
    end
  end
end
