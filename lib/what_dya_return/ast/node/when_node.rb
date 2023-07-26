# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class WhenNode < ::RuboCop::AST::WhenNode
      include Ascendence
    end
  end
end
