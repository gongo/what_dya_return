# frozen_string_literal: true

require 'test_helper'

module WhatDyaReturn
  class ExtractorTest < Test::Unit::TestCase
    test 'no statement' do
      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
        end
      CODE
      expect_result = ['']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          42
        end
      CODE
      expect_result = ['42']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          'bar'
        end
      CODE
      expect_result = ['"bar"']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          :baz
        end
      CODE
      expect_result = [':baz']
      assert_equal(expect_result, actual_result)
    end

    test 'return statement' do
      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          return 42
        end
      CODE
      expect_result = ['42']
      assert_equal(expect_result, actual_result)
    end
  end
end
