#lang racket
(require "define.rkt"
         "ctypes.rkt"
         "target.rkt"
         "execution-engine.rkt")
(require ffi/unsafe)
(provide (all-defined-out))

(define-llvm LLVMGetGlobalPassRegistry (_fun -> LLVMPassRegistryRef))
(define-llvm LLVMInitializeCore (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeTransformUtils (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeScalarOpts (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeObjCARCOpts (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeVectorization (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeInstCombine (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeIPO (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeInstrumentation (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeAnalysis (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeIPA (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeCodeGen (_fun LLVMPassRegistryRef -> _void))
(define-llvm LLVMInitializeTarget (_fun LLVMPassRegistryRef -> _void))


(define (llvm-initialize-all)
  (LLVMLinkInMCJIT)
  (LLVMInitializeX86Target)
  (LLVMInitializeX86TargetInfo)
  (LLVMInitializeX86TargetMC)
  (LLVMInitializeX86AsmParser)
  (LLVMInitializeX86AsmPrinter)
  (define gpr (LLVMGetGlobalPassRegistry))
  (LLVMInitializeCore gpr)
  (LLVMInitializeTransformUtils gpr)
  (LLVMInitializeScalarOpts gpr)
  (LLVMInitializeObjCARCOpts gpr)
  (LLVMInitializeVectorization gpr)
  (LLVMInitializeInstCombine gpr)
  (LLVMInitializeIPO gpr)
  (LLVMInitializeInstrumentation gpr)
  (LLVMInitializeAnalysis gpr)
  (LLVMInitializeIPA gpr)
  (LLVMInitializeCodeGen gpr)
  (LLVMInitializeTarget gpr))
