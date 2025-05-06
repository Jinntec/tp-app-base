xquery version "3.1";

import module namespace file='http://exist-db.org/xquery/file';
import module namespace sm='http://exist-db.org/xquery/securitymanager';
import module namespace xmldb='http://exist-db.org/xquery/xmldb';

declare variable $EXIST_HOME := system:get-exist-home();

declare function local:get-file($src as xs:string ) as node() {
    
file:read($EXIST_HOME || $src) => fn:parse-xml()

};

declare function local:modify-conf($nodes as node()*) as item()* {
 
for $n in $nodes
return
    typeswitch($n)
        case text() return ($n)
        case comment () return ($n)
        case element (xquery) return if ($n/@enable-java-binding/data() eq 'no') 
            then ($n) 
            else (element xquery { attribute {'enable-java-binding'} {'no'}, local:modify-conf($n/node()) })
        case element (feature) return switch($n/@name)
            case 'http://xml.org/sax/features/external-general-entities' 
                return if($n/@value/data() eq 'false') 
                    then ($n)  
                    else (element feature { 
                        attribute {'name'} {'http://xml.org/sax/features/external-general-entities'},
                        attribute {'value'} {'false'}, 
                        local:modify-conf($n/node()) })
            case 'http://xml.org/sax/features/external-parameter-entities' 
                return if($n/@value/data() eq 'false') 
                    then ($n)  
                    else (element feature { 
                        attribute {'name'} {'http://xml.org/sax/features/external-parameter-entities'},
                        attribute {'value'} {'false'}, 
                        local:modify-conf($n/node()) })
            case 'http://javax.xml.XMLConstants/feature/secure-processing' 
                return if($n/@value/data() eq 'true') 
                    then ($n)  
                    else (element feature { 
                        attribute {'name'} {'http://javax.xml.XMLConstants/feature/secure-processing'},
                        attribute {'value'} {'true'}, 
                        local:modify-conf($n/node()) })
            default return (local:modify-conf($n/node()))
            
    default return ($n)
};
let $conf_prod := local:get-file('/etc/conf.xml') => local:modify-conf() 
return
    xmldb:store('/db/', 'conf_mod.xml', $conf_prod)
