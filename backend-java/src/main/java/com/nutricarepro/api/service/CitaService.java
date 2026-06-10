package com.nutricarepro.api.service;

import com.nutricarepro.api.exception.BusinessException;
import com.nutricarepro.api.exception.ResourceNotFoundException;
import com.nutricarepro.api.model.Cita;
import com.nutricarepro.api.repository.CitaRepository;
import com.nutricarepro.api.repository.PacienteRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CitaService {

    private final CitaRepository repository;
    private final PacienteRepository pacienteRepository;

    public CitaService(CitaRepository repository, PacienteRepository pacienteRepository) {
        this.repository = repository;
        this.pacienteRepository = pacienteRepository;
    }

    public List<Cita> findAll() {
        return repository.findAll(Sort.by(Sort.Direction.ASC, "fechaHora"));
    }

    public Cita findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cita no encontrada: " + id));
    }

    public Cita create(Cita cita) {
        validatePatient(cita.getPacienteId());
        return repository.save(cita);
    }

    public Cita update(Long id, Cita input) {
        validatePatient(input.getPacienteId());
        Cita cita = findById(id);
        cita.setPacienteId(input.getPacienteId());
        cita.setFechaHora(input.getFechaHora());
        cita.setMotivo(input.getMotivo());
        cita.setEstado(input.getEstado());
        cita.setNotas(input.getNotas());
        return repository.save(cita);
    }

    public void delete(Long id) {
        repository.delete(findById(id));
    }

    private void validatePatient(Long pacienteId) {
        if (!pacienteRepository.existsById(pacienteId)) {
            throw new BusinessException("El paciente asignado no existe.");
        }
    }
}
