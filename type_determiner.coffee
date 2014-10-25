TreeParser = require('./tree_parser')

class TypeDeterminer
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

    console.log 'parsing node', node

module.exports = TypeDeterminer