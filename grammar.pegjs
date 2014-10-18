/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */

{
  function optionalList(value) {
    return value !== null ? value : [];
  }

  function buildList(first, rest, index) {
    return [first].concat(extractList(rest, index));
  }

  function extractList(list, index) {
    var result = new Array(list.length), i;

    for (i = 0; i < list.length; i++) {
      result[i] = list[i][index];
    }

    return result;
  }
}


start
  = __ program:Program __ { return program; }

Program
  = body:SourceElements? {
      return {
        type: "Program",
        body: optionalList(body)
      };
    }

SourceElements
  = first:SourceElement rest:(__ SourceElement)* {
      return buildList(first, rest, 1);
    }

SourceElement
  = Statement

Statement
  = Block
  / LetStatement
  / VarStatement

Block
= "{" __ body:(StatementList __)? "}" {
    return {
      type: "BlockStatement",
      body: optionalList(extractOptional(body, 0))
    };
  }

StatementList
  = first:Statement rest:(__ Statement)* { return buildList(first, rest, 1); }

LetStatement
  = "let" WhiteSpace identifier:Identifier WhiteSpace "=" WhiteSpace expression:expression { return { type: "ValueBinding", identifier: identifier, expression: expression } }

VarStatement
  = "var" WhiteSpace identifier:Identifier WhiteSpace "=" WhiteSpace expression:expression { return { type: "ValueBinding", identifier: identifier, expression: expression } }

Identifier
  = name:[a-zA-Z0-9]+ { return { type: "Identifier", name: name.join('') } }

expression
  = integer

integer "integer"
  = digits:[0-9]+ { return { type: "Literal", value: parseInt(digits.join(""), 10) } }



__
  = (WhiteSpace / LineTerminatorSequence / Comment)*

_
  = (WhiteSpace / MultiLineCommentNoLineTerminator)*

WhiteSpace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"
  / Zs

LineTerminator
  = [\n\r\u2028\u2029]

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"

Comment "comment"
  = MultiLineComment
  / SingleLineComment

MultiLineComment
  = "/*" (!"*/" SourceCharacter)* "*/"

MultiLineCommentNoLineTerminator
  = "/*" (!("*/" / LineTerminator) SourceCharacter)* "*/"

SingleLineComment
  = "//" (!LineTerminator SourceCharacter)*

// Separator, Space
Zs = [\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]

SourceCharacter
  = .