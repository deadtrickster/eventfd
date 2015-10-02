(in-package :cl-user)

(defpackage :eventfd
  (:use :cl)
  (:export #:eventfd.new
           #:eventfd.close
           #:eventfd.notify
           #:eventfd.notify-1
           #:eventfd.read))
