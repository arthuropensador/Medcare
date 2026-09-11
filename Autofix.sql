CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela mecanicos
CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    valor_hora NUMERIC(10, 2) NOT NULL CHECK (valor_hora > 0)
);

-- Tabela: veiculos
CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    placa CHAR(7) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabela: ordens_servico
CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL,
    mecanico_id INT NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra NUMERIC(10, 2) NOT NULL CHECK (valor_mao_obra >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Em Aberto' CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada')),
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id)
);

-- Tabela: pecas_os
CREATE TABLE pecas_os (
    id SERIAL PRIMARY KEY,
    os_id INT NOT NULL,
    nome_peca VARCHAR(150) NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    valor_unitario NUMERIC(10, 2) NOT NULL CHECK (valor_unitario > 0),
    FOREIGN KEY (os_id) REFERENCES ordens_servico(id)
);

-- 2. [DML] INSERÇÃO DOS DADOS INICIAIS

-- Inserindo Clientes (incluindo Fernanda Lima para o relatório Q2)
INSERT INTO clientes (nome, email, telefone, cpf) VALUES 
('Fernanda Lima', 'fernanda.lima@email.com', '(48) 99999-1111', '12345678901'),
('Carlos Eduardo', 'carlos.eduardo@email.com', '(48) 98888-2222', '98765432100'),
('Beatriz Souza', 'beatriz.souza@email.com', '(48) 97777-3333', '45678912305');

-- Inserindo Mecânicos
INSERT INTO mecanicos (nome, especialidade, valor_hora) VALUES 
('Roberto Santos', 'Motor', 120.00),               
('Marcelo Oliveira', 'Injeção Eletrônica', 95.00), 
('Juliana Paes', 'Suspensão', 85.00);              

-- Inserindo Veículos
INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano) VALUES 
(1, 'ABC1D23', 'Civic', 'Honda', 2020),  
(2, 'XYZ9K88', 'Gol', 'Volkswagen', 2018),
(3, 'JKL4M56', 'Corolla', 'Toyota', 2022);

-- Inserindo Ordens de Serviço (OS)
INSERT INTO ordens_servico (veiculo_id, mecanico_id, data_abertura, valor_mao_obra, status) VALUES 
(1, 1, '2026-03-01 08:30:00', 250.00, 'Concluida'),   -- OS 1 (Fernanda Lima)
(1, 2, '2026-03-05 10:00:00', 180.00, 'Em Andamento'),-- OS 2 (Fernanda Lima)
(2, 3, '2026-03-02 13:15:00', 150.00, 'Concluida'),   -- OS 3 (Carlos)
(3, 1, '2026-03-03 09:00:00', 300.00, 'Concluida');   -- OS 4 (Beatriz)

-- Inserindo Peças/Insumos
INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES 
(1, 'Filtro de Óleo', 1, 45.00),
(1, 'Óleo Sintético 5W30', 4, 60.00),
(3, 'Pastilha de Freio', 2, 120.00),
(4, 'Jogo de Velas de Ignição', 1, 180.00);


-- 3. [DQL] CONSULTAS SQL (RELATÓRIOS)

-- Q1: Listar veículos ordenados por marca e modelo
SELECT 
    v.modelo,
    v.marca,
    v.placa,
    c.nome AS proprietario,
    c.telefone
FROM veiculos v
JOIN clientes c ON v.cliente_id = c.id
ORDER BY v.marca ASC, v.modelo ASC;

-- Q2: Buscar todas as Ordens de Serviço da cliente "Fernanda Lima"
SELECT 
    os.id AS os_id,
    v.placa,
    v.modelo,
    os.data_abertura,
    m.nome AS mecanico,
    os.status
FROM ordens_servico os
JOIN veiculos v ON os.veiculo_id = v.id
JOIN clientes c ON v.cliente_id = c.id
JOIN mecanicos m ON os.mecanico_id = m.id
WHERE c.nome = 'Fernanda Lima';

-- Q3: Calcular o valor total de cada OS (Mão de obra + Soma de Peças)
SELECT 
    os.id AS os_id,
    v.placa,
    m.nome AS mecanico,
    os.valor_mao_obra,
    (os.valor_mao_obra + COALESCE(SUM(p.quantidade * p.valor_unitario), 0)) AS valor_total_final
FROM ordens_servico os
JOIN veiculos v ON os.veiculo_id = v.id
JOIN mecanicos m ON os.mecanico_id = m.id
LEFT JOIN pecas_os p ON os.id = p.os_id
GROUP BY os.id, v.placa, m.nome, os.valor_mao_obra;

-- Q4: Listar mecânicos com valor de hora superior a R$ 90,00
SELECT 
    nome,
    especialidade,
    valor_hora
FROM mecanicos
WHERE valor_hora > 90.00;

-- Q5: Exibir o total faturado com mão de obra agrupado por especialidade (somente status 'Concluida')
SELECT 
    m.especialidade,
    SUM(os.valor_mao_obra) AS total_mao_obra_faturado
FROM ordens_servico os
JOIN mecanicos m ON os.mecanico_id = m.id
WHERE os.status = 'Concluida'
GROUP BY m.especialidade;