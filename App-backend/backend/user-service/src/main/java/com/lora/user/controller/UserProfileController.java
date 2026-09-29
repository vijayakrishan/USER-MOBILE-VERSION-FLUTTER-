package com.lora.user.controller;

import com.lora.user.config.JwtValidator;
import com.lora.user.entity.UserProfile;
import com.lora.user.service.UserProfileService;
import io.jsonwebtoken.Claims;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/users/profile")
@CrossOrigin(origins = "*")
public class UserProfileController {

    private final UserProfileService userProfileService;
    private final JwtValidator jwtValidator;

    public UserProfileController(UserProfileService userProfileService, JwtValidator jwtValidator) {
        this.userProfileService = userProfileService;
        this.jwtValidator = jwtValidator;
    }

    private boolean isAuthorizedUser(String authHeader, String identifier) {
        if (authHeader == null || authHeader.trim().isEmpty()) {
            return true;
        }
        Optional<Claims> claimsOpt = jwtValidator.validateAndGetClaims(authHeader);
        if (claimsOpt.isEmpty()) {
            return false;
        }
        Claims claims = claimsOpt.get();
        String role = claims.get("role", String.class);
        if ("ADMIN".equalsIgnoreCase(role) || "WORKER".equalsIgnoreCase(role)) {
            return true;
        }
        String sub = claims.getSubject();
        String email = claims.get("email", String.class);
        return (sub != null && sub.equalsIgnoreCase(identifier)) ||
               (email != null && email.equalsIgnoreCase(identifier));
    }

    // =====================================================
    // GET PROFILE (By Email or User UUID)
    // =====================================================

    @GetMapping("/{identifier}")
    public ResponseEntity<?> getProfile(
            @PathVariable String identifier,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        if (authHeader != null && !isAuthorizedUser(authHeader, identifier)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access Denied: User isolation violation");
        }

        return ResponseEntity.ok(
                userProfileService.getProfile(identifier)
        );
    }

    // =====================================================
    // UPDATE PROFILE (By Email or User UUID)
    // =====================================================

    @PutMapping("/{identifier}")
    public ResponseEntity<?> updateProfile(
            @PathVariable String identifier,
            @RequestBody UserProfile updatedProfile,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        if (authHeader != null && !isAuthorizedUser(authHeader, identifier)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access Denied: User isolation violation");
        }

        return ResponseEntity.ok(
                userProfileService.updateProfile(
                        identifier,
                        updatedProfile
                )
        );
    }
}