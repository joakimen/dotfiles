function kf-edit --description "Edit kf config files via fzf"
    set -l file (kf list | fzf)
    if test -n "$file"
        # Expand ~ without eval to avoid injection
        set file (string replace '~' "$HOME" -- $file)
        $EDITOR $file
    end
end
