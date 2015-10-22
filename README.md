# xq-mustache
Partial implementation of the mustache template language for XQuery 3.1. <p />
See <a href="https://mustache.github.io/">Mustache.js</a> for details.

### Whats implemented
* Variables
* Conditionals
* Sections
* Inverseions
* Compilation
* Lambdas

### Namespace
``http://xq-mustache``

### Dependencies
None

### Methods
This module includes three simple methods in the spirit of Mustache: <code>render</code>, <code>compile</code> and <code>is-mustache</code>. <br />

The render method can take a raw string or compiled expression and returns a rendered string.
```xquery
render($template as item(), $hash as map()) as xs:string 
```
Compiling a template is as easy as calling the following: 
```xquery
compile($template as item()) as element(fn:analyze-string-result) 
```
To check if a string contains a mustache expression simply use:
```xquery
is-mustache($string as xs:string) as xs:boolean
```
### Usage
Import into your XQuery module or script and call <code>render</code> providing a template and hash.

```xquery
import module namespace mustache = 'http://xq-mustache';
let $hash := map { 'word': 'world' }
return
  mustache:render('Hello {{word}}!', $hash) 
```
#### Compiling
If the template is going to be used multiple times you can increase performance significantly by compiling the expression:
```xquery
import module namespace mustache = 'http://xq-mustache';
let $hash := map { 'word': 'world' }
let $compiled := mustache:compile('Hello {{word}} {{index}}!')
  return
  for $i in (1 to 1000)
    return
      mustache:render($compiled, map:merge(($hash, map { 'index': $i }))) 
```
#### Lambdas
Lambdas allow for powerful patterns such as wrapping. For example, the following would return 
<code>Hello World!</code>

```xquery
let $template := '{{#greeting}}{{name}}{{/greeting}}'
let $hash := map {
  'name': 'world',
  'greeting': function ($template, $hash) {
      'Hello ' || mustache:render($template, $hash) || '!' 
  }
}
return
  mustache:render($template, $hash)
```

#### Unit Tests
If using BaseX, unit tests can be run from BaseX via the command line:
<pre>basex -t src/xq-mustache-test.xqm</pre>

Happy templating!
