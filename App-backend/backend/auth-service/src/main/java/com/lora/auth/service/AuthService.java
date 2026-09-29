package com.lora.auth.service;

import com.lora.auth.dto.ForgotPasswordRequest;
import com.lora.auth.dto.LoginRequest;
import com.lora.auth.dto.LoginResponse;
import com.lora.auth.dto.RegisterRequest;
import com.lora.auth.dto.ResetPasswordRequest;
import com.lora.auth.dto.VerifyForgotPasswordOtpRequest;
import com.lora.auth.dto.VerifyOtpRequest;

import com.lora.auth.entity.EmailVerification;
import com.lora.auth.entity.PasswordResetVerification;
import com.lora.auth.entity.PhoneVerification;
import com.lora.auth.entity.User;

import com.lora.auth.repository.EmailVerificationRepository;
import com.lora.auth.repository.PasswordResetVerificationRepository;
import com.lora.auth.repository.PhoneVerificationRepository;
import com.lora.auth.repository.UserRepository;

import com.lora.auth.security.JwtService;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;

    private final EmailVerificationRepository
            emailVerificationRepository;

    private final PhoneVerificationRepository
            phoneVerificationRepository;

    private final PasswordResetVerificationRepository
            passwordResetVerificationRepository;

    private final EmailService emailService;

    private final SmsService smsService;

    private final JwtService jwtService;

    private final BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    public AuthService(
            UserRepository userRepository,
            EmailVerificationRepository emailVerificationRepository,
            PhoneVerificationRepository phoneVerificationRepository,
            PasswordResetVerificationRepository passwordResetVerificationRepository,
            EmailService emailService,
            SmsService smsService,
            JwtService jwtService
    ) {

        this.userRepository = userRepository;

        this.emailVerificationRepository =
                emailVerificationRepository;

        this.phoneVerificationRepository =
                phoneVerificationRepository;

        this.passwordResetVerificationRepository =
                passwordResetVerificationRepository;

        this.emailService = emailService;

        this.smsService = smsService;

        this.jwtService = jwtService;
    }


    // =====================================================
    // LOGIN
    // EMAIL OR PHONE
    // =====================================================

    public LoginResponse login(LoginRequest request) {

        String identifier = request.getIdentifier();

        if (identifier == null ||
                identifier.trim().isEmpty()) {

            throw new RuntimeException(
                    "EMAIL_OR_PHONE_REQUIRED"
            );
        }

        if (request.getPassword() == null ||
                request.getPassword().trim().isEmpty()) {

            throw new RuntimeException(
                    "PASSWORD_REQUIRED"
            );
        }

        identifier = identifier.trim();


        System.out.println("=================================");
        System.out.println("LOGIN REQUEST");
        System.out.println("Identifier: " + identifier);


        // =================================================
        // FIND USER
        // =================================================

        User user;

        if (identifier.contains("@")) {

            user = userRepository
                    .findByEmail(identifier)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "USER_NOT_FOUND"
                            )
                    );

        } else {

            user = userRepository
                    .findByPhone(identifier)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "USER_NOT_FOUND"
                            )
                    );
        }


        System.out.println(
                "USER FOUND: " +
                        user.getEmail()
        );

        System.out.println(
                "NAME: " +
                        user.getName()
        );

        System.out.println(
                "ROLE: " +
                        user.getRole()
        );

        System.out.println(
                "WORKER ID: " +
                        user.getWorkerId()
        );

        System.out.println(
                "TEAM ID: " +
                        user.getTeamId()
        );

        System.out.println(
                "TEAM NAME: " +
                        user.getTeamName()
        );


        // =================================================
        // ACCOUNT VERIFICATION CHECK
        // =================================================

        if (!"ACTIVE".equalsIgnoreCase(
                user.getAccountStatus()
        )) {

            throw new RuntimeException(
                    "ACCOUNT_NOT_VERIFIED"
            );
        }


        // =================================================
        // PASSWORD CHECK
        // =================================================

        boolean passwordMatch =
                passwordEncoder.matches(
                        request.getPassword(),
                        user.getPassword()
                );


        System.out.println(
                "PASSWORD MATCH: " +
                        passwordMatch
        );


        if (!passwordMatch) {

            throw new RuntimeException(
                    "INVALID_PASSWORD"
            );
        }


        // =================================================
        // LOGIN SUCCESS
        // =================================================

        System.out.println("LOGIN SUCCESS");

        System.out.println(
                "================================="
        );


        String jwtToken = jwtService.generateToken(user);

        return LoginResponse.builder()
                .message("Login successful")
                .role(user.getRole())
                .token(jwtToken)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .workerId(user.getWorkerId())
                .teamId(user.getTeamId())
                .teamName(user.getTeamName())
                .build();
    }


    // =====================================================
    // REGISTER
    // EMAIL OPTIONAL
    // PHONE REQUIRED
    // =====================================================

    public String register(RegisterRequest request) {

        System.out.println("=================================");
        System.out.println("REGISTRATION REQUEST");


        // =================================================
        // VALIDATE NAME
        // =================================================

        if (request.getName() == null ||
                request.getName().trim().isEmpty()) {

            throw new RuntimeException(
                    "NAME_REQUIRED"
            );
        }


        // =================================================
        // VALIDATE PHONE
        // =================================================

        if (request.getPhone() == null ||
                request.getPhone().trim().isEmpty()) {

            throw new RuntimeException(
                    "PHONE_REQUIRED"
            );
        }


        // =================================================
        // VALIDATE PASSWORD
        // =================================================

        if (request.getPassword() == null ||
                request.getPassword().trim().isEmpty()) {

            throw new RuntimeException(
                    "PASSWORD_REQUIRED"
            );
        }


        // =================================================
        // CLEAN INPUTS
        // =================================================

        String name =
                request.getName().trim();

        String email =
                request.getEmail();

        /*
         * EMAIL IS OPTIONAL.
         *
         * If the user leaves email empty,
         * convert it to null.
         */

        if (email != null) {

            email = email.trim();

            if (email.isEmpty()) {
                email = null;
            }
        }


        String phone =
                request.getPhone().trim();


        System.out.println(
                "Name: " + name
        );

        System.out.println(
                "Email: " + email
        );

        System.out.println(
                "Phone: " + phone
        );


        // =================================================
        // CHECK EMAIL ONLY IF PROVIDED
        // =================================================

        if (email != null) {

            if (userRepository.existsByEmail(email)) {

                throw new RuntimeException(
                        "EMAIL_ALREADY_REGISTERED"
                );
            }
        }


        // =================================================
        // CHECK PHONE
        // =================================================

        if (userRepository.existsByPhone(phone)) {

            throw new RuntimeException(
                    "PHONE_ALREADY_REGISTERED"
            );
        }


        // =================================================
        // CREATE USER
        // =================================================

        User user = new User();

        user.setId(
                UUID.randomUUID().toString()
        );

        user.setName(name);

        user.setEmail(email);

        user.setPhone(phone);


        // =================================================
        // PASSWORD
        // =================================================

        String encryptedPassword =
                passwordEncoder.encode(
                        request.getPassword()
                );

        user.setPassword(
                encryptedPassword
        );


        // =================================================
        // DEFAULT ROLE
        // =================================================

        user.setRole("USER");


        // =================================================
        // ACCOUNT STATUS
        // =================================================

        user.setAccountStatus(
                "PENDING_VERIFICATION"
        );


        // =================================================
        // AUTH PROVIDER
        // =================================================

        user.setAuthProvider("LOCAL");


        // =================================================
        // SAVE USER
        // =================================================

        User savedUser =
                userRepository.save(user);


        System.out.println(
                "USER CREATED: " +
                        savedUser.getId()
        );


        // =================================================
        // PHONE OTP
        // PHONE OTP IS ALWAYS REQUIRED
        // =================================================

        String phoneOtp =
                generateOtp();

        System.out.println(
                "PHONE OTP GENERATED: " +
                        phoneOtp
        );


        // =================================================
        // CREATE PHONE VERIFICATION
        // =================================================

        PhoneVerification phoneVerification =
                new PhoneVerification();

        phoneVerification.setUserId(
                savedUser.getId()
        );

        phoneVerification.setOtp(
                phoneOtp
        );

        phoneVerification.setExpiresAt(
                LocalDateTime.now().plusMinutes(10)
        );

        phoneVerification.setVerified(false);

        phoneVerificationRepository.save(
                phoneVerification
        );


        // =================================================
        // SEND PHONE OTP
        // DEVELOPMENT VERSION
        // =================================================

        smsService.sendOtpSms(
                savedUser.getPhone(),
                phoneOtp
        );

        System.out.println(
                "PHONE OTP GENERATED FOR DEVELOPMENT"
        );


        // =================================================
        // EMAIL OTP
        // ONLY IF EMAIL IS PROVIDED
        // =================================================

        if (email != null) {

            String emailOtp =
                    generateOtp();

            System.out.println(
                    "EMAIL OTP GENERATED: " +
                            emailOtp
            );


            // =============================================
            // CREATE EMAIL VERIFICATION
            // =============================================

            EmailVerification emailVerification =
                    new EmailVerification();

            emailVerification.setUserId(
                    savedUser.getId()
            );

            emailVerification.setOtp(
                    emailOtp
            );

            emailVerification.setExpiresAt(
                    LocalDateTime.now().plusMinutes(10)
            );

            emailVerification.setVerified(false);

            emailVerificationRepository.save(
                    emailVerification
            );


            // =============================================
            // SEND EMAIL OTP
            // =============================================

            emailService.sendOtpEmail(
                    email,
                    emailOtp
            );

            System.out.println(
                    "EMAIL OTP SENT"
            );
        }


        System.out.println(
                "================================="
        );


        // =================================================
        // RESPONSE
        // =================================================

        if (email != null) {

            return
                    "Registration successful. " +
                            "Email OTP sent to your email. " +
                            "Phone OTP: " +
                            phoneOtp;

        } else {

            return
                    "Registration successful. " +
                            "Phone OTP: " +
                            phoneOtp;
        }
    }


    // =====================================================
    // VERIFY EMAIL OTP
    // =====================================================

    public String verifyEmail(
            VerifyOtpRequest request
    ) {

        if (request.getEmail() == null ||
                request.getEmail().trim().isEmpty()) {

            throw new RuntimeException(
                    "EMAIL_REQUIRED"
            );
        }

        if (request.getOtp() == null ||
                request.getOtp().trim().isEmpty()) {

            throw new RuntimeException(
                    "OTP_REQUIRED"
            );
        }


        String email =
                request.getEmail().trim();

        String otp =
                request.getOtp().trim();


        // =================================================
        // FIND USER
        // =================================================

        User user =
                userRepository
                        .findByEmail(email)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "USER_NOT_FOUND"
                                )
                        );


        // =================================================
        // FIND LATEST EMAIL OTP
        // =================================================

        EmailVerification verification =
                emailVerificationRepository
                        .findTopByUserIdOrderByCreatedAtDesc(
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "EMAIL_OTP_NOT_FOUND"
                                )
                        );


        // =================================================
        // CHECK ALREADY VERIFIED
        // =================================================

        if (Boolean.TRUE.equals(
                verification.getVerified()
        )) {

            return "Email already verified.";
        }


        // =================================================
        // CHECK OTP
        // =================================================

        if (!verification.getOtp().equals(otp)) {

            throw new RuntimeException(
                    "INVALID_EMAIL_OTP"
            );
        }


        // =================================================
        // CHECK EXPIRY
        // =================================================

        if (LocalDateTime.now().isAfter(
                verification.getExpiresAt()
        )) {

            throw new RuntimeException(
                    "EMAIL_OTP_EXPIRED"
            );
        }


        // =================================================
        // MARK EMAIL VERIFIED
        // =================================================

        verification.setVerified(true);

        emailVerificationRepository.save(
                verification
        );


        System.out.println(
                "EMAIL VERIFIED SUCCESSFULLY"
        );


        // =================================================
        // CHECK ACCOUNT ACTIVATION
        // =================================================

        activateUserIfVerified(user);


        return "Email verified successfully.";
    }


    // =====================================================
    // VERIFY PHONE OTP
    // =====================================================

    public String verifyPhone(
            String phone,
            String otp
    ) {

        if (phone == null ||
                phone.trim().isEmpty()) {

            throw new RuntimeException(
                    "PHONE_REQUIRED"
            );
        }

        if (otp == null ||
                otp.trim().isEmpty()) {

            throw new RuntimeException(
                    "OTP_REQUIRED"
            );
        }


        String cleanPhone =
                phone.trim();

        String cleanOtp =
                otp.trim();


        // =================================================
        // FIND USER
        // =================================================

        User user =
                userRepository
                        .findByPhone(cleanPhone)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "USER_NOT_FOUND"
                                )
                        );


        // =================================================
        // FIND LATEST PHONE OTP
        // =================================================

        PhoneVerification verification =
                phoneVerificationRepository
                        .findTopByUserIdOrderByCreatedAtDesc(
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "PHONE_OTP_NOT_FOUND"
                                )
                        );


        // =================================================
        // CHECK ALREADY VERIFIED
        // =================================================

        if (Boolean.TRUE.equals(
                verification.getVerified()
        )) {

            return "Phone already verified.";
        }


        // =================================================
        // CHECK OTP
        // =================================================

        if (!verification.getOtp().equals(
                cleanOtp
        )) {

            throw new RuntimeException(
                    "INVALID_PHONE_OTP"
            );
        }


        // =================================================
        // CHECK EXPIRY
        // =================================================

        if (LocalDateTime.now().isAfter(
                verification.getExpiresAt()
        )) {

            throw new RuntimeException(
                    "PHONE_OTP_EXPIRED"
            );
        }


        // =================================================
        // MARK PHONE VERIFIED
        // =================================================

        verification.setVerified(true);

        phoneVerificationRepository.save(
                verification
        );


        System.out.println(
                "PHONE VERIFIED SUCCESSFULLY"
        );


        // =================================================
        // CHECK ACCOUNT ACTIVATION
        // =================================================

        activateUserIfVerified(user);


        return "Phone verified successfully.";
    }


    // =====================================================
    // FORGOT PASSWORD - REQUEST OTP
    // EMAIL OR PHONE
    // =====================================================

    public String requestForgotPasswordOtp(
            ForgotPasswordRequest request
    ) {

        if (request == null ||
                request.getIdentifier() == null ||
                request.getIdentifier().trim().isEmpty()) {

            throw new RuntimeException(
                    "EMAIL_OR_PHONE_REQUIRED"
            );
        }


        String identifier =
                request.getIdentifier().trim();


        System.out.println("=================================");
        System.out.println("FORGOT PASSWORD OTP REQUEST");

        System.out.println(
                "Identifier: " + identifier
        );


        // =================================================
        // FIND USER BY EMAIL OR PHONE
        // =================================================

        User user;

        if (identifier.contains("@")) {

            user = userRepository
                    .findByEmail(identifier)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "USER_NOT_FOUND"
                            )
                    );

        } else {

            user = userRepository
                    .findByPhone(identifier)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "USER_NOT_FOUND"
                            )
                    );
        }


        // =================================================
        // GENERATE OTP
        // =================================================

        String otp =
                generateOtp();

        System.out.println(
                "PASSWORD RESET OTP: " + otp
        );


        // =================================================
        // CREATE RESET VERIFICATION
        // =================================================

        PasswordResetVerification verification =
                new PasswordResetVerification();

        verification.setUserId(
                user.getId()
        );

        verification.setIdentifier(
                identifier
        );

        verification.setOtp(
                otp
        );

        verification.setExpiresAt(
                LocalDateTime.now().plusMinutes(10)
        );

        verification.setVerified(false);


        passwordResetVerificationRepository.save(
                verification
        );


        // =================================================
        // SEND OTP
        // =================================================

        if (identifier.contains("@")) {

            emailService.sendOtpEmail(
                    user.getEmail(),
                    otp
            );

            System.out.println(
                    "PASSWORD RESET OTP SENT TO EMAIL"
            );

            System.out.println(
                    "================================="
            );

            return "OTP sent to your email.";

        } else {

            smsService.sendOtpSms(
                    user.getPhone(),
                    otp
            );

            System.out.println(
                    "PASSWORD RESET OTP GENERATED FOR PHONE"
            );

            System.out.println(
                    "================================="
            );

            return "OTP sent to your phone.";
        }
    }


    // =====================================================
    // FORGOT PASSWORD - VERIFY OTP
    // =====================================================

    public String verifyForgotPasswordOtp(
            VerifyForgotPasswordOtpRequest request
    ) {

        if (request == null ||
                request.getIdentifier() == null ||
                request.getIdentifier().trim().isEmpty()) {

            throw new RuntimeException(
                    "EMAIL_OR_PHONE_REQUIRED"
            );
        }

        if (request.getOtp() == null ||
                request.getOtp().trim().isEmpty()) {

            throw new RuntimeException(
                    "OTP_REQUIRED"
            );
        }


        String identifier =
                request.getIdentifier().trim();

        String otp =
                request.getOtp().trim();


        // =================================================
        // FIND LATEST RESET OTP
        // =================================================

        PasswordResetVerification verification =
                passwordResetVerificationRepository
                        .findTopByIdentifierOrderByCreatedAtDesc(
                                identifier
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "PASSWORD_RESET_OTP_NOT_FOUND"
                                )
                        );


        // =================================================
        // CHECK ALREADY VERIFIED
        // =================================================

        if (Boolean.TRUE.equals(
                verification.getVerified()
        )) {

            return "OTP already verified.";
        }


        // =================================================
        // CHECK OTP
        // =================================================

        if (!verification.getOtp().equals(otp)) {

            throw new RuntimeException(
                    "INVALID_PASSWORD_RESET_OTP"
            );
        }


        // =================================================
        // CHECK EXPIRY
        // =================================================

        if (LocalDateTime.now().isAfter(
                verification.getExpiresAt()
        )) {

            throw new RuntimeException(
                    "PASSWORD_RESET_OTP_EXPIRED"
            );
        }


        // =================================================
        // MARK OTP VERIFIED
        // =================================================

        verification.setVerified(true);

        passwordResetVerificationRepository.save(
                verification
        );


        System.out.println(
                "PASSWORD RESET OTP VERIFIED"
        );


        return "OTP verified successfully.";
    }


    // =====================================================
    // FORGOT PASSWORD - RESET PASSWORD
    // =====================================================

    public String resetPassword(
            ResetPasswordRequest request
    ) {

        if (request == null ||
                request.getIdentifier() == null ||
                request.getIdentifier().trim().isEmpty()) {

            throw new RuntimeException(
                    "EMAIL_OR_PHONE_REQUIRED"
            );
        }

        if (request.getNewPassword() == null ||
                request.getNewPassword().trim().isEmpty()) {

            throw new RuntimeException(
                    "NEW_PASSWORD_REQUIRED"
            );
        }


        String identifier =
                request.getIdentifier().trim();


        // =================================================
        // FIND LATEST RESET VERIFICATION
        // =================================================

        PasswordResetVerification verification =
                passwordResetVerificationRepository
                        .findTopByIdentifierOrderByCreatedAtDesc(
                                identifier
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "PASSWORD_RESET_OTP_NOT_FOUND"
                                )
                        );


        // =================================================
        // OTP MUST BE VERIFIED
        // =================================================

        if (!Boolean.TRUE.equals(
                verification.getVerified()
        )) {

            throw new RuntimeException(
                    "OTP_NOT_VERIFIED"
            );
        }


        // =================================================
        // CHECK EXPIRY
        // =================================================

        if (LocalDateTime.now().isAfter(
                verification.getExpiresAt()
        )) {

            throw new RuntimeException(
                    "PASSWORD_RESET_OTP_EXPIRED"
            );
        }


        // =================================================
        // FIND USER
        // =================================================

        User user;

        if (identifier.contains("@")) {

            user = userRepository
                    .findByEmail(identifier)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "USER_NOT_FOUND"
                            )
                    );

        } else {

            user = userRepository
                    .findByPhone(identifier)
                    .orElseThrow(() ->
                            new RuntimeException(
                                    "USER_NOT_FOUND"
                            )
                    );
        }


        // =================================================
        // ENCRYPT NEW PASSWORD
        // =================================================

        String encryptedPassword =
                passwordEncoder.encode(
                        request.getNewPassword()
                );

        user.setPassword(
                encryptedPassword
        );


        // =================================================
        // SAVE USER
        // =================================================

        userRepository.save(user);


        // =================================================
        // CONSUME OTP
        // =================================================

        verification.setVerified(false);

        passwordResetVerificationRepository.save(
                verification
        );


        System.out.println(
                "PASSWORD RESET SUCCESSFUL"
        );


        return "Password reset successfully.";
    }


    // =====================================================
    // ACTIVATE USER
    //
    // PHONE IS ALWAYS REQUIRED.
    // EMAIL IS REQUIRED ONLY WHEN PROVIDED.
    // =====================================================

    private void activateUserIfVerified(
            User user
    ) {

        // =================================================
        // CHECK PHONE VERIFICATION
        // =================================================

        PhoneVerification phoneVerification =
                phoneVerificationRepository
                        .findTopByUserIdOrderByCreatedAtDesc(
                                user.getId()
                        )
                        .orElse(null);


        boolean phoneVerified =
                phoneVerification != null &&
                        Boolean.TRUE.equals(
                                phoneVerification.getVerified()
                        );


        // =================================================
        // CHECK EMAIL VERIFICATION
        //
        // If email is not provided,
        // email verification is automatically considered
        // satisfied.
        // =================================================

        boolean emailVerified = true;

        if (user.getEmail() != null &&
                !user.getEmail().trim().isEmpty()) {

            EmailVerification emailVerification =
                    emailVerificationRepository
                            .findTopByUserIdOrderByCreatedAtDesc(
                                    user.getId()
                            )
                            .orElse(null);


            emailVerified =
                    emailVerification != null &&
                            Boolean.TRUE.equals(
                                    emailVerification.getVerified()
                            );
        }


        // =================================================
        // DEBUG
        // =================================================

        System.out.println(
                "EMAIL PROVIDED: " +
                        (user.getEmail() != null)
        );

        System.out.println(
                "EMAIL VERIFIED: " +
                        emailVerified
        );

        System.out.println(
                "PHONE VERIFIED: " +
                        phoneVerified
        );


        // =================================================
        // ACTIVATE ACCOUNT
        // =================================================

        if (phoneVerified && emailVerified) {

            user.setAccountStatus(
                    "ACTIVE"
            );

            userRepository.save(user);


            System.out.println(
                    "================================="
            );

            System.out.println(
                    "ACCOUNT ACTIVATED"
            );

            System.out.println(
                    "USER: " +
                            user.getName()
            );

            System.out.println(
                    "EMAIL: " +
                            user.getEmail()
            );

            System.out.println(
                    "PHONE: " +
                            user.getPhone()
            );

            System.out.println(
                    "================================="
            );
        }
    }


    // =====================================================
    // GENERATE OTP
    // =====================================================

    private String generateOtp() {

        return String.format(
                "%06d",
                new Random().nextInt(1000000)
        );
    }
}