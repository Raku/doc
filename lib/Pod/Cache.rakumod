unit class Pod::Cache;

=begin overview

Given a filename, generate a cached, rendered text version of the POD
in that file.

=end overview

method cache-file(Str $file --> Str) {
    my $outfile = '.pod-cache/' ~ $file;
    my $output-io = $outfile.IO;

    my $in-time = $file.IO.modified;
    my $out-time = $output-io.e ?? $output-io.modified !! 0;

    # If the input file is newer or the target file is empty, cache.
    # The empty check helps in cases where the cache creation died for some reason

    if $in-time > $out-time || $output-io.s == 0 {
       note "Caching $file";
       mkdir $output-io.dirname;
       my $outfile = $output-io.open(:w);
       LEAVE $outfile.close;
       $outfile.lock;
       my $job = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
       $job.stdout.tap(-> $buf {$outfile.print: $buf});

       my $has-error = ! await $job.start;
       if $has-error {
           note "Error occurred caching $file";
       }
    }
    $outfile
}
