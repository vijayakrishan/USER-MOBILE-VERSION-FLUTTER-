package com.lora.user.repository;

import com.lora.user.entity.UserProfile;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

@Repository
public class UserProfileRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserProfileRepository(
            JdbcTemplate jdbcTemplate) {

        this.jdbcTemplate = jdbcTemplate;
    }

    private static final String SELECT_BASE = """
        SELECT
            id,
            email,
            name,
            phone,
            date_of_birth,
            gender,
            address,
            emergency_contact_name,
            emergency_contact_number,
            relationship,
            medical_information,
            designation,
            team_id,
            team_name,
            base_station
        FROM auth_db.users_auth
        """;

    private UserProfile mapRow(ResultSet rs) throws SQLException {
        UserProfile profile = new UserProfile();
        profile.setId(rs.getString("id"));
        profile.setEmail(rs.getString("email"));
        profile.setFullName(rs.getString("name"));
        profile.setPhone(rs.getString("phone"));
        profile.setDateOfBirth(rs.getString("date_of_birth"));
        profile.setGender(rs.getString("gender"));
        profile.setAddress(rs.getString("address"));
        profile.setEmergencyContactName(rs.getString("emergency_contact_name"));
        profile.setEmergencyContactNumber(rs.getString("emergency_contact_number"));
        profile.setRelationship(rs.getString("relationship"));
        profile.setMedicalInformation(rs.getString("medical_information"));
        profile.setDesignation(rs.getString("designation"));
        profile.setTeamId(rs.getString("team_id"));
        profile.setTeamName(rs.getString("team_name"));
        profile.setBaseStation(rs.getString("base_station"));
        return profile;
    }

    // =====================================================
    // GET PROFILE BY EMAIL
    // =====================================================

    public Optional<UserProfile> findByEmail(String email) {
        String sql = SELECT_BASE + " WHERE email = ? LIMIT 1";

        return jdbcTemplate.query(
                sql,
                rs -> {
                    if (!rs.next()) {
                        return Optional.empty();
                    }
                    return Optional.of(mapRow(rs));
                },
                email
        );
    }

    // =====================================================
    // GET PROFILE BY USER ID (UUID)
    // =====================================================

    public Optional<UserProfile> findById(String id) {
        String sql = SELECT_BASE + " WHERE id = ? LIMIT 1";

        return jdbcTemplate.query(
                sql,
                rs -> {
                    if (!rs.next()) {
                        return Optional.empty();
                    }
                    return Optional.of(mapRow(rs));
                },
                id
        );
    }

    // =====================================================
    // UPDATE PROFILE
    // =====================================================

    public UserProfile save(UserProfile profile) {

        // Try updating by ID first if present
        if (profile.getId() != null && !profile.getId().trim().isEmpty()) {
            String sql = """
                UPDATE auth_db.users_auth
                SET
                    name = ?,
                    phone = ?,
                    date_of_birth = ?,
                    gender = ?,
                    address = ?,
                    emergency_contact_name = ?,
                    emergency_contact_number = ?,
                    relationship = ?,
                    medical_information = ?
                WHERE id = ?
                """;

            int rows = jdbcTemplate.update(
                    sql,
                    profile.getFullName(),
                    profile.getPhone(),
                    profile.getDateOfBirth(),
                    profile.getGender(),
                    profile.getAddress(),
                    profile.getEmergencyContactName(),
                    profile.getEmergencyContactNumber(),
                    profile.getRelationship(),
                    profile.getMedicalInformation(),
                    profile.getId()
            );

            if (rows > 0) {
                return findById(profile.getId()).orElse(profile);
            }
        }

        // Fallback: update by email
        if (profile.getEmail() != null && !profile.getEmail().trim().isEmpty()) {
            String sql = """
                UPDATE auth_db.users_auth
                SET
                    name = ?,
                    phone = ?,
                    date_of_birth = ?,
                    gender = ?,
                    address = ?,
                    emergency_contact_name = ?,
                    emergency_contact_number = ?,
                    relationship = ?,
                    medical_information = ?
                WHERE email = ?
                """;

            int rows = jdbcTemplate.update(
                    sql,
                    profile.getFullName(),
                    profile.getPhone(),
                    profile.getDateOfBirth(),
                    profile.getGender(),
                    profile.getAddress(),
                    profile.getEmergencyContactName(),
                    profile.getEmergencyContactNumber(),
                    profile.getRelationship(),
                    profile.getMedicalInformation(),
                    profile.getEmail()
            );

            if (rows > 0) {
                return findByEmail(profile.getEmail()).orElse(profile);
            }
        }

        throw new RuntimeException("PROFILE_UPDATE_FAILED: Neither ID nor Email matched");
    }
}