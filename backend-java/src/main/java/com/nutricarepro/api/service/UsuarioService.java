package com.nutricarepro.api.service;

import com.nutricarepro.api.exception.BusinessException;
import com.nutricarepro.api.exception.ResourceNotFoundException;
import com.nutricarepro.api.model.Usuario;
import com.nutricarepro.api.repository.UsuarioRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UsuarioService {

    private final UsuarioRepository repository;

    public UsuarioService(UsuarioRepository repository) {
        this.repository = repository;
    }

    public List<Usuario> findAll() {
        return repository.findAll(Sort.by("nombre"));
    }

    public Usuario findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado: " + id));
    }

    public Usuario create(Usuario usuario) {
        validateEmail(usuario.getEmail(), null);
        return repository.save(usuario);
    }

    public Usuario update(Long id, Usuario input) {
        Usuario usuario = findById(id);
        validateEmail(input.getEmail(), id);
        usuario.setNombre(input.getNombre());
        usuario.setEmail(input.getEmail());
        usuario.setPassword(input.getPassword());
        usuario.setEspecialidad(input.getEspecialidad());
        return repository.save(usuario);
    }

    public void delete(Long id) {
        repository.delete(findById(id));
    }

    private void validateEmail(String email, Long currentId) {
        repository.findByEmailIgnoreCase(email)
                .filter(usuario -> !usuario.getId().equals(currentId))
                .ifPresent(usuario -> {
                    throw new BusinessException("El correo ya esta registrado.");
                });
    }
}
