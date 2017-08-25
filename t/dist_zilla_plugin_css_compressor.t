use Test2::V0 -no_srand => 1;
use Test::DZil;

subtest 'basic' => sub {

  my $tzil = Builder->from_config(
    { dist_root => 'corpus/DZT' },
    {
      add_files => {
        'source/dist.ini' => simple_ini(
          {},
          # [GatherDir]
          'GatherDir',
          # [CSS::Compressor]
          [
            'CSS::Compressor' => {}
          ],
        )
      }
    }
  );

  $tzil->build;

  my @css_files = sort grep /\.css$/, map { $_->name } @{ $tzil->files };

  my @expected = qw( 
    public/css/all.css
    public/css/all.min.css
    public/css/comment.css
    public/css/comment.min.css
    public/css/screen.css
    public/css/screen.min.css
  );

  my $is_smaller = sub {
    my($orig_fn, $min_fn) = @_;
    #diag "read $orig_fn";
    my $orig = $tzil->slurp_file("source/$orig_fn");
    #diag "read $min_fn";
    my $min  = $tzil->slurp_file("build/$min_fn");
  
    cmp_ok length($orig), '>', length($min), 
      "$orig_fn [" . length($orig) . "] is larger than $min_fn [" . length($min) . "]";
  };

  is_filelist \@css_files, \@expected, 'minified all CSS files';
  $is_smaller->(qw( public/css/all.css     public/css/all.min.css ));
  $is_smaller->(qw( public/css/comment.css public/css/comment.min.css ));
  $is_smaller->(qw( public/css/screen.css  public/css/screen.min.css ));


};

subtest 'combine' => sub {

  my $tzil = Builder->from_config(
    { dist_root => 'corpus/DZT' },
    {
      add_files => {
        'source/dist.ini' => simple_ini(
          {},
          # [GatherDir]
          'GatherDir',
          # [CSS::Compressor]
          [
            'CSS::Compressor' => {
              output => 'public/css/awesome.min.css',
            }
          ],
        )
      }
    }
  );

  $tzil->build;

  my @css_files = sort grep /\.css$/, map { $_->name } @{ $tzil->files };

  my @expected = qw( 
    public/css/all.css
    public/css/awesome.min.css
    public/css/comment.css
    public/css/screen.css
  );

  is_filelist \@css_files, \@expected, 'minified to public/css/awesome.min.css';

  my $orig = join('', map { $tzil->slurp_file("source/public/css/$_.css") } qw( all comment screen ) );
  my $min  = $tzil->slurp_file("build/public/css/awesome.min.css");

  cmp_ok length($orig), '>', length($min), "original [" . length($orig) . "] is larger than min [" . length($min) ."]";

};

done_testing;
