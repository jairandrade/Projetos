#INCLUDE "rwmake.ch"
#include "topconn.ch"


/*/{Protheus.doc} GARQSERX
@description Funcao para Gerar Aquivo de envio para o serasa Conciliacao
@author	Kaique Sousa
@since	    15/06/13
@since	   ALteracoes Andre Vicente 02/03/2015

/*/

User Function GARQSERX()

Private _cPerg     := PadR('GARQSERAX',10,Space(1))
Private _oGeraTxt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Filial De                             ³
//³ mv_par02               Filial Ate                            ³
//³ mv_par03               Vencimento De                         ³
//³ mv_par04               Vencimento Ate                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaSx1(_cPerg)
Pergunte(_cPerg,.F.)
	
	@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Geracao de Arquivo Exportacao SERASA")
	@ 02,10 TO 060,215
	@ 10,018 Say " Este programa ira gerar um arquivo texto com informações de clientes para o " SIZE 196,0
	@ 18,018 Say " SERASA e serão utilizados para informações comerciais.                      " SIZE 196,0
	
	@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
	@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| GARQSER1AX(), Close(_oGeraTxt) })
	@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)
	
	Activate Dialog _oGeraTxt Centered

Return()


Static Function GARQSER1AX()

Local _cQuery1	:= ""
Local _cQuery2	:= ""
Local _cPath	:= "C:\Serasa\Enviado\"
Local _cFile	:= _cPath + "CONCILIA_"+DTOS(dDatabase)
Local _cTipoMov := ""
Local _cCli		:= ""
Local _cCliAnt  := ""
Local _cCliAtu  := ""
Local _nTotCli  := 0
Local _nTotTit  := 0
Local _cEOL 	:= CHR(13)+CHR(10)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _nHdl    := fCreate(_cFile + ".TXT")


If _nHdl == -1
	MsgAlert(cUserName+Chr(13)+"O arquivo "+_cFile+".TXT"+" não pode ser executado! Verifique os parametros.","Atencao!")
	Return()
Endif

ProcRegua( 0 )

// A primeira parte gravará o cabecalho do arquivo
_cLin := '00RELATO COMP NEGOCIOS07768381000100' + "CONCILIA" + dtos(MV_PAR04 ) + "M" + space(15) + "   " + space(29) +"V.01"+space(26)+ _cEOL

							 		
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na gravacao do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
		Return()
	EndIf
Endif

If Select("QRYSA1") > 0
	QRYSA1->(DbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Buscando Titulos Normal   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery1:=" SELECT A1.A1_COD,A1.A1_LOJA,A1.A1_CGC,A1.A1_PRICOM, A1.A1_DTCADAS,E1.E1_FILIAL,E1.E1_PREFIXO,E1.E1_NUM,E1.E1_PARCELA,E1.E1_TIPO,E1.E1_EMISSAO,"+_cEOL
_cQuery1+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR, E1.E1_ENVSER, E1.D_E_L_E_T_[DEL] FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
//_cQuery1+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR, E1.E1_ENVSER FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
_cQuery1+=" WHERE A1.A1_CGC !='' "+_cEOL
_cQuery1+=" AND A1.A1_PESSOA='J' "+_cEOL
_cQuery1+=" AND A1.A1_ESERASA='S' "+_cEOL
_cQuery1+=" AND A1.A1_COD=E1_CLIENTE  "+_cEOL
_cQuery1+=" AND A1.A1_LOJA=E1.E1_LOJA "+_cEOL
_cQuery1+=" AND A1.D_E_L_E_T_=''  "+_cEOL
_cQuery1+=" AND E1.D_E_L_E_T_ ='' "+_cEOL
_cQuery1+=" AND E1.E1_FILIAL BETWEEN  '"+MV_PAR01+"' AND  '"+MV_PAR02+"'"+_cEOL
_cQuery1+=" AND E1.E1_VENCREA BETWEEN  '"+ DTOS(MV_PAR03) +"'AND  '"+ DTOS(MV_PAR04) +"'"+_cEOL
//_cQuery1+=" AND E1_TIPO ='DP'"+_cEOL
_cQuery1+=" AND NOT E1_BAIXA=E1_EMISSAO "+_cEOL
_cQuery1+=" AND NOT E1.E1_EMISSAO BETWEEN  '"+ DTOS(MV_PAR03) +"'AND  '"+ DTOS(MV_PAR04) +"'"+_cEOL                                                               

_cQuery1+="UNION ALL"+_cEOL

_cQuery1+=" SELECT A1.A1_COD,A1.A1_LOJA,A1.A1_CGC,A1.A1_PRICOM, A1.A1_DTCADAS, E1.E1_FILIAL,E1.E1_PREFIXO,E1.E1_NUM,E1.E1_PARCELA,E1.E1_TIPO,E1.E1_EMISSAO, "+_cEOL
_cQuery1+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR,E1.E1_ENVSER,E1.D_E_L_E_T_[DEL] FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
//_cQuery1+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR,E1.E1_ENVSER FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
_cQuery1+=" WHERE A1.A1_CGC !='' "+_cEOL
_cQuery1+=" AND A1.A1_PESSOA='J'"+_cEOL
_cQuery1+=" AND A1.A1_ESERASA='S' "+_cEOL
_cQuery1+=" AND A1.A1_COD=E1_CLIENTE"+_cEOL
_cQuery1+=" AND A1.A1_LOJA=E1.E1_LOJA "+_cEOL
_cQuery1+=" AND A1.D_E_L_E_T_=''"+_cEOL
_cQuery1+=" AND E1.D_E_L_E_T_ ='' "+_cEOL
_cQuery1+=" AND E1.E1_FILIAL BETWEEN  '"+MV_PAR01+"' AND  '"+MV_PAR02+"' "+_cEOL
_cQuery1+=" AND E1.E1_EMISSAO  BETWEEN  '"+ DTOS(MV_PAR03) +"'AND  '"+ DTOS(MV_PAR04) +"'"+_cEOL
//_cQuery1+=" AND E1_TIPO ='DP'"+_cEOL
_cQuery1+=" AND NOT E1_BAIXA=E1_EMISSAO"+_cEOL
_cQuery1+=" ORDER BY A1_CGC"+_cEOL
TcQuery  _cQuery1 Alias "QRYSA1"    

MemoWrite("C:\TEMP\SERASACONC.SQL",_cQuery1)


//Gravando Titulos Normais
dbSelectArea("QRYSA1")
QRYSA1->(DbGoTop())
While !QRYSA1->(Eof())
	
	_cDtaAux  := if(!Empty( QRYSA1->E1_BAIXA ), QRYSA1->E1_BAIXA, space(8))
	_cVlrAux  := StrTran(StrZero(QRYSA1->E1_VALOR,14,2),".","")
	
	_cLin  := '01' + QRYSA1->A1_CGC + '05'+ padr(Alltrim(QRYSA1->E1_NUM)+QRYSA1->E1_PARCELA,10) + QRYSA1->E1_EMISSAO + _cVlrAux
	_cLin  += QRYSA1->E1_VENCREA + _cDtaAux
	_cLin  += space(35) + _cEOL
	
	
	If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
		If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na gravação do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
			Return()
		Endif
	Endif
	_nTotTit ++

	//Marcando Flag de Envio P/Serasa
	DbSelectArea("SE1")
	DbSetORder(1)  
	If DbSeek(QRYSA1->E1_FILIAL+QRYSA1->E1_PREFIXO+QRYSA1->E1_NUM+QRYSA1->E1_PARCELA+QRYSA1->E1_TIPO)
		RecLock("SE1",.F.)
		E1_ENVSER		:= "S"
		MsUnlock()
	EndIf	

	IncProc(OemToAnsi("Titulos Normais " + QRYSA1->E1_FILIAL + '-' + Alltrim(QRYSA1->E1_NUM) + '-' + Alltrim(QRYSA1->E1_PARCELA) ))
	QRYSA1->(DbSkip())
	
Enddo  


//Finalizando Arquivo - Gravando Trailler
_cLin  := '99'+ strzero( _nTotCli , 11 ) + space(44) + strzero( _nTotTit, 11 )  + space(32) + _cEOL
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na gravação do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
		Return()
	Endif
Endif

fClose(_nHdl)
MsgInfo(cUserName+Chr(13)+"Arquivo Gerado com Sucesso.")

Return()   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaSx1  ºAutor ³ Diego Donatti       º Data ³  07/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria o SX1 - Arquivo de Perguntas..                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriaSx1(_cPerg)

Local aRegs    := {}
Local _i 	   := 0
Local _j 	   := 0


aAdd(aRegs,{_cPerg,'01' ,'Filial  de ?         	','                   ?','                   ?','mv_ch1','C', 06,00,00,'G','','mv_par01',"","","","","","","","","","","","","","","","","","","","","","","","",'SM0'})
aAdd(aRegs,{_cPerg,'02' ,'Filial  Ate ?        	','                   ?','                   ?','mv_ch2','C', 06,00,00,'G','','mv_par02',"","","","","","","","","","","","","","","","","","","","","","","","",'SM0'})
aAdd(aRegs,{_cPerg,'03' ,'Vencimento de ? 		','                   ?','                   ?','mv_ch3','D', 08,00,00,'G','','mv_par03',"","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{_cPerg,'04' ,'Vencimento Ate ?  		','                   ?','                   ?','mv_ch4','D', 08,00,00,'G','','mv_par04',"","","","","","","","","","","","","","","","","","","","","","","","",''})
//aAdd(aRegs,{_cPerg,'05' ,'Mes Anterior?			','                   ?','                   ?','mv_ch5','D', 08,00,00,'G','','mv_par05',"","","","","","","","","","","","","","","","","","","","","","","","",''})


DbSelectArea("SX1")
dbSetOrder(1)
For _i := 1 to Len(aRegs)
	If !dbSeek(_cPerg + aRegs[_i][2])
		RecLock("SX1", .T.)
		For _j := 1 to FCount()
			If _j <= Len(aRegs[_i])
				FieldPut(_j, aRegs[_i][_j])
			EndIf
		Next
		msUnlock()
	EndIf
Next

Return