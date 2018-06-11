(in-package :emotiq-quickdist)

(defparameter quickdist::*distinfo-template*
  "name: {name}
version: {version}
distinfo-subscription-url: {base-url}/{name}.txt
release-index-url: {base-url}/{name}/{version}/releases.txt
system-index-url: {base-url}/{name}/{version}/systems.txt
")

(defparameter quickdist::*distinfo-file-template*
  "{dists-dir}/{name}.txt")
(defparameter quickdist::*dist-dir-template*
  "{dists-dir}/{name}/{version}")
(defparameter quickdist::*archive-dir-template*
  "{dists-dir}/{name}/archive")
(defparameter quickdist::*archive-url-template*
  "{base-url}/{name}/archive")

(defparameter quickdist::*gnutar*
  (if (find :darwin *features*)
      (some 'probe-file
            '("/usr/local/bin/gtar"      ;; Brew (?)
              "/opt/local/bin/gnutar"))  ;; MacPorts
      "/bin/tar"))

(defun var/root ()
  #p"/var/tmp/emotiq/")

(defun var/root/dist ()
  (merge-pathnames "dist/" (var/root)))

(defun var/root/systems ()
  (merge-pathnames "systems/" (var/root)))

(defun stage (&key
                (database (asdf:system-relative-pathname :emotiq-quickdist "emotiq-systems.lisp"))
                (systems-root (var/root/systems)))
  (let ((systems (with-open-file (o database)
                   (read o))))
    (loop :for (system uri tag) :in systems
       :doing (git/sync uri :systems-root systems-root :tag tag))
    t)) ;; TODO account for errors in staging source: network, etc.; provide diagnostics

;;; Have to use `http` as the ql-client code only supports that scheme
;;;                            (base-url "http://s3.eu-central-1.amazonaws.com/mte.dev/")

(defun make-emotiq-dist (&key
                           (base-url "http://s3.us-east-1.amazonaws.com/emotiq-quickdist/")
                           (dists-dir (var/root/dist)))
  (stage)
  (quickdist:quickdist :name "emotiq"
                       :base-url base-url
                       :projects-dir (var/root/systems)
                       :dists-dir dists-dir))

;; (upload-sub*directories (var/root/dist) (aref (zs3:all-buckets) 0))
(defun upload-sub*directories (root bucket)
  (uiop/filesystem:collect-sub*directories
   root (constantly t) (constantly t)
   (lambda (d)
     (upload-directory root d bucket))))

(defun upload-directory (root directory bucket)
  (dolist (p (directory (merge-pathnames "*.*" directory)))
    (unless (not (pathname-name p))
      (let ((key (enough-namestring p (truename root)))
            (content-type (if (string-equal (pathname-type p) "txt")
                              "text/plain"
                              "binary/octet-stream")))
        (note "Uploading ~a to ~a" p key)
        (zs3:put-object p bucket key
                        :content-type content-type
                        :access-policy :public-read)))))
