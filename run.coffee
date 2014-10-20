fs = require('fs')

PEG = require('pegjs');
prettyjson = require('prettyjson')


grammar = fs.readFileSync('./grammar.pegjs', 'utf8')
parser = PEG.buildParser(grammar)

input = fs.readFileSync('./input.rapid', 'utf8')


class BindingsStack
  constructor: ->
    @contexts = []

  push: (context) ->
    @contexts.push(context)

  currentContext: ->
    @contexts[-1..][0]

class BindingsContext
  constructor: ->
    @bindings = {}

  @bindValue: (name, value) ->
    if @bindings[name]
      throw "Already bound: #{name}"


class Parser
  parse: (tree) ->
    # Create empty stack with first context
    @stack = new BindingsStack()
    context = new BindingsContext
    @stack.push(context)

    @parseNode(tree)

  parseNode: (node) ->
    if node.type == 'Program'
      return @parseArray(node.body)

    if node.type == 'ConstantDeclaration'
      return @parseConstantDeclaration(node)

    throw "Unknow node type #{node.type}"

  parseArray: (array) ->
    @parseNode(node) for node in array

  parseConstantDeclaration: (node) ->
    @declare(node.declarations)

  declare: (declarations) ->
    console.log 'declaring', declarations






tree = parser.parse(input)
console.log('tree', prettyjson.render(tree));

parser = new Parser()
parser.parse(tree)




# function bindValues(node, context) {
#   if (node.type == 'Program') {
#     node.body.forEach(function(statement) {
#       bindValues(statement, context);
#     })
#   } else if (node.type == 'ValueBinding') {
#     context.bindValue(node.identifier.name, node.expression.value);
#   }
# }

# bindValues(result, context);


# console.log('context', context);