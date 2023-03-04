#! /usr/bin/env raku

# see USAGE for info.

use Telemetry; # used so we can check these docs
# stubs
role Result{...}; role Ok{...}; role Err{...}; role ErrKind{...}; role UncheckableType {...}
role NoTypeFound{...}; class Report{...}; class Summary{...}; grammar MethodDoc {...}

my $doc_dir := $*PROGRAM.resolve.parent(2);
constant $report_opts   = (<a all>, <n none>, <u under>, <o over>, <i introspect>, <p pass>, <f fail>, <e err>);
constant $summary_opts  = (<a all>, <n none>, <u under>, <o over>, <i introspect>, <t totals>);

#| Allowable values for --report
subset ReportCsv  of Str:D where *.split(',')».trim ⊆ ($report_opts.flat);
#| Allowable values for --summary
subset SummaryCsv of Str:D where *.split(',')».trim ⊆ ($summary_opts.flat);
#| Type to require an argument to be True
subset Flag of Bool:D where :so;

#| Scan a rakudoc file or directory of rakudoc files for under-documented & over-documented methods
sub MAIN(
    IO(Str) $input-path where *.e="{$doc_dir}/doc/Type",    #= Path to the file or directory to check
    ReportCsv  :report(:$r)='all',                          #= Comma-separated list of documentation types to display
    SummaryCsv :summary(:$s)='all',                         #= Comma-separated list of summary types to display
    Flag :$h,                                               #= Display short usage information and exit
    Flag :$help,                                            #= Display long usage information and exit
    Str  :i(:$ignore)="$doc_dir/util/ignored-methods.txt",  #= Path to file with methods to skip
    Str  :exclude(:$e),                                     #= Exclude files matching Regex
    Str  :exclude-dir(:$E),                                 #= Exclude directories matching Regex
    Str  :only(:$o),                                        #= Include ONLY files matching Regex
    Str  :only-dir(:$O),                                    #= Include ONLY files within one or more directories
                                                            #= matching Regex
) { # Exit early for --help or invalid usage not handled by typechecking
    when $h { short-usage}; when $help { long-usage }
    CATCH { when X::Syntax::Regex::SolitaryQuantifier | X::Syntax::Regex::Adverb {
                  note "invalid Regex '{$e//$E//$o//$O}' {.message}\n"
                  ~ "Use ./{$*PROGRAM.relative} --help for usage info"}}
    # Setup
    my $reports-to-print   := $r.&normalize-options($report_opts);
    my $summaries-to-print := $s.&normalize-options($summary_opts);
    # avoid perf penalty of re-constructing Regex
    my %filters = exclude => do with $e { /<$e>/ }, exclude-dir => do with $E { /<$E>/ },
                  only    => do with $o { /<$o>/ }, only-dir    => do with $O { /<$O>/ };
    my %ignored-types is Map = validate-ignore-file($ignore);
    my $summary := Summary.new;

    # Main program execution -- parse each file, and print reports as we go
    for $input-path.&process-rakudoc(:%filters, :%ignored-types).map(
        -> Result $_ --> Str {
            when Err { given .kind {
                when NoTypeFound     { if $reports-to-print ~~ 'err'  { Report::fmt($_)} }
                when UncheckableType { $summary.update(:uncheckable-type);
                                       if $reports-to-print ~~ 'introspect' { Report::fmt($_)} }
                default { X::Syntax::Missing.new(what => "error case {.kind.gist}").throw}
            }}
            my (:%file, :%methods (:%over-documented, :%under-documented, :%introspection, *%)) := .unwrap;

            $summary.update(:totals, |%methods)
                    .update(:%over-documented,   :%file)
                    .update(:%under-documented, :%file)
                    .update(:%introspection);

            my $status := (given [∪] |(%over-documented<>:v), |(%under-documented<>:v) -> $problem-methods {
                when $problem-methods ∪ (%introspection<missing>:v) ~~ ∅         { '✔' }
                when $problem-methods ~~ ∅ && (%introspection<missing>:v) !~~ ∅  { '∅' }
                default                                                          { '✗' }
            });

            (if (($reports-to-print ~~ 'pass')  && $status eq '✔')
             || (($reports-to-print ~~ 'introspect')  && ?%introspection<missing>.values».List.flat)
             || (($reports-to-print ~~ 'under') && ?%under-documented.values».List.flat)
             || (($reports-to-print ~~ 'over')  &&  ?%over-documented.values».List.flat) {
                    "\n$status {%file<type-name>} – documented at ⟨%file<path>.IO}⟩\n"
            })

            ~ (if $reports-to-print ~~ 'under'      { Report::fmt(:%under-documented) })
            ~ (if $reports-to-print ~~ 'over'       { Report::fmt(:%over-documented) })
            ~ (if $reports-to-print ~~ 'introspect' { Report::fmt(:missing-introspection(%introspection<missing>)) });
        }
    ) { .print };

    # Only print summaries after printing reports
    if $summaries-to-print !~~ 'none'       { print $summary.fmt(:header)};
    if $summaries-to-print  ~~ 'totals'     { print $summary.fmt(:totals) };
    if $summaries-to-print  ~~ 'under'      { print $summary.fmt(:under-documented)};
    if $summaries-to-print  ~~ 'over'       { print $summary.fmt(:over-documented)};
    if $summaries-to-print  ~~ 'introspect' { print $summary.fmt(:introspection)};
}

#| Process either a Pod6 file or a directory of Pod6 files
proto process-rakudoc(|) { given {*} { .WHAT ~~ List ?? $_ !! ($_,).List} };

#| Process a directory of Pod6 files by recursively processing each file
multi process-rakudoc($path where *.IO.d, :%ignored-types,
                   :%filters (:$exclude, :$exclude-dir, :$only, :$only-dir) --> List) {
    |(lazy $path.dir ==> grep( -> $path {
                             when $path ~~ :d { all( (with $exclude-dir { $path.basename !~~ $_}))}
                             default          { all( (with $exclude     { $path.basename !~~ $_}),
                                                     (with $only        { $path.basename  ~~ $_}),
                                                     (with $only-dir    { $path.parent    ~~ $_}))}})
                     ==> map({|process-rakudoc($^next-path, :%ignored-types, :%filters)}))
}

#| Process a Pod6 file by parsing with the MethodDoc grammar and then comparing
#| the documented methods against the methods visible via introspection
multi process-rakudoc($path where *.IO.f, :%ignored-types, *% --> Result) {
    POST {{ # Must return either an error or a methods Map with only Set|Bag leaf values
        when Ok { given .unwrap<methods> {
            when Set|Bag { True }
            when Map     { ?all($_.values.map(&?BLOCK))}
            default      { note "Expected Set|Bag but got {.WHAT.gist}"; False } } }
        default { True }
    }}

    when $path !~~ /'doc/Type/'.*.rakudoc/ { return NoTypeFound.new(:$path)}
    my $type-name := (S/.*'doc/Type/'(.*).rakudoc/$0/).subst(:g, '/', '::') with $path;
    my $ignored-methods := %ignored-types{"$type-name", 'ALL_TYPES'}.map(|*).grep(Any:D).List;

    # if we're at a low enough level that this amount of introspection fails, skip the type
    try { ::($type-name).^methods;
          CATCH { default { return UncheckableType.new(:$path, :$type-name)}} }

    # Methods from the doc
    my (:@in-header, :@with-signature) :=
            $path.IO.lines.map({ MethodDoc.parse($_).made }).grep(*.defined).classify(*.key, :as{.value});

    # Methods from introspection
    my %methods := (::($type-name).^methods(:local).classify(
                          # despite the name, not all :local methods are local, so we classify
                          {classify-method($_, $type-name, $ignored-methods);},
                          :into( %(<local ignored nqp-routine native-code other-missing-introspection
                                    from-a-role from-any from-mu from-other>.map(*=>[]))),
                          :as(*.name) ));
    my (:$local, :$ignored, :$nqp-routine, :$native-code, :$other-missing-introspection,
        :$from-a-role, :$from-any, :$from-mu, :$from-other, *%roles ) := %methods.map({.key => .value.Set});
    $native-code := Bag.new(%methods<native-code><>);

    # Comparison between the two
    my Set $missing-header    := $local (-) Set.new(@in-header);
    my Set $missing-signature := $local (-) @with-signature (-) $missing-header;
    my %over-documented       := (@in-header (-) $local).keys.classify(
        {classify-documented($_, $type-name)},
        :into(%(<doesn't-exist non-local non-method>.map(*=>[]))));
    my (:$non-local, :$non-method, :$doesn't-exist) := %over-documented.kv.map({ $^k => $^v.Set});

    ok(Map.new(( file    => Map.new((:$type-name, :$path)),
                 methods => Map.new(
                     (ignored       => $ignored,
                      introspection => Map.new((over-inclusive => Map.new((from-a-role => %roles.Bag, :$from-mu,
                                                                           :$from-any, :$from-other)),
                                                 missing        => Map.new((:$native-code, :$nqp-routine,
                                                                            :$other-missing-introspection)))),
                      under-documented => Map.new((:$missing-header, :$missing-signature)),
                      over-documented  => Map.new((:$non-local, :$non-method, :$doesn't-exist)),
                      all-good         => [(-)] $local, $other-missing-introspection, $missing-header,
                                                $native-code, $missing-signature, |%over-documented.values)))))
}

#| Classifies Methods by whether they are local to a Type based on Raku's introspection (or explicitly ignored)
sub classify-method(Mu $method, $type-name, List $ignored-methods) {
    when $method.name ∈ $ignored-methods                  { 'ignored' };
    # Some builtins don't support the introspection we need, mostly ones that call ForeignCode
    # (which includes NQP methods).  ForeignCode methods typically have the name `<anon>`
    when $method.name eq '<anon>'                         { 'native-code' };
    CATCH {  when X::Method::NotFound {
                  when .typename eq 'NQPRoutine'          { return 'nqp-routine' }
                  when .method ~~ 'roles' | 'candidates'  { return 'other-missing-introspection' } } }

    # we treat a multi method as local if any of it's variants are in the Type's package
    my $packages = (?$method.candidates ?? $method.candidates !! $method).map(*.package).cache;
    when ?any($packages.map({ try .isa($type-name)}))      { 'local'}
    when ?any($packages.map({ try $_ ~~ ::($type-name)}))  { 'local'}
    # For low level types, === won't work, so use string comparison of ^name
    my $package-names := try {$packages<>.map(*.^name).List} // ();
    my $type's-roles := try {::($type-name).^roles.map(*.^name).List} // ();
    when any($package-names) eq any($type's-roles) {
        $package-names.grep({ $_ ∈ $type's-roles}).head
    }
    when any($package-names) eq 'Any'                      { 'from-any' }
    when any($package-names) eq 'Mu'                       { 'from-mu' }
    default                                                { 'from-other' }
}

#| Classifies Methods by whether they are inherited, a non-method Sub, or just don't exist
sub classify-documented(Mu $method, $type-name) {
    # if ^find_method finds it, it's *somewhere* in the inheritance graph, just not local
    when try {::($type-name).^find_method($method).defined} { 'non-local' }
    # If the type matches first item in the signature, then it's a sub the type can call with .&…
    when try { any(&::($method).candidates.map(-> $a {::($type-name) ~~ $a.signature.params.head.type}))} {
        'non-method'
    }
    "doesn't-exist"
},

#| Namespace for report-printing functionality
class Report {
    #| Formats reports for individual Types (displayed with --report)
    our proto fmt(|) {*}

    #| Skipped type
    multi fmt(UncheckableType $e --> Str) {
        "\n∅ {$e.type-name} – documented at  ⟨{$e.path.IO}⟩\n  Skipped as uncheckable\n"
    }

    #| Unreadable type
    multi fmt(NoTypeFound $e --> Str) {
        "\n! ERR could not process file at ⟨{$e.path.IO}⟩\n  Does it contain documentation for a Raku type?\n"
    }

    #| Methods that can't be introspected
    multi fmt(:missing-introspection($_) --> Str) {
        ~( if .<nqp-routine> {
            "{+.<nqp-routine>} method implemented in Not Quite Perl:\n".&pluralize('method').indent(2)
            ~ (.<nqp-routine>.keys.sort.join("\n").indent(4) ~ "\n")})
        ~( if .<native-code> {
            "{+.<native-code>} method implemented in native-code:\n".&pluralize('method').indent(2)
            ~ (.<native-code>.keys.sort.join("\n").indent(4) ~ "\n")})
        ~( if .<other-missing-introspection> {
            "{+.<other-missing-introspection>} method without introspection:\n".&pluralize('method').indent(2)
            ~ (.<other-missing-introspection>.keys.sort.join("\n").indent(4) ~ "\n")})

    }

    #| Non-local Methods that are documented (but shouldn't be)
    multi fmt(:%over-documented (:$non-local, :$non-method, :$doesn't-exist) --> Str) {
        ~( if $non-local {
            "{+$non-local} non-local method with documentation:\n".&pluralize('method').indent(2)
            ~ $non-local.keys.sort.join("\n").indent(4) ~ "\n"})
        ~( if $non-method {
            "{+$non-method} non-method with documentation:\n".&pluralize('non-method').indent(2)
            ~ $non-method.keys.sort.join("\n").indent(4) ~ "\n"})
        ~( if $doesn't-exist {
            "{+$doesn't-exist} non-existing method with documentation:\n".&pluralize('method').indent(2)
            ~ $doesn't-exist.keys.sort.join("\n").indent(4) ~ "\n"})
    }

    #| Local Methods that should be documented (but aren't)
    multi fmt(:%under-documented (:%missing-header, :%missing-signature) --> Str) {
        ~ ( if +%missing-header {
             "{+%missing-header} missing method:\n".&pluralize('method').indent(2)
             ~ %missing-header.keys.sort.join("\n").indent(4) ~ "\n" })
        ~ ( if %missing-signature {
             ("{+%missing-signature} method without signature:\n"
                 ).&pluralize('method').&pluralize('signature').indent(2)
             ~ %missing-signature.keys.sort.join("\n").indent(4) ~ "\n"})
    }

    #| Appends an 's' to the provided $noun if the closest preceding number in $phrase is ≥ 2
    sub pluralize(Str $phrase, Str $noun --> Str) {
        $phrase ~~ /(\d+) \D* $noun/;
        +$0 == 1 ?? $phrase !! $phrase.subst(/$noun/, $noun ~ 's')
    }
}

#| Collects and formats summary statistics (displayed with --summary)
class Summary {
    has Map $!totals;
    has Map $!under-documented;
    has Map $!over-documented;
    has Map $!over-inclusive-introspection;

    # Hard-coded constants that change Summary output.  (Could be user-configurable if wanted)
    constant $missing_method_threshold    = 20;
    constant $overdocked_method_threshold = 20;
    constant $top_missing_list_length    = 5;
    constant $top_overdocked_list_length = 5;
    constant $top_roles_list_length       = 5;
    constant $line_length                 = 40;
    constant $head                        = '#' x $line_length;
    constant $subhead                     = '=' x $line_length;

    submethod BUILD() {
        # Maps with scalar values gives interior mutability but guarantees we can't typo keys
        $!totals := Map.new(
            ( types   => Map.new((skip => $=0, pass => $=0, fail => $=0)),
              methods => Map.new(
                  ( pass                  => $=0,
                    ignored               => $=0,
                    under-documented      => Map.new(( missing-header => $=0, missing-signature => $=0 )),
                    over-documented       => Map.new(( doesn't-exist => $=0, non-method => $=0, non-local => $=0 )),
                    missing-introspection => Map.new(( native-code => $=0, nqp-routine => $=0,
                                                       other-missing-introspection => $=0 )) ))));
        $!under-documented := Map.new(
            ( missing-per-type           => BagHash.new(),
              times-missing-by-method    => BagHash.new()));
        $!over-documented  := Map.new(
            ( missing-per-type           => BagHash.new(),
              times-overdocked-by-method => BagHash.new()));
        $!over-inclusive-introspection := Map.new(( from-a-role => BagHash.new(), from-any => $=0,
                                                    from-mu => $=0, from-other => $=0, anon => $=0 ));
    }

    #| Update the running totals based on new data
    proto update(|) {*}
    multi submethod update(Flag :uncheckable-type($)!) {
        $!totals<types><skip>++;
        self
    }
    multi submethod update(:$totals!, :$ignored, :$all-good, :%under-documented, :%over-documented, :%uncheckable) {
        my $problem-methods = [∪] ((%uncheckable,  %under-documented,  %over-documented)».values.map(|*));
        $problem-methods ~~ ∅ ?? $!totals<types><pass>++ !! $!totals<types><fail>++;
        given $!totals<methods> {
            .<ignored> += +$ignored;
            .<pass>    += +$all-good;
        }
        self
    }
    multi submethod update(:%under-documented!, :%file (:$type-name, *%)) {
        $!under-documented<missing-per-type>{$type-name}       += +%under-documented<missing-header>;
        $!totals<methods><under-documented><missing-header>    += +%under-documented<missing-header>;
        $!totals<methods><under-documented><missing-signature> += +%under-documented<missing-signature>;
        for %under-documented<missing-header>.keys { $!under-documented<times-missing-by-method>.add($_)};
        self
    }
    multi submethod update(:%over-documented!, :%file (:$type-name, *%)) {
        $!totals<methods><over-documented>{.key}        += .value.elems for %over-documented.pairs;
        $!over-documented<missing-per-type>{$type-name} += +%over-documented<doesn't-exist>;
        for %over-documented<doesn't-exist>.keys { $!over-documented<times-overdocked-by-method>.add($_) };
        self
    }
    multi submethod update(:introspection($_)) {
        for .<missing>.kv { $!totals<methods><missing-introspection>{$^key} += +$^value};
        for .<over-inclusive>.kv -> $k, $v {
            when $k eq 'from-a-role' { $!over-inclusive-introspection<from-a-role>.add($v.kxxv); }
            default                  { $!over-inclusive-introspection{$k} += +$v}
        };
        self
    }

    #| Format summary statistics (as governed by --summary)
    proto fmt(|) {*};
    multi submethod fmt(Flag :header($)! --> Str) {
        fmt-head('SUMMARY').&center ~ "\n"
    }
    multi submethod fmt(Flag :totals($)! --> Str) {
        (given $!totals<types> {
            my ($detected, $checked) := (.&total, .&total - .<skip>);
            qq:to/EOF/

              { 'Total types processed:'.&center }
              $subhead
              documented types detected:          {'%4d'.sprintf($detected)}
              types checked:                      {$checked.&fmt-with-percent-of(:$detected)}
              types skipped:                      {.<skip>.&fmt-with-percent-of(:$detected)}
              problems found:                     {.<fail>.&fmt-with-percent-of(:$checked)}
              no problems found:                  {.<pass>.&fmt-with-percent-of(:$checked)}
             EOF
            })
        ~ (given $!totals<methods>  {
            my ($detected, $checked)  = (.&total, .&total - .<missing-introspection>.&total - .<ignored>);
            qq:to/EOF/

             { 'Total methods processed:'.&center }
             $subhead
             documented methods detected:        { '%4d'.sprintf($detected)}
             explicitly ignored methods:         { .<ignored>.&fmt-with-percent-of(:$detected)}
             non-introspectable methods skipped: { .<missing-introspection>.&total.&fmt-with-percent-of(:$detected)}
             methods checked:                    { $checked.&fmt-with-percent-of(:$detected)}
             over-documented methods:            { .<over-documented>.&total.&fmt-with-percent-of(:$checked)}
             under-documented methods:           { .<under-documented>.&total.&fmt-with-percent-of(:$checked)}
             problem-free methods:               { .<pass>.&fmt-with-percent-of(:$checked)}
             overinclusive introspection issues: { '%4d'.sprintf($!over-inclusive-introspection.&total)}
            EOF
        })
    }
    multi submethod fmt(Flag :under-documented($)! --> Str) {
        my (:%times-missing-by-method, :%missing-per-type) := $!under-documented;
        my $total = $!totals<methods><under-documented>.&total;
        my $top-missing = %times-missing-by-method
                              .grep(*.value ≥ $missing_method_threshold)
                              .sort({.value, .key})
                              .cache;
        my $top-types = %missing-per-type.sort({.value, .key}).tail($top_missing_list_length).cache;

        (given $!totals<methods><under-documented> { qq:to/EOF/

        { 'UNDER-DOCUMENTED'.&fmt-head.&center }

         { '(Potentially) under-documented methods:'.&center }
         { $subhead }
         missing methods:                    { .<missing-header>.&fmt-with-percent-of(:$total)}
         methods with no signature:          { .<missing-signature>.&fmt-with-percent-of(:$total)}
        {fmt-sum($total)}
        EOF
        })
        ~ (if $top-missing {
                  ~ " \n{'Methods missing from 20+ types:'.&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-list($top-missing) ~ "\n"
              })
        ~ (if $top-types.elems {
                  ~ " \n{"Top $top_missing_list_length types with missing methods:".&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-list($top-types)}) ~ "\n"
    }
    multi submethod fmt(Flag :over-documented($)! --> Str) {
        my (:%sums, :%missing-per-type, :%times-overdocked-by-method) := $!over-documented;
        my $total = $!totals<methods><over-documented>.&total;
        my $top-types = %missing-per-type.sort({.value, .key}).tail($top_overdocked_list_length).cache;
        my $top-overdocked = %times-overdocked-by-method.grep(*.value ≥ $overdocked_method_threshold).cache;

        ( given $!totals<methods><over-documented> { qq:to/EOF/

        { 'OVER-DOCUMENTED'.&fmt-head.&center }

         { 'Total over-documented methods:'.&center }
         $subhead
         non-local methods:                  {.<non-local>.&fmt-with-percent-of(:$total)}
         non-method routines:                {.<non-method>.&fmt-with-percent-of(:$total)}
         non-existent methods:               {.<doesn't-exist>.&fmt-with-percent-of(:$total)}
        {fmt-sum($total)}
        EOF
        })
        ~ (if $top-overdocked {
                  ~ "\n {'Overdocumented methods in 20+ types:'.&center}\n"
                  ~ " {$subhead}\n"
                  ~ fmt-top-list($top-overdocked) ~ "\n"
              })
        ~ (if $top-types.elems ≥ 3 {
                  ~ "\n {"Top $top_overdocked_list_length types with over-documented methods:".&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-list($top-types) ~ "\n" })
    }
    multi submethod fmt(Flag :introspection($)! --> Str) {
        my $over-inclusive := $!over-inclusive-introspection;
        my $missing := $!totals<methods><missing-introspection>;
        my $top-roles := $over-inclusive<from-a-role>.sort(*.values).tail($top_roles_list_length).List;
        qq:to/EOF/

        {'INTROSPECTION ISSUES'.&fmt-head.&center}

         {'Methods without needed introspection:'.&center}
         $subhead
         NativeCall methods:                 {'%4d'.sprintf($missing<native-code>)}
         Not Quite Perl methods:             {'%4d'.sprintf($missing<nqp-routine>)}
         Other non-introspecable methods:    {'%4d'.sprintf($missing<other-missing-introspection>)}
        {fmt-sum($missing.values.sum)}

         {"'local' methods actually from:".&center}
         $subhead
         ...a role:                          { '%4d'.sprintf($over-inclusive<from-a-role>)}
         ...Any:                             { '%4d'.sprintf($over-inclusive<from-any>)}
         ...Mu:                              { '%4d'.sprintf($over-inclusive<from-mu>)}
         ...some other type:                 { '%4d'.sprintf($over-inclusive<from-other>)}
        {fmt-sum($over-inclusive.values.sum)}
        EOF
        ~ (if $top-roles.elems ≥ 3 {
                  ~ "\n {"Top $top_roles_list_length roles providing 'local' methods:".&center}\n"
                  ~ " $subhead\n"
                  ~ fmt-top-list($top-roles) ~ "\n" })
    }

    #| Format list of methods with their counts aligned to the right
    sub fmt-top-list(List $top-methods) {
        ~ ($top-methods.sort(*.value)
                       .map({ " %-*s%3d".sprintf(($line_length - 3), .key, .value)})
                       .join("\n") ~ "\n")
        ~ fmt-sum($top-methods.map(*.value).sum ~ "\n")
    }

    #| Returns the length of the longest key in a list of pairs
    sub max-len(List $pairs --> Int) { $pairs.max(*.key.chars).key.chars }

    #| Format a number as a percent of a pair's value, and label it with the key's name
    sub fmt-with-percent-of($num, *%names where *.elems == 1) {
        my $name = S:g/'-'/ / with %names.head.key;
        given %names.head.value -> $val {
            when $val > 0 { "%4d (%4.1f%% of $name)".sprintf($num, 100 × $num/$val) }
            default       { "%4d".sprintf($num) }
        }
    }

    #| Recursively total a Map with Int|Baggy leaf nodes (cf. Bag.total)
    sub total($item where Int|Map|Baggy) is nodal {
        given $item { when Int { $_ }
                      when Baggy { $_.total }
                      when Map { [+] .values».&total}}
    }

    #| Center a line of text according to $line_length constant
    sub center($txt) { $txt.lines.map({' ' x ($line_length - .chars) ÷ 2 ~ $_}).join("\n")}

    #| Format a header by boxing it with `#` characters
    sub fmt-head($txt) { my $mid = $txt.lines.map({"#    {$_}    #"}).join("\n");
                         given '#' x $mid.lines.map(&chars).sum {($_, $mid, $_).join("\n")}
    }

    #| Format a sum by printing a line of `-` characters, and then the right-aligned sum
    sub fmt-sum($num) {
        given 'TOTAL', 5 -> ($txt, $num-len ){
            ('-' x $line_length  ~ "\n").indent(1)
            ~ ' ' x $line_length + 1 - $txt.chars - $num-len ~ $txt ~ '%*d'.sprintf($num-len, $num)}
    }
}

#| Parses a Pod6 document and returns all methods mentioned in a header or given a signature
grammar MethodDoc {
    token TOP { <doc-line> { make $<doc-line>.made }}

    proto rule doc-line          {*}
    rule doc-line:sym<signature> { <.ws>['multi' ]?<method-decl>'('.+  { make (with-signature => ~$<method-decl>)}}
    rule doc-line:sym<in-header> {      '=head'\d? <method-decl>       { make (in-header      => ~$<method-decl>)}}
    token method-decl            { ['method' | 'routine'] <.ws> <(<[-'\w]>+)>}
}

#| Display short usage instructions
sub short-usage() {
    USAGE;
    print qq:to/EOF/

      This script scans Pod6 documentation files and finds under-documented methods, over-documented
      methods, and methods with introspection issues.  Use the --help flag for more detailed usage
      information.

      EOF


}

#| Display detailed usage instructions (including full lists of allowed options)
sub long-usage() {
    sub fmt-allowed($opts) { $opts.split(' ').flat.join('|')}
    USAGE;
    print qq:to/EOF/

      This script scans Pod6 documentation files, compares the information in those files
      to information from Raku's internal introspection, and displays a large amount of
      information in three broad categories:

      1. Under-documented methods: methods that are implemented on a type, but that are
         not documented.  Because Raku's introspection can be a bit over-inclusive about
         what it considers to be a local method, this category only includes methods that
         are both local (according to Raku) _and_ implemented in a package with the same
         name as the type.  Separately, this category also includes methods that are
         documented but that lack signatures in their documentation.
      2. Over-documented methods: methods that are _not_ local to a type, but that are
         documented as though they were.  (This most often occurs when a method is
         implemented on a closely related role.)
      3. Methods with introspection issues: methods where either Raku does not provide us
         with enough information to determine whether they are correctly documented, or
         where Raku claims the method is local to a type but where it does not appear to
         actually local.  The first category is mostly low-level types, such as those
         implemented in NQP.

      For all three categories, this script displays info in two ways: First, as a series
      of «Reports» for all scanned types, one at a time.  You can control the generation
      of reports with the --report|-r option, which accepts a comma-separated string of
      the following values:
          {$report_opts.&fmt-allowed}
      'all' hides shows all reports; 'none' hides them all; 'under', 'over', and
      'introspect' show just the category described above; 'pass' shows reports with no
      issue (in any category); 'fail' shows all non-passing reports; and 'err' lists files
      that could not be scanned.

      Second, this script also displays «Summary» information about all scanned types.
      You can control the generation of summary info with the -s|--summary option, which
      accepts a comma-separated string of the following values:
          {$summary_opts.&fmt-allowed}
      'all', 'none', 'under', 'over', and 'introspect' behave just as in the --report
      option.  'totals' displays aggregate information applicable to all categories, such
      as the total number of files scanned.

      With default settings, this script provides a large amount of information.  To help
      you manage this information, the script provides several ways to manage its output
      (in addition to limiting output categories with -r or -s).  First, you can scan
      fewer types, by specifying an individual file or sub-directory as the INPUT-PATH
      argument.  Alternatively, you can provide a Regex to the --exclude or --exclude-dir
      options to exclude individual files or entire directories from your search.
      (Excluding the Metamodel directory, for example, will significantly reduce the
      number of types without introspection information).  You can perform the inverse
      operation, limiting the script to files/directories that match a Regex, with the
      --only and --only-dir options respectively.

      Finally, you can manually list methods to exclude from scanning in an ignore-methods
      file; you can direct the script to the location of that file with the --ignore
      option.  This file should consist of a Raku Map with Str keys and values that are
      Lists of Strs.  Specifically, each key should be the name of a type, or the special
      key ALL_TYPES; the value should be a list of methods that should be excluded from
      that type (or from all types).

      EOF
}

#| Provide dynamic usage info, including default values assigned in MAIN
sub USAGE() {
    my &fmt-param = { $^a ~ (' ' x (20 - $^a.chars) ~ $^b.WHY ~ (with $^b.default { " [default: {.()}]"})) }

    # print CLI parameters, grouped by arg/flag/opt and alphabetized within each group
    print S:g/'/home/'$(%*ENV<USER>)/~/ with do given &MAIN.signature.params.sort(*.name.fc).cache {
      "Usage: ./{$*PROGRAM.relative} [FLAGS]... [OPTION]... [ARG]\n"
      ~ "{&MAIN.WHY}\n\n"
      ~ (with .grep(!*.named) {
          "ARGS:\n"
          ~ .map({ fmt-param(.name.substr(1).uc, $_) }).join("\n").indent(2) ~ "\n\n"})
      ~ (with .grep({.named && .type ~~ Bool}) {
          "FLAGS:\n"
          ~ .map({
              fmt-param(.named_names.sort(*.chars).map({'-' x (1 + (.chars > 1))  ~ $_}).join(', '), $_);
             }).join("\n").indent(2) ~ "\n\n"})
      ~ (with .grep({.named && .type !~~ Bool}) {
                "OPTIONS:\n"
                ~ .map({
              fmt-param(.named_names.sort(*.chars).map({'-' x ++$ ~ $_}).join(', '), $_);
          }).join("\n").indent(2) ~ "\n"})
    }
}

#| Provide error messages that inform the user what unsupported parameter they passed
sub GENERATE-USAGE(&main, |c) {
    my $default-txt = "\nUse ./{$*PROGRAM.relative} --help for usage info";
    when +c.list > 1 { "Too many positional arguments passed: {c.list}\n"
                       ~ "Did you mean to pass an option?  Use '='" ~ $default-txt }
    my $last-invalid = c.list.pairs.head; my $h = c.hash;
    while $h !~~ &main.signature {
        $last-invalid = $h.pairs.tail;
        $h =  \(|$h.hash.head(*-1).hash);
    }
    sub fmt-allowed($opts) { $opts.split(' ').flat.join('|')}
    sub with-dash($txt) { ($txt.chars > 1 ?? '--' !! '-') ~ $txt }
    (given $last-invalid {
         when .key ~~ Int
              && !.value.IO.e       { "Cannot open INPUT-PATH '{.value}'"}
         when .key ~~ Int           { "Unrecognized positional argument '{.value}'" }
         when .value ~~ Bool        { "Unrecognized flag '{.key.&with-dash}'" }
         when .key eq 'r'|'report'  { "Invalid value for '--report'.  Valid values: {$report_opts.&fmt-allowed}"}
         when .key eq 's'|'summary' { "Invalid value for '--summary'.  Valid values: {$summary_opts.&fmt-allowed}"}
         default                    { "Invalid option '{.key.&with-dash}={.value}'" }
    }) ~ $default-txt
}

#| Convert a comma-separated Str of short and/or long options into a Junction of long options
sub normalize-options(Str $given, List $allowed --> Junction ) {
    $allowed.map(-> ($short, $l) { if  $short | $l ∈  $given.split(',')».trim { $l }}).cache
    ==> { any('all' ∈ $_ ??  $allowed.grep({$_ !~~ <n none>})»[1] !! |$_) }()
}

#| Create a Map from the specified file, or exit with an appropriate error message
sub validate-ignore-file(Str $ignore --> Map){
    when $ignore eq '' { note 'Not using ignored-methods file'; % }
    when !$ignore.IO.r { note "No ignored-methods file found.  Not ignoring any methods."; % }
    CATCH { default { note "Could not parse $ignore as a Raku Hash. Got error:\n{$!.gist.indent(4)}"; exit 1};}
    given EVALFILE($ignore) {
        constant $err_msg = "The file specified with --ignore must provide a Map";
        when $_ !~~ Map { note "$err_msg, not a {.^name}."; exit 1};
        .values.grep(* !~~ List) ==> {
            when ?$_ { note "$err_msg with List values, but $_ is a {.head.WHAT.gist}"; exit 1}}();
        .values».values.flat.grep(* !~~ Str) ==> {
            when ?$_ { note "$err_msg with Lists of Strs as values, but $_ is a {.head.WHAT.gist}"; exit 1}}();
        default { $_ }
    }
};

# Result as an algebraic data type (specifically, a sum type)
#     Inspired by Rust's Result type and
#     https://wimvanderbauwhede.github.io/articles/roles-as-adts-in-raku/

#| The result of a fallible operation, which will be Ok|Err
role Result { method unwrap() {...} };

#| A successful Result that can be unwrapped
role Ok[::T] does Result {
    has T $!inner;
    submethod BUILD(Mu :$inner) { $!inner = $inner}
    method unwrap() { $!inner }
};

#| Construct a new Result[Ok]
sub ok(Mu $v --> Ok) { Ok[$v.WHAT].new(inner => $v) }

#| An unsuccessfully Result; attempting to unwrap it throws an exception
role Err does Result {
    has ErrKind $.kind;
    method unwrap() {
        self.^set_name('Err');
        note self.^roles[0].^candidates[0].WHY; # The WHY for the role, not the punned class
        fail(X::TypeCheck.new(operation => 'Result.unwrap()', expected => Ok, got => self))}
}

#| The helper role that every custom error type should do
role ErrKind does Err {
    method kind() { self }
    has $!name = self.^name;
    method raku() { $!name }
}

#| Error: The type lacked fundamental introspection methods, and could not be checked
role UncheckableType does ErrKind {
    has $.path;
    has $.type-name;
}

#| Error: No Type was detected at the provided path
role NoTypeFound does ErrKind {
    has $.path;
}
