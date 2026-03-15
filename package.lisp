;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; package.lisp
;;;; cl-uuid-pure package definition

(defpackage #:cl-uuid-pure
  (:use #:cl)
  (:nicknames #:uuid-pure)
  (:export
   ;; UUID type
   #:uuid
   #:uuid-p
   ;; Generation
   #:make-v4-uuid
   #:make-v1-uuid
   #:null-uuid
   ;; Conversion
   #:uuid-to-string
   #:string-to-uuid
   #:uuid-to-bytes
   #:bytes-to-uuid
   ;; Comparison
   #:uuid=
   #:uuid<
   ;; Accessors
   #:uuid-version
   #:uuid-variant))
