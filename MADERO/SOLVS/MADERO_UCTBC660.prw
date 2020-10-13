#INCLUDE "CTBC660.ch"
#INCLUDE "Protheus.ch"
#Include "TopConn.ch"
#Include "TBICONN.ch"

#define ALIASDOC	1
#define DATADOC		2
#define NRODOC		3
#define MOEDOC 		4
#define VLRDOC 		5
#define NODIA 		6

STATIC cRetF3Mark := Space(150) 

//altera��o feita no changeset:74459 
/*
�����������������������������������CONFE������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBC660   � Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para auditoria da contabilidade. Ele demonstrara   ���
���          �se o que foi gerado pelos modulos existe na contabilidade,  ���
���          �assim como se o que ha na contabilidade tambem possui seu   ���
���          �documento correlativo no modulo.						      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBC660()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil		                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//Customiza��o realizada para exibir auditoria cont�bil sem o uso do Controle Correlativo
//Calandrine Maximiliano
//08_04_2018
User Function UCTBC660()

Local cRetSegOfi	:= ""
Local nOpc 			:= 0

Local aCfgDoc		:= {}
Local aButtons		:= {}                                                          
Local aSays			:= {}
Local aModSel		:= {}

Local nI			:= 0
Local nResult		:= 0		

Local bParam		:= {|| aModSel := Ctbc66Param() }
Local bBtnOk		:= {||	Iif(aModSel[4] == "1" .And. aModSel[7] == .F. , aCtbc66Fil := AdmGetFil(), aCtbc66Fil := {cFilAnt} ),;
                            Iif(Empty(aCtbc66Fil),Help(" ",1,"CTBC660",,STR0068,1,0),;  //## "N�o foi selecionada nenhuma filial."		
                            (aCfgDoc 	:= CtbCQCLoad(aModSel[1]),;
							Processa( {|lEnd| CtbC66GenInf(aModSel,aCfgDoc,aResultSet)},STR0021,STR0019 ,.T.),; 
							CtbC66Scr(aModSel[1],aResultSet)) ) }

Private aResultSet	:= {}	//Veja a documentacao destes array no final do arquivo

Private aCtbc66Moe 	:= CtbC66GMoe()
Private aCtbc66Fil	:= {} 
Private cSelecOrd   := "1"
Private cGetFilDoc  := Space(30)
Private cOnlyAlias  := Space(150)
Private cExceAlias  := Space(150)
Private oOnlyAlias  := Nil
Private oExceAlias  := Nil
Private nSeqUnique  := 0
Private aCabMod		:= {}
Private aCabCtb		:= {}//cabecalho do browse dos dados da contabilidade
Private aTipoMod	:= {}
Private aTipoCtb	:= {}
Private lCheckBo1   := .T.
Private lCheckBo2   := .T.
Private lCheckBo3   := .T.
Private lCheckBo4   := .T.

//MsAguarde({|| CriaCTL()},"Aguarde...","Aguarde...Carregando estruturas (CTL).")
//Alterar CVA e CTL para modo totalmente compartilhado
//CVA o pr�prio sistema recria
//CTL � populada pela fun��o acima

//Ignora Controle Correlativo 
/*
cRetSegOfi := GetMv("MV_SEGOFI")

If Empty(cRetSegOfi) .or. alltrim(cRetSegOfi) == "0"
	Help(" ",1,"CTBC660_NODIA",,STR0033,1,0)	 //##"O uso do controle diario (n�mero correlativo) est� desabilitado."
	Return()
Endif
*/
	
aAdd(aButtons,{5,.t.,bParam})
aAdd(aButtons,{1,.t.,{|| nOpc := 1, oDlg:End() } })
aAdd(aButtons,{2,.t.,{|| oDlg:End() } })

aAdd(aSays,STR0001)	//## "Programa com o objetivo de demonstrar um comparativo entre"
aAdd(aSays,STR0002)	//## "documentos dos m�dulos do sistema e a contabilidade."
aAdd(aSays,"")
aAdd(aSays,STR0003) //## "Para tal, em par�metros, selecione um ou mais m�dulos."
aAdd(aSays,STR0004) //## "O per�odo definido ser� considerado para os lan�amentos cont�beis."

FormBatch(STR0005,aSays,aButtons) //## "Relat�rio de Auditoria"

If nOpc == 1
	If !Empty(aModSel)
		If len(aModSel[1]) > 0
			Eval(bBtnOk)
		Else
			Help(" ",1,"CTBC660",,STR0006,1,0)	//#"N�o foi selecionado nenhum m�dulo."
		Endif	
	Else
		Help(" ",1,"CTBC660",,STR0007,1,0)	//#"N�o houve parametriza��o definida."			
	Endif	
Endif	

For nI := 1 to Len(aCtbc66Fil)

	For nResult := 1 to Len(aResultSet[nI,2,1,2])
		FreeObj(aResultSet[nI,2,1,2,nResult,1])
		aResultSet[nI,2,1,2,nResult,1] := Nil
		DelClassIntf()
	Next nResult

Next nI

FreeObj(oOnlyAlias)
oOnlyAlias := Nil
FreeObj(oExceAlias)
oExceAlias := Nil

aSize(aResultSet,0)

DelClassIntf()

Return()   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66Param� Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tela de parametrizacao da auditoria. Definicao do periodo   ���
���          �de movimentacoes e de quais modulos se vai auditar.		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66Param()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array	- Tipo: A 	                                          ���
���          �	Array[1] - Tipo: A => Array com os modulos selecionados	  ���
���          �	Array[2] - Tipo: D => data de inicio do periodo     	  ���
���          �	de contabilizacao								     	  ���
���          �	Array[3] - Tipo: D => data do final do periodo     	  	  ���
���          �	de contabilizacao								     	  ���
���          �	Array[4] - Tipo: C => Seleciona Filiais?         	  	  ���
���          �		"1" = Sim									     	  ��� 
���          �		"2" = Nao									     	  ��� 
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

*/
Static Function Ctbc66Param()

Local oDlg
Local oScrLayer		:= fwLayer():New()
Local oPnlDlg		
Local oGrpDlg
Local oGetDI
Local oGetDF
Local oListMod
Local oSelecFil
Local oSelecOrd
Local oSelecMvt
local oCheck

Local aSizeDlg		:= FwGetDialogsize(oMainWnd)
Local aListMod		:= CtbC660LoadMod()
Local aSelected		:= {}
Local aSelecFil		:= {"1="+STR0008,"2="+STR0009}				//Sim###N�o

Local aSelecMvt		:= {"1="+STR0057,"2="+STR0056,"3="+STR0058}	//N�o Conferidos###Conferidos###Todos
Local nHeight		:= aSizeDlg[3] * 0.80
Local nWidth        := aSizeDlg[4] * 0.80
Local nOpc			:= 0

Local cSelecFil		:= "2"
Local cSelecMvt		:= "3"

Local dDataI		:= FirstDay(dDataBase)
Local dDataF		:= LastDay(dDataBase)

Local lCheckNDiv		:=.F.
Local lChkThd			:=.F.
Local nThrdDia 			:= GetMV("MV_660TDIA",,4)

Local bBtnOk		:= {|| 	Iif( ChkModActive(aListMod), nOpc := 1, nil ),; 
							Iif(nOpc == 1, oDlg:End(),nil) }
Local bBtnCancel	:= {|| oDlg:End()}							
Local bEnchBar		:= {|| EnchoiceBar(oDlg,bBtnOk,bBtnCancel) }

Local oGetFilDoc

Local aSelecOrd   	:= {"1="+STR0008,"2="+STR0009}				//Sim###N�o

DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0005 PIXEL STYLE DS_MODALFRAME of oMainWnd //## "Relat�rio de Auditoria"

	oScrLayer:init(oDlg,.F.)
	
	oScrLayer:addLine("Linha",100,.t.)
	oScrLayer:addCollumn("Coluna",100,.t.,"Linha")	
	oScrLayer:addWindow("Coluna","Janela",STR0010,100,.f.,.t.,{||},"Linha")	 //## "Parametriza��o"
    
    oPnlDlg := oScrLayer:getWinPanel("Coluna","Janela","Linha")
	oPnlDlg:FreeChildren()

	nWidth *= 0.488
	nHeight*= 0.12
	
	oGrpDlg := tGroup():New(0,0,nHeight,nWidth,STR0011,oPnlDlg,,,.T.)	//##"Per�odo de Verfica��o"
	
	@ 15,005 Say STR0012 PIXEL OF oPnlDlg //## "Data Inicial"
	@ 15,045 MsGet oGetDI Var dDataI VALID ( IIF(lChkThd .And. !Empty(dDataF) .And. (dDataF - dDataI) < nThrdDia,.T.,IIF(Empty(dDataF) .Or. lChkThd == .F.,.T.,.F.)) ) Size 40,008 PIXEL OF oPnlDlg

	@ 30,005 Say STR0013 PIXEL OF oPnlDlg //## "Data Final"
	@ 30,045 MsGet oGetDF Var dDataF VALID ( IIF(lChkThd .And. !Empty(dDataI) .And. (dDataF - dDataI) < nThrdDia,.T.,IIF(Empty(dDataI) .Or. lChkThd == .F.,.T.,.F.)) ) Size 40,008 PIXEL OF oPnlDlg	
	
	@ 15,110 Say STR0014 PIXEL OF oPnlDlg //## "Seleciona Filiais"
	@ 15,160 ComboBox oSelecFil Var cSelecFil Items aSelecFil When (!lChkThd) Size 50,008 PIXEL OF oPnlDlg
	
	@ 30,110 Say "Ordena Doc." PIXEL OF oPnlDlg
	@ 30,160 ComboBox oSelecOrd Var cSelecOrd Items aSelecOrd Size 50,008 PIXEL OF oPnlDlg
	                               
	@ 15,235 Say STR0034 PIXEL OF oPnlDlg //## "Documento j� conferido
	@ 15,305 ComboBox oSelecMvt Var cSelecMvt Items aSelecMvt Size 60,008 PIXEL OF oPnlDlg
		
	@ 30,235 Say "Filtra Documento" PIXEL OF oPnlDlg
	@ 30,305 MsGet oGetFilDoc Var cGetFilDoc PICTURE "@!" Size 60,008 PIXEL OF oPnlDlg	
		
	@ 15,385 Say "Somente Tabelas" PIXEL OF oPnlDlg
	@ 15,435 MsGet oOnlyAlias Var cOnlyAlias F3 "CTLAUD" PICTURE "@!" Size 80,008 PIXEL OF oPnlDlg	
		
	@ 30,385 Say "Exceto Tabelas" PIXEL OF oPnlDlg
	@ 30,435 MsGet oExceAlias Var cExceAlias F3 "CTLAUD" PICTURE "@!" Size 80,008 PIXEL OF oPnlDlg	
		
	@ 45,005 CHECKBOX oCheckNDiv VAR lCheckNDiv Size 100,009 PROMPT STR0060 When (.T.) On Change() Of oPnlDlg //adicionado filtro para n�o divergentes //##"Seleciona n�o divergentes?"
	@ 45,110 CHECKBOX oChkThd    VAR lChkThd	Size 100,009 PROMPT 'Threads' When ((dDataF - dDataI) < nThrdDia) On Change() Of oPnlDlg //adicionado filtro para n�o divergentes //##"Seleciona n�o divergentes?"
	
	oGrpDlg2 := tGroup():New(nHeight + 5,0,nHeight+147,nWidth,STR0015,oPnlDlg,,,.T.) //## "M�dulos"
	                                                        //"Nro Modulo","Descricao","Desc. Extendida"
	                                                        
	@ nHeight + 15,002 ListBox oListMod Fields  HEADER " ",STR0016,STR0017,STR0018 Size nWidth-2,nHeight * 2.30 Pixel Of oPnlDlg ON  dblClick( aListMod[oListMod:nAt][1] := !aListMod[oListMod:nAt][1] , oListMod:Refresh())

	oListMod:lShowHint := .T.
		    
	oListMod:SetArray(aListMod)
		
	oListMod:bLine := {|| {;
							Iif(aListMod[oListMod:nAT,01], LoadBitmap(GetResources(),"CHECKED") , LoadBitmap(GetResources(), "UNCHECKED") ),;
							aListMod[oListMod:nAT,02],;
							aListMod[oListMod:nAT,03],;
							aListMod[oListMod:nAT,04]}}
    
	oListMod:bHeaderClick := {|| Ctbc66ChkAll(aListMod,oListMod)}	   	
oDlg:Activate(,,,.T.,,,bEnchBar)

If nOpc == 1
	aEval(aListMod,{|x| Iif(x[1], aAdd(aSelected,{strzero(x[2],2),x[4]}),nil) })	
Endif

FreeObj(oDlg)
oDlg := Nil
FreeObj(oScrLayer)	
oScrLayer := Nil
FreeObj(oPnlDlg)	
oPnlDlg := Nil
FreeObj(oGrpDlg)
oGrpDlg := Nil
FreeObj(oGetDI)
oGetDI := Nil
FreeObj(oGetDF)
oGetDF := Nil
FreeObj(oListMod)
oListMod := Nil
FreeObj(oSelecFil)
oSelecFil := Nil
FreeObj(oSelecOrd)
oSelecOrd := Nil
FreeObj(oSelecMvt)
oSelecMvt := Nil
FreeObj(oCheck)
oCheck := Nil
FreeObj(oGetFilDoc)
oGetFilDoc := Nil
DelClassIntF()

Return({aSelected,dDataI,dDataF,cSelecFil,cSelecMvt,lCheckNDiv,lChkThd})

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66ChkAll� Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Marcacao e desmarcacao dos modulos 					       ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66ChkAll(aListMod,oListMod)                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros�aListMod	- Tipo: A => Lista dos modulos                     ���
���          �oListMod	- Tipo: O => Objeto ListBox 	                   ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nil			 	                                           ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������

*/
Static Function Ctbc66ChkAll(aListMod,oListMod)

Local nI		:= 0
Local nQtdOn	:= 0

aEval(aListMod,{|x| If(x[1],nQtdOn++,nil) })

For nI := 1 to len(aListMod)
	
	If aListMod[nI,1] .and. nQtdOn == len(aListMod) 
		aListMod[nI,1] := .f.	
	Else
		aListMod[nI,1] := .t.
	Endif
	
Next nI

oListMod:Refresh()

Return()

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ChkModActive� Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se ha pelo menos UM modulo selecionado			       ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �ChkModActive(aListMod)		                               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�aListMod	- Tipo: A => Lista dos modulos                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �lRet	- Tipo: L => .t., validado                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ChkModActive(aListMod)

Local nI	:= 0

Local lRet	:= .f.

For nI := 1 to len(aListMod) 
	If aListMod[nI,1]
		lRet := .t.
		Exit
	Endif	
Next nI

If !lRet
	Help(" ",1,"ChkModActive",,STR0006,1,0)	//#"N�o foi selecionado nenhum m�dulo."
Endif

Return(lRet)


/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC660LoadMod� Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Monta a lista de modulos que integram com a contabilidade	     ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC660LoadMod()				                                 ���
����������������������������������������������������������������������������Ĵ��
���Parametros�        	                                                     ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Lista dos modulos                           ���
���          �	aRet[n,1]- Tipo: L => Se possui selecao ou nao, .t., possui  ���
���          �	aRet[n,2]- Tipo: N => nro do modulo						     ���
���          �	aRet[n,3]- Tipo: C => Descricao curta do modulo			     ���
���          �	aRet[n,5]- Tipo: C => Descricao extendida do modulo	 	     ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static function CtbC660LoadMod() 

Local cQry 		:= "SELECT DISTINCT CVA_MODULO FROM " + RetSQlName("CVA") + " WHERE D_E_L_E_T_ = ' ' ORDER BY CVA_MODULO "

Local aModulo	:= RetModName()
Local aRet		:= {}

Local nPos		:= 0

cQry := ChangeQuery(cQry)

If Select("TRBCVA") > 0
	TRBCVA->(DbCloseArea())  
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCVA", .T., .F.)

While TRBCVA->(!eof())      

	If ( nPos :=  aScan(aModulo,{|x| x[1] == Val(TRBCVA->CVA_MODULO) }) ) > 0
		aAdd(aRet, {.f.,aModulo[nPos,1],aModulo[nPos,2],aModulo[nPos,3]} )
	Endif

	TRBCVA->(DbSkip())
EndDo

/*
If ( nPos :=  aScan(aModulo,{|x| alltrim(x[2]) == "SIGACTB" }) ) > 0
	aAdd(aRet, {.f.,aModulo[nPos,1],aModulo[nPos,2],aModulo[nPos,3]} )
Endif
*/

TRBCVA->(DbCloseArea())

Return(aRet)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC66GenInf  � Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Carrega em memoria as informacoes necessarias para  o relatorio���
���          �de auditoria.													 ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC66GenInf(aParams,aCfgDoc,aResult)                          ���
����������������������������������������������������������������������������Ĵ��
���Parametros�aParams	- tipo: A => Parametros deifinidos pelo usuario      ���
���          �aCfgDoc	- tipo: A => Configuracao do arquivo do modulo       ���
���          �aResult	- tipo: A => Array com os dados dos comparativos     ���
���          �modulo X contabilidade									     ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Lista dos modulos                           ���
���          �	aRet[n,1]- Tipo: L => Se possui selecao ou nao, .t., possui  ���
���          �	aRet[n,2]- Tipo: N => nro do modulo						     ���
���          �	aRet[n,3]- Tipo: C => Descricao curta do modulo			     ���
���          �	aRet[n,5]- Tipo: C => Descricao extendida do modulo	 	     ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function CtbC66GenInf(aParams,aCfgDoc,aResult)

Local nP		:= 0
Local nI		:= 0
Local nX		:= 0

Local aSelected 	:= aClone(aParams[1])
                                                        
Local cDtIni		:= dtos(aParams[2])		//Data Inicial
Local cDtfim		:= dtos(aParams[3])     //Data Final
Local cSelecMvt   := aParams[5]           //Movimentos
local lCheckNDiv	:= aParams[6]			//Mostra n�o divergentes
Local cNameFil		:= ""
Local nTrbCtl := 0
Local nCount := 0

//#TB Mult-Thread
Local aNwRes1	:= {}
Local aNwRes2	:= {}
Local aNwRes3	:= {}
Local aNwRes4	:= {}
Local aNwRes5	:= {}
Local aNwRes6	:= {}
Local aNwRes7	:= {}
Local aNwRes8	:= {}
Local aNwRes9	:= {}
Local aNwRes10	:= {}
Local aThreads 		:= {} 
Local nThreads 		:= GetMV("MV_660THRD",,4)
Local nLoopThread	:= 0
Local lThrdLivre 	:= .F.
Local nLoopLista	:= 1
Local nContThreads	:= 0
Local nI			:= 0
local nJ			:= 0
Local aInfo			:= {}
Local nLoopTD		:= 0
Local lThread		:= aParams[7]	//Executa com threads
Local nPosCpy		:= 0
Local nResult		:= 0
Local aTrab			:= {}
Local dTrab			:= STOD('')

Local cAlias 	:= ''
Local cQuery := ''
Local aFields	:= {}

Private cChaveT		:= CriaTrab(,.F.)
//#TB Mult-Thread Fim

If lThread

	dTrab := STOD(cDtIni)

	While dTrab <= STOD(cDtFim)
		AAdd(aTrab,{DTOS(dTrab),DTOS(dTrab)})
		dTrab++
	EndDo


EndIf

QryTabMod(aSelected)

For nI := 1 to len(aCtbc66Fil)
	
    cNameFil := Alltrim(SM0->(GetAdvFVal("SM0","M0_FILIAL",cEmpAnt+aCtbc66Fil[nI],1,"")))
	
	aAdd(aResult,{aCtbc66Fil[nI]+"|"+cNameFil,Nil})	
	
	aResult[nI,2]  := {}
	
	For nX := 1 to len(aSelected)
		aAdd(aResult[nI,2],{aSelected[nX,1]+"|"+aSelected[nX,2],nil,nil})	
	Next nX	
	
	
	If Select("TRBCTL") > 0

		Count to nTrbCtl
		
		TRBCTL->(DbGoTop())      
	    
		While TRBCTL->(!Eof())  
			If Alltrim(TRBCTL->CTL_ALIAS) $ cOnlyAlias .And. Alltrim(TRBCTL->CTL_ALIAS) # cExceAlias   //#TB
				nP := aScan(aCfgDoc,{|x| alltrim(x[ALIASDOC]) == Alltrim(TRBCTL->CTL_ALIAS) })
				
				If nP > 0      
					
					If !lThread
						U_FillInfMod(TRBCTL->CTL_ALIAS,cDtIni,cDtfim,aCfgDoc[nP],aResult[nI,2],TRBCTL->CVA_MODULO,aCtbc66Fil[nI],cSelecMvt,lCheckNDiv,nTrbCtl,TRBCTL->(RECNO()),,,,,cOnlyAlias,cExceAlias,cSelecOrd,cGetFilDoc,nSeqUnique,nLoopLista)
					Else
					
						//#TB Mult+Thread
						For nLoopThread := 1 to nThreads
				
							Aadd( aThreads , "cThrT"+cChaveT+"_"+StrZero(nLoopThread,2) )
							
							ClearGlbValue( "cThrT"+cChaveT+"_"+StrZero(nLoopThread,2) )
							PutGlbValue( "cThrT"+cChaveT+"_"+StrZero(nLoopThread,2) , "L" ) // L = Thread livre | E = Thread em uso
							GlbUnLock()
							
						Next nLoopThread
			
						//�����������������������������������������������������������������������������Ŀ
						//�Variavel para armazenar os IDs das Threads utilizadas no calculo multithread �
						//�������������������������������������������������������������������������������
						ClearGlbValue( "cThrT"+cChaveT+"_IDThread" )
						PutGlbValue( "cThrT"+cChaveT+"_IDThread" , "" )
						GlbUnLock()
						ProcRegua(Len(aTrab))
						For nLoopLista := 1 to Len(aTrab)
														
							//�������������������������������������������������������������������������Ŀ
							//� Executa enquanto nao encontrar uma thread livre                         �
							//���������������������������������������������������������������������������
							lThrdLivre := .F.
							While !lThrdLivre .And. !KillApp() .and. !lEnd
								
								//�������������������������������������������������������������������������Ŀ
								//� Busca uma thread livre para executar o calculo mensal                   �
								//���������������������������������������������������������������������������
								For nLoopThread := 1 to nThreads
									
									//�������������������������������������������������������������������������Ŀ
									//� Verifica se a thread esta disponivel - "L"=Livre / "E"=Em uso           �
									//���������������������������������������������������������������������������
									If GetGlbValue( aThreads[nLoopThread] ) == "L" // verifica se a thread esta liberada
										
										lThrdLivre := .T. // Encontrou thread disponivel
										
										While !SysRefresh()
										Enddo
										
										//�������������������������������������������������������������������������Ŀ
										//� Define a variavel de controle da thread como em uso "E"                 �
										//���������������������������������������������������������������������������
										GlbLock( aThreads[nLoopThread] )
										PutGlbValue( aThreads[nLoopThread] , "E" )
										GlbUnLock()
										
										//���������������������������������������������Ŀ
										//� Inicializa a rotina U_FillInfMod em Job   �
										//�����������������������������������������������																	
										
										StartJob( "U_FillInfMod",GetEnvServer(), .F.,TRBCTL->CTL_ALIAS,/*cDtIni*/aTrab[nLoopLista,1],/*cDtfim*/aTrab[nLoopLista,2],aCfgDoc[nP],aResult[nI,2],TRBCTL->CVA_MODULO,aCtbc66Fil[nI],cSelecMvt,lCheckNDiv,nTrbCtl,TRBCTL->(RECNO()),cEmpAnt,cFilAnt,aThreads[nLoopThread],"cThrT"+cChaveT+"_IDThread",cOnlyAlias,cExceAlias,cSelecOrd,cGetFilDoc,nSeqUnique,nLoopLista,aFields)
										IncProc()
										
									EndIf
									
									//�������������������������������������������������������������������������Ŀ
									//� Se encontrar thread livre executa a rotina                              �
									//���������������������������������������������������������������������������
									If lThrdLivre
										Exit
									EndIf
									
								Next nLoopThread
								
							EndDo
							
						Next nLoopLista
						
						//�������������������������������������������������������������������������Ŀ
						//� Aguarda o encerramento das threads em execucao                          �
						//���������������������������������������������������������������������������
						nContThreads := 1
						While nContThreads > 0 .And. !KillApp() .and. !lEnd //!lFimThreads //
							
							//�����������������������������������������������������������������������������Ŀ
							//�Valida se finalizou a execucao                                               �
							//�������������������������������������������������������������������������������
							
							Sleep(3000) //3 segundos
							
							//�������������������������������������������������������������������������������������������������Ŀ
							//� Dados da thread - Monitor                                                                       �
							//�-------------------------------------------------------------------------------------------------�
							//�aInfo[x][01] = (C) Nome de usu�rio                                                               �
							//�aInfo[x][02] = (C) Nome da m�quina local                                                         �
							//�aInfo[x][03] = (N) ID da Thread                                                                  �
							//�aInfo[x][04] = (C) Servidor (caso esteja usando Balance; caso contr�rio � vazio)                 �
							//�aInfo[x][05] = (C) Nome da fun��o que est� sendo executada                                       �
							//�aInfo[x][06] = (C) Ambiente(Environment) que est� sendo executado                                �
							//�aInfo[x][07] = (C) Data e hora da conex�o                                                        �
							//�aInfo[x][08] = (C) Tempo em que a thread est� ativa (formato hh:mm:ss)                           �
							//�aInfo[x][09] = (N) N�mero de instru��es                                                          �
							//�aInfo[x][10] = (N) N�mero de instru��es por segundo                                              �
							//�aInfo[x][11] = (C) Observa��es                                                                   �
							//�aInfo[x][12] = (N) (*) Mem�ria consumida pelo processo atual, em bytes                           �
							//�aInfo[x][13] = (C) (**) SID - ID do processo em uso no TOPConnect/TOTVSDBAccess, caso utilizado. �
							//���������������������������������������������������������������������������������������������������
							aInfo := GetUserInfoArray()
							nContThreads := 0
							
							//����������������������������������������������������������������������Ŀ
							//� Verifica se e a funcao U_RGena09Dados que esta em execucao na thread �
							//������������������������������������������������������������������������
							For nJ := 1 to Len(aInfo)
								
								If AllTrim(STR( aInfo[nJ][3] )) $ GetGlbValue( "cThrT"+cChaveT+"_IDThread" )
									nContThreads++
								EndIf
								
							Next nJ
							
						EndDo
						
						//����������������������������������������������������������������������������������������������������������������������Ŀ
						//� Verifica se alguma Thread foi interrompida antes de finalizar a execu��o ou se ocorreu algum erro na execu��o do Job �
						//������������������������������������������������������������������������������������������������������������������������
						For nLoopTD := 1 to Len(aThreads)
							
							If SubStr(GetGlbValue(aThreads[nLoopTD]),1,1) == "E" .or. GetGlbValue( "cErrojob"+"cThrT"+cChaveT+"_IDThread" ) == "T"
								
								Alert("Ocorreu um erro na execu��o das Multi-Threads, favor reiniciar a rotina")
								Final()
								
							Endif
						Next nLoopTD
						
						For nLoopLista := 1 to Len(aTrab)
						
							aSize(aNwRes1,Len(aNwRes1)+1)
							aSize(aNwRes2,Len(aNwRes2)+1)
							aSize(aNwRes3,Len(aNwRes3)+1)
							aSize(aNwRes4,Len(aNwRes4)+1)
							aSize(aNwRes5,Len(aNwRes5)+1)
							aSize(aNwRes6,Len(aNwRes6)+1)
							aSize(aNwRes7,Len(aNwRes7)+1)
							aSize(aNwRes8,Len(aNwRes8)+1)
							aSize(aNwRes9,Len(aNwRes9)+1)
							aSize(aNwRes10,Len(aNwRes10)+1)
							
							GetGlbVars("aArray1"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes1[Len(aNwRes1)])
							ClearGlbValue(("aArray1"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))
							
							GetGlbVars("aArray2"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes2[Len(aNwRes2)])
							ClearGlbValue(("aArray2"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))
							
							GetGlbVars("aArray3"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes3[Len(aNwRes3)])
							ClearGlbValue(("aArray3"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))
							
							GetGlbVars("aArray4"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes4[Len(aNwRes4)])
							ClearGlbValue(("aArray4"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

							GetGlbVars("aArray5"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes5[Len(aNwRes5)])
							ClearGlbValue(("aArray5"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

							GetGlbVars("aArray6"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes6[Len(aNwRes6)])
							ClearGlbValue(("aArray6"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

							GetGlbVars("aArray7"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes7[Len(aNwRes7)])
							ClearGlbValue(("aArray7"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

							GetGlbVars("aArray8"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes8[Len(aNwRes8)])
							ClearGlbValue(("aArray8"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

							GetGlbVars("aArray9"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes9[Len(aNwRes9)])
							ClearGlbValue(("aArray9"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

							GetGlbVars("aArray10"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista)),aNwRes10[Len(aNwRes10)])
							ClearGlbValue(("aArray10"+"cThrT"+cChaveT+"_IDThread"+Alltrim(STR(nLoopLista))))

						Next nLoopLista
						
						//#TB Mult Thread Fim	
					
					EndIf
				Endif              
            EndIf
			TRBCTL->(Dbskip())  
		EndDo

		If lThread
			If aResult[nI,2,1,2] == nil
				aResult[nI,2,1,2] := {}
			Endif

			If aResult[nI,2,1,3] == nil
				aResult[nI,2,1,3] := {}
			Endif

			For nResult := 1 to Len(aNwRes1)
				
				If Len(aNwRes1[nResult]) > 0
					
					If aNwRes1[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes1[nResult,1,2]))
						ACopy(aNwRes1[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf

					If aNwRes1[nResult,1,3] != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes1[nResult,1,3]))
						ACopy(aNwRes1[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes2[nResult]) > 0
				
					If aNwRes2[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes2[nResult,1,2]))
						ACopy(aNwRes2[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf

					If aNwRes2[nResult,1,3] != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes2[nResult,1,3]))
						ACopy(aNwRes2[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes3[nResult]) > 0

					If aNwRes3[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes3[nResult,1,2]))
						ACopy(aNwRes3[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf

					If aNwRes3[nResult,1,3] != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes3[nResult,1,3]))
						ACopy(aNwRes3[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes4[nResult]) > 0

					If aNwRes4[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes4[nResult,1,2]))
						ACopy(aNwRes4[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf

					If aNwRes4[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes4[nResult,1,3]))
						ACopy(aNwRes4[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes5[nResult]) > 0

					If aNwRes5[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes5[nResult,1,2]))
						ACopy(aNwRes5[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf

					If aNwRes5[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes5[nResult,1,3]))
						ACopy(aNwRes5[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes6[nResult]) > 0
				
					If aNwRes6[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes6[nResult,1,2]))
						ACopy(aNwRes6[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf
									
					If aNwRes6[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes6[nResult,1,3]))
						ACopy(aNwRes6[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes7[nResult]) > 0
				
					If aNwRes7[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes7[nResult,1,2]))
						ACopy(aNwRes7[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf
									
					If aNwRes7[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes7[nResult,1,3]))
						ACopy(aNwRes7[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes8[nResult]) > 0
				
					If aNwRes8[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes8[nResult,1,2]))
						ACopy(aNwRes8[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf
									
					If aNwRes8[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes8[nResult,1,3]))
						ACopy(aNwRes8[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes9[nResult]) > 0
				
					If aNwRes9[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes9[nResult,1,2]))
						ACopy(aNwRes9[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf
									
					If aNwRes9[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes9[nResult,1,3]))
						ACopy(aNwRes9[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

				If Len(aNwRes10[nResult]) > 0
				
					If aNwRes10[nResult,1,2] != Nil
						nPosCpy := Len(aResult[nI,2,1,2]) + 1
						aSize(aResult[nI,2,1,2],Len(aResult[nI,2,1,2])+Len(aNwRes10[nResult,1,2]))
						ACopy(aNwRes10[nResult,1,2], aResult[nI,2,1,2],,,nPosCpy)
					EndIf
									
					If aNwRes10[nResult,1,3]  != Nil
						nPosCpy := Len(aResult[nI,2,1,3]) + 1
						aSize(aResult[nI,2,1,3],Len(aResult[nI,2,1,3])+Len(aNwRes10[nResult,1,3]))
						ACopy(aNwRes10[nResult,1,3], aResult[nI,2,1,3],,,nPosCpy)
					EndIf

				EndIf

			Next nResult			

			aSize(aNwRes1,0)
			aSize(aNwRes2,0)
			aSize(aNwRes3,0)
			aSize(aNwRes4,0)
			aSize(aNwRes5,0)
			aSize(aNwRes6,0)
			aSize(aNwRes7,0)
			aSize(aNwRes8,0)
			aSize(aNwRes9,0)
			aSize(aNwRes10,0)

		EndIf	
	  
	Endif

	//Ajuste Objeto Legenda
	//#TB20191202 Thiago Berna - Ajuste para verificar se � array
	If ValType(aResult[nI,2,1,2]) == 'A'
		For nResult := 1 to Len(aResult[nI,2,1,2])
			aResult[nI,2,1,2,nResult,1] :=  LoadBitmap(GetResources(),aResult[nI,2,1,2,nResult,1]) 
		Next nResult
	EndIf

	If aScan(aSelected,{|x| alltrim(x[1]) == "34"}) > 0
		MsgRun(STR0022 + alltrim(aCtbc66Fil[nI]),STR0021, {|| FillInfCtb(cDtIni,cDtfim,aResult[nI,2],aCtbc66Fil[nI],cSelecMvt) } )//##"Extraindo dados da contabilidade, filial "
	Endif

	Ctbc66FillBlank(aResult[nI,2])
	
Next nI

TRBCTL->(DbCloseArea())

Return()

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �QryTabMod	    � Autor �Fernando Radu Muscalu � Data � 29/08/11 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Monta arquivo temporario com as tabelas utilizadas nos LPs     ���
���          �dos modulos selecionados										 ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �QryTabMod(aSelected)					                         ���
����������������������������������������������������������������������������Ĵ��
���Parametros�aSelected	- tipo: A => Lista dos modulos selecionados	         ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �Nil															 ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function QryTabMod(aSelected)

Local cQry 			:= ""
Local cRetMod   	:= GetClauseInArray(aSelected)
Local cFilQry		:= ""
Local nW			:= 0

//#TB20200204 Thiago Berna - Ajuste para considerar a filial
For nW := 1 To Len(aCtbc66Fil)
	cFilQry += aCtbc66Fil[nW]
	If Len(aCtbc66Fil) > nW
		cFilQry += "|"	
	EndIf
Next Nw

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	DISTINCT CTL_ALIAS, " + chr(13) + chr(10)
cQry += "	CVA_MODULO " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CVA") + " CVA " + chr(13) + chr(10)
cQry += "INNER JOIN " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CTL") + " CTL " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	CTL.D_E_L_E_T_ = ' '  " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)

//#TB20200204 Thiago Berna - Ajuste para considerar a filial
//cQry += "	CTL_FILIAL = CVA_FILIAL " + chr(13) + chr(10)
cQry += " CTL_FILIAL IN " + FormatIn(cFilQry,"|") + chr(13) + chr(10)

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CTL_LP = CVA_CODIGO	 " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CVA.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CVA_MODULO " + cRetMod + chr(13) + chr(10)
cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	CVA_MODULO, " + chr(13) + chr(10)
cQry += "	CTL_ALIAS "

cQry := ChangeQuery(cQry)

If Select("TRBCTL") > 0
	TRBCTL->(DbCloseArea())  
Endif                                                     	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTL", .T., .F.)

Return()


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �FillInfMod	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Gera massa de dados em memoria de acordo com o modulo e tabela. ���
���          �Esta massa de dado corresponde tanto do lancamento quanto do    ���
���          �documento gerador (lado do modulo)							  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FillInfMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect)���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cAlias	- Tipo: C => Alias da tabela a ser analisada          ���
���          �cDtIni	- Tipo: C => Data inicial do periodo			      ���
���          �cDtFim	- Tipo: C => Data final do periodo				      ���
���          �aConfig	- Tipo: A => Campos utilizados pela Tabela		      ���
���          �aResult	- Tipo: A => Array com os dados comparativo Modulo X  ���
���          �cMod		- Tipo: C => Codigo do Modulo						  ���
���          �cFilSelect- Tipo: C => Filiais selecionadas					  ���        
���          �cSelecMvt - Tipo: C => Filtrar movimentos.					  ���  
���          �lCheckNDiv - Tipo: L => Filtrar n�o Divergente.				  ���             
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Nil									                          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
//Static Function FillInfMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect,cSelecMvt,lCheckNDiv,nTrbCtl,nRecCtl)
User Function FillInfMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect,cSelecMvt,lCheckNDiv,nTrbCtl,nRecCtl,cEmpOk,cFilOk,cVarThread,cVarIDThread,cOnlyAlias,cExceAlias,cSelecOrd,cGetFilDoc,nSeqUnique,Nw,aFields)

Local cQry		:= ""
Local cSelectEnt:= "" 
Local cMoeMod	:= ""
Local cBmpLeg	:= ""
Local cIdFil	:= ''
Local cDataDoc	:= ""
Local cNroDoc	:= Alltrim(StrTran(aConfig[NRODOC],"+",","+space(1) ) ) + ", "
Local cMoeDoc	:= ""
Local cVlrDoc	:= ""
Local cNodia	:= ""
Local aDataMod	:= {}
Local aDataCtb	:= {}
Local aDataCV3	:= {}
Local aVlrMCtb	:= {}
Local aEntities := {}
Local nP		:= 0
Local nIa		:= 0
Local nX		:= 0
Local nQtdEnt	:= 0
Local lCond1
Local lCond2
Local lCond3
Local lCond4
Local nConReg 	:= 0
Local nRegAtu 	:= 0

Local nCount	:= 0

Local aArray1 	:= {}
Local aArray2 	:= {}
Local aArray3 	:= {}
Local aArray4 	:= {}
Local aArray5	:= {}
Local aArray6	:= {}
Local aArray7	:= {}
Local aArray8	:= {}
Local aArray9	:= {}
Local aBkp		:= aClone(aResult)
Local nArray	:= 1
Local cInicio	:= ''

If !Empty(cEmpOk)
	//�����������������������������������������������������������������������������Ŀ
	//�Endereca as funcoes a serem executadas em caso de erro                       �
	//�������������������������������������������������������������������������������
	SysErrorBlock( { |e| fLibThread(3,cVarThread,cVarIDThread) } )
	ErrorBlock( { |e| fLibThread(3,cVarThread,cVarIDThread) } )

	//��������������������������������������������������Ŀ
	//� Abre nova thread para executar a rotina          �
	//����������������������������������������������������
	RpcSetType( 3 )
	RpcSetEnv( cEmpOk , cFilOk , , , 'FAT' )   

	//��������������������������������������������������Ŀ
	//� Retorna o ID da thread criada                    �
	//����������������������������������������������������
	cThreadID := StrZero(ThreadId(),20)

	//��������������������������������������������������������������Ŀ
	//� Adiciona o ID da Thread na variavel de IDThreads             �
	//����������������������������������������������������������������
	GlbLock( cVarIDThread )
	PutGlbValue( cVarIDThread , GetGlbValue(cVarIDThread) + "|" + AllTrim(STR(ThreadId())) )
	GlbUnLock()

	//��������������������������������������������������������������Ŀ
	//� Adiciona o ID da Thread na variavel de controle das threads  �
	//����������������������������������������������������������������
	GlbLock( cVarThread )
	PutGlbValue( cVarThread , GetGlbValue(cVarThread) + "|" + cThreadID )
	GlbUnLock()

EndIf

cIdFil		:= GetFieldFil(cAlias)
aEntities := Ctbc66RetEnt()  
nQtdEnt	:= len(aEntities[1])    

If (!Empty(cOnlyAlias).And. !cAlias $ cOnlyAlias) .Or. (!Empty(cExceAlias) .And. cAlias $ cExceAlias) 
	Return
EndIf

//cFilSelect:=xfilial(TRBCTL->CTL_ALIAS,cFilSelect)
cFilSelect:=xfilial(cAlias,cFilSelect)

For nIa := 1 to nQtdEnt
	cSelectEnt += alltrim(aEntities[1][nIa,1])+ ", " + alltrim(aEntities[2][nIa,1]) + ", " 
Next nIa

If "NO_" $ Upper(aConfig[DATADOC])
	cDataDoc := "	' ' " + aConfig[DATADOC] + ", "
Else
	cDataDoc := "	" + aConfig[DATADOC] + ", "
Endif	        

If "NO_" $ Upper(cNroDoc)
	cNroDoc := "	' ' " + cNroDoc 
Else
	cNroDoc := "	" + cNroDoc 
Endif

If "NO_" $ Upper(aConfig[MOEDOC])
	cMoeDoc := "	'01' " + aConfig[MOEDOC]+ ", "
Else
	cMoeDoc := "	" + aConfig[MOEDOC]+ ", "
Endif

If "NO_" $ Upper(aConfig[VLRDOC])
	cVlrDoc := "	0 " + aConfig[VLRDOC]+ ", "
Else	
	cVlrDoc := "	" + aConfig[VLRDOC]+ ", "
Endif

If "NO_" $ Upper(aConfig[NODIA])	
	cNodia := "	' ' " + aConfig[NODIA]+ ", "
Else	
	cNodia := "		" + aConfig[NODIA]+ ", "
Endif

cQry := "SELECT "
cQry += cIdFil + ", "
cQry += cDataDoc
cQry += cNroDoc
cQry += cMoeDoc
//cQry += cVlrDoc

cQry += "CV3_VLR01 " + aConfig[VLRDOC] + "," + chr(13) + chr(10)
cQry += cNodia + chr(13) + chr(10)
cQry += "	" + cAlias + ".D_E_L_E_T_ DELETADO, "+ chr(13) + chr(10)
cQry += "	" + cAlias + ".R_E_C_N_O_ RECORI, "+ chr(13) + chr(10)
cQry += "	CT2.R_E_C_N_O_ CT2_RECNO,  "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_TPSALD,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE, "+ chr(13) + chr(10)
cQry += "	CT2_DOC, "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_MOEDLC, "+ chr(13) + chr(10)
cQry += "	CT2_LP,  "+ chr(13) + chr(10)
cQry += "	CT2_NODIA,  "+ chr(13) + chr(10)
cQry += "	CT2_DEBITO,  "+ chr(13) + chr(10)
cQry += "	CT2_CREDIT,  "+ chr(13) + chr(10)
cQry += "	CT2_CCD,  "+ chr(13) + chr(10)
cQry += "	CT2_CCC,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMD,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMC,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLDB,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLCR,  "+ chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_VALOR,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQUEN, "+ chr(13) + chr(10)
cQry += "	CT2_DC, "+ chr(13) + chr(10)
cQry += "	CT2_CONFST, "+ chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ CT2_DELET,  "+ chr(13) + chr(10)
cQry += "	ROWNUM LINHA  "+ chr(13) + chr(10)
cQry += "FROM " + RetSQlName("CT2") + " CT2 "+ chr(13) + chr(10)

cQry += "INNER JOIN " + RetSqlName("CV3") + " CV3 ON CV3_FILIAL = '" + cFilSelect + "'"+ chr(13) + chr(10)  
cQry += " AND CV3_RECDES = CAST(CT2.R_E_C_N_O_ AS CHAR(17))" + chr(13) + chr(10)
cQry += " AND CV3.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)


cQry += "INNER JOIN " + RetSqlName(cAlias) + " " + cAlias + " ON " + cIdFil + " = '" + cFilSelect + "'"+ chr(13) + chr(10)
cQry += " AND CV3_RECORI = CAST(" + cAlias + ".R_E_C_N_O_ AS CHAR(17))" + chr(13) + chr(10)
cQry += " AND " + cAlias + ".D_E_L_E_T_= ' '" + chr(13) + chr(10)

//Ignora t�tulos com origem espec�ficas
If cAlias == "SE1"
	cQry += " AND E1_ORIGEM NOT LIKE 'MATA%' " + chr(13) + chr(10)
EndIf

//Ignora t�tulos com origem espec�ficas
If cAlias == "SE2"
	cQry += " AND E2_ORIGEM NOT LIKE 'MATA%' " + chr(13) + chr(10)
EndIf
	
cQry += "INNER JOIN  " + RetSQLName("CTL") + " CTL ON CTL_FILIAL = '" + xFilial("CTL") + "'"+ chr(13) + chr(10)
//cQry += " AND CTL_LP = CT2_LP AND CTL_ALIAS = '"+cAlias+"' AND CTL.D_E_L_E_T_ = ' ' " 
cQry += " AND CONCAT(CTL_LP,CTL_ALIAS)  = CONCAT(CT2_LP,'"+cAlias+"')  AND CTL.D_E_L_E_T_ = ' ' "+ chr(13) + chr(10) 

cQry += "INNER JOIN " + RetSqlName("CVA") + " CVA ON CVA_FILIAL = '" + xFilial("CVA") + "'" + chr(13) + chr(10)
cQry += " AND CVA_MODULO = '"+cMod+"' AND CVA_CODIGO = CT2_LP AND CVA.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
	
cQry += "WHERE CT2_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += "	AND CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND CT2_MOEDLC = '01' " + chr(13) + chr(10)
cQry += "	AND CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'	 " + chr(13) + chr(10)
cQry += "	AND CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)
cQry += "	AND CT2.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
//cQry += "	AND  CT2.R_E_C_N_O_ = 433 " //#tb

If !Empty(cGetFilDoc)
	cCampos := StrTran(AllTrim(cNroDoc),",","||")
	cCampos := SubStr(cCampos,1,Len(cCampos)-2)	
	cQry += " AND " + cCampos + " LIKE '%" + AllTrim(cGetFilDoc) + "%'" + chr(13) + chr(10)
EndIf

cQry += "UNION " + chr(13) + chr(10)

//Monta o lado do M�dulo que n�o tem refer�ncia na Contabilidade
cQry += "SELECT "+ chr(13) + chr(10)
cQry += cIdFil + ", " + chr(13) + chr(10)
cQry += cDataDoc + chr(13) + chr(10)
cQry += cNroDoc + chr(13) + chr(10)
cQry += cMoeDoc + chr(13) + chr(10)
cQry += cVlrDoc + chr(13) + chr(10)
cQry += cNodia + chr(13) + chr(10)
cQry += "	" + cAlias + ".D_E_L_E_T_ DELETADO, "  + chr(13) + chr(10) 
cQry += "	" + cAlias + ".R_E_C_N_O_ RECORI, "+ chr(13) + chr(10)
cQry += "	CT2.R_E_C_N_O_ CT2_RECNO,  "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_TPSALD,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE, "+ chr(13) + chr(10)
cQry += "	CT2_DOC, "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_MOEDLC, "+ chr(13) + chr(10)
cQry += "	CT2_LP,  "+ chr(13) + chr(10)
cQry += "	CT2_NODIA,  "+ chr(13) + chr(10)
cQry += "	CT2_DEBITO,  "+ chr(13) + chr(10)
cQry += "	CT2_CREDIT,  "+ chr(13) + chr(10)
cQry += "	CT2_CCD,  "+ chr(13) + chr(10)
cQry += "	CT2_CCC,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMD,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMC,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLDB,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLCR,  "+ chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_VALOR,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQUEN, "+ chr(13) + chr(10)
cQry += "	CT2_DC, "+ chr(13) + chr(10)
cQry += "	CT2_CONFST, "+ chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ CT2_DELET,  "+ chr(13) + chr(10)
cQry += "	ROWNUM LINHA  "+ chr(13) + chr(10)
cQry += "FROM " + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)

cQry += " LEFT JOIN " + RetSQlName("CT2") + " CT2 ON 1=2 "+ chr(13) + chr(10)
cQry += " WHERE " + cIdFil + " = '" + cFilSelect + "' " + chr(13) + chr(10)

//Filtrar por data no arquivo Origem, ex: F1_EMISSAO, F2_EMISSAO
If ! "NO_DATA" $ cDataDoc
	cDataDoc := StrTran(cDataDoc,",","")
	cQry += " AND "+ chr(13) + chr(10)
    cQry += cDataDoc + " BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
EndIf
cQry += " AND " + cAlias + ".D_E_L_E_T_ = ' ' "+ chr(13) + chr(10)

//Ignora t�tulos com origem espec�ficas
If cAlias == "SE1"
	cQry += " AND E1_ORIGEM NOT LIKE 'MATA%' " + chr(13) + chr(10)
EndIf

//Ignora t�tulos com origem espec�ficas
If cAlias == "SE2"
	cQry += " AND E2_ORIGEM NOT LIKE 'MATA%'  " + chr(13) + chr(10)
EndIf

//cQry += " AND NOT EXISTS(SELECT * " + chr(13) + chr(10)
//cQry += " FROM " + RetSQlName("CV3") + " CV3 " + chr(13) + chr(10)

//cQry += " INNER JOIN " + RetSqlName("CT2") + " CT2 ON CV3_FILIAL = '" + cFilSelect + "'" 	
//cQry += " AND CAST(CT2.R_E_C_N_O_ AS CHAR(17)) = CV3_RECDES"+ chr(13) + chr(10)
//cQry += " AND CT2.D_E_L_E_T_ = ' '"+ chr(13) + chr(10)

//cQry += " INNER JOIN  " + RetSQLName("CTL") + " CTL ON CTL_FILIAL = '" + xFilial("CTL") + "'"+ chr(13) + chr(10)
//cQry += "   AND CTL_LP = CT2_LP AND	 CTL_ALIAS = '"+cAlias+"' AND CTL.D_E_L_E_T_ = ' ' "

//cQry += " INNER JOIN " + RetSqlName("CVA") + " CVA ON CVA_FILIAL = '" + xFilial("CVA") + "'"+ chr(13) + chr(10)
//cQry += "  AND CVA_MODULO = '"+cMod+"' AND CVA_CODIGO = CT2_LP AND CVA.D_E_L_E_T_ = ' '"+ chr(13) + chr(10)
	
//cQry += " WHERE CV3_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
//cQry += " AND CV3_RECORI = CAST(" + cAlias+ ".R_E_C_N_O_ AS CHAR(17))"    + chr(13) + chr(10)  
//cQry += " AND CV3_TABORI = '" + cAlias + "' "+ chr(13) + chr(10)
//cQry += " AND CV3.D_E_L_E_T_ = ' ') " + chr(13) + chr(10)

cQry += " AND NOT EXISTS(SELECT 1 " + chr(13) + chr(10)
cQry += " FROM " + RetSQlName("CV3") + " CV3B " + chr(13) + chr(10)

cQry += " INNER JOIN " + RetSqlName("CT2") + " CT2 ON CT2_FILIAL = '" + cFilSelect + "'" + chr(13) + chr(10)	
cQry += " AND CAST(CT2.R_E_C_N_O_ AS CHAR(17)) = CV3_RECDES"+ chr(13) + chr(10)
cQry += " AND CT2.D_E_L_E_T_ = ' '"+ chr(13) + chr(10)

cQry += "INNER JOIN " + RetSqlName("CVA") + " CVA ON CVA_FILIAL = '" + xFilial("CVA") + "'" + chr(13) + chr(10)
cQry += " AND CVA_MODULO = '"+cMod+"' AND CVA_CODIGO = CT2_LP AND CVA.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
	
cQry += "INNER JOIN  " + RetSQLName("CTL") + " CTL ON CTL_FILIAL = '" + xFilial("CTL") + "'"+ chr(13) + chr(10)
cQry += " AND CONCAT(CTL_LP,CTL_ALIAS)  = CONCAT(CT2_LP,'"+cAlias+"')  AND CTL.D_E_L_E_T_ = ' ' "+ chr(13) + chr(10) 

cQry += " WHERE CV3B.CV3_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += " AND CV3B.CV3_RECORI = CAST(" + cAlias+ ".R_E_C_N_O_ AS CHAR(17)) " + chr(13) + chr(10)
cQry += " AND CV3B.D_E_L_E_T_ = ' ')  " + chr(13) + chr(10)

If !Empty(cGetFilDoc)
	cCampos := StrTran(AllTrim(cNroDoc),",","||")
	cCampos := SubStr(cCampos,1,Len(cCampos)-2)	
	cQry += " AND " + cCampos + " LIKE '%" + AllTrim(cGetFilDoc) + "%'" + chr(13) + chr(10)
EndIf

cQry += "ORDER BY "+ chr(13) + chr(10)

If cSelecOrd == "1" //Ordena pelo Documento
	cCampos  := AllTrim(cNroDoc)
	cCampos  := SubStr(cCampos,1,Len(cCampos)-1)	
	nCampos  := Len(StrToKarr(cCampos, ",")) 
	cOrderBy := ""
	
	For nX := 1 To nCampos
		cOrderBy += Iif(!Empty(cOrderBy),",","") + cValToChar(nX+2)	
	Next nX
	cQry += cOrderBy + chr(13) + chr(10)
Else
	cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
	cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
	cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
	cQry += "	CT2_SBLOTE,  "+ chr(13) + chr(10)
	cQry += "	CT2_DOC,  "+ chr(13) + chr(10)
	cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
	cQry += "	CT2_SEQLAN  "+ chr(13) + chr(10)
EndIf

//cQry := ChangeQuery(cQry)

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())  
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTB", .T., .F.)

Count To nConReg

TcSetField( "TRBCTB", aConfig[VLRDOC], "N", TamSx3("CT2_VALOR")[1], TamSx3("CT2_VALOR")[2] )

TRBCTB->(DbGotop())

If TRBCTB->(!eof())

	cInicio := Time()
	While TRBCTB->(!eof())
		

		nSeqUnique++
		
		aDataCV3 := Ctbc66CV3(TRBCTB->CT2_DATA,TRBCTB->CT2_SEQUEN,TRBCTB->CT2_SEQLAN,cFilSelect,TRBCTB->CT2_RECNO,TRBCTB->RECORI,cAlias)
		
		nStatus := Ctbc66GRsc(,,"TRBCTB",2,aDataCV3,aConfig,@cBmpLeg)
	
		// monta condi��es apartir do Filtro
		lcond1:= (cSelecMvt == "2" 	.AND. nStatus == 3)
		lcond2:= (cSelecMvt == "1" 	.AND. (nStatus == 1 .OR. nStatus == 2))
		lcond3:= (cSelecMvt == "3"	.AND. nStatus != 0)
		lcond4:= (lCheckNDiv	.AND. nStatus == 0)
			
		If !Empty(TRBCTB->&(aConfig[NRODOC])) .OR. !Empty(TRBCTB->&(aConfig[DATADOC])) .OR. !Empty(TRBCTB->&(aConfig[VLRDOC]))

			if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4

				aAdd(aDataMod,cBmpLeg) // reservado para a legenda
				aAdd(aDataMod,TRBCTB->&(cIdFil))
				aAdd(aDataMod,cAlias)
				aAdd(aDataMod,stod(TRBCTB->&(aConfig[DATADOC])))	//data
				aAdd(aDataMod,TRBCTB->&(aConfig[NRODOC]))		//Documento

				If Valtype(TRBCTB->&(aConfig[MOEDOC])) == "N"
					cMoeMod := Alltrim(str(TRBCTB->&(aConfig[MOEDOC])))
				Else
					cMoeMod := Alltrim(TRBCTB->&(aConfig[MOEDOC]))
				Endif

				aAdd(aDataMod,cMoeMod)							//Moeda
				aAdd(aDataMod,TRBCTB->&(aConfig[VLRDOC]))	    //Vrl Doc				
				aAdd(aDataMod,TRBCTB->&(aConfig[NODIA]))		//Correlativo
				aAdd(aDataMod,aDataCV3[1])						//CV3_DEBITO
				aAdd(aDataMod,aDataCV3[2])						//CV3_CREDIT
				aAdd(aDataMod,aDataCV3[3])						//CV3_CCD
				aAdd(aDataMod,aDataCV3[4])						//CV3_CCC
				aAdd(aDataMod,aDataCV3[5])						//CV3_ITEMD
				aAdd(aDataMod,aDataCV3[6])						//CV3_ITEMC
				aAdd(aDataMod,aDataCV3[7])						//CV3_CLVLDB
				aAdd(aDataMod,aDataCV3[8])						//CV3_CLVLCR

				For nIa := 1 to len(aDataCV3[9])
					aAdd(aDataMod,aDataCV3[9,nIa])
				Next nIa

				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			else
				aDataMod := Array(16+(nQtdEnt*2))
				aFill(aDataMod,"")
				aDataMod[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
				aDataMod[7] := 0
				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao				
			endif
			//aAdd(aDataMod,nSeqUnique)
		Else
			aDataMod := Array(16+(nQtdEnt*2))
			aFill(aDataMod,"")
			aDataMod[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
			aDataMod[7] := 0
			aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao			
		Endif

		If !Empty(TRBCTB->CT2_LOTE)
			aVlrMCtb    := Array(1) //GetValMCT2(TRBCTB->CT2_NODIA,TRBCTB->CT2_SEQLAN,cFilSelect)
			//aVlrMCtb := GetValMCT2(TRBCTB->CT2_RECNO,TRBCTB->CT2_SEQLAN,cFilSelect)
			aVlrMCtb[1] := TRBCTB->CT2_VALOR
			
			aAdd(aDataCtb,TRBCTB->CT2_FILIAL)
			aAdd(aDataCtb,stod(TRBCTB->CT2_DATA))
			aAdd(aDataCtb,TRBCTB->CT2_TPSALD)
			aAdd(aDataCtb,TRBCTB->CT2_LOTE)
			aAdd(aDataCtb,TRBCTB->CT2_SBLOTE)
			aAdd(aDataCtb,TRBCTB->CT2_DOC)
			aAdd(aDataCtb,TRBCTB->CT2_LINHA)
			aAdd(aDataCtb,TRBCTB->CT2_LP)
			aAdd(aDataCtb,TRBCTB->CT2_SEQLAN)
			aAdd(aDataCtb,TRBCTB->CT2_NODIA)
			aAdd(aDataCtb,TRBCTB->CT2_DEBITO)
			aAdd(aDataCtb,TRBCTB->CT2_CREDIT)
			aAdd(aDataCtb,TRBCTB->CT2_CCD)
			aAdd(aDataCtb,TRBCTB->CT2_CCC)
			aAdd(aDataCtb,TRBCTB->CT2_ITEMD)
			aAdd(aDataCtb,TRBCTB->CT2_ITEMC)
			aAdd(aDataCtb,TRBCTB->CT2_CLVLDB)
			aAdd(aDataCtb,TRBCTB->CT2_CLVLCR)

			For nIa := 1 to nQtdEnt
				aAdd(aDataCtb,TRBCTB->&(aEntities[1][nIa,1]))
				aAdd(aDataCtb,TRBCTB->&(aEntities[2][nIa,1]))
			Next nIa

			aEval(aVlrMCtb,{|x| aAdd(aDataCtb,x)})

			aAdd(aDataCtb,TRBCTB->CT2_DC)
			
			//Adicionados
			aAdd(aDataCtb,TRBCTB->CT2_RECNO)
			aAdd(aDataCtb,TRBCTB->&(aConfig[NRODOC]))		//Documento para Ordena��o			
			//aAdd(aDataCtb,nSeqUnique)
		Else
			aDataCtb := Array(20+(nQtdEnt*2)) //+len(aCtbc66Moe)) //Pego somente uma moeda
			aFill(aDataCtb,"")
			For nIa := 20+(nQtdEnt*2) to len(aDataCtb)-1
				aDataCtb[nIa] := 0
			Next nIa
			aAdd(aDataCtb,0)
			aAdd(aDataCtb,TRBCTB->&(aConfig[NRODOC]))		//Documento para Ordena��o
			//aAdd(aDataCtb,nSeqUnique)			
		Endif
		
		If !Empty(cEmpOk)
			
			nP := aScan(aResult,{|x| AllTrim(cMod) $ alltrim(x[1]) })
			
			If nP > 0
				If aResult[nP,2] == nil
					aResult[nP,2] := {}
				Endif

				If aResult[nP,3] == nil
					aResult[nP,3] := {}
				Endif

				If Len(aResult[nP,2]) > 10000 .Or. Len(aResult[nP,3]) > 10000
					If nArray == 1
						aSize(aArray1,Len(aResult))
						ACopy(aResult, aArray1)
						aResult := aClone(aBkp)
						nArray++
					ElseIf nArray == 2
						aSize(aArray2,Len(aResult))
						ACopy(aResult, aArray2)
						aResult := aClone(aBkp)
						nArray++
					ElseIf nArray == 3
						aSize(aArray3,Len(aResult))
						ACopy(aResult, aArray3)
						aResult := aClone(aBkp)
						nArray++
					ElseIf nArray == 4
						aSize(aArray4,Len(aResult))
						ACopy(aResult, aArray4)
						aResult := aClone(aBkp)
						nArray++
					ElseIf nArray == 5
						aSize(aArray5,Len(aResult))
						ACopy(aResult, aArray5)
						aResult := aClone(aBkp)
						nArray++
					ElseIf nArray == 6
						aSize(aArray6,Len(aResult))
						ACopy(aResult, aArray6)
						aResult := aClone(aBkp)
						nArray++			
					ElseIf nArray == 7
						aSize(aArray7,Len(aResult))
						ACopy(aResult, aArray7)
						aResult := aClone(aBkp)
						nArray++	
					ElseIf nArray == 8
						aSize(aArray8,Len(aResult))
						ACopy(aResult, aArray8)
						aResult := aClone(aBkp)
						nArray++		
					ElseIf nArray == 9
						aSize(aArray9,Len(aResult))
						ACopy(aResult, aArray9)
						aResult := aClone(aBkp)
						nArray++	
					EndIf
				EndIf

				If aResult[nP,2] == nil
					aResult[nP,2] := {}
				Endif

				If aResult[nP,3] == nil
					aResult[nP,3] := {}
				Endif

				if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4
					aAdd(aResult[nP,2],aClone(aDataMod))
					aAdd(aResult[nP,3],aClone(aDataCtb))
				EndIf
				aDataMod := {}
				aDataCtb := {}
			Endif
		
		Else
			nP := aScan(aResult,{|x| AllTrim(cMod) $ alltrim(x[1]) })
			
			If nP > 0
				If aResult[nP,2] == nil
					aResult[nP,2] := {}
				Endif

				If aResult[nP,3] == nil
					aResult[nP,3] := {}
				Endif
				if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4
					aAdd(aResult[nP,2],aClone(aDataMod))
					aAdd(aResult[nP,3],aClone(aDataCtb))
				EndIf
				aDataMod := {}
				aDataCtb := {}
			Endif
		EndIf
		
		TRBCTB->(DbSkip())

	EndDo
	ConOut('LOG: Data[' + DTOC(STOD(cDtIni)) + '] Registros[' + AllTrim(Str(nConReg)) + '] Hora Inicio[' + cInicio + '] Hora Fim[' + Time() + ']')
Endif


If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())  
Endif

If !Empty(cEmpOk)
	GlbLock()
	PutGlbVars("aArray1"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray1))
	PutGlbVars("aArray2"+alltrim(cVarIDThread)+alltrim(str(Nw)),aCLone(aArray2))
	PutGlbVars("aArray3"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray3))
	PutGlbVars("aArray4"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray4))
	PutGlbVars("aArray5"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray5))
	PutGlbVars("aArray6"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray6))
	PutGlbVars("aArray7"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray7))
	PutGlbVars("aArray8"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray8))
	PutGlbVars("aArray9"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aArray9))
	PutGlbVars("aArray10"+alltrim(cVarIDThread)+alltrim(str(Nw)),aClone(aResult))
	PutGlbValue( cVarThread , "L" )
	GlbUnlock()
	
	aSize(aDataMod,0)
	aSize(aDataCtb,0)
	aSize(aDataCV3,0)
	aSize(aArray1,0)
	aSize(aArray2,0)
	aSize(aArray3,0)
	aSize(aArray4,0)
	aSize(aArray5,0)
	aSize(aArray6,0)
	aSize(aArray7,0)
	aSize(aArray8,0)
	aSize(aArray9,0)
	aSize(aResult,0)
	
	DelClassIntf()
	RpcClearEnv()
	RESET Environment
	dbcloseall()
EndIf

Return()


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �FillInfCtb	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Gera massa de dados em memoria de acordo com os lancamentos     ���
���          �contabeis manuais.								              ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FillInfCtb(cDtIni,cDtfim,aResult,cFilSelect)					  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cDtIni	- Tipo: C => Data inicial do periodo			      ���
���          �cDtFim	- Tipo: C => Data final do periodo				      ���
���          �aResult	- Tipo: A => Array com os dados comparativo Modulo X  ���
���          �Contabilidade													  ���
���          �cFilSelect- Tipo: C => Filiais selecionadas					  ���
���          �cSelecMvt - Tipo: C => seleciona movimentos					  	 ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Nil									                          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/

Static Function FillInfCtb(cDtIni,cDtfim,aResult,cFilSelect,cSelecMvt)

Local cQry			:= ""
Local cSelectEnt    := ""

Local aDataCtb		:= {}
Local aVlrMCtb		:= {}
Local aEntities 	:= Ctbc66RetEnt()

Local nP			:= 0
Local nI			:= 0
Local nQtdEnt		:= len(aEntities[1])

cFilSelect:=xfilial("CT2",cFilSelect)

For nI := 1 to nQtdEnt
	cSelectEnt += alltrim(aEntities[1][nI,1])+ ", " + alltrim(aEntities[2][nI,1]) + ", " 
Next nI

cQry := "SELECT " + chr(13) + chr(10)        
cQry += "	CT2_FILIAL,   " + chr(13) + chr(10)
cQry += "	CT2_DATA,   " + chr(13) + chr(10)
cQry += "	CT2_TPSALD,   " + chr(13) + chr(10)
cQry += "	CT2_LOTE,   " + chr(13) + chr(10)
cQry += "	CT2_SBLOTE,  " + chr(13) + chr(10)
cQry += "	CT2_DOC,  " + chr(13) + chr(10)
cQry += "	CT2_SEQLAN,   " + chr(13) + chr(10)
cQry += "	CT2_LINHA,   " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC,  " + chr(13) + chr(10)
cQry += "	CT2_LP,   " + chr(13) + chr(10)
cQry += "	CT2_NODIA,   " + chr(13) + chr(10)
cQry += "	CT2_DEBITO,   " + chr(13) + chr(10)
cQry += "	CT2_CREDIT,   " + chr(13) + chr(10)
cQry += "	CT2_CCD,   " + chr(13) + chr(10)
cQry += "	CT2_CCC,   " + chr(13) + chr(10)
cQry += "	CT2_ITEMD,   " + chr(13) + chr(10)
cQry += "	CT2_ITEMC,   " + chr(13) + chr(10)
cQry += "	CT2_CLVLDB,   " + chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_CLVLCR,   " + chr(13) + chr(10)
cQry += "	CT2_VALOR,   " + chr(13) + chr(10)
cQry += "	CT2_SEQUEN,  " + chr(13) + chr(10)
cQry += "	CT2_DC " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CT2") + " CT2 " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CT2_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_LP < '500' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC = '01' " + chr(13) + chr(10)                  

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)

cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	CT2_DATA,  " + chr(13) + chr(10)
cQry += "	CT2_LOTE, " + chr(13) + chr(10)
cQry += "	CT2_SBLOTE, " + chr(13) + chr(10)
cQry += "	CT2_DOC, " + chr(13) + chr(10)
cQry += "	CT2_LINHA, " + chr(13) + chr(10)
cQry += "	CT2_SEQLAN "

cQry := ChangeQuery(cQry)

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())  
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTB", .T., .F.)
   
TRBCTB->(DbGotop())

If TRBCTB->(!eof())
	While TRBCTB->(!eof())
				
		aVlrMCtb    := Array(1) //GetValMCT2(TRBCTB->CT2_NODIA,TRBCTB->CT2_SEQLAN,cFilSelect)
		aVlrMCtb[1] := TRBCTB->CT2_VALOR

		aAdd(aDataCtb,TRBCTB->CT2_FILIAL)
		aAdd(aDataCtb,stod(TRBCTB->CT2_DATA))
	    aAdd(aDataCtb,TRBCTB->CT2_TPSALD)
	    aAdd(aDataCtb,TRBCTB->CT2_LOTE)
	    aAdd(aDataCtb,TRBCTB->CT2_SBLOTE)
	    aAdd(aDataCtb,TRBCTB->CT2_DOC)
	    aAdd(aDataCtb,TRBCTB->CT2_LINHA)
	    aAdd(aDataCtb,TRBCTB->CT2_LP)
	    aAdd(aDataCtb,TRBCTB->CT2_SEQLAN)
	    aAdd(aDataCtb,TRBCTB->CT2_NODIA)
	    aAdd(aDataCtb,TRBCTB->CT2_DEBITO)
	    aAdd(aDataCtb,TRBCTB->CT2_CREDIT)
	    aAdd(aDataCtb,TRBCTB->CT2_CCD)
	    aAdd(aDataCtb,TRBCTB->CT2_CCC)
	    aAdd(aDataCtb,TRBCTB->CT2_ITEMD)
	    aAdd(aDataCtb,TRBCTB->CT2_ITEMC)
	    aAdd(aDataCtb,TRBCTB->CT2_CLVLDB)
	    aAdd(aDataCtb,TRBCTB->CT2_CLVLCR)	

	    For nI := 1 to nQtdEnt
	    	aAdd(aDataCtb,TRBCTB->&(aEntities[1][nI,1]))
	    	aAdd(aDataCtb,TRBCTB->&(aEntities[2][nI,1]))
	    Next nI 	
	    
	    aEval(aVlrMCtb,{|x| aAdd(aDataCtb,x)})
	    
	    aAdd(aDataCtb,TRBCTB->CT2_DC)

		TRBCTB->(Dbskip())
		
		nP := aScan(aResult,{|x| "34" $ alltrim(x[1]) })

		If nP > 0
			
			If aResult[nP,3] == nil
				aResult[nP,3] := {}
			Endif	
			
	 		aAdd(aResult[nP,3],aClone(aDataCtb)	)
	 		
	 		aDataCtb := {}
		Endif	
    EndDo
    
Endif                    

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())  
Endif

Return()


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC66Scr  	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem da interface da quadratura contabil				      ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC66Scr(aSelected,aResultSet)								  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�aSelected	- Tipo: A => Modulos selecionados				      ���
���          �aResultSet- Tipo: A => Array com os dados comparativo Modulo X  ���
���          �Contabilidade													  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Nil									                          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CtbC66Scr(aSelected,aResultSet)

Local oDlg
	
Local oBrwMod 
Local oBrwCtb

Local aSizeDlg		:= FwGetDialogsize(oMainWnd)
Local aButtons		:= {}

Local aFolderFil	:= {}
Local aScrLayer	 	:= {}

Local nHeight		:= aSizeDlg[3]
Local nWidth    	:= aSizeDlg[4]
Local nI			:= 0
Local nX            := 0

Local bBtnOk		:= {|| 	oDlg:End() }
Local bBtnCanc		:= {|| 	oDlg:End() }
Local bEnchBar		:= {||	EnchoiceBar(oDlg,bBtnOk,bBtnCanc,,aButtons) }

//Local oFolderFil
//Local aFModulos		:= {}
//Local aBrwMod		:= {}
//Local aBrwCtb		:= {}

Private oFolderFil
Private aFModulos		:= {}
Private aBrwMod		:= {}
Private aBrwCtb		:= {}

Private oGetLocali := Nil
Private cGetLocali := Space(50)
Private oRadLocali := Nil
Private nRadLocali := 1

Private oGetFiltra := Nil
Private cGetFiltra := Space(50)
Private oRadFiltra := Nil
Private nRadFiltra := 1

Private cContaDMod := ""
Private cContaCMod := ""

Private cContaDCtb := ""
Private cContaCCtb := ""

Private oSayDebMod := Nil
Private oSayCreMod := Nil
Private oSayDebCtb := Nil
Private oSayCreCtb := Nil

aEval(aCtbc66Fil,{|x| aAdd(aFolderFil,x+"-"+ Alltrim(SM0->(GetAdvFVal("SM0","M0_FILIAL",cEmpAnt+x,1,"")))   )})

aAdd(aButtons,{"EDITAR"           ,{|| CT660Conf(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)},STR0045})			//"Conferir"
aAdd(aButtons,{"EDITAR"			  ,{|| CT660Reve(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)},STR0046})			//"Reverter"
aAdd(aButtons,{"VISUAL"			  ,{|| CT660Dive(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)},STR0047})			//"Divergencias"
//aAdd(aButtons,{"TOTVSPRINTER_LOGO",{|| CTBR660A(aResultSet)}   ,STR0023})		//"Imprimir"
aAdd(aButtons,{"S4WB011N"         ,{|| CTBC66Leg()}           ,STR0024})		//"Legenda"
//aAdd(aButtons,{"Localizar"        ,{|| Localizar()},"Localizar (F4)"})
aAdd(aButtons,{"Filtrar"          ,{|| Filtrar()},"Filtrar (F4)"})

Set Key VK_F4 To Filtrar()

DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight-20, nWidth-30 TITLE STR0005 PIXEL STYLE DS_MODALFRAME of oMainWnd //## "Relat�rio de Auditoria"
    
    oFolderFil := TFolder():New(031,0,aFolderFil,aFolderFil,oDlg,,,,.T.,,nWidth/2-15,(nHeight/2)-60) //20)
    oFolderFil:bChange := {|| ChangeCT1()}
	aFModulos := CtbC66FMod(oFolderFil,aSelected)
    aScrLayer := CtbC66Layer(aFModulos)
	                                
	@ (nHeight/2)-27, 010 SAY oSayDebMod PROMPT "D�bito   " + cContaDMod SIZE 220, 010 OF oDlg COLORS 255, 16777215 PIXEL
	@ (nHeight/2)-17, 010 SAY oSayCreMod PROMPT "Cr�dito  " + cContaCMod SIZE 220, 010 OF oDlg COLORS 16711680, 16777215 PIXEL
	
	@ (nHeight/2)-27, nWidth/4 SAY oSayDebCtb PROMPT "D�bito   " + cContaDCtb SIZE 220, 010 OF oDlg COLORS 255, 16777215 PIXEL
	@ (nHeight/2)-17, nWidth/4 SAY oSayCreCtb PROMPT "Cr�dito  " + cContaCCtb SIZE 220, 010 OF oDlg COLORS 16711680, 16777215 PIXEL	
		                    	                                                      
	CtbC66Load(aScrLayer,oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)
	
oDlg:Activate(,,,.T.,,,bEnchBar)

FreeObj(aScrLayer[1,1])
aScrLayer[1,1] := Nil
FreeObj(oFolderFil)
oFolderFil := Nil
FreeObj(oDlg)
oDlg := Nil
FreeObj(oSayDebMod)
oSayDebMod := Nil
FreeObj(oSayCreMod)
oSayCreMod := Nil
FreeObj(oSayDebCtb)
oSayDebCtb := Nil
FreeObj(oSayCreCtb)
oSayCreCtb := Nil

FreeObj(oGetLocali)
oGetLocali := Nil
FreeObj(oRadLocali)
oRadLocali := Nil
FreeObj(oGetFiltra)
oGetFiltra := Nil
FreeObj(oRadFiltra)
oRadFiltra := Nil

aSize(aScrLayer,0)
aSize(aFModulos,0)
aSize(aBrwMod,0)
aSize(aBrwCtb,0)
DelClassIntf()
Return()

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC66FMod  	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem das abas dos modulos selecionados.					  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC66FMod(oFolderFil,aSelected)								  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�oFolderFil- Tipo: O => Objeto da Folder das Filiais 			  ���
���          �aSelected	- Tipo: A => Modulos selecionados				      ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aRetMod	- Tipo: A => Array com os objetos tFolder dos         ���
���          �modulos de acordo com as filiais						          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CtbC66FMod(oFolderFil,aSelected)

Local aRetMod	:= array(len(oFolderFil:aDialogs))
Local aFolder	:= {}
Local aSizeDlg	:= {}

Local nI		:= 0
Local nWidth	:= 0
Local nHeight	:= 0

//Montagem dos Folders de acordo com os modulo selecionados
For nI := 1 to len(aSelected)
	aAdd(aFolder,alltrim(aSelected[nI,1])+"-"+alltrim(aSelected[nI,2]))
Next nI

For nI := 1 to len(aRetMod)

	aSizeDlg := FwGetDialogsize(oFolderFil:aDialogs[nI])

	nHeight		:= aSizeDlg[3]-52
	nWidth    	:= aSizeDlg[4]
	
	aRetMod[nI] := TFolder():New(0,0,aFolder,aFolder,oFolderFil:aDialogs[nI],,,,.T.,,nWidth/2-15,nHeight/2-55)
	aRetMod[nI]:bChange := {|| ChangeCT1()}	
		
Next nI

Return(aRetMod)

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC66Layer  	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem das layers.											  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC66Layer(aFModulos)										  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�aFModulos	- Tipo: A => Array com os objetos tfolders dos Modulos���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aLayers	- Tipo: A => Array com os objetos das layers	      ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CtbC66Layer(aFModulos)

Local cSufix	:= ""

Local nI		:= 0
Local nX		:= 0

Local aAuxLay	:= {}
Local aLayers	:= {}

For nI := 1 to len(aFModulos)
	
	aAuxLay := array(len(aFModulos[nI]:aDialogs))	
	
	For nX := 1 to len(aAuxLay)
		
		aAuxLay[nX] := fwLayer():New()

		aAuxLay[nX]:init(aFModulos[nI]:aDialogs[nX],.F.)	
			
		aAuxLay[nX]:addLine("Linha"+cSufix,100,.t.)           
		
		aAuxLay[nX]:addCollumn("ColMod"+cSufix,50,.t.,"Linha"+cSufix)
		aAuxLay[nX]:addCollumn("ColCtb"+cSufix,50,.t.,"Linha"+cSufix)
			
		aAuxLay[nX]:addWindow("ColMod"+cSufix,"WinMod"+cSufix,aFModulos[nI]:aDialogs[nX]:cCaption,100,.f.,.t.,{||},"Linha"+cSufix)
		aAuxLay[nX]:addWindow("ColCtb"+cSufix,"WinCtb"+cSufix,"34-"+STR0025 ,100,.f.,.t.,{||},"Linha"+cSufix)//##"Contabilidad de Gestion"			
	Next nX
	
	aAdd(aLayers,aClone(aAuxLay))
	aAuxLay := {}		
Next nI

Return(aLayers)               


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC66Load  	� Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem das abas dos modulos selecionados.					   ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC66Load(aScrLayer,oFolderFil,aFModulos,aBrwMod,aBrwCtb,	   ���
���          �aResultSet)													   ���
������������������������������������������������������������������������������Ĵ��
���Parametros�aScrLayer	- Tipo: A => Array com os objetos das layers		   ���
���          �oFolderFil- Tipo: O => Objeto da Folder das Filiais 			   ���
���          �aFModulos	- Tipo: A => Array com os objetos tfolders dos Modulos ���
���          �aBrwMod	- Tipo: A => Array com os objetos twBrowses dos Modulos���
���          �aBrwCtb	- Tipo: A => Array com os objetos twBrowses do CTB	   ���
���          �aResultSet- Tipo: A => Array com os dados comparativo Modulo X   ���
���          �Contabilidade													   ���
������������������������������������������������������������������������������Ĵ��
���Retorno   �Nil													           ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                         ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function CtbC66Load(aScrLayer,oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)

Local oPnlMod 
Local oPnlCtb

Local nI			:= 0
Local nX			:= 0
Local nZ			:= 0

Local cSufix		:= ""
Local cLineMod		:= ""
Local cLineCtb		:= ""

Local aHeadMod		:= CTBC66GetHBrw(1)//cabecalho do browse dos dados do Modulo
Local aHeadCtb		:= CTBC66GetHBrw(2)//cabecalho do browse dos dados da contabilidade
//Local aCabMod		:= {}
//Local aCabCtb		:= {}//cabecalho do browse dos dados da contabilidade
Local aSizeMod		:= {}
Local aSizeCtb		:= {}
//Local aTipoMod		:= {}
//Local aTipoCtb		:= {}
Local aAuxBrwMod	:= {}
Local aAuxBrwCtb	:= {}

aBrwMod	:= Array(len(oFolderFil:aDialogs),len(aFModulos[1]:aDialogs))
aBrwCtb	:= Array(len(oFolderFil:aDialogs),len(aFModulos[1]:aDialogs))

aEval(aHeadMod,{|x| aAdd(aCabMod,x[1]),aAdd(aSizeMod,x[2]),aAdd(aTipoMod,x[3]) })
aEval(aHeadCtb,{|x| aAdd(aCabCtb,x[1]),aAdd(aSizeCtb,x[2]),aAdd(aTipoCtb,x[3]) })

For nI := 1 to len(oFolderFil:aDialogs)
    
	For nX := 1 to len(aFModulos[nI]:aDialogs)
		
			For nZ := 1 to len(aCabMod)
				If aTipoMod[nZ] == "N"
					cLineMod += "Transform(aResultSet["+str(nI)+",2,"+str(nX)+",2][aBrwMod["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"],PesqPict('CT2','CT2_VALOR'))," 
				Else	
					cLineMod += "aResultSet["+str(nI)+",2,"+str(nX)+",2][aBrwMod["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"]," 
				Endif	
			Next nX			
			cLineMod := Substr(cLineMod,1,len(cLineMod)-1)

			For nZ := 1 to len(aCabCtb)	
				If aTipoCtb[nZ] == "N"
					cLineCtb += "Transform(aResultSet["+str(nI)+",2,"+str(nX)+",3][aBrwCtb["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"],PesqPict('CT2','CT2_VALOR')),"
				Else 
					cLineCtb += "aResultSet["+str(nI)+",2,"+str(nX)+",3][aBrwCtb["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nz))+"],"	
				Endif	
			Next nZ                                        			
			cLineCtb := Substr(cLineCtb,1,len(cLineCtb)-1)	
			
			oPnlMod	:= aScrLayer[nI,nX]:getWinPanel("ColMod"+cSufix,"WinMod"+cSufix,"Linha"+cSufix)
			oPnlCtb	:= aScrLayer[nI,nX]:getWinPanel("ColCtb"+cSufix,"WinCtb"+cSufix,"Linha"+cSufix) 
			
			If aBrwMod[nI,nX] == nil
				aBrwMod[nI,nX] := TWBrowse():New(0,0,0,0,,aCabMod,aSizeMod,oPnlMod,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
				aBrwMod[nI,nX]:nFreeze := 1
			endif
			
			If aBrwCtb[nI,nX] == nil
				aBrwCtb[nI,nX] := TWBrowse():New(0,0,0,0,,aCabCtb,aSizeCtb,oPnlCtb,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
			Endif
			if !empty(aResultSet[nI,2,nX,2])
				aBrwMod[nI,nX]:Align := CONTROL_ALIGN_ALLCLIENT
				aBrwCtb[nI,nX]:Align := CONTROL_ALIGN_ALLCLIENT							
				
				aBrwMod[nI,nX]:bChange := &("{|| aBrwCtb["+str(nI)+","+str(nX)+"]:GoPosition(aBrwMod["+str(nI)+","+str(nX)+"]:nAt),ChangeCT1()}")
				aBrwCtb[nI,nX]:bChange := &("{|| aBrwMod["+str(nI)+","+str(nX)+"]:GoPosition(aBrwCtb["+str(nI)+","+str(nX)+"]:nAt),ChangeCT1()}")
								
				//aBrwMod[nI,nX]:bLDblClick := {||  CTC660ConfLanc() }
				
				If cSelecOrd == "1" //Ordena pelo Documento
					aSort(aResultSet[nI,2,nX,2],,,{|x,y| x[5] > y[5]})
					aSort(aResultSet[nI,2,nX,3],,,{|x,y| x[22] > y[22]})
				EndIf				
				aBrwMod[nI,nX]:SetArray(aResultSet[nI,2,nX,2])				
								
				aBrwCtb[nI,nX]:bLDblClick := {||  Rastrear()}				
				aBrwCtb[nI,nX]:SetArray(aResultSet[nI,2,nX,3])
			
				aBrwMod[nI,nX]:bLine := &("{|| {" + cLineMod + "}}")
				aBrwCtb[nI,nX]:bLine := &("{|| {" + cLineCtb + "}}")
		        
				aBrwMod[nI,nX]:nClrBackFocus := 0
				aBrwCtb[nI,nX]:nClrBackFocus := 0
		                                         
				aBrwMod[nI,nX]:nClrForeFocus := 0
				aBrwCtb[nI,nX]:nClrForeFocus := 0
		
				aBrwMod[nI,nX]:Refresh()
				aBrwCtb[nI,nX]:Refresh()
			endif 	
		

		cLineMod := ""
		cLineCtb := ""
		
	Next nX
	
Next nI

/*FreeObj(oPnlMod)
oPnlMod := nil
FreeObj(oPnlCtb)
oPnlCtb := nil
//DelClassIntF()*/

Return()

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �GetClauseInArray� Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Gera String da clausula IN de um select de query a partir de um 	 ���
���          �array bidimensional											 	 ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   �GetClauseInArray(aArray,nInd)									     ���
��������������������������������������������������������������������������������Ĵ��
���Parametros�aArray- Tipo: A => dados a serem convertidos 			             ���
���          �nInd	- Tipo: N => Coluna de aArray utilizada na geracao da string ���
��������������������������������������������������������������������������������Ĵ��
���Retorno   �cRet	- Tipo: C => String com a clausula IN			             ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                           ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static function GetClauseInArray(aArray,nInd)

Local nI 	:= 0

Local cRet	:= ""

Default nInd	:= 1

If Len(aArray) == 1
	cRet := " = "
	cRet += "'" + Alltrim(aArray[1,nInd]) + "'"
Else
	cRet := " IN("
	
	For nI := 1 to len(aArray)
		cRet += "'" + Alltrim(aArray[nI,nInd]) + "',"
	Next nI
	
	cRet := Substr(cRet,1,len(cRet)-1) + ")"
Endif              

Return(cRet) 


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �CTBOrdSIXByChave� Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Atraves da chave, busca-se a ordem do indice					 	 ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTBOrdSIXByChave(cAlias,cChave)								     ���
��������������������������������������������������������������������������������Ĵ��
���Parametros�cAlias- Tipo: C => Alias do arquivo								 ���
���          �cCahve- Tipo: C => Chave a ser buscada no SIX						 ���
��������������������������������������������������������������������������������Ĵ��
���Retorno   �nOrdem- Tipo: N => Ordem da chave no SIX				             ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                           ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CTBOrdSIXByChave(cAlias,cChave)

Local nOrdem	:= 0
Local aAreaSIX	:= SIX->(GetArea())

SIX->(DbSetOrder(1))

SIX->(DbSeek(cAlias))

While !SIX->(Eof()) .and. Alltrim(SIX->INDICE) == Alltrim(cAlias)
	If Alltrim(cChave) $ Alltrim(SIX->CHAVE)
		If !IsAlpha(SIX->ORDEM)
			nOrdem := Val(SIX->ORDEM)
		Else                         
			nOrdem := Asc(UPPER(SIX->ORDEM))-55
		Endif	
		Exit
	Endif	
	SIX->(DbSkip())
EndDo

RestArea(aAreaSIX)
Return(nOrdem)


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbcQCLoad	  � Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Carrega os campos necessario para gerar informacoes das tabelas do ���
���          �modulo gerador dos lancamentos								 	 ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbcQCLoad(aSelected)											     ���
��������������������������������������������������������������������������������Ĵ��
���Parametros�aSelected- Tipo: A => Modulos selecionados 			             ���
��������������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Campos que devem ser utilizados pelas tabelas   ���
���          �do modulo gerador													 ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                           ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Static Function CtbcQCLoad(aSelected)

Local aRet		:= {}
Local aAux		:= {}
Local aAreaSx3	:= SX3->(GetArea())
Local aNrDoc	:= {}

Local cQry		:= ""
Local cRetMod	:= GetClauseInArray(aSelected)
Local cConteudo	:= ""
Local cCampo	:= ""
Local cAuxCont	:= ""
Local cFilQry	:= ""

Local lExistX3	:= .f.

Local nI		:= 0
Local nX		:= 0
Local nZ		:= 0
Local nPos		:= 0
Local nW		:= 0

//#TB20200204 Thiago Berna - Ajuste para considerar a filial
For nW := 1 To Len(aCtbc66Fil)
	cFilQry += aCtbc66Fil[nW]
	If Len(aCtbc66Fil) > nW
		cFilQry += "|"	
	EndIf
Next Nw

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	DISTINCT CTL_ALIAS, " + chr(13) + chr(10)
cQry += "	CTL_QCDATA, " + chr(13) + chr(10)
cQry += "	CTL_QCDOC, " + chr(13) + chr(10)
cQry += "	CTL_QCMOED, " + chr(13) + chr(10)
cQry += "	CTL_QCVLRD, " + chr(13) + chr(10)
cQry += "	CTL_QCCORR " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CTL") + " CTL " + chr(13) + chr(10)
cQry += "INNER JOIN " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CVA") + " CVA " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)

//#TB20200204 Thiago Berna - Ajuste para considerar o correto compartilhamento da tabela CVA
//cQry += "	CVA_FILIAL = CTL_FILIAL " + chr(13) + chr(10)
cQry += "	CVA_FILIAL = '" + xFilial("CVA") + "'" + chr(13) + chr(10)

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CVA_CODIGO = CTL_LP " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CVA_MODULO " + cRetMod
cQry += "	AND	 " + chr(13) + chr(10)
cQry += "	CVA.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)

//#TB20200204 Thiago Berna - Ajuste para considerar a filial
cQry += " CTL.CTL_FILIAL IN " + FormatIn(cFilQry,"|") + " AND "

cQry += "	CTL.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)

//Adicionado, pois agora os relacionamentos ser�o realizados pelos RECNOS de Origem e Destino
cQry += "	AND CTL_QCDATA <> '' " + chr(13) + chr(10)
cQry += "	AND CTL_QCVLRD <> '' " + chr(13) + chr(10)

cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	CTL_ALIAS  "

cQry := ChangeQuery(cQry)

If Select("TRBCTL") > 0
	TRBCTL->(DbCloseArea())  
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTL", .T., .F.)

While TRBCTL->(!Eof())

  	lExistX3 := .f.
  	
	For nI := 1 to TRBCTL->(FCount())
		
		cConteudo	:= TRBCTL->(FieldGet(nI))
		cCampo		:= Alltrim(TRBCTL->(FieldName(nI)))
		
		SX3->(DbSetOrder(2))//campo
		
		If Alltrim(cCampo) == "CTL_QCDOC"
			aNrDoc := Separa(cConteudo,"+")
			
			If Len(aNrDoc) > 0
				For nX := 1 to Len(aNrDoc)
				    
					If ( nPos := AT("(",aNrDoc[nX]) ) > 0 
						cConteudo := ""
						For nZ := nPos to len(aNrDoc[nX])
							If Substr(aNrDoc[nX],nZ,1) $ "(*)"
								Loop
							Endif
							
							cAuxCont += Substr(aNrDoc[nX],nZ,1)
							
						Next nZ
						
						aNrDoc[nX] 	:= cAuxCont
							
					Endif
				
					If !("FILIAL" $ aNrDoc[nX])
						lExistX3 := SX3->(DbSeek(aNrDoc[nX]))										
					Endif
				Next nX
			   
				If lExistX3 .and. !Empty(cAuxCont)
					For nX := 1 to len(aNrDoc)	
						cConteudo += aNrDoc[nX]+ "+"
					Next nX	
					cAuxCont	:= ""
					cConteudo 	:= Substr(cConteudo,1,Rat("+",cConteudo)-1)
				Endif
					
			Else	
				lExistX3 := SX3->(DbSeek(cConteudo))
			Endif	
		Else
			lExistX3 := SX3->(DbSeek(cConteudo))
		Endif
		
		If (!Empty(cConteudo) .and. lExistX3 ) .or. cCampo == "CTL_ALIAS"
			aAdd(aAux,cConteudo)
		Else
			Do Case
			Case cCampo == "CTL_QCDATA"	
				aAdd(aAux,"NO_DATA")
			Case cCampo == "CTL_QCDOC"
				aAdd(aAux,"NO_DOC")
			Case cCampo == "CTL_QCMOED"
				aAdd(aAux,"NO_MOEDA")
			Case cCampo == "CTL_QCVLRD"
				aAdd(aAux,"NO_VALOR")
			Case cCampo == "CTL_QCCORR"				
				aAdd(aAux,"NO_NODIA")			
			EndCase	
		Endif
	Next nI
    
	aAdd(aRet,aAux)
	aAux := {}	
	//aAdd(aRet,{TRBCTL->CTL_ALIAS,TRBCTL->CTL_QCDATA,TRBCTL->CTL_QCDOC,TRBCTL->CTL_QCMOED,TRBCTL->CTL_QCVLRD,TRBCTL->CTL_QCCORR})
	TRBCTL->(DbSkip())
EndDo

TRBCTL->(DbCloseArea())

RestArea(aAreaSX3)

Return(aRet)


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �CTBC66GetHBrw	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Gera as colunas dos objetos tWBrowse referentes ao modulo e a   ���
���          �contabilidade													  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTBC66GetHBrw(nCabTipo)										  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�nCabTipo	- Tipo: N => Tipo de cabecalho a ser montado          ���
���          �				1 = Modulo									      ���
���          �				2 = Contabilidade				      			  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aRetCab	- Tipo: A => Dados para a formacao das colunas dos    ���
���          �objetos twBrowse											      ���
���          �	aRetCab[n,1] - Tipo: C => Titulo da coluna				      ���
���          �	aRetCab[n,2] - Tipo: N => Tamanho da coluna				      ���
���          �	aRetCab[n,3] - Tipo: C => Tipo de dado da coluna		      ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CTBC66GetHBrw(nCabTipo)

Local aRetCab		:= {}
Local aTitulo		:= {}
Local aAux			:= {} 
Local aEntidades	:= Ctbc66RetEnt()

Local nI		:= 0

If nCabTipo == 1     

	aAux := {	" ",;      
	            "CT2_FILIAL",;
				STR0026,; 	//##"Arquivo"
				STR0027,;	//## "Data"
				STR0028,;	//##"Documento"
				"CT2_MOEDLC",;
				STR0029,;	//##"Valor Doc."
				"CT2_NODIA",;
				"CT2_DEBITO",;
				"CT2_CREDIT",;
				"CT2_CCD",;
				"CT2_CCC",;
				"CT2_ITEMD",;
				"CT2_ITEMC",;
				"CT2_CLVLDB",;
				"CT2_CLVLCR"}

	For nI := 1 to len(aEntidades[1])
		aAdd(aAux,aEntidades[1,nI,1])
		aAdd(aAux,aEntidades[2,nI,1])
	Next nI
Else	   
	aAux := {	"CT2_FILIAL",;
				"CT2_DATA",;
				"CT2_TPSALD",;
				"CT2_LOTE",;
				"CT2_SBLOTE",;
				"CT2_DOC",;
				"CT2_LINHA",;
				"CT2_LP",;
				"CT2_SEQLAN",;
				"CT2_NODIA",;
				"CT2_DEBITO",;
				"CT2_CREDIT",;
				"CT2_CCD",;
				"CT2_CCC",;
				"CT2_ITEMD",;
				"CT2_ITEMC",;
				"CT2_CLVLDB",;
				"CT2_CLVLCR"}

	For nI := 1 to len(aEntidades[1])
		aAdd(aAux,aEntidades[1,nI,1])
		aAdd(aAux,aEntidades[2,nI,1])
	Next nI
	
	aEval(aCtbc66Moe,{|x| aAdd(aAux,alltrim(x[3])) })

Endif

For nI := 1 to len(aAux)
	If nCabTipo == 1
		If nI == 7
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI],"N")	
		Else
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI])		
		Endif	
	Else
		If nI > 18+len(aEntidades[1])*2
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI],"N")	
		Else
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI])	
		Endif
	EndIf	
	aAdd(aRetCab,{aTitulo[1],aTitulo[2],aTitulo[3]})
Next nI    


Return(aRetCab)


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66GCpoTit	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Gera as informacoes necessarias para a criacao das colunas      ���
���          �dos objetos tWBrowse referentes ao modulo e a contabilidade	  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66GCpoTit(cAlias,cField,cTipoDef)							  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cAlias	- Tipo: C => Alias do arquivo 				          ���
���          �cField	- Tipo: C => Campo									  ���
���          �cTipoDef	- Tipo: C => tipo de dado que coluna ira assumir	  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Informacoes das colunas				      ���
���          �	aRet[1] - Tipo: C => Titulo da coluna		   			      ���
���          �	aRet[2] - Tipo: N => Tamanho da coluna					      ���
���          �	aRet[3] - Tipo: C => Tipo de dado da coluna		    		  ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/ 
Static Function Ctbc66GCpoTit(cAlias,cField,cTipoDef)

Local aRet			:= {}
Local aAreaSX3		:= SX3->(GetArea())

Local cTitulo		:= ""
Local cTipo			:= ""

Local nConst		:= 2.5
Local nVal			:= 0

Default cTipoDef	:= "C"

SX3->(DbSetOrder(2))//campo

If "_" $ cField .and. SX3->(DbSeek(cField))
	cTitulo := (cAlias)->(RetTitle(cField))	
	nVal 	:= ( TamSx3(cField)[1]*nConst )+( len(cTitulo)*nConst )
	cTipo 	:= Alltrim(SX3->X3_TIPO)
Else
	cTitulo := cField
	nVal	:= 40 + (len(cTitulo)*nConst)	
	cTipo	:= cTipoDef 
Endif

aRet := {cTitulo,nVal,cTipo}

RestArea(aAreaSX3)
Return(aRet)

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �CtbC66GMoe	� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna as moedas cadastradas que nao estao bloqueadas 	      ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �CtbC66GMoe()													  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�      	                              				          	 	 ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Moedas do cadastradas na tab. CTO		    ���
���          �	aRet[n,1] - Tipo: C => Titulo da coluna		   			    ���
���          �	aRet[n,2] - Tipo: N => Tamanho da coluna				      	 ���
���          �	aRet[n,3] - Tipo: C => Tipo de dado da coluna	    		  	 ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CtbC66GMoe()

Local cFilCTO	:= xFilial("CTO")

Local aRet 		:= {}
Local aAreaCTO  := CTO->(GetArea())

CTO->(dbsetorder(1)) 

If Empty(cFilCTO)
	CTO->(dbGotop())
Else
	CTO->(DbSeek(cFilCTO))
Endif

While CTO->(!Eof()) .and. xFilial("CTO") == CTO->CTO_FILIAL
	If Alltrim(CTO->CTO_BLOQ) == "2" .And. CTO->CTO_MOEDA == "01"
		aAdd(aRet,{CTO->CTO_MOEDA,CTO->CTO_SIMB,"Valor"})
	Endif	              
	CTO->(DbSkip())
EndDo

Restarea(aAreaCTO)
Return(aRet)


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �GetValMCT2	� Autor �Fernando Radu Muscalu � Data � 29/08/11  	 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna os valores dos lancamentos contabeis nas n moedas que   	 ���
���          �foram lancadas.												  	 	 ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �GetValMCT2(cNodia,cSeqLan,cFilPesq)							  	 ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cNodia	- Tipo: C => Nro diario, conhecido como correlativo   	 ���
���          �cSeqLan	- Tipo: C => Sequencia do lancamento contabil		  	 ���
���          �cFilPesq	- Tipo: C => Filial									  	 ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Valores nas Moedas dos Lancamentos Contabeis���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function GetValMCT2(nRecnoCT2,cSeqLan,cFilPesq)
Local aRet
Local aAreaCT2	:= CT2->(GetArea())
Local aExist	:= {}
Local nP		:= 0

If nRecnoCT2 > 0
    
	CT2->(DbGoTo(nRecnoCT2))
	    
	aRet := Array(len(aCtbc66Moe))
	   aFill(aRet,0)
	                                   
	nP := aScan(aCtbc66Moe,{|x| alltrim(x[1]) == Alltrim(CT2->CT2_MOEDLC) })
	If nP > 0
		If aScan(aExist,CT2->CT2_MOEDLC) == 0
			aRet[nP] := CT2->CT2_VALOR
			aAdd(aExist,CT2->CT2_MOEDLC)
		Endif
	Endif	
Endif

Restarea(aAreaCT2)

Return(aRet)



/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �GetFieldFil	� Autor �Fernando Radu Muscalu � Data � 29/08/11  	 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna o nome do campo filial do alias passado				  		 ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �GetFieldFil(cAlias)											  		 ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cAlias	- Tipo: C => Alias do arquivo 						  		 ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �cRet	- Tipo: C => Nome do campo Filial do dicionario SX3		 ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function GetFieldFil(cAlias)

Local cRet		:= ""
Local aAreaSx3	:= SX3->(GetArea())

SX3->(DbSetOrder(1))//adicionado por Caio Quiqueto

If SX3->(DbSeek(cAlias))
	While SX3->(!Eof()) .AND. Alltrim(SX3->X3_ARQUIVO) == Alltrim(cAlias) 
		If "FILIAL" $ SX3->X3_CAMPO 
			cRet := Alltrim(SX3->X3_CAMPO)
			Exit 
		Endif	
		SX3->(DBSKIP())
	EndDo
Endif

RestArea(aAreaSx3)
Return(cRet)


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66CV3		� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna os dados do arquivo CV3 pois estes irao compor as       	 ���
���          �informacoes do lado do modulo, quando ha lancamento contabil    ���
���          �para um determinado registro do modulo						  		 ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66CV3(cData,cSequen,cLPSeq,cFilPesq)						  	 ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cData		- Tipo: C => data do lancamento 					  	 ���
���          �cSequen	- Tipo: C => sequencia do lancamento				  	 ���
���          �cLPSeq	- Tipo: C => Sequencia do LP						  		 ���
���          �cFilPesq	- Tipo: C => Filial			 						  	 ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �aRet	- Tipo: A => Dados de CV3								  	 ���
���          �	aRet[1]	- Tipo: C => Conta Debito							 ���
���          �	aRet[2]	- Tipo: C => Conta Credito							 ���
���          �	aRet[3]	- Tipo: C => Centro de Custo Debito				 ���
���          �	aRet[4]	- Tipo: C => Centro de Custo Credito				 ���
���          �	aRet[5]	- Tipo: C => Item de Conta Debito					 ���
���          �	aRet[6]	- Tipo: C => Item de Conta Credito					 ���
���          �	aRet[7]	- Tipo: C => Classe de Valor Debito				 ���
���          �	aRet[8]	- Tipo: C => Classe de Valor Credito				 ���
���          �	aRet[9]	- Tipo: C => Array com as demais entidades		 ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function Ctbc66CV3(cData,cSequen,cLPSeq,cFilPesq,nRecno,nRecOri,cAliOri)

Local aAreaCV3		:= CV3->(GetArea()) 
Local aRet			:= {}
Local aEnt			:= Ctbc66RetEnt("CV3")

Local nI			:= 0
Local nQtdEnt		:= 0

Default cFilPesq	:= xFilial("CV3")

aRet 	:= Array(9)
aFill(aRet,"")
aRet[9]	:= {}          
nQtdEnt := len(aEnt[1])

If !Empty(nRecno)

	//CV3->(DbSetOrder(2))
	CV3->(DbSetOrder(3))
	
	//If CV3->(DbSeek(cFilPesq + padr(AllTrim(STR(nRecno)),tamSX3("CV3_RECDES")[1])))
	If CV3->(DbSeek(cFilPesq + cAliOri + Padr(AllTrim(STR(nRecOri)),tamSX3("CV3_RECORI")[1]) + Padr(AllTrim(STR(nRecno)),tamSX3("CV3_RECDES")[1])))
		aRet[1] := CV3->CV3_DEBITO
   		aRet[2] := CV3->CV3_CREDIT
   		aRet[3] := CV3->CV3_CCD
    	aRet[4] := CV3->CV3_CCC
		aRet[5] := CV3->CV3_ITEMD
		aRet[6] := CV3->CV3_ITEMC
		aRet[7] := CV3->CV3_CLVLDB
		aRet[8] := CV3->CV3_CLVLCR
		For nI := 1 to nQtdEnt
			aAdd(aRet[9],CV3->&(aEnt[1,nI,1]))		
			aAdd(aRet[9],CV3->&(aEnt[2,nI,1]))	
		Next nI
	Endif
Endif    				

If len(aRet[9]) == 0
	aRet[9]	 := Array(nQtdEnt*2)
	aFill(aRet[9],"")	
Endif

Restarea(aAreaCV3) 

Return(aRet)


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66FillBlank� Autor �Fernando Radu Muscalu � Data � 29/08/11  ���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Adiciona valores em branco no array master aResultSet caso nao   ���
���          �haja nenhum valor preenchido.									   ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66FillBlank(aResult)	     								   ���
������������������������������������������������������������������������������Ĵ��
���Parametros�aResult - Tipo: A => Array com os dados comparativo Modulo X     ���
���          �Contabilidade													   ���
������������������������������������������������������������������������������Ĵ��
���Retorno   �Nil							    							   ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                         ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function Ctbc66FillBlank(aResult)
Local nI		:= 0
Local aAux		:= {}
Local nQtdEnt   := Len(Ctbc66RetEnt()[1])*2

For nI := 1 to len(aResult)
	If aResult[nI,2] == nil
	
		aResult[nI,2] := {}
	
		aAux := Array(16+nQtdEnt)
		
		aFill(aAux,"")          
		
		aAux[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
		
		Aadd(aAux,-1)		//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
		
		aAdd(aResult[nI,2],aAux)
		aAux := {}
	Endif
	If aResult[nI,3] == nil    
	
		aResult[nI,3] := {}
	
		aAux := Array(20+nQtdEnt+len(aCtbc66Moe))
		aFill(aAux,"")     
		
		aResult[nI,2,len(aResult[nI,2]),1] := LoadBitmap(GetResources(),"BR_VERDE")
		
		Aadd(aAux,-1)		//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
		
		aAdd(aResult[nI,3],aAux)
		aAux := {}
	Endif
Next nI

Return()

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66RetEnt	 � Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna os campos e suas descricoes das outras entidades		    ���
���          �contabeis alem das quatro fixas							 	    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66RetEnt(cAlias)		     								    ���
�������������������������������������������������������������������������������Ĵ��
���Parametros�cAlias - Tipo: C => Alias do arquivo						        ���
�������������������������������������������������������������������������������Ĵ��
���Retorno   �Array - Entidades contabeis alem das 4 fixas					    ���
���          �	Array[1] - Tipo: A => Entidades de Debito					    ���
���          �		Array[1,n,1] - Tipo: C => Campo para o Alias passado        ���
���          �		Array[1,n,2] - Tipo: C => Nome do campo para o Alias passado���
���          �	Array[2] - Tipo: A => Entidades de Credito					    ���
���          �		Array[2,n,1] - Tipo: C => Campo para o Alias passado        ���
���          �		Array[2,n,2] - Tipo: C => Nome do campo para o Alias passado���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                         	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Static Function Ctbc66RetEnt(cAlias)

Local aRetDb	:= {}
Local aRetCr	:= {}
Local aAreaSX3 	:= SX3->(GetArea())

Local nQtdEnt	:= 0
Local nI		:= 0

Local cCompl	:= ""

Default cAlias	:= "CT2"

nQtdEnt := CtbQtdEntd()

SX3->(DbSetOrder(1))

If SX3->( DbSeek(cAlias) ) 
	cCompl := Substr(SX3->X3_CAMPO,1,At("_",SX3->X3_CAMPO,1))		
Endif

If !Empty(cCompl) .And. .F. //For�a somente as Entidades Padr�es
	For nI := 5 to nQtdEnt
		
		aAdd(aRetDB,{cCompl+"EC"+STRZERO(nI,2)+"DB",(cAlias)->(RetTitle(cCompl+"EC"+STRZERO(nI,2)+"DB"))} )
		aAdd(aRetCR,{cCompl+"EC"+STRZERO(nI,2)+"CR",(cAlias)->(RetTitle(cCompl+"EC"+STRZERO(nI,2)+"CR"))} )
		
	Next nI
Endif


RestArea(aAreaSX3)

Return({aRetDb,aRetCr})

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctbc66GRsc	 � Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �funcao responsavel pela definicao do semafaro para os registros   ���
���          �que compoe a browse do modulo								 	    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctbc66GRsc(aArrayMod,aArrayCtb,cAlias,nTipo,aDataCV3,aCfgFields)  ���
�������������������������������������������������������������������������������Ĵ��
���Parametros�aArrayMod - Tipo: A => Array com os dados do Modulo    	        ���
���          �aArrayCtb - Tipo: A => Array com os dados da Contabilidade        ���
���          �cAlias 	- Tipo: C => Alias do arquivo do modulo				    ���
���          �nTipo 	- Tipo: N => Tipo de Validacao a ser usada			    ���
���          �      	  1 = Validacao diretamente no browse     			    ���
���          �      	  2 = Validacao na composicao dos dados do array master 	���
���			   �cBmp - Tipo: O => Objeto com a cor										���
�������������������������������������������������������������������������������Ĵ��
���Retorno   �nStatus - Tipo: N => status da conta								���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                         	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Static Function Ctbc66GRsc(aArrayMod,aArrayCtb,cAlias,nTipo,aDataCV3,aCfgFields,cBmp) 			
Local nStatus		:= 0
Local aCabecMod 	:= CTBC66GetHBrw(1)
Local aEntities 	:= Ctbc66RetEnt()
Local nI			:= 0
Local nEnt			:= 0
Local nX 			:= 0
Local nPos			:= 0
Local lDone			:= .f.

Default nTipo		:= 1
Default aDataCV3	:= {}
Default aArrayMod	:= {}
Default aArrayCtb	:= {}

//cBmp		:= LoadBitmap(GetResources(),"BR_VERDE")
cBmp		:= "BR_VERDE"

If nTipo == 1
    nX 		:= 11
    nEnt	:= Len(aEntities[1]) * 2
	For nI := 1 to len(aCabecMod)
		
		If nI == 3
			If ( Empty(aArrayMod[nI]) .and. !Empty(aArrayCtb[2]) ) .or. ( !Empty(aArrayMod[nI]) .and. Empty(aArrayCtb[2]) ) 		
				//cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")	
				cBmp := "BR_VERMELHO"
				nStatus:=1		
				Exit
			Endif
		ElseIf nI == 7
			If ( !Empty(aArrayMod[nI]) .or. !Empty(aArrayCtb[20+nEnt]) ) .and. aArrayMod[nI] <> aArrayCtb[20+nEnt]
				//cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
				cBmp := "BR_AMARELO"
				nStatus:=2
				Exit
			Endif	
		ElseIf nI >= 9 
			If (!Empty(aArrayMod[nI]) .or. !Empty(aArrayCtb[nX]) ) .and. aArrayMod[nI] <> aArrayCtb[nX]
				//cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
				cBmp := "BR_AMARELO"
				nStatus:=2
			Endif
			nX++
		Endif
	Next nI
Else   
	
	nEnt	:= Len(aEntities[1])

	If ( Empty( (cAlias)->&(aCfgFields[NRODOC]) ) .AND. !Empty((cAlias)->CT2_DATA) ) .OR. ( !Empty((cAlias)->&(aCfgFields[NRODOC])) .AND. Empty((cAlias)->CT2_DATA ) )
		//cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")
		cBmp := "BR_VERMELHO"
		nStatus:=1			
		lDone := .t.	
	Endif

	If !lDone	
		
		//nPos := (cAlias)->(FieldPos(aCfgFields[NODIA])) 
		
        //�����������������������������������������������������������������������������������������������Ŀ
        //� Problemas encontrados no modulo SIGAATF; somente SN3 esta, atualmente, sendo rastreado em CV3 �
        //� **  Nao conformidade a ser resolvida: SN3->N3_NODIA nao esta sendo gravado ! *** 02/01/2013   �
        //�������������������������������������������������������������������������������������������������
        //If ( Empty((cAlias)->(FieldGet(nPos) )) .and. !Empty((cAlias)->CT2_NODIA) ) .OR. ( !Empty((cAlias)->(FieldGet(nPos))) .and. Empty((cAlias)->CT2_NODIA) )
		  //	cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")	
		   	//nStatus:=1		
		  	//lDone := .t.
		//Endif
		
		If !lDone
			If (!Empty((cAlias)->DELETADO) .or. !Empty((cAlias)->CT2_DELET) ) .and. (cAlias)->DELETADO <> (cAlias)->CT2_DELET
				//cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")
				cBmp := "BR_VERMELHO"
				nStatus:=1
				lDone := .t.			
			Endif                       
			
			If !lDone
				If (cAlias)->CT2_CONFST == "1"
					//cBmp    := LoadBitmap(GetResources(),"BR_PRETO")
					cBmp    := "BR_PRETO"
					nStatus := 3
					lDone   := .T.
				Else
					//Verifica se o Valor do documento e diferente da contabilidade
					nPos := (cAlias)->(FieldPos(aCfgFields[VLRDOC]))
					If ( !Empty((cAlias)->(FieldGet(nPos))) .or. !Empty( (cAlias)->CT2_VALOR ) ) .and. (cAlias)->(FieldGet(nPos)) <> (cAlias)->CT2_VALOR
						If (cAlias)->CT2_CONFST == "1"
							//cBmp := LoadBitmap(GetResources(),"BR_PRETO")
							cBmp    := "BR_PRETO"
							nStatus:=3
							Else	
							//cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
							cBmp    := "BR_AMARELO"
							nStatus:=2
						EndIf	
						lDone := .t.			
					Endif
				EndIf	                    
				
				If !lDone 
					//Verifica se ha divergencias entre as quantidades
					aPosEntCT2 := {	(cAlias)->(FieldPos("CT2_DEBITO")),;
									(cAlias)->(FieldPos("CT2_CREDIT")),;
									(cAlias)->(FieldPos("CT2_CCD")),;
									(cAlias)->(FieldPos("CT2_CCC")),; 
									(cAlias)->(FieldPos("CT2_ITEMD")),;
									(cAlias)->(FieldPos("CT2_ITEMC")),;
									(cAlias)->(FieldPos("CT2_CLVLDB")),;
									(cAlias)->(FieldPos("CT2_CLVLCR")),;
									} 
									
					
					For nI := 1 to nEnt
						aAdd(aPosEntCt2,(cAlias)->(FieldPos(aEntities[1,nI,1])))	
						aAdd(aPosEntCt2,(cAlias)->(FieldPos(aEntities[2,nI,1])))	
					Next nI	
					
					For nI := 1 to len(aDataCV3)
						
						If Valtype(aDataCV3[nI]) <> "A"
							cEntCT2 := (cAlias)->(FieldGet(aPosEntCt2[nI]))
							
							If ( !Empty(aDataCV3[nI]) .or. !Empty(cEntCT2) ) .and. aDataCV3[nI] <> cEntCT2
								//cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
								cBmp    := "BR_AMARELO"
								nStatus:=2			
								lDone := .t.	
							Endif
						Endif
						
						If !lDone
							If Valtype(aDataCV3[nI]) == "A"	 
								For nX := 1 to len(aDataCV3[nI])           
									cEntCT2 := (cAlias)->(FieldGet(aPosEntCt2[nI+nX]))
									If ( !Empty(aDataCV3[nI,nX]) .or. !Empty(cEntCT2) ) .and. aDataCV3[nI,nX] <> cEntCT2
										//cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
										cBmp    := "BR_AMARELO"
										nStatus:=2			
										lDone := .t.	
										Exit
									Endif
								Next nX
							Endif 
						Endif   
						
						If lDone
							Exit
						Endif
					Next nI
					
				Endif
				
			Endif
			
	    Endif
		
	Endif

Endif

Return(nStatus)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    �CTBC66leg		 � Autor �Fernando Radu Muscalu � Data � 29/08/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem da tela de legenda									    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTBC66leg()														���
�������������������������������������������������������������������������������Ĵ��
���Parametros�																	���
�������������������������������������������������������������������������������Ĵ��
���Retorno   �Nil																���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                         	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Static Function CTBC66leg()

Local aCores := {	{"BR_VERMELHO"	,STR0030	},;		//## "Documentos desbalanceados."
				 	{"BR_AMARELO"   ,STR0031	},;		//## "Doc. dados divergentes"
				 	{"BR_VERDE"		,STR0032	},;		//## "Documentos corretos."
				 	{"BR_PRETO"     ,STR0059    }	}   //## "Documentos conferidos."

BrwLegenda(STR0005,STR0024,aCores)  //##"Relat�rio de Auditoria"#"Legenda"

Return()

/*
Mapa de aResultSet

aResultSet
	aResultSet[n] - array, refere-se a aba das Dialogs das Filiais
		aResultSet[n,1] - Filial Codigo + Descicao 
		aResultSet[n,2] - array, refere-se a aba dos Modulos selecionados 
			aResultSet[n,2,x] - array dos modulos
				aResultSet[n,2,x,1] - nro do modulo
				aResultSet[n,2,x,2] - array com as informacoes do modulo
					aResultSet[n,2,x,2,z] 		- array indicando a Linha 
						aResultSet[n,2,x,2,z,1] 		- Bitmap da cor
						aResultSet[n,2,x,2,z,2] 		- Filial
						aResultSet[n,2,x,2,z,3] 		- CV3_TABORI
						aResultSet[n,2,x,2,z,4] 		- Data (Pegar na CTL)
						aResultSet[n,2,x,2,z,5] 		- Documento (Pegar na CTL)
						aResultSet[n,2,x,2,z,6] 		- Moeda (Pegar na CTL)
						aResultSet[n,2,x,2,z,7] 		- Vlr Doc (Pegar na CTL)
						aResultSet[n,2,x,2,z,8] 		- Correlativo
						aResultSet[n,2,x,2,z,9] 		- CV3_DEBITO
						aResultSet[n,2,x,2,z,10] 		- CV3_CREDIT
						aResultSet[n,2,x,2,z,11] 		- CV3_CCD
						aResultSet[n,2,x,2,z,12]		- CV3_CCC
						aResultSet[n,2,x,2,z,13]	 	- CV3_ITEMD
						aResultSet[n,2,x,2,z,14]	 	- CV3_ITEMC
						aResultSet[n,2,x,2,z,15] 		- CV3_CLVLDB
						aResultSet[n,2,x,2,z,16] 		- CV3_CLVLCR
						aResultSet[n,2,x,2,z,17] 		- Status// adicionado por Caio Quiqueto
						aResultSet[n,3,x,2,z,18...n]	- Entidades Contabeis
				aResultSet[n,2,x,3] - array Contabilidade
					aResultSet[n,2,x,3,z] 		- array indicando a Linha 
						aResultSet[n,2,x,3,z,1] 		- CT2_FILIAL
						aResultSet[n,2,x,3,z,2] 		- CT2_DATA
						aResultSet[n,2,x,3,z,3] 		- CT2_TPSALD
						aResultSet[n,2,x,3,z,4] 		- CT2_LOTE
						aResultSet[n,2,x,3,z,5] 		- CT2_SBLOTE
						aResultSet[n,2,x,3,z,6] 		- CT2_DOC
						aResultSet[n,2,x,3,z,7] 		- CT2_LINHA
						aResultSet[n,2,x,3,z,8] 		- CT2_SEQLAN
						aResultSet[n,2,x,3,z,9] 		- CT2_LP
						aResultSet[n,2,x,3,z,10] 		- CT2_NODIA
						aResultSet[n,2,x,3,z,11] 		- CT2_DEBITO
						aResultSet[n,2,x,3,z,12] 		- CT2_CREDIT
						aResultSet[n,2,x,3,z,13] 		- CT2_CCD
						aResultSet[n,2,x,3,z,14] 		- CT2_CCC
						aResultSet[n,2,x,3,z,15] 		- CT2_ITEMD
						aResultSet[n,2,x,3,z,16] 		- CT2_ITEMC
						aResultSet[n,2,x,3,z,17] 		- CT2_CLVLDB
						aResultSet[n,2,x,3,z,18] 		- CT2_CLVLCR
						aResultSet[n,2,x,3,z,20...n]	- Entidades Contabeis
						aResultSet[n,2,x,3,z,n+1...n+y]- valor nas Moedas
						aResultSet[n,2,x,3,z,n+y+1]	- CT2_DC	 	

*/                  

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � CTC660Conf()	 � Autor � Jose Lucas           � Data � 31/10/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Conferir lan�amentos e gravar marca de conferencia.			    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTC660Conf(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3)						���
�������������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 := oFolderFil - Folder com as filiais ativas).				���    
���          � ExpO2 := aFModulos - Folder com as configura��es modulos).		���
���          � ExpA1 := aBrwMod - Objeto correspondente ao browse do m�dulo sel-���
���          � ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		���
���          � ExpA2 := aBrwCtb - Objeto correspondente ao browse do m�dulo CTB.���
���          � ExpA3 := Array aResultSet.										���
�������������������������������������������������������������������������������Ĵ��
���Retorno   � Nil																���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � CTC660 - Quadratura                                             	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/                                
Static Function Ct660Conf(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet) 
Local nI := 0 //Elemento correspondente ao folder da filial corrente.
Local nX := 0 //Elemento correspondente ao subfolder do modulo corrente.
Local nC := 0      
Local nPosLinha := 0
Local lConfere  := .F.
Local lConferir := .F.
Local lReverter := .F.
local cMod:=0 //codigo do modulo
Local oConferir
Local oObs 
Local cObs      := CriaVar("CT2_OBSCNF")              
Local lGravaCT2 := .F.
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local oDlg		:= Nil
Local nHeight	:= aSizeDlg[3] * 0.50
Local nWidth    := aSizeDlg[4] * 0.60
Local bUpdate	:= {|| If(lConferir .and. !Empty(cObs),(Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,.T.,.F.),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}							
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }
  
nI := oFolderFil:nOption				//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption			//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0 )
	cMod:=aFModulos[nI]:aDialogs[nX]:cCaption
	if !("34" $ cMod)
		nPosLinha := aBrwMod[nI][nX]:nAt	//Posi��o da linha do lan�amento posicionado.
		If nPosLinha > 0      
			If aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName $ "BR_AMARELO|BR_VERDE" 
				lConfere := .T.
			Else	
				If "BR_PRETO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
					lConfere := .F. 
					Help(" ",1,"CTBC660_DOCCONF",,STR0034,1,0)	 //"Documento ja conferido."
				ElseIf ! "BR_AMARELO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
					lConfere := .F.
					Help(" ",1,"CTBC660_NOCONF",,STR0035,1,0)	 //"Documento n�o permite conferecia."
				EndIf
			EndIf		
			
			If lConfere                                                                    
			
				DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0036 PIXEL STYLE DS_MODALFRAME of oMainWnd  //###Conferencia do Documento
			
				@ 031,010  CHECKBOX oConferir VAR lConferir PROMPT STR0037 PIXEL OF oDlg SIZE 80,9 MESSAGE STR0038;	  //###"Se estiver marcado, modificar� o status e gravar� o lan�amento contabil como conferido."
					   	 			ON CLICK lGravaCT2 := .T.
		
				@ 044,011  SAY OemToAnsi(STR0039)	PIXEL OF oDlg SIZE 50,9			// "Observa��o"
				@ 051,010  MSGET oObs	VAR cObs Picture "@!" 	VALID Ct660Obs(cObs)  PIXEL OF oDlg SIZE 150,10
	
				oDlg:Activate(,,,.T.,,,bEnchBar)
	        EndIf
	    EndIf
	Else
		lConfere := .F.
		Help(" ",1,"CTBC660_NOCONF",,STR0035,1,0)	 //"Documento n�o permite conferecia."
	Endif
EndIf
Return

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � CTC660Reve()	 � Autor � Jose Lucas           � Data � 31/10/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Reverter a confirma��o do lan�amento selecionado.			    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTC660Reve(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3)						���
�������������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 := oFolderFil - Folder com as filiais ativas).				���    
���          � ExpO2 := aFModulos - Folder com as configura��es modulos).		���
���          � ExpA1 := aBrwMod - Objeto correspondente ao browse do m�dulo sel-���
���          � ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		���
���          � ExpA2 := aBrwCtb - Objeto correspondente ao browse do m�dulo CTB.���
���          � ExpA3 := Array aResultSet.										���
�������������������������������������������������������������������������������Ĵ��
���Retorno   � Nil																���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � CTC660 - Quadratura                                             	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/                                
Static Function CT660Reve(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet) 
Local nI := 0 
Local nX := 0 
Local nC := 0      
Local nPosLinha := 0
Local lConfere  := .F.
Local lConferir := .F.
Local lReverter := .T.
Local oConferir
Local oObs 
Local cObs      := CriaVar("CT2_OBSCNF")              
Local lGravaCT2 := .F.
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local nHeight	:= aSizeDlg[3] * 0.50
Local nWidth    := aSizeDlg[4] * 0.60
Local oDlg		:= Nil
Local bUpdate	:= {|| If(lConferir .and. lReverter,(Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,.F.,lReverter),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}							
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }
  
nI := oFolderFil:nOption				//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption			//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0 )
	cMod:=aFModulos[nI]:aDialogs[nX]:cCaption
	if !("34" $ cMod)
		nPosLinha := aBrwMod[nI][nX]:nAt	//Posi��o da linha do lan�amento posicionado.
		If nPosLinha > 0      
			If "BR_PRETO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lConfere  := .T.
				dDataLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][2]
				cLoteLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][4]
				cSBLote   := aBrwCtb[nI][nX]:aArray[nPosLinha][5]
				cDocLanc  := aBrwCtb[nI][nX]:aArray[nPosLinha][6]
				cLinha    := aBrwCtb[nI][nX]:aArray[nPosLinha][7]
				cTipSaldo := aBrwCtb[nI][nX]:aArray[nPosLinha][3]
				CT2->(dbSetOrder(1))
				CT2->(dbSeek(xFilial("CT2")+DTOS(dDataLan)+cLoteLan+cSBLote+cDocLanc+cLinha+cTipSaldo))
	            cObs := CT2->CT2_OBSCNF
			Else
				lConfere := .F.
				Help(" ",1,"CTBC660_NOREV",,STR0040,1,0)	 //"Revers�o s� � poss�vel nos documentos confirmados."
			EndIf		
			
			If lConfere                                                                    
			
				DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0041 PIXEL STYLE DS_MODALFRAME of oMainWnd  	//"Revers�o do Documento"
	
				@ 031,010  CHECKBOX oConferir VAR lConferir PROMPT STR0042 PIXEL OF oDlg SIZE 80,9 MESSAGE STR0043;		//"Reverter Documento"###"Se estiver marcado, reverter� o status estornando a conferencia do documento contabil."
					   	 			ON CLICK lGravaCT2 := .T.
		
				@ 044,011  SAY OemToAnsi(STR0039)	PIXEL OF oDlg SIZE 50,9			// "Observa��o"
				@ 051,010  MSGET oObs	VAR cObs Picture "@!" 	WHEN .F.            	PIXEL OF oDlg SIZE 150,10
	
				oDlg:Activate(,,,.T.,,,bEnchBar)
	        EndIf
	    EndIf
	Endif
EndIf
Return

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � Ct660GrvCT2()	 � Autor � Jose Lucas       � Data � 04/11/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados de conferencia ou revers�o de lan�amento na tabela  ���
���          � de lan�amentos contabeis na tabela CT2.                          ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � C660GrvCT2(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3, ExpN1, ExpL1, ExpL2)	���
���          � Linha,lConferir,lReverter)										���
�������������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 := oFolderFil - Folder com as filiais ativas).				���    
���          � ExpO2 := aFModulos - Folder com as configura��es modulos).		���
���          � ExpA1 := aBrwMod - Objeto correspondente ao browse do m�dulo sel-���
���          � ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		���
���          � ExpA2 := aBrwCtb - Objeto correspondente ao browse do m�dulo CTB.���
���          � ExpA3 := Array aResultSet.										���
���          � ExpN1 := Numero da linha do elemento selecionado.				���
���          � ExpL1 := Variavel de controle lConferir.							���
���          � ExpL2 := Variavel de controle lReverter.							���   
�������������������������������������������������������������������������������Ĵ��
���Retorno   � Nil																���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � CTC660 - Quadratura Contabil.                                   	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/  
Static Function Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,lConferir,lReverter) 
Local aArea := GetArea()
Local nI := 0 
Local nX := 0 
Local dDataLan  := CTOD("")
Local cLoteLan  := ""
Local cSBLote   := ""
Local cDocLanc  := ""
Local cLinha    := ""
Local cTipSaldo := ""

nI := oFolderFil:nOption			//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption		//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0 ) .and. nPosLinha > 0                
	cFilCT2   := aBrwCtb[nI][nX]:aArray[nPosLinha][1] 
	dDataLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][2]
	cLoteLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][4]
	cSBLote   := aBrwCtb[nI][nX]:aArray[nPosLinha][5]
	cDocLanc  := aBrwCtb[nI][nX]:aArray[nPosLinha][6]
	cLinha    := aBrwCtb[nI][nX]:aArray[nPosLinha][7]
	cTipSaldo := aBrwCtb[nI][nX]:aArray[nPosLinha][3]
	CT2->(dbSetOrder(1)) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
	//Alert("xFilial: " + xFilial("CT2") + " cFilCT2: " + cFilCT2)
	If CT2->(dbSeek(xFilial("CT2")+DTOS(dDataLan)+cLoteLan+cSBLote+cDocLanc+cLinha+cTipSaldo)) 
		If lConferir
			aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName := "BR_PRETO"	//Conferido
			RecLock('CT2',.F.)
			Replace CT2_CONFST	With "1"
			Replace CT2_OBSCNF	With cObs
			Replace CT2_USRCNF	With cUserName
			Replace CT2_DTCONF	With MSDate()
			Replace CT2_HRCONF	With Time()
			MsUnLock()			
		EndIf
		If lReverter
			aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName := "BR_AMARELO"	//Revertido
			RecLock('CT2',.F.)
			Replace CT2_CONFST	With " "
			Replace CT2_OBSCNF	With " "
			Replace CT2_USRCNF	With " "
			Replace CT2_DTCONF	With CTOD("")
			Replace CT2_HRCONF	With " "
			MsUnLock()
		EndIf				
	EndIf		
Endif
RestArea(aArea)
Return  

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � Ct660Obs()		 � Autor � Jose Lucas       � Data � 04/11/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Validar a caixa de edi��o do campo Observa��o.          		    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL := Ct660Obs(ExpC)											���
�������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC := cObs - Texto digitado.									���
�������������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL := Retorno logico True ou False.							���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � CTC660 - Quadratura Contabil.                                   	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/  
Static Function Ct660Obs(cObs)   
Local lTrue  := .T.
Local lFalse := .F.
If Empty(cObs)
	Help(" ",1,"CTBC660_OBSMSG",,STR0044,1,0)	 //"Informe o texto para o campo observa��o."
EndIf	
Return If(Empty(cObs),lFalse,lTrue)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � CTC660Dive()	 � Autor � Jose Lucas           � Data � 31/10/11   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Exibir divergencias do documento selecionado.   				    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTC660Dive(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3)						���
�������������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 := oFolderFil - Folder com as filiais ativas).				���    
���          � ExpO2 := aFModulos - Folder com as configura��es modulos).		���
���          � ExpA1 := aBrwMod - Objeto correspondente ao browse do m�dulo sel-���
���          � ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		���
���          � ExpA2 := aBrwCtb - Objeto correspondente ao browse do m�dulo CTB.���
���          � ExpA3 := Array aResultSet.										���
�������������������������������������������������������������������������������Ĵ��
���Retorno   � Nil																���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � CTC660 - Quadratura                                             	���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/                                
Static Function CT660Dive(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet) 
Local nI := 0 
Local nX := 0 
Local nC := 0      
Local nPosLinha    := 0
Local lDivergencia := .F.           
Local lGravaCT2 := .F.
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local nHeight	:= aSizeDlg[3] * 0.50
Local nWidth    := aSizeDlg[4] * 0.60
Local oDlg		:= Nil
Local oListBox
Local aListBox  := {}            
Local aEntidades:= Ctbc66RetEnt()
Local cModulo   := ""
Local bUpdate	:= {|| If(lGravaCT2,(Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,.F.,lReverter),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }
  
nI := oFolderFil:nOption				//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption			//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0)      
	cModulo := aFModulos[nI]:aPrompts[nX]//alterado pois precisa pegar o modulo
	if (cModulo != "34") // inserido o !=34 pois no modulo de contabilidade n�o existe compara��o
		nPosLinha := aBrwMod[nI][nX]:nAt	//Posi��o da linha do lan�amento posicionado.
		If nPosLinha > 0      
			If "BR_AMARELO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lDivergencia := .T.
				//Divergencias
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][4] <> aBrwCtb[nI][nX]:aArray[nPosLinha][2]	//Data do Lan�amento
					AADD(aListBox,{STR0048,Transform(aBrwMod[nI][nX]:aArray[nPosLinha][4],"@D"),Transform(aBrwCtb[nI][nX]:aArray[nPosLinha][2],"@D")})	//"Data do documento"
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][7] <> aBrwCtb[nI][nX]:aArray[nPosLinha][19]	//Valor do Documento
					AADD(aListBox,{STR0049,Transform(aBrwMod[nI][nX]:aArray[nPosLinha][7],"@E 999,999,999.99"),Transform(aBrwCtb[nI][nX]:aArray[nPosLinha][19],"@E 999,999,999.99")})
				EndIf
				                               
				//If aBrwMod[nI][nX]:aArray[nPosLinha][8] <> aBrwCtb[nI][nX]:aArray[nPosLinha][10]	//Numero do Diario
					//AADD(aListBox,{STR0050,aBrwMod[nI][nX]:aArray[nPosLinha][8],aBrwCtb[nI][nX]:aArray[nPosLinha][10]})
				//EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][9] <> aBrwCtb[nI][nX]:aArray[nPosLinha][11]	//Conta Contabil Debito
					AADD(aListBox,{STR0051,aBrwMod[nI][nX]:aArray[nPosLinha][9],aBrwCtb[nI][nX]:aArray[nPosLinha][11]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][10] <> aBrwCtb[nI][nX]:aArray[nPosLinha][12]	//Conta Contabil Credito
					AADD(aListBox,{STR0067,aBrwMod[nI][nX]:aArray[nPosLinha][10],aBrwCtb[nI][nX]:aArray[nPosLinha][12]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][11] <> aBrwCtb[nI][nX]:aArray[nPosLinha][13]	//Centro custo Debito
					AADD(aListBox,{STR0061,aBrwMod[nI][nX]:aArray[nPosLinha][11],aBrwCtb[nI][nX]:aArray[nPosLinha][13]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][12] <> aBrwCtb[nI][nX]:aArray[nPosLinha][14]	//Centro custo credito
					AADD(aListBox,{STR0062,aBrwMod[nI][nX]:aArray[nPosLinha][12],aBrwCtb[nI][nX]:aArray[nPosLinha][14]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][13] <> aBrwCtb[nI][nX]:aArray[nPosLinha][15]	//Item debito
					AADD(aListBox,{STR0063,aBrwMod[nI][nX]:aArray[nPosLinha][13],aBrwCtb[nI][nX]:aArray[nPosLinha][15]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][14] <> aBrwCtb[nI][nX]:aArray[nPosLinha][16]	//item credito
					AADD(aListBox,{STR0064,aBrwMod[nI][nX]:aArray[nPosLinha][14],aBrwCtb[nI][nX]:aArray[nPosLinha][16]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][15] <> aBrwCtb[nI][nX]:aArray[nPosLinha][17]	//cl valor debito
					AADD(aListBox,{STR0065,aBrwMod[nI][nX]:aArray[nPosLinha][15],aBrwCtb[nI][nX]:aArray[nPosLinha][17]})
				EndIf
				
				If aBrwMod[nI][nX]:aArray[nPosLinha][16] <> aBrwCtb[nI][nX]:aArray[nPosLinha][18]	//Cl valor credito
					AADD(aListBox,{STR0066,aBrwMod[nI][nX]:aArray[nPosLinha][16],aBrwCtb[nI][nX]:aArray[nPosLinha][18]})
				EndIf
				
				
			EndIf			
			If lDivergencia                                                                    
			
				DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE "Divergencias" PIXEL STYLE DS_MODALFRAME of oMainWnd  //###Conferencia do Documento
			
				nHeight	:= aSizeDlg[3] * 0.40
				nWidth  := aSizeDlg[4] * 0.50
		
				@ 010, 010 LISTBOX oListBox Fields HEADER "Referencia",cModulo,"34-Contabilidade Gerencial"; //"Referencia"###"Modulo"###"Contabilidade"
							SIZE 355, 110 PIXEL
				oListBox:SetArray( aListBox )
				oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ]} }
				oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	
				oDlg:Activate(,,,.T.,,,bEnchBar)
	        EndIf
	    EndIf
    EndIf      
EndIf
Return

Static Function Filtrar()
Local nI         := 0
Local nX         := 0
Local nY         := 0
Local nZ         := 0  
Local oFont01    := TFont():New("Arial",,020,,.F.,,,,,.F.,.F.)
Local oFont02    := TFont():New("Arial",,019,,.T.,,,,,.F.,.F.)
Local oDlgFil    := Nil
Local oPanelFil  := Nil 
Local lFiltra    := .F.
Local aDadosMod  := {}
Local aDadosCtb  := {}
Local cLineMod   := ""
Local cLineCtb   := ""
Local aEmpty     := {}
Local oCheckBo1  := Nil
Local oCheckBo2  := Nil
Local oCheckBo3  := Nil
Local oCheckBo4  := Nil
Local cColor     := ""

Set Key VK_F4 To

oDlgFil := FWDialogModal():New()	
oDlgFil:SetBackground(.F.)    
oDlgFil:SetTitle("Filtrar")	
oDlgFil:SetEscClose(.T.)                       
oDlgFil:SetSize(110,150) //085		
oDlgFil:EnableFormBar(.T.)
oDlgFil:CreateDialog()        	
oPanelFil := oDlgFil:GetPanelMain()
oDlgFil:CreateFormBar()       

@ 002, 002 MSGET oGetFiltra VAR cGetFiltra PICTURE "@!" SIZE 145, 013 OF oPanelFil COLORS 0, 16777215 FONT oFont01 PIXEL

@ 019, 002 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "     Documentos desbalanceados" SIZE 090, 007 OF oPanelFil COLORS 0, 16777215 PIXEL
@ 019, 010 BITMAP oCheckBo1 RESOURCE "BR_VERMELHO" PIXEL OF oPanelFil SIZE 064, 025 NOBORDER PIXEL

@ 031, 002 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT "     Doc. dados divergentes" SIZE 090, 007 OF oPanelFil COLORS 0, 16777215 PIXEL
@ 031, 010 BITMAP oCheckBo2 RESOURCE "BR_AMARELO" PIXEL OF oPanelFil SIZE 064, 025 NOBORDER PIXEL

@ 043, 002 CHECKBOX oCheckBo3 VAR lCheckBo3 PROMPT "     Documentos corretos" SIZE 090, 007 OF oPanelFil COLORS 0, 16777215 PIXEL
@ 043, 010 BITMAP oCheckBo3 RESOURCE "BR_VERDE" PIXEL OF oPanelFil SIZE 064, 025 NOBORDER PIXEL

@ 055, 002 CHECKBOX oCheckBo4 VAR lCheckBo4 PROMPT "     Documentos conferidos" SIZE 090, 007 OF oPanelFil COLORS 0, 16777215 PIXEL
@ 055, 010 BITMAP oCheckBo4 RESOURCE "BR_PRETO" PIXEL OF oPanelFil SIZE 064, 025 NOBORDER PIXEL

oDlgFil:AddButton("Filtrar",{|| (lFiltra := .T., oDlgFil:Deactivate())},"Filtrar",,.T.,.F.,.T.,)			 
oDlgFil:AddButton("Cancelar",{|| oDlgFil:Deactivate()},"Cancelar",,.T.,.F.,.T.,)

oDlgFil:SetInitBlock({|| oGetFiltra:SetFocus()})
oDlgFil:Activate()

If lFiltra 
	nI := oFolderFil:nOption //Elemento correspondente ao folder da filial corrente.
	If nI > 0
		nX := aFModulos[nI]:nOption	//Elemento correspondente ao subfolder do modulo corrente.
	EndIf

	If nI > 0 .And. nX > 0
		For nY := 1 To Len(aResultSet[nI][2][nX][2]) //Len(aBrwMod[nI][nX]:aArray)
			If AllTrim(cGetFiltra) $ AllTrim(aResultSet[nI][2][nX][2][nY][5]) .Or. Empty(cGetFiltra)
				cColor := AllTrim(ClassDataArr(aResultSet[nI][2][nX][2][nY][1],.F.)[1][2])
				
				If (lCheckBo1 .And. cColor ==  "BR_VERMELHO") .Or.; //Documentos desbalanceados
				   (lCheckBo2 .And. cColor ==  "BR_AMARELO")  .Or.; //Doc. dados divergentes
				   (lCheckBo3 .And. cColor ==  "BR_VERDE")    .Or.; //Documentos corretos
				   (lCheckBo4 .And. cColor ==  "BR_PRETO")          //Documentos conferidos
				   
				   Aadd(aDadosMod, aResultSet[nI][2][nX][2][nY]) 					 
				   Aadd(aDadosCtb, aResultSet[nI][2][nX][3][nY]) 					 					
				
				EndIf
			EndIf	
		Next nY	
					
		//Filtra lado do M�dulo
		If Len(aDadosMod) = 0			
			Aadd(aEmpty, {"Vazio",Nil,Nil})						
			Ctbc66FillBlank(@aEmpty)
			aDadosMod := aClone(aEmpty[1][2])				
			aDadosCtb := aClone(aEmpty[1][3])
		EndIf
		If .T.
			aBrwMod[nI,nX]:SetArray(aDadosMod)						
			For nZ := 1 to Len(aCabMod)	
				If aTipoMod[nZ] == "N"
					cLineMod += "Transform(aDadosMod[aBrwMod[" + cValToChar(nI) + "," + cValToChar(nX) + "]:nAT," + cValToChar(nZ) + "],'" + PesqPict('CT2','CT2_VALOR') + "'),"
				Else 
					cLineMod += "aDadosMod[aBrwMod[" + cValToChar(nI) + "," + cValToChar(nX) + "]:nAT,"+cValToChar(nZ)+"],"	
				Endif					
			Next nZ		                                        		
			cLineMod := Substr(cLineMod,1,len(cLineMod)-1)					
			aBrwMod[nI,nX]:bLine := &("{|| {" + cLineMod + "}}")
			
			//Filtra lado Cont�bil
			aBrwCtb[nI,nX]:SetArray(aDadosCtb)					
			For nZ := 1 to len(aCabCtb)	
				If aTipoCtb[nZ] == "N"
					cLineCtb += "Transform(aDadosCtb[aBrwCtb[" + cValToChar(nI) + "," + cValToChar(nX) + "]:nAT," + cValToChar(nZ) + "],'" + PesqPict('CT2','CT2_VALOR') + "'),"
					Else
					cLineCtb += "aDadosCtb[aBrwCtb[" + cValToChar(nI) + "," + cValToChar(nX) + "]:nAT,"+cValToChar(nZ)+"],"	
				Endif					
			Next nZ                                       			
			cLineCtb := Substr(cLineCtb,1,len(cLineCtb)-1)					
			aBrwCtb[nI,nX]:bLine := &("{|| {" + cLineCtb + "}}")		
		EndIf
		aBrwMod[nI,nX]:Refresh()
		aBrwMod[nI,nX]:GoTop()		
			
		aBrwCtb[nI,nX]:Refresh()
		aBrwCtb[nI,nX]:GoTop()
			
		//Imprime descri��o da Conta
		ChangeCT1()				
	EndIf
EndIf

Set Key VK_F4 To Filtrar()				  
Return Nil


//Static Function Localizar(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)
/*
Static Function Localizar()
Local nI        := 0
Local nX        := 0
Local oFont01   := TFont():New("Arial",,020,,.F.,,,,,.F.,.F.)
Local oFont02   := TFont():New("Arial",,019,,.T.,,,,,.F.,.F.)
Local oDlgLoc   := Nil
Local oPanelLoc := Nil 
Local lAchou    := .F.
Local lLocaliza := .F.

oDlgLoc := FWDialogModal():New()	
oDlgLoc:SetBackground(.F.)           //.T. -> Escurece o fundo da janela
oDlgLoc:SetTitle("Localizar")	
oDlgLoc:SetEscClose(.T.)             //Permite fechar a tela com o ESC                 
oDlgLoc:SetSize(085,150)		
oDlgLoc:EnableFormBar(.T.)
oDlgLoc:CreateDialog()               //Cria a janela (cria os paineis)	
oPanelLoc := oDlgLoc:GetPanelMain()
oDlgLoc:CreateFormBar()              //Cria barra de bot�es

@ 002, 002 MSGET oGetLocali VAR cGetLocali PICTURE "@!" SIZE 145, 013 OF oPanelLoc COLORS 0, 16777215 FONT oFont01 PIXEL
@ 019, 002 RADIO oRadLocali VAR nRadLocali ITEMS "Desde o Inicio","A partir do registro posicionado" SIZE 145, 018 OF oPanelLoc COLOR 0, 16777215 PIXEL

oDlgLoc:AddButton("Localizar",{|| (lLocaliza := .T., oDlgLoc:Deactivate())},"Localizar",,.T.,.F.,.T.,)			 
oDlgLoc:AddButton("Cancelar",{|| oDlgLoc:Deactivate()},"Cancelar",,.T.,.F.,.T.,)

oDlgLoc:SetInitBlock({|| oGetLocali:SetFocus()})
oDlgLoc:Activate()

If lLocaliza .And. !Empty(cGetLocali)
	nI := oFolderFil:nOption //Elemento correspondente ao folder da filial corrente.
	If nI > 0
		nX := aFModulos[nI]:nOption	//Elemento correspondente ao subfolder do modulo corrente.
	EndIf

	If nI > 0 .And. nX > 0
		If nRadLocali = 2
			nInicio := aBrwMod[nI][nX]:nAt+1	//Posi��o da linha do lan�amento posicionado
		Else
			nInicio := 1
		EndIf
	
		For nY := nInicio To Len(aBrwMod[nI][nX]:aArray)
			If AllTrim(cGetLocali) $ AllTrim(Upper(aBrwMod[nI][nX]:aArray[nY][5]))
				aBrwMod[nI][nX]:GoPosition(nY)
				aBrwMod[nI][nX]:Refresh()
				lAchou := .T.
				Exit
			EndIf	
		Next nY
			
		//aBrwCtb[nI][nX]:SetFilter(cCpoFil, &cTopFun, &cBotFun)
		//aBrwCtb[nI][nX]:Refresh()
	EndIf
EndIf				    

Return Nil
*/

Static Function ChangeCT1()
Local aAreaCT1  := CT1->(GetArea())
Local nPosLinha := 0
Local nX        := 0
Local nI        := oFolderFil:nOption
Local cModulo   := ""

cContaDMod := ""
cContaCMod := ""
cContaDCtb := ""
cContaCCtb := ""

If nI > 0
	nX := aFModulos[nI]:nOption
EndIf

If nI > 0 .And. nX > 0
	cModulo := aFModulos[nI]:aPrompts[nX]
	If (cModulo != "34") // inserido o !=34 pois no modulo de contabilidade n�o existe compara��o
		nPosLinha := aBrwMod[nI][nX]:nAt
	
		If nPosLinha > 0
			//Lado M�dulo
			If !Empty(aBrwMod[nI][nX]:aArray[nPosLinha][9])
				cContaDMod := Posicione("CT1",1,xFilial("CT1")+aBrwMod[nI][nX]:aArray[nPosLinha][9],"CT1_DESC01")
			EndIf
			
			If !Empty(aBrwMod[nI][nX]:aArray[nPosLinha][10])
				cContaCMod := Posicione("CT1",1,xFilial("CT1")+aBrwMod[nI][nX]:aArray[nPosLinha][10],"CT1_DESC01")
			EndIf
		
			//Lado Cont�bil
			If !Empty(aBrwCtb[nI][nX]:aArray[nPosLinha][11])
				cContaDCtb := Posicione("CT1",1,xFilial("CT1")+aBrwCtb[nI][nX]:aArray[nPosLinha][11],"CT1_DESC01")
			EndIf
			
			If !Empty(aBrwCtb[nI][nX]:aArray[nPosLinha][12])
				cContaCCtb := Posicione("CT1",1,xFilial("CT1")+aBrwCtb[nI][nX]:aArray[nPosLinha][12],"CT1_DESC01")
			EndIf								
		EndIf				
	EndIf					
EndIf
		
oSayDebMod:Refresh()
oSayCreMod:Refresh()
oSayDebCtb:Refresh()
oSayCreCtb:Refresh()

RestArea(aAreaCT1)
Return Nil

Static Function Rastrear()
Local aAreaCT2    	:= CT2->(GetArea()) 
Local nPosLinha   	:= 0
Local nX          	:= 0
Local nI          	:= oFolderFil:nOption
Local cFunAnt	  	:= ''

//#TB20200128 Thiago Berna - AJuste para posicionar na filial correta
Local cFilBkp		:= cFilAnt 

Private cCadastro := "Rastrear Lan�amentos Cont�beis"
Private aRotina := {}   

AAdd(aRotina, {"OK",  "Alert('OK')", 0 , 2, 0, Nil})

If nI > 0
	nX := aFModulos[nI]:nOption
EndIf

If nI > 0 .And. nX > 0
	nPosLinha := aBrwCtb[nI][nX]:nAt 
	
	If nPosLinha > 0		
		If Len(aBrwCtb[nI][nX]:aArray[nPosLinha]) > 20 .And.;
			ValType(aBrwCtb[nI][nX]:aArray[nPosLinha][21]) == "N" .And.;
			aBrwCtb[nI][nX]:aArray[nPosLinha][21] > 0
			 
			CT2->(dbGoTo(aBrwCtb[nI][nX]:aArray[nPosLinha][21]))
			
			//#TB20190529 Thiago Berna - Ajuste para corrigir problema de rastreabilidade
			DbSelectArea('CT2') 

			//#TB20200128 Thiago Berna - AJuste para posicionar na filial correta
			cFilAnt := CT2->CT2_FILIAL
			
			CtbC010Rot("CT2",CT2->(Recno()),2,Nil)
			
			//#TB20200128 Thiago Berna - AJuste para posicionar na filial correta
			cFilAnt	:= cFilBkp			

		EndIf
	EndIf
EndIf

RestArea(aAreaCT2)
Return Nil

/*
Static Function CTBC010ROT( cAlias, nReg, nOpc, nRecDes)
Local lRet		:= .T.
Local cSequenc	:= CT2->CT2_SEQUEN
Local dDtCV3	:= CT2->CT2_DTCV3
Local lDel		:= Set(_SET_DELETED) 
Local nRecno  := 0
Local aArea   := CT2->(GetArea())
Local aAreaCT2:= {} 
Local cTabOri := cAlias
Local nRecOri := nReg
DEFAULT nRecDes := 0

lRet := Ctc010Val(cSequenc,dDtCV3)
RestArea(aArea)
If lRet	
	// Se for um lan�amento aglutinado, exibe todos os lan�amentos aglutinados para que o 
	// usu�rio escolha qual quer rastrear.
	If Ct2->CT2_AGLUT == "1"
		CtbAglut(cSequenc,dDtCV3,cTabOri,nRecOri)
	ElseIf CT2->CT2_AGLUT == "2"				// Lancamento nao Aglutinado
		CtbRastrear()			
	ElseIf CT2->CT2_AGLUT == "3"				// Lancamento importado
		Help(" ",1,"CTB010IMP")
	EndIf
EndIf
RestArea(aArea)
Set(_SET_DELETED, lDel)
RestInter()
Return nil
*/

User Function F3TabCTL()
Local lRet       := .F.
Local lExceto    := AllTrim(ReadVar()) == "CEXCEALIAS"
Local oDlgCTL    := Nil
Local oPanelCTL  := Nil
Local oTempTable := Nil
Local aFields    := {}
Local aFields2   := {}
Local bOk		 := {||((lRet := .T., oMrkBrowse:Deactivate(), oPanelCTL:End()))}
Local cFilSel    := "!Empty(TMP->OK)"
Local lMarcar     	:= .F.

//Inicia Vari�vel
cRetF3Mark := Space(150)

Aadd(aFields, {"OK",    "C", 02, 0})
Aadd(aFields, {"ALIAS", "C", 03, 0})
Aadd(aFields, {"NOME",  "C", 40, 0})

Aadd(aFields2, {"Alias", "ALIAS", "C", 03, 0, "@!"})
Aadd(aFields2, {"Nome",  "NOME",  "C", 40, 0, "@!"})

//Cria o objeto da Tabela Temporaria
oTempTable := FWTemporaryTable():New("TMP")

//Input dos campos na Tabela Tempor�ria
oTemptable:SetFields(aFields)

//Criacao da Tabela no Banco de Dados
oTempTable:Create()

//Criacao da Query que ir� alimentar a Tabela Tempor�ria
cQuery := "SELECT DISTINCT CTL_ALIAS
cQuery += " FROM " + RetSqlName("CTL") 
cQuery += " WHERE CTL_FILIAL = '" + xFilial("CTL") + "'
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY CTL_ALIAS
     
//Cria uma Tabela Termpor�ria para Query
MPSysOpenQuery(cQuery, "QRY")
 
While !QRY->(Eof())
	RecLock("TMP", .T.)
    TMP->OK    := Iif(lExceto,Iif(QRY->CTL_ALIAS $ AllTrim(cExceAlias), "XX","  "),Iif(QRY->CTL_ALIAS $ AllTrim(cOnlyAlias), "XX","  "))    
    TMP->ALIAS := QRY->CTL_ALIAS 
    TMP->NOME  := Posicione("SX2",1,QRY->CTL_ALIAS,"X2_NOME")
    MsUnLock("TMP")
    
    QRY->(dbSkip())    
EndDo
QRY->(dbCloseArea())

oDlgCTL := FWDialogModal():New()	
oDlgCTL:SetBackground(.F.)          
oDlgCTL:SetTitle(Iif(lExceto, "Exceto Tabelas","Somente Tabelas"))	
oDlgCTL:SetEscClose(.T.)                             
oDlgCTL:SetSize(250,350)		
oDlgCTL:EnableFormBar(.T.)
oDlgCTL:CreateDialog()              	
oPanelCTL := oDlgCTL:GetPanelMain()
oDlgCTL:CreateFormBar()

oDlgCTL:AddButton("Confirmar",{|| (lRet := .T.,oDlgCTL:DeActivate())},"Confirmar",,.T.,.F.,.T.,)			 
oDlgCTL:AddButton("Cancelar",{|| oDlgCTL:DeActivate()},"Cancelar",,.T.,.F.,.T.,)

oMrkBrowse := FWMarkBrowse():New()	
oMrkBrowse:SetOwner(oPanelCTL)		
oMrkBrowse:SetFieldMark("OK")			
oMrkBrowse:SetAlias("TMP")
oMrkBrowse:SetTemporary(.T.)
oMrkBrowse:SetMenuDef("")
//oMrkBrowse:AddButton("Confirmar",bOk,,2)
oMrkBrowse:SetIgnoreARotina(.T.)
oMrkBrowse:SetMark("XX","TMP","OK")
//oMrkBrowse:bAllMark := {|| .F.}
oMrkBrowse:bAllMark := { || SetMarkAll(oMrkBrowse:Mark(),lMarcar := !lMarcar ), oMrkBrowse:Refresh(.T.)  }
oMrkBrowse:DisableReport()
oMrkBrowse:SetFields(aFields2)
oMrkBrowse:DisableFilter()
oMrkBrowse:DisableLocate()
oMrkBrowse:DisableSeek()
oMrkBrowse:DisableReport()
oMrkBrowse:Activate()             	
oDlgCTL:Activate()

If lRet
	dbSelectArea("TMP")
	TMP->(DbSetfilter({|| &cFilSel}, cFilSel))
	TMP->(dbGoTop())
	If !TMP->(Eof())
		While !TMP->(Eof())			
			cRetF3Mark += Iif(!Empty(cRetF3Mark), ";", "") + TMP->ALIAS
			TMP->(dbSkip())		
		EndDo 						
	EndIf
	cRetF3Mark := PadR(AllTrim(cRetF3Mark),150," ")	
	
	If lExceto
		cExceAlias := cRetF3Mark
		oExceAlias:Refresh()
	Else
		cOnlyAlias := cRetF3Mark
		oOnlyAlias:Refresh()
	EndIf
EndIf

//Exclui a Tabela Termpor�ria do Bando de Dados
oTempTable:Delete()

Return lRet

User Function RetF3Mark()
Return cRetF3Mark

Static Function ChangeCTB()
Local nPosLinha := 0
Local nX        := 0
Local nZ        := 0
Local nY        := 0
Local nI        := oFolderFil:nOption
Local cModulo   := ""
Local nUnique   := {}
Local aCtb      := {}
Local cLineCtb  := ""

If nI > 0
	nX := aFModulos[nI]:nOption
EndIf

If nI > 0 .And. nX > 0
	cModulo := aFModulos[nI]:aPrompts[nX]
	If (cModulo != "34") // inserido o !=34 pois no modulo de contabilidade n�o existe compara��o
		nPosLinha := aBrwMod[nI][nX]:nAt
	
		If nPosLinha > 0
			//Lado M�dulo
			nUnique := aBrwMod[nI][nX]:aArray[nPosLinha][18]
			
			For nY := 1 To Len(aResultSet[nI][2][nX][3])
				If aResultSet[nI][2][nX][3][nY][22] = nUnique
					Aadd(aCtb, aResultSet[nI][2][nX][3][nY]) 					 
					aBrwCtb[nI,nX]:SetArray(aCtb)
					
					For nZ := 1 to len(aCabCtb)	
						If aTipoCtb[nZ] == "N"
							cLineCtb += "Transform(aCtb[1," + cValToChar(nZ) + "],'" + PesqPict('CT2','CT2_VALOR') + "'),"
						Else 
							cLineCtb += "aCtb[1,"+cValToChar(nZ)+"],"	
						Endif							
					Next nZ                                        
			
					cLineCtb := Substr(cLineCtb,1,len(cLineCtb)-1)					
					aBrwCtb[nI,nX]:bLine := &("{|| {" + cLineCtb + "}}")
					
					aBrwCtb[nI,nX]:Refresh()
					Exit
				EndIf						
			Next nX
			
			
											
		EndIf				
	EndIf					
EndIf
		
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLibThread�Autor  �Thiago Berna        � Data �  09/06/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se tem alguma thread que a conexao caiu por qq     ���
���          �motivo mas que ainda esteja bloqueada para uso. Se encontrar���
���          �faz a liberacao da thread.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fLibThread(nTpLib,cNomThread,cVarIDThread)

Local nI			:= 0
Local aInfo		:= {}
Local aConexoes	:= {}
Local cFuncao		:= "U_FillInfMod"
Local nPos1		:= 0
Local nPos2		:= 0
Local cIDThreads	:= ""

Default nTpLib 		:= 1  // 1=Libera Thread / 2=Encerra conexao de uma ou mais threads / 3=Encerra a conexao da thread devido a SysErrorBlock 
Default cNomThread	:= "" // Nome da variavel de controle da thread 

//�������������������������������������������������������������������������������������������������Ŀ
//� Dados da thread - Monitor                                                                       �
//�-------------------------------------------------------------------------------------------------� 
//�aInfo[x][01] = (C) Nome de usu�rio                                                               �
//�aInfo[x][02] = (C) Nome da m�quina local                                                         �
//�aInfo[x][03] = (N) ID da Thread                                                                  �
//�aInfo[x][04] = (C) Servidor (caso esteja usando Balance; caso contr�rio � vazio)                 �
//�aInfo[x][05] = (C) Nome da fun��o que est� sendo executada                                       �
//�aInfo[x][06] = (C) Ambiente(Environment) que est� sendo executado                                �
//�aInfo[x][07] = (C) Data e hora da conex�o                                                        �
//�aInfo[x][08] = (C) Tempo em que a thread est� ativa (formato hh:mm:ss)                           �
//�aInfo[x][09] = (N) N�mero de instru��es                                                          �
//�aInfo[x][10] = (N) N�mero de instru��es por segundo                                              �
//�aInfo[x][11] = (C) Observa��es                                                                   �
//�aInfo[x][12] = (N) (*) Mem�ria consumida pelo processo atual, em bytes                           �
//�aInfo[x][13] = (C) (**) SID - ID do processo em uso no TOPConnect/TOTVSDBAccess, caso utilizado. �
//���������������������������������������������������������������������������������������������������
aInfo := GetUserInfoArray()     


//������������������������������������������������������������������������������������������������Ŀ
//� Alimenta a variavel global cErroJob para identificar que ocorreu algum erro na execu��o do Job �
//��������������������������������������������������������������������������������������������������
GlbUnLock()
GlbLock( "cErrojob"+cVarIDThread )
ClearGlbValue("cErrojob"+cVarIDThread)
PutGlbValue( "cErrojob"+cVarIDThread , "T" )
GlbUnLock()

//�������������������������������������������������������Ŀ
//� Monta array com as threads do multithread ainda ativas�
//���������������������������������������������������������
For nI := 1 to Len(aInfo)

	//�����������������������������������������������������������������Ŀ
	//� Verifica se e a funcao U_FillInfMod que esta em execucao na thread �
	//�������������������������������������������������������������������
	If  cFuncao $ AllTrim(Upper(aInfo[nI][5])) 
	
		Aadd( aConexoes , {	aInfo[nI][1],; //1 - (C) Nome de usu�rio
								aInfo[nI][2],; //2 - (C) Nome da m�quina local
								aInfo[nI][3],; //3 - (N) ID da Thread
								aInfo[nI][4],; //4 - (C) Servidor (caso esteja usando Balance; caso contr�rio � vazio)
								aInfo[nI][5],; //5 - (C) Nome da fun��o que est� sendo executada
								aInfo[nI][6],; //6 - (C) Ambiente(Environment) que est� sendo executado
								aInfo[nI][9]}) //7 - (N) N�mero de instru��es
		
	
		If Empty(cIDThreads)
			cIDThreads := StrZero(aInfo[nI][3],20) 
		Else
			cIDThreads += "|" + StrZero(aInfo[nI][3],20)
		EndIf	
	
	EndIf
	
Next nI

//����������������������������������������������������������������������������������Ŀ
//� Se nao tiver conexao multitrhead ativa libera verifica se libera ou fecha conexao�
//������������������������������������������������������������������������������������
If !Empty(cIDThreads) .And. nTpLib <> 3 

	//����������������������������������������������������������������������������������Ŀ
	//� Se tipo de liberacao = 1 --> Libera threads                                      �
	//������������������������������������������������������������������������������������
	If nTpLib = 1

		//����������������������������������������������������������������������������������Ŀ
		//� Verifica se tem thread bloqueada cuja conexao tenha caido e libera para uso      �
		//������������������������������������������������������������������������������������
		For nI := 1 to Len(aThreads)	
			If SubStr(GetGlbValue(aThreads[nI]),1,1) == "E"
				If !Empty(AllTrim(SubStr(GetGlbValue(aThreads[nI]),3,20))) .And. !SubStr(GetGlbValue(aThreads[nI]),3,20) $ cIDThreads 
					//�������������������������������������������������������Ŀ
					//� Libera a thread para calcular um novo registro        �
					//���������������������������������������������������������
					Conout( "[fLibThread] - Thread liberada devido a erro de execucao (nTpLib = 1). " )	
					GlbUnLock()
					GlbLock( aThreads[nI] )
					ClearGlbValue(aThreads[nI])
					PutGlbValue( aThreads[nI] , "L" )  
					GlbUnLock()					       
					
				EndIf
			EndIf
		Next nI

	//����������������������������������������������������������������������������������Ŀ
	//� Se tipo de liberacao = 2 --> Finaliza e libera as threads                        �
	//������������������������������������������������������������������������������������	
	ElseIf nTpLib = 2

		//����������������������������������������������������������������������������������Ŀ
		//� Verifica se tem thread bloqueada cuja conexao tenha caido e mata conexao         �
		//������������������������������������������������������������������������������������
		cIDThreads := ""
		For nI := 1 to Len(aThreads)	
			If SubStr(GetGlbValue(aThreads[nI]),1,1) == "E" .And. !Empty(AllTrim(SubStr(GetGlbValue(aThreads[nI]),3,20)))

				//������������������������������������������������������������������������������Ŀ
				//� Espera 2 seg e monta o array com as informacoes das threads ativas novamente �
				//��������������������������������������������������������������������������������
				Sleep(03000) //3 segundos
				aInfo := {}
				aInfo := GetUserInfoArray()
				
				nPos1 := aScan( aInfo 		, { |x| x[3] == Val( AllTrim(SubStr(GetGlbValue(aThreads[nI]),3,20)) ) }) 
				nPos2 := aScan( aConexoes	, { |x| x[3] == Val( AllTrim(SubStr(GetGlbValue(aThreads[nI]),3,20)) ) })
				
				//�������������������������������������������������������������������������������������������Ŀ
				//� Compara posicao do array, ID da Thread, qtd de instrucoes da thread e funcao em execucao  �
				//���������������������������������������������������������������������������������������������
				If nPos1 > 0 .And. nPos2 > 0 .And. aInfo[nPos1][3] = aConexoes[nPos2][3]; 
				.And. aInfo[nPos1][9] = aConexoes[nPos2][7] .And. AllTrim(Upper(aInfo[nPos1][5])) == cFuncao   
					
					//�������������������������������������������������������Ŀ
					//� Encerra a conexao da thread                           �
					//���������������������������������������������������������
					cIDThreads += StrZero(aInfo[nPos1][3],20) + "|" //Threads que serao liberadas nas variaveis globais			
					Conout( "[fLibThread] - Thread finalizada devido a erro de execucao (nTpLib = 2): " + StrZero(aInfo[nPos1][3],20) )
					KillUser( aInfo[nPos1][1] , aInfo[nPos1][2] , aInfo[nPos1][3] , aInfo[nPos1][4] ) //( UserName, ComputerName, ThreadId, ServerName )	
				
				EndIf

			EndIf
		Next nI

		//������������������������������������������������������������������������������Ŀ
		//� Se finalizou alguma conexao procura a thread correta para liberar para uso   �
		//��������������������������������������������������������������������������������
		If !Empty(cIDThreads)
	
			//����������������������������������������������������������������������������������Ŀ
			//� Verifica se tem thread bloqueada cuja conexao tenha caido e libera para uso      �
			//������������������������������������������������������������������������������������
			For nI := 1 to Len(aThreads)	
				If SubStr(GetGlbValue(aThreads[nI]),1,1) == "E" .And. SubStr(GetGlbValue(aThreads[nI]),3,20) $ cIDThreads
					//�������������������������������������������������������Ŀ
					//� Libera a thread para calcular um novo registro        �
					//���������������������������������������������������������
					GlbUnLock()
					GlbLock( aThreads[nI] )
					ClearGlbValue(aThreads[nI])
					PutGlbValue( aThreads[nI] , "L" )  			
					GlbUnLock()                        			
					
					Conout( "[fLibThread] - Thread liberada devido a erro de execucao." )
				EndIf
			Next nI
		
		EndIf
	EndIf
//����������������������������������������������������������������������������������Ŀ
//� Se nao tiver conexao ativa libera todas as threads                               �
//������������������������������������������������������������������������������������
ElseIf Empty(cIDThreads) .And. nTpLib <> 3

	//����������������������������������������������������������������������������������Ŀ
	//� Verifica se tem thread bloqueada cuja conexao tenha caido e libera para uso      �
	//������������������������������������������������������������������������������������
	For nI := 1 to Len(aThreads)
	
		//�������������������������������������������������������Ŀ
		//� Libera a thread para calcular um novo registro        �
		//���������������������������������������������������������
		GlbUnLock()
		GlbLock( aThreads[nI] )
		ClearGlbValue(aThreads[nI])
		PutGlbValue( aThreads[nI] , "L" )  
		GlbUnLock()                        		
		
		Conout( "[fLibThread] - Thread liberada devido a conexao inexistente.(Empty(cIDThreads) .And. nTpLib <> 3)" )						
		
	Next nI

//����������������������������������������������������������������������������������Ŀ
//� Encerra conexao e libera a thread devido a SysErrorBlock                         �
//������������������������������������������������������������������������������������
ElseIf nTpLib = 3 .And. !Empty(cNomThread) .And. SubStr(GetGlbValue(cNomThread),1,1) == "E" .And. SubStr(GetGlbValue(cNomThread),3,20) $ cIDThreads

	nPos1 := aScan( aInfo , { |x| x[3] == Val( AllTrim(SubStr(GetGlbValue(cNomThread),3,20)) ) })
	
	If nPos1 > 0 

		//�������������������������������������������������������Ŀ
		//� Encerra a conexao da thread                           �
		//���������������������������������������������������������
		//Conout( "[fLibThread] - Thread finalizada devido a erro de execucao(SysErrorBlock): " + StrZero(aInfo[nPos1][3],20) )
		KillUser( aInfo[nPos1][1] , aInfo[nPos1][2] , aInfo[nPos1][3] , aInfo[nPos1][4] ) //( UserName, ComputerName, ThreadId, ServerName )

		//�������������������������������������������������������Ŀ
		//� Libera a thread para calcular um novo registro        �
		//���������������������������������������������������������
		GlbUnLock()
		GlbLock( cNomThread )
		ClearGlbValue(cNomThread)
		PutGlbValue( cNomThread , "L" )  
		GlbUnLock()                      
		
		Conout( "[fLibThread] - Thread liberada devido a erro de execucao (SysErrorBlock)-(nTpLib = 3)." )	
	
	EndIf 

EndIf

Return


/*/{Protheus.doc} SetMarkAll
Fun��o que controla a marcacao de todos os itens no browse
@author Thiago Berna TSM
@since 20/05/2019
@version 1.0
@type function
@example SetMarkAll()
/*/
Static Function SetMarkAll(cMarca,lMarcar )
	
	Local aAreaMark  := TMP->( GetArea() )
	
	dbSelectArea('TMP')
	TMP->( dbGoTop() )
	
	While !TMP->( Eof() )
		RecLock( 'TMP', .F. )
		TMP->OK := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()
		TMP->( dbSkip() )
	EndDo
	
	RestArea( aAreaMark )
	
Return .T.

