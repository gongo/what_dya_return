# frozen_string_literal: true

module WhatDyaReturn
  class Processor
    #
    # @param [RuboCop::AST::DefNode] node
    # @return [Array<RuboCop::AST::Node>]
    #
    def process(node)
      @return_nodes = []

      check_branch(node.body, true)

      @return_nodes
    end

    private

    #
    # @param [RuboCop::AST::Node] node
    # @param [Boolean] is_ret_expr Whether current scope is within return expression
    # @return [void]
    #
    def check_branch(node, is_ret_expr)
      unless node
        @return_nodes << node if is_ret_expr
        return
      end

      case node
      when ::RuboCop::AST::ReturnNode
        check_return_node(node)
      else
        @return_nodes << node if is_ret_expr
      end
    end

    #
    # @param [RuboCop::AST::ReturnNode] node
    # @return [void]
    #
    def check_return_node(node)
      check_branch(node.children.first, true)
    end
  end
end
