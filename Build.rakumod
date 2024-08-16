class Build {
    BEGIN {
        note q:to/END/;
            This repository is not intended to be installed!
            View the latest HTML version at https://docs.raku.org/
            Command line viewer at https://github.com/raku/rakudoc
        END
        die;
    }
}
