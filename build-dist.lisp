(defparameter *s3-url* "http://s3.us-east-1.amazonaws.com/emotiq-quickdist/")
(defparameter *s3-bucket* "emotiq-quickdist")

(ql:quickload :emotiq-quickdist)
(edist:make-emotiq-dist :base-url *s3-url*)

(in-package :zs3)
(defclass environment-credentials () ())

(defmethod access-key ((credentials environment-credentials))
  (declare (ignore credentials))
  (ccl:getenv "AWS_ACCESS_KEY_ID"))

(defmethod secret-key ((credentials environment-credentials))
  (declare (ignore credentials))
  (ccl:getenv "AWS_SECRET_ACCESS_KEY"))

(setf *credentials* (make-instance 'environment-credentials))
(in-package :cl-user)

(edist:upload-sub*directories (edist:var/root/dist) *s3-bucket*)
(quit)
