
# HireVibes Freelance Contract

## Private Functions
- transfer-stx-to-escrow (uint)
- transfer-vibes-to-escrow (uint)
- transfer-stx-to-freelancer (uint, principal)
- transfer-vibes-to-freelancer  (uint, principal)
- transfer-stx-to-hv-fee-wallet (uint)
- transfer-vibes-to-hv-fee-wallet (uint)


## Public Functions
- add-job-in-stx (uint, uint, principal) 
- add-job-in-vibes (uint, uint, principal) 
- close-job (uint)
- change-hv-fee-wallet (principal)
- change-stx-percentage (uint)
- change-vibes-percentage (uint)

## Read-Only Functions
- get-hv-fee-wallet
- get-stx-percentage
- get-vibes-percentage
- get-job-info (uint principal)