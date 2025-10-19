;; Decentralized Karma System
;; Simple contract to track karma scores for wallets based on good deeds

;; Error constants
(define-constant ERR-INVALID-AMOUNT (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))
(define-constant ERR-ZERO-AMOUNT (err u102))
(define-constant ERR-OVERFLOW (err u103))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Data maps
(define-map karma-scores principal uint)
(define-map karma-history {recipient: principal, block-number: uint} {giver: principal, amount: uint})

;; Data variables
(define-data-var total-participants uint u0)

;; Read-only functions

;; Get karma score for a specific wallet
(define-read-only (get-karma-score (wallet principal))
  (default-to u0 (map-get? karma-scores wallet))
)

;; Get current caller's karma score
(define-read-only (get-my-karma)
  (get-karma-score tx-sender)
)

;; Get karma transaction history for a recipient at a specific block
(define-read-only (get-karma-transaction (recipient principal) (block-number uint))
  (map-get? karma-history {recipient: recipient, block-number: block-number})
)

;; Get total number of participants in the karma system
(define-read-only (get-total-participants)
  (var-get total-participants)
)

;; Check if a wallet has any karma (useful for leaderboard filtering)
(define-read-only (has-karma (wallet principal))
  (> (get-karma-score wallet) u0)
)

;; Public functions

;; Add karma points for good deeds (can be called by anyone for any wallet)
(define-public (add-karma (recipient principal) (amount uint))
  (begin
    ;; Validate amount is greater than 0
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    ;; Get current karma score
    (let ((current-karma (get-karma-score recipient)))
      ;; Check for overflow
      (asserts! (<= amount (- u340282366920938463463374607431768211455 current-karma)) ERR-OVERFLOW)
      ;; Track if this is a new participant
      (if (is-eq current-karma u0)
          (var-set total-participants (+ (var-get total-participants) u1))
          true
      )
      ;; Log the karma transaction
      (map-set karma-history 
        {recipient: recipient, block-number: block-height} 
        {giver: tx-sender, amount: amount}
      )
      ;; Update karma score
      (ok (map-set karma-scores recipient (+ current-karma amount)))
    )
  )
)

;; Add karma to yourself (convenience function)
(define-public (add-my-karma (amount uint))
  (add-karma tx-sender amount)
)

;; Batch add karma to multiple recipients
(define-public (batch-add-karma (recipients (list 10 principal)) (amounts (list 10 uint)))
  (begin
    ;; Ensure lists are same length
    (asserts! (is-eq (len recipients) (len amounts)) ERR-INVALID-AMOUNT)
    ;; Validate all amounts are greater than 0
    (asserts! (is-eq (len (filter is-positive amounts)) (len amounts)) ERR-ZERO-AMOUNT)
    ;; Process each recipient-amount pair with validation
    (ok (map add-karma-internal recipients amounts))
  )
)

;; Helper function for batch processing
(define-private (add-karma-internal (recipient principal) (amount uint))
  (let ((current-karma (get-karma-score recipient)))
    ;; Check for overflow before adding
    (if (<= amount (- u340282366920938463463374607431768211455 current-karma))
        (begin
          ;; Track new participants
          (if (is-eq current-karma u0)
              (var-set total-participants (+ (var-get total-participants) u1))
              true
          )
          ;; Log transaction
          (map-set karma-history 
            {recipient: recipient, block-number: block-height} 
            {giver: tx-sender, amount: amount}
          )
          ;; Update score
          (map-set karma-scores recipient (+ current-karma amount))
        )
        (map-set karma-scores recipient current-karma)
    )
  )
)

;; Helper function to check if amount is positive
(define-private (is-positive (amount uint))
  (> amount u0)
)

;; Get karma ranking for a wallet (simplified version)
(define-public (get-karma-rank (wallet principal))
  (let ((wallet-karma (get-karma-score wallet)))
    (if (is-eq wallet-karma u0)
        (ok none)
        (ok (some u1))
    )
  )
)

;; Award "good deed" karma with a reason (enhanced version)
(define-public (award-good-deed (recipient principal) (amount uint) (deed-type (string-ascii 50)))
  (begin
    ;; Validate amount is reasonable for good deeds (max 100 per transaction)
    (asserts! (and (> amount u0) (<= amount u100)) ERR-INVALID-AMOUNT)
    ;; Call standard add-karma function
    (unwrap-panic (add-karma recipient amount))
    ;; Could emit event here in future versions
    (ok {recipient: recipient, amount: amount, deed: deed-type, giver: tx-sender})
  )
)

;; Initialize contract (optional - sets deployer karma to 1)
(map-set karma-scores CONTRACT-OWNER u1)
(var-set total-participants u1)