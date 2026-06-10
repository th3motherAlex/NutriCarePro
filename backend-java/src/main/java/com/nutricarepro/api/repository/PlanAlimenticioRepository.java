package com.nutricarepro.api.repository;

import com.nutricarepro.api.model.PlanAlimenticio;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlanAlimenticioRepository extends JpaRepository<PlanAlimenticio, Long> {
    boolean existsByPacienteId(Long pacienteId);
}
