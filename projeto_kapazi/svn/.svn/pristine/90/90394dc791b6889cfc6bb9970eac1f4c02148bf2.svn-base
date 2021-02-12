
create procedure EstruturaProdutos_040( @produto_ini varchar(15),@produto_fim varchar(15))
as
begin
	declare produtos cursor local fast_forward for 
		SELECT DISTINCT 
			B1_COD

		FROM SB1010

		WHERE 
				D_E_L_E_T_ <> '*'
			AND B1_COD >= @produto_ini
			AND B1_COD <= @produto_fim

		ORDER BY 1
	open produtos
	
	declare @produto varchar(15)
	
	if 0 = (select COUNT(*) from tempdb.dbo.sysobjects o where o.xtype in ('U') and o.id = object_id(N'tempdb..#resultado'))
		begin
			create table #resultado 
			(
				nivel varchar(2)
				,pai varchar(15)
				,produzido varchar(15)
				,componente varchar(15)
				,quantidade float 
				,validade_ini varchar(8)
				,validade_fim varchar(8)
			)
			CREATE CLUSTERED INDEX IDX_C_NIVEL_PAI_PRODUZIDO_COMPONENTE ON #resultado(nivel,pai,produzido,componente)
			
		end
	
	fetch next from produtos into @produto
	while @@FETCH_STATUS = 0
		begin 
			if dbo.ProdutoPossuiCompontes_040(@produto) = 'S'
				begin
					exec dbo.EstruturaProduto_040 @produto,'',0,'N'		
				end
			fetch next from produtos into @produto
		end
	close produtos
	deallocate produtos
	
	select * from #resultado order by pai,nivel,componente
end
	--drop index IDX_C_NIVEL_PAI_PRODUZIDO_COMPONENTE on #resultado
	--drop table #resultado
	