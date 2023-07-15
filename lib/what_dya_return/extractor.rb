# frozen_string_literal: true

require 'rubocop-ast'
require 'unparser'
require_relative 'processor'

module WhatDyaReturn
  class Extractor
    #
    # @param [String] source_code
    # @return [Array<String>]
    # @raise [WhatDyaReturn::SyntaxErrfor] if `source_code` cannot be parsed
    #
    def extract(source_code)
      processed = ::RuboCop::AST::ProcessedSource.new(source_code, RUBY_VERSION.to_f)
      raise WhatDyaReturn::SyntaxError unless processed.valid_syntax?

      Processor.new.process(processed.ast).map { |node| Unparser.unparse(node) }
    end
  end
end
