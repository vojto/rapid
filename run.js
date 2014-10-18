var fs = require('fs')

var PEG = require('pegjs');
var prettyjson = require('prettyjson')


var grammar = fs.readFileSync('./grammar.pegjs', 'utf8')
var parser = PEG.buildParser(grammar)

var input = fs.readFileSync('./input.rapid', 'utf8')
var result = parser.parse(input)

console.log('result', prettyjson.render(result));


function Stack() {
  this.contexts = [];
};

Stack.prototype.push = function(context) {
  this.contexts.push(context);
};

function Context() {
  this.bindings = {};
};

Context.prototype.bindValue = function(name, value) {
  if (this.bindings[name]) {
    throw 'Already bound: ' + name;
  }

  this.bindings[name] = value;
}



var stack = new Stack();
var context = new Context();

stack.push(context);

function bindValues(node, context) {
  if (node.type == 'Program') {
    node.body.forEach(function(statement) {
      bindValues(statement, context);
    })
  } else if (node.type == 'ValueBinding') {
    context.bindValue(node.identifier.name, node.expression.value);
  }
}

bindValues(result, context);


console.log('context', context);