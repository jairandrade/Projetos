#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM011
E-mail com avaliação de não conformidade

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))
                                           
User Function RCOM011()                    
        

	Private cCadastro := "Regras de avaliação de Fornecedores"
	Private aRotina := {}
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cAlias := "QI2"
	Private aCores := {}
	
	aCORES := {{"QI2_RELAT == '1' " ,"BR_VERDE" } ,;   
				{"QI2_RELAT != '1' ","BR_VERMELHO"}} 
	
	
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"      , "AxPesqui"   ,0,1})  
	AADD(aRotina,{"Visualizar NC"  , "AxVisual"   ,0,2})
	AADD(aRotina,{"Visualizar Rel" , "U_RCOM011V" ,0,2})	
	AADD(aRotina,{"Gerar Relat"    , "U_RCOM011I" ,0,4})
	AADD(aRotina,{"Reimprimir"     , "U_RCOM011I" ,0,5})
	AADD(aRotina,{"Lengenda"       , "U_RCOM011L" ,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,aCORES)
	
Return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} EXECUTA
E-mail com aviso de entrega do pedido já atrasado

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------     

User Function RCOM011I() 
Local nRetAx	:= 1                
             

If ALTERA
	IF QI2->QI2_RELAT == '1' 
	    Alert('Não é possível realizar a inclusão de um novo relatório. Relatório já digitado!') 
		Return
	EndIf
	
	nRetAx := AxInclui( "Z09")
Else
	IF QI2->QI2_RELAT != '1' 
	    Alert('Não é possível realizar a reimpressão de um relatório não digitado!') 
		Return
	EndIf
	     
	DbSelectArea('Z09')
	Z09->(DbSetOrder(2))
	Z09->(DbSeek(xFilial('Z09')+QI2->QI2_FNC))
EndIf    

If nRetAx != 3 // se não cancelou a operação       
	Executa()     
EndIf   

Return


Static Function EXECUTA()
	Local cArq		:= ''		
	Local lRet		:= .F. 
	Local cQuery	:= ""
	Local cTime		:= TIME()	

	Private cDirPdf 	:= "\_RNC_PDF\"
	Private cNomeRel 	:= "RNC_" + cFilAnt + "_" + SubStr(DtoS(dDataBase),1,4) + SubStr(DtoS(dDataBase),5,2) + SubStr(DtoS(dDataBase),7,2) +;
						   SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + SubStr(cTime, 7, 2) + ".pdf"
	Private nPagi    	:= 0
	Private oFont10		:= TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
	Private oFont10n	:= TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
	Private oFont12n	:= TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
	Private oFont13n	:= TFont():New("Arial",,13,,.T.,,,,.F.,.F.)
	Private oFont16n	:= TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
	Private oFont24n	:= TFont():New("Arial",,24,,.T.,,,,.F.,.F.)
	
	Private MV_PAR01 	:= 3
	Private MV_PAR02 	:= 3
	
	Private nLin		:= 0
	Private oPrint		:= NIL

	//Verifica se a pasta existe
	If !ExistDir(cDirPdf)
		MakeDir(cDirPdf)
	EndIf
	                        
	If ALTERA // não apresenta a tela para setup do relatório                                                         	            
   		oPrint := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,cDirPdf,.T.,,,,,.F.,,.F.,1 )
    Else
   		oPrint := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,,.F.,,,,,.F.,,.F.,1 )    
    EndIf
	oPrint:SetPortrait()
	oPrint:SetPaperSize(DMPAPER_A4) 
	oPrint:SetMargin(05,05,05,05)	    

	oPrint:cPathPDF := cDirPdf
		
	ImpCabec() //cabeçalho do relatório

  	ImpCorpo() //corpo do relatório
	       
  	ImpRodape()
	   	
	oPrint:EndPage()
	oPrint:Preview()
	      
	If ALTERA	      
		RecLock('QI2',.F.)
		QI2->QI2_RELAT := '1'
		MsUnlock()
		
		//Envia email do relatorio
	
		cAssunto := 'Relatório de Não Conformidade'
	 	//=============================================================================
		// falta fazer o corpo do e-mail
		//==============================================================================
		
		cCorpo := corpo()
		If empty(alltrim(GetMv("TCP_MAILTS")))
			cTo		 := SA2->A2_EMAIL
			cCC		 :=  GetMv("TCP_MAILRE")
		Else         
			cTo		 := alltrim(GetMv("TCP_MAILTS"))
			cCC		 := alltrim(GetMv("TCP_MAILTS"))     	
		EndIf
		
		If !Empty(Alltrim(cTo))
			U_MCOM016(cTo, cCC, cAssunto, cCorpo, cDirPdf + cNomeRel, .F. ) 
			Msginfo('E-mail enviado com sucesso!')
		Else
			Alert('E-mail não enviado ao fornecedor devido a falta de cadastro de endereço de e-mail')
		EndIf
		nRet := FERASE(cDirPdf + cNomeRel)
			
	EndIf
			
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} IMPCABEC
Cabeçalho do relatório

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function IMPCABEC()           
	
	nLin := 10
	oPrint:Box( nLin, 0050, nLin+200, 2350, "-4")

	oPrint:Box( nLin, 0050, nLin+200, 0741, "-8")
	oPrint:SayBitmap( 030, 140,  "\sigaadv\lgrl01.bmp", 450, 150)

	oPrint:Box( nLin, 0740, nLin+200, 1660, "-8")
	oPrint:Say(nLin+050,0992,"RELATÓRIO DE NÃO",oFont24n)
	oPrint:Say(nLin+100,0980,"CONFORMIDADES DE",oFont24n)  
	oPrint:Say(nLin+150,1040,"FORNECEDOR",oFont24n)

	oPrint:Box( nLin, 1660, nLin+200, 2350, "-8")
	oPrint:Box( nLin, 1660, nLin+66, 1900, "-8")
	oPrint:Say(nLin+45,1767,"N°",oFont24n)
	oPrint:Box( nLin, 1900, nLin+66, 2350, "-8")
	nSeqRNC := GetMv("TCP_SEQRNC")+1
	PutMv("TCP_SEQRNC",nSeqRNC)
	oPrint:Say(nLin+45,2100,Alltrim(Str(nSeqRNC)),oFont24n)	
	oPrint:Box( nLin+66, 1660, nLin+132, 1900, "-8")
	oPrint:Say(nLin+105,1730,"DATA",oFont24n)
	oPrint:Box( nLin+66, 1900, nLin+132, 2350, "-8")
	oPrint:Say(nLin+105,2050,DtoC(dDataBase),oFont24n)
	oPrint:Say(nLin+170,1840,GetMv("TCP_FO_RNC"),oFont24n)	
	
	nLin+= 220
	oPrint:Box( nLin, 0050, nLin+200, 2350, "-8")
	oPrint:Box( nLin, 0050, nLin+200, 0521, "-8")
	oPrint:Box( nLin	, 0520, nLin+050, 0741, "-8")
	oPrint:Box( nLin+050, 0520, nLin+100, 0741, "-8")
	oPrint:Box( nLin+100, 0520, nLin+150, 0741, "-8")
	oPrint:Box( nLin+150, 0520, nLin+200, 0741, "-8") 
	
	oPrint:Box( nLin    , 0740, nLin+050, 2350, "-8")
	oPrint:Box( nLin+050, 0740, nLin+100, 2350, "-8")
	oPrint:Box( nLin+100, 0740, nLin+150, 2350, "-8")
	oPrint:Box( nLin+150, 0740, nLin+200, 2350, "-8")

	oPrint:Say(nLin+115,130,"FORNECEDOR:",oFont24n)
	oPrint:Say(nLin+040,540,QI2->QI2_CODFOR,oFont24n)
	oPrint:Say(nLin+090,540,"A/C",oFont24n)
	oPrint:Say(nLin+140,540,"NF",oFont24n)
	oPrint:Say(nLin+190,540,"PEDIDO",oFont24n)

	oPrint:Say(nLin+040,760,Posicione('SA2',1,xFilial('SA2')+QI2->QI2_CODFOR+QI2->QI2_LOJFOR,"A2_NOME"),oFont24n)
	oPrint:Say(nLin+090,760,Z09->Z09_CONTAT,oFont24n)
	oPrint:Say(nLin+140,760,QI2->QI2_DOCNF+"/"+QI2->QI2_SERNF,oFont24n)
	oPrint:Say(nLin+190,760,Posicione("SD1",1,xFilial('SD1')+QI2->QI2_CODPRO+QI2->QI2_DOCNF+QI2->QI2_SERNF,"D1_PEDIDO"),oFont24n)

		
	nLin+= 220
	oPrint:Box( nLin, 0050, nLin+60, 2350, "-4")
	oPrint:Say(nLin+40,0950,"DEPARTAMENTO EMITENTE",oFont24n)	
	nlin+=60
	oPrint:Box( nLin, 0050, nLin+60, 2350, "-8")
	oPrint:Say(nLin+40,0960,"COMPRAS/ALMOXARIFADO",oFont24n)	

	nLin+= 140
	

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ImpCorpo
Corpo do relatório

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function ImpCorpo()
Local aObs := {}            
 Local n1
	oPrint:Box( nLin, 0050, nLin+1250	, 2350, "-4")

	nLin += 50
	oPrint:Say(nLin,60,"Prezado fornecedor,",oFont10n)
	nLin += 65
	oPrint:Say(nLin,90,"O TCP - Terminal de Contêineres de Paranaguá S/A, no intuito de melhorar a qualidade dos materiais e/ou serviços prestados, ",oFont10n)
	nLin += 45
	oPrint:Say(nLin,60,"executa a avaliação de fornecedores, e quando esta tem alguma não conformidade o setor solicitante emite um documento ",oFont10n)
	nLin += 45
	oPrint:Say(nLin,60,"justificando, baseado na capacidade dos mesmos de fornecerem materiais, produtos, componentes e serviços que satisfaçam ",oFont10n)
	nLin += 45
	oPrint:Say(nLin,60,"aos requisitos da qualidade, quer seja através do atendimento das Instruções de Trabalho formuladas pela TCP, quando ",oFont10n)
	nLin += 45
	oPrint:Say(nLin,60,"aplicável.",oFont10n)
	
	nLin += 70
	oPrint:Box( nLin, 0250, nLin+60	, 2150, "-4")  
	oPrint:Say(nLin+040,1000,"NÃO CONFORMIDADE",oFont24n)
	nLin += 60
	oPrint:Box( nLin, 0250, nLin+60	, 2150, "-4")
	oPrint:Say(nLin+040,350,Z09->Z09_TIPONC,oFont24n)

	nLin += 80
	oPrint:Box( nLin, 0250, nLin+60	, 2150, "-4")
	oPrint:Box( nLin, 0250, nLin+60	, 950, "-4")
	oPrint:Say(nLin+040,290,"COD. MATERIAL E/OU SERVIÇO",oFont24n)
	oPrint:Say(nLin+040,1210,"DESCRIÇÃO MATERIAL E/OU SERVIÇO",oFont24n)
   	nLin += 60  
	oPrint:Box( nLin, 0250, nLin+100	, 2150, "-4")
	oPrint:Box( nLin, 0250, nLin+100	, 0950, "-4")
	nLin += 20
   	If !Empty(Alltrim(QI2->QI2_CODPRO))
		oPrint:Say(nLin+040,270,QI2->QI2_CODPRO,oFont24n)
		oPrint:Say(nLin+040,980,Posicione('SB1',1,xFilial('SB1')+QI2->QI2_CODPRO,"B1_DESC"),oFont24n)
	ELSE
		oPrint:Say(nLin+040,270,"DIVERSOS",oFont24n)
		oPrint:Say(nLin+040,1010,"DIVERSOS",oFont24n)
	
	EndIf
		    
	nLin += 100
	oPrint:Box( nLin, 0250, nLin+60	, 2150, "-4")
	oPrint:Say(nLin+040,760,"Desta forma, abaixo descrevemos a não conformidade:",oFont24n)
	nLin += 60
	oPrint:Box( nLin, 0250, nLin+480	, 2150, "-4")
	aObs := QLinha(StrTran(Z09->Z09_NC,chr(10),chr(13)), 70)
	nLin += 60
	For n1 := 1 To len(aObs)
		IF !Empty(aObs[n1])
			oPrint:Say(nLin+(40*(n1-1)),0350,aObs[n1],oFont12n,,,,0)
		EndIF
	Next n1	
	 	
	nLin += 500
	oPrint:Box( nLin, 0050, nLin+250, 2350, "-4")
	nLin += 20                            
	oPrint:Box( nLin, 0250, nLin+60	, 2150, "-4")
	oPrint:Say(nLin+040,760,"LOCAL (Em caso de obra referenciar a sua identificação)",oFont24n)

	nLin += 60
	oPrint:Box( nLin, 0250, nLin+150	, 2150, "-4")
	aObs := QLinha(StrTran(Z09->Z09_LOCAL,chr(10),chr(13)), 120)
	nLin += 60	
	For n1 := 1 To len(aObs)
		IF !Empty(aObs[n1])
			oPrint:Say(nLin+(40*(n1-1)),0350,aObs[n1],oFont12n,,,,0)
		EndIF
	Next n1	
	nLin += 170


Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} Improdapé
Função para imprimir rodapé da página

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015
/*/
//-------------------------------------------------------------------------------
Static Function ImpRodape(cChama)   
          
                
	nLin := 2450 
	oPrint:Say(nLin,0100,"Colocamo-nos á disposição para quaisquer esclarecimentos.",oFont12n)
	nLin += 100 
	oPrint:Say(nLin,0100,"Atencisamente, ",oFont12n) 
	nLin += 100               

	        
	_aRetUser := PswRet(1)
	cNomeUser := Posicione('QAA',1,xFilial("QAA")+QI2->QI2_MATRES,"QAA_NOME")
	oPrint:Say(nLin,0100,cNomeUser,oFont12n)
	nLin += 50           

	If !Empty(Alltrim(_aRetUser[1,12]))
		oPrint:Say(nLin,0100,Alltrim(Posicione('QAD',1,xFilial('QAD')+QAA->QAA_CC,'QAD_DESC')),oFont12n) 
	Else		 
		oPrint:Say(nLin,0100,"COMPRAS / ALMOXARIFADO",oFont12n) 
	EndIf
	nLin += 50
	oPrint:Say(nLin,0100,"E-mail: "+QAA->QAA_EMAIL,oFont12n) 
	
Return
               	
//-------------------------------------------------------------------------------
/*/{Protheus.doc} QLinha
Função para quebra de linha devido a problemas com a função padrão

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015
/*/
//-------------------------------------------------------------------------------
Static Function QLinha(cString,nTam)

   local nI3     := 0   // Contador dos caracteres
   local nJ      := 0   // Contador dos caracteres
   local nL      := 0   // Contador das linhas
   local cLinha  := ""  // Guarda a linha editada no campo memo
   local aLinhas := {}  // Array com o memo dividido em linhas


   for nI3 := 1 to len(cString)
      if (MsAscii(substr(cString,nI3,1)) != 13 /*.Or. MsAscii(substr(cString,nI3,1)) != 10*/) .and. (nL < nTam)
         cLinha+=substr(cString,nI3,1)
         nL++
      else
         if MsAscii(substr(cString,nI3,1)) != 13 /*.Or. MsAscii(substr(cString,nI3,1)) != 10*/
            nI3--
            for nJ := len(cLinha) to 1 step -1
               if substr(cLinha,nJ,1) <> " "
                  nI3--
                  nL--
               else
                  exit
               endif
            next nJ
            if nL <=0
               nL := len(cLinha)
            endif
         endif

         if nL >= 0
            cLinha := substr(cLinha,1,nL)
            AAdd(aLinhas, cLinha)
            cLinha := ""
            nL := 0
         endif
      endif
   next nI3

   if nL >= 0
      cLinha := substr(cLinha,1,nL)
      AAdd(aLinhas, cLinha)
      cLinha := ""
      nL := 0
   endif

return(aLinhas)
                  
Static Function corpo()
Local cCorpo := ''
cCorpo += '<html> '
cCorpo += '	<body> '                                                                                       
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Bom dia,</span></span> '
cCorpo += '			<BR><BR> ' 
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Vimos através informar a abertura de procedimento interno da TCP, RNC - Relatório de Não Conformidade referente divergência em seu atendimento com fornecimento de material (ais) ou serviço (s).</span></span> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Anexo segue documento detalhado e justificativa da abertura da Não Conformidade.</span></span> '
cCorpo += '			<BR> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Quaisquer dúvidas, favor entrar em contato com o comprador e/ou solicitante responsável através de seu e-mail ou telefone identificado na RNC. </span></span> '
cCorpo += '			<BR> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;">TCP</span></span> '
cCorpo += '	</body>'
cCorpo += '</html>

Return cCorpo                  
              

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM011L
Rotina para montagem de legenda

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015
                                                          TOT
/*/
//-------------------------------------------------------------------------------
User Function RCOM011L()
Private cCadastro := "Regras de avaliação de Fornecedores"

	BrwLegenda( cCadastro , "Legenda" ,{{"BR_VERDE"		,"Relatório Gerado"	},;
										{"BR_VERMELHO"	,"Relatório Não Gerado"}})

Return .T.


//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM011V
Visualização do relatório enviado

@return 
@author Felipe Toazza Caldeira
@since 28/09/2015
/*/
//-------------------------------------------------------------------------------     

User Function RCOM011V() 
Local nRetAx	:= 1                
             

	IF QI2->QI2_RELAT != '1' 
	    Alert('Não é possível realizar a visualização de um relatório não digitado!') 
		Return
	EndIf
	     
	DbSelectArea('Z09')
	Z09->(DbSetOrder(2))
	Z09->(DbSeek(xFilial('Z09')+QI2->QI2_FNC))
    AxVisual( "Z09",Z09->(Recno()))

Return

