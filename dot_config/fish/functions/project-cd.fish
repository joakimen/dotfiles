function project-cd
  set project (select-project)
  if set -q "$project"
    cd "$project"
  end
end

