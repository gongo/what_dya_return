# frozen_string_literal: true

require 'test_helper'

module WhatDyaReturn
  class ExtractorTest < Test::Unit::TestCase
    def assert_extract_values(code, expected)
      actual = WhatDyaReturn::Extractor.new.extract(code)
      assert_equal(expected, actual)
    end

    def test_no_statement
      assert_extract_values(<<-CODE, ['nil'])
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
      assert_extract_values(<<-CODE, %w[42])
        def foo
          return 42
        end
      CODE
    end

    def test_conditional_with_if
      assert_extract_values(<<-CODE, %w[42 nil])
        def foo
          if bar
            42
          end
        end
      CODE
    end

    def test_conditional_with_if_modifier
      assert_extract_values(<<-CODE, %w[42 nil])
        def foo
          42 if bar
        end
      CODE
    end

    def test_conditinal_with_if_modifier_must_true
      assert_extract_values(<<-CODE, %w[42])
        def foo
          42 if true
        end
      CODE
    end

    def test_conditinal_with_if_modifier_must_false
      assert_extract_values(<<-CODE, %w[nil])
        def foo
          42 if false
        end
      CODE
    end

    def test_conditional_with_if_else
      assert_extract_values(<<-CODE, %w[1 2])
        def foo
          if bar
            1
          else
            2
          end
        end
      CODE
    end

    def test_conditional_with_if_elsif_else
      assert_extract_values(<<-CODE, %w[1 2 3])
        def foo
          if bar
            1
          elsif baz
            2
          else
            3
          end
        end
      CODE
    end

    def test_conditional_with_if_else_only_if_branch
      assert_extract_values(<<-CODE, %w[1])
        def foo
          if true
            1
          else
            2
          end
        end
      CODE
    end

    def test_conditional_with_if_else_only_else_branch
      assert_extract_values(<<-CODE, %w[2])
        def foo
          if false
            1
          else
            2
          end
        end
      CODE
    end

    def test_conditional_with_unless_else_only_unless_branch
      assert_extract_values(<<-CODE, %w[1])
        def foo
          unless false
            1
          else
            2
          end
        end
      CODE
    end

    def test_conditional_with_unless_else_only_else_branch
      assert_extract_values(<<-CODE, %w[2])
        def foo
          unless true
            1
          else
            2
          end
        end
      CODE
    end

    def test_conditional_with_if_elsif_else_exclude_elsif
      assert_extract_values(<<-CODE, %w[1 3])
        def foo
          if bar
            1
          elsif false
            2
          else
            3
          end
        end
      CODE
    end

    def test_conditional_with_nested_if_else
      assert_extract_values(<<-CODE, %w[1 2 3 4])
        def foo
          if bar
            if baz
              1
            else
              2
            end
          else
            if qux
              3
            else
              4
            end
          end
        end
      CODE
    end

    def test_conditinal_with_ternary
      assert_extract_values(<<-CODE, %w[1 2])
        def foo
          bar ? 1 : 2
        end
      CODE
    end

    def test_conditinal_with_ternary_only_former
      assert_extract_values(<<-CODE, %w[1])
        def foo
          true ? 1 : 2
        end
      CODE
    end

    def test_conditinal_with_ternary_only_latter
      assert_extract_values(<<-CODE, %w[2])
        def foo
          false ? 1 : 2
        end
      CODE
    end

    def test_multiline
      assert_extract_values(<<-CODE, %w[3])
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

    def test_multiline_with_early_return_always
      assert_extract_values(<<-CODE, %w[1])
        def foo
          return 1
          2
          3
        end
      CODE
    end

    def test_conditional_with_case_when
      assert_extract_values(<<-CODE, %w[1 2 nil])
        def foo
          case bar
          when '1'
            1
          when '2'
            2
          end
        end
      CODE
    end

    def test_conditional_with_case_when_else
      assert_extract_values(<<-CODE, %w[1 2 3 4])
        def foo
          case bar
          when false
            1
          when 2
            2
          when nil
            3
          else
            4
          end
        end
      CODE
    end

    def test_conditional_with_case_when_else_no_case_condition
      assert_extract_values(<<-CODE, %w[2 4])
        def foo
          case
          when false
            1
          when 2
            2
          when nil
            3
          else
            4
          end
        end
      CODE
    end

    def test_conditional_with_case_when_have_return_all_branches
      assert_extract_values(<<-CODE, %w[1 2 42])
        def foo
          case
          when true
            return 1
          when 22
            return 2
          end

          42
        end
      CODE
    end

    def test_conditional_with_case_when_else_have_return_any_branches
      assert_extract_values(<<-CODE, %w[2 42])
        def foo
          case foo
          when true
            1
          else
            return 2
          end

          42
        end
      CODE
    end

    def test_conditional_with_case_when_else_have_return_all_branches
      assert_extract_values(<<-CODE, %w[1 2])
        def foo
          case
          when true
            return 1
          else
            return 2
          end

          42
        end
      CODE
    end

    def test_conditional_with_while
      assert_extract_values(<<-CODE, %w[nil])
        def foo
          while bar
            1
          end
        end
      CODE
    end

    def test_conditional_with_while_break_always
      assert_extract_values(<<-CODE, %w[2])
        def foo
          while bar
            1
            break 2
            3
          end
        end
      CODE
    end

    def test_conditional_with_while_break_sometimes
      assert_extract_values(<<-CODE, %w[2 nil])
        def foo
          while bar
            1
            break 2 if baz
            3
          end
        end
      CODE
    end

    def test_conditional_with_while_not_last_statement
      assert_extract_values(<<-CODE, %w[4])
        def foo
          while bar
            1
            break 2
            3
          end

          4
        end
      CODE
    end

    def test_conditional_with_while_condition_always_false
      assert_extract_values(<<-CODE, %w[nil])
        def foo
          while false
            break 2
          end
        end
      CODE
    end

    def test_conditional_with_until
      assert_extract_values(<<-CODE, %w[nil])
        def foo
          until bar
            1
          end
        end
      CODE
    end

    def test_conditional_with_until_break_always
      assert_extract_values(<<-CODE, %w[2])
        def foo
          until bar
            1
            break 2
            3
          end
        end
      CODE
    end

    def test_conditional_with_until_break_sometimes
      assert_extract_values(<<-CODE, %w[2 nil])
        def foo
          until bar
            1
            break 2 if baz
            3
          end
        end
      CODE
    end

    def test_conditional_with_until_not_last_statement
      assert_extract_values(<<-CODE, %w[4])
        def foo
          until bar
            1
            break 2
            3
          end

          4
        end
      CODE
    end

    def test_conditional_with_until_condition_always_true
      assert_extract_values(<<-CODE, %w[nil])
        def foo
          until true
            break 2
          end
        end
      CODE
    end

    def test_rescue
      assert_extract_values(<<-CODE, %w[1 2])
        def foo
          1
        rescue
          2
        end
      CODE
    end

    def test_rescue_else
      assert_extract_values(<<-CODE, %w[3 2])
        def foo
          1
        rescue
          2
        else
          3
        end
      CODE
    end

    def test_rescue_ensure
      assert_extract_values(<<-CODE, %w[1 2])
        def foo
          1
        rescue
          2
        ensure
          3
        end
      CODE
    end

    def test_rescue_else_ensure
      assert_extract_values(<<-CODE, %w[3 2])
        def foo
          1
        rescue
          2
        else
          3
        ensure
          4
        end
      CODE
    end

    def test_rescue_else_ensure_with_early_return_in_ensure
      assert_extract_values(<<-CODE, %w[4])
        def foo
          1
        rescue
          2
        else
          3
        ensure
          return 4
        end
      CODE
    end

    def test_rescue_else_ensure_with_early_return_in_begin
      assert_extract_values(<<-CODE, %w[1 2])
        def foo
          return 1
        rescue
          2
        else
          3
        ensure
          4
        end
      CODE
    end
  end
end
