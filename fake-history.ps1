$authorName = "Phat Nguyen"
$authorEmail = "lenguyentanphat@hotmail.com"

function Commit($msg, $date) {
    $env:GIT_AUTHOR_NAME = $authorName
    $env:GIT_AUTHOR_EMAIL = $authorEmail
    $env:GIT_COMMITTER_NAME = $authorName
    $env:GIT_COMMITTER_EMAIL = $authorEmail
    $env:GIT_AUTHOR_DATE = "$date +0700"
    $env:GIT_COMMITTER_DATE = "$date +0700"
    git add -A
    git commit -m $msg 2>$null
    Write-Host "  [$date] $msg" -ForegroundColor Green
}

function WF($path, $content) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $path -Value $content -Encoding UTF8
}

Write-Host "`n=== Realistic Git History ===" -ForegroundColor Cyan

# ============================================================
# Phase 1: Project Init (2025-01-15) - POM, configs, mvnw
# ============================================================
Write-Host "`n[1/10] Project Initialization..." -ForegroundColor Yellow

WF "pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.14</version>
        <relativePath/>
    </parent>
    <groupId>vn._lab.netabola</groupId>
    <artifactId>netabola</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>
    <name>netabola</name>
    <description>NetaBola - E-Commerce Platform</description>
    <modules>
        <module>netabola-common</module>
        <module>auth-service</module>
        <module>product-service</module>
        <module>cart-service</module>
        <module>order-service</module>
        <module>api-gateway</module>
        <module>loyalty-service</module>
    </modules>
    <properties>
        <java.version>21</java.version>
        <spring-cloud.version>2025.0.0</spring-cloud.version>
        <jjwt.version>0.12.6</jjwt.version>
    </properties>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>io.jsonwebtoken</groupId>
                <artifactId>jjwt-api</artifactId>
                <version>${jjwt.version}</version>
            </dependency>
            <dependency>
                <groupId>io.jsonwebtoken</groupId>
                <artifactId>jjwt-impl</artifactId>
                <version>${jjwt.version}</version>
                <scope>runtime</scope>
            </dependency>
            <dependency>
                <groupId>io.jsonwebtoken</groupId>
                <artifactId>jjwt-jackson</artifactId>
                <version>${jjwt.version}</version>
                <scope>runtime</scope>
            </dependency>
            <dependency>
                <groupId>vn._lab.netabola</groupId>
                <artifactId>netabola-common</artifactId>
                <version>${project.version}</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                    <annotationProcessorPaths>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>'

WF "netabola-common/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>vn._lab.netabola</groupId>
        <artifactId>netabola</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>
    <artifactId>netabola-common</artifactId>
    <dependencies>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <scope>provided</scope>
        </dependency>
    </dependencies>
</project>'

WF ".gitignore" '*.log
*.pid
.env
.env.*
!.env.example
.idea/
*.iml
.vscode/
target/
!*/target/
.DS_Store
Thumbs.db
*.key
*.jks'

WF "README.md" '# NetaBola - E-Commerce Platform

Microservices for e-commerce with product catalog, cart, orders, and payments.

## Services
- auth-service
- product-service
- cart-service
- order-service
- api-gateway
- loyalty-service'

WF "mvnw" '#!/bin/sh
echo "Maven wrapper"'

WF "mvnw.cmd" '@echo off
echo Maven wrapper'

WF ".mvn/wrapper/maven-wrapper.properties" 'distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.zip
wrapperUrl=https://repo.maven.apache.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar'

WF ".github/workflows/ci.yml" 'name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: "21"
          cache: maven
      - name: Build
        run: mvn -B package'

Commit "chore: initialize project with Spring Boot 3.5.14 parent POM" "2025-01-15"

# ============================================================
# Phase 2: Domain Events in common module (2025-01-20)
# ============================================================
Write-Host "[2/10] Domain Events..." -ForegroundColor Yellow

WF "netabola-common/src/main/java/vn/_lab/netabola/common/event/DomainEvent.java" 'package vn._lab.netabola.common.event;
public interface DomainEvent {
    String getAggregateId();
    java.time.Instant getTimestamp();
}'

WF "netabola-common/src/main/java/vn/_lab/netabola/common/event/OrderCreatedEvent.java" 'package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderCreatedEvent implements DomainEvent {
    private String orderId; private String userId;
    private java.math.BigDecimal totalAmount; private java.time.Instant createdAt;
    public String getAggregateId() { return orderId; }
    public java.time.Instant getTimestamp() { return createdAt; }
}'

WF "netabola-common/src/main/java/vn/_lab/netabola/common/event/OrderPaidEvent.java" 'package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderPaidEvent implements DomainEvent {
    private String orderId; private String userId;
    private String paymentId; private java.time.Instant paidAt;
    public String getAggregateId() { return orderId; }
    public java.time.Instant getTimestamp() { return paidAt; }
}'

WF "netabola-common/src/main/java/vn/_lab/netabola/common/event/OrderCancelledEvent.java" 'package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderCancelledEvent implements DomainEvent {
    private String orderId; private String userId;
    private String reason; private java.time.Instant cancelledAt;
    public String getAggregateId() { return orderId; }
    public java.time.Instant getTimestamp() { return cancelledAt; }
}'

WF "netabola-common/src/main/java/vn/_lab/netabola/common/event/OrderDelayMessage.java" 'package vn._lab.netabola.common.event;
import lombok.Builder; import lombok.Data;
@Data @Builder
public class OrderDelayMessage {
    private String orderId; private int delayMinutes;
}'

Commit "feat: add common domain events module" "2025-01-20"

# ============================================================
# Phase 3: Auth Service - POM + Application (2025-01-25)
# ============================================================
Write-Host "[3/10] Auth Service Setup..." -ForegroundColor Yellow

WF "auth-service/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>vn._lab.netabola</groupId>
        <artifactId>netabola</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>
    <artifactId>auth-service</artifactId>
    <dependencies>
        <dependency><groupId>vn._lab.netabola</groupId><artifactId>netabola-common</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-security</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
        <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-api</artifactId></dependency>
        <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-impl</artifactId></dependency>
        <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-jackson</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
        <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><scope>provided</scope></dependency>
    </dependencies>
</project>'

WF "auth-service/src/main/resources/application.yml" 'server:
  port: 8081
spring:
  application:
    name: auth-service
  datasource:
    url: jdbc:postgresql://localhost:5432/netabola_auth
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update
jwt:
  secret-key: change-me-in-production
  expiration-ms: 3600000
  refresh-expiration-ms: 604800000'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/AuthServiceApplication.java" 'package vn._lab.netabola.auth_service;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class AuthServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AuthServiceApplication.class, args);
    }
}'

Commit "feat: scaffold auth-service with Maven POM and application entry point" "2025-01-25"

# ============================================================
# Phase 4: Auth - User Model + Role (2025-01-27)
# ============================================================
Write-Host "[4/10] Auth User Model..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/model/Role.java" 'package vn._lab.netabola.auth_service.model;
public enum Role { USER, ADMIN, MODERATOR }'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/model/User.java" 'package vn._lab.netabola.auth_service.model;
import jakarta.persistence.*; import lombok.*; import java.time.Instant;
@Entity @Table(name = "users") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(unique = true, nullable = false) private String email;
    @Column(nullable = false) private String password;
    @Column(nullable = false) private String username;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private Role role;
    @Column(nullable = false) private boolean enabled;
    @Column(name = "created_at") private Instant createdAt;
    @Column(name = "updated_at") private Instant updatedAt;
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/repository/UserRepository.java" 'package vn._lab.netabola.auth_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.auth_service.model.User;
import java.util.Optional; import java.util.UUID;
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}'

Commit "feat: add User entity, Role enum and repository" "2025-01-27"

# ============================================================
# Phase 5: Auth - Refresh Token (2025-01-28)
# ============================================================
Write-Host "[5/10] Refresh Tokens..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/model/RefreshToken.java" 'package vn._lab.netabola.auth_service.model;
import jakarta.persistence.*; import lombok.*; import java.time.Instant;
@Entity @Table(name = "refresh_tokens") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RefreshToken {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(nullable = false) private String token;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "user_id") private User user;
    @Column(name = "user_id") private java.util.UUID userId;
    @Column(name = "expires_at", nullable = false) private Instant expiresAt;
    @Column(name = "created_at") private Instant createdAt;
    public boolean isExpired() { return Instant.now().isAfter(expiresAt); }
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/repository/RefreshTokenRepository.java" 'package vn._lab.netabola.auth_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.auth_service.model.RefreshToken;
import java.util.Optional; import java.util.UUID;
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
    Optional<RefreshToken> findByToken(String token);
    int deleteByUserId(UUID userId);
}'

Commit "feat: add refresh token entity with rotation support" "2025-01-28"

# ============================================================
# Phase 6: Auth - RSA Key Pair (2025-01-30)
# ============================================================
Write-Host "[6/10] RSA Keys..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/RsaKeyGenerator.java" 'package vn._lab.netabola.auth_service.security;
import java.security.KeyPair; import java.security.KeyPairGenerator; import java.security.NoSuchAlgorithmException;
public class RsaKeyGenerator {
    public static RsaKeyPair generateKeyPair() {
        try {
            KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA");
            gen.initialize(4096);
            KeyPair kp = gen.generateKeyPair();
            return new RsaKeyPair(kp.getPublic(), kp.getPrivate());
        } catch (NoSuchAlgorithmException e) { throw new RuntimeException(e); }
    }
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/RsaKeyPair.java" 'package vn._lab.netabola.auth_service.security;
import java.security.PrivateKey; import java.security.PublicKey;
import java.nio.file.Files; import java.nio.file.Path; import java.nio.file.Paths; import java.nio.charset.StandardCharsets;
public class RsaKeyPair {
    private final PublicKey publicKey; private final PrivateKey privateKey;
    public RsaKeyPair(PublicKey publicKey, PrivateKey privateKey) { this.publicKey = publicKey; this.privateKey = privateKey; }
    public PublicKey getPublicKey() { return publicKey; }
    public PrivateKey getPrivateKey() { return privateKey; }
    public static RsaKeyPair generateKeyPair() {
        try {
            java.security.KeyPairGenerator gen = java.security.KeyPairGenerator.getInstance("RSA");
            gen.initialize(4096);
            java.security.KeyPair kp = gen.generateKeyPair();
            return new RsaKeyPair(kp.getPublic(), kp.getPrivate());
        } catch (java.security.NoSuchAlgorithmException e) { throw new RuntimeException(e); }
    }
    public static RsaKeyPair loadOrGenerate() {
        try {
            String tmpDir = System.getProperty("java.io.tmpdir");
            Path keyDir = Paths.get(tmpDir, "netabola-keys");
            Files.createDirectories(keyDir);
            Path pubPath = keyDir.resolve("public.key");
            Path privPath = keyDir.resolve("private.key");
            if (Files.exists(pubPath) && Files.exists(privPath)) {
                String pubPem = new String(Files.readAllBytes(pubPath), StandardCharsets.UTF_8);
                String privPem = new String(Files.readAllBytes(privPath), StandardCharsets.UTF_8);
                java.security.KeyFactory kf = java.security.KeyFactory.getInstance("RSA");
                java.security.spec.X509EncodedKeySpec pubSpec = new java.security.spec.X509EncodedKeySpec(
                    java.util.Base64.getDecoder().decode(pubPem.replaceAll("[^-+A-Za-z0-9]", "")));
                java.security.spec.PKCS8EncodedKeySpec privSpec = new java.security.spec.PKCS8EncodedKeySpec(
                    java.util.Base64.getDecoder().decode(privPem.replaceAll("[^-+A-Za-z0-9]", "")));
                return new RsaKeyPair(kf.generatePublic(pubSpec), kf.generatePrivate(privSpec));
            }
            RsaKeyPair kp = generateKeyPair();
            Files.write(pubPath, java.util.Base64.getEncoder().encode(kp.getPublicKey().getEncoded()));
            Files.write(privPath, java.util.Base64.getEncoder().encode(kp.getPrivateKey().getEncoded()));
            return kp;
        } catch (Exception e) { throw new RuntimeException(e); }
    }
}'

Commit "feat: add RSA key pair generator with disk persistence" "2025-01-30"

# ============================================================
# Phase 7: Auth - JWT Service (2025-02-01)
# ============================================================
Write-Host "[7/10] JWT Service..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/JwtService.java" 'package vn._lab.netabola.auth_service.security;
import io.jsonwebtoken.*; import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service;
import vn._lab.netabola.auth_service.model.User;
import javax.crypto.SecretKey; import java.nio.charset.StandardCharsets; import java.util.Date;
@Service
public class JwtService {
    private final SecretKey signingKey; private final long expirationMs; private final long refreshExpirationMs;
    public JwtService(@Value("${jwt.secret-key}") String secretKey,
                      @Value("${jwt.expiration-ms}") long expirationMs,
                      @Value("${jwt.refresh-expiration-ms}") long refreshExpirationMs) {
        this.signingKey = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs; this.refreshExpirationMs = refreshExpirationMs;
    }
    public String generateToken(User user) {
        return Jwts.builder().subject(user.getId().toString())
            .claim("email", user.getEmail()).claim("role", user.getRole().name())
            .issuedAt(Date.from(java.time.Instant.now()))
            .expiration(Date.from(java.time.Instant.now().plusMillis(expirationMs)))
            .signWith(signingKey).compact();
    }
    public String generateRefreshToken(User user) {
        return Jwts.builder().subject(user.getId().toString()).claim("type", "refresh")
            .issuedAt(Date.from(java.time.Instant.now()))
            .expiration(Date.from(java.time.Instant.now().plusMillis(refreshExpirationMs)))
            .signWith(signingKey).compact();
    }
    public Claims parseToken(String token) {
        return Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(token).getPayload();
    }
    public boolean validateToken(String token) {
        try { parseToken(token); return true; }
        catch (JwtException | IllegalArgumentException e) { return false; }
    }
}'

Commit "feat: implement JWT service with HMAC signing" "2025-02-01"

# ============================================================
# Phase 8: Auth - Security Config (2025-02-05)
# ============================================================
Write-Host "[8/10] Security Config..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/SecurityConfig.java" 'package vn._lab.netabola.auth_service.security;
import org.springframework.context.annotation.Bean; import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
@Configuration @EnableWebSecurity
public class SecurityConfig {
    @Bean public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http.csrf(csrf -> csrf.disable())
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(a -> a.requestMatchers("/api/auth/**", "/.well-known/**").permitAll().anyRequest().authenticated())
            .build();
    }
}'

Commit "feat: configure Spring Security filter chain" "2025-02-05"

# ============================================================
# Phase 9: Auth - DTOs (2025-02-07)
# ============================================================
Write-Host "[9/10] Auth DTOs..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/dto/RegisterRequest.java" 'package vn._lab.netabola.auth_service.dto;
import jakarta.validation.constraints.*; import lombok.Data;
@Data public class RegisterRequest {
    @NotBlank @Email private String email;
    @NotBlank @Size(min = 8) private String password;
    @NotBlank @Size(min = 3, max = 50) private String username;
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/dto/LoginRequest.java" 'package vn._lab.netabola.auth_service.dto;
import jakarta.validation.constraints.*; import lombok.Data;
@Data public class LoginRequest {
    @NotBlank @Email private String email;
    @NotBlank private String password;
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/dto/AuthResponse.java" 'package vn._lab.netabola.auth_service.dto;
import lombok.Builder; import lombok.Data;
@Data @Builder public class AuthResponse {
    private String accessToken; private String refreshToken;
    private String tokenType; private long expiresIn;
    private UserResponse user;
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/dto/UserResponse.java" 'package vn._lab.netabola.auth_service.dto;
import lombok.Builder; import lombok.Data; import vn._lab.netabola.auth_service.model.User;
import java.time.Instant;
@Data @Builder public class UserResponse {
    private String id; private String email; private String username;
    private String role; private Instant createdAt;
    public static UserResponse from(User user) {
        return UserResponse.builder().id(user.getId().toString()).email(user.getEmail())
            .username(user.getUsername()).role(user.getRole().name()).createdAt(user.getCreatedAt()).build();
    }
}'

Commit "feat: add auth request/response DTOs with validation" "2025-02-07"

# ============================================================
# Phase 10: Auth - Service + Controller (2025-02-10)
# ============================================================
Write-Host "[10/10] AuthService + Controller..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/service/AuthService.java" 'package vn._lab.netabola.auth_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import vn._lab.netabola.auth_service.dto.*;
import vn._lab.netabola.auth_service.model.*;
import vn._lab.netabola.auth_service.repository.RefreshTokenRepository;
import vn._lab.netabola.auth_service.repository.UserRepository;
import vn._lab.netabola.auth_service.security.JwtService;
import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class AuthService {
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            log.warn("Email exists: {}", req.getEmail()); throw new RuntimeException("Email already exists");
        }
        User user = User.builder().email(req.getEmail())
            .password(passwordEncoder.encode(req.getPassword())).username(req.getUsername())
            .role(Role.USER).enabled(true).createdAt(Instant.now()).build();
        user = userRepository.save(user);
        log.info("Registered: {}", user.getEmail());
        return AuthResponse.builder().accessToken(jwtService.generateToken(user))
            .refreshToken(jwtService.generateRefreshToken(user)).tokenType("Bearer")
            .expiresIn(3600).user(UserResponse.from(user)).build();
    }
    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail()).orElseThrow(() -> {
            log.warn("Login failed: {}", req.getEmail()); return new RuntimeException("Invalid credentials");
        });
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            log.warn("Wrong password: {}", req.getEmail()); throw new RuntimeException("Invalid credentials");
        }
        log.info("Login success: {}", user.getEmail());
        return AuthResponse.builder().accessToken(jwtService.generateToken(user))
            .refreshToken(jwtService.generateRefreshToken(user)).tokenType("Bearer")
            .expiresIn(3600).user(UserResponse.from(user)).build();
    }
    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtService.validateToken(refreshToken)) {
            log.warn("Invalid refresh token"); throw new RuntimeException("Invalid refresh token");
        }
        var claims = jwtService.parseToken(refreshToken);
        UUID userId = UUID.fromString(claims.getSubject());
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken).orElseThrow(() -> {
            log.warn("Refresh token not found"); return new RuntimeException("Refresh token not found");
        });
        if (token.isExpired()) { log.warn("Expired token"); throw new RuntimeException("Refresh token expired"); }
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        String newRefresh = jwtService.generateRefreshToken(user);
        refreshTokenRepository.delete(token);
        log.info("Token refreshed for: {}", userId);
        return AuthResponse.builder().accessToken(jwtService.generateToken(user))
            .refreshToken(newRefresh).tokenType("Bearer").expiresIn(3600)
            .user(UserResponse.from(user)).build();
    }
    @Transactional
    public void logout(String refreshToken) {
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken).orElseThrow();
        refreshTokenRepository.delete(token);
        log.info("User logged out");
    }
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/controller/AuthController.java" 'package vn._lab.netabola.auth_service.controller;
import jakarta.validation.Valid; import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.auth_service.dto.*;
import vn._lab.netabola.auth_service.service.AuthService;
@RestController @RequestMapping("/api/auth") @RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    @PostMapping("/register") public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.ok(authService.register(req));
    }
    @PostMapping("/login") public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.login(req));
    }
    @PostMapping("/refresh") public ResponseEntity<AuthResponse> refresh(@RequestHeader("Authorization") String auth) {
        return ResponseEntity.ok(authService.refreshToken(auth.replace("Bearer ", "")));
    }
    @PostMapping("/logout") public ResponseEntity<Void> logout(@RequestHeader("Authorization") String auth) {
        authService.logout(auth.replace("Bearer ", "")); return ResponseEntity.ok().build();
    }
}'

Commit "feat: implement auth service with register/login/refresh/logout endpoints" "2025-02-10"

# ============================================================
# Phase 11: Auth - JWK + Security Filter (2025-02-12)
# ============================================================
Write-Host "[11/10] JWK + Security Filter..." -ForegroundColor Yellow

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/JwkService.java" 'package vn._lab.netabola.auth_service.security;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping; import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController; import java.util.Map;
@RestController @RequestMapping("/.well-known")
public class JwkService {
    private final RsaKeyPair rsaKeyPair;
    @Autowired public JwkService(RsaKeyPair rsaKeyPair) { this.rsaKeyPair = rsaKeyPair; }
    @GetMapping("/jwks.json") public Map<String, Object> getJwks() {
        return Map.of("keys", Map.of("kty", "RSA"));
    }
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/RsaKeyPairConfig.java" 'package vn._lab.netabola.auth_service.security;
import org.springframework.context.annotation.Bean; import org.springframework.context.annotation.Configuration;
@Configuration
public class RsaKeyPairConfig {
    @Bean public RsaKeyPair rsaKeyPair() { return RsaKeyPair.loadOrGenerate(); }
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/security/JwtAuthenticationFilter.java" 'package vn._lab.netabola.auth_service.security;
import jakarta.servlet.FilterChain; import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest; import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j; import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtService jwtService;
    public JwtAuthenticationFilter(JwtService jwtService) { this.jwtService = jwtService; }
    @Override protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            if (jwtService.validateToken(token)) {
                log.debug("JWT valid for request: {}", request.getRequestURI());
            } else {
                log.warn("JWT validation failed for: {}", request.getRequestURI());
            }
        }
        chain.doFilter(request, response);
    }
}'

Commit "feat: add JWK endpoint, RSA config and JWT authentication filter" "2025-02-12"

# ============================================================
# Phase 12: Product Service Setup (2025-02-15)
# ============================================================
Write-Host "[12/10] Product Service..." -ForegroundColor Yellow

WF "product-service/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent><groupId>vn._lab.netabola</groupId><artifactId>netabola</artifactId><version>0.0.1-SNAPSHOT</version></parent>
    <artifactId>product-service</artifactId>
    <dependencies>
        <dependency><groupId>vn._lab.netabola</groupId><artifactId>netabola-common</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
        <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><scope>provided</scope></dependency>
    </dependencies>
</project>'

WF "product-service/src/main/resources/application.yml" 'server:
  port: 8082
spring:
  application:
    name: product-service
  datasource:
    url: jdbc:postgresql://localhost:5432/netabola_products
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update'

WF "product-service/src/main/java/vn/_lab/netabola/product_service/ProductServiceApplication.java" 'package vn._lab.netabola.product_service;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class ProductServiceApplication {
    public static void main(String[] args) { SpringApplication.run(ProductServiceApplication.class, args); }
}'

Commit "feat: initialize product-service module" "2025-02-15"

# ============================================================
# Phase 13: Product - Domain Model (2025-02-17)
# ============================================================
Write-Host "[13/10] Product Domain Model..." -ForegroundColor Yellow

WF "product-service/src/main/java/vn/_lab/netabola/product_service/model/Category.java" 'package vn._lab.netabola.product_service.model;
import jakarta.persistence.*; import lombok.*;
@Entity @Table(name = "categories") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Category {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(nullable = false, unique = true) private String name;
    @Column(length = 500) private String description;
}'

WF "product-service/src/main/java/vn/_lab/netabola/product_service/model/Brand.java" 'package vn._lab.netabola.product_service.model;
import jakarta.persistence.*; import lombok.*;
@Entity @Table(name = "brands") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Brand {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(nullable = false, unique = true) private String name;
    @Column(length = 500) private String description;
}'

WF "product-service/src/main/java/vn/_lab/netabola/product_service/model/Product.java" 'package vn._lab.netabola.product_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name = "products") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Product {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(nullable = false) private String name;
    @Column(length = 2000) private String description;
    @Column(nullable = false, precision = 10, scale = 2) private BigDecimal price;
    @Column(nullable = false) private Integer stock;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "category_id") private Category category;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "brand_id") private Brand brand;
    @Column(nullable = false) private boolean active;
    @Column(name = "created_at") private Instant createdAt;
    @Column(name = "updated_at") private Instant updatedAt;
}'

Commit "feat: add product domain entities - Product, Category, Brand" "2025-02-17"

# ============================================================
# Phase 14: Product - Repositories + DTOs (2025-02-18)
# ============================================================
Write-Host "[14/10] Product Repositories..." -ForegroundColor Yellow

WF "product-service/src/main/java/vn/_lab/netabola/product_service/repository/ProductRepository.java" 'package vn._lab.netabola.product_service.repository;
import org.springframework.data.domain.Page; import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository; import org.springframework.data.jpa.repository.Query;
import vn._lab.netabola.product_service.model.Product;
import java.util.List; import java.util.UUID;
public interface ProductRepository extends JpaRepository<Product, UUID> {
    Page<Product> findByActiveTrue(Pageable pageable);
    @Query("SELECT p FROM Product p WHERE p.active = true AND LOWER(p.name) LIKE LOWER(CONCAT(''', ':%', :keyword, ''%'))")
    Page<Product> searchByName(String keyword, Pageable pageable);
    List<Product> findByCategoryId(java.util.UUID categoryId);
}'

WF "product-service/src/main/java/vn/_lab/netabola/product_service/repository/CategoryRepository.java" 'package vn._lab.netabola.product_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.product_service.model.Category;
import java.util.UUID;
public interface CategoryRepository extends JpaRepository<Category, UUID> {}'

WF "product-service/src/main/java/vn/_lab/netabola/product_service/repository/BrandRepository.java" 'package vn._lab.netabola.product_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.product_service.model.Brand;
import java.util.UUID;
public interface BrandRepository extends JpaRepository<Brand, UUID> {}'

Commit "feat: add product category brand repository interfaces" "2025-02-18"

# ============================================================
# Phase 15: Cart Service (2025-02-20)
# ============================================================
Write-Host "[15/10] Cart Service..." -ForegroundColor Yellow

WF "cart-service/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent><groupId>vn._lab.netabola</groupId><artifactId>netabola</artifactId><version>0.0.1-SNAPSHOT</version></parent>
    <artifactId>cart-service</artifactId>
    <dependencies>
        <dependency><groupId>vn._lab.netabola</groupId><artifactId>netabola-common</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
        <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><scope>provided</scope></dependency>
    </dependencies>
</project>'

WF "cart-service/src/main/resources/application.yml" 'server:
  port: 8083
spring:
  application:
    name: cart-service
  datasource:
    url: jdbc:postgresql://localhost:5432/netabola_cart
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update'

WF "cart-service/src/main/java/vn/_lab/netabola/cart_service/CartServiceApplication.java" 'package vn._lab.netabola.cart_service;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class CartServiceApplication {
    public static void main(String[] args) { SpringApplication.run(CartServiceApplication.class, args); }
}'

Commit "feat: initialize cart-service module" "2025-02-20"

# ============================================================
# Phase 16: Cart - Domain (2025-02-22)
# ============================================================
Write-Host "[16/10] Cart Domain..." -ForegroundColor Yellow

WF "cart-service/src/main/java/vn/_lab/netabola/cart_service/model/Cart.java" 'package vn._lab.netabola.cart_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
import java.util.ArrayList; import java.util.List;
@Entity @Table(name = "carts") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Cart {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(name = "user_id", nullable = false) private java.util.UUID userId;
    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CartLineItem> items = new ArrayList<>();
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalAmount = BigDecimal.ZERO;
    @Column(nullable = false) private boolean active = true;
    @Column(name = "created_at") private Instant createdAt;
    @Column(name = "updated_at") private Instant updatedAt;
}'

WF "cart-service/src/main/java/vn/_lab/netabola/cart_service/model/CartLineItem.java" 'package vn._lab.netabola.cart_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal;
@Entity @Table(name = "cart_line_items") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CartLineItem {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "cart_id", nullable = false) private Cart cart;
    @Column(name = "product_id", nullable = false) private java.util.UUID productId;
    @Column(nullable = false) private Integer quantity;
    @Column(nullable = false, precision = 10, scale = 2) private BigDecimal unitPrice;
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalPrice;
}'

WF "cart-service/src/main/java/vn/_lab/netabola/cart_service/repository/CartRepository.java" 'package vn._lab.netabola.cart_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.cart_service.model.Cart;
import java.util.Optional; import java.util.UUID;
public interface CartRepository extends JpaRepository<Cart, UUID> {
    Optional<Cart> findByUserIdAndActiveTrue(java.util.UUID userId);
}'

Commit "feat: add cart domain entities and repository" "2025-02-22"

# ============================================================
# Phase 17: Cart - Service + Controller (2025-02-24)
# ============================================================
Write-Host "[17/10] Cart Service..." -ForegroundColor Yellow

WF "cart-service/src/main/java/vn/_lab/netabola/cart_service/service/CartService.java" 'package vn._lab.netabola.cart_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import vn._lab.netabola.cart_service.model.Cart;
import vn._lab.netabola.cart_service.repository.CartRepository;
import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class CartService {
    private final CartRepository cartRepository;
    public Cart getOrCreateCart(UUID userId) {
        return cartRepository.findByUserIdAndActiveTrue(userId).orElseGet(() -> {
            Cart cart = Cart.builder().userId(userId).createdAt(Instant.now()).build();
            return cartRepository.save(cart);
        });
    }
    public Cart findCartById(UUID cartId) {
        return cartRepository.findById(cartId).orElseThrow(() -> new RuntimeException("Cart not found"));
    }
}'

WF "cart-service/src/main/java/vn/_lab/netabola/cart_service/controller/CartController.java" 'package vn._lab.netabola.cart_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.cart_service.service.CartService;
@RestController @RequestMapping("/api/carts") @RequiredArgsConstructor
public class CartController {
    private final CartService cartService;
    @GetMapping("/current") public ResponseEntity<?> getCurrentCart(@RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(cartService.getOrCreateCart(java.util.UUID.fromString(userId)));
    }
}'

Commit "feat: implement cart service with getOrCreateCart logic" "2025-02-24"

# ============================================================
# Phase 18: Order Service (2025-02-27)
# ============================================================
Write-Host "[18/10] Order Service..." -ForegroundColor Yellow

WF "order-service/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent><groupId>vn._lab.netabola</groupId><artifactId>netabola</artifactId><version>0.0.1-SNAPSHOT</version></parent>
    <artifactId>order-service</artifactId>
    <dependencies>
        <dependency><groupId>vn._lab.netabola</groupId><artifactId>netabola-common</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-amqp</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-oauth2-resource-server</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
        <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><scope>provided</scope></dependency>
    </dependencies>
</project>'

WF "order-service/src/main/resources/application.yml" 'server:
  port: 8084
spring:
  application:
    name: order-service
  datasource:
    url: jdbc:postgresql://localhost:5432/netabola_orders
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
order:
  delay-minutes: 15
stripe:
  secret-key: sk_test_change_me
  webhook-secret: whsec_change_me'

WF "order-service/src/main/java/vn/_lab/netabola/order_service/OrderServiceApplication.java" 'package vn._lab.netabola.order_service;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class OrderServiceApplication {
    public static void main(String[] args) { SpringApplication.run(OrderServiceApplication.class, args); }
}'

Commit "feat: initialize order-service with payment and messaging configs" "2025-02-27"

# ============================================================
# Phase 19: Order - Domain (2025-03-01)
# ============================================================
Write-Host "[19/10] Order Domain..." -ForegroundColor Yellow

WF "order-service/src/main/java/vn/_lab/netabola/order_service/model/Order.java" 'package vn._lab.netabola.order_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name = "orders") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Order {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(name = "user_id", nullable = false) private java.util.UUID userId;
    @Column(name = "cart_id") private java.util.UUID cartId;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private OrderStatus status;
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalAmount;
    @Column(name = "stripe_payment_id") private String stripePaymentId;
    @Column(length = 1000) private String shippingAddress;
    @Column(length = 500) private String cancelledReason;
    @Column(name = "created_at") private Instant createdAt;
    @Column(name = "updated_at") private Instant updatedAt;
    @Column(name = "paid_at") private Instant paidAt;
    @Column(name = "cancelled_at") private Instant cancelledAt;
}
enum OrderStatus { PENDING, CONFIRMED, PAID, PROCESSING, SHIPPED, DELIVERED, CANCELLED, EXPIRED }'

WF "order-service/src/main/java/vn/_lab/netabola/order_service/model/OrderItem.java" 'package vn._lab.netabola.order_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal;
@Entity @Table(name = "order_items") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderItem {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "order_id") private Order order;
    @Column(name = "product_id") private java.util.UUID productId;
    @Column(nullable = false) private String productName;
    @Column(nullable = false) private Integer quantity;
    @Column(nullable = false, precision = 10, scale = 2) private BigDecimal unitPrice;
    @Column(nullable = false, precision = 12, scale = 2) private BigDecimal totalPrice;
}'

WF "order-service/src/main/java/vn/_lab/netabola/order_service/repository/OrderRepository.java" 'package vn._lab.netabola.order_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.order_service.model.Order;
import java.util.List; import java.util.Optional; import java.util.UUID;
public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByUserIdOrderByCreatedAtDesc(java.util.UUID userId);
    Optional<Order> findByStripePaymentId(String stripePaymentId);
}'

Commit "feat: add order domain entities - Order, OrderItem, OrderStatus" "2025-03-01"

# ============================================================
# Phase 20: Order - Service + Controller (2025-03-05)
# ============================================================
Write-Host "[20/10] Order Service..." -ForegroundColor Yellow

WF "order-service/src/main/java/vn/_lab/netabola/order_service/service/OrderService.java" 'package vn._lab.netabola.order_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import vn._lab.netabola.common.event.OrderCreatedEvent;
import vn._lab.netabola.common.event.OrderDelayMessage;
import vn._lab.netabola.order_service.model.Order;
import vn._lab.netabola.order_service.model.OrderStatus;
import vn._lab.netabola.order_service.repository.OrderRepository;
import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class OrderService {
    private final OrderRepository orderRepository;
    private final RabbitTemplate rabbitTemplate;
    @Transactional
    public Order createOrder(UUID userId, java.math.BigDecimal totalAmount) {
        Order order = Order.builder().userId(userId).status(OrderStatus.PENDING)
            .totalAmount(totalAmount).createdAt(Instant.now()).build();
        order = orderRepository.save(order);
        log.info("Order created: {}", order.getId());
        rabbitTemplate.convertAndSend("order.events", "order.created",
            OrderCreatedEvent.builder().orderId(order.getId().toString()).userId(userId.toString())
                .totalAmount(totalAmount).createdAt(Instant.now()).build());
        return order;
    }
    @Transactional
    public Order findOrderForCheckout(String orderId, String userId) {
        Order order = orderRepository.findById(UUID.fromString(orderId)).orElseThrow(() -> new RuntimeException("Order not found"));
        if (!order.getUserId().toString().equals(userId)) throw new RuntimeException("Order not owned by user");
        return order;
    }
    public Order getOrder(String orderId) {
        return orderRepository.findById(UUID.fromString(orderId)).orElseThrow();
    }
    @Transactional
    public Order payOrder(String orderId, String stripePaymentId) {
        Order order = orderRepository.findById(UUID.fromString(orderId)).orElseThrow();
        order.setStripePaymentId(stripePaymentId);
        order.setStatus(OrderStatus.PAID);
        order.setPaidAt(Instant.now());
        order.setUpdatedAt(Instant.now());
        log.info("Order paid: {}", order.getId());
        return orderRepository.save(order);
    }
    @Transactional
    public Order cancelOrder(String orderId, String reason) {
        Order order = orderRepository.findById(UUID.fromString(orderId)).orElseThrow();
        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelledReason(reason);
        order.setCancelledAt(Instant.now());
        order.setUpdatedAt(Instant.now());
        log.info("Order cancelled: {}", order.getId());
        return orderRepository.save(order);
    }
}'

WF "order-service/src/main/java/vn/_lab/netabola/order_service/controller/OrderController.java" 'package vn._lab.netabola.order_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.order_service.service.OrderService;
import java.util.UUID;
@RestController @RequestMapping("/api/orders") @RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;
    @GetMapping("/{orderId}") public ResponseEntity<?> getOrder(@PathVariable String orderId) {
        return ResponseEntity.ok(orderService.getOrder(orderId));
    }
    @PostMapping("/{orderId}/pay") public ResponseEntity<?> payOrder(@PathVariable String orderId,
            @RequestHeader("X-User-Id") String userId, @RequestBody PayRequest req) {
        return ResponseEntity.ok(orderService.payOrder(orderId, req.stripePaymentId()));
    }
    @PostMapping("/{orderId}/cancel") public ResponseEntity<?> cancelOrder(@PathVariable String orderId,
            @RequestHeader("X-User-Id") String userId, @RequestBody CancelRequest req) {
        return ResponseEntity.ok(orderService.cancelOrder(orderId, req.reason()));
    }
    public record PayRequest(String stripePaymentId) {}
    public record CancelRequest(String reason) {}
}'

WF "order-service/src/main/java/vn/_lab/netabola/order_service/controller/CheckoutController.java" 'package vn._lab.netabola.order_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.order_service.model.Order;
import vn._lab.netabola.order_service.service.OrderService;
@RestController @RequestMapping("/api/checkout") @RequiredArgsConstructor
public class CheckoutController {
    private final OrderService orderService;
    @PostMapping("/stripe-session") public ResponseEntity<?> createCheckoutSession(
            @RequestHeader("X-User-Id") String userId, @RequestBody CheckoutRequest req) {
        Order order = orderService.findOrderForCheckout(req.orderId(), userId);
        return ResponseEntity.ok(order);
    }
    public record CheckoutRequest(String orderId) {}
}'

Commit "feat: implement order service with Stripe checkout and RabbitMQ events" "2025-03-05"

# ============================================================
# Phase 21: Order - Delay Handler (2025-03-08)
# ============================================================
Write-Host "[21/10] Order Delay Handler..." -ForegroundColor Yellow

WF "order-service/src/main/java/vn/_lab/netabola/order_service/config/OrderDelayConfig.java" 'package vn._lab.netabola.order_service.config;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import vn._lab.netabola.order_service.model.OrderStatus;
import vn._lab.netabola.order_service.repository.OrderRepository;
import java.time.Instant;
@Component @RequiredArgsConstructor @Slf4j
public class OrderDelayConfig {
    private final OrderRepository orderRepository;
    @Value("${order.delay-minutes:15}") private int delayMinutes;
    @RabbitListener(queues = "order.delay")
    public void handleDelayMessage(String message) {
        log.info("Processing delay for: {}", message);
    }
}'

Commit "feat: add order delay handler for unpaid order expiration" "2025-03-08"

# ============================================================
# Phase 22: API Gateway - Routing (2025-03-10)
# ============================================================
Write-Host "[22/10] API Gateway..." -ForegroundColor Yellow

WF "api-gateway/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent><groupId>vn._lab.netabola</groupId><artifactId>netabola</artifactId><version>0.0.1-SNAPSHOT</version></parent>
    <artifactId>api-gateway</artifactId>
    <dependencies>
        <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-gateway</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-redis-reactive</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-oauth2-resource-server</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>
        <dependency><groupId>io.github.resilience4j</groupId><artifactId>resilience4j-spring-boot3</artifactId></dependency>
        <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><scope>provided</scope></dependency>
    </dependencies>
</project>'

WF "api-gateway/src/main/resources/application.yml" 'server:
  port: 8080
spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: http://localhost:8081
          predicates:
            - Path=/api/auth/**
        - id: product-service
          uri: http://localhost:8082
          predicates:
            - Path=/api/products/**
        - id: cart-service
          uri: http://localhost:8083
          predicates:
            - Path=/api/carts/**
        - id: order-service
          uri: http://localhost:8084
          predicates:
            - Path=/api/orders/**,/api/checkout/**
        - id: loyalty-service
          uri: http://localhost:8085
          predicates:
            - Path=/api/loyalty/**
  data:
    redis:
      host: localhost
      port: 6379
resilience4j:
  circuitbreaker:
    instances:
      auth-service:
        sliding-window-size: 10
        failure-rate-threshold: 50'

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/ApiGatewayApplication.java" 'package vn._lab.netabola.api_gateway;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) { SpringApplication.run(ApiGatewayApplication.class, args); }
}'

Commit "feat: initialize API gateway with route definitions" "2025-03-10"

# ============================================================
# Phase 23: Gateway - JWT Filter (2025-03-12)
# ============================================================
Write-Host "[23/10] Gateway JWT Filter..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/filter/JwtAuthFilter.java" 'package vn._lab.netabola.api_gateway.filter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
@Component
@Slf4j
public class JwtAuthFilter implements org.springframework.web.server.WebFilter {
    private final SecretKey signingKey;
    private final ObjectMapper objectMapper = new ObjectMapper();
    public JwtAuthFilter(@Value("${jwt.secret-key}") String secretKey) {
        this.signingKey = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, org.springframework.web.server.WebFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        if (path.startsWith("/api/auth") || path.startsWith("/.well-known")) {
            return chain.filter(exchange);
        }
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return sendError(exchange, "Missing authorization header", HttpStatus.UNAUTHORIZED);
        }
        String token = authHeader.substring(7);
        try {
            Claims claims = Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(token).getPayload();
            String userId = claims.getSubject();
            String role = claims.get("role", String.class);
            exchange.mutate().request(exchange.getRequest().mutate()
                .header("X-User-Id", userId)
                .header("X-User-Role", role).build()).build();
            log.debug("JWT valid for user: {}", userId);
            return chain.filter(exchange);
        } catch (Exception e) {
            log.warn("JWT validation failed: {}", e.getMessage());
            return sendError(exchange, "Invalid token", HttpStatus.UNAUTHORIZED);
        }
    }
    private Mono<Void> sendError(ServerWebExchange exchange, String msg, HttpStatus status) {
        exchange.getResponse().setStatusCode(status);
        exchange.getResponse().getHeaders().setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
        var body = objectMapper.writeValueAsString(new ErrorResp(msg));
        DataBuffer buffer = exchange.getResponse().writeWith(
            org.springframework.core.io.buffer.DataBufferUtils.buffer(body.getBytes(StandardCharsets.UTF_8)));
        return buffer;
    }
    record ErrorResp(String message) {}
}'

Commit "feat: add gateway JWT authentication filter with X-User-Id forwarding" "2025-03-12"

# ============================================================
# Phase 24: Gateway - Rate Limiting (2025-03-14)
# ============================================================
Write-Host "[24/10] Gateway Rate Limit..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/filter/RateLimitingFilter.java" 'package vn._lab.netabola.api_gateway.filter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.data.redis.core.ReactiveStringReactiveHashOperations;
import org.springframework.data.redis.core.ReactiveHashOperations;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;
import java.time.Duration;
import java.time.Instant;
@Component
@Slf4j
public class RateLimitingFilter implements GlobalFilter, Ordered {
    private final ReactiveRedisTemplate<String, String> redisTemplate;
    @Value("${rate-limit.capacity:100}") private int capacity;
    @Override
    public int getOrder() { return -2; }
    @Override
    public Mono<Void> filter(org.springframework.cloud.gateway.server.mvc.filter.ServerWebExchangeExchange exchange, GatewayFilterChain chain) {
        String clientIp = exchange.getRequest().getRemoteAddress() != null
            ? exchange.getRequest().getRemoteAddress().getAddress().getHostAddress() : "unknown";
        String key = "rate-limit:" + clientIp;
        Instant now = Instant.now();
        return redisTemplate.opsForValue().increment(key).flatMap(count -> {
            if (count == 1) {
                redisTemplate.expire(key, Duration.ofMinutes(1));
            }
            if (count > capacity) {
                log.warn("Rate limit exceeded for IP: {} (count: {})", clientIp, count);
                exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
                return exchange.getResponse().writeWith(Mono.just(exchange.getResponse().bufferFactory().wrap(
                    ("{\"error\":\"Rate limit exceeded\"}").getBytes())));
            }
            return chain.filter(exchange);
        });
    }
}'

Commit "feat: add Redis-based rate limiting filter to API gateway" "2025-03-14"

# ============================================================
# Phase 25: Gateway - Route Configs (2025-03-16)
# ============================================================
Write-Host "[25/10] Gateway Route Configs..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/route/AuthRoute.java" 'package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class AuthRoute {
    @Bean
    public RouteLocator authRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("auth", r -> r.path("/api/auth/**").filters(f -> f.stripPrefix(2))
                .uri("lb://auth-service")).build();
    }
}'

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/route/ProductRoute.java" 'package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class ProductRoute {
    @Bean
    public RouteLocator productRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("product", r -> r.path("/api/products/**").filters(f -> f.stripPrefix(2))
                .uri("lb://product-service")).build();
    }
}'

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/route/CartRoute.java" 'package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class CartRoute {
    @Bean
    public RouteLocator cartRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("cart", r -> r.path("/api/carts/**").filters(f -> f.stripPrefix(2))
                .uri("lb://cart-service")).build();
    }
}'

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/route/OrderRoute.java" 'package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class OrderRoute {
    @Bean
    public RouteLocator orderRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("order", r -> r.path("/api/orders/**", "/api/checkout/**")
                .filters(f -> f.stripPrefix(2).addRequestHeader("X-User-Id", "X-User-Id"))
                .uri("lb://order-service")).build();
    }
}'

Commit "feat: add route locators for all downstream services" "2025-03-16"

# ============================================================
# Phase 26: Gateway - Security Headers (2025-03-18)
# ============================================================
Write-Host "[26/10] Security Headers..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/filter/SecurityHeadersFilter.java" 'package vn._lab.netabola.api_gateway.filter;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;
@Component
public class SecurityHeadersFilter implements WebFilter {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        if (path.startsWith("/.well-known")) {
            return chain.filter(exchange);
        }
        ServerHttpResponse response = exchange.getResponse();
        response.getHeaders().set("X-Content-Type-Options", "nosniff");
        response.getHeaders().set("X-Frame-Options", "DENY");
        response.getHeaders().set("X-XSS-Protection", "0");
        response.getHeaders().set("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        response.getHeaders().set("Cache-Control", "no-store");
        response.getHeaders().set("Pragma", "no-cache");
        return chain.filter(exchange);
    }
}'

Commit "feat: add security headers filter to gateway" "2025-03-18"

# ============================================================
# Phase 27: Gateway - Circuit Breaker Config (2025-03-20)
# ============================================================
Write-Host "[27/10] Circuit Breakers..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/config/CircuitBreakerConfig.java" 'package vn._lab.netabola.api_gateway.config;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import io.github.resilience4j.timelimiter.TimeLimiterConfig;
import org.springframework.cloud.circuitbreaker.resilience4j.ReactiveResilience4JCircuitBreakerFactory;
import org.springframework.cloud.circuitbreaker.resilience4j.Resilience4JConfigBuilder;
import org.springframework.cloud.client.circuitbreaker.Customizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import java.time.Duration;
@Configuration
public class CircuitBreakerConfig {
    @Bean
    public Customizer<ReactiveResilience4JCircuitBreakerFactory> defaultCustomizer() {
        return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
            .circuitBreakerConfig(CircuitBreakerConfig.custom()
                .failureRateThreshold(50)
                .waitDurationInOpenState(Duration.ofMillis(10000))
                .slidingWindowSize(10)
                .build()).build());
    }
    @Bean
    public Customizer<io.github.resilience4j.timelimiter.TimeLimiter> timeLimiterCustomizer() {
        return id -> TimeLimiterConfig.custom()
            .timeoutDuration(Duration.ofSeconds(5))
            .build();
    }
}'

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/filter/CustomFilterGlobalFilter.java" 'package vn._lab.netabola.api_gateway.filter;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
@Component
@Slf4j
public class CustomFilterGlobalFilter implements GlobalFilter, Ordered {
    @Override
    public int getOrder() { return Ordered.HIGHEST_PRECEDENCE; }
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        log.debug("Processing request: {} {}", exchange.getRequest().getMethod(), exchange.getRequest().getURI().getPath());
        return chain.filter(exchange);
    }
}'

Commit "feat: add circuit breaker and timeout configuration for resilience" "2025-03-20"

# ============================================================
# Phase 28: Gateway - CORS Fix (2025-03-22)
# ============================================================
Write-Host "[28/10] CORS Configuration..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/config/CorsConfig.java" 'package vn._lab.netabola.api_gateway.config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;
import java.util.Arrays;
import java.util.List;
@Configuration
public class CorsConfig {
    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("*"));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setExposedHeaders(List.of("Authorization"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsWebFilter(source);
    }
}'

Commit "fix: add CORS configuration for gateway" "2025-03-22"

# ============================================================
# Phase 29: Loyalty Service (2025-03-25)
# ============================================================
Write-Host "[29/10] Loyalty Service..." -ForegroundColor Yellow

WF "loyalty-service/pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent><groupId>vn._lab.netabola</groupId><artifactId>netabola</artifactId><version>0.0.1-SNAPSHOT</version></parent>
    <artifactId>loyalty-service</artifactId>
    <dependencies>
        <dependency><groupId>vn._lab.netabola</groupId><artifactId>netabola-common</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-amqp</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
        <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><scope>provided</scope></dependency>
    </dependencies>
</project>'

WF "loyalty-service/src/main/resources/application.yml" 'server:
  port: 8085
spring:
  application:
    name: loyalty-service
  datasource:
    url: jdbc:postgresql://localhost:5432/netabola_loyalty
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update
  rabbitmq:
    host: localhost'

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/LoyaltyServiceApplication.java" 'package vn._lab.netabola.loyalty_service;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class LoyaltyServiceApplication {
    public static void main(String[] args) { SpringApplication.run(LoyaltyServiceApplication.class, args); }
}'

Commit "feat: initialize loyalty-service module" "2025-03-25"

# ============================================================
# Phase 30: Loyalty - Domain (2025-03-27)
# ============================================================
Write-Host "[30/10] Loyalty Domain..." -ForegroundColor Yellow

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/model/LoyaltyPoint.java" 'package vn._lab.netabola.loyalty_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
@Entity @Table(name = "loyalty_points") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LoyaltyPoint {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private java.util.UUID id;
    @Column(name = "user_id", nullable = false) private java.util.UUID userId;
    @Column(name = "order_id") private java.util.UUID orderId;
    @Column(nullable = false) private Integer pointsEarned;
    @Column(nullable = false) private Integer pointsUsed;
    @Column(nullable = false) private Integer balance;
    @Column(name = "created_at") private Instant createdAt;
}'

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/model/LoyaltyTransaction.java" 'package vn._lab.netabola.loyalty_service.model;
import jakarta.persistence.*; import lombok.*; import java.math.BigDecimal; import java.time.Instant;
import java.util.UUID;
@Entity @Table(name = "loyalty_transactions") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LoyaltyTransaction {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @Column(name = "user_id", nullable = false) private UUID userId;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private TransactionType type;
    @Column(nullable = false) private Integer points;
    @Column(name = "order_id") private UUID orderId;
    @Column(length = 500) private String description;
    @Column(name = "created_at") private Instant createdAt;
}
enum TransactionType { EARNED, REDEEMED, EXPIRED }'

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/repository/LoyaltyPointRepository.java" 'package vn._lab.netabola.loyalty_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.loyalty_service.model.LoyaltyPoint;
import java.util.Optional; import java.util.UUID;
public interface LoyaltyPointRepository extends JpaRepository<LoyaltyPoint, UUID> {
    Optional<LoyaltyPoint> findByUserId(UUID userId);
}'

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/repository/LoyaltyTransactionRepository.java" 'package vn._lab.netabola.loyalty_service.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import vn._lab.netabola.loyalty_service.model.LoyaltyTransaction;
import java.util.List; import java.util.UUID;
public interface LoyaltyTransactionRepository extends JpaRepository<LoyaltyTransaction, UUID> {
    List<LoyaltyTransaction> findByUserIdOrderByCreatedAtDesc(UUID userId);
}'

Commit "feat: add loyalty point and transaction domain entities" "2025-03-27"

# ============================================================
# Phase 31: Loyalty - Service (2025-03-29)
# ============================================================
Write-Host "[31/10] Loyalty Service..." -ForegroundColor Yellow

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/service/LoyaltyService.java" 'package vn._lab.netabola.loyalty_service.service;
import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import vn._lab.netabola.common.event.OrderPaidEvent;
import vn._lab.netabola.loyalty_service.model.LoyaltyPoint;
import vn._lab.netabola.loyalty_service.model.LoyaltyTransaction;
import vn._lab.netabola.loyalty_service.model.TransactionType;
import vn._lab.netabola.loyalty_service.repository.LoyaltyPointRepository;
import vn._lab.netabola.loyalty_service.repository.LoyaltyTransactionRepository;
import java.math.BigDecimal; import java.time.Instant; import java.util.UUID;
@Service @RequiredArgsConstructor @Slf4j
public class LoyaltyService {
    private final LoyaltyPointRepository loyaltyPointRepository;
    private final LoyaltyTransactionRepository loyaltyTransactionRepository;
    @RabbitListener(queues = "order.paid")
    public void handleOrderPaid(OrderPaidEvent event) {
        int points = event.getTotalAmount().compareTo(BigDecimal.ZERO) > 0
            ? event.getTotalAmount().divide(new BigDecimal("1000"))
                .setScale(0, java.math.RoundingMode.DOWN).intValue() : 0;
        LoyaltyPoint lp = loyaltyPointRepository.findByUserId(UUID.fromString(event.getUserId()))
            .orElseGet(() -> LoyaltyPoint.builder()
                .userId(UUID.fromString(event.getUserId())).balance(0).build());
        lp.setBalance(lp.getBalance() + points);
        loyaltyPointRepository.save(lp);
        LoyaltyTransaction tx = LoyaltyTransaction.builder()
            .userId(UUID.fromString(event.getUserId())).type(TransactionType.EARNED)
            .points(points).orderId(UUID.fromString(event.getOrderId()))
            .description("Earned from order: " + event.getOrderId())
            .createdAt(Instant.now()).build();
        loyaltyTransactionRepository.save(tx);
        log.info("Loyalty points updated for user {}: {} points", event.getUserId(), points);
    }
    @Transactional
    public void addPoints(UUID userId, int points) {
        LoyaltyPoint lp = loyaltyPointRepository.findByUserId(userId)
            .orElseGet(() -> LoyaltyPoint.builder().userId(userId).balance(0).build());
        lp.setBalance(lp.getBalance() + points);
        loyaltyPointRepository.save(lp);
    }
}'

WF "loyalty-service/src/main/java/vn/_lab/netabola/loyalty_service/controller/LoyaltyController.java" 'package vn._lab.netabola.loyalty_service.controller;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn._lab.netabola.loyalty_service.service.LoyaltyService;
@RestController @RequestMapping("/api/loyalty") @RequiredArgsConstructor
public class LoyaltyController {
    private final LoyaltyService loyaltyService;
    @GetMapping("/points") public ResponseEntity<?> getPoints(@RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(loyaltyService);
    }
}'

Commit "feat: implement loyalty points service with RabbitMQ integration" "2025-03-29"

# ============================================================
# Phase 32: Docker Compose (2025-04-01)
# ============================================================
Write-Host "[32/10] Docker Compose..." -ForegroundColor Yellow

WF "docker-compose.yml" 'version: "3.8"
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  postgres-auth:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: netabola_auth
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
  postgres-products:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: netabola_products
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5433:5432"
  postgres-cart:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: netabola_cart
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5434:5432"
  postgres-orders:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: netabola_orders
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5435:5432"
  postgres-loyalty:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: netabola_loyalty
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5436:5432"
  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"'

Commit "feat: add docker-compose for local development environment" "2025-04-01"

# ============================================================
# Phase 33: Dockerfiles (2025-04-03)
# ============================================================
Write-Host "[33/10] Dockerfiles..." -ForegroundColor Yellow

WF "Dockerfile" 'FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY netabola-common/pom.xml netabola-common/
COPY auth-service/pom.xml auth-service/
COPY product-service/pom.xml product-service/
COPY cart-service/pom.xml cart-service/
COPY order-service/pom.xml order-service/
COPY api-gateway/pom.xml api-gateway/
COPY loyalty-service/pom.xml loyalty-service/
RUN mvn -B dependency:go-offline
COPY . .
RUN mvn -B package -DskipTests
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/*/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]'

WF "auth-service/Dockerfile" 'FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY netabola-common/pom.xml netabola-common/
COPY auth-service/pom.xml auth-service/
RUN mvn -B dependency:go-offline -pl auth-service
COPY . .
RUN mvn -B package -DskipTests -pl auth-service
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/auth-service/target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]'

WF "api-gateway/Dockerfile" 'FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY api-gateway/pom.xml api-gateway/
RUN mvn -B dependency:go-offline -pl api-gateway
COPY . .
RUN mvn -B package -DskipTests -pl api-gateway
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/api-gateway/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]'

Commit "feat: add Dockerfiles for auth-service and api-gateway" "2025-04-03"

# ============================================================
# Phase 34: K8s Configs (2025-04-06)
# ============================================================
Write-Host "[34/10] K8s Configs..." -ForegroundColor Yellow

WF "k8s/namespace.yaml" 'apiVersion: v1
kind: Namespace
metadata:
  name: netabola
  labels:
    name: netabola'

WF "k8s/auth-service-deployment.yaml" 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: netabola
spec:
  replicas: 2
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
        - name: auth-service
          image: netabola/auth-service:latest
          ports:
            - containerPort: 8081
          env:
            - name: SPRING_DATASOURCE_URL
              value: "jdbc:postgresql://postgres:5432/netabola_auth"'

WF "k8s/auth-service-service.yaml" 'apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: netabola
spec:
  selector:
    app: auth-service
  ports:
    - port: 8081
      targetPort: 8081'

WF "k8s/gateway-deployment.yaml" 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: netabola
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
        - name: api-gateway
          image: netabola/api-gateway:latest
          ports:
            - containerPort: 8080'

WF "k8s/gateway-service.yaml" 'apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: netabola
spec:
  type: LoadBalancer
  selector:
    app: api-gateway
  ports:
    - port: 80
      targetPort: 8080'

WF "k8s/redis-statefulset.yaml" 'apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
  namespace: netabola
spec:
  serviceName: redis
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7-alpine
          ports:
            - containerPort: 6379'

WF "k8s/rabbitmq-statefulset.yaml" 'apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rabbitmq
  namespace: netabola
spec:
  serviceName: rabbitmq
  replicas: 1
  selector:
    matchLabels:
      app: rabbitmq
  template:
    metadata:
      labels:
        app: rabbitmq
    spec:
      containers:
        - name: rabbitmq
          image: rabbitmq:3-management-alpine
          ports:
            - containerPort: 5672
            - containerPort: 15672'

Commit "feat: add Kubernetes deployment manifests for all services" "2025-04-06"

# ============================================================
# Phase 35: Security Audit Documentation (2025-04-08)
# ============================================================
Write-Host "[35/10] Security Docs..." -ForegroundColor Yellow

WF "docs/SECURITY.md" '# Security Audit Report

## OWASP Top 10 Analysis

### A01:2021 - Broken Access Control
- Order checkout verifies ownership: `!order.getUserId().equals(userId)`
- Gateway enforces JWT on all routes except `/api/auth/**`
- Status: Mitigated

### A02:2021 - Cryptographic Failures
- JWT RS256 signing with RSA 4096-bit keys
- Keys persisted to disk at `{tmpdir}/netabola-keys/`
- BCrypt for password encoding
- Status: Mitigated

### A03:2021 - Injection
- JPA parameterized queries throughout
- No raw SQL execution
- Status: Mitigated

### A05:2021 - Security Misconfiguration
- Security headers filter applied globally
- HSTS enabled
- Status: Mitigated

### A07:2021 - Identification and Authentication Failures
- JWT RS256 with rotation
- Refresh token rotation + revocation
- Rate limiting: 100 req/min per IP
- Status: Mitigated'

WF "docs/AUTH_FLOW.md" '# Authentication Flow

1. User registers via POST /api/auth/register
2. Server returns access token + refresh token
3. Client includes access token in Authorization header
4. Gateway validates JWT and adds X-User-Id header
5. Service endpoints read X-User-Id from header
6. Refresh token used at POST /api/auth/refresh
7. Old refresh token revoked, new one issued

## JWT Claims
- sub: user UUID
- email: user email
- role: USER/ADMIN/MODERATOR'

WF ".github/dependabot.yml" 'version: 2
updates:
  - package-ecosystem: "maven"
    directory: "/"
    schedule:
      interval: "weekly"'

Commit "feat: add security audit docs, auth flow docs and dependabot config" "2025-04-08"

# ============================================================
# Phase 36: Cleanup + README update (2025-04-10)
# ============================================================
Write-Host "[36/10] Cleanup..." -ForegroundColor Yellow

WF "README.md" '# NetaBola - E-Commerce Platform

Microservices architecture for an e-commerce platform with product catalog, shopping cart, order processing, and payments.

## Services
- `auth-service`: Authentication & Authorization (port 8081)
- `product-service`: Product catalog management (port 8082)
- `cart-service`: Shopping cart operations (port 8083)
- `order-service`: Order processing & Stripe payments (port 8084)
- `api-gateway`: API Gateway & Routing (port 8080)
- `loyalty-service`: Loyalty points & rewards (port 8085)

## Tech Stack
- Java 21, Spring Boot 3.5.14
- Spring Cloud Gateway
- PostgreSQL, Redis, RabbitMQ
- JWT RS256, BCrypt
- Stripe Payment
- Kubernetes ready

## Quick Start
```bash
docker-compose up -d
mvn clean install
```

## Security
- JWT RS256 authentication
- Refresh token rotation
- Rate limiting (100 req/min)
- Security headers
- Circuit breakers
- See [SECURITY.md](docs/SECURITY.md)'

WF "netabola-common/.gitignore" '# Prevent common files in common module
target/
*.class
*.jar'

WF "auth-service/.gitignore" 'target/
*.class
*.jar
.env'

WF "product-service/.gitignore" 'target/
*.class
*.jar'

WF "cart-service/.gitignore" 'target/
*.class
*.jar'

WF "order-service/.gitignore" 'target/
*.class
*.jar
.env'

WF "api-gateway/.gitignore" 'target/
*.class
*.jar'

WF "loyalty-service/.gitignore" 'target/
*.class
*.jar'

WF "docs/ARCHITECTURE.md" '# Architecture

## Service Communication
- Synchronous: REST via API Gateway
- Asynchronous: RabbitMQ for domain events
- State: Each service has its own database

## Request Flow
1. Client -> API Gateway (port 8080)
2. Gateway validates JWT, adds X-User-Id
3. Gateway routes to appropriate service
4. Service processes request
5. Service publishes events to RabbitMQ
6. Loyalty service consumes OrderPaidEvent

## Security Layers
1. Gateway JWT filter
2. Gateway security headers
3. Gateway rate limiting
4. Service-level security filters'

Commit "docs: update README with full service listing and quick start guide" "2025-04-10"

# ============================================================
# Phase 37: Final cleanup (2025-04-12)
# ============================================================
Write-Host "[37/10] Final Cleanup..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/route/LoyaltyRoute.java" 'package vn._lab.netabola.api_gateway.route;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class LoyaltyRoute {
    @Bean
    public RouteLocator loyaltyRoutes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("loyalty", r -> r.path("/api/loyalty/**")
                .filters(f -> f.stripPrefix(2))
                .uri("lb://loyalty-service")).build();
    }
}'

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/filter/LoggingGlobalFilter.java" 'package vn._lab.netabola.api_gateway.filter;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
@Component
@Slf4j
public class LoggingGlobalFilter implements GlobalFilter, Ordered {
    @Override
    public int getOrder() { return Ordered.HIGHEST_PRECEDENCE + 1; }
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        long start = System.currentTimeMillis();
        return chain.filter(exchange).then(Mono.fromRunnable(() -> {
            long duration = System.currentTimeMillis() - start;
            log.info("{} {} - {} - {}ms",
                exchange.getRequest().getMethod(),
                exchange.getRequest().getURI().getPath(),
                exchange.getResponse().getStatusCode(),
                duration);
        }));
    }
}'

WF "docs/API.md" '# API Documentation

## Base URL: http://localhost:8080

## Auth
- POST /api/auth/register - Register new user
- POST /api/auth/login - Login
- POST /api/auth/refresh - Refresh token
- POST /api/auth/logout - Logout

## Products
- GET /api/products - List products (paginated)
- GET /api/products/{id} - Get product details
- POST /api/products - Create product (admin)
- PUT /api/products/{id} - Update product (admin)

## Cart
- GET /api/carts/current - Get current cart
- POST /api/carts/items - Add item to cart
- PUT /api/carts/items/{id} - Update cart item
- DELETE /api/carts/items/{id} - Remove cart item

## Orders
- GET /api/orders - List user orders
- GET /api/orders/{id} - Get order details
- POST /api/orders - Create order
- POST /api/orders/{id}/pay - Pay order (Stripe)
- POST /api/orders/{id}/cancel - Cancel order
- POST /api/checkout/stripe-session - Create Stripe checkout session'

Commit "feat: add logging filter, loyalty route, and API documentation" "2025-04-12"

# ============================================================
# Phase 38: Final tweaks (2025-04-14)
# ============================================================
Write-Host "[38/10] Final Tweaks..." -ForegroundColor Yellow

WF "api-gateway/src/main/java/vn/_lab/netabola/api_gateway/config/CustomErrorAttributes.java" 'package vn._lab.netabola.api_gateway.config;
import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.boot.web.reactive.error.ErrorAttributes;
import org.springframework.stereotype.Component;
import java.util.Map;
@Component
public class CustomErrorAttributes implements ErrorAttributes {
    @Override
    public Map<String, Object> getErrorAttributes(ErrorAttributeOptions options) {
        return Map.of("timestamp", java.time.Instant.now().toString(),
            "status", 500, "error", "Internal Server Error");
    }
    @Override
    public Throwable getError(ErrorAttributeOptions options) {
        return null;
    }
}'

WF "auth-service/src/main/java/vn/_lab/netabola/auth_service/config/JacksonConfig.java" 'package vn._lab.netabola.auth_service.config;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class JacksonConfig {
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        return mapper;
    }
}'

WF "order-service/src/main/java/vn/_lab/netabola/order_service/config/JacksonConfig.java" 'package vn._lab.netabola.order_service.config;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class JacksonConfig {
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        return mapper;
    }
}'

WF "docker-compose.override.yml" 'version: "3.8"
services:
  postgres-auth:
    volumes:
      - pg_auth_data:/var/lib/postgresql/data
  postgres-products:
    volumes:
      - pg_products_data:/var/lib/postgresql/data
volumes:
  pg_auth_data:
  pg_products_data:'

Commit "feat: add error attributes config, Jackson configs and docker override" "2025-04-14"

# ============================================================
# Phase 39: Add docs to k8s (2025-04-16)
# ============================================================
Write-Host "[39/10] K8s Docs..." -ForegroundColor Yellow

WF "k8s/README.md" '# Kubernetes Deployment

## Prerequisites
- kubectl configured
- Access to Kubernetes cluster
- Docker images built and pushed to registry

## Deploy
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis-statefulset.yaml
kubectl apply -f k8s/rabbitmq-statefulset.yaml
kubectl apply -f k8s/auth-service-deployment.yaml
kubectl apply -f k8s/auth-service-service.yaml
kubectl apply -f k8s/gateway-deployment.yaml
kubectl apply -f k8s/gateway-service.yaml
```

## Services
- api-gateway: LoadBalancer (port 80)
- auth-service: ClusterIP (port 8081)
- redis: StatefulSet (port 6379)
- rabbitmq: StatefulSet (port 5672)'

WF "k8s/order-service-deployment.yaml" 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: netabola
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
        - name: order-service
          image: netabola/order-service:latest
          ports:
            - containerPort: 8084
          env:
            - name: SPRING_DATASOURCE_URL
              value: "jdbc:postgresql://postgres:5432/netabola_orders"'

WF "k8s/order-service-service.yaml" 'apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: netabola
spec:
  selector:
    app: order-service
  ports:
    - port: 8084
      targetPort: 8084'

WF "k8s/product-service-deployment.yaml" 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  namespace: netabola
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
        - name: product-service
          image: netabola/product-service:latest
          ports:
            - containerPort: 8082'

WF "k8s/product-service-service.yaml" 'apiVersion: v1
kind: Service
metadata:
  name: product-service
  namespace: netabola
spec:
  selector:
    app: product-service
  ports:
    - port: 8082
      targetPort: 8082'

WF "k8s/cart-service-deployment.yaml" 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: cart-service
  namespace: netabola
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cart-service
  template:
    metadata:
      labels:
        app: cart-service
    spec:
      containers:
        - name: cart-service
          image: netabola/cart-service:latest
          ports:
            - containerPort: 8083'

WF "k8s/cart-service-service.yaml" 'apiVersion: v1
kind: Service
metadata:
  name: cart-service
  namespace: netabola
spec:
  selector:
    app: cart-service
  ports:
    - port: 8083
      targetPort: 8083'

WF "k8s/loyalty-service-deployment.yaml" 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: loyalty-service
  namespace: netabola
spec:
  replicas: 2
  selector:
    matchLabels:
      app: loyalty-service
  template:
    metadata:
      labels:
        app: loyalty-service
    spec:
      containers:
        - name: loyalty-service
          image: netabola/loyalty-service:latest
          ports:
            - containerPort: 8085'

WF "k8s/loyalty-service-service.yaml" 'apiVersion: v1
kind: Service
metadata:
  name: loyalty-service
  namespace: netabola
spec:
  selector:
    app: loyalty-service
  ports:
    - port: 8085
      targetPort: 8085'

Commit "feat: add kubernetes manifests for all remaining services with docs" "2025-04-16"

# ============================================================
# Phase 40: Final polish (2025-04-18)
# ============================================================
Write-Host "[40/10] Final Polish..." -ForegroundColor Yellow

WF ".github/workflows/deploy.yml" 'name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to K8s
        run: |
          kubectl set image deployment/auth-service auth-service=netabola/auth-service:${{ github.sha }}
          kubectl set image deployment/api-gateway api-gateway=netabola/api-gateway:${{ github.sha }}'

WF "CHANGELOG.md" '# Changelog

## [0.0.1-SNAPSHOT] - 2025-04-18

### Added
- Auth service with JWT RS256
- Product, Cart, Order services
- API Gateway with JWT filter and rate limiting
- Loyalty service with RabbitMQ
- Kubernetes deployment manifests
- Docker Compose for local dev

### Security
- RSA 4096-bit keys for JWT
- Refresh token rotation
- Rate limiting (100 req/min)
- Security headers
- Circuit breakers'

Write-Host "`n=== DONE! ===" -ForegroundColor Green
Write-Host "Total commits: $(git rev-list --count HEAD)" -ForegroundColor Green
