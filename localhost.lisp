(in-package :emotiq-quickdist)

(defparameter *emotiq-localhost-uri*
  "http://localhost:4242/")

(defun host-locally ()
  (push (hunchentoot:create-folder-dispatcher-and-handler
         "/"
         (var/root/dist))
         hunchentoot:*dispatch-table*)
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242))
  (note "Hosting dist on localhost via Hunchentoot.~&~
Install via (ql-dist:install-dist \"~aemotiq.txt\")" *emotiq-localhost-uri*))

                     
        
