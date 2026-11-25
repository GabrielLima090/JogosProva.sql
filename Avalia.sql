create table jogos (
id serial primary key,
confronto varchar(50) not null,
modalidade varchar(50) not null,
data_partida timestamp default current_timestamp,
status varchar(50) default 'Em breve' check (status in('Acontecendo' , 'Finalizada' , 'Cancelada'))
);

create table logs_partidas (
id serial primary key,
jogo_id int,
jogador_id int,
acao varchar(50),
detalhes text,
data_log timestamp default current_timestamp
);


create table jogadores (
id serial primary key
jogo_id int references jogos(id),
nickname varchar(50) unique not null,
email varchar(100) unique not null
);

insert into jogos (confronto, modalidade, status) values
('Amistoso' , 'Asimetrico' , 'Finalizada'),
('Final' , 'Battle Royale' , 'Acontecendo'),
('Semi' , 'Duplas' , 'Cancelada');

insert into jogadores (nickname, email) values
('Vargas' , 'vargas@gmail.com'),
('Peter' , 'peter@gmail.com'),
('Ph' , 'ph@gmail.com' );

CREATE VIEW vw_jogadores_jogos AS
SELECT 
j.id AS jogo_id,
j.confronto,
j.modalidade,
j.data_partida,
j.status,
jg.id AS jogador_id,
jg.nickname,
jg.email
FROM jogadores jg
INNER JOIN jogos j ON j.id = jg.jogo_id;

SELECT * FROM vw_jogadores_jogos;

create function buscar_jogadores
returns table (
id INT,
jogo_id INT,
nickname VARCHAR(50),
email VARCHAR(100)
)
language plpgsql
as $$
begin
return query
select 
jg.id,
jg.jogo_id,
jg.nickname,
jg.email
from jogadores jg
where jg.nickname ilike '%' || termo_busca || '%'
OR jg.email ilike '%' || termo_busca || '%';
end;
$$;

SELECT * FROM buscar_jogadores;

alter table jogadores 
add column status varchar(20) default 'ativo' check (status in ('ativo', 'inativo', 'banido'));

alter table jogos 
add column jogador_id int references jogadores(id),
add column data_criacao timestamp;

create table logs_partidas (
id serial primary key,
jogo_id int,
jogador_id int,
acao varchar(50),
detalhes text,
data_log timestamp default current_timestamp
);

create trigger trg_validar_partida
before insert on jogos
for each row
execute function fn_validar_partida();

create or replace view vw_cronograma_partidas as
select 
j.id as partida_id,
j.confronto,
j.modalidade,
j.data_partida as data_agendamento,
j.status as status_partida,
(j.data_partida::date - current_date) as dias_restantes,
jg.nickname as jogador_responsavel
from jogos j
left join jogadores jg on jg.jogo_id = j.id
order by j.data_partida asc;

select * from vw_cronograma_partidas;