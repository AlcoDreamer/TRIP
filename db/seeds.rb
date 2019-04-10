admins = [
  {password: 'root', login: 'root'},
  {password: 'yasya', login: 'yasya'}
]

admins.each do |a|
  Admin.create(a)
end
