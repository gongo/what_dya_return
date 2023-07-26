# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class RescueNode < ::RuboCop::AST::RescueNode
      include Ascendence
    end
  end
end
