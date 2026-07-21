function zd
  set parent_dir (list-filedirs)
  if test -n "$parent_dir"
    cd "$parent_dir"
  end
end
