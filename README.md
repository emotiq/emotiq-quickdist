# Quicklisp Emotiq distribution

This constitutes the instructions for creating a new version of the
`emotiq` distribution.

## [Rationale/usage](docs/edm-004-emotiq-quicklisp-dist.md)

## TL;DR
1. Install prerequisites
  1. [Clozure Common List](https://ccl.clozure.com) (`ccl`)
  1. Clone [Quickdist package](https://github.com/emotiq/quickdist) to `~/common-lisp` folder
1. Set path to this repository in `~/.config/common-lisp/source-registry.conf.d/emotiq-quickdist.conf`:
```lisp
(:tree "<path to this repository>")
```
1. Setup AWS environment variables with credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.)

1. Update URL and Name of AWS S3 bucket used to store Emotiq quickdist in `build-dist.lisp`

1. Update `emotiq-systems.lisp` with list of systems to be included in Emotiq distribution.

1. Run command:
```bash
ccl -l build-dist.lisp
```

## Gory details

## Install Dependencies

N.b. We currently require the `ccl` implementation to run this
procedure `docs/edm-004-emotiq-quicklisp-dist.md`.)

The constructions of the Emotiq Quicklisp distribution requires the
ASDF definition for [Quickdist](https://github.com/emotiq/quickdist) to be found,
which can be satisfied by cloning that system in
`~/common-lisp/`:
```bash
mkdir ~/common-lisp && cd ~/common-lisp && git clone https://github.com/emotiq/quickdist
```

Then satisfy dependencies from the `quicklisp` Quicklisp graph via:
```lisp
(ql:quickload :emotiq-quickdist)
```

## Creating the Emotiq dist

First, assemble the files on the local filesystem:
```lisp
(edist:make-emotiq-dist)
```

This will invoke git to checkout the sources listed in
`emotiq-systems.lisp`, and run the quickdist mechanism to create the
Emotiq dist under `(var/root)`.

### Uploading dist to S3

#### Configuring S3 credentials

In order to upload to Amazon S3, one has to have the client set with
the correct credentials.  

Credentials are available from the AWS Console web application under
"YOUR USERNAME" >> "Your Security Credentials".  They consist of a
`AWSAccessKeyID` and a `AWSSecretKey`.

There are two ways to provid AWS credentials to upload objects to S3 bucket

1. Place these values (without the keys) in a file with a line separator after each value.  Then issue the follwing commands at the REPL:
```
    (ql:quickload :emotiq-quickdist)
    (setf zs3:*credentials*
      (zs3:file-credentials #p"/keybase/private/easye/etc/emotiq/zs3-credentials"))
```
1. Setup environment variables:
* AWS_ACCESS_KEY_ID
* AWS_DEFAULT_REGION
* AWS_SECRET_ACCESS_KEY

#### Uploading to S3

After configuring the credentials, the release may be uploaded via:
```lisp
(edist:upload-sub*directories (edist:var/root/dist) "<bucket-name>")
```

This pushes the dist into the S3 bucket `<bucket-name>`

## Testing the Emotiq distribution mechanism locally

For testing purposes, one can self-host a locally created `emotiq`
distribution.

The code in `emotiq-quickdist/localhost.lisp` will use Hunchentoot to
serve the distributions via HTTP so that they may be installed via
`ql-dist:install-dist`.  Hosting locally allows one to test aspects of
the Quicklisp mechanism without needing to publish to S3.

One must build a version of the distribution with the base URI
pointing to localhost rather than the default locations in S3, then
install and host via:
```lisp
(ql:quickload :emotiq-quickdist/localhost)
(edist:make-emotiq-dist :base-url edist::*emotiq-localhost-uri*)
(emotiq-quickdist:host-locally)
```

Then the Emotiq dist may be installed via
```lisp
(ql-dist:install-dist "http://localhost:4242/emotiq.txt")
```

The Emotiq dist may be uninstalled via
```lisp
(ql-dist:uninstall (ql-dist:find-dist "emotiq"))
```

## Priorities of distributions

When multiple distributions provide the same system, the latest
installed distribution is prefered by default.  If this is not what
you want, you can inspect priorities with `(ql-dist:preference
(ql-dist:find-dist "emotiq")))` and set them with `setf`.  For a
finer-grained control projects (`ql-dist:find-release-in-dist`) and
systems (`ql-dist:find-system-in-dist`) have preferences too.

# Colophon

    Mark Evenson <mte@emotiq.ch>
    Created: 01-MAR-2018
    Revised: <2018-06-11T15:19:37Z>
