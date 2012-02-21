name 'edge-server'
description 'An edge server exposes applications'
run_list ['role[base]', 'recipe[alice-routers]', 'recipe[alice-prober]' ]
