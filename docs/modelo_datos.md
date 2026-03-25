erDiagram
    USUARIO ||--o{ RUTINA : crea
    ZONA_ARTICULAR ||--o{ EJERCICIO : agrupa
    RUTINA ||--o{ RUTINA_EJERCICIO : contiene
    EJERCICIO ||--o{ RUTINA_EJERCICIO : aparece_en

    USUARIO {
        string id PK
        string email "UNIQUE"
        string nombre
        int edad
        datetime created_at
    }

    ZONA_ARTICULAR {
        string id PK
        string nombre "UNIQUE"
    }

    EJERCICIO {
        string id PK
        string nombre
        string descripcion
        int series
        int repeticiones
        string imagen
        string zona_articular_id FK
    }

    RUTINA {
        string id PK
        string nombre
        string descripcion
        string usuario_id FK
        boolean creada_por_ia
        datetime created_at
    }

    RUTINA_EJERCICIO {
        string rutina_id PK, FK
        string ejercicio_id PK, FK
        int orden
    }
