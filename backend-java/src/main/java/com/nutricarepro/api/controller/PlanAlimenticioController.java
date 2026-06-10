package com.nutricarepro.api.controller;

import com.nutricarepro.api.model.PlanAlimenticio;
import com.nutricarepro.api.service.PlanAlimenticioService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/planes")
public class PlanAlimenticioController {

    private final PlanAlimenticioService service;

    public PlanAlimenticioController(PlanAlimenticioService service) {
        this.service = service;
    }

    @GetMapping
    public List<PlanAlimenticio> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public PlanAlimenticio findById(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PlanAlimenticio create(@Valid @RequestBody PlanAlimenticio plan) {
        return service.create(plan);
    }

    @PutMapping("/{id}")
    public PlanAlimenticio update(@PathVariable Long id, @Valid @RequestBody PlanAlimenticio plan) {
        return service.update(id, plan);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
