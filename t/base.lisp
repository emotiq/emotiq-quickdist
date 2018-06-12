(in-package :cl-user)

(prove:plan 1)
(prove:ok
 (emotiq-quickdist:git/sync "https://github.com/svspire/time-parser/")
 "Cloning TIME-PARSER…")

(prove:plan 1)
(prove:ok
 (emotiq-quickdist:git/sync "https://github.com/sharplispers/ironclad/" :tag "v0.38")
 "Cloning Ironclad 'v0.38'…")

(prove:plan 1)
(prove:ok
 (emotiq-quickdist:stage)
 "Local staging.")

(prove:finalize)
