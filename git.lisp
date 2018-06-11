;;;; Code dealing with git checkouts via UIOP:RUN-PROGRAM
(in-package :emotiq-quickdist)


;;; REMOVEME
(defun note (message-or-format &rest args)
  "Emit a note of progress to the appropiate logging system."
  (let ((formats '(simple-date-time:|yyyymmddThhmmssZ|
                   simple-date-time:|yyyy-mm-dd hh:mm:ss|)))
    (format *error-output* 
            "~&~a ~a~&"
            (apply (second formats)
                   (list (simple-date-time:now)))
            (apply 'format 
                 nil
                 message-or-format
                 (if args args nil)))))


(defun git-clone-directory-name (uri)
  "Return the directory with a trailing slash that would be created for a git clone of URI."
  (let ((u (if (puri:uri-p uri)
               uri
               (puri:uri uri))))
    ;; deal with possibly trailing #\/
    (let ((path (ppcre:split "/" (puri:uri-path u)))) 
      (concatenate 'string (first (last path)) "/"))))

(defun git/clone-or-fetch (uri &key (systems-root (var/root/systems)))
  "Clone git respository at URI under SYSTEMS-ROOT.  

If the repository already exists on the local filesystem the repository
synchronized with the remote branch."
  (let ((root (if (pathnamep systems-root)
                  systems-root
                  (pathname systems-root))))
    (unless (probe-file root)
      (note "Creating root directory '~a' to contain systems." root)
      (ensure-directories-exist root))
    (let ((cloned-directory
           (merge-pathnames (git-clone-directory-name uri) root )))
      (if (probe-file cloned-directory)
          (progn 
            (note "Fetching into existing '~a'" cloned-directory)
            (uiop:run-program
             "git fetch"
             :output :string :error-output :string
             :directory cloned-directory))
          (progn
            (note "Cloning ~a into '~a'" uri cloned-directory)
            (uiop:run-program
             (format nil "git clone ~a" uri)
             :output :string :error-output :string
             :directory root))))))

(defun git/checkout (uri
                     &key
                       (systems-root (var/root/systems))
                       (tag nil tag-p))
  (let* ((root
          (if (pathnamep systems-root)
              systems-root
              (pathname systems-root)))
         (cloned-directory
          (merge-pathnames (git-clone-directory-name uri) root)))
    (if tag-p
        (progn
          (note "Updating '~a' to tag '~a'" cloned-directory tag)
          (uiop:run-program 
           (format nil "git checkout ~a" tag)
           :output :string :error-output :string
           :directory cloned-directory))
        (progn
          (note "Updating '~a' to 'master'" cloned-directory)
          (uiop:run-program 
           (format nil "git checkout master")
           :output :string :error-output :string
           :directory cloned-directory)))))

(defun git/sync (uri
                 &key
                   (systems-root (var/root/systems))
                   (tag nil tag-p))
  (values
   (git/clone-or-fetch uri)
   (if tag-p 
       (git/checkout uri :systems-root systems-root :tag tag)
       (git/checkout uri :systems-root systems-root))))

