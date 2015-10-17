module namespace test = 'http://basex.org/modules/xqunit-tests';
import module namespace mustache = 'http://xq-mustache' at 'xq-mustache.xqm'; 

 declare %unit:test function test:mustache-variables() {
   let $template := 'His name is {{first}} {{last}}.'
   let $hash := map {
      'first': 'John',
      'last': 'Doe'
   } 
   let $out := mustache:render($template, $hash)
   return 
    unit:assert-equals($out, 'His name is John Doe.')
 };

 declare %unit:test function test:mustache-escape-html() {
   let $hash := map {
      'html': '<code>Test markup</code>'
   }
   let $out := mustache:render('{{html}}', $hash)
   return
     unit:assert-equals($out, '<code>Test markup</code>')
 };

 declare %unit:test function test:mustache-sections() {
   let $template := '{{#list}}Value is {{value}}{{/list}}'
   let $hash := map {
      'list': array {
        map { 'value': 'apple' }, 
        map { 'value': 'orange'}
      }
   } 
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, 'Value is apple Value is orange') 
 };

 declare %unit:test function test:mustache-empty-list() {
   let $template := '{{#list}}Value is {{value}}{{/list}}'
   let $hash := map {
     'list': () 
   }
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, '')
 };


 declare %unit:test function test:mustache-inversion() {
   let $template := '{{^list}}No values{{/list}}'
   let $hash := map {
     'list': () 
   }
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, 'No values')
 };
