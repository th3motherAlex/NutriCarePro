package com.nutricarepro.api.service;

import com.nutricarepro.api.dto.LoginRequest;
import com.nutricarepro.api.dto.LoginResponse;
import com.nutricarepro.api.exception.BusinessException;
import com.nutricarepro.api.model.Usuario;
import com.nutricarepro.api.repository.UsuarioRepository;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UsuarioRepository repository;

    public AuthService(UsuarioRepository repository) {
        this.repository = repository;
    }

    public LoginResponse login(LoginRequest request) {
        Usuario usuario = repository.findByEmailIgnoreCase(request.email())
                .filter(found -> found.getPassword().equals(request.password()))
                .orElseThrow(() -> new BusinessException("Credenciales incorrectas."));
        return new LoginResponse(
                usuario.getId(),
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getEspecialidad(),
                "Inicio de sesion correcto."
        );
    }
}
