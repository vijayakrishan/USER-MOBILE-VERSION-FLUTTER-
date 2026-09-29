package com.lora.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private String message;

    private String role;

    private String token;

    private String userId;

    private String name;

    private String email;

    private String phone;

    private String workerId;

    private String teamId;

    private String teamName;
}