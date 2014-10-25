# For now, this class implements bottom-up parsing

class TreeParser
  constructor: ->

  parse: (tree) ->
    @nodes = []

    @parseNode(tree)

  parseNode: (node) ->
    @delegate?.willParse?(node)

    switch node.type
      when 'Program' then @parseArray(node.body)
      when 'VariableDeclaration' then @parseArray(node.declarations)
      when 'VariableDeclarator' then @parseNode(node.init)
      when 'ConstantDeclaration' then @parseArray(node.declarations)
      when 'ExpressionStatement' then @parseNode(node.expression)
      when 'AssignmentExpression' then @parseArray([node.left, node.right])
      when 'BinaryExpression'
        @parseNode(node.left)
        @parseNode(node.right)
      when 'Literal' then
      when 'Identifier' then
      else
        throw "Unknow node type #{node.type}"

    @delegate?.didParse?(node)

    

  parseArray: (array) ->
    @parseNode(node) for node in array

  bazinga: (node) ->
    console.log 'bazinga', node


module.exports = TreeParser