;; Digital Asset Borrowing Contract
;; Implements functionality for lending and borrowing digital assets with integrated payment processing
;; Define digital asset trait
(define-trait digital-asset-trait (
    (transfer (uint principal principal) (response bool uint))
    (get-owner (uint) (response principal uint))
    (get-asset-uri (uint) (response (optional (string-ascii 256)) uint))
))

(define-non-fungible-token loan-asset uint)

;; Constants for input validation
(define-constant MAX_LOAN_DURATION u52560) ;; Max loan duration (approximately 1 year in blocks)
(define-constant MAX_LOAN_RATE u1000000000) ;; Max loan rate (1 billion - adjust as needed)
(define-constant ERR-INVALID-ASSET (err u100))
(define-constant ERR-ASSET-NOT-FOUND (err u101))
(define-constant ERR-INVALID-PARAMS (err u102))
(define-constant ERR-NOT-OWNER (err u103))
(define-constant ERR-ALREADY-BORROWED (err u104))
(define-constant ERR-INSUFFICIENT-FUNDS (err u105))

(define-map loan-contracts
  { asset-id: uint }
  { borrower: (optional principal), 
    lender: principal, 
    loan-expiry: uint, 
    loan-rate: uint, 
    loan-duration: uint })

(define-map accounts
  { user: principal }
  { funds: uint })

;; Helper function to validate asset ID
(define-private (validate-asset-id (id uint))
  (and 
    (< id u1000000) ;; Arbitrary max asset ID
    (is-some (nft-get-owner? loan-asset id))))

;; Helper function to validate loan parameters
(define-private (validate-loan-params (rate uint) (duration uint))
  (and 
    (> rate u0)
    (<= rate MAX_LOAN_RATE)
    (> duration u0)
    (<= duration MAX_LOAN_DURATION)))

(define-read-only (get-asset-owner (asset-id uint))
  (begin
    (asserts! (validate-asset-id asset-id) ERR-INVALID-ASSET)
    (ok (unwrap! (nft-get-owner? loan-asset asset-id) ERR-ASSET-NOT-FOUND))))

;; The `create-asset` function mints a new digital asset with the given ID and assigns it to the transaction sender.
(define-public (create-asset (id uint))
  (begin
    (asserts! (validate-asset-id id) ERR-INVALID-ASSET)
    (try! (nft-mint? loan-asset id tx-sender))
    (ok u1)))

;; Function to offer an asset for lending by specifying the asset ID, loan rate, and loan duration
(define-public (offer-asset-for-loan (asset-id uint) (rate uint) (loan-duration uint))
  (begin
    (asserts! (validate-asset-id asset-id) ERR-INVALID-ASSET)
    (asserts! (validate-loan-params rate loan-duration) ERR-INVALID-PARAMS)
    (asserts! (is-eq tx-sender (unwrap! (get-asset-owner asset-id) ERR-ASSET-NOT-FOUND)) 
              ERR-NOT-OWNER)
    (map-insert loan-contracts
      { asset-id: asset-id }
      { borrower: none, 
        lender: tx-sender, 
        loan-expiry: u0, 
        loan-rate: rate, 
        loan-duration: loan-duration })
    (ok u1)))

;; Function to borrow an asset by specifying the asset ID and paying the loan rate
(define-public (borrow-asset (asset-id uint))
  (begin
    (asserts! (validate-asset-id asset-id) ERR-INVALID-ASSET)
    (let (
          (contract (unwrap! (map-get? loan-contracts { asset-id: asset-id }) 
                             ERR-ASSET-NOT-FOUND))
          (borrower-account (unwrap! (map-get? accounts { user: tx-sender }) 
                                  ERR-INSUFFICIENT-FUNDS))
        )
      (begin
        (asserts! (is-none (get borrower contract)) ERR-ALREADY-BORROWED)
        (asserts! (>= (get funds borrower-account) (get loan-rate contract)) 
                  ERR-INSUFFICIENT-FUNDS)
        (map-set loan-contracts
          { asset-id: asset-id }
          { borrower: (some tx-sender), 
            lender: (get lender contract), 
            loan-expiry: (+ stacks-block-height (get loan-duration contract)), 
            loan-rate: (get loan-rate contract), 
            loan-duration: (get loan-duration contract) })
        (map-set accounts
          { user: tx-sender }
          { funds: (- (get funds borrower-account) (get loan-rate contract)) })
        (ok u1)))))