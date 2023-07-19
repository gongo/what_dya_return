# frozen_string_literal: true

require_relative '../../../ast/node/begin_node'

module RuboCop
  module AST
    class Builder
      EXT_NODE_MAP = NODE_MAP.merge(
        {
          begin: WhatDyaReturn::AST::BeginNode,
          kwbegin: WhatDyaReturn::AST::BeginNode
        }
      )

      #
      # @override
      #
      def node_klass(type)
        EXT_NODE_MAP.fetch(type, ::RuboCop::AST::Node)
      end
    end
  end
end
