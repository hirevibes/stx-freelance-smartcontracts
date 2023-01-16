
;; main

;; errors
;;
(define-constant ERR_JOB_EXISTS (err u200))
(define-constant ERR_JOB_NOT_FOUND (err u201))
(define-constant ERR_VALUE_NOT_FOUND (err u202))
(define-constant ERR_CALLER_NOT_OWNER (err u203))


;; data maps and vars
;;
(define-map jobs {job-id : uint, employer: principal } {amount: uint, freelancer-wallet: principal, vibes: bool})

(define-data-var stx-percentage uint u5)
(define-data-var vibes-percentage uint u3)

;; change the address to any address you want to use
(define-data-var hv-fee-wallet principal 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6)

;; sets the owner to the wallet address that deploys the contract 
(define-constant owner tx-sender)

(define-constant contract-address (as-contract tx-sender))

;; private functionsc
;;
(define-private (transfer-stx-to-escrow (amount uint)) 

    (stx-transfer? amount tx-sender contract-address)

)

(define-private (transfer-vibes-to-escrow (amount uint)) 

    (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender contract-address none)

)

(define-private (transfer-stx-to-freelancer (amount uint) (freelancer-wallet principal)) 

    ;; the context is changed to the contract, now tx-sender is the contract address itself
    (as-contract (stx-transfer? amount tx-sender freelancer-wallet))

)

(define-private (transfer-vibes-to-freelancer (amount uint) (freelancer-wallet principal)) 

    ;; the context is changed to the contract, now tx-sender is the contract address itself
    ;; change the ".vibes-token" to the actual contract address on testnet/mainnet or add vibes-token contract in the project
   (as-contract (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender freelancer-wallet none))

)

(define-private (transfer-stx-to-hv-fee-wallet (amount uint)) 

    (stx-transfer? amount tx-sender (var-get hv-fee-wallet))

)

(define-private (transfer-vibes-to-hv-fee-wallet (amount uint)) 

    ;; change the ".vibes-token" to the actual contract address on testnet/mainnet or add vibes-token contract in the project
    (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender (var-get hv-fee-wallet) none)

)


;; public functions

(define-public (add-job-in-stx (job-id uint) (amount uint) (freelancer-wallet principal) ) 

(let 
    (
        (percentage (var-get stx-percentage))
        (hv-fee (/ (* amount percentage) u100))
    )
    
    (asserts! (is-none (map-get? jobs {job-id: job-id, employer: tx-sender})) ERR_JOB_EXISTS) ;; execution only continues if data doesn't already exists

    
    (try! (transfer-stx-to-hv-fee-wallet hv-fee)) ;;transfers the fee for posting the job to owner
    (try! (transfer-stx-to-escrow amount))

    (map-set jobs {job-id: job-id, employer: tx-sender} {amount: amount, freelancer-wallet: freelancer-wallet, vibes: false})
    (ok true)
)
)


(define-public (add-job-in-vibes (job-id uint) (amount uint) (freelancer-wallet principal) ) 
(let 
    (
        (percentage (var-get vibes-percentage))
        (hv-fee (/ (* amount percentage) u100))
    )

    (asserts! (is-none (map-get? jobs {job-id: job-id, employer: tx-sender})) ERR_JOB_EXISTS) ;; execution only continues if data doesn't already exists

    (try! (transfer-vibes-to-hv-fee-wallet hv-fee)) ;;transfers the fee for posting the job to owner
    (try! (transfer-vibes-to-escrow amount))
    (map-set jobs {job-id: job-id, employer: tx-sender} {amount: amount, freelancer-wallet: freelancer-wallet, vibes: true})
    (ok true)
)
)

(define-public (close-job (job-id uint)) 
(let
    (
        (amount (get amount (unwrap! (map-get? jobs {job-id: job-id, employer: tx-sender}) ERR_VALUE_NOT_FOUND )) )

        (freelancer-wallet (get freelancer-wallet (unwrap! (map-get? jobs {job-id: job-id, employer: tx-sender}) ERR_VALUE_NOT_FOUND )) )

        (vibes (get vibes (unwrap! (map-get? jobs {job-id: job-id, employer: tx-sender}) ERR_VALUE_NOT_FOUND )) )
    )

    ;; execution only continues if data already exists
    (asserts! (is-some (map-get? jobs {job-id: job-id, employer: tx-sender})) ERR_JOB_NOT_FOUND) 

    (if (is-eq vibes true)
        ;;true
        (try! (transfer-vibes-to-freelancer amount freelancer-wallet))

        ;;false
        (try! (transfer-stx-to-freelancer amount freelancer-wallet))
    )
    
    ;; if funds are successfully transfered, delete the job
    (map-delete jobs {job-id: job-id, employer: tx-sender})

    (ok true)
)
)

(define-public (change-hv-fee-wallet (wallet principal)) 
(begin

    (asserts! (is-eq tx-sender owner) ERR_CALLER_NOT_OWNER)
    (ok (var-set hv-fee-wallet wallet))

)
)

(define-public (change-stx-percentage (val uint)) 
(begin

    (asserts! (is-eq tx-sender owner) ERR_CALLER_NOT_OWNER)
    (ok (var-set stx-percentage val))

)
)

(define-public (change-vibes-percentage (val uint)) 
(begin

    (asserts! (is-eq tx-sender owner) ERR_CALLER_NOT_OWNER)
    (ok (var-set vibes-percentage val))

)
)


;; read-only functions
;;
(define-read-only (get-hv-fee-wallet) 

    (var-get hv-fee-wallet)
)

(define-read-only (get-stx-percentage) 

    (var-get stx-percentage)
)

(define-read-only (get-vibes-percentage) 

    (var-get vibes-percentage)

)

(define-read-only (get-job-info (job-id uint) (employer principal)) 

    (ok (unwrap! (map-get? jobs {job-id: job-id, employer: employer}) ERR_JOB_NOT_FOUND))
)