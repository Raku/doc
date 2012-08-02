use v6;
use Perl6::TypeGraph;

class Perl6::TypeGraph::Viz {
    has @.types;
    has $.dot-hints;
    has $.url-base    = '../type/';
    has $.rank-dir    = 'BT';
    has $.role-color  = '#6666FF';
    has $.class-color = '#000000';

    method new-for-type ($type) {
        my $self = self.bless(*, :types([$type]));
        $self!add-neighbors;
        return $self;
    }

    method !add-neighbors {
        sub visit ($n) {
            state %seen;
            return if %seen{$n}++;
            visit($_) for $n.super, $n.roles;
            @!types.push: $n;
        }

        for @.types -> $t {
	    visit($_) for $t, $t.sub, $t.doers;
        }

        @.types .= uniq;
    }

    method as-dot () {
        my @dot;
        @dot.push: "digraph \"perl6-type-graph\" \{\n    rankdir=$.rank-dir;\n    splines=polyline;\n";

        if $.dot-hints {
            @dot.push: "\n    // Layout hints\n";
            @dot.push: $.dot-hints;
        }

        @dot.push: "\n    // Types\n";
        for @.types -> $type {
            my $color = $type.packagetype eq 'role' ?? $.role-color !! $.class-color;
            @dot.push: "    \"$type.name()\" [color=\"$color\", fontcolor=\"$color\", href=\"{$.url-base ~ $type.name ~ '.html' }\"];\n";
        }

        @dot.push: "\n    // Superclasses\n";
        for @.types -> $type {
            for $type.super -> $super {
                @dot.push: "    \"$type.name()\" -> \"$super\" [color=\"$.class-color\"];\n";
            }
        }

        @dot.push: "\n    // Roles\n";
        for @.types -> $type {
            for $type.roles -> $role {
                @dot.push: "    \"$type.name()\" -> \"$role\" [color=\"$.role-color\"];\n";
            }
        }

        @dot.push: "\}\n";
        return @dot.join;
    }

    method to-dot-file ($file) {
        spurt $file, self.as-dot;
    }

    method to-file ($file, :$format = 'svg') {
        my $pipe = open "dot -T$format -o$file", :w, :p;
        $pipe.print: self.as-dot;
        close $pipe;
    }
}
