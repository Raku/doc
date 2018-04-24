use v6;
use Perl6::TypeGraph;

class Perl6::TypeGraph::Viz {
    has @.types;
    has $.dot-hints;
    has $.url-base    = '/type/';
    has $.rank-dir    = 'BT';
    has $.role-color  = '#6666FF';
    has $.enum-color  = '#33BB33';
    has $.class-color = '#000000';
    has $.node-soft-limit = 20;
    has $.node-hard-limit = 50;

    method new-for-type ($type) {
        my $self = self.bless(:types[$type]);
        $self!add-neighbors;
        return $self;
    }

    method !add-neighbors {
        # Add all ancestors (both class and role) to @.types
        sub visit ($n) {
            state %seen;
            return if %seen{$n}++;
            visit($_) for flat $n.super, $n.roles;
            @!types.append: $n;
        }

        # Work out in all directions from @.types,
        # trying to get a decent pool of type nodes
        my @seeds = flat @.types, @.types.map(*.sub), @.types.map(*.doers);
        while (@.types < $.node-soft-limit) {
            # Remember our previous node set
            my @prev = @.types;

            # Add ancestors of all seeds to the pool nodes
            visit($_) for @seeds;
            @.types .= unique;

            # Find a new batch of seed nodes
            @seeds = (flat @seeds.map(*.sub), @seeds.map(*.doers)).unique;

            # If we're not growing the node pool, stop trying
            last if @.types <= @prev or !@seeds;

            # If the pool got way too big, drop back to previous
            # pool snapshot and stop trying
            if @.types > $.node-hard-limit {
                @.types = @prev;
                last;
            }
        }
    }

    method as-dot (:$size) {
        my @dot;
        @dot.append: “digraph "perl6-type-graph" \{\n    rankdir=$.rank-dir;\n    splines=polyline;\n”;
        @dot.append: "    overlap=false; ";
        @dot.append: “    size="$size"\n” if $size;

        if $.dot-hints -> $hints {
            @dot.append: "\n    // Layout hints\n";
            @dot.append: $hints;
        }

        @dot.append: "\n    // Types\n";
        for @.types -> $type {
            my $color = do given $type.packagetype {
                when ‘role’ { $.role-color  }
                when ‘enum’ { $.enum-color  }
                default     { $.class-color }
            }
            @dot.append: “    "$type.name()" [color="$color", fontcolor="$color", href="{$.url-base ~ $type.name }", fontname="FreeSans"];\n”;
        }

        @dot.append: "\n    // Superclasses\n";
        for @.types -> $type {
            for $type.super -> $super {
                @dot.append: “    "$type.name()" -> "$super" [color="$.class-color"];\n”;
            }
        }

        @dot.append: "\n    // Roles\n";
        for @.types -> $type {
            for $type.roles -> $role {
                @dot.append: “    "$type.name()" -> "$role" [color="$.role-color"];\n”;
            }
        }

        @dot.append: "\}\n";
        return @dot.join;
    }

    method to-dot-file ($file) {
        spurt $file, self.as-dot;
    }

    method to-file ($file, :$format = 'svg', :$size --> Promise:D) {
        once {
            run 'dot', '-V', :!err or die 'dot command failed! (did you install Graphviz?)';
        }
        die "bad filename '$file'" unless $file;
        my $graphvizzer = ( $file ~~ /Metamodel\:\: || X\:\:Comp/ )??'neato'!!'dot';
        spurt $file ~ ‘.dot’, self.as-dot(:$size).encode; # raw .dot file for debugging
        my $dot = Proc::Async.new(:w, $graphvizzer, '-T', $format, '-o', $file);
        my $promise = $dot.start;
        await($dot.write(self.as-dot(:$size).encode));
        $dot.close-stdin;
        $promise
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
