# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class EnsureNode < ::RuboCop::AST::EnsureNode
      include Ascendence
    end
  end
end
