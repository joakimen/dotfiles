function project-cd
  set projects_bin "scriv"
  if not type -q "$projects_bin"
    echo "missing bin: $projects_bin" >&2
    return
  end

  set projects ($projects_bin list | string split0)
  if not test -n "$projects"
    echo "couldn't list projects" >&2
    return
  end

  set project (echo "$projects" | fzf)
  if test "$status" -ne 0
    return
  end

  cd "$project"
end

