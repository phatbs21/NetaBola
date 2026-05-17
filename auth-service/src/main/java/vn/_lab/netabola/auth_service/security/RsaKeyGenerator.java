package vn._lab.netabola.auth_service.security;
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
}
