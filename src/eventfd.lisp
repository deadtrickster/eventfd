(in-package #:eventfd)

(isys:defsyscall (eventfd "eventfd") :int
  "Create a file descriptor for event notification"
  (initval :unsigned-int)
  (flags :int))

(defun eventfd.new (initval &key cloexec (nonblock t) semaphore)
  (let ((flags (logior
                (if cloexec +efd-cloexec+ 0)
                (if nonblock +efd-nonblock+ 0)
                (if semaphore +efd-semaphore+ 0))))
    (eventfd initval flags)))

(defun eventfd.close (fd)
  (iolib.syscalls:close fd))

;; TODO: respect host byte order
(defun int64-to-octet(val)
  (declare (type (signed-byte 64) val)
           (optimize  (sb-c::insert-debug-catch 0)
                      (speed 3)
                      (compilation-speed 0)
                      (safety 0)))
  (let ((array (make-array 8 :element-type '(unsigned-byte 8))))
    (setf (aref array 0) (ldb (byte 8 0) val))
    (setf (aref array 1) (ldb (byte 8 8) val))
    (setf (aref array 2) (ldb (byte 8 16) val))
    (setf (aref array 3) (ldb (byte 8 24) val))
    (setf (aref array 4) (ldb (byte 8 32) val))
    (setf (aref array 5) (ldb (byte 8 40) val))
    (setf (aref array 6) (ldb (byte 8 48) val))
    (setf (aref array 7) (ldb (byte 8 56) val))
    array))

(defun to-val(vec size)
  (let ((value 0))
    (dotimes (position size)
      (let ((pos (* 8 position)))
        (setf (ldb (byte 8 pos) value) (aref vec position))))
    value))

;; TODO: respect host byte order
(defun octet-to-uint64 (vec)
  (to-val vec 8))

(alexandria:define-constant +1-octets+ (make-array 8 :element-type '(unsigned-byte 8)
                                                     :initial-contents '(1 0 0 0 0 0 0 0))
  :test 'equalp)

(defun eventfd.notify% (fd bytes)
  (assert (= 8 (length bytes)))
  (cffi:with-pointer-to-vector-data (ptr bytes)
    (iolib.syscalls:write fd ptr 8)))

(defun eventfd.notify (fd val)
  (eventfd.notify% fd (int64-to-octet val)))

(defun eventfd.notify-1 (fd)
  (eventfd.notify% fd +1-octets+))

(defun eventfd.read (fd)
  "Returns number of notifications or zero"
  (let ((buffer (make-array 8 :element-type '(unsigned-byte 8) :initial-element 0)))
    (cffi:with-pointer-to-vector-data (ptr buffer)
      (handler-case
          (progn (iolib.syscalls:read fd ptr 8)
                 (octet-to-uint64 buffer))
        ;; mostly there will be ewouldblock I suppose
        (error () 0)))))
