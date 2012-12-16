package Dist::Zilla::Plugin::CSS::Compressor;

use Moose;
use v5.10;
use CSS::Compressor qw( css_compress );
use Dist::Zilla::File::FromCode;

# ABSTRACT: Compress CSS files
# VERSION

=head1 SYNOPSIS

 [CSS::Compressor]

=head1 DESCRIPTION

Compress CSS files in your distribution using L<CSS::Compressor>.  By default for
each C<foo.css> file in your distribution this plugin will create a C<foo.min.css>
which has been compressed.

=cut

with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::FileInjector';

use namespace::autoclean;

=head1 ATTRIBUTES

=head2 finder

Specifies a L<FileFinder|Dist::Zilla::Role::FileFinder> for the CSS files that
you want compressed.  If this is not specified, it will compress all the CSS
files that do not have a C<.min.> in their filenames.  Roughly equivalent to
this:

 [FileFinder::ByName / CSSFiles]
 file = *.css
 skip = .min.
 [CSS::Compressor]
 finder = CSSFile

=cut

has finder => (
  is  => 'ro',
  isa => 'Str',
);

=head2 output_regex

Regular expression substitution used to generate the output filenames.  By default
this is

 [CSS::Compressor]
 output_regex = /\.css$/.min.css/

which generates a C<foo.min.css> for each C<foo.css>.

=cut

has output_regex => (
  is      => 'ro',
  isa     => 'Str',
  default => '/\.css$/.min.css/',
);

=head2 output

Output filename.  Not used by default, but if specified, all CSS files are merged and
compressed into a single file using this as the output filename.

=cut

has output => (
  is  => 'ro',
  isa => 'Str',
);

=head1 METHODS

=head2 $plugin-E<gt>gather_files( $arg )

This method adds the compressed CSS files to your distribution.

=cut

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
