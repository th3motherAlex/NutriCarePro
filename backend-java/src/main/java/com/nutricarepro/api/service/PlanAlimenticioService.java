package com.nutricarepro.api.service;

import com.nutricarepro.api.exception.BusinessException;
import com.nutricarepro.api.exception.ResourceNotFoundException;
import com.nutricarepro.api.model.PlanAlimenticio;
import com.nutricarepro.api.repository.PacienteRepository;
import com.nutricarepro.api.repository.PlanAlimenticioRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PlanAlimenticioService {

    private final PlanAlimenticioRepository repository;
    private final PacienteRepository pacienteRepository;

    public PlanAlimenticioService(PlanAlimenticioRepository repository, PacienteRepository pacienteRepository) {
        this.repository = repository;
        this.pacienteRepository = pacienteRepository;
    }

    public List<PlanAlimenticio> findAll() {
        return repository.findAll(Sort.by(Sort.Direction.DESC, "fechaInicio"));
    }

    public PlanAlimenticio findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Plan alimenticio no encontrado: " + id));
    }

    public PlanAlimenticio create(PlanAlimenticio plan) {
        validate(plan);
        return repository.save(plan);
    }

    public PlanAlimenticio update(Long id, PlanAlimenticio input) {
        validate(input);
        PlanAlimenticio plan = findById(id);
        plan.setPacienteId(input.getPacienteId());
        plan.setNombre(input.getNombre());
        plan.setDescripcion(input.getDescripcion());
        plan.setCaloriasObjetivo(input.getCaloriasObjetivo());
        plan.setFechaInicio(input.getFechaInicio());
        plan.setFechaFin(input.getFechaFin());
        plan.setActivo(input.isActivo());
        return repository.save(plan);
    }

    public void delete(Long id) {
        repository.delete(findById(id));
    }

    private void validate(PlanAlimenticio plan) {
        if (!pacienteRepository.existsById(plan.getPacienteId())) {
            throw new BusinessException("El paciente asignado no existe.");
        }
        if (plan.getFechaInicio() != null && plan.getFechaFin() != null
                && plan.getFechaFin().isBefore(plan.getFechaInicio())) {
            throw new BusinessException("La fecha final del plan debe ser posterior a la inicial.");
        }
    }
}
