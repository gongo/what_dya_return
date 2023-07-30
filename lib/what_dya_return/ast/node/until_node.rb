# frozen_string_literal: true

module WhatDyaReturn
  module AST
    #
    # A node extension for `if` nodes.
    #
    class UntilNode < ::RuboCop::AST::UntilNode
      #
      # @example
      #
      #   until true
      #     42 # unreachable
      #   end
      #
      # @return [Boolean]
      #
      def body_reachable?
        condition.truthy_literal?.!
      end
    end
  end
end
