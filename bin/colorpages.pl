#!/usr/bin/perl
use CAM::PDF;

my $infile = shift;
my $pdf = CAM::PDF->new($infile);
PAGE:
for my $p (1 .. $pdf->numPages) {
   my $tree = $pdf->getPageContentTree($p);
   if (!$tree) {
      print "Failed to parse page $p\n";
      next PAGE;
   }
   my $colors = $tree->traverse('My::Renderer::FindColors')->{colors};
   my $uncertain = 0;
   for my $color (@{$colors}) {
      my ($name, @rest) = @{$color};
      if ($name eq 'g') {
      } elsif ($name eq 'rgb') {
         my ($r, $g, $b) = @rest;
         if ($r != $g || $r != $b) {
            print "Page $p is color\n";
            next PAGE;
         }
      } elsif ($name eq 'cmyk') {
         my ($c, $m, $y, $k) = @rest;
         if ($c != 0 || $m != 0 || $y != 0) {
            print "Page $p is color\n";
            next PAGE;
         }
      } else {
         $uncertain = $name;
      }
   }
   if ($uncertain) {
      print "Page $p has user-defined color ($uncertain), needs more investigation\n";
   } else {
      print "Page $p is grayscale\n";
   }
}

package My::Renderer::FindColors;

sub new {
   my $pkg = shift;
   return bless { colors => [] }, $pkg;
}
sub clone {
   my $self = shift;
   my $pkg = ref $self;
   return bless { colors => $self->{colors}, cs => $self->{cs}, CS => $self->{CS} }, $pkg;
}
sub rg {
   my ($self, $r, $g, $b) = @_;
   push @{$self->{colors}}, ['rgb', $r, $g, $b];
}
sub g {
   my ($self, $gray) = @_;
   push @{$self->{colors}}, ['rgb', $gray, $gray, $gray];
}
sub k {
   my ($self, $c, $m, $y, $k) = @_;
   push @{$self->{colors}}, ['cmyk', $c, $m, $y, $k];
}
sub cs {
   my ($self, $name) = @_;
   $self->{cs} = $name;
}
sub cs {
   my ($self, $name) = @_;
   $self->{CS} = $name;
}
sub _sc {
   my ($self, $cs, @rest) = @_;
   return if !$cs; # syntax error                                                                                             
   if ($cs eq 'DeviceRGB') { $self->rg(@rest); }
   elsif ($cs eq 'DeviceGray') { $self->g(@rest); }
   elsif ($cs eq 'DeviceCMYK') { $self->k(@rest); }
   else { push @{$self->{colors}}, [$cs, @rest]; }
}
sub sc {
   my ($self, @rest) = @_;
   $self->_sc($self->{cs}, @rest);
}
sub SC {
   my ($self, @rest) = @_;
   $self->_sc($self->{CS}, @rest);
}
sub scn { sc(@_); }
sub SCN { SC(@_); }
sub RG { rg(@_); }
sub G { g(@_); }
sub K { k(@_); }
