function _cached_source --description "Cache and source the output of 'cmd init fish'"
    # Usage: _cached_source <command> [args...]
    # Example: _cached_source starship init fish
    # Caches output to ~/.cache/fish/<command>.fish, regenerates when binary changes.

    set -l cmd $argv[1]
    set -l bin_path (command -s $cmd)
    or return 1

    set -l cache_dir ~/.cache/fish
    set -l cache_file $cache_dir/$cmd.fish

    if not test -f $cache_file; or test $bin_path -nt $cache_file
        mkdir -p $cache_dir
        command $argv >$cache_file
    end

    source $cache_file
end
