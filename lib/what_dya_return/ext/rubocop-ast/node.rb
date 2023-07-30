# frozen_string_literal: true

module WhatDyaReturn
  module NodeRefinary
    refine ::RuboCop::AST::Node do
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
        when AST::ReturnNode
          true
        when AST::DefNode
          sibling_index == parent.children.size - 1
        when AST::BeginNode
          sibling_index == parent.children.size - 1 ? parent.used_as_return_value? : false
        when AST::BreakNode
          ancestors.find { |n| [AST::WhileNode, AST::UntilNode].include?(n.class) }.used_as_return_value?
        when AST::WhileNode, AST::UntilNode
          false # Only with break or return node.
        else
          parent.used_as_return_value?
        end
      end
    end
  end
end