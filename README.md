# Quicklisp Emotiq distribution

This constitutes the instructions for creating a new version of the
`emotiq` distribution.

## [Rationale/usage](docs/edm-004-emotiq-quicklisp-dist.md)


## TL;DR
1. Install prerequisites
  1. [Clozure Common List](https://ccl.clozure.com) (`ccl`)
  1. [Quickdist package](https://github.com/emotiq/quickdist)
1. Update URL and Name of AWS S3 bucket used to store Emotiq quickdist in `build-dist.lisp`


## Install Dependencies

N.b. We currently require the `ccl` implementation to run this
procedure `docs/edm-004-emotiq-quicklisp-dist.md`.)

The constructions of the Emotiq Quicklisp distribution requires the
ASDF definition for <https://github.com/emotiq/quickdist> to be found
which can be satisfied by cloning that system in
<file:~/common-lisp/>:

    mkdir ~/common-lisp && cd ~/common-lisp && git clone https://github.com/emotiq/quickdist

Then satisfy dependencies from the `quicklisp` Quicklisp graph via:

    (ql:quickload :emotiq-quickdist)

## Creating the Emotiq dist

First, assemble the files on the local filesystem:

    (edist:make-emotiq-dist)

This will invoke git to checkout the sources listed in
`emotiq-systems.lisp`, and run the quickdist mechanism to create the
Emotiq dist under `(var/root)`.

# Uploading dist to S3

## Configuring S3 credentials

In order to upload to Amazon S3, one has to have the client set with
the correct credentials.  

Credentials are available from the AWS Console web application under
"YOUR USERNAME" >> "Your Security Credentials".  They consist of a
`AWSAccessKeyID` and a `AWSSecretKey`.

There are two ways to provid AWS credentials to upload objects to S3 bucket

1. Place these values (without
the keys) in a file with a line separator after each value.  Then
issue the follwing commands at the REPL:

    (ql:quickload :emotiq-quickdist)
    (setf zs3:*credentials*
      (zs3:file-credentials #p"/keybase/private/easye/etc/emotiq/zs3-credentials"))

## Uploading to S3

After configuring the credentials, the release may be uploaded via:

    (edist:upload-sub*directories (edist:var/root/dist) (aref (zs3:all-buckets) 0))

N.b. this pushes the dist into the first S3 bucket of which we

currently have one.  TODO: Fix the code in `zs3` which fails to parse
the current version of the S3 XML representation of a buckets contents.  

# Testing the Emotiq distribution mechanism locally

For testing purposes, one can self-host a locally created `emotiq`
distribution.

The code in `emotiq-quickdist/localhost.lisp` will use Hunchentoot to
serve the distributions via HTTP so that they may be installed via
`ql-dist:install-dist`.  Hosting locally allows one to test aspects of
the Quicklisp mechanism without needing to publish to S3.

One must build a version of the distribution with the base URI
pointing to localhost rather than the default locations in S3, then
install and host via:

    (ql:quickload :emotiq-quickdist/localhost)
    (edist:make-emotiq-dist :base-url edist::*emotiq-localhost-uri*)
    (emotiq-quickdist:host-locally)

Then the Emotiq dist may be installed via

    (ql-dist:install-dist "http://localhost:4242/emotiq.txt")

The Emotiq dist may be uninstalled via

    (ql-dist:uninstall (ql-dist:find-dist "emotiq"))

# Priorities of distributions

When multiple distributions provide the same system, the latest
installed distribution is prefered by default.  If this is not what
you want, you can inspect priorities with `(ql-dist:preference
(ql-dist:find-dist "emotiq")))` and set them with `setf`.  For a
finer-grained control projects (`ql-dist:find-release-in-dist`) and
systems (`ql-dist:find-system-in-dist`) have preferences too.

# Colophon

    Mark Evenson <mte@emotiq.ch>
    Created: 01-MAR-2018
    Revised: <2018-03-26 Mon 09:13Z>
