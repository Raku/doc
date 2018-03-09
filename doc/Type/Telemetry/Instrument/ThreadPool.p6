
=begin pod

=TITLE class Telemetry::Instrument::ThreadPool

=SUBTITLE Instrument for collecting ThreadPoolScheduler data

    class Telemetry::Instrument::ThreadPool { }

B<Note: > This class is a Rakudo-specific feature and not standard Perl 6.

Objects of this class are generally not created by themselves, but rather
through making a L<snap|/type/Telemetry>shot.

This class provides the following data points (in alphabetical order):

=item atc

The number of tasks completed by affinity thread workers
(B<a>ffinity-B<t>asks-B<c>ompleted).

=item atq

The number of tasks queued for execution for affinity thread workers
(B<a>ffinity-B<t>asks-B<q>ueued).

=item aw

The number of affinity thread workers (B<a>ffinity-B<w>orkers).

=item gtc

The number of tasks completed by general workers
(B<g>eneral-B<t>asks-B<c>ompleted).

=item gtq

The number of tasks queued for execution by general worker
(B<g>eneral-B<t>asks-B<q>ueued).

=item gw

The number of general workers (B<g>eneral-B<w>orkers).

=item s

The number of supervisor threads running, usually C<0> or C<1> (B<s>upervisor>).

=item ttc

The number of tasks completed by timer workers (B<t>imer-B<t>asks-B<c>ompleted).

=item ttq

The number of tasks queued for execution by timer workers
(B<t>imer-B<t>asks-B<q>ueued).

=item tw

The number of timer workers (B<t>imer-B<w>orkers).

=end pod

# vim: expandtab softtabstop=4 shiftwidth=4 ft=perl6
