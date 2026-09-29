package com.lora.sos_service.controller;

import com.lora.sos_service.dto.AcceptSosRequestDTO;
import com.lora.sos_service.entity.SosAlert;
import com.lora.sos_service.service.SosAlertService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sos")
@CrossOrigin(origins = "http://localhost:5173")
public class SosAlertController {

    private final SosAlertService sosAlertService;
    private final com.lora.sos_service.config.JwtValidator jwtValidator;

    public SosAlertController(
            SosAlertService sosAlertService,
            com.lora.sos_service.config.JwtValidator jwtValidator) {
        this.sosAlertService = sosAlertService;
        this.jwtValidator = jwtValidator;
    }

    // ============================================================
    // CREATE SOS
    // ============================================================

    @PostMapping
    public ResponseEntity<SosAlert> createSos(
            @RequestBody SosAlert sosAlert,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        // Use authenticated identity from JWT when available
        if (authHeader != null && !authHeader.trim().isEmpty()) {
            jwtValidator.validateAndGetClaims(authHeader).ifPresent(claims -> {
                String authenticatedUserId = claims.getSubject();
                if (authenticatedUserId != null && !authenticatedUserId.trim().isEmpty()) {
                    sosAlert.setSenderUserId(authenticatedUserId);
                }
                String authenticatedEmail = claims.get("email", String.class);
                if (authenticatedEmail != null && !authenticatedEmail.trim().isEmpty()) {
                    sosAlert.setSenderEmail(authenticatedEmail);
                }
            });
        }

        return ResponseEntity.ok(
                sosAlertService.createSos(sosAlert)
        );
    }

    // ============================================================
    // GET ALL SOS
    // ============================================================

    @GetMapping
    public ResponseEntity<List<SosAlert>> getAllSos() {

        return ResponseEntity.ok(
                sosAlertService.getAllSos()
        );
    }

    // ============================================================
    // GET USER SOS HISTORY
    // ============================================================

    @GetMapping("/user/{senderUserId}")
    public ResponseEntity<?> getUserSosHistory(
            @PathVariable String senderUserId,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        if (authHeader != null && !authHeader.trim().isEmpty()) {
            var claimsOpt = jwtValidator.validateAndGetClaims(authHeader);
            if (claimsOpt.isPresent()) {
                String authenticatedUserId = claimsOpt.get().getSubject();
                String role = claimsOpt.get().get("role", String.class);
                if (!"ADMIN".equalsIgnoreCase(role) && !"WORKER".equalsIgnoreCase(role)) {
                    // Enforce user isolation: User cannot query another user's SOS history
                    if (authenticatedUserId != null && !authenticatedUserId.equals(senderUserId)) {
                        return ResponseEntity.status(403).body("Access Denied: User isolation violation");
                    }
                }
            }
        }

        return ResponseEntity.ok(
                sosAlertService.getUserSosHistory(senderUserId)
        );
    }

    // ============================================================
    // GET PENDING SOS
    // ============================================================

    @GetMapping("/pending")
    public ResponseEntity<List<SosAlert>> getPendingSos() {

        return ResponseEntity.ok(
                sosAlertService.getPendingSos()
        );
    }

    // ============================================================
    // GET SINGLE SOS
    // ============================================================

    @GetMapping("/{id}")
    public ResponseEntity<SosAlert> getSos(
            @PathVariable String id) {

        return ResponseEntity.ok(
                sosAlertService.getSos(id)
        );
    }

    // ============================================================
    // UPDATE STATUS
    // ============================================================

    @PutMapping("/{id}/status")
    public ResponseEntity<SosAlert> updateStatus(
            @PathVariable String id,
            @RequestParam String status) {

        return ResponseEntity.ok(
                sosAlertService.updateStatus(id, status)
        );
    }

    // ============================================================
    // ACCEPT SOS
    // ============================================================

    @PostMapping("/{id}/accept")
    public ResponseEntity<?> acceptSos(
            @PathVariable String id,
            @RequestBody AcceptSosRequestDTO request) {

        try {

            SosAlert accepted = sosAlertService.acceptSos(
                    id,
                    request.getTeamId(),
                    request.getTeamName()
            );

            return ResponseEntity.ok(accepted);

        } catch (RuntimeException e) {

            if ("TEAM_BUSY".equals(e.getMessage())) {

                return ResponseEntity
                        .status(409)
                        .body("TEAM_BUSY");
            }

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }

    // ============================================================
    // COMPLETE SOS
    // ============================================================

    @PostMapping("/{id}/complete")
    public ResponseEntity<?> completeSos(
            @PathVariable String id) {

        try {

            return ResponseEntity.ok(
                    sosAlertService.completeSos(id)
            );

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }

    // ============================================================
    // CANCEL SOS
    // ============================================================

    @PostMapping("/{id}/cancel")
    public ResponseEntity<?> cancelSos(
            @PathVariable String id) {

        try {

            return ResponseEntity.ok(
                    sosAlertService.cancelSos(id)
            );

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }
}