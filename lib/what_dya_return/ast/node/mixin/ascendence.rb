# frozen_string_literal: true

module WhatDyaReturn
  module AST
    module Ascendence
      #
      # Inspired by RuboCop::AST::Node#value_used?
      #
      # @example
      #
      #   def foo
      #     1 # true
      #   end
      #
      # @example
      #
      #   def foo
      #     1 # false
      #     2 # true
      #   end
      #
      # @example
      #
      #   def foo      # last index is 1
      #     if bar
      #       return 1 # true  (parent is `return`)
      #     else
      #       2        # false (parent `if` sibling_index == 0)
      #     end
      #
      #     if baz
      #       3        # true  (parent `if` sibling_index == 1)
      #     else
      #       4        # true  (parent `if` sibling_index == 1)
      #     end
      #   end
      #
      def used_as_return_value?
        return false if parent.nil?

        case parent
        when ReturnNode
          true
        when DefNode
          sibling_index == parent.children.size - 1
        when BeginNode
          sibling_index == parent.children.size - 1 ? parent.used_as_return_value? : false
        when BreakNode
          ancestors.find { |n| [WhileNode, UntilNode].include?(n.class) }.used_as_return_value?
        when WhileNode, UntilNode
          false # Only with break or return node.
        else
          parent.used_as_return_value?
        end
      end
    end
  end
end
