# WhatDyaReturn

:angel: "What do you return?"

```rb
def foo
  if bar
    42
  else
    'baz'
  end
end
```

:robot: "42 and 'baz'"

## Installation

    $ gem install what_dya_return

## Usage

```rb
WhatDyaReturn::Extractor.new.extract(<<-CODE)
  def foo
    if bar
      42
    else
      'baz'
    end
  end
CODE
# => ['42', "'baz'"]

WhatDyaReturn::Extractor.new.extract(<<-CODE)
  def foo
    return 42 if bar # `bar` is not evaluated in this gem

    123
  end
CODE
# => ['42', '123']

WhatDyaReturn::Extractor.new.extract(<<-CODE)
  def foo
    return 42

    123
  end
CODE
# => ['42']

puts WhatDyaReturn::Extractor.new.extract(<<-CODE)
  def foo
    do_something
  rescue
    2
  else
    3
  ensure
    4
  end
CODE
# => ['3', '2']
```

## Caution

`what_dya_return` is an experimental project. There are still many statements that are not supported.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gongo/what_dya_return .

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
