#include "protheus.ch"
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Validação de pergunta                                                                                                                  |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 24.01.2017                                                                                                                       |
| Descricao: Função chamada no X1_VALID do grupo de pergunta RFIN001X  ordem 10, irá validar a subconta para correta                     |
| geração do Boleto Itau                                                                                                                 |
| Empresa: KAPAZI                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User function ValidSEE()                  

local _Subconta := MV_PAR10
local _SEE01 := '000' 	 			//SubConta 000  empresa Kapazi
local _SEE02 := '002' 				//SubConta 000  empresa Albatros
local _SEE03 := '002' 				//SubConta 000  empresa Capachos
local _SEE04 := '001' 	 			//SubConta 000  empresa Kapazi Ind
local _SEE06 := '001' 	 			//SubConta 000  empresa Kapazi Licenciadora
local _SEE07 := '000' 				//SubConta 000  empresa Kapbrassul
local cFilPOS := FWCodEmp() 	// Filial posicionada


IF cFilPOS == '01' .and.  _Subconta <> _SEE01  // Kapazi
	msginfo("A SubConta será alterada para 002 conforme definições do setor Financeiro!","U_VALIDSEE")
	MV_PAR10 := '002'
	
ELSEIF 	cFilPOS == '02' .and.  _Subconta <> _SEE02  // Albatros
	msginfo("A SubConta será alterada para 002 conforme definições do setor Financeiro!","U_VALIDSEE")
	MV_PAR10 := '002'
	
ELSEIF	cFilPOS == '03' .and.  _Subconta <> _SEE03  // Capachos
	msginfo("A SubConta será alterada para 002 conforme definições do setor Financeiro!","U_VALIDSEE")
	MV_PAR10 := '002'
	
ELSEIF cFilPOS == '04' .and.  _Subconta <> _SEE04   // Kapazi Industria
	msginfo("A SubConta será alterada para 002 conforme definições do setor Financeiro!","U_VALIDSEE")
	MV_PAR10 := '002'
	
ELSEIF cFilPOS == '06' .and.  _Subconta <> _SEE06    // Kapazi Licenciadora
	msginfo("A SubConta será alterada para 002 conforme definições do setor Financeiro!","U_VALIDSEE")
	MV_PAR10 := '002'
	
ELSEIF  cFilPOS == '07' .and.  _Subconta <> _SEE07 // Kapbrassul
	msginfo("A SubConta será alterada para 002 conforme definições do setor Financeiro!","U_VALIDSEE")
	MV_PAR10 := '002'
ENDIF

return
