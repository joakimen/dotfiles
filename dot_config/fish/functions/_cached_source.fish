function _cached_source --description "Cache and source the output of 'cmd init fish'"
    # Usage: _cached_source [--watch FILE]... <command> [args...]
    # Example: _cached_source --watch ~/.config/scriv/config.toml scriv init fish
    # Caches output to ~/.cache/fish/<command>.fish, regenerates when the binary
    # changes, when a watched file changes, or when the cache is older than
    # $_cached_source_ttl seconds (30 days).

    # `-s` stops at the command name, so the command's own flags — starship's
    # `--print-full-init` — are arguments to pass on rather than options here.
    argparse -s 'w/watch=+' -- $argv
    or return 1

    set -l cmd $argv[1]
    set -l bin_path (command -s $cmd)
    or return 1

    set -l cache_dir ~/.cache/fish
    set -l cache_file $cache_dir/$cmd.fish

    set -q _cached_source_ttl; or set -g _cached_source_ttl (math 30 x 24 x 60 x 60)
    # Read the clock once per shell rather than once per cached command.
    set -q _cached_source_now; or set -g _cached_source_now (date +%s)

    set -l stale
    if not test -f $cache_file
        set stale 1
    else if test $bin_path -nt $cache_file
        set stale 1
    else if test (math $_cached_source_now - (path mtime $cache_file)) -gt $_cached_source_ttl
        set stale 1
    end

    # A config file the command reads is as much an input as the binary is.
    # Without this, editing it changes nothing until the binary happens to move.
    for watched in $_flag_watch
        if test -e $watched; and test $watched -nt $cache_file
            set stale 1
        end
    end

    if set -q stale[1]
        mkdir -p $cache_dir
        # Generate to a temp file so a failing command doesn't blank the cache.
        set -l tmp_file $cache_file.(random).tmp
        if command $argv >$tmp_file
            mv -f $tmp_file $cache_file
        else
            rm -f $tmp_file
            # Fall back to the stale cache if we have one.
            test -f $cache_file; or return 1
        end
    end

    source $cache_file
end
