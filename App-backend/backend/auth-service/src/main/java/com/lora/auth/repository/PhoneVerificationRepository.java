package com.lora.auth.repository;

import com.lora.auth.entity.PhoneVerification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PhoneVerificationRepository
        extends JpaRepository<PhoneVerification, Long> {

    Optional<PhoneVerification>
    findTopByUserIdOrderByCreatedAtDesc(String userId);
}