#INCLUDE "TopConn.ch"


User Function ATUCNN()



Local cPerg := Padr("ATUCNN",10)
Local oProcess

Private cCam   	:= ""

//CriaSX1(cPerg)
if !(Pergunte(cPerg))
	return
EndIF

oProcess := MsNewProcess():New({|lEnd| atusrcnn(@oProcess, @lEnd) },"Processando","Processando",.T.)
oProcess:Activate()

Return


Static Function atusrcnn(oProcess, lEnd)

cSql:=" SELECT * FROM "+RetSqlName('CNN')
cSql+=" WHERE D_E_L_E_T_<>'*'"
cSql+=" "
if Select('TRB01')<>0
	TRB01->(DBCloseArea())
EndIF
Tcquery cSql New Alias 'TRB01'

nCont:=0
WHILE !TRB01->(EOF())
	nCont++
	TRB01->(dbsKIP())
Enddo

oProcess:SetRegua1(ncont)
oProcess:SetRegua2(0)
nA:=0
TRB01->(dbGotop())
WHILE !TRB01->(EOF())
	nA++
	oProcess:IncRegua1("Processando usuarops...")
	oProcess:IncRegua2("Processando "+cValtoChar(nA)+" de "+ cValtoChar(NCONT) )
	DBSelectArea('CNN')
	DBSetOrder(1)
	If !CNN->(DbSeek(xFilial('CNN') + MV_PAR03 + TRB01->CNN_CONTRA))
		RecLock('CNN', .T.)
		CNN_FILIAL := TRB01->CNN_FILIAL
		CNN_CONTRA := TRB01->CNN_CONTRA
		CNN_USRCOD := MV_PAR03
		CNN_GRPCOD := ''
		CNN_TRACOD := '001'
		CNN->(MsUnlock())
	EndIF
	
	DBSelectArea('CNN')
	DBSetOrder(1)
	If CNN->(DbSeek(xFilial('CNN') + MV_PAR01 + TRB01->CNN_CONTRA))
		if !CNN->(DbSeek(xFilial('CNN') + MV_PAR02 + TRB01->CNN_CONTRA))
			RecLock('CNN', .T.)
			CNN_FILIAL := TRB01->CNN_FILIAL
			CNN_CONTRA := TRB01->CNN_CONTRA
			CNN_USRCOD := MV_PAR02
			CNN_GRPCOD := ''
			CNN_TRACOD := '001'
			CNN->(MsUnlock())
		EndIF
		
		DBSelectArea('CNN')
		DBSetOrder(1)
		If CNN->(DbSeek(xFilial('CNN') + MV_PAR01 + TRB01->CNN_CONTRA))
			RecLock('CNN', .f.)
			dbDelete()
			msUnlock()
		EndIF
	EndIF
	
	
	
	TRB01->(dbsKIP())
Enddo





Return

/*static Function CriaSX1(cPerg)
//PutSx1(cPerg,"01","Retirar","Retirar","Arquivo ","mv_ch1","C",6,0,0,"G","","USR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o usuario a ser retirado "," dos acessos aos contratos","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Inserir","Inserir","Inserir" ,"mv_ch2","C",6,0,0,"G","","USR","","","mv_par02","","","","","","","","","","","","","","","","",{"Informe o usuario a ser inserido "," dos acessos aos contratos","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Master","Master","Master" ,"mv_ch3","C",6,0,0,"G","","USR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o usuario que deve ter"," acessos a todos contratos","",""},{"","","",""},{"","",""},"")
Return*/
