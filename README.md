# cl-uuid-pure

RFC 4122 UUID implementation for Common Lisp with ZERO external dependencies.

## Installation

```lisp
(asdf:load-system :cl-uuid-pure)
```

## API

### UUID Generation
- `make-v4-uuid` - Random UUID (version 4)
- `make-v1-uuid` - Time-based UUID (version 1)
- `null-uuid` - Nil UUID (all zeros)

### Conversion
- `uuid-to-string` - Convert to canonical string
- `string-to-uuid` - Parse from string

### Comparison
- `uuid=` - Test equality
- `uuid<` - Lexicographic ordering
- `uuid-p` - Type predicate

## Example

```lisp
(let ((id (make-v4-uuid)))
  (uuid-to-string id))
; => "550e8400-e29b-41d4-a716-446655440000"

(uuid= (string-to-uuid "550e8400-e29b-41d4-a716-446655440000")
       (string-to-uuid "550e8400-e29b-41d4-a716-446655440000"))
; => T
```

## License

BSD-3-Clause. Copyright (c) 2024-2026 Parkian Company LLC.
