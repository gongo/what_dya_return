# frozen_string_literal: true

#
# This file is based on https://github.com/rubocop/rubocop-ast/blob/v1.28.1/lib/rubocop/ast/builder.rb
# The original code is licensed under the MIT License.
#
# https://github.com/rubocop/rubocop-ast/blob/v1.28.1/LICENSE.txt
#
module WhatDyaReturn
  module AST
    class Builder < Parser::Builders::Default
      NODE_MAP = {
        def: DefNode,
        begin: BeginNode,
        kwbegin: BeginNode,
        array: ArrayNode,
        return: ReturnNode,
        if: IfNode,
        case: CaseNode,
        when: WhenNode,
        rescue: RescueNode,
        resbody: ResbodyNode,
        ensure: EnsureNode,
        while: WhileNode,
        until: UntilNode,
        for: ForNode,
        break: BreakNode,
        next: NextNode,
        block: BlockNode
      }.freeze

      #
      # NOTE: Reason why wrap with ArrayNode if the node is `return` or `break` and has multiple children.
      #
      #   To treat `return 1, 2` like `return [1, 2]`.
      #
      # @return [Node]
      #
      def n(type, children, source_map)
        if %i[return break].include?(type) && children.size > 1
          children = [ArrayNode.new(:array, children)]
        end

        node_klass(type).new(type, children, location: source_map)
      end

      private

      def node_klass(type)
        NODE_MAP[type] || Node
      end
    end
  end
end
