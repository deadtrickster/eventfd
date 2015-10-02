(in-package :cl-user)

(defpackage :eventfd-system
  (:use :cl :asdf))

(in-package :eventfd-system)

(defsystem :eventfd
  :version "0.1"
  :description "IOLib based eventfd bindings"
  :maintainer "Ilya Khaprov <ilya.khaprov@publitechs.com>"
  :author "Ilya Khaprov <ilya.khaprov@publitechs.com>"
  :licence "MIT"
  :depends-on (:iolib
               :alexandria)
  :serial t
  :components ((:file "src/package")
               (:file "src/eventfd")))
