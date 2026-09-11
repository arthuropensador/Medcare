
CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0),
    FOREIGN KEY (especialidade_id) REFERENCES especialidades(id)
);


CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    paciente_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada')),
    FOREIGN KEY (medico_id) REFERENCES medicos(id),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
);


CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    nome_exame VARCHAR(150) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0),
    FOREIGN KEY (consulta_id) REFERENCES consultas(id)
);
-- Inserção de Especialidades
INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');


INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('Carlos Silva', 'carlos.silva@email.com', '12345678901', '1985-05-12'),
('Ana Oliveira', 'ana.oliveira@email.com', '98765432100', '1992-10-25'),
('João Souza', 'joao.souza@email.com', '45678912305', '1978-03-04');


INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES 
(1, 'Dr. Roberto Costa', 'CRM/SP 123456', 350.00), -- Cardiologia (> 300)
(2, 'Dra. Fernanda Lima', 'CRM/SP 654321', 250.00), -- Pediatria
(3, 'Dr. Marcelo Ribeiro', 'CRM/SP 789123', 400.00); -- Dermatologia (> 300)


INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES 
(1, 1, '2026-03-01 10:00:00', 'Realizada'), -- Carlos Silva no Cardiologista
(2, 1, '2026-03-05 14:30:00', 'Agendada'),  -- Carlos Silva no Pediatra
(3, 2, '2026-03-02 09:00:00', 'Realizada'), -- Ana Oliveira no Dermatologista
(1, 3, '2026-03-03 11:00:00', 'Realizada'); -- João Souza no Cardiologista



INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES 
(1, 'Eletrocardiograma', 150.00),
(1, 'Ecocardiograma', 250.00),
(3, 'Biópsia de Pele', 200.00),
(4, 'Hemograma Completo', 50.00);

SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;
SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'Carlos Silva';

SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    (m.valor_consulta + COALESCE(SUM(ec.valor_exame), 0)) AS valor_total_calculado
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ec ON c.id = ec.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta;

SELECT 
    nome,
    crm,
    valor_consulta
FROM medicos
WHERE valor_consulta > 300.00;
SELECT 
    e.nome AS especialidade,
    SUM(m.valor_consulta + COALESCE(sub_exames.total_exames, 0)) AS total_faturado
FROM consultas c
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
LEFT JOIN (
    SELECT consulta_id, SUM(valor_exame) AS total_exames
    FROM exames_consulta
    GROUP BY consulta_id
) sub_exames ON c.id = sub_exames.consulta_id
WHERE c.status = 'Realizada'
GROUP BY e.nome;