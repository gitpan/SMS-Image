package SMS::Image;
#### Package information ####
# Description and copyright:
#   See POD (i.e. perldoc SMS::Image).
####

use strict;
use Carp;
use Exporter();
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(gif_to_ota ota_to_gif png_to_ota ota_to_png raw_to_ota ota_to_raw);
our $VERSION = '0.02';
1;

####
# Function:	gif_to_ota
# Description:	Converts monochrome GIF image into an OTA bitmap.
# Parameters:	1. Reference to GIF image buffer.
#		2. Reference to receive buffer for OTA bitmap.
# Returns:	void
####
sub gif_to_ota {
 my $gif = shift;
 my $ota = shift;
 require Image::Magick;
 my $image = Image::Magick->new('magick' => 'gif');
 $image->BlobToImage($$gif);
 $image->Set('dither' => 'True');
 $image->Set('monochrome' => 'True');
 my $h = $image->Get('height');
 my $w = $image->Get('width');
 my ($raw) = $image->ImageToBlob('magick' => 'mono');
 &raw_to_ota(\$raw,$w,$h,1,$ota);
}

####
# Function:	ota_to_gif
# Description:	Converts a monochrome OTA bitmap into a monochrome GIF image.
# Parameters:	1. Reference to OTA image buffer.
#		2. Reference to receive buffer for GIF bitmap.
# Returns:	void
####
sub ota_to_gif {
 my $ota = shift;
 my $gif = shift;
 my $raw;
 my ($w,$h,$d) = &ota_to_raw($ota,\$raw);
 require Image::Magick;
 my $image = Image::Magick->new('magick' => 'mono', 'size' => $w . 'x' . $h);
 $image->BlobToImage($raw);
 ($$gif) = $image->ImageToBlob('magick' => 'gif');
}

####
# Function:	png_to_ota
# Description:	Converts monochrome PNG image into an OTA bitmap.
# Parameters:	1. Reference to PNG image buffer.
#		2. Reference to receive buffer for OTA bitmap.
# Returns:	void
####
sub png_to_ota {
 my $png = shift;
 my $ota = shift;
 require Image::Magick;
 my $image = Image::Magick->new('magick' => 'png');
 $image->BlobToImage($$png);
 $image->Set('dither' => 'True');
 $image->Set('monochrome' => 'True');
 my $h = $image->Get('height');
 my $w = $image->Get('width');
 my ($raw) = $image->ImageToBlob('magick' => 'mono');
 &raw_to_ota(\$raw,$w,$h,1,$ota);
}

####
# Function:	ota_to_png
# Description:	Converts a monochrome OTA bitmap into a monochrome PNG image.
# Parameters:	1. Reference to OTA image buffer.
#		2. Reference to receive buffer for PNG bitmap.
# Returns:	void
####
sub ota_to_png {
 my $ota = shift;
 my $png = shift;
 my $raw;
 my ($w,$h,$d) = &ota_to_raw($ota,\$raw);
 require Image::Magick;
 my $image = Image::Magick->new('magick' => 'mono', 'size' => $w . 'x' . $h);
 $image->BlobToImage($raw);
 ($$png) = $image->ImageToBlob('magick' => 'png');
}

####
# Function:	raw_to_ota
# Description:	Converts raw binary image into an OTA bitmap.
# Parameters:	1. Reference to raw binary image buffer.
#		2. Image width
#		3. Image height
#		4. Color depth
#		5. Reference to receive buffer for OTA bitmap.
# Returns:	void
####
sub raw_to_ota {
 my $raw = shift;
 my $w = shift;
 my $h = shift;
 my $d = shift;
 my $ota = shift;
 unless($d == 1) {
  croak("Only color depths of 1 are currently supported!\n");
 }
 my $bitlen = $w * $h;
 my $bytelen = int($bitlen / 8);
 if ($bitlen % 8) {
  $bytelen++;
 }
 unless(length($$raw) == $bytelen) {
  croak('Raw buffer contains ' . length($$raw) . " bytes instead of $bytelen bytes!\n");
 }
 my @data = unpack('b*',$$raw);
 $$ota = pack('C4', 0,$w,$h,$d) . pack('B*',unpack('b*',$$raw));
}

####
# Function:	ota_to_raw
# Description:	Converts OTA bitmap into raw binary image.
# Parameters:	1. Reference to buffer containing OTA bitmap.
#		2. Reference to buffer to receive raw binary image.
# Returns:	Array of image width, image height, color depth.
####
sub ota_to_raw {
 my $ota = shift;
 my $raw = shift;
 my ($i,$w,$h,$d) = unpack('C4',$$ota);
 unless($i == 0) {
  croak("Unsupported OTA version!\n");
 }
 unless($d == 1) {
  croak("Invalid color depth: $1. Only color depths of 1 are supported!\n");
 }
 my $bitlen = $w * $h;
 my $bytelen = int($bitlen / 8);
 if ($bitlen % 8) {
  $bytelen++;
 }
 my $data = substr($$ota,4);
 unless(length($data) == $bytelen) {
  croak('OTA bitmap data contains ' . length($data) . " bytes instead of $bytelen bytes!\n");
 }
 $$raw = pack('b*',unpack('B*',$data));
 return ($w,$h,$d);
}


__END__

=head1 NAME

SMS::Image - common image conversion functions for use in SMS applications.


=head1 SYNOPSIS

 use SMS::Image qw(png_to_ota);

 # Read PNG data from file, convert into OTA bitmap, and write back to file.
 my $png;
 my $buf; # temporary buffer
 open(F,'<test.png') || die;
 binmode(F);
 while(read F, $buf, 1024) {
  $png .= $buf;
 }
 close(F);
 my $ota;
 &png_to_ota(\$png,\$ota);
 open(F,'>test.ota') || die;
 binmode(F);
 print F $ota;
 close(F);


=head1 DESCRIPTION

SMS::Image contains common image conversion functions for use in SMS
applications.

=head1 FUNCTIONS

All functions have no return value.

=over 4

=item gif_to_ota(\$gif,\$ota)

Converts monochrome GIF image into an OTA bitmap. The module Image::Magick
must be installed in order to use this function.

Parameters:

 1. Reference to GIF image buffer.
 2. Reference to receive buffer for OTA bitmap.


=item ota_to_gif(\$ota,\$gif)

Converts a monochrome OTA bitmap into a monochrome GIF image.

Parameters:

 1. Reference to OTA image buffer.
 2. Reference to receive buffer for GIF bitmap.

=item png_to_ota(\$png,\$ota)

Converts monochrome PNG image into an OTA bitmap. The module Image::Magick
must be installed in order to use this function.

Parameters:

 1. Reference to PNG image buffer.
 2. Reference to receive buffer for OTA bitmap.


=item ota_to_png(\$ota,\$png)

Converts a monochrome OTA bitmap into a monochrome PNG image.

Parameters:

 1. Reference to OTA image buffer.
 2. Reference to receive buffer for PNG bitmap.


=item raw_to_ota(\$raw,$width,$height,$bits_per_pixel,\$ota)

Converts a raw binary image into an OTA bitmap. The raw binary image is a
buffer of pixels from left to right and top to bottom where the top left
pixel is the lowest order bit and the bottom right pixel is the highest order
bit.

Parameters:

 1. Reference to raw binary image buffer.
 2. Image width.
 3. Image height.
 4. Color depth (currently only a value of 1 is supported).
 5. Reference to receive buffer for OTA bitmap.

Returns boolean result.


=item ota_to_raw(\$ota,\$raw)

Converts an OTA bitmap into a raw binary image. The raw binary image is a
buffer of pixels from left to right and top to bottom where the top left
pixel is the lowest order bit and the bottom right pixel is the highest order
bit. Only single image monoschrome OTA bitmaps are currently supported.

Parameters:

 1. Reference to OTA bitmap buffer.
 2. Reference to receive buffer for raw binary image.

Returns array of image width, image height, color depth.

=back


=head1 HISTORY

=over 4

=item Version 0.01  2001-11-05

Initial version

=item Version 0.02  2001-11-07

Added support for GIF to OTA bitmap conversion and vice versa.

=back


=head1 AUTHOR

Craig Manley	c.manley@skybound.nl


=head1 COPYRIGHT

Copyright (C) 2001 Craig Manley <c.manley@skybound.nl>.  All rights reserved.
This program is free software; you can redistribute it and/or modify
it under under the same terms as Perl itself. There is NO warranty;
not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut