# frozen_string_literal: true

module WhatDyaReturn
  module StatementChecker
    class ReturnableStatement
      # rubocop:disable Layout/HashAlignment
      USED_CHECKERS = {
        AST::ReturnNode => :return_node_used?,
        AST::DefNode    => :def_node_used?,
        AST::BeginNode  => :begin_node_used?,
        AST::BreakNode  => :break_node_used?,
        AST::WhileNode  => :while_until_node_used?,
        AST::UntilNode  => :while_until_node_used?,
        AST::ForNode    => :for_node_used?,
        AST::BlockNode  => :block_node_used?
      }.freeze
      # rubocop:enable Layout/HashAlignment

      #
      # Inspired by RuboCop::AST::Node#value_used?
      #
      def ok?(node)
        return false if node.parent.nil?

        if (checker = USED_CHECKERS[node.parent.class])
          send(checker, node)
        else
          ok?(node.parent)
        end
      end

      private

      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def return_node_used?(_node)
        true
      end

      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def def_node_used?(node)
        node.sibling_index == node.parent.children.size - 1
      end

      #
      # @example
      #
      #   def foo
      #     begin
      #       1 # false
      #       2 # true
      #     end
      #   end
      #
      #   foo # => 2
      #
      # @example
      #
      #   def foo
      #     begin
      #       1 # false
      #       2 # false
      #     end
      #
      #     begin
      #       3 # false
      #       4 # true
      #     end
      #   end
      #
      #   foo # => 4
      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def begin_node_used?(node)
        node.sibling_index == node.parent.children.size - 1 ? ok?(node.parent) : false
      end

      #
      # @example
      #
      #   def foo
      #     while bar
      #       break 1 if baz
      #     end
      #
      #     while qux
      #       break 2 if quux
      #     end
      #   end
      #
      #   foo # => 2
      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def break_node_used?(node)
        ancestor = node.ancestors.find do |n|
          [AST::WhileNode, AST::UntilNode, AST::ForNode, AST::BlockNode].include?(n.class)
        end

        ok?(ancestor)
      end

      #
      # Only with break or return node.
      #
      # @example
      #
      #   value = while foo
      #             1 # false
      #             return 2 if bar
      #             break 3 if baz
      #             4 # false
      #           end
      #
      #   value # => 2 or 3
      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def while_until_node_used?(_node)
        false
      end

      #
      # value = for variable in collection
      #           body
      #         end
      #
      # value == collection # => true
      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def for_node_used?(node)
        node.parent.collection == node ? ok?(node.parent) : false
      end

      #
      # [1, 2, 3].each do |n| # send_node == [1, 2, 3].each
      #   p n
      # end
      #
      # @param [RuboCop::AST::Node] node
      # @return [Boolean]
      #
      def block_node_used?(node)
        node.parent.send_node == node ? ok?(node.parent) : false
      end
    end
  end
end
