# Dist::Zilla::Plugin::CSS::Compressor ![linux](https://github.com/uperl/Dist-Zilla-Plugin-CSS-Compressor/workflows/linux/badge.svg) ![macos](https://github.com/uperl/Dist-Zilla-Plugin-CSS-Compressor/workflows/macos/badge.svg) ![windows](https://github.com/uperl/Dist-Zilla-Plugin-CSS-Compressor/workflows/windows/badge.svg) ![msys2-mingw](https://github.com/uperl/Dist-Zilla-Plugin-CSS-Compressor/workflows/msys2-mingw/badge.svg)

Compress CSS files

# SYNOPSIS

```
[CSS::Compressor]
```

# DESCRIPTION

Compress CSS files in your distribution using [CSS::Compressor](https://metacpan.org/pod/CSS::Compressor).  By default for
each `foo.css` file in your distribution this plugin will create a `foo.min.css`
which has been compressed.

# ATTRIBUTES

## finder

Specifies a [FileFinder](https://metacpan.org/pod/Dist::Zilla::Role::FileFinder) for the CSS files that
you want compressed.  If this is not specified, it will compress all the CSS
files that do not have a `.min.` in their filenames.  Roughly equivalent to
this:

```
[FileFinder::ByName / CSSFiles]
file = *.css
skip = .min.
[CSS::Compressor]
finder = CSSFile
```

## output\_regex

Regular expression substitution used to generate the output filenames.  By default
this is

```
[CSS::Compressor]
output_regex = /\.css$/.min.css/
```

which generates a `foo.min.css` for each `foo.css`.

## output

Output filename.  Not used by default, but if specified, all CSS files are merged and
compressed into a single file using this as the output filename.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2024 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
