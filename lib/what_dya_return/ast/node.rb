# frozen_string_literal: true

module WhatDyaReturn
  module AST
    class Node < ::RuboCop::AST::Node
      include Ascendence
    end
  end
end
