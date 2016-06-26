-- Instrucao para comparar os estilos duplicados na tabela layer_styles
select * from  layer_styles t1
inner join layer_styles t2  on (t1.f_table_name = t2.f_table_name) AND t1.id=t2.id order by t1.f_table_name
