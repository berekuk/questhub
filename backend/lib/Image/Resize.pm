package Image::Resize;

# $Id: Resize.pm,v 1.5 2005/11/04 23:44:59 sherzodr Exp $

use strict;
use Carp ('croak');
use GD;

$Image::Resize::VERSION = '0.5';

# Thanks to Paul Allen <paul.l.allen AT comcast.net> for this tip
GD::Image->trueColor( 1 );

sub new {
    my ($class, $image) = @_;
    unless ( $class && defined($image) ) { croak "Image::Resize->new(): usage error"; }
    my $gd;

    # Thanks to Nicholas Venturella <nick2588 AT gmail.com> for this tip
    if (ref($image) eq "GD::Image") {
        $gd = $image;

    } else {
        unless ( -e $image ) { croak "Image::Resize->new(): file '$image' does not exist"; }
        $gd = GD::Image->new($image) or die $@;
    }

    return bless {
        gd => $gd
    }, $class;
}

sub width   { return ($_[0]->gd->getBounds)[0]; }
sub height  { return ($_[0]->gd->getBounds)[1]; }
sub gd      { return $_[0]->{gd}; }

sub resize {
    my $self = shift;
    my ($width, $height, $constraint) = @_;
    unless ( defined $constraint ) { $constraint = 1; }
    unless ( $width && $height ) { croak "Image::Resize->resize(): usage error"; }

    if ( $constraint ) {
        my $k_h = $height / $self->height;
        my $k_w = $width / $self->width;
        my $k = ($k_h < $k_w ? $k_h : $k_w);
        $height = int($self->height * $k);
        $width  = int($self->width * $k);
    }

    my $image = GD::Image->new($width, $height);

    # This is a local patch for preserving transparency, this code is not on CPAN.
    # See https://rt.cpan.org/Ticket/Display.html?id=88350 for details.
    # -- mmcleric
    $image->saveAlpha(1);
    $image->alphaBlending(0);

    $image->copyResampled($self->gd,
        0, 0,               # (destX, destY)
        0, 0,               # (srcX,  srxY )
        $width, $height,    # (destX, destY)
        $self->width, $self->height
    );
    return $image;
}


1;
__END__

=head1 NAME

Image::Resize - Simple image resizer using GD

=head1 SYNOPSIS

    use Image::Resize;
    $image = Image::Resize->new('large.jpg');
    $gd = $image->resize(250, 250);

=head1 ABSTRACT

Resizes images using GD graphics library

=head1 DESCRIPTION

Despite its heavy weight, I've always used L<Image::Magick|Image::Magick> for creating image thumbnails. I know it can be done using lighter-weight L<GD|GD>, I just never liked its syntax. Really, who wants to remember the lengthy arguments list of copyResized() or copyResampled() functions:

    $image->copyResampled($sourceImage,$dstX,$dstY,
                        $srcX,$srcY,$destW,$destH,$srcW,$srcH);

when L<Image::Magick|Image::Magick> lets me say:

    $image->Scale(-geometry=>'250x250');

Image::Resize is one of my attempts to make image resizing easier, more intuitive using L<GD|GD>.

=head1 METHODS

=over 4

=item new('path/to/image.jpeg')

=item new($gd)

Constructor method. Creates and returns Image::Resize object. Can accept either L<GD::Image|GD> object, or file system path leading to the image. All the file formats that are supported by L<GD|GD> are accepted.

=item resize($width, $height);

=item resize($width, $height, $constraint);

Returns a L<GD::Image|GD> object for the new, resized image. Original image is not modified. This lets you create multiple thumbnails of an image using the same Image::Resize object.

First two arguments are required, which define new image dimensions. By default C<resize()> retains image proportions while resizing. This is always what you expect to happen. In case you don't care about retaining image proportions, pass C<0> as the third argument to C<resize()>.

Following example creates a 120x120 thumbnail of a "large" image, and stores it in disk:

    $image = Image::Resize->new("large.jpg");
    $gd = $image->resize(120, 120);

    open(FH, '>thumbnail.jpg');
    print FH $gd->jpeg();
    close(FH);

=item gd()

Returns internal L<GD::Image|GD> object for the original image (the one passed to Image::Resize->new).

=item width()

=item height()

Returns original image's width and height respectively. If you want to get resized image's dimensions, call width() and height() methods on the returned L<GD::Image|GD> object, like so:

    $gd = $image->resize(120, 120);
    printf("Width: %s, Height: %s\n", $gd->width, $height);

=back

=head1 CREDITS

Thanks to Paul Allen <paul.l.allen AT comcast.net> for the C<trueColor(1)> tip. Now Image::Resize should work fine for photographs too.

Thanks to Nicholas Venturella <nick2588 AT gmail.com> for allowing Image::Resize to work with already-opened L<GD::Image|GD> objects and for checking the scaling routine. It's now comparable to L<Image::Magick|Image::Magick>'s C<Scale()>: the resulting image dimensions won't exceed the given width and height.

=head1 SEE ALSO

L<GD>, L<Image::Magick>

=head1 AUTHOR

Sherzod B. Ruzmetov, E<lt>sherzodr@cpan.orgE<gt>
http://author.handalak.com/

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Sherzod B. Ruzmetov

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
