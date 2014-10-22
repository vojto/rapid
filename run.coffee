fs = require('fs')

prettyjson = require('prettyjson')
colors = require('colors');

PEG = require('pegjs')
escodegen = require('escodegen')


grammar = fs.readFileSync('./grammar.pegjs', 'utf8')
parser = PEG.buildParser(grammar)

input = fs.readFileSync('./input.rapid', 'utf8')

assert = (value) ->
  if !value
    throw "Expected truthy value: #{value}"

class Environment
  constructor: ->
    @contexts = []
    @push(new Context)

  push: (context) ->
    @contexts.push(context)

  current: -> @contexts[-1..][0]

  bind: (identifier, value) ->
    @current().bind(identifier, value)


class Context
  constructor: ->
    @bindings = {}

  bind: (identifier, value) ->
    if @bindings[identifier]
      Checker.fail "Already bound: #{identifier}"

    @bindings[identifier] = value


class Checker
  parse: (tree) ->
    # Create empty stack with first context
    @environment = new Environment

    @parseNode(tree)

  @fail: (error) ->
    node = Checker.node
    console.log "#{error} on #{node.loc}".red

    process.exit()

  parseNode: (node) ->
    Checker.node = node

    if node.type == 'Program'
      return @parseArray(node.body)

    if node.type == 'VariableDeclaration'
      return @parseArray(node.declarations)

    if node.type == 'VariableDeclarator'
      return @declareVariable(node)

    throw "Unknow node type #{node.type}"

  parseArray: (array) ->
    @parseNode(node) for node in array


  declareVariable: (declaration) ->
    assert declaration.id.type == 'Identifier'

    @environment.bind declaration.id.name, declaration.init





tree = parser.parse(input)
console.log('tree', prettyjson.render(tree));

checker = new Checker()
checker.parse(tree)

result = escodegen.generate(tree, indent: '')

console.log 'result'
console.log result


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