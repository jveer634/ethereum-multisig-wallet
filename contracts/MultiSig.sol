// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MultiSig is Ownable {
    using Address for address;

    mapping(address => bool) public signers;
    uint public threshold;

    enum TransactionStatus {
        Cancelled,
        Initiated,
        Voted,
        Executed
    }

    struct Transaction {
        uint id;
        address to;
        bytes data;
        uint votes;
        address proposedBy;
        TransactionStatus status;
    }

    mapping(uint => mapping(address => bool)) public signedBy;
    mapping(uint => Transaction) public transactions;
    uint public counter;

    event TransactionProposed(
        address indexed to,
        address indexed proposer,
        bytes data
    );
    event TransactionVoted(uint indexed txId, address indexed signer);
    event TransactionCancelled(uint txId);
    event TransactionExecuted(uint txId);

    event ThresholdUpdated(uint newThreshold);
    event SignerUpdated(address signer, bool enabled);

    constructor(
        address[] memory _signers,
        uint _threshold
    ) Ownable(msg.sender) {
        require(
            _signers.length > 0 && _signers.length <= _threshold,
            "Invalid signers"
        );

        for (uint i = 0; i < _signers.length; i++) {
            signers[_signers[i]] = true;
        }

        threshold = _threshold;
    }

    function submit(address to, bytes calldata data) external {
        address caller = _msgSender();
        require(caller == owner() || signers[caller], "Unauthorized caller");

        Transaction memory transaction = Transaction({
            id: counter,
            data: data,
            proposedBy: caller,
            to: to,
            votes: 1,
            status: TransactionStatus.Initiated
        });

        signedBy[counter][caller] = true;
        transactions[counter] = transaction;
        counter = counter + 1;
        emit TransactionProposed(to, caller, data);
        if (caller == owner()) {
            _execute(transaction.id);
        }
    }

    function approve(uint txId) external {
        address caller = _msgSender();
        require(signers[caller], "Unauthorized user");
        require(txId <= counter, "Invalid transaction Id");
        require(!signedBy[txId][caller], "User already approved");
        Transaction storage transaction = transactions[txId];

        require(
            transaction.status == TransactionStatus.Initiated ||
                transaction.status == TransactionStatus.Voted,
            "Invalid transaction"
        );
        transaction.votes += 1;
        signedBy[txId][caller] = true;

        emit TransactionVoted(txId, caller);

        if (transaction.votes >= threshold) {
            _execute(txId);
        }
    }

    function cancel(uint txId) external {
        require(txId <= counter, "Invalid transaction Id");

        Transaction storage transaction = transactions[txId];
        require(
            transaction.status == TransactionStatus.Executed ||
                transaction.status == TransactionStatus.Cancelled,
            "Invalid transaction"
        );
        transaction.status = TransactionStatus.Cancelled;

        emit TransactionCancelled(txId);
    }

    function _execute(uint txId) internal {
        Transaction storage transaction = transactions[txId];
        Address.functionCall(transaction.to, transaction.data);
        transaction.status = TransactionStatus.Executed;
        emit TransactionExecuted(transaction.id);
    }

    function setSigner(address signer, bool setEnable) external onlyOwner {
        signers[signer] = setEnable;
        emit SignerUpdated(signer, setEnable);
    }

    function updateThreshold(uint th) external onlyOwner {
        threshold = th;
        emit ThresholdUpdated(th);
    }
}
