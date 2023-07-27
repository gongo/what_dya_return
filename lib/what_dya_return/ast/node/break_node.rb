# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class BreakNode < ::RuboCop::AST::BreakNode
      include Ascendence
    end
  end
end
