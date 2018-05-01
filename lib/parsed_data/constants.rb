class ParsedData
  JSON_REGEXP = /(
    (?<number>  -?(?=[1-9]|0(?!\d))\d+(\.\d+)?([eE][+-]?\d+)?){0}
    (?<boolean> true | false | null ){0}
    (?<string>  " (?>[^"\\\\]* | \\\\ ["\\\\bfnrt\/] | \\\\ u [0-9a-f]{4} )* " ){0}
    (?<array>   \[ (?> \g<json> (?: , \g<json> )* )? \s* \] ){0}
    (?<pair>    \s* \g<string> \s* : \g<json> ){0}
    (?<object>  \{ (?> \g<pair> (?: , \g<pair> )* )? \s* \} ){0}
    (?<json>    \s* (?> \g<number> | \g<boolean> | \g<string> | \g<array> | \g<object> ) \s* ){0}
  )
  \A \g<json> \Z
  /uix

  XML_REGEXP = /[[:space:]]*\<\?xml/
end
