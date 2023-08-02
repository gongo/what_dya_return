# frozen_string_literal: true

module WhatDyaReturn
  #
  # A RuboCop::AST::Node refinement.
  #
  module NodeRefinary
    refine ::RuboCop::AST::Node do
      #
      # @see WhatDyaReturn::StatementChecker#returnable_statement?
      #
      def returnable_statement?
        StatementChecker.returnable_statement?(self)
      end

      #
      # @see WhatDyaReturn::StatementChecker#reachable_to_next_statement?
      #
      def reachable_to_next_statement?
        StatementChecker.reachable_to_next_statement?(self)
      end
    end
  end
end
