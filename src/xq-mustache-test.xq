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

 declare %unit:test function test:mustache-sub-sections() {
   let $template := '{{#list}}Value: {{#values}}{{value}}{{/values}}{{/list}}'
   let $hash := map {
      'list': array {
        map { 
          'values': array {
            map { 'value': 'apple' }, 
            map { 'value': 'grape' }
          }
        },
        map { 
          'values': map {
            'value': 'orange' 
          }
        }
      }
   } 
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, 'Value: apple grape Value: orange') 
 };

 declare %unit:test function test:mustache-performance() {
   let $template := mustache:compile('{{#list}}Value: {{#values}}{{value}}{{/values}}{{/list}}')
   let $hash := map {
      'list': array {
        map { 
          'values': array {
            map { 'value': 'apple' }, 
            map { 'value': 'grape' }
          }
        },
        map { 
          'values': map {
            'value': 'orange' 
          }
        }
      }
   } 
   return
       (1 to 1000) ! mustache:render($template, $hash)
 };

 declare %unit:test function test:mustache-no-array-section() {
   let $template := '{{#list}}Value is {{value}}{{/list}}'
   let $hash := map {
      'list': map { 'value': 1.2 } 
   } 
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, 'Value is 1.2') 
 };

 declare %unit:test function test:mustache-false-section() {
   let $template := 'Should be just this{{#list}}Value is {{value}}{{/list}}'
   let $hash := map {
      'list': false() 
   } 
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, 'Should be just this') 
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

 declare %unit:test function test:mustache-is() {
   let $f := mustache:is-mustache(?) 
   return (
     unit:assert-equals($f('{{John}} doe is'), true()),
     unit:assert-equals($f('{{#list}}Template{{/list}}'), true()),
     unit:assert-equals($f('John doe is'), false())
   )
 };

 declare %unit:test function test:mustache-lambda() {
   let $template := '{{#welcome}}{{name}}s{{/welcome}}'
   let $hash := map {
      'name': 'world',
      'welcome': function ($template, $hash) {
         'Hello ' || mustache:render($template, $hash) || '!' 
      }
   }
   let $out := mustache:render($template, $hash)
   return
     unit:assert-equals($out, 'Hello worlds!')

 };
