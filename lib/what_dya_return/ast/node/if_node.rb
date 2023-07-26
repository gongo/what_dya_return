# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class IfNode < ::RuboCop::AST::IfNode
      #
      # @example
      #
      #   if false # or `nil`
      #     42 # unreachable
      #   else
      #     run
      #   end
      #
      # @return [Boolean]
      #
      def if_branch_reachable?
        ((if? || ternary? || elsif?) && condition.falsey_literal?.!) || (unless? && condition.truthy_literal?.!)
      end

      #
      # @example
      #
      #   if true
      #     42
      #   else
      #     run # unreachable
      #   end
      #
      # @return [Boolean]
      #
      def else_branch_reachable?
        ((if? || ternary? || elsif?) && condition.truthy_literal?.!) || (unless? && condition.falsey_literal?.!)
      end
    end
  end
end
