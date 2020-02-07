package Code::Includable::Tree::NodeMethods;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
our $GET_PARENT_METHOD = 'parent';
our $GET_CHILDREN_METHOD = 'children';
our $SET_PARENT_METHOD = 'parent';
our $SET_CHILDREN_METHOD = 'children';

# we must contain no other functions

use Scalar::Util ();

# like children, but always return list
sub _children_as_list {
    my $self = shift;
    my @children = $self->$GET_CHILDREN_METHOD;
    if (@children == 1) {
        return () unless defined($children[0]);
        return @{$children[0]} if ref($children[0]) eq 'ARRAY';
    }
    @children;
}

sub _descendants {
    my ($self, $res) = @_;
    my @children = _children_as_list($self);
    push @$res, @children;
    for (@children) { _descendants($_, $res) }
}

sub descendants {
    my $self = shift;
    my $res = [];
    _descendants($self, $res);
    @$res;
}

sub ancestors {
    my $self = shift;
    my @res;
    my $parent = $self->$GET_PARENT_METHOD;
    while ($parent) {
        push @res, $parent;
        $parent = $parent->$GET_PARENT_METHOD;
    }
    @res;
}

sub walk {
    my ($self, $code) = @_;
    for (descendants($self)) {
        $code->($_);
    }
}

sub first_node {
    my ($self, $code) = @_;
    for (descendants($self)) {
        return $_ if $code->($_);
    }
    undef;
}

sub is_first_child {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my @siblings = _children_as_list($parent);
    @siblings && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[0]);
}

sub is_last_child {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my @siblings = _children_as_list($parent);
    @siblings && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[-1]);
}

sub is_only_child {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my @siblings = _children_as_list($parent);
    @siblings==1;# && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[0]);
}

sub is_nth_child {
    my ($self, $n) = @_;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my @siblings = _children_as_list($parent);
    @siblings >= $n && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[$n-1]);
}

sub is_nth_last_child {
    my ($self, $n) = @_;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my @siblings = _children_as_list($parent);
    @siblings >= $n && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[-$n]);
}

sub is_first_child_of_type {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my $type = ref($self);
    my @siblings = grep { ref($_) eq $type } _children_as_list($parent);
    @siblings && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[0]);
}

sub is_last_child_of_type {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my $type = ref($self);
    my @siblings = grep { ref($_) eq $type } _children_as_list($parent);
    @siblings && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[-1]);
}

sub is_only_child_of_type {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my $type = ref($self);
    my @siblings = grep { ref($_) eq $type } _children_as_list($parent);
    @siblings == 1; # && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[0]);
}

sub is_nth_child_of_type {
    my ($self, $n) = @_;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my $type = ref($self);
    my @siblings = grep { ref($_) eq $type } _children_as_list($parent);
    @siblings >= $n && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($siblings[$n-1]);
}

sub is_nth_last_child_of_type {
    my ($self, $n) = @_;
    my $parent = $self->$GET_PARENT_METHOD;
    return 0 unless $parent;
    my $type = ref($self);
    my @children = grep { ref($_) eq $type } _children_as_list($parent);
    @children >= $n && Scalar::Util::refaddr($self) == Scalar::Util::refaddr($children[-$n]);
}

sub prev_sibling {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD or return undef;
    my $refaddr = Scalar::Util::refaddr($self);
    my @siblings = _children_as_list($parent);
    for my $i (1..$#siblings) {
        if (Scalar::Util::refaddr($siblings[$i]) == $refaddr) {
            return $siblings[$i-1];
        }
    }
    undef;
}

sub prev_siblings {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD or return ();
    my $refaddr = Scalar::Util::refaddr($self);
    my @siblings = _children_as_list($parent);
    for my $i (1..$#siblings) {
        if (Scalar::Util::refaddr($siblings[$i]) == $refaddr) {
            return @siblings[0..$i-1];
        }
    }
    ();
}

sub next_sibling {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD or return undef;
    my $refaddr = Scalar::Util::refaddr($self);
    my @siblings = _children_as_list($parent);
    for my $i (0..$#siblings-1) {
        if (Scalar::Util::refaddr($siblings[$i]) == $refaddr) {
            return $siblings[$i+1];
        }
    }
    undef;
}

sub next_siblings {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD or return ();
    my $refaddr = Scalar::Util::refaddr($self);
    my @siblings = _children_as_list($parent);
    for my $i (0..$#siblings-1) {
        if (Scalar::Util::refaddr($siblings[$i]) == $refaddr) {
            return @siblings[$i+1 .. $#siblings];
        }
    }
    ();
}

# remove self from parent
sub remove {
    my $self = shift;
    my $parent = $self->$GET_PARENT_METHOD or return ();
    my $refaddr = Scalar::Util::refaddr($self);
    my @c;
    for my $c (_children_as_list($parent)) {
        if (Scalar::Util::refaddr($c) == $refaddr) {
            next;
        }
        push @c, $c;
    }
    $parent->$SET_CHILDREN_METHOD(\@c);
}

1;
# ABSTRACT: Tree node routines

=for Pod::Coverage .+

=head1 DESCRIPTION

The routines in this module can be imported manually to your tree class/role.
The only requirement is that your tree class supports C<parent> and C<children>
methods.

The routines can also be called as a normal function call, with your tree node
object as the first argument, e.g.:

 next_siblings($node)


=head1 FUNCTIONS

=head2 ancestors

Return a list of ancestors, from the direct parent upwards to the root.

=head2 check

Usage:

 $node->check(\%opts)

Check references in a tree: that all children refers back to the parent.
Options:

=over

=item * recurse => bool

=item * check_root => bool

If set to true, will also check that parent is undef (meaning this node is a
root node).

=back

=head2 descendants

Return a list of descendents, from the direct children, to their children's
children, and so on until all the leaf nodes.

=head2 first_node

Usage:

 $node->first_node($coderef)

Much like L<List::Util>'s C<first>. Will L</walk> the descendant nodes until the
first coderef returns true, and return that.

=head2 is_first_child

=head2 is_first_child_of_type

=head2 is_last_child

=head2 is_last_child_of_type

=head2 is_nth_child

=head2 is_nth_child_of_type

=head2 is_only_child

=head2 is_only_child_of_type

=head2 next_sibling

Return the sibling node directly after this node.

=head2 next_siblings

Return all the next siblings of this node, from the one directly after to the
last.

=head2 prev_sibling

Return the sibling node directly before this node.

=head2 prev_siblings

Return all the previous siblings of this node, from the first to the one
directly before.

=head2 remove

Detach this node from its parent. Also set the parent of this node to undef.

=head2 walk

Usage:

 $node->walk($coderef);

Call C<$coderef> for all descendants (this means the self node is not included).
$coderef will be passed the node.


=head1 VARIABLES

=head2 $GET_PARENT_METHOD => str (default: parent)

The method names C<parent> can actually be customized by (locally) setting this
variable and/or C<$SET_PARENT_METHOD>.

=head2 $SET_PARENT_METHOD => str (default: parent)

The method names C<parent> can actually be customized by (locally) setting this
variable and/or C<$GET_PARENT_METHOD>.

=head2 $GET_CHILDREN_METHOD => str (default: children)

The method names C<children> can actually be customized by (locally) setting
this variable and C<$SET_CHILDREN_METHOD>.

=head2 $SET_CHILDREN_METHOD => str (default: children)

The method names C<children> can actually be customized by (locally) setting
this variable and C<$GET_CHILDREN_METHOD>.


=head1 SEE ALSO

L<Role::TinyCommons::Tree::NodeMethods> if you want to use the routines in this
module via consuming role.
