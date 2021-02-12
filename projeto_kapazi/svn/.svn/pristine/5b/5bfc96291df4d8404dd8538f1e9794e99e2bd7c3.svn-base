if exists( select name
             from sysobjects
            where name = 'ProdutoPossuiCompontes_040')
  drop FUNCTION ProdutoPossuiCompontes_040
go

CREATE FUNCTION ProdutoPossuiCompontes_040(@produto VARCHAR(15))
RETURNS VARCHAR(1)
AS
BEGIN
	declare @retorno varchar(1) = 'N'
	declare @contagem int = (SELECT COUNT(*) FROM SG1040 WHERE D_E_L_E_T_<>'*' AND G1_FILIAL='' AND G1_COD = @produto)
	
	if @contagem > 0
	Begin
		set @retorno = 'S'
	End
	
	return @retorno
END

