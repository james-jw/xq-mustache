(: Partial implementation of the Mustache template language 
 : 
 : @author James Wright
 : @license MIT
 : @date 10/17/15 
 :)
module namespace mustache = 'http://xq-mustache';

(: Regex expressions used to compile templates :)
declare variable $mustache:var-regex := '(\{{2}[^#^]\w*?\}{2})';
declare variable $mustache:var := 1;

declare variable $mustache:section-regex := '(\{{2}#?(\^?(\w*?))\}{2}(.*?)\{{2}/\4\}{2})';
declare variable $mustache:section := 2;
declare variable $mustache:section-name := 3;
declare variable $mustache:section-template := 5;

declare variable $mustache:regex := ($mustache:var-regex, $mustache:section-regex) => string-join('|');

(:Remove the mustache {, }, # and / characters:)
declare variable $mustache:clean := replace(?, '[#]|/|\{|\}', '');

declare function mustache:bool($item as item()*) as xs:boolean {
   $item instance of map(*) or boolean($item) 
};

(: Compiles a template for faster re-use :)
declare function mustache:compile($template as xs:string) as element(fn:analyze-string-result) {
  copy $out := analyze-string($template, $mustache:regex)
  modify (for $name in $out//fn:group[@nr = ($mustache:var, $mustache:section-name)] return
          replace value of node $name with $mustache:clean($name),
          for $section in $out/fn:match/fn:group[@nr = $mustache:section]
          for $sub-template in $section/fn:group[@nr = $mustache:section-template] return
          replace node $sub-template with mustache:compile($sub-template))
  return $out
};

(: Provided a mustache template, compiled or not, and a hash map, returns a rendered string
 : @param $template String mustache template, or compiled template.
 : @param $hash Hash map containing data to populate template
 :)
declare function mustache:render($template as item(), $hash as map(*)) as xs:string {
  let $template := if($template instance of element(fn:analyze-string-result))
                   then $template
                   else mustache:compile($template)
  return 
    copy $out := $template
    modify ( 
      for $name in $out/fn:match/fn:group[@nr = $mustache:var]
      return 
        replace value of node $name with $hash($name),
      for $section in $out/fn:match/fn:group[@nr = $mustache:section]
      let $name := $section/fn:group[@nr = $mustache:section-name]
      let $isInversion := starts-with($name, '^') 
      let $sub-template := $section/fn:analyze-string-result
      return 
        replace value of node $section with ( 
          if($isInversion and not(mustache:bool($hash(substring($name, 2))))) then
            mustache:render($sub-template, $hash)          
          else (
             let $value := $hash($name)
             let $items := if($value instance of array(*)) then $value?* else $value 
             return
              for $item in $items 
              where mustache:bool($item)  
              return
               mustache:render($sub-template, map:merge(($hash, $item)))
          ) => string-join(' ')
        )  
     )
   return $out
};
