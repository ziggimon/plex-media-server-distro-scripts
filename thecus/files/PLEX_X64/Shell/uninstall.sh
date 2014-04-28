#!/bin/sh

res='fail'

mod_name='Plex'

/raid/data/module/cfg/module.rc/"$mod_name.rc" stop

/opt/bin/sqlite /raid/data/module/cfg/module.db "delete from module where name = '$mod_name'"
/opt/bin/sqlite /raid/data/module/cfg/module.db "delete from mod where module = '$mod_name'"

rm -rf "/raid/data/module/cfg/module.rc/$mod_name.rc"
rm -rf "/raid/data/module/$mod_name"
rm -f "/img/www/htdocs/modules/$mod_name"

res='pass'

echo $res
