package com.nutricarepro.api.repository;

import com.nutricarepro.api.model.Progreso;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProgresoRepository extends JpaRepository<Progreso, Long> {
    boolean existsByPacienteId(Long pacienteId);
}
