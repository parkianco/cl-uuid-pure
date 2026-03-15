;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; src/uuid.lisp
;;;; RFC 4122 UUID implementation

(in-package #:cl-uuid-pure)

;;; UUID structure - 128 bits stored as two 64-bit integers

(defstruct (uuid (:constructor %make-uuid (high low))
                 (:copier nil))
  "A 128-bit UUID as per RFC 4122."
  (high 0 :type (unsigned-byte 64) :read-only t)
  (low 0 :type (unsigned-byte 64) :read-only t))

;;; Node ID for v1 UUIDs (random, cached per session)

(defvar *node-id* nil)
(defvar *clock-seq* nil)

(defun get-node-id ()
  "Get or generate a random node ID."
  (or *node-id*
      (setf *node-id* (logior #x010000000000  ; Set multicast bit
                              (random (ash 1 48))))))

(defun get-clock-seq ()
  "Get or generate a clock sequence."
  (or *clock-seq*
      (setf *clock-seq* (random (ash 1 14)))))

;;; UUID generation

(defun make-v4-uuid ()
  "Generate a random UUID (version 4)."
  (let ((high (random (ash 1 64)))
        (low (random (ash 1 64))))
    ;; Set version to 4 (bits 76-79)
    (setf high (logior (logand high #xffffffffffff0fff)
                       #x0000000000004000))
    ;; Set variant to RFC 4122 (bits 62-63 = 10)
    (setf low (logior (logand low #x3fffffffffffffff)
                      #x8000000000000000))
    (%make-uuid high low)))

(defun make-v1-uuid ()
  "Generate a time-based UUID (version 1).
Note: Uses random node ID (with multicast bit set) for privacy."
  (let* ((unix-time (get-universal-time))
         ;; UUID epoch is Oct 15, 1582. Universal time epoch is Jan 1, 1900
         ;; Difference is 12219292800 seconds
         (uuid-time (+ (* (+ unix-time 12219292800 -2208988800) 10000000)
                       (random 10000000)))  ; Add sub-100ns precision
         (time-low (ldb (byte 32 0) uuid-time))
         (time-mid (ldb (byte 16 32) uuid-time))
         (time-hi (ldb (byte 12 48) uuid-time))
         (clock-seq (get-clock-seq))
         (node (get-node-id)))
    ;; Build high 64 bits: time-low (32) | time-mid (16) | version (4) | time-hi (12)
    (let ((high (logior (ash time-low 32)
                        (ash time-mid 16)
                        (ash 1 12)  ; version 1
                        time-hi))
          ;; Build low 64 bits: variant (2) | clock-seq (14) | node (48)
          (low (logior (ash #b10 62)  ; variant
                       (ash clock-seq 48)
                       node)))
      (%make-uuid high low))))

(defun null-uuid ()
  "Return the nil UUID (all zeros)."
  (%make-uuid 0 0))

;;; Conversion

(defun uuid-to-string (uuid)
  "Convert UUID to canonical string form (8-4-4-4-12)."
  (let ((high (uuid-high uuid))
        (low (uuid-low uuid)))
    (format nil "~8,'0X-~4,'0X-~4,'0X-~4,'0X-~12,'0X"
            (ldb (byte 32 32) high)
            (ldb (byte 16 16) high)
            (ldb (byte 16 0) high)
            (ldb (byte 16 48) low)
            (ldb (byte 48 0) low))))

(defun string-to-uuid (string)
  "Parse UUID from canonical string form."
  (flet ((parse-hex (start end)
           (parse-integer string :start start :end end :radix 16)))
    (let* ((s (remove #\- string))
           (high (parse-integer s :start 0 :end 16 :radix 16))
           (low (parse-integer s :start 16 :end 32 :radix 16)))
      (%make-uuid high low))))

(defun uuid-to-bytes (uuid)
  "Convert UUID to a 16-byte vector (big-endian)."
  (let ((bytes (make-array 16 :element-type '(unsigned-byte 8)))
        (high (uuid-high uuid))
        (low (uuid-low uuid)))
    (loop for i from 0 below 8
          do (setf (aref bytes i) (ldb (byte 8 (* 8 (- 7 i))) high)))
    (loop for i from 0 below 8
          do (setf (aref bytes (+ i 8)) (ldb (byte 8 (* 8 (- 7 i))) low)))
    bytes))

(defun bytes-to-uuid (bytes)
  "Convert a 16-byte vector to UUID."
  (let ((high 0) (low 0))
    (loop for i from 0 below 8
          do (setf high (logior (ash high 8) (aref bytes i))))
    (loop for i from 8 below 16
          do (setf low (logior (ash low 8) (aref bytes i))))
    (%make-uuid high low)))

;;; Comparison

(defun uuid= (uuid1 uuid2)
  "Return T if UUID1 equals UUID2."
  (and (= (uuid-high uuid1) (uuid-high uuid2))
       (= (uuid-low uuid1) (uuid-low uuid2))))

(defun uuid< (uuid1 uuid2)
  "Return T if UUID1 is lexicographically less than UUID2."
  (or (< (uuid-high uuid1) (uuid-high uuid2))
      (and (= (uuid-high uuid1) (uuid-high uuid2))
           (< (uuid-low uuid1) (uuid-low uuid2)))))

;;; Accessors

(defun uuid-version (uuid)
  "Return the version number of UUID (1-5)."
  (ldb (byte 4 12) (uuid-high uuid)))

(defun uuid-variant (uuid)
  "Return the variant of UUID.
0-1 = NCS backward compatible
2 = RFC 4122
3 = Microsoft backward compatible"
  (let ((bits (ldb (byte 3 61) (uuid-low uuid))))
    (cond ((zerop (logand bits #b100)) 0)
          ((= (logand bits #b110) #b100) 2)
          ((= (logand bits #b111) #b110) 3)
          (t 3))))

;;; Print method

(defmethod print-object ((uuid uuid) stream)
  (print-unreadable-object (uuid stream :type t)
    (write-string (uuid-to-string uuid) stream)))
