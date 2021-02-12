
create PROCEDURE EstuturaDosProdutosProduzidosNoPeriodo_040(@data_inicio varchar(8),
														@data_fim varchar(8),
														@produto_ini varchar(15) = '',
														@produto_fim varchar(15) = 'ZZZZZZZZZ')
as begin	
	-- CRIA TABELA TEMPORARIA
	if 0 = (select COUNT(*) from tempdb.dbo.sysobjects o where o.xtype in ('U') and o.id = object_id(N'tempdb..#resultado'))
		begin
			create table #resultado 
			(
				pai varchar(15)
				,nivel varchar(2)
				,produzido varchar(15)
				,produzido_descricao varchar(100)
				,componente varchar(15)
				,componente_descricao varchar(100)
				,quantidade float 
				,validade_ini varchar(8)
				,validade_fim varchar(8)
				,versao varchar(3)
			)
			-- CRIA INDICE DE PERFORMANCE DA TABELA TEMPORARIA
			CREATE CLUSTERED INDEX IDX_C_NIVEL_PAI_PRODUZIDO_COMPONENTE ON #resultado(nivel,pai,produzido,componente)
		end
	
	
	-- CRIA CURSOS PRA SER MAIS RAPIDO
	declare produtos cursor local fast_forward for 
		-- A QUERY AQUI DEVE TER NA PRIMEIRA COLUNA OS PRODUTOS QUE DEVEM TER A ESTRUTURA PESQUISADA
		-- NO CASO PEGA TODAS AS ESTRUTURAS DE TODOS OS PRODUTOS PRODUZIDOS NO PERIODO
		SELECT DISTINCT 
			D3_COD

		FROM SD3040

		WHERE 
				D_E_L_E_T_ <> '*'
			AND D3_FILIAL = '01'
			AND D3_CF = 'PR0'
			AND D3_ESTORNO <> 'S'
			AND D3_EMISSAO >= @data_inicio
			AND D3_EMISSAO <= @data_fim
			AND D3_COD >= @produto_ini
			AND D3_COD <= @produto_fim

		ORDER BY 1
	-- ABRE O CURSOR
	open produtos
	
	--DECLARE VARIAVEL A SER USADA
	declare @produto varchar(15)
	
	-- BUSCA PRIMEIRO REGISTRO DO CURSOR
	fetch next from produtos into @produto
	-- ENQUANTO CONSEGUIR PEGAR O REGISTRO
	while @@FETCH_STATUS = 0
		begin 
			-- VALIDA SE O PRODUTO TEM ESTRUTURA
			if dbo.ProdutoPossuiCompontes_040(@produto) = 'S'
				begin
					-- EXECUTA A PROCEDURE PRA OBTER OS DADOS DA ESTRUTURA E INSERE NA TABELA TEMPORARIA
					exec dbo.EstruturaProduto_040 @produto,'',0,'N'
					--EstruturaProduto_040 (@pa varchar(15),@produto varchar(15) = '',@nivel int = 0,@select_no_final char(1) = 'S')
				end
			
			-- BUSCA PROXIMO REGISTRO
			fetch next from produtos into @produto
		end
	-- AO FINAL FECHA O CURSOR
	close produtos
	-- DESALOCA MEMORIA
	deallocate produtos
	
	-- SELECIONA OS REGISTROS DA TABELA TEMPORARIA
	select * from #resultado order by pai,versao,nivel,produzido,componente,quantidade
	
end



	

