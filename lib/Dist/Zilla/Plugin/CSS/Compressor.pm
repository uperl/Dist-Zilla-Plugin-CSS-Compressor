package Dist::Zilla::Plugin::CSS::Compressor;

use Moose;
use v5.10;
use CSS::Compressor qw( css_compress );
use Dist::Zilla::File::FromCode;

# ABSTRACT: Compress CSS files
# VERSION

with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::FileInjector';

use namespace::autoclean;

has finder => (
  is  => 'ro',
  isa => 'Str',
);

has output_regex => (
  is      => 'ro',
  isa     => 'Str',
  default => '/\.css$/.min.css/',
);

has output => (
  is  => 'ro',
  isa => 'Str',
);

sub gather_files
{
  my($self, $arg) = @_;
  
  my $list = sub {
    defined $self->finder 
    ? @{ $self->zilla->find_files($self->finder) }
    : grep { $_->name =~ /\.css$/ && $_->name !~ /\.min\./ } @{ $self->zilla->files };
  };
  
  if(defined $self->output)
  {
    my $min_file;
    $min_file = Dist::Zilla::File::FromCode->new({
      name => $self->output,
      code => sub {
        my @list = $list->();
        $self->log("compressing " . join(', ', map { $_->name } @list) . " => " . $min_file->name);
        css_compress(join("\n", map { $_->content } @list));
      },
    });
    
    $self->add_file($min_file);
  }
  else
  {
    foreach my $file ($list->()) {
      my $min_file;
      $min_file = Dist::Zilla::File::FromCode->new({
        name => do {
          my $min_filename = $file->name;
          eval q{ $min_filename =~ s} . $self->output_regex;
          $min_filename;
        },
        code => sub {
          $self->log("compressing " . $file->name . " => " . $min_file->name);
          css_compress($file->content);
        },
      });
    
      $self->add_file($min_file);
    }
  }
}

__PACKAGE__->meta->make_immutable;

1;
