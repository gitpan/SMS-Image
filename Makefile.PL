use ExtUtils::MakeMaker;
require 5.6.0;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	=> 'SMS::Image',
    'VERSION_FROM' => 'lib/SMS/Image.pm',
    'AUTHOR' => 'Craig Manley (c.manley@skybound.nl)',
    'ABSTRACT' => 'Common image conversion functions for use in SMS applications.',
    'PREREQ_PM'	=> {'Image::Magick' => '5.40'},
    'dist' => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'}
);