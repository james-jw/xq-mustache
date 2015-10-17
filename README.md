# xq-mustache
Partial implementation of the mustache template language for XQuery 3.1. <p />
See <a href="https://mustache.github.io/">Mustach.js</a> for details.

<h3>Usage</h3>
Import into your XQuery module or script and call <code>render</code> providing a template and hash.

<pre>
import module namespace mustache = 'http://xq-mustach';
let $hash := map { 'word': 'world' }
return
  mustache:render('Hello {{word}}!', $hash) 
</pre>

<h4>Limitations</h4>
Lambdas are not supported

Happy templating!
