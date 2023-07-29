# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class WhileNode < ::RuboCop::AST::WhileNode
      include Ascendence

      #
      # @example
      #
      #   while false # or `nil`
      #     42 # unreachable
      #   end
      #
      # @return [Boolean]
      #
      def body_reachable?
        condition.falsey_literal?.!
      end
    end
  end
end