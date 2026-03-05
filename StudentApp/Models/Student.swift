//
//  Student.swift
//  StudentApp
//
//  Created by Rafael Mejía López on 03/03/26.
//

import Foundation

struct Student: Codable {
    var nombre: String
    var apellido: String
    var matricula: String
    var facultad: String
    var semestre: String
    var sexo: String
    var correo: String
    var contrasena: String
    
    var nombreCompleto: String {
        "\(nombre) \(apellido)"
    }
}

enum Sexo: String, CaseIterable {
    case masculino = "Masculino"
    case femenino = "Femenino"
    case otro = "Otro"
    case prefiero = "Prefiero no decir"
}

enum Facultad: String, CaseIterable {
    case ingenieria = "Ingeniería"
    case medicina = "Medicina"
    case derecho = "Derecho"
    case administracion = "Administración"
    case ciencias = "Ciencias"
    case humanidades = "Humanidades"
    case arquitectura = "Arquitectura"
    case psicologia = "Psicología"
    case economia = "Economía"
    case comunicacion = "Comunicación"
}
