package com.lora.auth.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
public class TeamDataSourceConfig {

    @Value("${spring.datasource.username:root}")
    private String dbUsername;

    @Value("${spring.datasource.password:root}")
    private String dbPassword;

    @Value("${DB_HOST:localhost}")
    private String dbHost;

    @Value("${DB_PORT:3306}")
    private String dbPort;

    // =====================================================
    // AUTH DATABASE
    // =====================================================

    @Bean(name = "authDataSource")
    @Primary
    public DataSource authDataSource() {

        return DataSourceBuilder
                .create()
                .url(
                        "jdbc:mysql://" + dbHost + ":" + dbPort + "/auth_db" +
                                "?useSSL=false" +
                                "&serverTimezone=Asia/Kolkata" +
                                "&allowPublicKeyRetrieval=true"
                )
                .username(dbUsername)
                .password(dbPassword)
                .driverClassName("com.mysql.cj.jdbc.Driver")
                .build();
    }


    // =====================================================
    // TEAM DATABASE
    // =====================================================

    @Bean(name = "teamDataSource")
    public DataSource teamDataSource() {

        return DataSourceBuilder
                .create()
                .url(
                        "jdbc:mysql://" + dbHost + ":" + dbPort + "/team_db" +
                                "?useSSL=false" +
                                "&serverTimezone=Asia/Kolkata" +
                                "&allowPublicKeyRetrieval=true"
                )
                .username(dbUsername)
                .password(dbPassword)
                .driverClassName("com.mysql.cj.jdbc.Driver")
                .build();
    }


    // =====================================================
    // TEAM JDBC TEMPLATE
    // =====================================================

    @Bean(name = "teamJdbcTemplate")
    public JdbcTemplate teamJdbcTemplate(
            @Qualifier("teamDataSource")
            DataSource dataSource) {

        return new JdbcTemplate(dataSource);
    }
}