#!/usr/bin/env raku

#=begin code
class Point {
    has Int $.x;
    has Int $.y;
}

class Rectangle {
    has Point $.lower;
    has Point $.upper;

    method area() returns Int {
        ($!upper.x - $!lower.x) * ( $!upper.y - $!lower.y);
    }
}

# Create a new Rectangle from two Points
my $r = Rectangle.new(lower => Point.new(x => 0, y => 0),
                      upper => Point.new(x => 10, y => 10));

say $r.area(); # OUTPUT: «100␤»
#=end code

#=begin code
# Example taken from
# https://medium.freecodecamp.org/a-short-overview-of-object-oriented-software-design-c7aa0a622c83
class Hero {
    has @!inventory;
    has Str $.name;
    submethod BUILD( :$name, :@inventory ) {
        $!name = $name;
        @!inventory = @inventory
    }

    method act {
        return @!inventory.pick;
    }
}
my $hero = Hero.new(:name('Þor'),
                    :inventory(['Mjölnir','Chariot','Bilskirnir']));
say $hero.act;
#=end code


#=begin code
class Task {
    has      &!callback;
    has Task @!dependencies;
    has Bool $.done;

    # Normally doesn't need to be written
    method new(&callback, *@dependencies) {
        return self.bless(:&callback, :@dependencies);
    }

    # BUILD is the equivalent of a constructor in other languages
    submethod BUILD(:&!callback, :@!dependencies) { }

    method add-dependency(Task $dependency) {
        push @!dependencies, $dependency;
    }

    method perform() {
        unless $!done {
            .perform() for @!dependencies;
            &!callback();
            $!done = True;
        }
    }
}

my $eat =
    Task.new({ say 'eating dinner. NOM!' },
        Task.new({ say 'making dinner' },
            Task.new({ say 'buying food' },
                Task.new({ say 'making some money' }),
                Task.new({ say 'going to the store' })
            ),
            Task.new({ say 'cleaning kitchen' })
        )
    );

$eat.perform();
#=end code


=begin code
class Str-with-ID is Str {
    my $.counter = 0;
    has Str $.string;
    has Int $.ID;

    method TWEAK() {
        $!ID = $.counter++;
    }
}

say Str-with-ID.new(string => 'First').ID;  # OUTPUT: «0»
say Str-with-ID.new(string => 'Second').ID; # OUTPUT: «1»
=end code


=begin code
my $in_destructor = 0;

class Foo {
    submethod DESTROY { $in_destructor++ }
}

my $foo;
for 1 .. 6000 {
    $foo = Foo.new();
}

say "DESTROY called $in_destructor times";
=end code


#=begin code
say Int.DEFINITE; # OUTPUT: «False␤» (type object)
say 426.DEFINITE; # OUTPUT: «True␤»  (instance)

class Foo {};
say Foo.DEFINITE;     # OUTPUT: «False␤» (type object)
say Foo.new.DEFINITE; # OUTPUT: «True␤»  (instance)
#=end code

#=begin code
multi foo (Int:U) { "It's a type object!" }
multi foo (Int:D) { "It's an instance!"   }
say foo Int; # OUTPUT: «It's a type object!␤»
say foo 42;  # OUTPUT: «It's an instance!␤»
#=end code


=for code :preamble<class Task {}>
has Task @!dependencies;


=for code
has Bool $.done;


=begin code
has Bool $!done;
method done() { return $!done }
=end code


=for code
has Bool $.done is rw;

=for code
has Bool $.done = False;

=begin code :preamble<class Task {}>
has Task @!dependencies;
has $.ready = not @!dependencies;
=end code

#=begin code
class a-class {
    has $.an-attribute is rw;
}
say (a-class.new.an-attribute = "hey"); # OUTPUT: «hey␤»
#=end code


#=begin code
class Str-with-ID is Str {
    my $counter = 0;
    our $hierarchy-counter = 0;
    has Str $.string;
    has Int $.ID;

    method TWEAK() {
        $!ID = $counter++;
        $hierarchy-counter++;
    }

}

class Str-with-ID-and-tag is Str-with-ID {
    has Str $.tag;
}

say Str-with-ID.new(string => 'First').ID;  # OUTPUT: «0␤»
say Str-with-ID.new(string => 'Second').ID; # OUTPUT: «1␤»
say Str-with-ID-and-tag.new( string => 'Third', tag => 'Ordinal' ).ID;
# OUTPUT: «2␤»
say $Str-with-ID::hierarchy-counter;       # OUTPUT: «4␤»
#=end code


=begin code
class Singleton {
    my Singleton $instance;
    method new {!!!}
    submethod instance {
        $instance = Singleton.bless unless $instance;
        $instance;
    }
}
=end code


=begin code :preamble<class Foo {}; sub some_complicated_subroutine {}>
class HaveStaticAttr {
    my Foo $.foo = some_complicated_subroutine;
}
=end code


=begin code :skip-test<incomplete code>
method add-dependency(Task $dependency) {
    push @!dependencies, $dependency;
}
=end code


=begin code :skip-test<incomplete code>
method perform() {
    unless $!done {
        .perform() for @!dependencies;
        &!callback();
        $!done = True;
    }
}
=end code


=begin code
class B {...}

class C {
    trusts B;
    has $!hidden = 'invisible';
    method !not-yours () { say 'hidden' }
    method yours-to-use () {
        say $!hidden;
        self!not-yours();
    }
}

class B {
    method i-am-trusted () {
        my C $c.=new;
        $c!C::not-yours();
    }
}

C.new.yours-to-use(); # the context of this call is GLOBAL, and not trusted by C
B.new.i-am-trusted();
=end code


=begin code
method new(&callback, *@dependencies) {
    return self.bless(:&callback, :@dependencies);
}
=end code


=begin code :preamble<has &.callback; has @.dependencies;>
submethod BUILD(:&!callback, :@!dependencies) { }
=end code


=begin code
has &!callback;
has @!dependencies;
has Bool ($.done, $.ready);
submethod BUILD(
        :&!callback,
        :@!dependencies,
        :$!done = False,
        :$!ready = not @!dependencies,
    ) { }
=end code


=for code :preamble<class Task {}>
my $eat = Task.new({ say 'eating dinner. NOM!' });


=begin code :preamble<class Task {}>
my $eat =
    Task.new({ say 'eating dinner. NOM!' },
        Task.new({ say 'making dinner' },
            Task.new({ say 'buying food' },
                Task.new({ say 'making some money' }),
                Task.new({ say 'going to the store' })
            ),
            Task.new({ say 'cleaning kitchen' })
        )
    );
=end code


=begin code :lang<output>
making some money
going to the store
buying food
cleaning kitchen
making dinner
eating dinner. NOM!
=end code

=head1 Inheritance


=begin code
class Employee {
    has $.salary;
}

class Programmer is Employee {
    has @.known_languages is rw;
    has $.favorite_editor;

    method code_to_solve( $problem ) {
        return "Solving $problem using $.favorite_editor in "
        ~ $.known_languages[0];
    }
}
=end code

=begin code :preamble<class Programmer {}>
my $programmer = Programmer.new(
    salary => 100_000,
    known_languages => <Perl Raku Erlang C++>,
    favorite_editor => 'vim'
);

say $programmer.code_to_solve('halting problem'),
    " will get \$ {$programmer.salary()}";
# OUTPUT: «Solving halting problem using vim in Perl will get $100000␤»
=end code


=begin code :preamble<class Employee {}>
class Cook is Employee {
    has @.utensils  is rw;
    has @.cookbooks is rw;

    method cook( $food ) {
        say "Cooking $food";
    }

    method clean_utensils {
        say "Cleaning $_" for @.utensils;
    }
}

class Baker is Cook {
    method cook( $confection ) {
        say "Baking a tasty $confection";
    }
}

my $cook = Cook.new(
    utensils  => <spoon ladle knife pan>,
    cookbooks => 'The Joy of Cooking',
    salary    => 40000
);

$cook.cook( 'pizza' );       # OUTPUT: «Cooking pizza␤»
say $cook.utensils.raku;     # OUTPUT: «["spoon", "ladle", "knife", "pan"]␤»
say $cook.cookbooks.raku;    # OUTPUT: «["The Joy of Cooking"]␤»
say $cook.salary;            # OUTPUT: «40000␤»

my $baker = Baker.new(
    utensils  => 'self cleaning oven',
    cookbooks => "The Baker's Apprentice",
    salary    => 50000
);

$baker.cook('brioche');      # OUTPUT: «Baking a tasty brioche␤»
say $baker.utensils.raku;    # OUTPUT: «["self cleaning oven"]␤»
say $baker.cookbooks.raku;   # OUTPUT: «["The Baker's Apprentice"]␤»
say $baker.salary;           # OUTPUT: «50000␤»
=end code


=begin code :preamble<class Programmer {}; class Cook {}>
class GeekCook is Programmer is Cook {
    method new( *%params ) {
        push( %params<cookbooks>, "Cooking for Geeks" );
        return self.bless(|%params);
    }
}

my $geek = GeekCook.new(
    books           => 'Learning Raku',
    utensils        => ('stainless steel pot', 'knife', 'calibrated oven'),
    favorite_editor => 'MacVim',
    known_languages => <Raku>
);

$geek.cook('pizza');
$geek.code_to_solve('P =? NP');
=end code


=begin code :preamble<class Programmer {}; class Cook {}>
class GeekCook {
    also is Programmer;
    also is Cook;
    # ...
}

role A {};
role B {};
class C {
    also does A;
    also does B;
    # ...
}
=end code


=begin code :preamble<class Programmer {}; class Employee {}; class GeekCook {}>
my Programmer $o .= new;
if $o ~~ Employee { say "It's an employee" };
say $o ~~ GeekCook ?? "It's a geeky cook" !! "Not a geeky cook";
say $o.^name;
say $o.raku;
say $o.^methods(:local)».name.join(', ');
=end code

=begin code :lang<output>
It's an employee
Not a geeky cook
Programmer
Programmer.new(known_languages => ["Perl", "Python", "Pascal"],
        favorite_editor => "gvim", salary => "too small")
code_to_solve, known_languages, favorite_editor
=end code


=for code :preamble<my $o>
say $o.^attributes.join(', ');
say $o.^parents.map({ $_.^name }).join(', ');


=begin code
class Cook {
    has @.utensils  is rw;
    has @.cookbooks is rw;

    method cook( $food ) {
        return "Cooking $food";
    }

    method clean_utensils {
        return "Cleaning $_" for @.utensils;
    }

    multi method gist(Cook:U:) { '⚗' ~ self.^name ~ '⚗' }
    multi method gist(Cook:D:) {
        '⚗ Cooks with ' ~ @.utensils.join( " ‣ ") ~ ' using '
          ~ @.cookbooks.map( "«" ~ * ~ "»").join( " and ") }
}

my $cook = Cook.new(
    utensils => <spoon ladle knife pan>,
    cookbooks => ['Cooking for geeks','The French Chef Cookbook']);

say Cook.gist; # OUTPUT: «⚗Cook⚗»
say $cook.gist; # OUTPUT: «⚗ Cooks with spoon ‣ ladle ‣ knife ‣ pan using «Cooking for geeks» and «The French Chef Cookbook»␤»
=end code
