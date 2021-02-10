#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Luiz Casagrande     º Data ³  06/02/04   º±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºDesc.     ³  Ponto de entrada que aplica desconto financeiro a partir  º±±
±±º          ³  do pedido de vendas                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± ALTERAÇÕES                                                             ¼±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºPrograma  ³M460FIM   ºAutor  ³Nilton Salvalagio   º Data ³  11/09/08   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºDesc.     ³  Alterações realizadas para atender a necessidade da ulti- º±±
±±º          ³  lização da ST em outros estados                           º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                                      
User Function M460FIM()

Static _CRLF := Chr(13) + Chr(10)
_lFlagSt:=.F.

//CARREGA VOLUME NO CABECALHO DO PEDIDO
IF Empty(SF2->F2_VOLUME1)
	cQryv := " SELECT SUM(D2_QUANT) VOL,SUM(D2_QUANT*B1_PESO) PLIQ,SUM(D2_QUANT*B1_PESBRU) PBRU 
	cQryv += " FROM "+RetSqlName("SD2") + " SD2, "+RetSqlName("SB1") + " SB1 "
	cQryv += " WHERE D2_FILIAL = '"+xfilial("SD2")+"' AND B1_FILIAL = '"+xfilial("SB1")+"' AND "
	cQryv += " D2_COD = B1_COD AND D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' AND "
	cQryv += " D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND D2_LOJA = '"+SF2->F2_LOJA+"' AND "
	cQryv += " SD2.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' "

	TCQUERY cQryv NEW ALIAS "TRAc"
			
    RecLock("SF2",.F.)     
		SF2->F2_VOLUME1 := TRAc->VOL
    MsUnLock("SF2")
    
    TRAc->(DbCloseArea())
Endif       	


//Alerta ao usuario sobre necessidade de cadastramento de EDI
If SF2->F2_TIPO == "N" 
	_aSA1:= GetArea("SA1")
	SA1->(DbSetOrder(1)) //FILIAL + CODIGO DO CLIENTE + LOJA
	SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
	If SA1->A1_CADEDI == "S"
	   MsgBox("Este cliente exige que seja cadastrado EDI, cadastre o EDI")
	   MsgBox("Este cliente exige que seja cadastrado EDI, cadastre o EDI")
	Endif
    RestArea(_aSA1)
Endif

//Contrato de Fidelidade
If SF2->F2_TIPO == "N" .And. SF2->F2_DUPL <> SPACE(09)
   If U_ZAN010(SF2->F2_FILIAL,SF2->F2_CLIENTE,SF2->F2_LOJA)
      U_ZAN010A(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE, SF2->F2_LOJA)
   Endif
Endif

If SM0->M0_CODFIL == "01" 

	_aSA1:= GetArea("SA1")
	SA1->(DbSetOrder(1)) //FILIAL + CODIGO DO CLIENTE + LOJA
	SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))

	_aSC5:=GetArea("SC5")
	SC5->(DbSetOrder(5)) //NOTA FISCAL  + SERIE  + CLIENTE + LOJA
	SC5->(DbSeek(xFilial("SC5") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))

	_aSE1:= GetArea("SE1")
	SE1->(DbSetOrder(2)) //FILIAL + CODIGO DO CLIENTE + LOJA + PREFIXO + N TITULO  + PARCELA  + TIPO

	If SF2->F2_ICMSRET > 0 
	   _lFlagSt:=.T.
	Endif
	
    //Envia e-mail no caso de venda para consumidor final
	If SA1->A1_TIPO == "F" .And. SF2->F2_EST <> "PR" //SF2->F2_DUPL <> SPACE(09) .And. SF2->F2_TIPO == "N"
		_cAssunto  := "Nota Fiscal de Saída para Consumidor Final"                                      
		_cInfo     := "Atenção!!! Esta Nota não deverá sair da empresa sem a GUIA DE RECOLHIMENTO PAGA E ANEXADA"
		_cMensagem :='Sr(a). '+_CRLF
		_cMensagem +='Esse e-mail confirma a geração de Nota Fiscal de venda para consumidor final '+_CRLF
		_cMensagem +='NF       :'+ SF2->F2_DOC           + _CRLF
		_cMensagem +='SERIE    :'+ SF2->F2_SERIE         + _CRLF
		_cMensagem +='CLIENTE  :'+ SF2->F2_CLIENTE       + '-'   + SA1->A1_NOME + _CRLF  
		_cMensagem +='LOJA     :'+ SF2->F2_LOJA          + _CRLF
		_cMensagem +='CNPJ/CPF :'+ SA1->A1_CGC           + _CRLF
		_cMensagem +='IE       :'+ SA1->A1_INSCR         + _CRLF
		_cMensagem +='CÓD REC  :'+ '100102'              + _CRLF
		_cMensagem +='ENDERECO :'+ SA1->A1_END           + _CRLF
		_cMensagem +='MUNICIPIO:'+ SA1->A1_MUN           + _CRLF
		_cMensagem +='ESTADO   :'+ SA1->A1_EST           + _CRLF
		_cMensagem +='CEP      :'+ SA1->A1_CEP           + _CRLF
		_cMensagem +='TELEFONE :'+ SA1->A1_TEL           + _CRLF
		_cMensagem +='PLACA    :'+ SC5->C5_PLACA         + _CRLF
		_cMensagem +='Data   :'+ DTOC(Date())            + _CRLF
		_cMensagem +='Hora   :'+ Time()                  + _CRLF+_CRLF+_CRLF
		_cMensagem +='Mensagem Automática'+_CRLF
		_cMensagem +=SM0->M0_NOMECOM
		u_EEMAIL(GetMv("MV_EMAILST"),_cAssunto,_cMensagem,"")	
	Endif	

	//==
	If SF2->F2_TIPO == "N" .And. SF2->F2_FILIAL = '01' .And. !SF2->F2_EST $ "PR|SC|MG|RJ|SP" 
	
	    _aSE4:=GetArea("SE4")
		SE4->(DbSetOrder(1))
	
		_aSB1:=GetArea("SB1")
		SB1->(DbSetOrder(1))
	
		_aSD2:=GetArea("SD2")
		SD2->(DbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
	
		_aSZS:=GetArea("SZS")
		SZS->(DbSetOrder(1))

	    //Cálculo do Icm Solidário e Envio de E Mail
	    If SF2->F2_ICMSRET > 0 
	    //.AND. SF2->F2_EST<>'SP'
			_cAssunto  := "Nota Fiscal de Saída com a incidência de ICM Solidário"                                      
			_cInfo     := "Atenção!!! Esta Nota não deverá sair da empresa sem a GUIA DE RECOLHIMENTO PAGA E ANEXADA"
		
			_cMensagem :='Sr(a). '+_CRLF
			_cMensagem +='Esse e-mail confirma a geração de Nota Fiscal com a incidência de ICM Solidário '+_CRLF
			_cMensagem +='NF       :'+ SF2->F2_DOC           + _CRLF
			_cMensagem +='SERIE    :'+ SF2->F2_SERIE         + _CRLF
			_cMensagem +='CLIENTE  :'+ SF2->F2_CLIENTE       + '-'   + SA1->A1_NOME + _CRLF  
			_cMensagem +='LOJA     :'+ SF2->F2_LOJA          + _CRLF
			_cMensagem +='CNPJ/CPF :'+ SA1->A1_CGC           + _CRLF
			_cMensagem +='IE       :'+ SA1->A1_INSCR         + _CRLF
			_cMensagem +='CÓD REC  :'+ '1009-9'              + _CRLF
			_cMensagem +='ENDERECO :'+ SA1->A1_END           + _CRLF
			_cMensagem +='MUNICIPIO:'+ SA1->A1_MUN           + _CRLF
			_cMensagem +='ESTADO   :'+ SA1->A1_EST           + _CRLF
			_cMensagem +='CEP      :'+ SA1->A1_CEP           + _CRLF
			_cMensagem +='TELEFONE :'+ SA1->A1_TEL           + _CRLF
			_cMensagem +='ICM SOL  :'+ Transform(SF2->F2_ICMSRET ,"@E 999,999,999.99")      + _CRLF
			_cMensagem +='PLACA    :'+ SC5->C5_PLACA         + _CRLF
		
			_cMensagem +='Data   :'+ DTOC(Date())          + _CRLF
			_cMensagem +='Hora   :'+ Time()                + _CRLF+_CRLF+_CRLF
			_cMensagem +='Mensagem Automática'+_CRLF
			_cMensagem +=SM0->M0_NOMECOM
		                      
	
			u_EEMAIL(GetMv("MV_EMAILST"),_cAssunto,_cMensagem,"")	
	
			_lFlagSt:=.T.
				
		Endif	
	    

	    If (SF2->F2_TIPO == "N" .And.  SF2->F2_FILIAL == '01' .And. SA1->A1_ST_CON <> "N" ) 
			////REGRA DA DATA DE VIGENCIA E REGRA DO CALCULO DA ST PARA PAUTA OU ALIQUOTA
			_nValIcmSol:=0
			_cVigencia :=u_tabelaSTAtiva(SF2->F2_EST,DTOS(SF2->F2_EMISSAO))
			
			_cQry := " 	SELECT DISTINCT D2_DOC,D2_COD,D2_ITEM,SD2.R_E_C_N_O_, "    
			_cQry += "	CASE WHEN ZS_TIPO = 'A' THEN (((D2_TOTAL + D2_VALIPI+(D2_BASEICM-D2_TOTAL))+((D2_TOTAL + D2_VALIPI+(D2_BASEICM-D2_TOTAL))*ZS_ALQST/100))*ZS_ALQINT/100)-D2_VALICM  "
			_cQry += "	ELSE ((D2_QUANT*B1_VCLQE2*ZS_VALOR)*ZS_ALQINT/100)-D2_VALICM END VRST "		
			_cQry += "	FROM SD2010 SD2,SF2010 SF2,SF4010 SF4,SZS010 SZS,SB1010 SB1  "
			_cQry += "	WHERE D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE  "
			_cQry += "	AND D2_TIPO = 'N'  AND  " 
			_cQry += "	F2_EST <> 'MG' AND  " 
			_cQry += "	F2_EST <> 'SC' AND  " 
			_cQry += "	F2_EST <> 'ES' AND  " 
	 		_cQry += "	D2_LOJA = F2_LOJA AND D2_TES <> '521' AND D2_TES = F4_CODIGO AND  "
		 	_cQry += "	D2_TP = 'PA' AND D2_COD = ZS_PRODUTO AND ZS_ESTADO = '"+SF2->F2_EST+"' AND  "
		 	_cQry += "	ZS_VIGENCI = '"+_cVigencia+"' AND  ZS_VALOR+ZS_ALQST > 0 AND  "
		 	_cQry += "	D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' AND D2_COD = B1_COD AND  "
			_cQry += "	D2_FILIAL = F2_FILIAL AND D2_FILIAL = ZS_FILIAL AND D2_FILIAL = F4_FILIAL AND  "
			_cQry += "	D2_FILIAL = B1_FILIAL AND	D2_FILIAL = '"+SF2->F2_FILIAL+"' AND "
		 	_cQry += "	SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' AND  "
		 	_cQry += "	SZS.D_E_L_E_T_ <> '*' AND SF4.D_E_L_E_T_ <> '*'  "
		
			TCQUERY _cQry NEW ALIAS "TRA"
	
			While !TRA->(Eof())
				_nValIcmSol += TRA->VRST
				TRA->(DbSkip())
			End
		
			DbSelectArea("TRA")
			DbCloseArea("TRA")
	
			SE4->(DbSeek(xFilial("SE4") + SC5->C5_CONDPAG))
		                                                                                                                                                                                    
			_cAssunto  := "Nota Fiscal de Saída com a incidência de ICM Solidário"                                      
			_cInfo     := "Atenção!!! Esta Nota não deverá sair da empresa sem a GUIA DE RECOLHIMENTO PAGA E ANEXADA"
		
			_cMensagem :='Sr(a). '+_CRLF
			_cMensagem +='Esse e-mail confirma a geração de Nota Fiscal com a incidência de ICM Solidário. '+_CRLF
			_cMensagem +='NF       :'+ SF2->F2_DOC           + _CRLF
			_cMensagem +='SERIE    :'+ SF2->F2_SERIE         + _CRLF
			_cMensagem +='CLIENTE  :'+ SF2->F2_CLIENTE       + '-'   + SA1->A1_NOME + _CRLF  
			_cMensagem +='LOJA     :'+ SF2->F2_LOJA          + _CRLF
			_cMensagem +='CNPJ/CPF :'+ SA1->A1_CGC           + _CRLF
			_cMensagem +='IE       :'+ SA1->A1_INSCR         + _CRLF
			_cMensagem +='CÓD REC  :'+ '1009-9'              + _CRLF
			_cMensagem +='ENDERECO :'+ SA1->A1_END           + _CRLF
			_cMensagem +='MUNICIPIO:'+ SA1->A1_MUN           + _CRLF
			_cMensagem +='ESTADO   :'+ SA1->A1_EST           + _CRLF
			_cMensagem +='CEP      :'+ SA1->A1_CEP           + _CRLF
			_cMensagem +='TELEFONE :'+ SA1->A1_TEL           + _CRLF
			_cMensagem +='ICM SOL  :'+ Transform(_nValIcmSol ,"@E 999,999,999.99")      + _CRLF
			_cMensagem +='PLACA    :'+ SC5->C5_PLACA         + _CRLF
		
			_cMensagem +='Data   :'+ DTOC(Date())          + _CRLF
			_cMensagem +='Hora   :'+ Time()                + _CRLF+_CRLF+_CRLF
			_cMensagem +='Mensagem Automática'+_CRLF
			_cMensagem +=SM0->M0_NOMECOM
		
			If _nValIcmSol > 0
				u_EEMAIL(GetMv("MV_EMAILST"),_cAssunto,_cMensagem,"")
				If SF2->F2_EST == "SP" .Or. SF2->F2_EST == "PA" 
				   MsgBox("Nota Fiscal emitida para " + SF2->F2_EST + ", verifique situacao de Guia de Recolhimento")
				Endif	
				_lFlagSt:=.T.
			endif	
		
			//Abre o Título no Contas a Receber caso o cliente de Minas não seja Solidário
			If _nValIcmSol > 0
		
				If SE1->(DbSeek(xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC + "S"))
		
			  		MsgBox("PROBLEMA!!! NO TÍTULO A RECEBER REFERENTE AO ICM SOLIDÁRIO, JA EXISTE PARCELA S ")
		
				Else
					_cDias:= " "
					_nPos := 0
					_nDias := 0
				    _lSol  := .F.
		
					if SA1->A1_ST_PRZ == "N" .AND. SE4->E4_GRUPO <> "A"
						if SC5->C5_TPFRETE == 'C'
							SE4->(DbSeek(xFilial("SE4") + SA1->A1_ST_CIF))
							_nDias := val(alltrim(SE4->E4_COND))
						else
							SE4->(DbSeek(xFilial("SE4") + SA1->A1_ST_FOB))
							_nDias := val(alltrim(SE4->E4_COND))
						endif    
			 				_lSol := .T.              
	 				elseif SA1->A1_ST_PRZ == "S" .and. SE4->E4_SOLID <> "S"
		 				If at(",",SE4->E4_COND) > 0
		 					_nDias :=  val(substr(SE4->E4_COND,1,at(",",SE4->E4_COND)-1))
		 				Else
	 						_nDias := val(alltrim(SE4->E4_COND))
		 				EndIf		
		 				_lSol := .T.			
					else
						Do Case
						Case substr(SE4->E4_COND,2,1) = ","
							_nPos:=1
						Case substr(SE4->E4_COND,3,1) = ","
							_nPos:=2
						Case substr(SE4->E4_COND,4,1) = ","
							_nPos:=3
						Case substr(SE4->E4_COND,5,1) = ","
							_nPos:=4
						End Case
					endif
		
					RecLock("SE1",.T.)
					SE1->E1_FILIAL  := xFilial("SE1")
					SE1->E1_PREFIXO := SF2->F2_SERIE
					SE1->E1_NUM     := SF2->F2_DOC
					SE1->E1_PARCELA := "S"
					SE1->E1_TIPO    := "NF"
					SE1->E1_NATUREZ := "ICMS ANTEC"
					SE1->E1_CLIENTE := SF2->F2_CLIENTE
					SE1->E1_LOJA    := SF2->F2_LOJA
					SE1->E1_NOMCLI  := SA1->A1_NREDUZ
					SE1->E1_EMISSAO := SF2->F2_EMISSAO
					SE1->E1_VENCTO  := SF2->F2_EMISSAO + iif(_lSol,_nDias,val(substr(SE4->E4_COND,1,_nPos)))
					SE1->E1_VENCREA := DATAVALIDA(SF2->F2_EMISSAO + iif(_lSol,_nDias,val(substr(SE4->E4_COND,1,_nPos))))
					SE1->E1_VALOR   := _nValIcmSol
					SE1->E1_EMIS1   := SF2->F2_EMISSAO
					SE1->E1_SALDO   := _nValIcmSol
					SE1->E1_VEND1   := " "
					SE1->E1_VENCORI := DATAVALIDA(SF2->F2_EMISSAO + iif(_lSol,_nDias,val(substr(SE4->E4_COND,1,_nPos))))	
					SE1->E1_MOEDA   := 1
					SE1->E1_PEDIDO  := SC5->C5_NUM
					SE1->E1_VLCRUZ  := _nValIcmSol
					SE1->E1_SERIE   := SF2->F2_SERIE
					SE1->E1_STATUS  := "A"
					SE1->E1_ORIGEM  := "MATA460"
					SE1->E1_FILORIG := "01"
					SE1->E1_MSFIL   := "01"
					SE1->E1_MSEMP   := "01"
					SE1->E1_SITUACA := "0"
					MsUnlock("SE1")
				Endif
			Endif
	    Endif
	
	RestArea(_aSE4)
	RestArea(_aSB1)
	RestArea(_aSD2)
	
	Endif

	//Juros de Mora (Definido como específico para Campo Largo
	If xFilial("SF2") == "01"  .AND. SM0->M0_CODIGO == "01" .And. SF2->F2_TIPO == "N"
			
		SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
		SE1->(DbSeek(xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC))
		
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. ;
			SF2->F2_CLIENTE == SE1->E1_CLIENTE .And. SF2->F2_LOJA == SE1->E1_LOJA .And. ;
			SF2->F2_SERIE == SE1->E1_PREFIXO .And. SF2->F2_DOC == SE1->E1_NUM
		
			RecLock("SE1",.F.)
			SE1->E1_PORCJUR := SA1->A1_MORA
			MsUnLock("SE1")
		
			SE1->(DbSkip())	
		End
		
	Endif
	
	//Desconto Financeiro
	If SC5->C5_DESCFI > 0	
		If SE1->(DbSeek(xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + ;
		    SF2->F2_DOC))
			While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. ;
				SF2->F2_CLIENTE == SE1->E1_CLIENTE .And. SF2->F2_LOJA == SE1->E1_LOJA .And. ;
				SF2->F2_SERIE == SE1->E1_PREFIXO .And. SF2->F2_DOC == SE1->E1_NUM
				If SF2->F2_EST == "MG" .AND. (ALLTRIM(SE1->E1_PARCELA) == "S" .OR. ALLTRIM(SE1->E1_PARCELA) == "19")	
					SE1->(DbSkip())
				Else
					RecLock("SE1" ,.F.)
					SE1->E1_DECRESC := (SE1->E1_valor * (SC5->C5_DESCFI / 100))
					SE1->E1_SDDECRE := (SE1->E1_valor * (SC5->C5_DESCFI / 100))
					MsUnLock("SE1")
					SE1->(DbSkip())
				Endif
			End
		Endif                                                    
	Endif
	
	RestArea(_aSE1)
	RestArea(_aSA1)

	if SF2->F2_FILIAL == '01' 
		U_AJCOND(1)
	else
		U_AJCOND(2)
	endif	
EndIf

SE4->(DbSetOrder(1)) //Filial + Cod Condicao de Pagamento    
SE4->(DbSeek(xFilial("SE4") + SF2->F2_COND))
If  SM0->M0_CODIGO == "01"
	If !Empty(SE4->E4_DCN1) .And. SF2->F2_FILIAL == "01"  .And. SF2->F2_TIPO == "N" .And. !Empty(SF2->F2_DUPL) 
	   _cn01()
	Endif
Endif

    
Return   

                                 


Static Function _cn01()

//Revisa datas da condição de Pagamento
If (!Empty(SE4->E4_DCN1) .And. SE4->E4_DCN1 < SF2->F2_EMISSAO ) .Or.;
   (!Empty(SE4->E4_DCN2) .And. SE4->E4_DCN2 < SF2->F2_EMISSAO ) .Or.;
   (!Empty(SE4->E4_DCN3) .And. SE4->E4_DCN3 < SF2->F2_EMISSAO ) .Or.;
   (!Empty(SE4->E4_DCN4) .And. SE4->E4_DCN4 < SF2->F2_EMISSAO ) .Or.;
   (!Empty(SE4->E4_DCN5) .And. SE4->E4_DCN5 < SF2->F2_EMISSAO )
   MsgBox("Data de Vencimento não pode ser menor do que a data de emissão da NF, revise a condição de pagamento")
   Return
Endif   


_nNPar   := 1

SE1->(DbSeek(xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC))		

If !Empty(SE4->E4_DCN1) .And. !Empty(SE4->E4_DCN2) .And. Empty(SE4->E4_DCN3)//Duas Parcelas

	If _lFlagSt //Tem ICMST
		
		_nValST  := IIF(SF2->F2_ICMSRET > 0,SF2->F2_ICMSRET,_nValIcmSol)
		_nValPar := (SF2->F2_VALBRUT - _nValST)/2
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
			      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValST
			   SE1->E1_SALDO   := _nValST
			   SE1->E1_VLCRUZ  := _nValST
			   SE1->E1_VENCTO  := SF2->F2_EMISSAO + 21
			   SE1->E1_VENCREA := DATAVALIDA(SF2->F2_EMISSAO + 21)
			   SE1->E1_VENCORI := SF2->F2_EMISSAO + 21
			   SE1->E1_COMIS1  := 0				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 1")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
	Else
		//Nao Tem ST
		_nValPar := SF2->F2_VALBRUT/2
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
		      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 3
               SE1->(DbDelete())
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 2")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
    Endif
Endif 

If !Empty(SE4->E4_DCN1) .And. Empty(SE4->E4_DCN2) .And. Empty(SE4->E4_DCN3) //Uma Parcela

	If _lFlagSt //Tem ICMST
		
		_nValST  := IIF(SF2->F2_ICMSRET > 0,SF2->F2_ICMSRET,_nValIcmSol)
		_nValPar := SF2->F2_VALBRUT - _nValST
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
			      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValST
			   SE1->E1_SALDO   := _nValST
			   SE1->E1_VLCRUZ  := _nValST
			   SE1->E1_VENCTO  := SF2->F2_EMISSAO + 21
			   SE1->E1_VENCREA := DATAVALIDA(SF2->F2_EMISSAO + 21)
			   SE1->E1_VENCORI := SF2->F2_EMISSAO + 21 
			   SE1->E1_COMIS1  := 0				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 3
               SE1->(DbDelete())
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 3")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
	Else
		//Nao Tem ST
		_nValPar := SF2->F2_VALBRUT
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
		      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 2
               SE1->(DbDelete())
			ElseIf _nNPar == 3
               SE1->(DbDelete())
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 4")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
    Endif
Endif

If !Empty(SE4->E4_DCN1) .And. !Empty(SE4->E4_DCN2) .And. !Empty(SE4->E4_DCN3) //Tres Parcelas

	If _lFlagSt //Tem ICMST
		
		_nValST  := IIF(SF2->F2_ICMSRET > 0,SF2->F2_ICMSRET,_nValIcmSol)
		_nValPar := (SF2->F2_VALBRUT - _nValST)/3
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
			      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValST
			   SE1->E1_SALDO   := _nValST
			   SE1->E1_VLCRUZ  := _nValST
			   SE1->E1_VENCTO  := SF2->F2_EMISSAO + 21
			   SE1->E1_VENCREA := DATAVALIDA(SF2->F2_EMISSAO + 21)
			   SE1->E1_VENCORI := SF2->F2_EMISSAO + 21
			   SE1->E1_COMIS1  := 0				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 4
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN3
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN3)
			   SE1->E1_VENCORI := SE4->E4_DCN3				   				   
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 5")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
	Else
		//Nao Tem ST
		_nValPar := SF2->F2_VALBRUT/3
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
		      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN3
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN3)
			   SE1->E1_VENCORI := SE4->E4_DCN3				   				   
			ElseIf _nNPar == 4
               SE1->(DbDelete())
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 6")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
    Endif
Endif 
If !Empty(SE4->E4_DCN1) .And. !Empty(SE4->E4_DCN2) .And. !Empty(SE4->E4_DCN3) .And. !Empty(SE4->E4_DCN4) //Quatro Parcelas

	If _lFlagSt //Tem ICMST
		
		_nValST  := IIF(SF2->F2_ICMSRET > 0,SF2->F2_ICMSRET,_nValIcmSol)
		_nValPar := (SF2->F2_VALBRUT - _nValST)/4
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
			      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValST
			   SE1->E1_SALDO   := _nValST
			   SE1->E1_VLCRUZ  := _nValST
			   SE1->E1_VENCTO  := SF2->F2_EMISSAO + 21
			   SE1->E1_VENCREA := DATAVALIDA(SF2->F2_EMISSAO + 21)
			   SE1->E1_VENCORI := SF2->F2_EMISSAO + 21
			   SE1->E1_COMIS1  := 0				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 4
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN3
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN3)
			   SE1->E1_VENCORI := SE4->E4_DCN3				   				   
			ElseIf _nNPar == 5
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN4
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN4)
			   SE1->E1_VENCORI := SE4->E4_DCN4				   				   
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 5")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
	Else
		//Nao Tem ST
		_nValPar := SF2->F2_VALBRUT/4
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
		      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN3
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN3)
			   SE1->E1_VENCORI := SE4->E4_DCN3				   				   
			ElseIf _nNPar == 4
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN4
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN4)
			   SE1->E1_VENCORI := SE4->E4_DCN4				   				   
			ElseIf _nNPar == 5
               SE1->(DbDelete())
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 6")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
    Endif
Endif 
If !Empty(SE4->E4_DCN1) .And. !Empty(SE4->E4_DCN2) .And. !Empty(SE4->E4_DCN3) .And. !Empty(SE4->E4_DCN4) .And. !Empty(SE4->E4_DCN5) //Cinco Parcelas

	If _lFlagSt //Tem ICMST
		
		_nValST  := IIF(SF2->F2_ICMSRET > 0,SF2->F2_ICMSRET,_nValIcmSol)
		_nValPar := (SF2->F2_VALBRUT - _nValST)/5
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
			      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValST
			   SE1->E1_SALDO   := _nValST
			   SE1->E1_VLCRUZ  := _nValST
			   SE1->E1_VENCTO  := SF2->F2_EMISSAO + 21
			   SE1->E1_VENCREA := DATAVALIDA(SF2->F2_EMISSAO + 21)
			   SE1->E1_VENCORI := SF2->F2_EMISSAO + 21
			   SE1->E1_COMIS1  := 0				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 4
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN3
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN3)
			   SE1->E1_VENCORI := SE4->E4_DCN3				   				   
			ElseIf _nNPar == 5
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN4
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN4)
			   SE1->E1_VENCORI := SE4->E4_DCN4				   				   
			ElseIf _nNPar == 6
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN5
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN5)
			   SE1->E1_VENCORI := SE4->E4_DCN5				   				   
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 5")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
	Else
		//Nao Tem ST
		_nValPar := SF2->F2_VALBRUT/5
		While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
		      SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC
		      
			RecLock("SE1",.F.)
			If _nNPar == 1
			   SE1->E1_VALOR   := _nValPar
			   SE1->E1_SALDO   := _nValPar
			   SE1->E1_VLCRUZ  := _nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN1
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN1)
			   SE1->E1_VENCORI := SE4->E4_DCN1				   				   
			ElseIf _nNPar == 2
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN2
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN2)
			   SE1->E1_VENCORI := SE4->E4_DCN2				   				   
			ElseIf _nNPar == 3
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN3
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN3)
			   SE1->E1_VENCORI := SE4->E4_DCN3				   				   
			ElseIf _nNPar == 4
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN4
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN4)
			   SE1->E1_VENCORI := SE4->E4_DCN4				   				   
			ElseIf _nNPar == 5
			   SE1->E1_VALOR   :=_nValPar
			   SE1->E1_SALDO   :=_nValPar
			   SE1->E1_VLCRUZ  :=_nValPar
			   SE1->E1_VENCTO  := SE4->E4_DCN5
			   SE1->E1_VENCREA := DATAVALIDA(SE4->E4_DCN5)
			   SE1->E1_VENCORI := SE4->E4_DCN5				   				   
			ElseIf _nNPar == 5
               SE1->(DbDelete())
			Else
			   MsgBox("Ocorreu um problema na gravaçào dos títulos referentes á condição especial, contate o Depto de TI - 6")
			Endif 
			MsUnLock("SE1")   
		    SE1->(DbSkip())
		    _nNPar:=_nNPar+1
	    End			       
    Endif
Endif 



Return