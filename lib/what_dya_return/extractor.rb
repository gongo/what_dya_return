# frozen_string_literal: true

require 'unparser'
require_relative 'processor'

module WhatDyaReturn
  class Extractor
    #
    # Extracts the return value candidates from `source_code`
    #
    # @example
    #
    #   WhatDyaReturn::Extractor.new.extract(<<-CODE)
    #     def foo
    #       if bar
    #         42
    #       else
    #         'baz'
    #       end
    #     end
    #   CODE
    #   # => ['42', '"baz"']
    #
    # @param [String] source_code
    # @return [Array<String>]
    # @raise [WhatDyaReturn::SyntaxErrfor] if `source_code` cannot be parsed
    #
    def extract(source_code)
      processed = AST::ProcessedSource.new(source_code, RUBY_VERSION.to_f)

      raise WhatDyaReturn::SyntaxError unless processed.valid_syntax?
      raise WhatDyaReturn::ArgumentError if processed.ast.type != :def

      Processor.new.process(processed.ast).map do |node|
        node.nil? ? 'nil' : Unparser.unparse(node)
      end.uniq
    end
  end
end
