package com.lora.user.service;

import com.lora.user.entity.UserProfile;
import com.lora.user.repository.UserProfileRepository;

import org.springframework.stereotype.Service;

@Service
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;

    public UserProfileService(UserProfileRepository userProfileRepository) {
        this.userProfileRepository = userProfileRepository;
    }

    // =====================================================
    // GET PROFILE (By Email or User UUID)
    // =====================================================

    public UserProfile getProfile(String identifier) {
        if (identifier.contains("@")) {
            return userProfileRepository
                    .findByEmail(identifier)
                    .orElseThrow(() ->
                            new RuntimeException("User profile not found for email: " + identifier)
                    );
        } else {
            return userProfileRepository
                    .findById(identifier)
                    .or(() -> userProfileRepository.findByEmail(identifier))
                    .orElseThrow(() ->
                            new RuntimeException("User profile not found for identifier: " + identifier)
                    );
        }
    }

    // =====================================================
    // UPDATE PROFILE
    // =====================================================

    public UserProfile updateProfile(String identifier, UserProfile updatedProfile) {
        UserProfile existingProfile = getProfile(identifier);

        // Update fields
        if (updatedProfile.getFullName() != null) {
            existingProfile.setFullName(updatedProfile.getFullName());
        }
        if (updatedProfile.getPhone() != null) {
            existingProfile.setPhone(updatedProfile.getPhone());
        }
        if (updatedProfile.getDateOfBirth() != null) {
            existingProfile.setDateOfBirth(updatedProfile.getDateOfBirth());
        }
        if (updatedProfile.getGender() != null) {
            existingProfile.setGender(updatedProfile.getGender());
        }
        if (updatedProfile.getAddress() != null) {
            existingProfile.setAddress(updatedProfile.getAddress());
        }
        if (updatedProfile.getEmergencyContactName() != null) {
            existingProfile.setEmergencyContactName(updatedProfile.getEmergencyContactName());
        }
        if (updatedProfile.getEmergencyContactNumber() != null) {
            existingProfile.setEmergencyContactNumber(updatedProfile.getEmergencyContactNumber());
        }
        if (updatedProfile.getRelationship() != null) {
            existingProfile.setRelationship(updatedProfile.getRelationship());
        }
        if (updatedProfile.getMedicalInformation() != null) {
            existingProfile.setMedicalInformation(updatedProfile.getMedicalInformation());
        }

        return userProfileRepository.save(existingProfile);
    }
}