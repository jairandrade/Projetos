#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Ponto Ent.³ MT100TOK ³ Autor ³ Marcos Feijó IT UP Sul³ Data ³ 20/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Na rotina Documento de Entrada (MATA103) ao fazer o retorno³±±
±±³          ³ do Doc. de Saída está chamando o Ponto de Entrada MT100TOK ³±±
±±³          ³ na abertura da tela, em vez de chamar apenas na conclusão  ³±±
±±³          ³ da geração do documento.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validar a diferença entre as datas de emissão/digitação.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCP – Terminais de Contêineres de Paranaguá S.A.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MT100TOK()
Local lMT100TOK := .f.	//Quando for definida como (.F.) o ponto de entrada será chamado somente uma vez.
Local _lRet		:= .T.
Local _nDiasVen := GetMv("TCP_DIAVEN",.F.,13)
Local _nPosPed  := aScan(aHeader,{|x| Alltrim(x[2])== 'D1_PEDIDO' } )
Local _nPosTes  := aScan(aHeader,{|x| Alltrim(x[2])== 'D1_TES' } )
Local _nPOSCOD  := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
lOCAL dDataVal 	:= DaySum( Date(),_nDiasVen )
Local _lFin     := .F.
local nIndAx	:= 1
Local _nI		:= 1
Local __p		:= 1
Local lEpi		:= .F.
Local lIntMdt   := GetMv('TCP_INTMST')
Local cDComMdt	:= GetMv('TCP_COMMDT')
Local cLocInf	:= GetMV("TCP_LOCINF")
Local cTpOpInf	:= GetMV("TCP_TPINF")
Local cGrpInf	:= GetMV("TCP_GRPINF")

dbSelectArea("SB1")
SB1->(dbSetOrder(1))

if Alltrim(FunName()) == 'MATA103'
	for nIndAx := 1 to LEN(aCols)
		if !aCols[nIndAx,Len(aHeader)+1]
			IF(POSICIONE('SB1',1,xFilial('SB1')+aCols[nIndAx,gdFieldPos("D1_COD")],'B1_GRUPO') $ cGrpInf )
				IF _lRet .AND. aCols[nIndAx,gdFieldPos("D1_LOCAL")] != cLocInf .OR. aCols[nIndAx,gdFieldPos("D1_OPER")] != cTpOpInf
					Help("",1,"TCPPRDINF",,'Produtos de informática devem obrigatóriamente ter a Operação: ' + cTpOpInf + ' e Armazém: ' + cLocInf,4,1,NIL, NIL, NIL, NIL, NIL, {"Revise os itens da nota."})
					_lRet := .F.
				ENDIF
				
				IF _lRet .AND. empty(aCols[nIndAx,gdFieldPos("D1_DTVALID")] )
					Help("",1,"TCPPRDINF",,'Produtos de informática devem obrigatóriamente ter a data de garantia preenchida.',4,1,NIL, NIL, NIL, NIL, NIL, {"Preencha a garantia."})
					_lRet := .F.
				ENDIF
			ENDIF  
			If SB1->(dbSeek(xFilial("SB1")+aCols[nIndAx][_nPOSCOD]))
				If ( SB1->B1_TIPO == "ES" )
					lEpi := .T.
				EndIf
			EndIf
		endif
	next
	
	//Integração Doc. Entr x MDT
	If ( lIntMdt .And. cDComMdt == "2" .And. lEpi )
		If ( INCLUI .Or. l103class ) 
			_lRet := ExecBlock("TCCO02KM",.F.,.F.)
		Endif
	EndIf
	
	If ( _lRet )
		If ( INCLUI )
			_lRet := u_ACOM010(cNFiscal,cA100For,cLoja)
			if !_lRet
				cA100For := space(TamSx3("F1_FORNECE")[1])
				cLoja 	 := space(TamSx3("F1_LOJA")[1])
			endif
		endif
	EndIf
	
endif

Return( _lRet )
