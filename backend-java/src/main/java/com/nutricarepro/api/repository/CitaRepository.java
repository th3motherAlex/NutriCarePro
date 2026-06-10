package com.nutricarepro.api.repository;

import com.nutricarepro.api.model.Cita;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CitaRepository extends JpaRepository<Cita, Long> {
    boolean existsByPacienteId(Long pacienteId);
}
