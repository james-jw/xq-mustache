(: Partial implementation of the Mustache template language 
 : 
 : @author James Wright
 : @license MIT
 : @date 10/17/15 
 :)
module namespace mustache = 'http://xq-mustache';

(: Regex expressions used to compile templates :)
declare variable $mustache:is-mustache-regex := '\{{2}.*\}{2}';
declare function mustache:is-mustache($str as xs:string) as xs:boolean {
  matches($str, $mustache:is-mustache-regex) 
};

declare variable $mustache:var-regex := '(\{{2}[^#^]\w*?\}{2})';
declare variable $mustache:var := 1;

declare variable $mustache:section-regex := '(\{{2}#?(\^?(\w*?))\}{2}(.*?)\{{2}/\4\}{2})';
declare variable $mustache:section := 2;
declare variable $mustache:section-name := 3;
declare variable $mustache:section-template := 5;

declare variable $mustache:regex := ($mustache:var-regex, $mustache:section-regex) => string-join('|');

(:Remove the mustache {, }, # and / characters:)
declare variable $mustache:clean := replace(?, '[#/{}]', '');

(: Provided a mustache template, compiled or not, and a hash map, returns a rendered string
 : @param $template String mustache template, or compiled template.
 : @param $hash Hash map containing data to populate template
 :)
declare function mustache:render($template as item(), $hash as map(*)) {
  let $template := if($template instance of xs:string)
                   then mustache:compile($template)
                   else $template
  return
    mustache:internal-render($template, $hash) => string-join('')
};

declare function mustache:bool($item as item()?) as xs:boolean {
  $item instance of map(*) or $item
};

(: Compiles a template for faster re-use :)
declare function mustache:compile($template as xs:string) as item()* {
  let $pre-compile := mustache:pre-compile($template)
  return
    mustache:internal-compile($pre-compile)
};

declare %private function mustache:pre-compile($template as xs:string) {
  copy $out := analyze-string($template, $mustache:regex)
  modify (for $name in $out//fn:group[@nr = ($mustache:var, $mustache:section-name)] return
          replace value of node $name with $mustache:clean($name),
          for $section in $out/fn:match/fn:group[@nr = $mustache:section]
          for $sub-template in $section/fn:group[@nr = $mustache:section-template] return
          replace node $sub-template with mustache:pre-compile($sub-template))
  return $out
};

declare %private function mustache:get($path as xs:string, $hash as map(*)*) as item()* {
   let $out := ($hash ! .($path))[1]
   return if($out instance of array(*)) then $out?*
          else $out
}; 

declare %private function mustache:internal-compile($template as element()) {
   for $item in $template/* return
     if($item/local-name() = 'non-match') then data($item)
     else
       for $match in $item/fn:group return
         if($match/@nr = $mustache:var) then 
           mustache:get($mustache:clean($match), ?)
         else if($match/@nr = $mustache:section) then 
           let $sub-template := mustache:internal-compile($match/fn:analyze-string-result) 
           let $path := $mustache:clean($match/fn:group[@nr = $mustache:section-name])
           let $isInversion := starts-with($path, '^') 
           return 
             if($isInversion) 
             then mustache:internal-render-inversion($sub-template, substring($path,2), ?) 
             else mustache:internal-render($sub-template, $path, ?)
         else ()
};

declare %private function mustache:internal-render($template as item()*, $hash as map(*)*) {
  ( $template ! (if(. instance of function(*)) then .($hash) else .)) ! xs:string(.)
};

declare %private function mustache:internal-render($template as item()*, $path as xs:string, $hash as map(*)*) as xs:string* {
   let $sub-hash := mustache:get($path, $hash)
   let $count := count($sub-hash)
   return 
     if(mustache:bool($sub-hash[1]) or $count > 1) 
     then
       for $sub at $i in $sub-hash return (
         mustache:internal-render($template, ($sub, $hash)), 
         if($count > 1 and $i < ($count)) then ' '
         else ()
       )
     else ()
};

declare %private function mustache:internal-render-inversion($template as item()*, $path as xs:string, $hash as map(*)*) {
  if(not(mustache:bool($hash($path)))) then
    mustache:internal-render($template, $hash)
  else ()
};

