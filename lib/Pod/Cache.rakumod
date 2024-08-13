unit class Pod::Cache;

=begin overview

Given a filename, generate a cached, rendered text version of the POD
in that file. Return the C<IO> of the cached file.

Use the new RakuAST generation as it's speedier (and more likely to be correct).

=end overview


method cache-file(Str $file --> Str) {

    # We only cache rakudoc files.
    return $file if ! $file.ends-with('.rakudoc');

    my $outfile = '.pod-cache/' ~ $file;
    my $output-io = $outfile.IO;

    my $in-time = $file.IO.modified;
    my $out-time = $output-io.e ?? $output-io.modified !! 0;

    # If the input file is newer or the target file is empty, cache.
    # The empty check helps in cases where the cache creation died for some reason

    if $in-time > $out-time || $output-io.s == 0 {
       mkdir $output-io.dirname;
       my $outfile = $output-io.open(:w);
       LEAVE $outfile.close;
       $outfile.lock;

       %*ENV<RAKUDO_RAKUAST>="1"; # Activate AST mode
       my $job = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
       $job.stdout.tap(-> $buf {$outfile.print: $buf});

       my $has-error = ! await $job.start;
       if $has-error {
           note "Error occurred caching $file";
       }
    }
    $outfile
}
