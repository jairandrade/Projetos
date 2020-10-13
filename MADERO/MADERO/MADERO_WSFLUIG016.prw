#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOTVS.CH"


User Function WSFLUIG016( aVetor, cOper, cEmp, cFil)
Local cMsg := ""
Local cRet := ""
Local aReturn := {}
private lMsErroAuto := .F.

	DO CASE
	         CASE 	cOper == 1
	         	aReturn := IncluiSB1( aVetor, cEmp, cFil )
	         	
	         CASE	cOper == 2
	         	aReturn := AlteraSB1( aVetor, cEmp, cFil )
	      
	         OTHERWISE
	         	cMsg := .F.
	         	
	ENDCASE
 
Return aReturn

Static Function IncluiSB1( aVetor, cEmp, cFil )
	Local cRet 	:= .F.
	Local aCod	:= {}
	Local cMsg := ""
	Local aReturn := {cRet,cMsg}
	Local cPath := ""
	Local cNomeArq := ""
	Local cPathTmp		:= "\wsfluigerrors\"
	Local cArqTmp 		:= "WSPRODUTOFLUIG_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
	private lMsErroAuto := .F.

	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	cNumEmp := cEmpAnt+cFilAnt
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)

	BeginTran()

	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
 
	If lMsErroAuto
		fCriaDir( cPathTmp )
		MostraErro( cPathTmp, cArqTmp )
		cMsg += " " + MemoRead( cPathTmp + cArqTmp )
		FErase( cPathTmp + cArqTmp )
		aReturn := {cRet,cMsg}
	 	DisarmTransaction()
	Else
		cRet := .T.
		aReturn := {cRet,cMsg}
	Endif
	
	EndTran()

Return aReturn //cRet

Static Function AlteraSB1( aVetor, cEmp, cFil )
Local cMsg := ""
Local cRet 	:= .F.
Local aCod	:= {}
Local aReturn := {cRet,cMsg}
Local cPath := ""
Local cPathTmp		:= "\wsfluigerrors\"
Local cArqTmp 		:= "WSPRODUTOFLUIG_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Local cNomeArq := "" 
private lMsErroAuto := .F.

	If aVetor[49][2] == ""
		aDel(aVetor, 49)
		aSize(aVetor, 48)
	Endif
	
	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	cNumEmp := cEmpAnt+cFilAnt
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)

	BeginTran()

	MSExecAuto({|x,y| Mata010(x,y)},aVetor,4)
 
	If lMsErroAuto
		fCriaDir( cPathTmp )
		MostraErro( cPathTmp, cArqTmp )
		cMsg += " " + MemoRead( cPathTmp + cArqTmp )
		FErase( cPathTmp + cArqTmp )
	 	// cMsg := MostraErro()
		aReturn := {cRet,cMsg}
	 	DisarmTransaction()
	Else
		cRet := .T.
		aReturn := {cRet,cMsg}
	Endif
	
	EndTran()
	
Return aReturn //cRet

Static Function fCriaDir(cPatch, cBarra)
	
Local lRet   := .T.
Local aDirs  := {}
Local nPasta := 1
Local cPasta := ""
DEFAULT cBarra	:= "\"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criando diretório de configurações de usuários.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDirs := Separa(cPatch, cBarra)
For nPasta := 1 to Len(aDirs)
	If !Empty (aDirs[nPasta])
		cPasta += cBarra + aDirs[nPasta]
		If !ExistDir (cPasta) .And. MakeDir(cPasta) != 0
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nPasta
	
Return lRet