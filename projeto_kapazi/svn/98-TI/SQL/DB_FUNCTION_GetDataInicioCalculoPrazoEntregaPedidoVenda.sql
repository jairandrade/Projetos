/*
01.	Inclusão de Item por solicitação do comercial: Reprogramação de prazo;
04.	Mudança de cadastro: Reprogramação de prazo;
06.	Pedido com item errado: Reprogramação de prazo;
*/

if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_01')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_01;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_01
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF010

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5010 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go


if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_02')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_02;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_02
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF020

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5020 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go


if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_03')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_03;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_03
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF030

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5030 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go

if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_04')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_04;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_04
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF040

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5040 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go


if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_05')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_05;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_05
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF050

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5050 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go


if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_06')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_06;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_06
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF060

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5060 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go


if exists( select name from sysobjects where name = 'GetDataInicioCalculoPrazoEntregaPedidoVenda_07')
	begin
		drop function GetDataInicioCalculoPrazoEntregaPedidoVenda_07;
	end
go

create function dbo.GetDataInicioCalculoPrazoEntregaPedidoVenda_07
(
	@Filial varchar(2),
	@Pedido varchar(6)
)
returns varchar(8) as 
begin 
	declare @retorno varchar(8) = (	SELECT TOP 1 ZF_DATA
									FROM SZF070

									WHERE D_E_L_E_T_<>'*'
										AND ZF_FILIAL = @Filial
										AND ZF_PEDIDO = @Pedido
										AND SUBSTRING(ZF_OBS,1,2) IN ('01','04')

									ORDER BY ZF_DATA DESC
								  );

	if @retorno is null
		set @retorno = (select C5_EMISSAO 
						from SC5070 
						where D_E_L_E_T_<> '*'
							and C5_FILIAL = @Filial
							and C5_NUM = @Pedido
						);

	if @retorno is null
		set @retorno = '';

	return @retorno;
end 
go