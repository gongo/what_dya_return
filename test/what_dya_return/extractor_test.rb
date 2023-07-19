# frozen_string_literal: true

require 'test_helper'

module WhatDyaReturn
  class ExtractorTest < Test::Unit::TestCase
    def assert_extract_values(code, expected)
      actual = WhatDyaReturn::Extractor.new.extract(code)
      assert_equal(expected, actual)
    end

    def test_no_statement
      assert_extract_values(<<-CODE, [''])
        def foo
        end
      CODE
    end

    def test_return_integer
      assert_extract_values(<<-CODE, ['42'])
        def foo
          42
        end
      CODE
    end

    def test_return_string
      assert_extract_values(<<-CODE, ['"bar"'])
        def foo
          'bar'
        end
      CODE
    end

    def test_return_symbol
      assert_extract_values(<<-CODE, [':baz'])
        def foo
          :baz
        end
      CODE
    end

    def test_return_integer_using_return_statement
      assert_extract_values(<<-CODE, ['42'])
        def foo
          return 42
        end
      CODE
    end

    def test_conditional_with_if
      assert_extract_values(<<-CODE, ['42', ''])
        def foo
          if bar
            42
          end
        end
      CODE
    end

    def test_conditional_with_if_modifier
      assert_extract_values(<<-CODE, ['42', ''])
        def foo
          42 if bar
        end
      CODE
    end

    def test_conditinal_with_if_modifier_must_true
      assert_extract_values(<<-CODE, ['42'])
        def foo
          42 if true
        end
      CODE
    end

    def test_conditinal_with_if_modifier_must_false
      assert_extract_values(<<-CODE, [''])
        def foo
          42 if false
        end
      CODE
    end

    def test_conditional_with_if_else
      assert_extract_values(<<-CODE, ['42', '"baz"'])
        def foo
          if bar
            42
          else
            'baz'
          end
        end
      CODE
    end

    def test_conditional_with_if_elsif_else
      assert_extract_values(<<-CODE, ['42', '"baz"', ':piyo'])
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
    end

    def test_conditional_with_if_else_only_if_branch
      assert_extract_values(<<-CODE, ['42'])
        def foo
          if true
            42
          else
            'baz'
          end
        end
      CODE
    end

    def test_conditional_with_if_else_only_else_branch
      assert_extract_values(<<-CODE, ['"baz"'])
        def foo
          if false
            42
          else
            'baz'
          end
        end
      CODE
    end

    def test_conditional_with_unless_else_only_unless_branch
      assert_extract_values(<<-CODE, ['42'])
        def foo
          unless false
            42
          else
            'baz'
          end
        end
      CODE
    end

    def test_conditional_with_unless_else_only_else_branch
      assert_extract_values(<<-CODE, ['"baz"'])
        def foo
          unless true
            42
          else
            'baz'
          end
        end
      CODE
    end

    def test_conditional_with_if_elsif_else_exclude_elsif
      assert_extract_values(<<-CODE, ['42', ':piyo'])
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
    end

    def test_conditional_with_nested_if_else
      assert_extract_values(<<-CODE, ['42', ':piyo', '"quux"', '"corge"'])
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
    end

    def test_conditinal_with_ternary
      assert_extract_values(<<-CODE, ['42', '"baz"'])
        def foo
          bar ? 42 : 'baz'
        end
      CODE
    end

    def test_conditinal_with_ternary_only_former
      assert_extract_values(<<-CODE, ['42'])
        def foo
          true ? 42 : 'baz'
        end
      CODE
    end

    def test_conditinal_with_ternary_only_latter
      assert_extract_values(<<-CODE, ['"baz"'])
        def foo
          false ? 42 : 'baz'
        end
      CODE
    end

    def test_multiline
      assert_extract_values(<<-CODE, ['3'])
        def foo
          1
          2
          3
        end
      CODE
    end

    def test_multiline_with_early_return
      assert_extract_values(<<-CODE, %w[1 3])
        def foo
          return 1 if bar
          2
          3
        end
      CODE
    end

    def test_conditional_with_case_when
      assert_extract_values(<<-CODE, ['"1"', '"2"', ''])
        def foo
          case bar
          when 1
            '1'
          when 2
            '2'
          end
        end
      CODE
    end

    def test_conditional_with_case_when_else
      assert_extract_values(<<-CODE, ['"1"', '"2"', '"3"', '"4"'])
        def foo
          case bar
          when false
            '1'
          when 2
            '2'
          when nil
            '3'
          else
            '4'
          end
        end
      CODE
    end

    def test_conditional_with_case_when_else_no_case_condition
      assert_extract_values(<<-CODE, ['"2"', '"4"'])
        def foo
          case
          when false
            '1'
          when 2
            '2'
          when nil
            '3'
          else
            '4'
          end
        end
      CODE
    end
  end
end
