function _source --description "Source a file if it exists"
    test -s $argv[1] && source $argv[1]
end
