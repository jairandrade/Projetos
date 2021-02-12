
alter procedure EstruturaProduto_040 (@pa varchar(15),@produto varchar(15) = '',@nivel int = 0,@select_no_final char(1) = 'S')
as 
begin
	declare @nivelini int = @nivel
	if @nivel = 0
		begin
			set @nivel = 1
		end
	else
		begin
			set @nivel = @nivel + 1
		end
		
	if @produto = ''
		set @produto = @pa
		
	SET @pa = RTRIM(@pa)
	
	DECLARE componentes CURSOR LOCAL FAST_FORWARD FOR
		SELECT
			RTRIM(G1_COD)
			,RTRIM(G1_COMP)
			,G1_QUANT
			,G1_INI
			,G1_FIM
			,RTRIM(G1_TRT)
			,RTRIM(COD.B1_DESC)
			,RTRIM(COMP.B1_DESC)
		FROM SG1040 SG1
			LEFT OUTER JOIN SB1010 COD ON COD.D_E_L_E_T_<>'*'
				AND COD.B1_FILIAL=''
				AND COD.B1_COD = G1_COD
			LEFT OUTER JOIN SB1010 COMP ON COMP.D_E_L_E_T_<>'*'
				AND COMP.B1_FILIAL=''
				AND COMP.B1_COD = G1_COMP

		WHERE 
				SG1.D_E_L_E_T_<>'*'
			and G1_FILIAL =''
			and G1_COD = @produto
			
		order by 1,G1_TRT,2
	OPEN componentes
	
	declare @produzido varchar(15)
	declare @componente varchar(15)
	declare @quantidade float
	declare @validade_ini varchar(8)
	declare @validade_fim varchar(8)
	declare @versao varchar(3)
	declare @produzido_descricao varchar(100)
	declare @componente_descricao varchar(100)
	
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
			CREATE CLUSTERED INDEX IDX_C_NIVEL_PAI_PRODUZIDO_COMPONENTE ON #resultado(nivel,pai,produzido,componente)
			
		end	
	
	FETCH NEXT FROM componentes into @produzido,@componente,@quantidade,@validade_ini,@validade_fim,@versao,@produzido_descricao,@componente_descricao
	While @@FETCH_STATUS = 0
		begin
			declare @char_nivel char(2) = RIGHT('00' + CONVERT(VARCHAR(2),@nivel), 2)
			--print 'insert estrutura '+@produzido+' '+@componente
			
			if (select COUNT(*) from #resultado where nivel = '00' and pai=@pa and produzido='' and componente='' and versao = @versao) = 0
				begin
					--print 'insert pa '+@pa
					insert into #resultado values (@pa,'00','','','','',0,'','',@versao)
				end
				
			insert into #resultado values(@pa,@char_nivel,@produzido,@produzido_descricao,@componente,@componente_descricao,@quantidade,@validade_ini,@validade_fim,@versao)
		
			if dbo.ProdutoPossuiCompontes_040(@componente) = 'S'
				begin
					--print 'exec procedure '+@pa+@componente+convert(char(2),@nivel)
					exec EstruturaProduto_040 @pa,@componente,@nivel
				end
				
			FETCH NEXT FROM componentes into @produzido,@componente,@quantidade,@validade_ini,@validade_fim,@versao,@produzido_descricao,@componente_descricao
		end
		
	CLOSE componentes
	DEALLOCATE componentes
	
	if @nivelini = 0 and @select_no_final = 'S'
		begin
			select * from #resultado order by pai,versao,nivel,produzido,componente,quantidade
		end
end

