;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-uuid-pure)

;;; Core types for cl-uuid-pure
(deftype cl-uuid-pure-id () '(unsigned-byte 64))
(deftype cl-uuid-pure-status () '(member :ready :active :error :shutdown))
