package com.nutricarepro.api.config;

import com.nutricarepro.api.model.Usuario;
import com.nutricarepro.api.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UsuarioRepository repository;
    private final String adminEmail;
    private final String adminPassword;
    private final String adminName;

    public DataInitializer(UsuarioRepository repository,
                           @Value("${app.seed.admin-email}") String adminEmail,
                           @Value("${app.seed.admin-password}") String adminPassword,
                           @Value("${app.seed.admin-name}") String adminName) {
        this.repository = repository;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
        this.adminName = adminName;
    }

    @Override
    public void run(String... args) {
        if (!repository.existsByEmailIgnoreCase(adminEmail)) {
            Usuario usuario = new Usuario();
            usuario.setNombre(adminName);
            usuario.setEmail(adminEmail);
            usuario.setPassword(adminPassword);
            usuario.setEspecialidad("Nutricion clinica");
            repository.save(usuario);
        }
    }
}
