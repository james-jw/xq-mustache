module namespace mustache = 'http://xq-mustache';
declare variable $mustache:clean := replace(?, '[#]|/|\{|\}', '');

(: Provided a mustache template and hash map, returns a rendered string :)
declare function mustache:render($template as xs:string, $hash as map(*)) as xs:string {
  let $varRegex := '(\{{2}[^#^]\w*?\}{2})'
  let $section := '(\{{2}#?(\^?\w*?)\}{2}(.*?)\{{2}/\w*?\}{2})'
  let $regex := string-join(($varRegex, $section), '|')
  let $analysis := analyze-string($template, $regex)
  return 
    copy $out := trace($analysis)
    modify ( 
      for $var in $out//fn:group[@nr = 1]
      let $name := $mustache:clean($var) 
      return 
        replace value of node $var with $hash($name),
      for $section in $out/fn:match/fn:group[@nr = 2]
      let $name := $mustache:clean(trace($section/fn:group[@nr = 3]))
      return replace value of node $section with ( 
        if(starts-with(trace($name), '^') and not($hash(substring($name, 2)))) then
          mustache:render(trace($section/fn:group[@nr = 4]), $hash)          
        else (
          for $item in $hash($name)?* return 
            mustache:render($section/fn:group[@nr = 4], map:merge(($hash, $item)))
        ) => string-join(' ')
      )  
     )
   return $out
};
