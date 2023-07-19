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
result = WhatDyaReturn::Extractor.new.extract(<<-CODE)
  def foo
    if bar
      42
    else
      'baz'
    end
  end
CODE

result # => ['42', "'baz'"]
```

## Caution

`what_dya_return` is an experimental project. There are still many statements that are not supported.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gongo/what_dya_return .

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
