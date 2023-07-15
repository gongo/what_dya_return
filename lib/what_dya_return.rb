# frozen_string_literal: true

require_relative 'what_dya_return/extractor'
require_relative 'what_dya_return/version'

module WhatDyaReturn
  class Error < StandardError; end
  class SyntaxError < Error; end
end
