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

    if $in-time > $out-time {
       mkdir $output-io.dirname;
       my $outfile = $output-io.open(:w);
       LEAVE $outfile.close;
       $outfile.lock;
       my $job = Proc::Async.new($*EXECUTABLE-NAME, '--doc', $file);
       $job.stdout.tap(-> $buf {$outfile.print: $buf});

       await $job.start;
    }
    $outfile
}
