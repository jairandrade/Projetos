#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

#DEFINE   CR   Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREFI060J  บAutor  ณ Kaique Sousa      บ Data ณ  06/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPROCESSA A TRANSF DE CARTEIRA E ANOTACOES NO TITULO.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ _cAto    ณ  I!   INCLUSAO MARCOU PARA NEGATIVAR                       บฑฑ
ฑฑบ          ณ  I-	INCLUSAO GEROU ARQUIVO (ENVIOU)                      บฑฑ
ฑฑบ          ณ  IY	INCLUSAO RETORNO CONFIRMADO (YES)                    บฑฑ
ฑฑบ          ณ  IN	INCLUSAO RETORNO REJEITADO  (NO)                     บฑฑ
ฑฑบ          ณ  IC   INCLUSAO CANCELAMENTO MANUAL (NO)                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  E!   EXCLUSAO MARCOU PARA POSITIVAR                       บฑฑ
ฑฑบ          ณ  E-	EXCLUSAO GEROU ARQUIVO (ENVIOU)                      บฑฑ
ฑฑบ          ณ  EY	EXCLUSAO RETORNO CONFIRMADO (YES)                    บฑฑ
ฑฑบ          ณ  EN	EXCLUSAO RETORNO REJEITADO  (NO)                     บฑฑ
ฑฑบ          ณ  EC   EXCLUSAO CANCELAMENTO MANUAL (NO)                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function REFI060J(_nRecno,_cAto,_aLogW,cNomArq,aOco,dOco,_cMotivo)

Local _aArea		:= GetArea()
Local _cOlPefin	:= ''
Local _nEndTRB		:= 0
Local _lEncTRB		:= .t.

Default _aLogW		:= {}
Default cNomArq	:= ''
Default aOco		:= {}
Default dOco		:= CtoD('')
Default _cMotivo	:= ""

//Posiciona o registro caso nao esteja.
If SE1->(Recno()) <> _nRecno
	SE1->(DbGoTo(_nRecno))
EndIf

//Posiciona o registro caso nao esteja.
If (_cArqTrb)->E1_RECNO <> _nRecno
	
	_nEndTRB := aScan(_aEndTRB, {|x| x[1] = _nRecno})
	
	If _nEndTRB > 0
		(_cArqTrb)->(DbGoTo(_aEndTRB[_nEndTRB, 2]))
	EndIf
	
	If ((_cArqTrb)->(Eof())) .or. ((_cArqTrb)->E1_RECNO <> _nRecno)
		_lEncTRB := .f.
	EndIf
	
EndIf
//I! - negativar
Do Case
	Case Right(_cAto,1) = '!'
		//*************************************************************************
		//********************  Somente Marcou o Registro   ***********************
		//*************************************************************************
		
		//Define Inclusao ou Exclusao
		If Left(_cAto,1) = 'I'
			_aVals := {'',CtoD(''),'','','','N',''}
		Else
			_aVals := {'2',CtoD(''),'','','','I',''}
		EndIf
		
		_cOlPefin := SE1->E1_STPEFIN + SE1->E1_ACPEFIN
		
		//Atualiza o Titulo
		If RecLock('SE1',.F.)
			//Campos de Controle da Rotina
			SE1->E1_STPEFIN 			:= _aVals[1]
			//SE1->E1_DTPEFIN 			:= _aVals[2]
			//SE1->E1_USPEFIN 			:= _aVals[3]
			//SE1->E1_OBPEFIN 			+= _aVals[4]
			//SE1->E1_UEPEFIN 			:= _aVals[5]
			SE1->E1_OLPEFIN				:= _cOlPefin
			//SE1->E1_MOPEFIN  		:= '' // -->> Alterado por Carlos Miranda em 31/01/2013
			SE1->E1_MOPEFIN  			:= _cMotivo
			//Campos do Cliente
			SE1->E1_ACPEFIN  			:= _aVals[6]
			//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
			SE1->E1_OCPEFIN 			:= ''
			SE1->E1_ODPEFIN 			:= CtoD('')
			SE1->E1_URPEFIN 			:= ''
			SE1->(MsUnlock())
		EndIf

		//Atualiza o Browse		
		If _lEncTRB
			If RecLock(_cArqTrb,.F.)
				(_cArqTrb)->E1_STPEFIN 		:= _aVals[1]
				//(_cArqTrb)->E1_DTPEFIN 	:= _aVals[2]
				//(_cArqTrb)->E1_USPEFIN 	:= _aVals[3]
				//(_cArqTrb)->E1_OBPEFIN 	+= _aVals[4]
				//(_cArqTrb)->E1_UEPEFIN 	:= _aVals[5]
				(_cArqTrb)->E1_OLPEFIN		:= _cOlPefin
				//(_cArqTrb)->E1_MOPEFIN  	:= '' // -->> Alterado por Carlos Miranda em 31/01/2013
				(_cArqTrb)->E1_MOPEFIN  	:= _cMotivo
				//Campos do Cliente
				(_cArqTrb)->E1_ACPEFIN  	:= _aVals[6]
				//(_cArqTrb)->E1_ANPEFIN 	:= _aVals[7]
				//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
				(_cArqTrb)->E1_OCPEFIN 	:= ''
				(_cArqTrb)->E1_ODPEFIN 	:= CtoD('')
				(_cArqTrb)->E1_URPEFIN 	:= ''
				(_cArqTrb)->E1_COR 		:= Val(U_S550JMCOR(5,'SE1',1))
				(_cArqTrb)->(MsUnlock())
			EndIf
		EndIf
		
	Case Right(_cAto,1) = '-'
		//*************************************************************************
		//********************  Somente Envio de Arquivo    ***********************
		//*************************************************************************
		
		//Define Inclusao ou Exclusao
		If Left(_cAto,1) = 'I'
			_aVals := {'1',dDataBase,Substr(cUserName,1,15),'|D1|' + DtoS(dDataBase) + '|U1|' + Substr(cUserName,1,15),cNomArq,'A','AGUARD RET NEGATIV'}
		Else
			_aVals := {'3',dDataBase,Substr(cUserName,1,15),'|D3|' + DtoS(dDataBase) + '|U3|' + Substr(cUserName,1,15),cNomArq,'A','AGUARD RET POSITIV'}
		EndIf
		
		//Atualiza o Titulo
		If RecLock('SE1',.F.)
			//Campos de Controle da Rotina
			SE1->E1_STPEFIN 			:= _aVals[1]
			SE1->E1_DTPEFIN 			:= _aVals[2]
			SE1->E1_USPEFIN 			:= _aVals[3]
			SE1->E1_OBPEFIN 			+= _aVals[4]
			SE1->E1_UEPEFIN 			:= _aVals[5]
			//Campos do Cliente
			SE1->E1_ACPEFIN  			:= _aVals[6]
			SE1->E1_ANPEFIN 			:= _aVals[7]
			//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
			SE1->E1_OCPEFIN 			:= ''
			SE1->E1_ODPEFIN 			:= CtoD('')
			SE1->E1_URPEFIN 			:= ''
			SE1->(MsUnlock())
		EndIf

		//Atualiza o Browse		
		If _lEncTRB		
			If RecLock(_cArqTrb,.F.)
				(_cArqTrb)->E1_STPEFIN 	:= _aVals[1]
				(_cArqTrb)->E1_DTPEFIN 	:= _aVals[2]
				(_cArqTrb)->E1_USPEFIN 	:= _aVals[3]
				(_cArqTrb)->E1_OBPEFIN 	+= _aVals[4]
				(_cArqTrb)->E1_UEPEFIN 	:= _aVals[5]
				//Campos do Cliente
				(_cArqTrb)->E1_ACPEFIN  	:= _aVals[6]
				(_cArqTrb)->E1_ANPEFIN 	:= _aVals[7]
				//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
				(_cArqTrb)->E1_OCPEFIN 	:= ''
				(_cArqTrb)->E1_ODPEFIN 	:= CtoD('')
				(_cArqTrb)->E1_URPEFIN 	:= ''
				(_cArqTrb)->E1_COR 		:= Val(U_S550JMCOR(5,'SE1',1))
				(_cArqTrb)->(MsUnlock())
			EndIf
		EndIf
		
	Case Right(_cAto,1) = 'N'
		//*************************************************************************
		//*****************  Retorno de Arquivo com Rejeicao   ********************
		//*************************************************************************
		
		//Define Inclusao ou Exclusao
		If Left(_cAto,1) = 'I'
			_aVals := {Left(SE1->E1_OLPEFIN,1),dDataBase,Substr(cUserName,1,15),'|DX|' + DtoS(dDataBase) + '|UX|' + Substr(cUserName,1,15),cNomArq,Right(SE1->E1_OLPEFIN,1),'NEGATIV REJEITADA',S060OCO(aOco),dOco}
		Else
			_aVals := {Left(SE1->E1_OLPEFIN,1),dDataBase,Substr(cUserName,1,15),'|DX|' + DtoS(dDataBase) + '|UX|' + Substr(cUserName,1,15),cNomArq,Right(SE1->E1_OLPEFIN,1),'POSITIV REJEITADA',S060OCO(aOco),dOco}
		EndIf
		
		//Atualiza o Titulo
		If RecLock('SE1',.F.)
			//Campos de Controle da Rotina
			SE1->E1_STPEFIN 			:= _aVals[1]
			SE1->E1_DTPEFIN 			:= _aVals[2]
			SE1->E1_USPEFIN 			:= _aVals[3]
			SE1->E1_OBPEFIN 			+= _aVals[4]
			//SE1->E1_UEPEFIN 		:= _aVals[5]
			//Campos do Cliente
			SE1->E1_ACPEFIN  			:= _aVals[6]
			SE1->E1_ANPEFIN 			:= _aVals[7]
			//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
			SE1->E1_OCPEFIN 			:= _aVals[8]
			SE1->E1_ODPEFIN 			:= _aVals[9]
			SE1->E1_URPEFIN 			:= _aVals[5]
			SE1->(MsUnlock())
		EndIf
		
		//Atualiza o Browse		
		If _lEncTRB		
			If RecLock(_cArqTrb,.F.)
				(_cArqTrb)->E1_STPEFIN 	:= _aVals[1]
				(_cArqTrb)->E1_DTPEFIN 	:= _aVals[2]
				(_cArqTrb)->E1_USPEFIN 	:= _aVals[3]
				(_cArqTrb)->E1_OBPEFIN 	+= _aVals[4]
				//(_cArqTrb)->E1_UEPEFIN := _aVals[5]
				//Campos do Cliente
				(_cArqTrb)->E1_ACPEFIN  	:= _aVals[6]
				(_cArqTrb)->E1_ANPEFIN 	:= _aVals[7]
				//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
				(_cArqTrb)->E1_OCPEFIN 	:= _aVals[8]
				(_cArqTrb)->E1_ODPEFIN 	:= _aVals[9]
				(_cArqTrb)->E1_URPEFIN 	:= _aVals[5]
				(_cArqTrb)->E1_COR 		:= Val(U_S550JMCOR(5,'SE1',1))
				(_cArqTrb)->(MsUnlock())
			EndIf
		EndIf
		
	Case Right(_cAto,1) = 'C'
		//*************************************************************************
		//*****************  Retorno de Arquivo com Rejeicao   ********************
		//*************************************************************************
		
		//Define Inclusao ou Exclusao
		If Left(_cAto,1) = 'I'
			_aVals := {Left(SE1->E1_OLPEFIN,1),dDataBase,Substr(cUserName,1,15),'|DC|' + DtoS(dDataBase) + '|UC|' + Substr(cUserName,1,15),cNomArq,Right(SE1->E1_OLPEFIN,1),'CANCELADO MANUAL',S060OCO(aOco),dOco}
		Else
			_aVals := {Left(SE1->E1_OLPEFIN,1),dDataBase,Substr(cUserName,1,15),'|DC|' + DtoS(dDataBase) + '|UC|' + Substr(cUserName,1,15),cNomArq,Right(SE1->E1_OLPEFIN,1),'CANCELADO MANUAL',S060OCO(aOco),dOco}
		EndIf
		
		//Atualiza o Titulo
		If RecLock('SE1',.F.)
			//Campos de Controle da Rotina
			SE1->E1_STPEFIN 			:= _aVals[1]
			SE1->E1_DTPEFIN 			:= _aVals[2]
			SE1->E1_USPEFIN 			:= _aVals[3]
			SE1->E1_OBPEFIN 			+= _aVals[4]
			//SE1->E1_UEPEFIN 		:= _aVals[5]
			//Campos do Cliente
			SE1->E1_ACPEFIN  			:= _aVals[6]
			SE1->E1_ANPEFIN 			:= _aVals[7]
			//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
			SE1->E1_OCPEFIN 			:= _aVals[8]
			SE1->E1_ODPEFIN 			:= _aVals[9]
			SE1->E1_URPEFIN 			:= _aVals[5]
			SE1->(MsUnlock())
		EndIf
		
		//Atualiza o Browse
		If _lEncTRB		
			If RecLock(_cArqTrb,.F.)
				(_cArqTrb)->E1_STPEFIN 	:= _aVals[1]
				(_cArqTrb)->E1_DTPEFIN 	:= _aVals[2]
				(_cArqTrb)->E1_USPEFIN 	:= _aVals[3]
				(_cArqTrb)->E1_OBPEFIN 	+= _aVals[4]
				//(_cArqTrb)->E1_UEPEFIN := _aVals[5]
				//Campos do Cliente
				(_cArqTrb)->E1_ACPEFIN  	:= _aVals[6]
				(_cArqTrb)->E1_ANPEFIN 	:= _aVals[7]
				//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
				(_cArqTrb)->E1_OCPEFIN 	:= _aVals[8]
				(_cArqTrb)->E1_ODPEFIN 	:= _aVals[9]
				(_cArqTrb)->E1_URPEFIN 	:= _aVals[5]
				(_cArqTrb)->E1_COR 		:= Val(U_S550JMCOR(5,'SE1',1))
				(_cArqTrb)->(MsUnlock())
			EndIf
		EndIf
		
	Case Right(_cAto,1) = 'Y'
		//*************************************************************************
		//***************  Retorno de Arquivo com Confirmacao   *******************
		//*************************************************************************
		
		//Define Inclusao ou Exclusao
		If Left(_cAto,1) = 'I'
			_aVals := {'2',dDataBase,Substr(cUserName,1,15),'|D2|' + DtoS(dDataBase) + '|U2|' + Substr(cUserName,1,15),cNomArq,'O','CLIENTE JA NEGATIVADO',S060OCO(aOco),dOco}
		Else
			_aVals := {'4',dDataBase,Substr(cUserName,1,15),'|D4|' + DtoS(dDataBase) + '|U4|' + Substr(cUserName,1,15),cNomArq,'I','CLIENTE JA POSITIVADO',S060OCO(aOco),dOco}
		EndIf
		
		//Atualiza o Titulo
		If RecLock('SE1',.F.)
			//Campos de Controle da Rotina
			SE1->E1_STPEFIN 			:= _aVals[1]
			SE1->E1_DTPEFIN 			:= _aVals[2]
			SE1->E1_USPEFIN 			:= _aVals[3]
			SE1->E1_OBPEFIN 			+= _aVals[4]
			//SE1->E1_UEPEFIN 		:= _aVals[5]
			//Campos do Cliente
			SE1->E1_ACPEFIN  			:= _aVals[6]
			SE1->E1_ANPEFIN 			:= _aVals[7]
			//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
			SE1->E1_OCPEFIN 			:= _aVals[8]
			SE1->E1_ODPEFIN 			:= _aVals[9]
			SE1->E1_URPEFIN 			:= _aVals[5]
			SE1->(MsUnlock())
		EndIf
		
		//Atualiza o Browse		
		If _lEncTRB		
			If RecLock(_cArqTrb,.F.)
				(_cArqTrb)->E1_STPEFIN 	:= _aVals[1]
				(_cArqTrb)->E1_DTPEFIN 	:= _aVals[2]
				(_cArqTrb)->E1_USPEFIN 	:= _aVals[3]
				(_cArqTrb)->E1_OBPEFIN 	+= _aVals[4]
				//(_cArqTrb)->E1_UEPEFIN := _aVals[5]
				//Campos do Cliente
				(_cArqTrb)->E1_ACPEFIN 	:= _aVals[6]
				(_cArqTrb)->E1_ANPEFIN 	:= _aVals[7]
				//Limpa os Campos de Controle do Retorno (Pois foi gerada um novo arquivo de envio)
				(_cArqTrb)->E1_OCPEFIN 	:= _aVals[8]
				(_cArqTrb)->E1_ODPEFIN 	:= _aVals[9]
				(_cArqTrb)->E1_URPEFIN 	:= _aVals[5]
				(_cArqTrb)->E1_COR 		:= Val(U_S550JMCOR(5,'SE1',1))
				(_cArqTrb)->(MsUnlock())
			EndIf
		EndIf
		
		//Transfere de Portador / e Atualiza Cliente
		S060JPORTA(_cAto,@_aLogW)
		
	OtherWise
		
		RestArea(_aArea)
		Return( Nil )
		
EndCase

Return( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณS060JPORTAบAutor  ณ Kaique Sousa      บ Data ณ  07/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMUDA O PORTADOR - ATUALIZA O CLIENTE -                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function S060JPORTA(_cAto,_aLogW)

Local _cSituant		:= ''
Local _cPorAnt			:= ''
Local _cAgeAnt			:= ''
Local _cConAnt			:= ''
Local _cNewSit			:= ''
Local _cNewPor			:= ''
Local _cNewAge			:= ''
Local _cNewCon			:= ''
Local _lMudaPor		:= GetNewPar('MV_MUDAPOR',.F.)
Local _cTime			:= ''
Local _cOcorrencia  	:= ''        // Inserido por Carlos Miranda em 30/11/2012
Local _lInsere			:= .T.
Local _cChvSEA			:= ''


//Protecao
If Right(_cAto,1) <> 'Y'
	Return( Nil )
EndIf

If _cAto = 'IY'
	
	_cNewSit 	:= GetNewPar('MV_CARTPFI','5')
	
	If _lMudaPor
		_cNewPor		:= 'C' + Left(AllTrim(SE1->E1_FILIAL),2)
		_cNewAge    := StrZero(0,5)
		_cNewCon    := StrZero(0,10)
	EndIf
	
ElseIf _cAto = 'EY'
	_cNewSit 	:= GetNewPar('MV_CARTPFE','0')
	
	If _lMudaPor
		_cNewPor		:= Space(3)
		_cNewAge    := Space(5)
		_cNewCon    := Space(10)
	EndIf
	
EndIf

//Guarda Situacao e Portador Anteriores.
_cSituant 	:= SE1->E1_SITUACA
_cPorAnt		:= SE1->E1_PORTADO
_cAgeAnt		:= SE1->E1_AGEDEP
_cConAnt		:= SE1->E1_NUMCON

If RecLock('SE1',.F.)
	
	//Transferir o Titulo para Carteira 5 (Pendencia Financeira)
	If (_cSituant <> _cNewSit) .Or. ;
		(_cPorAnt  <> _cNewPor) .Or. (_cAgeAnt  <> _cNewAge) .Or. (_cConAnt  <> _cNewCon)
		
		//Muda a Carteira
		Replace SE1->E1_SITUACA With _cNewSit
		
		//Muda o Portador
		If _lMudaPor
			Replace SE1->E1_PORTADO With _cNewPor
			Replace SE1->E1_AGEDEP  With _cNewAge
			Replace SE1->E1_CONTA   With _cNewCon
		EndIf
		
		SE1->(MsUnlock())
		
		//Grava a transferencia do titulo na tabela de titulos enviados ao banco
		DbSelectArea('SEA')
		SEA->(DbSetOrder(1))
		SEA->(DbGoTop())		
		
		Sleep(1000)

		_cChvSEA := xFilial('SEA') + PADR(STRTRAN( TIME() , ':', '' ), TAMSX3('EA_NUMBOR')[1]) + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + PADR(' ', TAMSX3('EA_FORNECE')[1]) + SE1->E1_LOJA
		//_cChvSEA := xFilial('SEA') + PADR(Alltrim(Str(Randomize(1,34000))), TAMSX3('EA_NUMBOR')[1]) + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + PADR(' ', TAMSX3('EA_FORNECE')[1]) + SE1->E1_LOJA
		If SEA->(DbSeek(_cChvSEA))
			While SEA->(Eof()) ;
					.and. (SEA->EA_FILIAL  + SEA->EA_NUMBOR  + SEA->EA_PREFIXO + ;
							 SEA->EA_NUM 	  + SEA->EA_PARCELA + SEA->EA_TIPO + ;
							 SEA->EA_FORNECE + SEA->EA_LOJA = _cChvSEA)
							
				If SEA->EA_FILORIG = cFilAnt
					_lInsere := .F.
					Exit
				EndIf
				
				SEA->(DbSkip())
			End
		EndIf
		
		If RecLock('SEA', _lInsere)
			
			Replace SEA->EA_NUMBOR  With PADR(STRTRAN( TIME() , ':', '' ), TAMSX3('EA_NUMBOR')[1])
			Replace SEA->EA_FILIAL  With xFilial('SEA')
			Replace SEA->EA_FILORIG With cFilAnt
			Replace SEA->EA_PREFIXO With SE1->E1_PREFIXO
			Replace SEA->EA_NUM     With SE1->E1_NUM
			Replace SEA->EA_PARCELA With SE1->E1_PARCELA
			Replace SEA->EA_FORNECE With PADR(' ', TAMSX3('EA_FORNECE')[1])
			Replace SEA->EA_PORTADO With SE1->E1_PORTADO
			Replace SEA->EA_AGEDEP  With SE1->E1_AGEDEP
			Replace SEA->EA_TIPO    With SE1->E1_TIPO
			Replace SEA->EA_CART    With 'R'
			Replace SEA->EA_NUMCON  With SE1->E1_CONTA
			Replace SEA->EA_SITUACA With SE1->E1_SITUACA
			Replace SEA->EA_SITUANT With _cSituant
			SEA->(MsUnlock())
			
			U_SetLogW(@_aLogW,'Transfer๊ncia de Carteira executada, Tํtulo [' + SE1->E1_FILIAL + '] ' + SE1->E1_PREFIXO + '/' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_TIPO + ' da Carteira '+_cSituant+' para Carteira ' +_cNewSit)
			
			If _lMudaPor
				U_SetLogW(@_aLogW,'Transfer๊ncia de Portador executada, Tํtulo [' + SE1->E1_FILIAL + '] ' + SE1->E1_PREFIXO + '/' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_TIPO + ' do Portador '+_cPorAnt + '/' + _cAgeAnt + '/' + _cConAnt +' para Portador ' + _cNewPor + '/' + _cNewAge + '/' + _cNewCon)
			EndIf
			
		Else
			
			U_SetLogW(@_aLogW,'Nใo foi possํvel registrar a transfer๊ncia de Carteira, Tํtulo [' + SE1->E1_FILIAL + '] ' + SE1->E1_PREFIXO + '/' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_TIPO + ' da Carteira '+_cSituant+' para Carteira ' +_cNewSit)
			
			If _lMudaPor
				U_SetLogW(@_aLogW,'Nใo foi possํvel registrar a transfer๊ncia de Portador, Tํtulo [' + SE1->E1_FILIAL + '] ' + SE1->E1_PREFIXO + '/' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_TIPO + ' do Portador '+_cPorAnt + '/' + _cAgeAnt + '/' + _cConAnt +' para Portador ' + _cNewPor + '/' + _cNewAge + '/' + _cNewCon)
			EndIf
			
		EndIf
		
		If Select('SEA') > 0
			SEA->(DbCloseArea())
		EndIf
		
	EndIf
	
EndIf

//*******************************************************
//****** Muda a Condicao de Pagamento do Cliente ********
//*******************************************************
SA1->(DbSetOrder(1))
SA1->(DbGoTop())
If SA1->(DbSeek(xFilial('SA1')+SE1->(E1_CLIENTE+E1_LOJA)))
	If RecLock('SA1',.F.)
		If Left(_cAto,1) = 'I'
			//Replace SA1->A1_COND    With GetNewPar('MV_CONDPFI','001') // Comentado conforme solicitacao do Kaique Sousa - Helitom Silva em 05/02/2013
			_cOcorrencia := 'NEGATIVADO SERASA.'
			Replace SA1->A1_TITPROT With (SA1->A1_TITPROT + 1) 	//MARCELO - 20/07/11
			Replace SA1->A1_DTULTIT With (dDataBase) 					//MARCELO - 20/07/11
		Else
			_cOcorrencia := 'POSITIVADO SERASA.'
		EndIf
		SA1->(MsUnlock())
		
		//Inclui Registro nos Alertas do Cliente
		_cTime := Time()
		DbSelectArea("ZP5")
		dBSetOrder(1)
		DbGoTop()

		//Enquanto encontrar chave duplicada incrementa o Time !
		While DbSeek( xFilial("ZP5") + PadR(cUserName,30) + PadR(DtoC(dDataBase)+" "+_cTime,20) + "SA1" + xFilial("SA1") + PadR(SE1->E1_CLIENTE+SE1->E1_LOJA,25)	 )
			DbGoTop()
			Sleep(500)
			_cTime := Time()
		EndDo

		If RecLock( "ZP5", .T. )
			ZP5->ZP5_FILIAL := xFilial("ZP5")
			ZP5->ZP5_FILENT := xFilial("SA1")
			ZP5->ZP5_ENTIDA := "SA1"
			ZP5->ZP5_CODENT := SE1->E1_CLIENTE + SE1->E1_LOJA
			ZP5->ZP5_CODCON := cUserName
			ZP5->ZP5_DATA   := DtoC(dDataBase) + " " + _cTime
			ZP5->ZP5_OCORR  := _cOcorrencia	+ ' Titulo/Parcela: ' +	SE1->E1_NUM + "/" + SE1->E1_PARCELA
			ZP5->(MsUnlock())
		EndIf
		
	EndIf
EndIf

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ S060OCO  บAutor  ณ Kaique Sousa      บ Data ณ  06/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณATUALIZA O REGISTRO COM O STATUS DE RETORNO.                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function S060OCO(_aOco)

Local _nI		:= 0
Local _cOco		:= ''

If !Empty(_aOco)
	For _nI := 1 To Len(_aOco)
		_cOco += AllTrim(_aOco[_nI]) + '|'
	Next _nI
Else
	_cOco := ''
EndIf

Return( _cOco )
