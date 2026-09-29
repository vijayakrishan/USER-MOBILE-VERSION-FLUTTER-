package com.lora.auth.service;

import org.springframework.stereotype.Service;

@Service
public class SmsService {

    public void sendOtpSms(String phone, String otp) {

        System.out.println("=================================");
        System.out.println("SMS OTP SERVICE");
        System.out.println("PHONE: " + phone);
        System.out.println("OTP: " + otp);
        System.out.println("=================================");

        // Actual SMS provider integration
        // will be added here later.
    }
}