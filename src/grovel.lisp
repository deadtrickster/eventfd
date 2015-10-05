(in-package :eventfd)

(include "sys/epoll.h" "sys/eventfd.h" "sys/syscall.h")

(constant (+efd-cloexec+ "EFD_CLOEXEC"))
(constant (+efd-nonblock+ "EFD_NONBLOCK"))
(constant (+efd-semaphore+ "EFD_SEMAPHORE"))
