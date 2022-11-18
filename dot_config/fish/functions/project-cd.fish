function project-cd
  set projects (project-list | string split0)
  if not set -q projects
    return
  end
  set dir (echo $projects | fzf)
  if test -n "$dir"
    cd "$HOME/$dir"
  end
end

