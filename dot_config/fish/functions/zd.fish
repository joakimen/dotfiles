function zd
  set parent_dir (list-filedirs)
  if set -q parent_dir
    cd "$parent_dir"
  end
end
