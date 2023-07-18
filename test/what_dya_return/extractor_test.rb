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

    test 'if statement' do
      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if bar
            42
          end
        end
      CODE
      expect_result = ['42', '']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          42 if bar
        end
      CODE
      expect_result = ['42', '']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if bar
            42
          else
            'baz'
          end
        end
      CODE
      expect_result = ['42', '"baz"']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if bar
            42
          elsif baz
            'baz'
          else
            :piyo
          end
        end
      CODE
      expect_result = ['42', '"baz"', ':piyo']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          42 if true
        end
      CODE
      expect_result = ['42']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          42 if false
        end
      CODE
      expect_result = ['']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if true
            42
          else
            'baz'
          end
        end
      CODE
      expect_result = ['42']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if false
            42
          else
            'baz'
          end
        end
      CODE
      expect_result = ['"baz"']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          unless false
            42
          else
            'baz'
          end
        end
      CODE
      expect_result = ['42']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          unless true
            42
          else
            'baz'
          end
        end
      CODE
      expect_result = ['"baz"']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if bar
            42
          elsif false
            'baz'
          else
            :piyo
          end
        end
      CODE
      expect_result = ['42', ':piyo']
      assert_equal(expect_result, actual_result)

      actual_result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
        def foo
          if bar
            if baz
              42
            else
              :piyo
            end
          else
            if qux
              'quux'
            else
              'corge'
            end
          end
        end
      CODE
      expect_result = ['42', ':piyo', '"quux"', '"corge"']
      assert_equal(expect_result, actual_result)
    end
  end
end
