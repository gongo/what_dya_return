# frozen_string_literal: true

require_relative 'ext/rubocop/ast/builder'
require_relative 'ext/rubocop/ast/node/if_node'
require_relative 'statement_checker'

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
      when WhatDyaReturn::AST::BeginNode
        check_begin_node(node, is_ret_expr)
      when ::RuboCop::AST::ReturnNode
        check_return_node(node)
      when ::RuboCop::AST::IfNode
        check_if_node(node, is_ret_expr)
      when ::RuboCop::AST::CaseNode
        check_case_node(node, is_ret_expr)
      else
        @return_nodes << node if is_ret_expr
      end
    end

    #
    # @param [WhatDyaReturn::AST::BeginNode] node
    # @return [void]
    #
    def check_begin_node(node, is_ret_expr)
      node.children[0..-2].each do |child|
        check_branch(child, false)
        return unless StatementChecker.reachable_to_next_statement?(child) # rubocop:disable Lint/NonLocalExitFromIterator
      end

      check_branch(node.children[-1], is_ret_expr)
    end

    #
    # @param [RuboCop::AST::ReturnNode] node
    # @return [void]
    #
    def check_return_node(node)
      check_branch(node.children.first, true)
    end

    #
    # @param [RuboCop::AST::IfNode] node
    # @param [Boolean] is_ret_expr Whether current scope is within return expression
    # @return [void]
    #
    def check_if_node(node, is_ret_expr)
      node.if_branch_reachable? && check_branch(node.if_branch, is_ret_expr)
      node.else_branch_reachable? && check_branch(node.else_branch, is_ret_expr)
    end

    #
    # @param [RuboCop::AST::CaseNode] node
    # @param [Boolean] is_ret_expr Whether current scope is within return expression
    # @return [void]
    #
    def check_case_node(node, is_ret_expr)
      node.when_branches.each do |when_branch|
        #
        # case # no condition
        # when false
        #   1 # unreachable
        # when 'qux'
        #   2 # reachable
        # end
        #
        next if node.condition.nil? && when_branch.conditions.all?(&:falsey_literal?)

        check_branch(when_branch.body, is_ret_expr)
      end

      check_branch(node.else_branch, is_ret_expr)
    end
  end
end
