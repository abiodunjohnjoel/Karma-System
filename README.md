🧭 Decentralized Karma System (Clarity Smart Contract)

📘 Overview

The Decentralized Karma System is a Clarity smart contract that allows anyone to assign and track karma points for blockchain wallets based on their good deeds or community contributions.
It maintains transparent, tamper-proof records of karma scores and histories, enabling fair reputation tracking across a decentralized ecosystem.

⚙️ Core Features
🪙 Karma Scoring

Each wallet has a unique karma score, stored on-chain.

Users can add karma to themselves or to others for positive actions.

Overflow checks ensure scores remain within safe limits.

📜 Transaction History

Every karma addition is logged in the karma-history map with:

recipient (who received karma)

giver (who gave it)

amount (karma value)

block-number (when it happened)

This allows full transparency of all karma transactions.

👥 Participation Tracking

Tracks the total number of participants with non-zero karma.

Automatically increments when a wallet receives karma for the first time.

🧩 Batch Operations

Allows batch karma assignments to up to 10 recipients in one transaction.

Validates that all provided amounts are positive and lists match in length.

💎 Good Deeds Awarding

Specialized function award-good-deed for assigning karma with a descriptive reason (deed-type string).

Limits individual awards to a maximum of 100 karma per transaction.

Useful for gamified or community-based reward systems.

🔒 Safety & Validation

Prevents:

Adding zero karma amounts

Overflow errors

Invalid list lengths during batch processing

Constants are used for error codes, ensuring consistent error handling.

🧠 Key Data Structures
Name	Type	Description
karma-scores	map (principal → uint)	Tracks each wallet’s total karma
karma-history	map ({recipient, block-number} → {giver, amount})	Logs every karma transaction
total-participants	uint	Number of wallets with non-zero karma

📚 Read-Only Functions

Function	Description
get-karma-score(wallet)	Returns the karma score of a given wallet
get-my-karma()	Returns the caller’s own karma
get-karma-transaction(recipient, block-number)	Fetches a specific karma transaction
get-total-participants()	Returns total number of unique participants
has-karma(wallet)	Checks if a wallet has any karma at all

⚡ Public Functions

Function	Description
add-karma(recipient, amount)	Adds karma to another wallet
add-my-karma(amount)	Adds karma to yourself
batch-add-karma(recipients, amounts)	Adds karma to multiple recipients in one call
award-good-deed(recipient, amount, deed-type)	Awards karma with a reason and validation
get-karma-rank(wallet)	(Placeholder) Returns simplified karma rank info

🔧 Private Helpers
Function	Description
add-karma-internal(recipient, amount)	Internal batch karma processor
is-positive(amount)	Checks if amount > 0

🚀 Initialization

Upon deployment, the contract owner (deployer) automatically:

Receives 1 karma point

Becomes the first participant in the system

(map-set karma-scores CONTRACT-OWNER u1)
(var-set total-participants u1)

🧪 Example Usage
;; Give 10 karma points to another user
(contract-call? .karma add-karma 'SP3XK6K... u10)

;; Give yourself 5 karma points
(contract-call? .karma add-my-karma u5)

;; Reward someone for "helping the community"
(contract-call? .karma award-good-deed 'SP3A4ZQ... u15 "helping the community")

⚖️ Error Codes
Constant	Code	Meaning
ERR-INVALID-AMOUNT	100	Invalid or mismatched amount(s)
ERR-UNAUTHORIZED	101	Unauthorized operation
ERR-ZERO-AMOUNT	102	Attempt to add zero karma
ERR-OVERFLOW	103	Overflow in karma total calculation

🧾 License
This contract is open for use, modification, and improvement under the MIT License.