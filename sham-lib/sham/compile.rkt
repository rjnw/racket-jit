#lang racket

(require sham/ir
         sham/ir/env
         sham/parameters
         sham/jit
         sham/ir/dump
         sham/ir/verify)

(require sham/private/keyword)
(require (for-syntax syntax/parse))

(provide (all-defined-out))

(define-general-keyword-procedure
  (sham-jit-compile! ka env/mod . rest-args)

  (define cm-env (sham-compile! env/mod (append (sham-compile-options) (lookup-keyword ka #:compile-options #:options '()))))
  (define jit-env (initialize-jit cm-env (lookup-keyword ka #:jit-type #:jit 'mc)))
  (env-try-set-callbacks! env/mod jit-env)
  jit-env)

(define (sham-compile! env/mod compile-options)
  (define (compile-module mod)
    (define (has-options? os)
      (ormap (λ (o) (member o compile-options)) os))
    (define-syntax (when-option stx)
      (syntax-parse stx
        [(_ option:id body ...)
         #`(let ([option (has-options? `(option))])
             (when option
               body ...))]
        [(_ ((~literal or) options:id ...) body ...)
         #`(let ([option (has-options? `(options ...))])
             (when option
               body ...))]))

    (when-option dump-sham (sham-dump-ir mod))
    (define e (build-sham-env mod))
    (when-option dump-llvm (sham-dump-llvm e))
    (when-option (or dump-llvm-ir dump-llvm-ir-before-opt)
                 (sham-dump-llvm-ir e))
    (when-option verify-llvm-with-error
                 (sham-verify-llvm-ir-error e))
    (when-option opt-level
                 (sham-env-optimize-llvm! e #:opt-level opt-level))
    (when-option (or dump-llvm-ir dump-llvm-ir-after-opt)
                 (sham-dump-llvm-ir e))
    e)
  (match env/mod
    [(? sham-env?) env/mod]
    [(? sham-module?) (compile-module env/mod)]
    [(? sham:def:module?) (sham-compile! (build-sham-module env/mod))]
    [(? open-sham-env?) (compile-module (close-open-sham-env! env/mod))]))

(define (env-try-set-callbacks! env jit-env)
  (when (open-sham-env? env)
    (for ([v (open-sham-env-values env)]
          #:when (open-sham-function? v))
      (set-open-sham-function-compiled-app! v (jit-lookup-function jit-env (open-sham-function-id v))))))