# frozen_string_literal: true

module RuboCop
  module MigrationHelpers
    # Helper methods for building custom cops that operate on migrations.
    # Actual cops should go in the `cop` directory, and `include` this module.
    # The structure here is inspired by GitLab's custom cops: refer to
    # https://gitlab.com/gitlab-org/gitlab/-/tree/master/rubocop?ref_type=heads
    # for more examples.

    # Determine if the given AST node is in a location where migrations live.
    def in_migration?(node)
      dirname(node).end_with?("db/migrate")
    end

    private

    def filepath(node)
      node.location.expression.source_buffer.name
    end

    def dirname(node)
      File.dirname(filepath(node))
    end
  end
end
