# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class ArrayNode < ::RuboCop::AST::ArrayNode
      include Ascendence
    end
  end
end
