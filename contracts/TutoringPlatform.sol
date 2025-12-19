// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// tutoring platform with encrypted sessions
contract TutoringPlatform is ZamaEthereumConfig {
    struct Tutor {
        address tutor;
        string subject;
        euint32 hourlyRate;  // encrypted
        bool available;
    }
    
    struct Session {
        address student;
        address tutor;
        euint32 duration;    // encrypted hours
        euint32 cost;        // encrypted total cost
        uint256 scheduledAt;
        bool completed;
    }
    
    mapping(address => Tutor) public tutors;
    mapping(uint256 => Session) public sessions;
    mapping(address => uint256[]) public studentSessions;
    uint256 public sessionCounter;
    
    event TutorRegistered(address indexed tutor, string subject);
    event SessionScheduled(uint256 indexed sessionId, address student, address tutor);
    event SessionCompleted(uint256 indexed sessionId);
    
    function registerTutor(
        string memory subject,
        euint32 encryptedHourlyRate
    ) external {
        tutors[msg.sender] = Tutor({
            tutor: msg.sender,
            subject: subject,
            hourlyRate: encryptedHourlyRate,
            available: true
        });
        emit TutorRegistered(msg.sender, subject);
    }
    
    function scheduleSession(
        address tutor,
        euint32 encryptedDuration,
        uint256 scheduledTime
    ) external returns (uint256 sessionId) {
        Tutor storage tutor_ = tutors[tutor];
        require(tutor_.available, "Tutor not available");
        
        sessionId = sessionCounter++;
        sessions[sessionId] = Session({
            student: msg.sender,
            tutor: tutor,
            duration: encryptedDuration,
            cost: calculateCost(tutor_.hourlyRate, encryptedDuration),
            scheduledAt: scheduledTime,
            completed: false
        });
        
        studentSessions[msg.sender].push(sessionId);
        emit SessionScheduled(sessionId, msg.sender, tutor);
    }
    
    function completeSession(uint256 sessionId) external {
        Session storage session = sessions[sessionId];
        require(session.tutor == msg.sender, "Not your session");
        session.completed = true;
        emit SessionCompleted(sessionId);
    }
    
    function calculateCost(euint32 hourlyRate, euint32 duration) private pure returns (euint32) {
        // simplified cost calculation
        return hourlyRate;  // placeholder - would need proper FHE multiplication
    }
}

