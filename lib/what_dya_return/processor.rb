# frozen_string_literal: true

require_relative 'statement_checker'

module WhatDyaReturn
  class Processor
    #
    # @param [WhatDyaReturn::AST::DefNode] node
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
      when WhatDyaReturn::AST::ReturnNode
        check_return_node(node)
      when WhatDyaReturn::AST::IfNode
        check_if_node(node, is_ret_expr)
      when WhatDyaReturn::AST::CaseNode
        check_case_node(node, is_ret_expr)
      when WhatDyaReturn::AST::RescueNode
        check_rescue_node(node, is_ret_expr)
      when WhatDyaReturn::AST::EnsureNode
        check_ensure_node(node, is_ret_expr)
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
    # @param [WhatDyaReturn::AST::ReturnNode] node
    # @return [void]
    #
    def check_return_node(node)
      check_branch(node.children.first, true)
    end

    #
    # @param [WhatDyaReturn::AST::IfNode] node
    # @param [Boolean] is_ret_expr Whether current scope is within return expression
    # @return [void]
    #
    def check_if_node(node, is_ret_expr)
      node.if_branch_reachable? && check_branch(node.if_branch, is_ret_expr)
      node.else_branch_reachable? && check_branch(node.else_branch, is_ret_expr)
    end

    #
    # @param [WhatDyaReturn::AST::CaseNode] node
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

    #
    # @param [WhatDyaReturn::AST::RescueNode] node
    # @param [Boolean] is_ret_expr Whether current scope is within return expression
    # @return [void]
    #
    def check_rescue_node(node, is_ret_expr)
      if node.else_branch && StatementChecker.reachable_to_next_statement?(node.body)
        check_branch(node.else_branch, is_ret_expr)
      else
        check_branch(node.body, is_ret_expr)
      end

      node.resbody_branches.each do |resbody_branch|
        check_branch(resbody_branch.body, is_ret_expr)
      end
    end

    #
    # @param [WhatDyaReturn::AST::EnsureNode] node
    # @param [Boolean] is_ret_expr Whether current scope is within return expression
    # @return [void]
    #
    def check_ensure_node(node, is_ret_expr)
      if StatementChecker.reachable_to_next_statement?(node.body)
        check_branch(node.node_parts[0], is_ret_expr) # begin or rescue node
      else
        check_branch(node.body, false)
      end
    end
  end
end
