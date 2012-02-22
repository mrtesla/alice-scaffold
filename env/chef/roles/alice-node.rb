name 'base'
description 'This is the base alice-node role'
run_list [
  'recipe[alice-sys-deps]',
  'recipe[ruby]',
  'recipe[node]',
  'recipe[runit]',
  'recipe[pluto]',
  'recipe[redis]',
  'recipe[alice-prober]',
  'recipe[alice-routers]',
  'recipe[alice-passers]'
]
