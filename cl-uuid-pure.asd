;;;; cl-uuid-pure.asd
;;;; RFC 4122 UUID implementation with ZERO external dependencies

(asdf:defsystem #:cl-uuid-pure
  :description "RFC 4122 UUID implementation for Common Lisp"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :components ((:file "uuid")))))
