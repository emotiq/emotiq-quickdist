(defpackage emotiq-quickdist
  (:nicknames edist)
  (:use :cl)
  (:export

   #:var/root 
   #:var/root/dist
   #:var/root/systems

   #:git/sync

   #:host-locally

   #:stage
   #:upload-sub*directories
   #:make-emotiq-dist))


   
