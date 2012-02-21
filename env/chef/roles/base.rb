name 'base'
description 'This is the base alice-node role'
run_list ['recipe[alice-sys-deps]', 'recipe[ruby]', 'recipe[node]', 'recipe[pluto]']
