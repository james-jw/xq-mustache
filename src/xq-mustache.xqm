module namespace mustache = 'http://xq-mustache';

(:Remove the mustache {, }, # and / characters:)
declare variable $mustache:clean := replace(?, '[#]|/|\{|\}', '');

(: Compiles a template for faster re-use :)
declare function mustache:compile($template) as element(fn:analyze-string-result) {
  let $varRegex := '(\{{2}[^#^]\w*?\}{2})'
  let $section := '(\{{2}#?(\^?\w*?)\}{2}(.*?)\{{2}/\w*?\}{2})'
  let $regex := ($varRegex, $section) => string-join('|')
  return
    copy $out := analyze-string($template, $regex)
    modify (for $name in $out//fn:group[@nr = (1, 3)] return
            replace value of node $name with $mustache:clean($name),
            for $section in $out/fn:match/fn:group[@nr = 2]
            for $sub-template in $section/fn:group[@nr = 4] return
            replace node $sub-template with mustache:compile($sub-template))
    return $out
};

(: Provided a mustache template, compiled or not, a and hash map, returns an rendered string
 : @param $template String mustache template, or compiled template.
 : @param $hash     Hash map(*) containing data to populate template
 :)
declare function mustache:render($template as item(), $hash as map(*)) as xs:string {
  let $analysis := if($template instance of xs:string)
                   then mustache:compile($template)
                   else $template
  return 
    copy $out := $analysis
    modify ( 
      for $name in $out/fn:match/fn:group[@nr = 1]
      return 
        replace value of node $name with $hash($name),
      for $section in $out/fn:match/fn:group[@nr = 2]
      let $name := $section/fn:group[@nr = 3]
      let $compiled := $section/fn:analyze-string-result
      return 
        replace value of node $section with ( 
          if(starts-with($name, '^') and not($hash(substring($name, 2)))) then
            mustache:render($compiled, $hash)          
          else (
             for $item in $hash($name)?* return 
             mustache:render($compiled, map:merge(($hash, $item)))
          ) => string-join(' ')
        )  
     )
   return $out
};
