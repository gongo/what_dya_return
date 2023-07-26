# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class CaseNode < ::RuboCop::AST::CaseNode
      include Ascendence
    end
  end
end
