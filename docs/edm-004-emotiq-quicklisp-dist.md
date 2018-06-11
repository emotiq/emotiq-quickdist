# Emotiq Development Memo 004 --  The Emotiq Quicklisp distribution

Producing reliable software depends on have a reliable and exact
versioning of dependencies.  

We use ASDF3 to package our software into ASDF systems, declaring
dependencies between these systems.  Although there is support within
ASDF for requiring a specific version or versions of a dependent
system, we currently do not use this mechanism, depending instead upon
Quicklisp to install the required version to the file-system.

In common usage, the term Quicklisp is overloaded with two meanings,
one being the software itself, but it also refers to a specific,
global version of the dependencies managed by Quicklisp.  This second
meaning is more properly known as the `quicklisp` dist.  In this
document we use `Quicklisp` to refer to the software, and `quicklisp`
to refer to the Quicklisp provided distribution.

For dependencies not in the `quicklisp` dist or which need a version
different than provided in Quicklisp, we use an `emotiq` Quicklisp
distribution.

## Current versions

Development currently relies on two Quicklisp distributions.

### `quicklisp`

    http://beta.quicklisp.org/dist/quicklisp/2018-01-31/distinfo.txt

### `emotiq`

    http://s3.us-east-1.amazonaws.com/emotiq-quickdist/emotiq.txt

## Developer best practices

The current practice for a developer on installing a new development instance of
development follow the following steps.  Afterwards, the
`ql:quickload` form will install the correct dependency.

### 1. Install Quicklisp

### 2. Pin the `quicklisp` distribution:
```lisp
(ql-dist:install-dist "http://beta.quicklisp.org/dist/quicklisp/2018-01-31/distinfo.txt" :replace t)
```

### 3. Install the `emotiq` distribution:
```lisp
    (ql-dist:install-dist "http://s3.us-east-1.amazonaws.com/emotiq-quickdist/emotiq.txt")
```

### 4. Make sure `emotiq` distribution takes precedence:
```lisp
(setf (ql-dist:preference (ql-dist:dist "emotiq"))
      (1+ (ql-dist:preference (ql-dist:dist "quicklisp"))))
```

# Limitations

## Previous versions of the  `emotiq` distribution are not available

The `quickdist` tool does not produce enough meta-data information to
rollback the `emotiq` to a specific version, so we currently only have
a "latest" implementation.

Fixing this will require a better understanding of the machinery
involved in getting this form to return something meaningful.

    (ql-dist:available-versions (ql-dist:dist "emotiq"))

## Producing `emotiq` dist requires ccl

`lwpro` cannot currently use the `quickdist` tools to create a new
`emotiq` dist,  bombing out in an error about not being able to use
`system:run-program` on synonym streams.

`quickdist` is not smart enough to decipher reader conditionals
correctly, so using `sbcl` to produce the `emotiq` quickdist results
in `ironclad` referring to `sb-posix` and other `sbcl` optimized
internals.

For the time being, we use `ccl` to produce the `emotiq` dist.
Code for producing `emotiq-quickdist` is located here https://github.com/emotiq/research/tree/master/src/quickdist

## The "last" dist installed wins

For systems that occur in more than one distribution, Quicklisp has a
customizable preference mechanism for picking which which one
`ql:quickload` wins.  By default, the temporally latest installed
distribution "wins".  We currently rely on this mechanism, so it is
important to "pin" the `quicklisp` installation to a specific version
before installing the `emotiq` distribution.

# References

See <http://blog.quicklisp.org/2011/08/going-back-in-dist-time.html>
for more information.

# Implementation

Uploading to S3: <https://github.com/emotiq/emotiq-quickdist>

# Colophon

    Mark Evenson <mte@emotiq.ch>
    Created: 09-MAR-2018
    Revised: <2018-06-11T14:45:30Z>
