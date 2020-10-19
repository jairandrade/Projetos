#INCLUDE "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGARQSERAV บAutor  ณ Kaique Sousaบ Data ณ  15/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para Gerar Aquivo de envio para o serasa.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Financeiro                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GARQSERAV()

Private _cPerg     := PadR('GARQSERA',10,Space(1))
Private _oGeraTxt

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01               Filial De                             ณ
//ณ mv_par02               Filial Ate                            ณ
//ณ mv_par03               Vencimento De                         ณ
//ณ mv_par04               Vencimento Ate                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaSx1(_cPerg)
Pergunte(_cPerg,.F.)

//If ("15375991000164"== AllTrim(SM0->M0_CGC))
	
	@ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Geracao de Arquivo Exportacao SERASA")
	@ 02,10 TO 060,215
	@ 10,018 Say " Este programa ira gerar um arquivo texto com informa็๕es de clientes para o " SIZE 196,0
	@ 18,018 Say " SERASA e serใo utilizados para informa็๕es comerciais.                      " SIZE 196,0
	
	@ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
	@ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| GARQSER1AL(), Close(_oGeraTxt) })
	@ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)
	
	Activate Dialog _oGeraTxt Centered
	
//Else
	//MsgInfo(cUserName+Chr(13)+"Esta Rotina so pode ser excultada na empresa. Todimo Varzea Grande! ")
//EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGARQSERAV -Autor  ณMicrosiga           บ Data ณ  06/15/13   บฑฑ

*/

Static Function GARQSER1AL()

Local _cQuery1	:= ""
Local _cQuery2	:= ""
Local _cPath	:= "C:\Serasa\Enviado\"
Local _cFile	:= _cPath + "Relato_"+DTOS(dDatabase)
Local _cTipoMov := ""
Local _cCli		:= ""
Local _cCliAnt  := ""
Local _cCliAtu  := ""
Local _nTotCli  := 0
Local _nTotTit  := 0
Local _cEOL 	:= CHR(13)+CHR(10)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o arquivo texto                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private _nHdl    := fCreate(_cFile + ".TXT")


If _nHdl == -1
	MsgAlert(cUserName+Chr(13)+"O arquivo "+_cFile+".TXT"+" nใo pode ser executado! Verifique os parametros.","Atencao!")
	Return()
Endif

ProcRegua( 0 )

// A primeira parte gravarแ o cabecalho do arquivo
_cLin := '00RELATO COMP NEGOCIOS07768381000100' + dtos( MV_PAR03 ) + dtos(MV_PAR04 ) + "S" + space(15) + Space(03) + space(29) + "V.01" + space(26) + _cEOL

							 		
If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na gravacao do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
		Return()
	EndIf
Endif

If Select("QRYSA1") > 0
	QRYSA1->(DbCloseArea())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBuscando Titulos Normal   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
_cQuery1:=" SELECT A1.A1_COD,A1.A1_LOJA,A1.A1_CGC,A1.A1_PRICOM, A1.A1_DTCADAS,E1.E1_FILIAL,E1.E1_PREFIXO,E1.E1_NUM,E1.E1_PARCELA,E1.E1_TIPO,E1.E1_EMISSAO,"+_cEOL
_cQuery1+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR, E1.E1_ENVSER, E1.D_E_L_E_T_[DEL] FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
//_cQuery1+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR, E1.E1_ENVSER FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
_cQuery1+=" WHERE A1.A1_CGC !='' "+_cEOL
_cQuery1+=" AND A1.A1_FILIAL=SUBSTRING(E1.E1_FILIAL,1,2) "+_cEOL
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
_cQuery1+=" AND A1.A1_FILIAL=SUBSTRING(E1.E1_FILIAL,1,2) "+_cEOL
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

MemoWrite("C:\TEMP\SERASA.SQL",_cQuery1)

//Gravando Tempo de Relacionamento
dbSelectArea("QRYSA1")
QRYSA1->(DbGoTop())
While !QRYSA1->(Eof())
	
	_cCliAtu:= Alltrim(QRYSA1->A1_CGC)
	
	If !(_cCliAtu == _cCliAnt)
		
		//Cliente Desde
		If  (dDataBase  < SToD(QRYSA1->A1_DTCADAS))
			_dCadCli:= dDataBase
		ElseIf Empty(QRYSA1->A1_DTCADAS)
			_dCadCli := dDataBase
		Else
			_dCadCli := QRYSA1->A1_DTCADAS
		EndIf
		
		//Tratamento Para Primeira Compra
		If Empty(QRYSA1->A1_PRICOM)
			_dPriCom:=QRYSA1->A1_DTCADAS
		ElseIf (dDataBase  < SToD(QRYSA1->A1_PRICOM))
			_dPriCom:=QRYSA1->A1_DTCADAS
		Else
			_dPriCom:=QRYSA1->A1_PRICOM
		EndIF
		
		//Tipo de Cliente: 1 = Antigo; 2 = Menos de um ano; 3 = Inativo
		IF  (dDataBase  - SToD(_dPriCom))  >= 365
			_cTipoCli := '1'
		Elseif (dDataBase  - SToD(_dPriCom))  <= 364
			_cTipoCli := '2'
		Endif
		
		_cLin 	 := '01'+ QRYSA1->A1_CGC + '01' + _dCadCli + _cTipoCli + space(103) +  _cEOL
		
		If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
			If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na grava็ใo do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
				Return()
			Endif
		Endif
		
		_nTotCli ++
		_cCliAnt:= Alltrim(QRYSA1->A1_CGC)
	EndIf
	
	IncProc(OemToAnsi("Cliente " + Alltrim(QRYSA1->A1_COD) + '-' + Alltrim(QRYSA1->A1_LOJA) ))
	QRYSA1->(DbSkip())
	
Enddo


//Gravando Titulos Normais
dbSelectArea("QRYSA1")
QRYSA1->(DbGoTop())
While !QRYSA1->(Eof())
	
	_cDtaAux  := if(!Empty( QRYSA1->E1_BAIXA ), QRYSA1->E1_BAIXA, space(8))
	_cVlrAux  := StrTran(StrZero(QRYSA1->E1_VALOR,14,2),".","")
	
	_cLin  := '01' + QRYSA1->A1_CGC + '05'+ padr(Alltrim(QRYSA1->E1_NUM)+QRYSA1->E1_PARCELA,10) + QRYSA1->E1_EMISSAO + _cVlrAux
	_cLin  += QRYSA1->E1_VENCREA + _cDtaAux
	_cLin  += space(65) + _cEOL
	
	
	If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
		If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na grava็ใo do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
			Return()
		Endif
	Endif
	
	_nTotTit ++

	//Marcando Flag de Envio P/Serasa
	DbSelectArea("SE1")
	DbSetORder(1)  
	If DbSeek(QRYSA1->E1_FILIAL+QRYSA1->E1_PREFIXO+QRYSA1->E1_NUM+QRYSA1->E1_PARCELA+QRYSA1->E1_TIPO)
		//RecLock("SE1",.F.)
		//E1_ENVSER		:= "S"
		//MsUnlock()
	EndIf	

	IncProc(OemToAnsi("Titulos Normais " + QRYSA1->E1_FILIAL + '-' + Alltrim(QRYSA1->E1_NUM) + '-' + Alltrim(QRYSA1->E1_PARCELA) ))
	QRYSA1->(DbSkip())
	
Enddo  

If Select("QRYDEL") > 0
	QRYDEL->(DbCloseArea())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBuscando Titulos Excluidosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
_cQuery2:=" SELECT A1.A1_COD,A1.A1_LOJA,A1.A1_CGC,A1.A1_PRICOM, A1.A1_DTCADAS, E1.E1_FILIAL,E1.E1_PREFIXO,E1.E1_NUM,E1.E1_PARCELA,E1.E1_TIPO,E1.E1_EMISSAO, "+_cEOL
_cQuery2+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR,E1.E1_ENVSER,E1.D_E_L_E_T_[DEL] FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
//_cQuery2+=" E1.E1_VENCREA,E1.E1_BAIXA,E1.E1_VALOR,E1.E1_ENVSER FROM "+RetSqlName("SA1")+" A1, "+RetSqlName("SE1")+" E1 "+_cEOL
_cQuery2+=" WHERE  A1.D_E_L_E_T_=''"+_cEOL 
_cQuery2+=" AND A1.A1_FILIAL=SUBSTRING(E1.E1_FILIAL,1,2) "+_cEOL
_cQuery2+=" AND A1.A1_COD=E1_CLIENTE"+_cEOL
_cQuery2+=" AND A1.A1_LOJA=E1.E1_LOJA"+_cEOL 
_cQuery2+=" AND E1.D_E_L_E_T_ ='*'"+_cEOL 
_cQuery2+=" AND E1.E1_FILIAL BETWEEN  '"+MV_PAR01+"' AND  '"+MV_PAR02+"' "+_cEOL
_cQuery2+=" AND E1.E1_EMISSAO BETWEEN  '"+ DTOS(MV_PAR05)+"' AND  '"+ DTOS(MV_PAR04) +"'"+_cEOL
_cQuery2+=" AND E1_ENVSER='S'"+_cEOL
_cQuery2+=" AND A1.A1_ESERASA='S' "+_cEOL
_cQuery2+=" ORDER BY A1_CGC "+_cEOL 
TcQuery  _cQuery2 Alias "QRYDEL" 

MemoWrite("C:\TEMP\SERASA2.SQL",_cQuery2)
//Gravando Titulos Excluidos
dbSelectArea("QRYDEL")
QRYDEL->(DbGoTop())
While !QRYDEL->(Eof()) 
	
	_cLin  := '01' + QRYDEL->A1_CGC + '05'+ padr(Alltrim(QRYDEL->E1_NUM)+QRYDEL->E1_PARCELA,10) + QRYDEL->E1_EMISSAO + "9999999999999"
	_cLin  += QRYDEL->E1_VENCREA + _cDtaAux
	_cLin  += space(35) + _cEOL   
		
	If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
		If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na grava็ใo do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
			Return()
		Endif
	Endif
	
	_nTotTit ++	

	IncProc(OemToAnsi("Titulos Excluidos: " + QRYDEL->E1_FILIAL + '-' + Alltrim(QRYDEL->E1_NUM) + '-' + Alltrim(QRYDEL->E1_PARCELA) ))
	QRYDEL->(DbSkip())	

Enddo  


//Finalizando Arquivo - Gravando Trailler
_cLin  := '99'+ strzero( _nTotCli , 11 ) + space(44) + strzero( _nTotTit, 11 )  + space(62) + _cEOL

If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	If !MsgAlert(cUserName+Chr(13)+"Ocorreu um erro na grava็ใo do arquivo."+Chr(13)+Chr(13)+"Continua ?","Atencao!")
		Return()
	Endif
Endif

fClose(_nHdl)
MsgInfo(cUserName+Chr(13)+"Arquivo Gerado com Sucesso.")

Return()   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaSx1  บAutor ณ Diego Donatti       บ Data ณ  07/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o SX1 - Arquivo de Perguntas..                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaSx1(_cPerg)

Local aRegs    := {}
Local _i 	   := 0
Local _j 	   := 0


aAdd(aRegs,{_cPerg,'01' ,'Filial  de ?         	','                   ?','                   ?','mv_ch1','C', 06,00,00,'G','','mv_par01',"","","","","","","","","","","","","","","","","","","","","","","","",'SM0'})
aAdd(aRegs,{_cPerg,'02' ,'Filial  Ate ?        	','                   ?','                   ?','mv_ch2','C', 06,00,00,'G','','mv_par02',"","","","","","","","","","","","","","","","","","","","","","","","",'SM0'})
aAdd(aRegs,{_cPerg,'03' ,'Vencimento de ? 		','                   ?','                   ?','mv_ch3','D', 08,00,00,'G','','mv_par03',"","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{_cPerg,'04' ,'Vencimento Ate ?  		','                   ?','                   ?','mv_ch4','D', 08,00,00,'G','','mv_par04',"","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{_cPerg,'05' ,'Emissao Mes Anterior?	','                   ?','                   ?','mv_ch5','D', 08,00,00,'G','','mv_par05',"","","","","","","","","","","","","","","","","","","","","","","","",''})


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
