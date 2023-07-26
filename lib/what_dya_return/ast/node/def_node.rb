# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class DefNode < ::RuboCop::AST::DefNode
      include Ascendence
    end
  end
end
