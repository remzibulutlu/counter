(define-constant ERR_COUNTER_MAX_REACHED (err u100))
(define-constant ERR_CANNOT_DECREMENT_BELOW_ZERO (err u101))

;; An on-chain counter that stores a count for each individual

(define-map counters principal uint)

;; Define MAX_COUNT constant
(define-constant MAX_COUNT u1000) ;;

;; Define total-ops data variable
(define-data-var total-ops uint u0)

;; Define get-total-operations read-only function
;; Returns the total number of operations performed (count-up or count-down)
(define-read-only (get-total-operations)
  (var-get total-ops)
)

;; Define update-total-ops private function
;; Increments the total-ops counter
(define-private (update-total-ops)
  (ok (var-set total-ops (+ (var-get total-ops) u1)))
)

;; Function to retrieve the count for a given individual
(define-read-only (get-count (who principal))
  (default-to u0 (map-get? counters who))
)

;; Update increment function (count-up) to include MAX_COUNT check and call update-total-ops
;; Function to increment the count for the caller, ensuring it doesn't exceed MAX_COUNT.
(define-public (count-up)
  (begin
    (let ((current-count (get-count tx-sender)))
      (asserts! (< current-count MAX_COUNT) ERR_COUNTER_MAX_REACHED)
      (try! (update-total-ops)) ;; Increment total operations
      (map-set counters tx-sender (+ current-count u1))
      (ok (+ current-count u1)) ;; Return the new count
    )
  )
)

;; Add a new public function to decrement the count
;; This function will also call update-total-ops
(define-public (count-down)
  (begin
    (let ((current-count (get-count tx-sender)))
      (asserts! (> current-count u0) ERR_CANNOT_DECREMENT_BELOW_ZERO)
      (try! (update-total-ops)) ;; Increment total operations
      (map-set counters tx-sender (- current-count u1))
      (ok (- current-count u1)) ;; Return the new count
    )
  )
)
