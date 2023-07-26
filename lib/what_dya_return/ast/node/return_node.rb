# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class ReturnNode < ::RuboCop::AST::ReturnNode
      include Ascendence
    end
  end
end
