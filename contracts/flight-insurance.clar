;; Flight Insurance Protocol
;; A decentralized flight insurance system using Stacks

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_POLICY_NOT_FOUND (err u101))
(define-constant ERR_POLICY_EXPIRED (err u102))
(define-constant ERR_INSUFFICIENT_PREMIUM (err u103))
(define-constant ERR_CLAIM_ALREADY_PROCESSED (err u104))

(define-map policies
  { policy-id: uint }
  {
    holder: principal,
    flight-number: (string-ascii 10),
    departure-date: uint,
    premium-paid: uint,
    coverage-amount: uint,
    is-active: bool,
    claim-processed: bool
  }
)

(define-map flight-delays
  { flight-number: (string-ascii 10), date: uint }
  { delay-minutes: uint, is-cancelled: bool }
)

(define-data-var policy-counter uint u0)
(define-data-var total-premiums uint u0)

(define-public (purchase-policy (flight-number (string-ascii 10)) (departure-date uint) (coverage-amount uint))
  (let (
    (policy-id (+ (var-get policy-counter) u1))
    (premium (/ coverage-amount u10))
  )
    (asserts! (>= (stx-get-balance tx-sender) premium) ERR_INSUFFICIENT_PREMIUM)
    (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))
    (map-set policies
      { policy-id: policy-id }
      {
        holder: tx-sender,
        flight-number: flight-number,
        departure-date: departure-date,
        premium-paid: premium,
        coverage-amount: coverage-amount,
        is-active: true,
        claim-processed: false
      }
    )
    (var-set policy-counter policy-id)
    (var-set total-premiums (+ (var-get total-premiums) premium))
    (ok policy-id)
  )
)

(define-public (report-flight-delay (flight-number (string-ascii 10)) (date uint) (delay-minutes uint) (is-cancelled bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set flight-delays
      { flight-number: flight-number, date: date }
      { delay-minutes: delay-minutes, is-cancelled: is-cancelled }
    )
    (ok true)
  )
)

(define-public (claim-insurance (policy-id uint))
  (let (
    (policy (unwrap! (map-get? policies { policy-id: policy-id }) ERR_POLICY_NOT_FOUND))
    (flight-info (map-get? flight-delays { flight-number: (get flight-number policy), date: (get departure-date policy) }))
  )
    (asserts! (is-eq tx-sender (get holder policy)) ERR_UNAUTHORIZED)
    (asserts! (get is-active policy) ERR_POLICY_EXPIRED)
    (asserts! (not (get claim-processed policy)) ERR_CLAIM_ALREADY_PROCESSED)
    
    (match flight-info
      delay-data
      (if (or (>= (get delay-minutes delay-data) u120) (get is-cancelled delay-data))
        (begin
          (try! (as-contract (stx-transfer? (get coverage-amount policy) tx-sender (get holder policy))))
          (map-set policies
            { policy-id: policy-id }
            (merge policy { claim-processed: true, is-active: false })
          )
          (ok (get coverage-amount policy))
        )
        (err u105)
      )
      (err u106)
    )
  )
)

(define-read-only (get-policy (policy-id uint))
  (map-get? policies { policy-id: policy-id })
)

(define-read-only (get-flight-status (flight-number (string-ascii 10)) (date uint))
  (map-get? flight-delays { flight-number: flight-number, date: date })
)

(define-read-only (get-total-premiums)
  (var-get total-premiums)
)