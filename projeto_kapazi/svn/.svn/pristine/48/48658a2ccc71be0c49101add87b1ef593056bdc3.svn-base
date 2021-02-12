#INCLUDE "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include 'protheus.ch'
/*/{Protheus.doc} nomeFunction
(long_description)
@type  Function
@author user
@since 20/08/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function VALPRODPV()
Local lRet  := .t.
Local cProd := ""
Local nAx   := 0
Local cPessoas  := SuperGetMV('KP_ACVLPV',.F., '000470/000287/000062/000304/000167/000309/000045/000199/000373/000195/000494/000404/')

If !(__cUserID $ Alltrim(cPessoas))

    nAx :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
    cProd := M->C6_PRODUTO //aCols[n,nAx]

    DBselectArea('SZ3')
    SZ3->(dbSetOrder(1))
    SZ3->(DbGoTop())
    If (SZ3->(dbSeek((xFilial("SZ3") + cProd))))

        If !ValidPrd() //Valida se o produto possui bloqueio temporário
            lRet	:=	.F.
        EndIf

    EndIf

EndIf

Return(lRet)

//Valida o produto
Static Function ValidPrd(cProd)
Local lRet := .t.

If cEmpAnt == "01"
	
	If cFilAnt =="01" //EMPRESA 01 FILIAL 01
		If Alltrim(SZ3->Z3_EMP1_01) == "1"
			lRet	:=	.F.
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="02" //EMPRESA 01 FILIAL 02
		If Alltrim(SZ3->Z3_EMP1_02) == "1"
			lRet	:=	.F.
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="03" //EMPRESA 01 FILIAL 03
		If Alltrim(SZ3->Z3_EMP1_03) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="04" //EMPRESA 01 FILIAL 04
		If Alltrim(SZ3->Z3_EMP1_04) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf		

	If cFilAnt =="05" //EMPRESA 01 FILIAL 05
		If Alltrim(SZ3->Z3_EMP1_05) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

EndIf
//FIM EMPRESA 01

//INICIO DA EMPRESA 02
If cEmpAnt == "02"
	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP2_01) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

EndIf
//FIM EMPRESA 02

//INICIO EMPRESA 03
If cEmpAnt == "03"
	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP3_01) == "1"
			lRet	:=	.F.
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf 	
EndIf
//FIM EMPRESA 03	

//EMPRESA 04
If cEmpAnt == "04"

	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP4_01) == "1"
			lRet	:=	.F.   
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="02" //FILIAL 02
		If Alltrim(SZ3->Z3_EMP4_02) == "1"
			lRet	:=	.F.
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf 	

	If cFilAnt =="03" //FILIAL 03
		If Alltrim(SZ3->Z3_EMP4_03) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="04" //FILIAL 04
		If Alltrim(SZ3->Z3_EMP4_04) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="05" //FILIAL 05
		If Alltrim(SZ3->Z3_EMP4_05) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="06" //FILIAL 06
		If Alltrim(SZ3->Z3_EMP4_06) == "1"
			lRet	:=	.F. 
            MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

	If cFilAnt =="07" //FILIAL 07
		If Alltrim(SZ3->Z3_EMP4_07) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf

EndIf
//FIM EMPRESA 04	


//EMPRESA 05
If cEmpAnt == "05"

	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP5_01) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf 	

EndIf
//FIM EMPRESA 05

//EMPRESA 06
If cEmpAnt == "06"

	//FILIAL 01     
	If cFilAnt =="01"
		If Alltrim(SZ3->Z3_EMP6_01) == "1"
			lRet	:=	.F. 
			MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! ", "KAPAZI")
		EndIf
	EndIf 	

EndIf
//FIM EMPRESA 06

Return(lRet)
