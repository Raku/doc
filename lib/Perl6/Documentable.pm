class Perl6::Documentable {
    has Str $.kind;     # type, language doc, routine, operator
    has Str $.subkind;  # class/role/enum, sub/method, prefix/infix/...

    has Str $.name;
    has Str $.url;
    has     $.pod;
    has Bool $.pod-is-complete;

    method human-kind() {   # SCNR
        $.kind eq 'operator'
            ?? "$.subkind operator"
            !! $.subkind // $.kind;
    }
}
