
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
    
    - _**Arguments:** job_id, cost of job in stx and freelancer wallet_
    - _**Description:** stores the information in a map. transfers the stx to the contract address itself acting as a escrow_
- add-job-in-vibes (uint, uint, principal) 
    - _**Arguments:** job_id, cost of job in vibes and freelancer wallet_
    - _**Description:** stores the information in a map. transfers the vibes to the contract address itself acting as a escrow_
- close-job (uint)
    - _**Arguments:** job_id_
    - _**Description:** closes the job and delete the entry from the map. transfers the funds from the contract to the freelancer wallet. Job can only be closed by the creator of job (checked using tx-sender)._
- change-hv-fee-wallet (principal)
    - _**Arguments:** new wallet address for HV funds_
    - _**Description:** changes the wallet where HV fee is sent_
- change-stx-percentage (uint)
    - _**Arguments:** new percentage of fee per job in stx_
    - _**Description:** changes the value of stx-percentage_
- change-vibes-percentage (uint)
    - _**Arguments:** new percentage of fee per job in vibes_
    - _**Description:** changes the value of vibes-percentage_

## Read-Only Functions
- get-hv-fee-wallet
- get-stx-percentage
- get-vibes-percentage
- get-job-info (uint principal)