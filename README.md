# parsed_data

(Very) experimental data parsing library that does two main things:
 * It converts JSON or XML strings into a generic, JSON-like data structure consisting of arrays and hashes.
 * It implements some support for querying and updating the data structure in an eager, recursive way:
  * All hash keys in the structure can be accessed via dot notation (i.e., "a[:b]" could be written as "a.b")
  * This dot notation support is eager and recursive.

The data structure can also be converted from a nested collection of arrays and hashes back to some other data structure. For example, a JSON string could be parsed, updated and then written back out as an XML string (using activesupport's built-in facilities for doing this.)

## Installation

```
gem install parsed_data
```

## Basic Usage
```ruby
require 'parsed_data'

# Create an XML string to parse:
xml_str = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
  <a type="array">
    <a type="integer">1</a>
    <a type="integer">2</a>
    <a>
      <b type="array">
        <b type="integer">3</b>
        <b>
          <c type="integer">4</c>
        </b>
      </b>
      <c type="integer">5</c>
    </a>
  </a>
EOS

# Parse the string.
data = xml_str.to_data
=> #<ParsedData:0x00007fddaac20918 @source={"hash"=>{"a"=>[1, 2, {"b"=>[3, {"c"=>4}], "c"=>5}]}}

# Note that the parsed data structure has two "c" keys. There's one at the top
# level and another one embedded down deeper in the structure. The top-level value
# could be accessed like this:
data.c
=> 5

# To get the second "c" value embedded deeper in the structure you don't need to
# explicitly traverse the data structure. You just need to provide enough
# information to find the correct key.
data.a.c
=> 4

# To change this value:
data.a.c = 777
=> 777

# To write out an XML string for the updated data:
data.to_xml

# To write out a JSON string for the updated data:
data.to_json
```
