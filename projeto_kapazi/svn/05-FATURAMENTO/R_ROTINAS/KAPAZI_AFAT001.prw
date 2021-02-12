#INCLUDE "FWBROWSE.CH"
#INCLUDE "protheus.CH"
#INCLUDE "Topconn.ch"

User Function AFAT001()
Local _cPerg := "KPZFAT001"

//INCLUIDO EM 24/03/14
AjustaSX1(_cPerg)
Pergunte(_cPerg,.T.)

oBrowse1 := FWMarkBrowse():New() 
oBrowse1:SetAlias('SC5')       
oBrowse1:SetDescription("[AFAT001] - Liberacao de Estoque")                                            
ADD BUTTON oButton TITLE "Liberar" ACTION { || libera() } OF oBrowse1
		
oBrowse1:AddLegend( "C5_XSITLIB=='4'","YELLOW", "Bloq.Estoque" )
oBrowse1:AddLegend( "C5_XSITLIB=='5'", "BLUE" , "Bloq.Cred/Est" )

oBrowse1:SetFilterDefault( "C5_NUM $'"+PEGAPED()+"' .AND. C5_FILIAL =="+XFILIAL('SC5') )
oBrowse1:Activate()

//4=Bloq estoque;
//5=Bloq cred e estoque;


//INCLUIDO EM 07/01/2014
//VERIFICA SE EXISTE TRANSFERENCIA
//NÃO EXECUTAR PARA AS FILIAIS 03, 04, 05 E 06 DA EMPRESA 04
If !cEmpAnt + cFilAnt $ "0403#0404#0405#0406#"
	Processa({||U_v_TRANSF()}) 
EndIf


return 

Static Function PEGAPED()
cSql:=" SELECT TOP 30 C6_NUM FROM (
cSql+=" 	SELECT C6_NUM FROM "+RETSQLNAME('SC6')+" SC6 "
cSql+=" 	INNER JOIN "+RETSQLNAME('SC9')+" SC9 "
cSql+=" 		ON C6_FILIAL=C9_FILIAL "
cSql+=" 		AND C6_NUM=C9_PEDIDO "
cSql+=" 		AND C6_ITEM = C9_ITEM "
cSql+="  WHERE C9_FILIAL='"+xFilial('SC9')+"'"  
cSql+="  AND SC6.D_E_L_E_T_<>'*' "
cSql+="  AND SC9.D_E_L_E_T_<>'*' "
cSql+="  AND C9_BLEST='02'"
cSql+="  AND C9_PEDIDO NOT IN (SELECT C9_PEDIDO FROM  "+RETSQLNAME('SC9')+" WHERE C9_BLCRED<>'' AND C9_FILIAL='"+xFilial('SF3')+"' AND D_E_L_E_T_<>'*') )N "

//INCLUIDO EM 24/03/14
cSql+="  WHERE C6_NUM >= '"+MV_PAR01+"'"  
cSql+="  AND C6_NUM <= '"+MV_PAR02+"'"  

cSql+="  GROUP BY C6_NUM

IF Select('TRPED')<>0
	TRPED->(dbCloseArea())
EndIF

tcQuery cSql new Alias "TRPED"
cRet:=""
While !TRPED->(eof())
		if (Empty(cRet))
			cRet+=TRPED->C6_NUM
		Else
			cRet+="|"+TRPED->C6_NUM           
		EndIF
		TRPED->(dbSkip())
EndDo


Return cRet


Static Function libera
Local oButton
Local oColumn
Local oDlg
Private oBrowse                                               

//-------------------------------------------------------------------
// Abertura da tabela
//------------------------------------------------------------------
criaTemp(.T.)

//Acerta o tamanho da tela
aSize    := MsAdvSize()

DEFINE MSDIALOG  oDlg TITLE "[AFAT001] - Liberacao de Estoque" FROM aSize[7],000 TO aSize[6],aSize[5] PIXEL

//-------------------------------------------------------------------
// Define o Browse
//-------------------------------------------------------------------
DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS "TRXC9" OF oDlg

oBrowse:SetDetails( .f.)



ADD MARKCOLUMN oColumn DATA { || If(!empty(TRXC9->OK),'LBOK','LBNO') } DOUBLECLICK { |oBrowse| ATUOK(oDlg ) } HEADERCLICK { |oBrowse| invertall(oDlg) } OF oBrowse
//--------------------------------------------------------
// Cria uma coluna de status
//-------------------------------------------------------- 
	
//ADD STATUSCOLUMN oColumn DATA { || If(EMPTY(TRXC9->C6_NUM),'BR_VERDE','BR_VERMELHO') } DOUBLECLICK { |oBrowse| /* Função executada no duplo clique na coluna*/ } OF oBrowse

//--------------------------------------------------------
// Adiciona legenda no Browse
//--------------------------------------------------------
//ADD LEGEND DATA 'X2_CHAVE $ "AA1|AA2"'    COLOR "GREEN" TITLE "Chave teste 1" OF oBrowse		ADD LEGEND DATA '!(X2_CHAVE $ "AA1|AA2")' COLOR "RED"   TITLE "Chave teste 2" OF oBrowse
//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
ADD BUTTON oButton TITLE "Liberar" ACTION { || libped(oDlg) } OF oBrowse		

//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
ADD COLUMN oColumn DATA { || TRXC9->C6_NUM  } 			TITLE "Pedido"    		SIZE  15 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->C6_PRODUTO  } 	TITLE "Produto"    		SIZE  15 OF oBrowse
ADD COLUMN oColumn DATA { || posicione("SB1",1,xFilial("SB1")+TRXC9->C6_PRODUTO,"B1_DESC")  } 	TITLE "Desc."    		SIZE  TAMSX3('B1_DESC')[1] OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->C6_QTDVEN	   } 	TITLE "Quantidade"    SIZE  9 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->C6_CLI	   } 		TITLE "Cliente"    SIZE  9 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->C6_LOJA	   } 		TITLE "Loja"    SIZE  9 OF oBrowse
ADD COLUMN oColumn DATA { || posicione("SA1",1,xFilial("SA1")+TRXC9->C6_CLI+TRXC9->C6_LOJA,"A1_NOME")	   } 		TITLE "Nome"    SIZE  TAMSX3('A1_NOME')[1] OF oBrowse


/*ADD COLUMN oColumn DATA { || TRXC9->C6_  } TITLE "Parcela"    SIZE  2 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->E1_VENCTO   } TITLE "Vencimento" SIZE  10 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->E1_CLIENTE  } TITLE "Cliente"    SIZE  6 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->E1_LOJA     } TITLE "Loja"       SIZE  4 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->E1_NOMCLI   } TITLE "Nome"       SIZE  20 OF oBrowse
ADD COLUMN oColumn DATA { || TRXC9->E1_OCORSER  } TITLE "Status Ret" SIZE  20 OF oBrowse                     

                */
oBrowse:SetDoubleClick({ |oBrowse| ATUOK(oDlg ) })

//-------------------------------------------------------------------
// Ativação do Browse
//-------------------------------------------------------------------
ACTIVATE FWFORMBROWSE oBrowse
//-------------------------------------------------------------------
// Ativação do janela
//-------------------------------------------------------------------
ACTIVATE MSDIALOG oDlg CENTERED
oBrowse1:CleanFilter()
oBrowse1:SetFilterDefault( "C5_NUM $'"+PEGAPED()+"' .AND. C5_FILIAL =="+XFILIAL('SC5') )
oBrowse1:Refresh(.T.)

Return



Static Function criaTemp(lNovo,aSE1ret)


Local aStru		:= SC6->(DbStruct())
DEFAULT lNovo:=.T.        
DEFAULT aSE1ret:={}
cQyr := buscaDados(lNovo,aSE1ret)

Aadd(aStru, {"OK","C",2,0})
Aadd(aStru, {"REC","N",10,0})

cArqTrab := CriaTrab(aStru,.T.) // Nome do arquivo temporario
if Select('TRXC9')<>0
  TRXC9->(DBCloseArea())
EndIF
dbUseArea(.T.,__LocalDriver,cArqTrab,'TRXC9',.F.)
If lNovo
	Processa({||SqlToTrb(cQyr, aStru, "TRXC9")}) // Cria arquivo temporario
Else
	SqlToTrb(cQyr, aStru, "TRXC9")
	
Endif

IndRegua ("TRXC9",cArqTrab,"C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO",,,"Selecionando Registros...")

Index On C6_NUM    	TAG COTACAO                   TO &cArqTrab //1
Index On C6_FILIAL 	TAG FILIAL   TO &cArqTrab //2

DbClearIndex()
OrdListAdd(cArqTrab)

DbSetOrder(1) //FICA NA ORDEM DA QUERY

Return

Static Function BuscaDados(lNovo,aSE1ret)
Local cQyr    

cQyr :=" SELECT 'XX'AS OK, SC9.R_E_C_N_O_ AS REC, SC6.* " 
cQyr +=" FROM "+RetSqlName('SC9')+" SC9 "
cQyr +=" INNER JOIN "+RetSqlName('SC6')+" SC6 "
cQyr +=" ON C6_FILIAL=C9_FILIAL "
cQyr +=" AND C6_NUM=C9_PEDIDO "
cQyr +=" AND C6_ITEM = C9_ITEM "
cQyr +=" WHERE C9_FILIAL='"+xFilial('SC9')+"'"  
cQyr +=" AND C9_PEDIDO='"+SC5->C5_NUM+"' "
cQyr +=" AND SC6.D_E_L_E_T_<>'*' "
cQyr +=" AND SC9.D_E_L_E_T_<>'*' "
cQyr +=" AND C9_BLEST='02' "

Return cQyr 

Static Function atuok
RECLOCK('TRXC9',.F.)
if Empty(TRXC9->OK)
	TRXC9->OK:=GETMARk()
Else
 	TRXC9->OK:= ' '
EndIF    

MsUnlock()

Return


Static Function invertall(oDlg)


TRXC9->(DBGOTOP())
WHILE !TRXC9->(EOF())	
	RECLOCK('TRXC9',.F.)
	if Empty(ALLTRIM(TRXC9->OK))
		TRXC9->OK:=GETMARk()
	Else
		TRXC9->OK:= ' '
	EndIF
	MsUnlock()
	
	TRXC9->(DBsKIP())
EndDo
oBrowse:Refresh(.t.)

TRXC9->(DBGOTOP())
	
Return

Static Function LibPed(oDlg)
Local aSaldos    := {}
Local lTransf := .F.

TRXC9->(DBGOTOP())
WHILE !TRXC9->(EOF())	
	if !Empty(ALLTRIM(TRXC9->OK))
		//Atualiza SZ1 - transferencias
		lTransf := U_AFAT002()
		If lTransf
			DBSelEctArea('SC9')                                                                       	
			DBGoto(TRXC9->REC)
			a450Grava(1,.F.,.T.,Nil,aSaldos)
		EndIf

	EndIF
	
	TRXC9->(DBsKIP())
EndDo        
If lTransf
	reclock('SC5',.F.)
	SC5->C5_XSITLIB:="6" 
	MSUNLOCK()
        
	Aviso("LIBERADO","O estoque para o pedido "+SC5->C5_NUM+CHR(13)+CHR(10)+;
				 "Foi liberado com sucesso",{"OK"},2,"Liberado",,'lgrl01..bmp',.t.,,1) 
EndIf
oDlg:END()
Return


//INCLUIDO EM 24/03/14
//CRIA PERGUNTA (SX1)
Static Function AjustaSx1(_cperg)
PutSx1(_cPerg,"01","Do Pedido     ?"      ,"Do Pedido     ?"      ,"Do Pedido     ?"       ,"mv_ch1","C",06,0,0,"G",""          ,"",""   ,"","mv_par01","","","",""                              ,"","","","","","","","","","","","",,,,"")
PutSx1(_cPerg,"02","Ate o Pedido  ?"      ,"Ate o Pedido  ?"      ,"Ate o Pedido  ?"       ,"mv_ch2","C",06,0,0,"G",""          ,"",""   ,"","mv_par02","","","","ZZZZZZ"                        ,"","","","","","","","","","","","",,,,"")
Return()