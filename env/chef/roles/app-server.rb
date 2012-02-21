name 'app-server'
description 'An app server runs applications'
run_list ['role[base]', 'recipe[alice-passers]', 'recipe[alice-prober]' ]
