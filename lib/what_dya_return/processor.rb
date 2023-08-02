# frozen_string_literal: true

require_relative 'statement_checker'

module WhatDyaReturn
  class Processor
    using NodeRefinary

    # rubocop:disable Lint/HashAlignment
    BRANCH_CHECKERS = {
      WhatDyaReturn::AST::BeginNode  => :check_begin_node,
      WhatDyaReturn::AST::ReturnNode => :check_return_node,
      WhatDyaReturn::AST::IfNode     => :check_if_node,
      WhatDyaReturn::AST::CaseNode   => :check_case_node,
      WhatDyaReturn::AST::RescueNode => :check_rescue_node,
      WhatDyaReturn::AST::EnsureNode => :check_ensure_node,
      WhatDyaReturn::AST::WhileNode  => :check_while_node,
      WhatDyaReturn::AST::UntilNode  => :check_until_node,
      WhatDyaReturn::AST::ForNode    => :check_for_node,
      WhatDyaReturn::AST::BreakNode  => :check_break_node,
      WhatDyaReturn::AST::BlockNode  => :check_block_node,
      WhatDyaReturn::AST::NextNode   => :check_next_node
    }.freeze
    # rubocop:enable Lint/HashAlignment

    #
    # @param [WhatDyaReturn::AST::DefNode] node
    # @return [Array<RuboCop::AST::Node>]
    #
    def process(node)
      @return_nodes = []

      if node.body.nil? # `def foo; end`
        @return_nodes << nil
      else
        check_branch(node.body, node)
      end

      @return_nodes
    end

    private

    #
    # @param [RuboCop::AST::Node, nil] node
    # @return [void]
    #
    def check_branch(node, parent)
      if node.nil?
        @return_nodes << node if parent.returnable_statement?
        return
      end

      if (checker = BRANCH_CHECKERS.key?(node.class))
        send(checker, node)
      elsif node.is_a?(RuboCop::AST::Node)
        @return_nodes << node if node.returnable_statement?
      else
        # For debug
        raise UnintentionalNodeError, "Unknown node type: #{node.class}"
      end
    end

    #
    # @param [WhatDyaReturn::AST::BeginNode] node
    # @return [void]
    #
    def check_begin_node(node)
      node.children[0..-2].each do |child|
        check_branch(child, node)
        return unless child.reachable_to_next_statement? # rubocop:disable Lint/NonLocalExitFromIterator
      end

      check_branch(node.children[-1], node)
    end

    #
    # @param [WhatDyaReturn::AST::ReturnNode] node
    # @return [void]
    #
    def check_return_node(node)
      check_branch(node.children.first, node)
    end

    #
    # @param [WhatDyaReturn::AST::IfNode] node
    # @return [void]
    #
    def check_if_node(node)
      node.if_branch_reachable? && check_branch(node.if_branch, node)
      node.else_branch_reachable? && check_branch(node.else_branch, node)
    end

    #
    # @param [WhatDyaReturn::AST::CaseNode] node
    # @return [void]
    #
    def check_case_node(node)
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

        check_branch(when_branch.body, when_branch)
      end

      check_branch(node.else_branch, node)
    end

    #
    # @param [WhatDyaReturn::AST::RescueNode] node
    # @return [void]
    #
    def check_rescue_node(node)
      if node.else_branch && node.body.reachable_to_next_statement?
        check_branch(node.else_branch, node)
      else
        check_branch(node.body, node)
      end

      node.resbody_branches.each do |resbody_branch|
        check_branch(resbody_branch.body, resbody_branch)
      end
    end

    #
    # @param [WhatDyaReturn::AST::EnsureNode] node
    # @return [void]
    #
    def check_ensure_node(node)
      if node.body.reachable_to_next_statement?
        check_branch(node.node_parts[0], node) # begin or rescue node
      else
        check_branch(node.body, node)
      end
    end

    #
    # @param [WhatDyaReturn::AST::WhileNode] node
    # @return [void]
    #
    def check_while_node(node)
      if node.body_reachable?
        check_branch(node.body, node)
        check_branch(nil, node) if node.body.reachable_to_next_statement?
      else
        check_branch(nil, node)
      end
    end

    #
    # @param [WhatDyaReturn::AST::UntilNode] node
    # @return [void]
    #
    def check_until_node(node)
      if node.body_reachable?
        check_branch(node.body, node)
        check_branch(nil, node) if node.body.reachable_to_next_statement?
      else
        check_branch(nil, node)
      end
    end

    #
    # @param [WhatDyaReturn::AST::ForNode] node
    # @return [void]
    #
    def check_for_node(node)
      check_branch(node.body, node)
      check_branch(node.collection, node) if node.body.reachable_to_next_statement?
    end

    #
    # @param [WhatDyaReturn::AST::BreakNode] node
    # @return [void]
    #
    def check_break_node(node)
      check_branch(node.children.first, node)
    end

    #
    # @param [WhatDyaReturn::AST::BlockNode] node
    # @return [void]
    #
    def check_block_node(node)
      check_branch(node.body, node)
      check_branch(node.send_node, node) if node.body.reachable_to_next_statement?
    end

    #
    # @note The value passed to `next` is not used for the return value of `block`.
    #
    # @example
    #
    #   def foo
    #     10.times do |i|
    #       next 42 if i == 2
    #     end
    #   end
    #
    #   foo => # 10.times
    #
    #
    # @param [WhatDyaReturn::AST::NextNode] node
    # @return [void]
    #
    def check_next_node(node)
      block_node = node.ancestors.find { |n| n.instance_of?(AST::BlockNode) }
      return if block_node.nil?

      check_branch(block_node.send_node, node)
    end
  end
end
