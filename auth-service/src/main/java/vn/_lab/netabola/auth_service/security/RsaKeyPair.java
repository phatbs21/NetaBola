package vn._lab.netabola.auth_service.security;
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
}
