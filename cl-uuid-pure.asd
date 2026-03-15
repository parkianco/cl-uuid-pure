;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-uuid-pure.asd
;;;; RFC 4122 UUID implementation with ZERO external dependencies

(asdf:defsystem #:cl-uuid-pure
  :description "RFC 4122 UUID implementation for Common Lisp"
  :author "Park Ian Co"
  :license "Apache-2.0"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :components ((:file "package")
                             (:file "conditions" :depends-on ("package"))
                             (:file "types" :depends-on ("package"))
                             (:file "cl-uuid-pure" :depends-on ("package" "conditions" "types")))))))

(asdf:defsystem #:cl-uuid-pure/test
  :description "Tests for cl-uuid-pure"
  :depends-on (#:cl-uuid-pure)
  :serial t
  :components ((:module "test"
                :components ((:file "test-uuid-pure"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-uuid-pure.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
