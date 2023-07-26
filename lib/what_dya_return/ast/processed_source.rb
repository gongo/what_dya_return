# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class ProcessedSource < ::RuboCop::AST::ProcessedSource
      #
      # Override `RuboCop::AST::ProcessedSource#create_parser` to
      # use `WhatDyaReturn::AST::Builder` instead of `RuboCop::AST::Builder`
      #
      def create_parser(ruby_version)
        builder = Builder.new

        parser_class(ruby_version).new(builder).tap do |parser|
          parser.diagnostics.all_errors_are_fatal = (RUBY_ENGINE != 'ruby')
          parser.diagnostics.ignore_warnings = false
          parser.diagnostics.consumer = lambda do |diagnostic|
            @diagnostics << diagnostic
          end
        end
      end
    end
  end
end
