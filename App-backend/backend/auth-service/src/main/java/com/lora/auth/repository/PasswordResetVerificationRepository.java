package com.lora.auth.repository;

import com.lora.auth.entity.PasswordResetVerification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PasswordResetVerificationRepository
        extends JpaRepository<PasswordResetVerification, Long> {

    Optional<PasswordResetVerification>
    findTopByIdentifierOrderByCreatedAtDesc(String identifier);
}