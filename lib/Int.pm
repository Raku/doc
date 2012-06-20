=begin pod

=head1 Int

    class Int is Cool does Real { ... }

C<Int> objects store integral numbers of arbitrary size. C<Int>s are immutable.

=head2 Operators

=head3 div

    multi sub infix:<div>(Int:D, Int:D) returns Int:D

Does an integer division, rounded down.

=end pod
