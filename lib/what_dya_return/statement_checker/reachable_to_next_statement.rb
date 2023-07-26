# frozen_string_literal: true

# This file is based on https://github.com/rubocop/rubocop/blob/v1.50.2/lib/rubocop/cop/lint/unreachable_code.rb
# The original code is licensed under the MIT License.
#
# https://github.com/rubocop/rubocop/blob/v1.50.2/LICENSE.txt

module WhatDyaReturn
  module StatementChecker
    class ReachableToNextStatement
      extend RuboCop::AST::NodePattern::Macros

      # @!method flow_terminate_command?(node)
      def_node_matcher :flow_terminate_command?, <<~PATTERN
        {
          return next break retry redo
          (send
            {nil? (const {nil? cbase} :Kernel)}
            {:raise :fail :throw :exit :exit! :abort}
            ...)
        }
      PATTERN

      #
      # @param node [RuboCop::AST::Node]
      # @return [Boolean]
      #
      def ok?(node)
        return false if flow_terminate_command?(node)

        case node
        when WhatDyaReturn::AST::BeginNode
          check_begin(node)
        when WhatDyaReturn::AST::IfNode
          check_if(node)
        when WhatDyaReturn::AST::CaseNode
          check_case(node)
        else
          true
        end
      end

      private

      #
      # @example Return true
      #
      #    def foo
      #      ( # begin start
      #        "a"
      #        "b"
      #      ) # begin end
      #
      #      "c" # reachable
      #    end
      #
      # @example Return false
      #
      #    def foo
      #      ( # begin start
      #        "a"
      #        return "b"
      #      ) # begin end
      #
      #      "c" # unreachable
      #    end
      #
      # @param node [WhatDyaReturn::AST::BeginNode]
      # @return [Boolean]
      #
      def check_begin(node)
        node.children.all? { |child| ok?(child) }
      end

      #
      # @example Return true
      #
      #    if foo?
      #      return "a"
      #    end
      #
      #    "b" # reachable
      #
      # @example Return true with else statement
      #
      #    if foo?
      #      return "a"
      #    else
      #      "c"
      #    end
      #
      #    "b" # reachable
      #
      # @example Return false
      #
      #    if foo?
      #      return "a"
      #    else
      #      return "c"
      #    end
      #
      #    "b" # unreachable
      #
      # @param node [WhatDyaReturn::AST::IfNode]
      # @return [Boolean]
      #
      def check_if(node)
        return true if node.else_branch.nil?

        ok?(node.body) || ok?(node.else_branch)
      end

      #
      # @example Return true without else statement
      #
      #    case foo
      #    when "bar"
      #      return :bar
      #    end
      #
      #    "b" # reachable
      #
      # @example Return true with else statement
      #
      #    case foo
      #    when "bar"
      #      return :bar
      #    else
      #      :baz
      #    end
      #
      #    "b" # reachable
      #
      # @example Return false
      #
      #    case foo
      #    when "bar"
      #      return :bar
      #    else
      #      return :baz
      #    end
      #
      #    "b" # unreachable
      #
      # @param node [WhatDyaReturn::AST::CaseNode]
      # @return [Boolean]
      #
      def check_case(node)
        return true if node.else_branch.nil?
        return true if ok?(node.else_branch)

        node.when_branches.any? { |when_branch| ok?(when_branch.body) }
      end
    end
  end
end
