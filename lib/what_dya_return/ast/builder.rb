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
        return: ReturnNode,
        if: IfNode,
        case: CaseNode,
        when: WhenNode,
        rescue: RescueNode,
        resbody: ResbodyNode,
        ensure: EnsureNode
      }.freeze

      #
      # @return [Node]
      #
      def n(type, children, source_map)
        node_klass(type).new(type, children, location: source_map)
      end

      private

      def node_klass(type)
        NODE_MAP[type] || Node
      end
    end
  end
end
