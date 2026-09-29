package com.lora.auth.controller;

import com.lora.auth.dto.ForgotPasswordRequest;
import com.lora.auth.dto.LoginRequest;
import com.lora.auth.dto.LoginResponse;
import com.lora.auth.dto.RegisterRequest;
import com.lora.auth.dto.ResetPasswordRequest;
import com.lora.auth.dto.VerifyForgotPasswordOtpRequest;
import com.lora.auth.dto.VerifyOtpRequest;
import com.lora.auth.service.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    public AuthController(
            AuthService authService
    ) {

        this.authService = authService;
    }


    // =====================================================
    // LOGIN
    // =====================================================

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request
    ) {

        try {

            LoginResponse response =
                    authService.login(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // REGISTER
    // =====================================================

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestBody RegisterRequest request
    ) {

        try {

            String response =
                    authService.register(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // VERIFY EMAIL OTP
    // =====================================================

    @PostMapping("/verify-email")
    public ResponseEntity<?> verifyEmail(
            @RequestBody VerifyOtpRequest request
    ) {

        try {

            String response =
                    authService.verifyEmail(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // VERIFY PHONE OTP
    // =====================================================

    @PostMapping("/verify-phone")
    public ResponseEntity<?> verifyPhone(
            @RequestBody VerifyPhoneRequest request
    ) {

        try {

            String response =
                    authService.verifyPhone(
                            request.getPhone(),
                            request.getOtp()
                    );

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // FORGOT PASSWORD - REQUEST OTP
    // =====================================================

    @PostMapping("/forgot-password/request-otp")
    public ResponseEntity<?> requestForgotPasswordOtp(
            @RequestBody ForgotPasswordRequest request
    ) {

        try {

            String response =
                    authService.requestForgotPasswordOtp(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // FORGOT PASSWORD - VERIFY OTP
    // =====================================================

    @PostMapping("/forgot-password/verify-otp")
    public ResponseEntity<?> verifyForgotPasswordOtp(
            @RequestBody VerifyForgotPasswordOtpRequest request
    ) {

        try {

            String response =
                    authService.verifyForgotPasswordOtp(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // FORGOT PASSWORD - RESET PASSWORD
    // =====================================================

    @PostMapping("/forgot-password/reset")
    public ResponseEntity<?> resetPassword(
            @RequestBody ResetPasswordRequest request
    ) {

        try {

            String response =
                    authService.resetPassword(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .badRequest()
                    .body(e.getMessage());
        }
    }


    // =====================================================
    // PHONE OTP REQUEST DTO
    // =====================================================

    public static class VerifyPhoneRequest {

        private String phone;

        private String otp;


        public String getPhone() {
            return phone;
        }


        public void setPhone(String phone) {
            this.phone = phone;
        }


        public String getOtp() {
            return otp;
        }


        public void setOtp(String otp) {
            this.otp = otp;
        }
    }
}