;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-uuid-pure)

(define-condition cl-uuid-pure-error (error)
  ((message :initarg :message :reader cl-uuid-pure-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-uuid-pure error: ~A" (cl-uuid-pure-error-message condition)))))
