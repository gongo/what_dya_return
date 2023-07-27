# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class UntilNode < ::RuboCop::AST::UntilNode
      include Ascendence

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
