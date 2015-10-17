# xq-mustache
Partial implementation of the mustache template language for XQuery 3.1. <p />
See <a href="https://mustache.github.io/">Mustache.js</a> for details.

<h3>Whats implemented</h3>
<ul>
  <li>Variables</li>
  <li>Conditionals</li>
  <li>Sections</li>
  <li>Inverse Sections</li>
  <li>Template compilation</li>
</ul>

<h3>Namespace</h3>
<pre>import module namespace mustache = 'http://xq-mustache';</pre>

<h3>Methods</h3>
This module includes three methods in the spirit of Mustache. The methods are <code>render</code> and <code>compile</code> and <code>is-mustache</code>. <br />
The render method can take a raw string or compiled expression.
<pre>
render($template as item(), $hash as map(*)) as xs:string {
</pre>

Compiling templates is as easy as calling: 
<pre>
compile($template as item()) as element(fn:analyze-string-result) {
</pre>

To check if a string contains a mustache expression simply use:
<pre>
is-mustache($string as xs:string) as xs:boolean
</pre>

<h3>Usage</h3>
Import into your XQuery module or script and call <code>render</code> providing a template and hash.

<pre>
import module namespace mustache = 'http://xq-mustache';
let $hash := map { 'word': 'world' }
return
  mustache:render('Hello {{word}}!', $hash) 
</pre>

If the template is going to be used multiple times you can increase performance by compiling the expression:
<pre>
import module namespace mustache = 'http://xq-mustache';
let $hash := map { 'word': 'world' }
let $compiled := mustache:compile('Hello {{word}} {{index}}!')
return
  for $i in (1 to 1000)
  return
   mustache:render($compiled, map:merge(($hash, map { 'index': $i }))) 
</pre>

<h4>Unit Tests</h4>
If using BaseX, unit tests can be run from BaseX via the command line:
<pre>basex -t src/xq-mustache-test.xqm</pre>

<h4>Limitations</h4>
Lambdas are not supported

Happy templating!
