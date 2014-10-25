TreeParser = require('./tree_parser')

class TypeDeterminer
  constructor: ({compiler}) -> 
    @compiler = compiler

  determineTypes: (tree) ->
    # Use tree parser to traverse tree bottom-up
    @parser = new TreeParser
    @parser.delegate = @

    @parser.parse(tree)

  didParse: (node) ->
    if node.type == 'Literal'
      if typeof node.value == 'number'
        node.kind = 'Number'
      else if typeof node.value == 'string'
        node.kind = 'string'

    if node.type == 'BinaryExpression'
      # TODO: Raise error if left or right is missing kind
      # TODO: Raise error if left has different type as right

      node.kind = node.left.kind

    console.log 'parsing node', node

module.exports = TypeDeterminer