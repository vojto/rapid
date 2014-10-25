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

  bindConstant: (identifier, value) ->
    @current().bindConstant(identifier, value)

  findBinding: (identifier) ->
    # TODO: loop through all contexts and check each
    @current().findBinding(identifier)


class Context
  constructor: ->
    @bindings = {}

  bind: (identifier, value) ->
    @checkBinding(identifier)

    @bindings[identifier] = {
      value: value,
      isVariable: true
    }

  bindConstant: (identifier, value) ->
    @checkBinding(identifier)    

    @bindings[identifier] = {
      value: value,
      isVariable: false
    }

  checkBinding: (identifier) ->
    if @bindings[identifier]
      Checker.fail "Already bound: #{identifier}"

  findBinding: (identifier) ->
    @bindings[identifier]


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

    if node.type == 'ConstantDeclaration'
      node.type = 'VariableDeclaration' # TODO: We're modifying tree now, should that be done in a separate pass?
      node.kind = 'var'
      return @declareConstants(node.declarations)

    if node.type == 'ExpressionStatement'
      return @parseNode(node.expression)

    if node.type == 'AssignmentExpression'
      return @parseAssignment(node)

    throw "Unknow node type #{node.type}"

  parseArray: (array) ->
    @parseNode(node) for node in array


  declareVariable: (declaration) ->
    assert declaration.id.type == 'Identifier'
    @environment.bind declaration.id.name, declaration.init

  declareConstants: (declarations) ->
    for declaration in declarations
      @declareConstant(declaration)

  declareConstant: (declaration) ->
    Checker.node = declaration
    assert declaration.id.type == 'Identifier'
    @environment.bindConstant declaration.id.name, declaration.init

  parseAssignment: (assignment) ->
    Checker.node = assignment

    assert assignment.left.type == 'Identifier' # for now only support assigning to identifiers

    identifier = assignment.left.name

    # It must exist
    binding = @environment.findBinding(identifier)

    if !binding
      Checker.fail "Not bound: #{identifier}"

    if !binding.isVariable
      Checker.fail "Attempting to change constant: #{identifier}"


    # TODO:
    # @environment.updateBinding(identifier, assignment.right)


    console.log 'parsing assignment', assignment





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