package com.example.temperaturacrud.controller;

import com.example.temperaturacrud.model.Temperatura;
import com.example.temperaturacrud.repository.TemperaturaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/temperaturas")
@CrossOrigin(origins = "*")
public class TemperaturaController {
    
    @Autowired
    private TemperaturaRepository temperaturaRepository;
    
    @GetMapping
    public List<Temperatura> getAllTemperaturas() {
        return temperaturaRepository.findAll();
    }
    
    @PostMapping
    public Temperatura createTemperatura(@RequestBody Temperatura temperatura) {
        return temperaturaRepository.save(temperatura);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Temperatura> getTemperaturaById(@PathVariable Long id) {
        return temperaturaRepository.findById(id)
                .map(temperatura -> ResponseEntity.ok().body(temperatura))
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Temperatura> updateTemperatura(@PathVariable Long id, 
                                                       @RequestBody Temperatura temperaturaDetails) {
        return temperaturaRepository.findById(id)
                .map(temperatura -> {
                    temperatura.setValor(temperaturaDetails.getValor());
                    temperatura.setUbicacion(temperaturaDetails.getUbicacion());
                    return ResponseEntity.ok(temperaturaRepository.save(temperatura));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTemperatura(@PathVariable Long id) {
        return temperaturaRepository.findById(id)
                .map(temperatura -> {
                    temperaturaRepository.delete(temperatura);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
