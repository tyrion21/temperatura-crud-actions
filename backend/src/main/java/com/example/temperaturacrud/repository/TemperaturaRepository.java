package com.example.temperaturacrud.repository;

import com.example.temperaturacrud.model.Temperatura;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TemperaturaRepository extends JpaRepository<Temperatura, Long> {
}
