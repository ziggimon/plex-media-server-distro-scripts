#!/bin/sh
res='fail'
mod_name='Plex'

mkdir "/raid/data/module/cfg/"               > /dev/null 2>&1
mkdir "/raid/data/module/cfg/module.rc/"     > /dev/null 2>&1
mkdir "/raid/data/module/$mod_name/"         > /dev/null 2>&1
mkdir "/raid/data/module/$mod_name/shell/"   > /dev/null 2>&1
mkdir "/raid/data/module/$mod_name/www/"     > /dev/null 2>&1
mkdir "/raid/data/module/$mod_name/sys/"  > /dev/null 2>&1
mkdir "/raid/data/module/$mod_name/bin/"  > /dev/null 2>&1

cp -f   /raid/data/tmp/module/Shell/module.rc             "/raid/data/module/cfg/module.rc/$mod_name.rc"       > /dev/null 2>&1
cp -Rrf  /raid/data/tmp/module/Binary/*			  "/raid/data/module/$mod_name/bin/"		       > /dev/null 2>&1
cp -Rrf  /raid/data/tmp/module/System/*			  "/raid/data/module/$mod_name/sys/"                   > /dev/null 2>&1
cp -Rrf  /raid/data/tmp/module/Shell/*                     "/raid/data/module/$mod_name/shell"                  > /dev/null 2>&1
cp -Rrf  /raid/data/tmp/module/WWW/*                       "/raid/data/module/$mod_name/www"                    > /dev/null 2>&1
cp -f   /raid/data/tmp/module/Configure/license.txt       "/raid/data/module/$mod_name/COPY"                   > /dev/null 2>&1

res='pass'

echo $res

