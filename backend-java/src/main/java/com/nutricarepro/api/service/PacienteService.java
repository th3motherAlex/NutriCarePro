package com.nutricarepro.api.service;

import com.nutricarepro.api.exception.BusinessException;
import com.nutricarepro.api.exception.ResourceNotFoundException;
import com.nutricarepro.api.model.Paciente;
import com.nutricarepro.api.repository.CitaRepository;
import com.nutricarepro.api.repository.PacienteRepository;
import com.nutricarepro.api.repository.PlanAlimenticioRepository;
import com.nutricarepro.api.repository.ProgresoRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PacienteService {

    private final PacienteRepository repository;
    private final PlanAlimenticioRepository planRepository;
    private final CitaRepository citaRepository;
    private final ProgresoRepository progresoRepository;

    public PacienteService(PacienteRepository repository, PlanAlimenticioRepository planRepository,
                           CitaRepository citaRepository, ProgresoRepository progresoRepository) {
        this.repository = repository;
        this.planRepository = planRepository;
        this.citaRepository = citaRepository;
        this.progresoRepository = progresoRepository;
    }

    public List<Paciente> findAll() {
        return repository.findAll(Sort.by("apellido", "nombre"));
    }

    public Paciente findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado: " + id));
    }

    public Paciente create(Paciente paciente) {
        return repository.save(paciente);
    }

    public Paciente update(Long id, Paciente input) {
        Paciente paciente = findById(id);
        paciente.setNombre(input.getNombre());
        paciente.setApellido(input.getApellido());
        paciente.setEmail(input.getEmail());
        paciente.setTelefono(input.getTelefono());
        paciente.setFechaNacimiento(input.getFechaNacimiento());
        paciente.setGenero(input.getGenero());
        paciente.setObjetivo(input.getObjetivo());
        paciente.setNotas(input.getNotas());
        paciente.setNutriologoId(input.getNutriologoId());
        return repository.save(paciente);
    }

    public void delete(Long id) {
        Paciente paciente = findById(id);
        if (planRepository.existsByPacienteId(id) || citaRepository.existsByPacienteId(id)
                || progresoRepository.existsByPacienteId(id)) {
            throw new BusinessException("El paciente tiene planes, citas o progresos asociados.");
        }
        repository.delete(paciente);
    }
}
