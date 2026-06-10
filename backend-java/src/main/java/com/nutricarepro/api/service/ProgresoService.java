package com.nutricarepro.api.service;

import com.nutricarepro.api.exception.BusinessException;
import com.nutricarepro.api.exception.ResourceNotFoundException;
import com.nutricarepro.api.model.Progreso;
import com.nutricarepro.api.repository.PacienteRepository;
import com.nutricarepro.api.repository.ProgresoRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProgresoService {

    private final ProgresoRepository repository;
    private final PacienteRepository pacienteRepository;

    public ProgresoService(ProgresoRepository repository, PacienteRepository pacienteRepository) {
        this.repository = repository;
        this.pacienteRepository = pacienteRepository;
    }

    public List<Progreso> findAll() {
        return repository.findAll(Sort.by(Sort.Direction.DESC, "fecha"));
    }

    public Progreso findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Progreso no encontrado: " + id));
    }

    public Progreso create(Progreso progreso) {
        validatePatient(progreso.getPacienteId());
        return repository.save(progreso);
    }

    public Progreso update(Long id, Progreso input) {
        validatePatient(input.getPacienteId());
        Progreso progreso = findById(id);
        progreso.setPacienteId(input.getPacienteId());
        progreso.setFecha(input.getFecha());
        progreso.setPeso(input.getPeso());
        progreso.setAltura(input.getAltura());
        progreso.setPorcentajeGrasa(input.getPorcentajeGrasa());
        progreso.setCintura(input.getCintura());
        progreso.setObservaciones(input.getObservaciones());
        return repository.save(progreso);
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
