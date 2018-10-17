Icon Build
==========

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/shoogle/icon-build.svg?branch=master)](https://travis-ci.org/shoogle/icon-build)

Demonstrates converting SVGs into application icons as part of an automated
build process.

The process starts with the master icon file in SVG format, and then:

1. Linked resources are embedded.

2. Editable text is converted to paths.

3. Icons are generated in various formats, including SVG, PNG, ICO.

4. These are packed into a ZIP archive and uploaded to [transfer.sh](https://transfer.sh).

The entire process takes place on Travis CI.
