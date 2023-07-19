# frozen_string_literal: true

require_relative 'statement_checker/reachable_to_next_statement'

module WhatDyaReturn
  module StatementChecker
    #
    # @param node [::RuboCop::AST::Node]
    # @return [Boolean]
    #
    def self.reachable_to_next_statement?(node)
      @reachable_to_next_statement ||= ReachableToNextStatement.new
      @reachable_to_next_statement.ok?(node)
    end
  end
end
