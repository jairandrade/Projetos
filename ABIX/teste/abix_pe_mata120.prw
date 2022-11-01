/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! COM - Compras                                           !
+------------------+---------------------------------------------------------+
!Nome              ! COM001                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Enviar Email de Compras para Fornecedor                 !
+------------------+---------------------------------------------------------+
!Autor             ! SERGIO KASSNER                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 25/08/2011                                              !
+------------------+---------------------------------------------------------+
@history 09.04.2019, A.Effting, Movidesk https://atendimento.abix.com.br/Ticket/Edit/37323
@history 13.10.2021, A.Effting, Movidesk https://atendimento2.abix.com.br/Ticket/Edit/300606
*/

#include "rwmake.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "protheus.ch"
#include 'hbutton.ch'

User Function MT120BRW()  // descobrir qual funcao do ponto de entrada

   AAdd( aRotina, { 'Enviar Email', 'U_COM001', 0, 6 } )

Return(aRotina)


//********************
// Enviar Email
User Function COM001()

   Local nOpca       := 0

   Local cServer     := cAccount := cFrom := cTo := cPassword := cAssunto  := cMensagem := cAttach := ""
   Local cCompEmail  :=  GetSrvProfString("Startpath","")+"docs_abix/comprasemailenv.html"   //grava ultimos emails enviados
   Local cEmailsEnv  :="" , cEnvPara := "" , lEnvia := .F.
   Local Aanexo := {}
   Private cHtml     := ""
   Private cMemoMail := ""
//Private cRemet    := "compras.suporte@abix.com.br"  //ALLTRIM(UsrRetMail(RETCODUSR())) + SPACE(100-Len(ALLTRIM(UsrRetMail(RETCODUSR()))))
   Private cRemet    := "compras.suporte@abix.com.br"  + SPACE(80)
   Private cDirWeb   := ALLTRIM(GETMV("AB_DOCSWEB"))
   Private cDest     := ""
   Private cObscomp := " "

   If cEmpAnt $ '01|02'
      cRemet:="compras.suporte@abix.com.br"  + SPACE(80)
   Else
      cRemet:= "compras@motelcelebrity.com.br " + SPACE(70)
   EndIf

//--- Busca dados do Usuário que realizou o Pedido de compras ---
   _aRetUsr := U_GetUsInf(1,SC7->C7_USER,1,{4,14})
  //_aRetUsr := U_GetUsInf(1,'000154',1,{4,14})
   If !Empty(_aRetUsr[2])
      cRemet := _aRetUsr[2]
   Else
      cRemet := 'abix@abix.com.br'
   EndIf
//---------------------------------------------------------------

//Posiciona na SA2-Fornecedores para pegar o email do fornec.
   cDest := Alltrim(POSICIONE("SA2",1, XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA ,"A2_X_MAILC"))
//cDest := cDest //+";"+cRemet

   cAuxDest := cDest // guardar sem o email do fornecedor

   cDest := cDest + Space(300-Len(cDest))

//cMemoMail := "Abix Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME

   If cEmpAnt $ '01|02'
      cMemoMail:=cMemoMail := "Abix Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
   Else
      If ALLTRIM(SC7->C7_FILIAL) =="03010001" // Hotel do largo
         cMemoMail:= cMemoMail := "Hotel do Largo -  Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010002" // Hotel do celebration
         cMemoMail:= cMemoMail := "Hotel do Celebrationo -  Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010003" // Hotel do don juan
         cMemoMail:= cMemoMail := "Hotel Don Juan -  Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020001" // Motel Mystik
         cMemoMail:= cMemoMail := "Motel Mystik -  Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020002" // Motel Celebrity
         cMemoMail:= cMemoMail := "Motel Celebrity -  Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020003" // Motel orquideas
         cMemoMail:= cMemoMail := "Motel das Orquídeas -  Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
      Endif
   EndIf

//DEFINE DIALOG oDlgMail TITLE "[COM001] - Abix - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL

   If cEmpAnt $ '01|02'
      DEFINE DIALOG oDlgMail TITLE "[COM001] - Abix - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
   Else
      If ALLTRIM(SC7->C7_FILIAL) =="03010001" // Hotel do largo
         DEFINE DIALOG oDlgMail TITLE "[COM001] - Hotel do Largo - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010002" // Hotel do celebration
         DEFINE DIALOG oDlgMail TITLE "[COM001] - Hotel Celebration - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010003" // Hotel do don juan
         DEFINE DIALOG oDlgMail TITLE "[COM001] - Hotel Don Juann - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020001" // Motel Mystik
         DEFINE DIALOG oDlgMail TITLE "[COM001] - Motel Mystik - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020002" // Motel Celebrity
         DEFINE DIALOG oDlgMail TITLE "[COM001] - Motel Celebrity - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020003" // Motel orquideas
         DEFINE DIALOG oDlgMail TITLE "[COM001] - Motel das Orquídeas - Pedido de Compra: "+ SC7->C7_NUM FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL
      Endif

   EndIf

   oSay1     := tSay():New(012,010,{|| "De: " },oDlgMail,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
   oGet1     := TGet():New(010,060,{|u| if(PCount()>0,cRemet:=u,cRemet)}, oDlgMail,140,9,,,,,,,,.T.,,,,,,,.F.,,,'cRemet')

   oSay2     := tSay():New(027,010,{|| "Para: " },oDlgMail,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
   oGet2     := TGet():New(025,060,{|u| if(PCount()>0,cDest:=u,cDest)}, oDlgMail,140,9,,,,,,,,.T.,,,,,,,.F.,,,'cDest')

   oGrpMemo  := tGroup():New(042,010,105,199,"Informações Adicionais ao Fornecedor",oDlgMail,CLR_HBLUE,,.T.)

   oMemoMail:= tMultiget():New(052,013,{|u|if(Pcount()>0,cMemoMail:=u,cMemoMail)},oGrpMemo,182,047,,.T.,,,,.T.)
   oMemoMail:EnableVScroll(.T.)
   oMemoMail:EnableHScroll(.T.)

   oBtVis := tButton():New(110,025,'Sel. Email' ,oDlgMail,{|| fSelEmail() },40,12,,,,.T.)
   oBtVis := tButton():New(110,070,'Visualizar' ,oDlgMail,{|| fVisual() },40,12,,,,.T.)
   oBtOK  := tButton():New(110,115,'Enviar'     ,oDlgMail,{|| nOpca:=1,oDlgMail:End() },40,12,,,,.T.)
   oBtCan := tButton():New(110,160,'Cancelar'   ,oDlgMail,{|| oDlgMail:End() },40,12,,,,.T.)

   ACTIVATE DIALOG oDlgMail CENTERED


   If nOpca == 1
      cEnvPara :=  chr(13) + Strtran(cDest,";",chr(13)+chr(13)) +"  "+chr(13)+ " "+chr(13)
      lEnvia := MsgYesNo(cEnvPara,"Confirma Envio dos Emails Abaixo?")
   Endif

   If nOpca == 1 .and. lEnvia

      cHtml     :=  fGeraHtml()

      cFrom     := cRemet
      cTo       := cDest

//	cAssunto  := "Pedido de Compra ABIX - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME) + "  Solic: "+ ;
//             	 Alltrim(POSICIONE("SC1",6, XFILIAL("SC1")+SC7->C7_NUM ,"C1_SOLICIT"))    // posiciona no primeiro item apesar de poder ter varios itens (o mesmo solic é replicado na SC1)            

      If cEmpAnt $ '01|02'
         cAssunto  := "Pedido de Compra ABIX - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME) + "  Solic: "+ ;
            Alltrim(POSICIONE("SC1",6, XFILIAL("SC1")+SC7->C7_NUM ,"C1_SOLICIT"))    // posiciona no primeiro item apesar de poder ter varios itens (o mesmo solic é replicado na SC1)
      Else
         If ALLTRIM(SC7->C7_FILIAL) =="03010001" // Hotel do largo
            cAssunto  := "Pedido de Compra Hotel do Largo - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME)
         Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010002" // Hotel do celebration
            cAssunto  := "Pedido de Compra Hotel Celebration - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME)
         Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010003" // Hotel do don juan
            cAssunto  := "Pedido de Compra Hotel Don Juan - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME)
         Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020001" // Motel Mystik
            cAssunto  := "Pedido de Compra Motel Mystik - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME)
         Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020002" // Motel Celebrity
            cAssunto  := "Pedido de Compra Motel Celebrity - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME)
         Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020003" // Motel orquideas
            cAssunto  := "Pedido de Compra Motel das Orquídeas - "+ SC7->C7_NUM+ " " +alltrim(SA2->A2_NOME)
         Endif

      EndIf


      cMensagem := cHtml // cMemoMail
      cAttach   := ""

      If U_MailTo(cDest,cAssunto , cMensagem , Aanexo, cFrom )
         ApMsgInfo("E-mail enviado com sucesso!","[ABIX_PE_MATA120] - OK")
      Else
         MsgStop("Erro ao Enviar E-mail ABIX_PE_MATA120 ")
         Return
      Endif

   EndIf


return



//==================================================== LAYOUT HTML =================================================//


Static Function fGeraHtml()
   Local cRet := "" , cBody := "" , cNum := 0
   Local TxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
   Local cTipoFrete := ""
   Local nTotIcms :=  nTotIpi := nTotDesp := nTotFrete	:= nTotalNF	:= nTotSeguro:= nTotNF := nTotIRet := 0
   Local aValIVA  := NIL , nTotal := 0
   Local cFiltro  := ""
   Local cDscriB1:= " "
   Local nDescProd := 0
   Local cCondPgt := ""
   Local cObs := ""
   Local cReajuste := ""
   Local nOldReg := 0
   Local lIniMaFis := .F.
   Local _cLogoWeb  := Alltrim(SuperGetMv("AB_LOGOWEB",.F.,"https://www.abix.com.br/images/logo_tecnologia.png"))
//Local lIniMaFis := .T.

// Logo Abix   

   cBody+= "<table  border='0' cellpadding='0' cellspacing='0' width='800'>"
   cBody+= "       <tbody>"
   If cEmpAnt $ '01|02'
     // cBody+= " <div ><img src='https://www.abix.com.br/images/logo_tecnologia.png'></div><br>"
      cBody+= " <div ><img src='"+_cLogoWeb+"'></div><br>"
   Else
      If ALLTRIM(SC7->C7_FILIAL) =="03010001" // Hotel do largo
         cBody+= " "
//      cBody+= "            <div style='text-align: left;'><img src='http://hoteldolargo.com.br/imagens/bannermedallhaGOLDLARGO.jpg'></div><br>"
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010002" // Hotel do celebration
         cBody+= " "
//            cBody+= "            <div style='text-align: left;'><img src='http://hotelcelebration.com.br/imagen/banner_principal4.png'></div><br>"
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03010003" // Hotel do don juan
         cBody+= " "
//            cBody+= " "
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020001" // Motel Mystik
         cBody+= " "
//            cBody+= "            <div style='text-align: left;'><img src='http://mystik.com.br/wp-content/uploads/2016/12/logo-site-1.jpg'></div><br>"
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020002" // Motel Celebrity
         cBody+= " "
//            cBody+= "            <div style='text-align: left;'><img src='http://177.159.111.235/motelcelebrity.com.br/wp-content/uploads/2016/12/logo-site.jpg'></div><br>"
      Elseif  ALLTRIM(SC7->C7_FILIAL) =="03020003" // Motel orquideas
         cBody+= " "
      Endif
   Endif
   cBody+= "  </tbody>"
   cBody+= "</table>"
// Cabeçalho do Usuário
   cBody+= "<div >"
   cBody+= cMemoMail+"<br>"

// Dados da Abix 
   cBody+= Repl("_",100) + "<br><br>"
   cBody+= " <br>Comprador: <br> "
   cBody+= padr(SM0->M0_NOMECOM,70)  + " Departamento de Compras <br>"
   cBody+= padr(SM0->M0_ENDENT,70)   + ' <a class="moz-txt-link-abbreviated" href="">' + alltrim(cRemet) + "</a> <br>"
   cBody+= "Cep: "+SM0->M0_CEPENT + " - "+ alltrim(SM0->M0_CIDENT) + " - " + SM0->M0_ESTENT + "<br>"
   cBody+= "Fone: "+SM0->M0_TEL + " - "+SM0->M0_FAX + "<br>"
   cBody+= "Cnpj/Cpf: "+Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) + " IE: "+SM0->M0_INSC + "<br><br>"

// Dados do Fornecedor
   cBody+= Repl("_",100) + "<br><br>"
   cBody+= "Fornecedor: <br>"
   cBody+= alltrim(SA2->A2_NOME) + "    CNPJ/CPF: "+SA2->A2_CGC + "   IE: " + SA2->A2_INSCR + "<br>"
   cBody+= alltrim(SA2->A2_END)  + " - "+alltrim(SA2->A2_BAIRRO) +"<br>"
   cBody+= alltrim(SA2->A2_MUN) + "-" + SA2->A2_EST + "  Contato: "+ SC7->C7_CONTATO  + "<br>"
   cBody+= "Fone: ("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + "  Fax: ("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_FAX,1,15) + "<br>"
   cBody+= Repl("_",100) + "<br><br>"

//dados da itens da nota

//cBody+= "<FONT SIZE=2>" 
 //  cBody+= "<SMALL><SMALL>"
 //  cBody+= "Item     Codigo      Descricao do Material           UM       Quant.  Val. Unitario   IPI       Val. Total  Entrega   C.C./S.C.<br><br>"

   /*cBody+= "<br>Produtos: <br>
   cBody+= "<table>
   cBody+= "	<tr class='itens'>
   cBody+= "		<td class='itens'>Item</td><td class='itens'>Codigo</td><td class='itens'>Descricao do Material</td><td class='itens'>UM</td><td class='itens'>Quant</td><td class='itens'>Val. Unitario</td><td class='itens'>IPI</td><td class='itens'>Val. Total</td><td class='itens'>Entrega</td><td class='itens'> C.C./S.C.</td>
   cBody+= "	</tr>
*/
cBody+= "<table BORDER=1 ; width= 100%>
cBody+= "<tr bgcolor = #F2F2F2> 
cBody+= " <td >Item  </td> "
cBody+= " <td >Codigo          </td> "
cBody+= " <td >Descricao do Material                                 </td> "
cBody+= " <td >UM  </td> "
cBody+= " <td >Quant      </td> "
cBody+= " <td >Val. Unitario  </td>"
cBody+= " <td >IPI            </td>"
cBody+= " <td >Val. Total     </td>"
cBody+= " <td >Prev. Entrega  </td>"
cBody+= " <td > C.C./S.C.     </td>"

   cNum := SC7->C7_NUM

// Posiciona no primeiro
   dbSelectArea("SC7")
   nOldreg := Recno()
   dbSetOrder(1)
   dbSeek(xFilial("SC7")+SC7->C7_NUM,.T.)


   DbSelectArea("SX5")
   DbSetOrder(1)
   DbSeek(xFilial("SX5") +"24"+ SC7->C7_FORMAPG)

// Acha cond pgto
   dbSelectArea("SE4")
   dbSetOrder(1)
   dbSeek(xFilial("SE4")+SC7->C7_COND)



   dbSelectArea("SC7")

//cCondPgt  := SC7->C7_COND + "-"+ SubStr(SE4->E4_COND,1,40) 
//cCondPgt  := SubStr(SE4->E4_DESCRI,1,40)
   cCondPgt  := SubStr(SE4->E4_DESCRI,1,40)+" ("+alltrim(SubStr(SE4->E4_COND,1,40))+")" + " Forma Pg: "+ SC7->C7_FORMAPG + " - "+ AllTrim(SX5->X5_DESCRI)

   cReajuste := SC7->C7_REAJUST
   cTipoFrete := IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))

   While !Eof() .And. SC7->C7_FILIAL = xFilial("SC7") .And. SC7->C7_NUM = cNum
      demissao := SC7->C7_EMISSAO
      If cEmpAnt $ '01|02'
         _cdescri:=alltrim(SC7->C7_DESCRI) + iif(EMPTY(SC7->C7_COMPLEM),""," - "+ALLTRIM(SC7->C7_COMPLEM))
      Else
         cDscriB1:= POSICIONE("SB1",1,XFILIAL("SB1")+SC7->C7_PRODUTO,"B1_DESCRI")
         _cdescri:=alltrim(cDscriB1) + iif(EMPTY(SC7->C7_COMPLEM),""," - "+ALLTRIM(SC7->C7_COMPLEM))
      EndIf



     /* cBody+= SC7->C7_ITEM +  " "+ SC7->C7_PRODUTO + " "+left(_CDESCRI,30) + "  "+SC7->C7_UM + ;
         Transform(SC7->C7_QUANT,PesqPictQt("C7_QUANT",13)) + ;
         Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",16)) + " "+ ;
         Transform(SC7->C7_IPI,PesqPictQT("C7_IPI",5)) +  ;
         Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL",16)) + " "+ ;
         Dtoc(SC7->C7_DATPRF) + " "+ ;
         alltrim(Transform(SC7->C7_CC,PesqPict("SC7","C7_CC",20))) + " "+ ;
         alltrim(SC7->C7_NUMSC)+ "<br>"
*/
      cccsc := alltrim(Transform(SC7->C7_CC,PesqPict("SC7","C7_CC",20))) +"/"+ alltrim(SC7->C7_NUMSC)
      cBody+= "  <tr> "
      cBody+= " <td class='Subitens'>"+SC7->C7_ITEM+"</td><td class='Subitens'>"+SC7->C7_PRODUTO+"</td><td class='Subitens'>"+left(_CDESCRI,30)+Substr(_CDESCRI,31,Len(_CDESCRI) )+"</td>  <td class='Subitens'>"+SC7->C7_UM+" </td><td class='Subitens'>"+Transform(SC7->C7_QUANT,PesqPictQt("C7_QUANT",13)) +"</td><td class='Subitens'>"+Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",16))+"</td><td class='Subitens'>"+Transform(SC7->C7_IPI,PesqPictQT("C7_IPI",5))+"  </td><td class='Subitens'>"+Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL",16))+" </td><td class='Subitens'>"+Dtoc(SC7->C7_DATPRF)+"</td><td class='Subitens'>"+cccsc +" </td> "
      cBody+= "</tr> "

     /* If ! empty(Substr(_CDESCRI,31,len(_CDESCRI)))
         // cBody+= Space(20) +Substr(_CDESCRI,31,Len(_CDESCRI) ) + "<br>"

         cBody+= "  <tr> "
         cBody+= " <td class='Subitens'></td><td class='Subitens'>Inf.Adicional</td><td class='Subitens'>"+Substr(_CDESCRI,31,Len(_CDESCRI) )+"</td>  <td class='Subitens'>  </td><td class='Subitens'> </td><td class='Subitens'></td><td class='Subitens'> </td><td class='Subitens'> </td><td class='Subitens'></td><td class='Subitens'> </td> "
         cBody+= "</tr> "

      Endif*/


      If ! empty(SC7->C7_OBS)
         If ! Empty(cObs)
            cObs += "    "+SC7->C7_OBS+"<br>"
         Else
            cObs += SC7->C7_OBS+"<br>"
         Endif
      Endif

      nTotal  :=nTotal+SC7->C7_TOTAL

      If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
         nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
      Else
         nDescProd+=SC7->C7_VLDESC
      Endif

      MaFisEnd()
      If SC7->C7_QUANT > SC7->C7_QUJE
         lIniMaFis := .T.
         R110FIniPC(SC7->C7_NUM,,, )
      Endif

      skip
   enddo
   cBody+= " </table> "
  


   //cBody+= "</SMALL></SMALL>"


// Dados rodadpe 
   If lIniMaFis
      nTotIcms   := MaFisRet(,'NF_VALICM')
      nTotIpi	  := MaFisRet(,'NF_VALIPI')
      nTotIcms   := MaFisRet(,'NF_VALICM')
      nTotDesp   := MaFisRet(,'NF_DESPESA')
      nTotFrete  := MaFisRet(,'NF_FRETE')
      nTotalNF   := MaFisRet(,'NF_TOTAL')
      nTotSeguro := MaFisRet(,'NF_SEGURO')
      aValIVA    := MaFisRet(,"NF_VALIMP")
      nTotNF	  := MaFisRet(,'NF_TOTAL')
//   nTotIRet	  := MaFisRet(,'NF_ICMSRET')
      nTotIRet	  := MaFisRet(,'NF_VALSOL')
   Endif




   cBody+= Repl("_",100) + "<br><br>"
   cBody+= "Emissão: "+ Dtoc(demissao)+"    Ipi: "+ Alltrim(Str(nTotIpi,12,2)) + "    Icms: " + Alltrim(Str(nTotICMS,12,2)) + "    Icms Ret: " + Alltrim(Str(nTotIRet,12,2))  +   "<br><br>"
   cBody+= "Frete: "+Alltrim(Str(nTotFrete,12,2)) + " - "+cTipoFrete + "   Descontos: "+ Alltrim(Str(nDescProd,12,2))+"    Despesas: "+Alltrim(Str(nTotDesp,12,2)) + "    Seguro: "+ Alltrim(Str(nTotSeguro,12,2)) + "<br><br>"
   cBody+= "Reajuste:  "  + cReajuste+  "<br><br>"
   cBody+= "Total Mercadoria: "+Alltrim(Str(nTotal,12,2)) + "     Total c/ Impostos: "+Alltrim(Str(nTotNF,12,2)) + ;
      "    <b> Total Geral: "+ Alltrim(Str(nTotNF,12,2)) + "</b><br><br>"
   cBody+= "Cond Pgto.: <b>" + cCondPgt + "</b><br><br>"

   cObs += cObscomp
   cBody+= "Obs: "+ cObs+ "<br>"

   cBody+= Repl("_",100) + "<br><br>"

   cBody+= "<b>"

   cBody+= "End. Entrega : "+ Alltrim(SM0->M0_ENDENT) +"  "+alltrim(SM0->M0_CIDENT)+ "  - "+SM0->M0_ESTENT+ ;
      "  Cep: "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP"))  + "<br><br>"

   //cBody+= "End. Cobrança: AL AUGUSTO STELLFELD, 1175  CURITIBA  - PR  Cep: 80430-140"+"<br><br>"
   cBody+= "End. Cobrança: RUA COMENDADOR ARAÚJO, 731 LOJA 411 ANDAR L4, CURITIBA  - PR  Cep: 80420-000"+"<br><br>"



//cBody+= "*NOTA: Favor fazer constar o número desta ordem de compra no corpo da nota fiscal. <br>"
//cBody+= "       Os valores desta O.C. tem impostos inclusos. </b><br>"
   If cEmpAnt $ '01|02'
      cBody+= "*NOTA: Favor fazer constar o número desta ordem de compra no corpo da nota fiscal. <br>"
      cBody+= "       Os valores desta ordem de compra tem impostos inclusos. </b><br>"
      cBody+= "       E-mail para envio da Nota Fiscal - <u>fornecedornfe@abix.com.br</u><br>"
      cBody+= "       Informamos que os fornecedores da Abix, são avaliados e pontuados por atendimento,  <br>"
      cBody+= "       pontualidade nas entregas, preço e qualidade dos produtos oferecidos.  <br>"
   Else
      cBody+= "*NOTA: Favor informar na nota fiscal, o número do pedido de compras. <br>"
      cBody+= "       Endereço Eletrônico para envio de Notas Fiscais e Boletos - <u>nfe@motelcelebrity.com.br</u><br>"
   EndIf

//cBody+= "       Email para envio da Nota Fiscal - <u>fornecedornfe@abix.com.br</u><br>"

   cBody+= "</div>" //"</table>"



   cBody+= Repl("_",100) + "<br>"

// Email
 /*  cRet+= "<html>"
   cRet+= "<head>"
   cRet+= '  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">'
   cRet+= "  <title></title>"
   cRet+= "</head>"
   cRet+= '<body font face=Courier,Bitstream Vera Sans Mono, Luxi Mono text="#000000" bgcolor="#ffffff">'
   cRet+= '<FONT SIZE=5 STYLE="font-size: 10pt">'
   cRet+= '<pre wrap="">'
*/
cRet+= " <html>
cRet+= "	<head>
/*cRet+= "		<style type='text/css'>		
cRet+= " 			.itens {
cRet+= "				background: #F2F2F2;
cRet+= "				border: 2px solid #ddd;	
cRet+= "				text-align: center;
cRet+= "			}
cRet+= "			.Subitens {				 
cRet+= "				border: 2px solid #ddd;	
cRet+= "				text-align: center;
cRet+= "       }
cRet+= "			table {
cRet+= "			  border-collapse: collapse;
cRet+= "			  width: 97%;
cRet+= "			  font-size: 80%;
cRet+= "			  text-align: justify;
cRet+= "			  margin: 0;
cRet+= "       }
cRet+= "		</style>*/
 

   cRet += cBody

   cRet+= "</FONT>"
   cRet+= "</span>"
   cRet+= "</body>"
   cRet+= "</html>"

 dbSelectArea("SC7")
   If nOldreg <> 0
      dbgoto( nOldreg )
   Endif

Return(cRet)


/////////////////
// Visualiza No Firefox o Pedido
Static Function fVisual()
   Local cArquivo  :=  GetSrvProfString("Startpath","")+"docs_abix/tempvisualiza.html"

	Private _cBrow := SuperGetMv("AB_LNXBROW",.F.,"/opt/google/chrome/chrome")

   cHtml  :=  fGeraHtml()

   memowrit(cArquivo, cHtml)

   If ! File(cArquivo)
      Alert("Nao Gravei "+cArquivo )
   Endif

   If GetRemoteType() == 2
      WinExec(_cBrow + " " + cDirWeb + "tempvisualiza.html")
   Else
      ShellExecute( "Open", cDirWeb +"tempvisualiza.html" ,"","c:\",1)
   EndIf

Return


//*********************
// Function  fselEmail()
//
// reformulado rotina do fselemail  memoline parou de funcionar 
// lendo o arquivo so aparece chr(10)
// talvez por isso nao acha linha por linha como chr(13)+chr(10) no memoline

Static Function fSelEmail()
   Local nOpc := 0
   Local oOk  := LoadBitMap(GetResources(), "LBOK")
   Local oNo  := LoadBitMap(GetResources(), "LBNO")
   Local cArquivo  :=  GetSrvProfString("Startpath","")+"docs_abix/emailscompras.txt"
   Local i := 0 , cArq := ""
   local cEmail := "" , pos := 0
   Local aTitulo := {}

//
//========================// Browse com os títulos //========================//

   aTitulo := F_GeraVet(cArquivo)  // traz o conteudo emaiscompras.txt

   If Len(aTitulo) = 0
      AADD(aTitulo,{.F., "Arquivo Vazio"})
   Endif
   aTitulo := ASort(aTitulo, , , {|x,y|x[2] < y[2]})

//
//
//========================// Browse com os títulos //========================//


   DEFINE MSDIALOG oDlgTit TITLE "Seleção de e-mails Cadastrados" From 001,001 to 380,615 Pixel

   oBrwTit := TCBrowse():New(010,005,300,150,,,,oDlgTit,,,,,,,,,,,,.F.,,.T.,,.F.,,,)


   oBrwTit:AddColumn(TCColumn():New(" "            , {|| If(aTitulo[oBrwTit:nAt,01],oOk,oNo) },,,,,,.T.,.F.,,,,.F., ) )

   oBrwTit:AddColumn(TCColumn():New("Prefixo"      , {|| aTitulo[oBrwTit:nAt,02]},,,,, ,.F.,.F.,,,,.F., ) )

   oBrwTit:SetArray(aTitulo)

   oBrwTit:bLDblClick   := { || aTitulo[oBrwTit:nAt,01] := !aTitulo[oBrwTit:nAt,01]  }
   oBrwTit:bHeaderClick := { || fSelectAll() }

   oBtnImpr := tButton():New(170,160,'Editar'    ,oDlgTit, {|| nOpc := 2, oDlgTit:End() },40,12,,,,.T.)
   oBtnImpr := tButton():New(170,210,'Cancelar'  ,oDlgTit, {|| oDlgTit:End() },40,12,,,,.T.)
   oBtnSair := tButton():New(170,260,'OK    '    ,oDlgTit, {|| nOpc := 1, oDlgTit:End() },40,12,,,,.T.)


   ACTIVATE MSDIALOG oDlgTit CENTERED


   If nOpc == 2
      fEdmails(cArquivo)
   Elseif   nOpc == 1

      cDest := alltrim(cDest)
      For i := 1 to Len(aTitulo)
         If aTitulo[i][1] = .T.
            If Empty(cDest)
               cDest := cDest + alltrim(Atitulo[i][2])
            Else
               cDest := cDest +";"+ alltrim(Atitulo[i][2])
            Endif
         Endif
      Next
      If Len(cDest) < 300
         cDest := cDest + Space(300-Len(cDest))
      Endif
   EndIf

Return

//============================ Inverte a seleção ============================//
Static Function fSelectAll()
Local i := 0
   For i:=1 to Len(aTitulo)
      aTitulo[i,1] := !aTitulo[i,1]
   Next i

   oBrwTit:Refresh()

Return

//**********************************
// Edita Emails do Compra
Static Function fEdmails(parArq)
   local nOp := 0
   Local oDlg
   local cMemoMail := "Vazio" //Memoread(parArq) //"xxxxxxxxxxxxxxxxxxxxxxxxxxx" //"Abix Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME
   local oGrpMemo

   if ! File(parArq)
      Alert("=>Arquivo não existe:"+parArq)
   Else
//   alert( "ARQUIVO:=>"+parArq)
      cmemoMail := memoread(parArq)
   Endif

   if empty(cmemoMail)
      cmemoMail := "Vazio"
   endif

   DEFINE DIALOG oDlg TITLE "E-mails do Compra" FROM 001,001 TO 250,420 COLOR CLR_BLACK,CLR_WHITE PIXEL

//oSay1     := tSay():New(012,010,{|| "De: " },oDlgMail,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
//oGet1     := TGet():New(010,060,{|u| if(PCount()>0,cRemet:=u,cRemet)}, oDlgMail,140,9,,,,,,,,.T.,,,,,,,.F.,,,'cRemet')
//
//oSay2     := tSay():New(027,010,{|| "Para: " },oDlgMail,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
//oGet2     := TGet():New(025,060,{|u| if(PCount()>0,cDest:=u,cDest)}, oDlgMail,140,9,,,,,,,,.T.,,,,,,,.F.,,,'cDest')
//

   oGrpMemo  := tGroup():New(001,010,105,199,"E-mails do Compra",oDlg,CLR_HBLUE,,.T.)

   oMemoMail:= tMultiget():New(001,010,{|u|if(Pcount()>0,cMemoMail:=u,cMemoMail)},oGrpMemo,190,103,,.T.,,,,.T.)
   oMemoMail:EnableVScroll(.T.)
   oMemoMail:EnableHScroll(.T.)

//oBtVis := tButton():New(110,070,'Visualizar' ,oDlgMail,{|| fVisual() },40,12,,,,.T.)
   oBtOK  := tButton():New(110,115,'Cancela'     ,oDlg,{|| oDlg:End() },40,12,,,,.T.)
   oBtCan := tButton():New(110,160,'OK'          ,oDlg,{|| nOp:=1,oDlg:End() },40,12,,,,.T.)

   ACTIVATE DIALOG oDlg CENTERED


   If nOp == 1
      memowrit(parArq,cMemoMail)
      Alert("Arquivo de Email do Compras Gravado Com Sucesso => " +parArq)
   Endif
//



//**************************
// Function F_Geravet()
// retorna array contendo cada linha arquivo
// usando funcoes do protheus
Static Function F_GeraVet(cArquivo)
   Local nTamLinha := 0 , vet := {} , cLinha := ""

   FT_FUse (cArquivo)

   nTamLinha := Len (FT_FREADLN())

   FT_FGOTOP()
   while !FT_FEOF()
      cLinha := FT_FREADLN()
      if (Empty(cLinha))
         FT_Fskip() ; Loop
      endif
      AADD(vet,{.F.,cLinha })
      FT_Fskip()
   enddo

Return vet

//**************************
// Function F_Geravet2()
// retorna array contendo cada linha de um arquivo
// usando  a funcao AT achando pelo chr(10)                   
/*
Static Function F_GeraVet2(cArquivo)
       Local aTitulo := {} , cArq := "" , pos := 0 , cEmail := ""
       
   If File(cArquivo)
    cArq := MemoRead(cArquivo)                        
      If Empty(cArq)
       AADD(aTitulo,{.F., "Arquivo Vazio"})                                                                               
      Else
         If chr(13) $ cArq // tira o chr(13) pois esta se referenciando como linha somente o chr(10)
          cArq := Strtran(chr(13), cArq ,"")
         Endif
  
         do while .t.
          
          pos := At( chr(10),cArq,1 )  
            If pos = 0
               If ! Empty(cArq)
                AADD(aTitulo,{.F., cArq } )     
               Endif
             exit
            Endif
      
          cEmail := Substr(cArq,1,pos-1)
       
          AADD(aTitulo,{.F., cEmail } )     
                                                                                             
          cArq := Subst(cArq,pos+1,Len(cArq))
           
         enddo

       aTitulo := ASort(aTitulo, , , {|x,y|x[2] < y[2]})
      Endif
   Else
    AADD(aTitulo,{.F., "none"})                                                                               
   Endif

return aTitulo
*/



//**************************
// Function F_Geravet2()
// retorna array contendo cada linha de um arquivo
// usando  memoline   (parou de funcionar)
/*
Static Function F_GeraVet3(cArquivo)
Local aTitulo := {} , cArq := "" , pos := 0 ,  i :=0

If File(cArquivo)

	cArq := MemoRead(cArquivo) 
	For i := 1 to mlcount(cArq)

		If ! Empty(memoline(cArq,100,i))
			AADD(aTitulo,{.F.,memoline(cArq,100,i)} ) 
		Endif
	Next
	aTitulo := ASort(aTitulo, , , {|x,y|x[2] < y[2]})

Else
	AADD(aTitulo,{.F., "none"})
Endif
return aTitulo
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

   Local aArea		:= GetArea()
   Local aAreaSC7	:= SC7->(GetArea())
   Local cValid		:= ""
   Local nPosRef		:= 0
   Local nItem		:= 0
   Local cItemDe		:= IIf(cItem==Nil,'',cItem)
   Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
   Local cRefCols	:= ''
   DEFAULT cSequen	:= ""
   DEFAULT cFiltro	:= ""

   dbSelectArea("SC7")
   dbSetOrder(1)
   If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
      MaFisEnd()
      MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
      While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
            SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

         // Nao processar os Impostos se o item possuir residuo eliminado
         If &cFiltro
            dbSelectArea('SC7')
            dbSkip()
            Loop
         EndIf

         // Inicia a Carga do item nas funcoes MATXFIS
         nItem++
         MaFisIniLoad(nItem)
         dbSelectArea("SX3")
         dbSetOrder(1)
         dbSeek('SC7')
         While !EOF() .AND. (X3_ARQUIVO == 'SC7')
            cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
            cValid	:= StrTran(cValid,"'",'"')
            If "MAFISREF" $ cValid
               nPosRef  := AT('MAFISREF("',cValid) + 10
               cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
               // Carrega os valores direto do SC7.
               MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
            EndIf
            dbSkip()
         End
         MaFisEndLoad(nItem,2)
         dbSelectArea('SC7')
         dbSkip()
      End
   EndIf

   RestArea(aAreaSC7)
   RestArea(aArea)

Return .T.


 /*/{Protheus.doc} MT120FIM
   PE utilizado para enviar email ao apos inclusao de PC para aprovadores.
   @type  Function
   @author Henrique
   @since 07/04/2019
   @version version
   @param  
   @return empty
   @example
   
   @see (links_or_references)
   /*/


USER FUNCTION MT120FIM()
Local lEnvmail := SuperGetMv("AB_EMAIPC",.T.,.F.)
Local cObsAdic := " "
private cTipo  := "PC"
private cNumPC := SC7->C7_NUM
private cFilialPC := SC7->C7_FILIAL

     
// PESQUISA  SCR PARA VER SE ESTA PENDENTE DE LIBERAÇÃO, SE SIM ENVIA EMAIL.
	IF inclui  .and.   PARAMIXB[3] == 1  //.OR. altera
      DbSelectArea("SCR")
      SCR->(DbSetOrder(1))
      If SCR->(DbSeek(cFilialPC+cTipo+cNumPC))
         if lEnvmail
            COM002(cObsAdic)
         endif
      Else
         // valida valo e se nao foi gerado aprovação
         u_validaApr()
         If SCR->(DbSeek(cFilialPC+cTipo+cNumPC))
            if lEnvmail
               COM002(cObsAdic)
            endif
         endif   
      EndIf
   endif   
   If altera  .and.   PARAMIXB[3] == 1 
      If SCR->(DbSeek(cFilialPC+cTipo+cNumPC))
         if empty(cabxaltite)
            cabxaltite := "Não identificado qual a alteração realizada"
         endif
         COM002(cabxaltite)
      Else
      // valida valo e se nao foi gerado aprovação
         u_validaApr() 
         If SCR->(DbSeek(cFilialPC+cTipo+cNumPC))
            if empty(cabxaltite)
               cabxaltite := "Não identificado qual a alteração realizada"
            endif
            COM002(cabxaltite)
         endif
      endif
   
   endif 
   
Return()

	
Static Function COM002(cObsAdic,cFilialPC,cNumPC,cTipo)

Local nOpca       := 0

Local cServer     := cAccount := cFrom := cTo := cPassword := cAssunto  := cMensagem := cAttach := ""
Local cCompEmail  :=  GetSrvProfString("Startpath","")+"docs_abix/comprasemailenv.html"   //grava ultimos emails enviados                                           
Local cEmailsEnv  :="" , cEnvPara := "" , lEnvia := .F. 
Local _cEnvia		:= GETMV("AB_XLPC")
Private cHtml     := ""
Private cMemoMail := ""
//Private cRemet    := "compras.suporte@abix.com.br"  //ALLTRIM(UsrRetMail(RETCODUSR())) + SPACE(100-Len(ALLTRIM(UsrRetMail(RETCODUSR()))))
Private cRemet    := "compras.suporte@abix.com.br "  + SPACE(80)
Private cDirWeb   := ALLTRIM(GETMV("AB_DOCSWEB"))
Private cDest     := ""  
Private cDestMsg := "pipa@abix.com.br"
Private cFromMsg := "compras.suporte@abix.com.br" //"pipa@abix.com.br"    
Private cSolicit := " "
Private cEmsolic := " "
Private cEmiped := " "
Private cEmiEma := " " 
Private cObscomp := " "

Private _cAssunSol := ""

Private _lEnvMSol := SuperGetMv("AB_ENVMSOL",.F.,.F.)

//cAuxDest := cDest // guardar sem o email do fornecedor

cDest := cDest + Space(300-Len(cDest))                         

cMemoMail:=cMemoMail := "Abix Pedido de Compra: "+ SC7->C7_NUM + " - " + SA2->A2_NOME


// busca email dos aprovadores
DbSelectArea("SCR")
SCR->(DbSetOrder(1))
SCR->(DbSeek(SC7->C7_FILIAL+"PC"+ SC7->C7_NUM ))

   While !SCR->(eof())  .And. SCR->CR_FILIAL = xFilial("SCR") .And.    SCR->CR_TIPO =="PC"  .And. SCR->CR_NUM = SC7->C7_NUM

   _aRetUsr := U_GetUsInf(1,SCR->CR_USER,1,{4,14})
   
   cDest += _aRetUsr[2]+";"

   SCR->(DBSKIP())                  
   enddo

cDest +=  _cEnvia

// conout("email  de liberacao enviado para " +  cDest)

//msgalert("email  de liberacao enviado para " +  cDest)
//cDest := "Henrique@abix.com.br"

   If empty(SC7->C7_NUMSC)
	   _aRetUsr := U_GetUsInf(1,SC7->C7_USER,1,{4,14}) 
	   cSolicit := _aRetUsr[1]
	   cEmsolic := _aRetUsr[2]
	   cEmiped  := _aRetUsr[1]
	   cEmiEma  := _aRetUsr[2]
   Else
	    // Alltrim(POSICIONE("SC1",6, XFILIAL("SC1")+SC7->C7_NUM ,"C1_SOLICIT"))    // posiciona no primeiro item apesar de poder ter varios itens (o mesmo solic é replicado na SC1)   
		dbSelectArea("SC1")
		dbSetOrder(1)
      	
      	If SC1->(DBSEEK(XFILIAL("SC1")+SC7->C7_NUMSC))
   
	      _aRetUsr := U_GetUsInf(1,SC1->C1_USER,1,{4,14}) 
	      cSolicit := _aRetUsr[1]
	      cEmsolic := _aRetUsr[2]      
	      
	      _aRetUsr := U_GetUsInf(1,SC7->C7_USER,1,{4,14}) 
	     // _aRetUsr := U_GetUsInf(1,'000154',1,{4,14}) 
	      cEmiped := _aRetUsr[1]
	      cEmiEma := _aRetUsr[2]
	      
      	Endif
      	
   Endif

   cNomFor := POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE +SC7->C7_LOJA,"A2_NOME")
   cUpdSCR := "update scr010 set  CR_CLIEFOR  ='"+cNomFor+"'  where cr_num ='"+SC7->C7_NUM+" ' and d_e_l_e_t_ =' '"
   If TCSQLEXEC(cUpdSCR) <> 0
      aviso("",cUpdSCR,{"ok"},3)
   Endif

	cObscomp += " Emissor da Solicitação de Compras: "+cSolicit+"<br>"
	cObscomp += " E-mail: "+cEmsolic+"<br>"
	cObscomp += " <br>"
	cObscomp += " Emissor do Pedido de Compras: "+cEmiped+"<br>"
	cObscomp += " E-mail: "+cEmiEma+"<br>"

	cObscomp +=   cObsAdic
	cHtml :=fGeraHtml()

	cFrom := cRemet
	cTo   := cDest

	If empty(cObsAdic)
		cAssunto := "APROVAR - Pedido de Compra ABIX - Nº"+ SC7->C7_NUM+ " - " +alltrim(SA2->A2_NOME) + "  Solic: "+  cSolicit
		_cAssunSol := "Pedido de Compra ABIX - Incluído - Nº"+ SC7->C7_NUM+ " - " +alltrim(SA2->A2_NOME) + "  Solic: "+  cSolicit
	Else 
		cAssunto := "APROVAR (Alteração) - Pedido de Compra ABIX - Nº"+ SC7->C7_NUM+ " - " +alltrim(SA2->A2_NOME) + "  Solic: "+  cSolicit
		_cAssunSol := "Pedido de Compra ABIX - Alterado - Nº"+ SC7->C7_NUM+ " - " +alltrim(SA2->A2_NOME) + "  Solic: "+  cSolicit 		   				
	EndIf
	
	// Alltrim(POSICIONE("SC1",6, XFILIAL("SC1")+SC7->C7_NUM ,"C1_SOLICIT"))    // posiciona no primeiro item apesar de poder ter varios itens (o mesmo solic é replicado na SC1)   
	                  
	cMensagem := cHtml // cMemoMail
	cAttach   := ""

   If U_MailTo(cDest,cAssunto , cMensagem , {}, cFrom )
   		//ApMsgInfo("E-mail enviado com sucesso!","[ABIX_PE_MATA120] - OK")
   		If _lEnvMSol
   			If !empty(cEmsolic)
				U_MailTo(cEmsolic,_cAssunSol , cMensagem , {}, cFrom )
			EndIf	
		EndIf	
   Else
	   MsgStop("Erro ao Enviar E-mail ABIX_PE_MATA120 , Avise ao TI ")
	   cMsg := SC7->C7_NUM+ ' Problemas com envido de e-mail para liberação '
		cAssmsg := "Pedido de compras " + SC7->C7_NUM +" Nao foi enviado, verifique "
	   //	EnvMailRet(cMsg, cAssmsg, cDestMsg, cFromMsg, .T.)
	   U_MailTo(cDestMsg,  cAssmsg  ,cMsg , {} , cFromMsg )
   Endif
   
Return


USER FUNCTION MT120GRV()
Local atArea	:= GetArea()
Local lInclui  := PARAMIXB[2]
Local lAltera  := PARAMIXB[3]
Local lExclui  := PARAMIXB[4]
Local lRet := .T.
Local Asc7 :={}
Local cObsAdic :=""
Local cObsnewitem :=""
Local i := 0
Local N := 0
Local H := 0
Local lEnvmail := SuperGetMv("AB_EMAIPC",.T.,.F.)
private nNewRecno := SC7->(RECNO())    
private nOldRecno 
private cNum     := PARAMIXB[1]


private cTipo  := "PC"
private cNumPC := " "
private cFilialPC := " "
Public  cabxaltite :=" "

IF lInclui // Ajusta grupo 
      // criar variavel publica 
  nPosNSC    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_NUMSC"})
  nPosGRcomp    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_APROV"})

// validar se item 1 nao esta deletado,  pega o proximo // ver conforme demanda. 
   IF !empty(acols[1,nPosNSC])      
      dbSelectArea("SC1")
      dbSetOrder(1)
      SC1->(DBSEEK(XFILIAL("SC1")+acols[1,nPosNSC]))
      // pega grupo do solicitante  a base é sempre o primeiro item.
      dbSelectArea("SY1")
      SY1->(DbSetOrder(3))  
      If SY1->(DbSeek(Xfilial("SY1")+SC1->C1_USER))
         if !empty(SY1->Y1_GRAPROV)
            For i := 1 to Len(aCols)  
               acols[i,nPosGRcomp] :=   SY1->Y1_GRAPROV
            next
         endif
      endif 
   else
      // caso nao tenha solicitação de compras, pega grupo de quem esta incluindo o pedido.
      dbSelectArea("SY1")
      SY1->(DbSetOrder(3))
      If SY1->(DbSeek(Xfilial("SY1")+__cuserid))
         if !empty(SY1->Y1_GRAPROV)
            For i := 1 to Len(aCols)  
               acols[i,nPosGRcomp] :=   SY1->Y1_GRAPROV
            next
         endif
      endif    
   endif   

endif


//..customizacao do clienteReturn lRet
IF lAltera // ALTERAÇÃO NAO CONCLUI
   if lEnvmail
      DbSelectArea("SC7")
      DBSETORDER(1)
      DBSEEK(xFilial("SC7") + cNum ) 
      cNumPC := SC7->C7_NUM
      cFilialPC := SC7->C7_FILIAL   
         nOldRecno := SC7->(RECNO())          

      For i := 1 to Len(aCols)  
      if aCols[i,LEN(aCols[i])]  // item apagado
         cObsnewitem +="Excluido item: "+ acols[i,1] +" ao pedido <br>""
      loop 
      endif

         DbSelectArea("SC7")
         DBSETORDER(1)
         if( DBSEEK(xFilial("SC7") + cNum + aCols[i,1] ))
            For N := 1 to Len(AHEADER)  
               nPos := fieldpos(AHEADER[N,2]) // VERIFICA SE EXISTE NO BANCO DE DADOS

               IF nPos > 1 
               // VALIDA CAMPOS 
                  IF acols[i,n]  <> SC7->&(AHEADER[n,2])
                     AADD(Asc7,{acols[i,1] ,AHEADER[n,1]  ,SC7->&(AHEADER[n,2]), acols[i,n] }) // validar titulo do campo
                  ENDIF
               ENDIF
            next
         else
            cObsnewitem +="Adicionado item: "+ acols[i,1] +" ao pedido <br>""
         endif
      next

      if len(Asc7) >0
         cObsAdic :=' <font color="red"> '
         cObsAdic +="Campo Alterados: <br>"
         citem :="0000"
         For H := 1 to Len(Asc7) 
            if  citem <>Asc7[H,1]
               cObsAdic +="Item : "+Asc7[H,1]+" <br>"
            endif
            If ValType(Asc7[H,3]) == "C"
                  cObsAdic += "Campo: "+ PADR(Asc7[H,2],15) +  " De: " +  Alltrim(Asc7[H,3])     + " Para: "   + Alltrim(Asc7[H,4]) +    "<br>"
               Elseif ValType(Asc7[H,3]) == "D"
                  cObsAdic += "Campo: "+ PADR(Asc7[H,2],15) +  " De: " + Dtoc(Asc7[H,3])         + " Para: "   +Dtoc(Asc7[H,4]) +    "<br>"
               Elseif ValType(Asc7[H,3]) == "N"
                  cObsAdic += "Campo: "+ PADR(Asc7[H,2],15) +  " De: " + Alltrim(Str(Asc7[H,3])) + " Para: "   + Alltrim(Str(Asc7[H,4])) +    "<br>"
               Else
               //	MsgAlert('Avisar o TI gravação de Log campo Logico - AFAT501 LINHA 119')
            Endif  
            citem := Asc7[H,1] 
         next 
         // condicao de pagamento
         if ccondpold <> ccondicao
            cObsAdic += "Campo: Condicao de pagamento  De: " + ccondpold + " Para: "   + ccondicao +    "<br>"
         endif
         cObsAdic +='</font>'
      endif
      
     

      if !empty(cObsnewitem)
         cObsAdic += ' <font color="red"> '+cObsnewitem + '</font>'
         
      EndIf
   
      cabxaltite := cObsAdic

      dbSelectArea("SC7")
      dbgoto(nOldRecno)

      //Monta Html e Envia por email 
      // U_ABXCOM003(cObsAdic,cFilialPC,cTipo,cNumPC)
      //COM002(cObsAdic)

   
      dbSelectArea("SC7")
      If nNewRecno <> 0
         dbgoto( nNewRecno )
      Endif
   EndIf
EndIf

RestArea(atArea)

return (.T.)



User Function ABXCOM003(cObsAdic,cFilialPC,cTipo,cNumPC)


Local cServer     := cAccount := cFrom := cTo := cPassword := cAssunto  := cMensagem := cAttach := ""
Local cCompEmail  :=  GetSrvProfString("Startpath","")+"docs_abix/comprasemailenv.html"   //grava ultimos emails enviados                                           
Local cEmailsEnv  :="" , cEnvPara := "" , lEnvia := .F. 
Local _cEnvia		:= GETMV("AB_XLPC")
Private cHtml     := ""
Private cMemoMail := ""
//Private cRemet    := "compras.suporte@abix.com.br"  //ALLTRIM(UsrRetMail(RETCODUSR())) + SPACE(100-Len(ALLTRIM(UsrRetMail(RETCODUSR()))))
Private cRemet    := "compras.suporte@abix.com.br "  + SPACE(80)
Private cDirWeb   := ALLTRIM(GETMV("AB_DOCSWEB"))
Private cDest     := ""  
Private cDestMsg := "pipa@abix.com.br"
Private cFromMsg := "compras.suporte@abix.com.br" //"pipa@abix.com.br"    
Private cSolicit := " "
Private cEmsolic := " "
Private cEmiped := " "
Private cEmiEma := " " 
Private cObscomp := " "
cAuxDest := cDest // guardar sem o email do fornecedor

cDest := cDest + Space(300-Len(cDest))                         

cMemoMail:=cMemoMail := "Abix Pedido de Compra: "+ cNum + " - " + SA2->A2_NOME
 
//MsgAlert("Abix Pedido de Compra: "+ cNum + " - " + SA2->A2_NOME)

// busca email dos aprovadores
DbSelectArea("SCR")
SCR->(DbSetOrder(1))
SCR->(DbSeek(SC7->C7_FILIAL+"PC"+ cNum ))

   While !SCR->(eof())  .And. SCR->CR_FILIAL = xFilial("SCR") .And.    SCR->CR_TIPO =="PC"  .And. SCR->CR_NUM = cNum

   _aRetUsr := U_GetUsInf(1,SCR->CR_USER,1,{4,14})
   
   cDest += _aRetUsr[2]+";"

   SCR->(DBSKIP())                  
   enddo

cDest +=  _cEnvia

// conout("email  de liberacao enviado para " +  cDest)

//msgalert("email  de liberacao enviado para " +  cDest)
//cDest := "Henrique@abix.com.br"

   if empty(SC7->C7_NUMSC)
   _aRetUsr := U_GetUsInf(1,SC7->C7_USER,1,{4,14}) 
 //_aRetUsr := U_GetUsInf(1,'000154',1,{4,14}) 
   cSolicit := _aRetUsr[1]
   cEmsolic := _aRetUsr[2]
   cEmiped  := _aRetUsr[1]
   cEmiEma  := _aRetUsr[2]
   else
  // Alltrim(POSICIONE("SC1",6, XFILIAL("SC1")+SC7->C7_NUM ,"C1_SOLICIT"))    // posiciona no primeiro item apesar de poder ter varios itens (o mesmo solic é replicado na SC1)   
   dbSelectArea("SC1")
	dbSetOrder(1)
      if SC1->(DBSEEK(XFILIAL("SC1")+SC7->C7_NUMSC))
   
      _aRetUsr := U_GetUsInf(1,SC1->C1_USER,1,{4,14}) 
      cSolicit := _aRetUsr[1]
      cEmsolic := _aRetUsr[2]      
      
      _aRetUsr := U_GetUsInf(1,SC7->C7_USER,1,{4,14}) 
    //_aRetUsr := U_GetUsInf(1,'000154',1,{4,14})
      cEmiped := _aRetUsr[1]
      cEmiEma := _aRetUsr[2]
      endif
   endif



cObscomp += " Emissor da Solicitação de Compras: "+cSolicit+"<br>"
cObscomp += " E-mail: "+cEmsolic+"<br>"
cObscomp += " <br>"
cObscomp += " Emissor do Pedido de Compras: "+cEmiped+"<br>"
cObscomp += " E-mail: "+cEmiEma+"<br>"

cObscomp +=   cObsAdic
cHtml :=fGeraHHtml()

cFrom := cRemet
cTo   := cDest


cAssunto := "APROVAR (Alteração) - Pedido de Compra ABIX - Nº"+ SC7->C7_NUM+ " - " +alltrim(SA2->A2_NOME) + "  Solic: "+  cSolicit
// Alltrim(POSICIONE("SC1",6, XFILIAL("SC1")+SC7->C7_NUM ,"C1_SOLICIT"))    // posiciona no primeiro item apesar de poder ter varios itens (o mesmo solic é replicado na SC1)   

                  
cMensagem := cHtml // cMemoMail
cAttach   := ""

   If U_MailTo(cDest,cAssunto , cMensagem , {}, cFrom )
   //ApMsgInfo("E-mail enviado com sucesso!","[ABIX_PE_MATA120] - OK")
   Else
   MsgStop("Erro ao Enviar E-mail ABIX_PE_MATA120 , Avise ao TI ")
   cMsg := SC7->C7_NUM+ ' Problemas com envido de e-mail para liberação.'
	cAssmsg := "Pedido de compras " + SC7->C7_NUM +" Nao foi enviado, verifique. "
   //	EnvMailRet(cMsg, cAssmsg, cDestMsg, cFromMsg, .T.)
   U_MailTo(cDestMsg,  cAssmsg  ,cMsg , {} , cFromMsg )

   Endif
return



//==================================================== LAYOUT HTML =================================================//


Static Function fGeraHHtml()
   Local cRet := "" , cBody := "" , cNum := 0
   Local TxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
   Local cTipoFrete := ""
   Local nTotIcms :=  nTotIpi := nTotDesp := nTotFrete	:= nTotalNF	:= nTotSeguro:= nTotNF := nTotIRet := 0
   Local aValIVA  := NIL , nTotal := 0
   Local cFiltro  := ""
   Local cDscriB1:= " "
   Local nDescProd := 0
   Local cCondPgt := ""
   Local cObs := ""
   Local cReajuste := ""
   Local nOldReg := 0
   Local lIniMaFis := .F.
   Local nA := 0

   Local nPosfrete   := aScan( aHeader,{|x| AllTrim(x[2])=="C7_VALFRE"})
   Local nPosVicm    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_VALICM"})
   Local nPosvIpi    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_VALIPI"})
   Local nPosProd    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_PRODUTO"})
   Local nPosUn    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_UM"}) 
   Local nPosQtd    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_QUANT"}) 
   Local nPosPrc    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_PRECO"})
   Local nPosIpi    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_IPI"})
   Local nPosTot    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_TOTAL"})
   Local nPosCc    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_CC"})
   Local nPosNSC    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_NUMSC"})
   Local nPosdtent    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_DATPRF"})
   Local _cLogoWeb  := Alltrim(SuperGetMv("AB_LOGOWEB",.F.,"https://www.abix.com.br/images/logo_tecnologia.png"))
//Local lIniMaFis := .T.

// Logo Abix   

   cBody+= "<table  border='0' cellpadding='0' cellspacing='0' width='800'>"
   cBody+= "       <tbody>"
  
   //cBody+= "            <div ><img src='https://www.abix.com.br/images/logo_tecnologia.png'></div><br>"
   cBody+= "            <div ><img src='"+_cLogoWeb+"'></div><br>"
  
   cBody+= "        </tbody>"
   cBody+= "</table>"
// Cabeçalho do Usuário
   cBody+= "<div >"
   cBody+= cMemoMail+"<br>"

// Dados da Abix 
   cBody+= Repl("_",100) + "<br><br>"
   cBody+= " <br>Comprador: <br>"
   cBody+= padr(SM0->M0_NOMECOM,70)  + " Departamento de Compras <br>"
   cBody+= padr(SM0->M0_ENDENT,70)   + ' <a class="moz-txt-link-abbreviated" href="">' + alltrim(cRemet) + "</a> <br>"
   cBody+= "Cep: "+SM0->M0_CEPENT + " - "+ alltrim(SM0->M0_CIDENT) + " - " + SM0->M0_ESTENT + "<br>"
   cBody+= "Fone: "+SM0->M0_TEL + " - "+IIF(!EMPTY(SM0->M0_FAX),SM0->M0_FAX,'') + "<br>"
   cBody+= "Cnpj/Cpf: "+Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) + " IE: "+SM0->M0_INSC + "<br><br>"
   cBody+= Repl("_",100) + "<br><br>"

// Dados do Fornecedor

   cBody+= "Fornecedor: <br>"
   cBody+= alltrim(SA2->A2_NOME) + "    CNPJ/CPF: "+SA2->A2_CGC + "   IE: " + SA2->A2_INSCR + "<br>"
   cBody+= alltrim(SA2->A2_END)  + " - "+alltrim(SA2->A2_BAIRRO) +"<br>"
   cBody+= alltrim(SA2->A2_MUN) + "-" + SA2->A2_EST + "  Contato: "+ SC7->C7_CONTATO  + "<br>"
   cBody+= "Fone: ("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + "  Fax: ("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_FAX,1,15) + "<br>"
   cBody+= Repl("_",100) + "<br><br>"

//dados da itens da nota

//cBody+= "<FONT SIZE=2>" 
cBody+= "<br>Produtos: <br>
cBody+= "<table>
cBody+= "	<tr class='itens'>
cBody+= "		<td class='itens'>Item</td><td class='itens'>Codigo</td><td class='itens'>Descricao do Material</td><td class='itens'>UM</td><td class='itens'>Quant</td><td class='itens'>Val. Unitario</td><td class='itens'>IPI</td><td class='itens'>Val. Total</td><td class='itens'>Entrega</td><td class='itens'> C.C./S.C.</td>
cBody+= "	</tr>

   cNum := SC7->C7_NUM

// Posiciona no primeiro
   dbSelectArea("SC7")
   nOldreg := Recno()
   dbSetOrder(1)
   dbSeek(xFilial("SC7")+SC7->C7_NUM,.T.)

   DbSelectArea("SX5")
   nOldSX5 := Recno()   
   DbSetOrder(1)
   DbSeek(xFilial("SX5") +"24"+ SC7->C7_FORMAPG)

// Acha cond pgto
   dbSelectArea("SE4")
   nOldSE4 := Recno()
   dbSetOrder(1)
   dbSeek(xFilial("SE4")+SC7->C7_COND)

   cCondPgt  := SubStr(SE4->E4_DESCRI,1,40)+" ("+alltrim(SubStr(SE4->E4_COND,1,40))+")" + " Forma Pg: "+ SC7->C7_FORMAPG + " - "+ AllTrim(SX5->X5_DESCRI)

   cReajuste := SC7->C7_REAJUST
   cTipoFrete := IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))

   For nA := 1 to Len(aCols)  
      IF  !aCols[nA,LEN(aCols[nA])]    
         _cdescri:=alltrim(aCols[nA,3])

       /*  cBody+= aCols[nA,1] +  " "+ aCols[nA,nPosProd] + " "+left(_CDESCRI,30) + "  "+aCols[nA,nPosUn] + ;
            Transform(aCols[nA,nPosQtd] ,PesqPictQt("C7_QUANT",13)) + ;
            Transform(aCols[nA,nPosPrc] ,PesqPict("SC7","C7_PRECO",16)) + " "+ ;
            Transform(aCols[nA,nPosIpi],PesqPictQT("C7_IPI",5)) +  ;
            Transform(aCols[nA,nPosTot],PesqPict("SC7","C7_TOTAL",16)) + " "+ ;
            Dtoc(aCols[nA,nPosdtent]) + " "+ ;
            alltrim(Transform(aCols[nA,nPosCc],PesqPict("SC7","C7_CC",20))) + " "+ ;
            alltrim(aCols[nA,nPosNSC])+ "<br>"
*/
         cBody+= "  <tr>
         cBody+= " <td class='Subitens'>"+aCols[nA,1]+"</td><td class='Subitens'>"+aCols[nA,nPosProd]+"</td><td class='Subitens'>"+left(_CDESCRI,30)+"</td>  <td class='Subitens'>"+aCols[nA,nPosUn]+" </td><td class='Subitens'>"+Transform(aCols[nA,nPosQtd] ,PesqPictQt("C7_QUANT",13)) +"</td><td class='Subitens'>"+Transform(aCols[nA,nPosPrc] ,PesqPict("SC7","C7_PRECO",16))+"</td><td class='Subitens'>"+Transform(aCols[nA,nPosIpi],PesqPictQT("C7_IPI",5))+"  </td><td class='Subitens'>"+Transform(aCols[nA,nPosTot],PesqPict("SC7","C7_TOTAL",16))+" </td><td class='Subitens'>"+Dtoc(aCols[nA,nPosdtent])+"</td><td class='Subitens'>"+alltrim(aCols[nA,nPosNSC])+" </td>
	      cBody+= "</tr>



         If ! empty(Substr(_CDESCRI,31,len(_CDESCRI)))
            cBody+= Space(20) +Substr(_CDESCRI,31,Len(_CDESCRI) ) + "<br>"
         Endif


         If ! empty(aCols[nA,11])
            If ! Empty(cObs)
               cObs += "    "+aCols[nA,11]+"<br>"
            Else
               cObs += aCols[nA,11]+"<br>"
            Endif
         Endif

         nTotal      := nTotal+aCols[nA,nPosTot]
         nTotNF      := nTotNF+aCols[nA,nPosTot]
         nTotIcms    := nTotIcms + aCols[nA,nPosVicm]
         nTotIpi	   := nTotIpi  + aCols[nA,nPosvIpi]
         nTotDesp    := nTotDesp
         nTotIRet	   := nTotIRet

      ENDIF
   NEXT

   cBody+= "</SMALL></SMALL>"
   // valor do frete 
   cQery := " select sum(C7_VALFRE) VLRFRETE from "+RetSqlName('SC7') + " SC7  where  C7_FILIAL ='"+CFILIALENT+"' AND  c7_num='"+CA120NUM+"'  AND D_E_L_E_T_ = ' ' "

   If ( SELECT("TRAB1") ) > 0
	dbSelectArea("TRAB1")
	TRAB1->(dbCloseArea())
EndIf

TCQUERY cQery NEW ALIAS "TRAB1"

nTotFrete := TRAB1->VLRFRETE
if cTipoFrete ==  "C"
   nTotNF  += nTotFrete
endif

   cBody+= Repl("_",100) + "<br><br>"
   cBody+= "Emissão: "+ Dtoc(SC7->C7_EMISSAO)+"    Ipi: "+ Alltrim(Str(nTotIpi,12,2)) + "    Icms: " + Alltrim(Str(nTotICMS,12,2)) + "    Icms Ret: " + Alltrim(Str(nTotIRet,12,2))  +   "<br><br>"
   cBody+= "Frete: "+Alltrim(Str(nTotFrete,12,2)) + " - "+cTipoFrete + "   Descontos: "+ Alltrim(Str(nDescProd,12,2))+"    Despesas: "+Alltrim(Str(nTotDesp,12,2)) + "    Seguro: "+ Alltrim(Str(nTotSeguro,12,2)) + "<br><br>"
   cBody+= "Reajuste:  "  + cReajuste+  "<br><br>"
   cBody+= "Total Mercadoria: "+Alltrim(Str(nTotal,12,2)) + "     Total c/ Impostos: "+Alltrim(Str(nTotNF,12,2)) + ;
      "    <b> Total Geral: "+ Alltrim(Str(nTotNF,12,2)) + "</b><br><br>"
   cBody+= "Cond Pgto.: <b>" + cCondPgt + "</b><br><br>"

   cObs += cObscomp
   cBody+= "Obs: "+ cObs+ "<br>"

   cBody+= Repl("_",100) + "<br><br>"

   cBody+= "<b>"

   cBody+= "End. Entrega : "+ Alltrim(SM0->M0_ENDENT) +"  "+alltrim(SM0->M0_CIDENT)+ "  - "+SM0->M0_ESTENT+ ;
      "  Cep: "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP"))  + "<br><br>"

 //  cBody+= "End. Cobrança: AL AUGUSTO STELLFELD, 1175  CURITIBA  - PR  Cep: 80430-140"+"<br><br>"
   cBody+= "End. Cobrança: Rua COMENDADOR ARAÚJO, 731 LOJA 411 ANDAR L4, CURITIBA  - PR  Cep: 80420-000"+"<br><br>"


//cBody+= "*NOTA: Favor fazer constar o número desta ordem de compra no corpo da nota fiscal. <br>"
//cBody+= "       Os valores desta O.C. tem impostos inclusos. </b><br>"
   If cEmpAnt $ '01|02'
      cBody+= "*NOTA: Favor fazer constar o número desta ordem de compra no corpo da nota fiscal. <br>"
      cBody+= "       Os valores desta ordem de compra tem impostos inclusos. </b><br>"
      cBody+= "       E-mail para envio da Nota Fiscal - <u>fornecedornfe@abix.com.br</u><br>"
      cBody+= "       Informamos que os fornecedores da Abix, são avaliados e pontuados por atendimento,  <br>"
      cBody+= "       pontualidade nas entregas, preço e qualidade dos produtos oferecidos.  <br>"
   Else
      cBody+= "*NOTA: Favor informar na nota fiscal, o numero do pedido de compras. <br>"
      cBody+= "       Endereço Eletronico para envio de Notas Fiscais e Boletos - <u>nfe@motelcelebrity.com.br</u><br>"
   EndIf

   cBody+= "</div>" //"</table>"



   cBody+= Repl("_",100) + "<br>"

// Email
   cRet+= "<html>"
   cRet+= "<head>"
   cRet+= '  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">'
   cRet+= "  <title></title>"
   cRet+= "</head>"
   cRet+= '<body font face=Courier,Bitstream Vera Sans Mono, Luxi Mono text="#000000" bgcolor="#ffffff">'
   cRet+= '<FONT SIZE=5 STYLE="font-size: 10pt">'
   cRet+= '<pre wrap="">'

   cRet += cBody

   cRet+= "</FONT>"
   cRet+= "</span>"
   cRet+= "</body>"
   cRet+= "</html>"

 dbSelectArea("SC7")
   If nOldreg <> 0
      dbgoto( nOldreg )
   Endif

dbSelectArea("SX5")
   If nOldSX5 <> 0
      dbgoto( nOldSX5 )
   Endif

dbSelectArea("SE4")
   If nOldSE4 <> 0
      dbgoto( nOldSE4 )
   Endif

Return(cRet)

/*/{Protheus.doc} ABXGPCOM
    Funcao que retorna o grupo de aprovação do solicitante do pedido de compras
   @type  User Function
   @author Henrique Baldin
   @since /07/2019
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/

USER FUNCTION  ABXGPCOM()
lOCAL cGPCOM := " "
Local nPosNSC    := aScan( aHeader,{|x| AllTrim(x[2])=="C7_NUMSC"})

// validar se item 1 nao esta deletado,  pega o proximo // ver conforme demanda. 
IF !empty(acols[1,nPosNSC])      
   dbSelectArea("SC1")
   dbSetOrder(1)
   SC1->(DBSEEK(XFILIAL("SC1")+acols[1,nPosNSC]))
   // pega grupo do solicitante  a base é sempre o primeiro item.
   dbSelectArea("SY1")
   SY1->(DbSetOrder(3))  
   If SY1->(DbSeek(Xfilial("SY1")+SC1->C1_USER))
      if !empty(SY1->Y1_GRAPROV)
         cGPCOM := SY1->Y1_GRAPROV
      endif
   endif 
  else
   // caso nao tenha solicitação de compras, pega grupo de quem esta incluindo o pedido.
   dbSelectArea("SY1")
   SY1->(DbSetOrder(3))
   If SY1->(DbSeek(Xfilial("SY1")+__cuserid))
      if !empty(SY1->Y1_GRAPROV)
         cGPCOM := SY1->Y1_GRAPROV
      endif
   endif    
endif
Return(cGPCOM)
 

/*
Após a gravação dos pedidos de compras pela analise da cotação e 
antes dos eventos de contabilização, utilizado para os processos de 
workFlow posiciona a tabela SC8 e passa como parametro o numero da cotação.
*/
User Function MT160WF()
Local cObsAdic := " "   
private cTipo  := "PC"
private cNumPC := SC7->C7_NUM
private cFilialPC := SC7->C7_FILIAL

     
// PESQUISA  SCR PARA VER SE ESTA PENTE DE LIBERAÇÃO, SE SIM ENVIA EMAIL.
   DbSelectArea("SCR")
   SCR->(DbSetOrder(1))
   If SCR->(DbSeek(cFilialPC+cTipo+cNumPC))
   //Bloqueado para nao disparar email no analisa cotação   
   //COM002(cObsAdic)
   EndIf
//msgalert("passou por aqui   =D  MT160WF Enviou e-mail.... ")
Return()

User Function ABXC003()
Local nPosCOMP  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_COMPLEM" })
Local nPosDEST  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_DESTINO" })
Local nPosOBS  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_OBS"     })
Local nPosSC  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_NUMSC"     })
Local nPosISC  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_ITEMSC"     })
Local nPosFINALI  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_FINALID" })

IF !EMPTY(aCOLS[N][nPosSC] )
  dbSelectArea("SC1")
   dbSetOrder(1)
   If dbSeek(xFilial("SC1")+aCOLS[N][nPosSC]+aCOLS[N][nPosISC])
      aCOLS[N][nPosCOMP] := SC1->C1_COMPLEM
      aCOLS[N][nPosDEST] := SC1->C1_DESTINO
      aCOLS[N][nPosOBS] := SC1->C1_OBS
       aCOLS[N][nPosFINALI] := SC1->C1_FINALID
   eNDIF
eNDIF 
Return(SC1->C1_FINALID)


//User Function  MT120LOK()
//MSGALERT("MT120LOK")
//Return()


User Function MT120PCOK()
Local nPosAPROV  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_APROV" })
Local nPosSC  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_NUMSC" })
Local lRet :=.T.
Local i := 0

   IF !empty(acols[1,nPosSC])      
      dbSelectArea("SC1")
      dbSetOrder(1)
      SC1->(DBSEEK(XFILIAL("SC1")+acols[1,nPosSC]))
      // pega grupo do solicitante  a base é sempre o primeiro item.
      dbSelectArea("SY1")
      SY1->(DbSetOrder(3))  
      If SY1->(DbSeek(Xfilial("SY1")+SC1->C1_USER))
         For i := 1 to  Len(aCols) 
            if acols[i,nPosAPROV] <>   SY1->Y1_GRAPROV
				U_MailTo("Henrique@abix.com.br", "Ajuste Pedido de compras "+ca120num  , "Ajustado pedido de compras referente a Sc: "+acols[1,nPosSC] +chr(13) + chr(10)+" Alteado grupo de aprvação De " + acols[i,nPosAPROV]+ " Para "+SY1->Y1_GRAPROV) 
				acols[i,nPosAPROV] :=   SY1->Y1_GRAPROV
            endif
         next
      endif 
 /*  else  // se ano tiver SC segue fluxo normal , caso um dia precise validar esta pronto.
      // caso nao tenha solicitação de compras, pega grupo de quem esta incluindo o pedido.
      dbSelectArea("SY1")
      SY1->(DbSetOrder(3))
      If SY1->(DbSeek(Xfilial("SY1")+__cuserid))
         For i := 1 to Len(aCols)  
            acols[i,nPosAPROV] :=   SY1->Y1_GRAPROV
         next
      endif   */ 
   endif
Return(lRet)

User Function MT120APV()
Local cGPCOM :=  SC7->C7_APROV
Local nPosAPROV  := 0
Local nPosSC  := 0
Local lRet :=.T.
Local i := 0
if funname() <> "MATA161"
   nPosAPROV  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_APROV" })
   nPosSC  := AScan(AHEADER,{|x| AllTrim(x[2]) == "C7_NUMSC" })
   IF !empty(acols[1,nPosSC])      
      dbSelectArea("SC1")
      dbSetOrder(1)
      SC1->(DBSEEK(XFILIAL("SC1")+acols[1,nPosSC]))
      // pega grupo do solicitante  a base é sempre o primeiro item.
      dbSelectArea("SY1")
      SY1->(DbSetOrder(3))  
      If SY1->(DbSeek(Xfilial("SY1")+SC1->C1_USER))
        cGPCOM := SY1->Y1_GRAPROV
      endif 
   else  // se ano tiver SC segue fluxo normal , caso um dia precise validar esta pronto.
      // caso nao tenha solicitação de compras, pega grupo de quem esta incluindo o pedido.
      dbSelectArea("SY1")
      SY1->(DbSetOrder(3))
      If SY1->(DbSeek(Xfilial("SY1")+SC7->C7_USER))
         For i := 1 to Len(aCols)  
            cGPCOM :=   SY1->Y1_GRAPROV
         next
      endif     
   endif
endif
 
Return(cGPCOM)

User Function MT120TEL()
Local aArea     := GetArea()
Local oDlg      := PARAMIXB[1] 
Local aPosGet   := PARAMIXB[2]
Local nOpcx     := PARAMIXB[4]
Local nRecPC    := PARAMIXB[5]
Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
Public  cCombo

Public cXObsAux := {'1=SIM','2=NAO'}

//Define o conteúdo para os campos
SC7->(DbGoTo(nRecPC))
If nOpcx == 3
   cCombo := "2"
 //  cXObsAux := CriaVar("C7_XPANUA",.F.)
Else
/*   if SC7->C7_XPANUA =="1"
      cCombo := "1"
   else  
      cCombo := "2"
   endif
*/
EndIf

//Criando na janela o campo OBS
//@ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_XPANUA")) OF oDlg PIXEL SIZE 050,006
@ 062, aPosGet[1,08] - 012 SAY "Pedido Anual" OF oDlg PIXEL SIZE 050,006
@ 061, aPosGet[1,06] - 25 COMBOBOX cCombo ITEMS cXObsAux SIZE 50, 006 OF oDlg COLORS 0, 16777215  PIXEL

 
/*
//Se não houver edição, desabilita os gets
If !lEdit
   cCombo:lActive := .F.
EndIf
*/
RestArea(aArea)
Return


user Function validaApr()
 
   
   cQery :=" SELECT C1_USER,Y1_GRAPROV,SUM(C7_TOTAL)C7_TOTAL "
   cQery +=" FROM "+RetSqlName('SC7')+" SC7 "
   cQery +=" LEFT JOIN "+RetSqlName('SC1')+" SC1 ON C1_FILIAL = C7_FILIAL AND C1_NUM = C7_NUMSC 
   cQery +=" AND C1_PRODUTO = C7_PRODUTO AND SC1.D_E_L_E_T_ =' ' "
   cQery +=" INNER JOIN "+RetSqlName('SY1')+" SY1 ON Y1_USER = C1_USER AND SY1.D_E_L_E_T_ =' ' "
   cQery +=" WHERE C7_NUM ='"+SC7->C7_NUM+" ' "
   cQery +=" AND C7_FILIAL='"+SC7->C7_FILIAL+" ' " 
   cQery +=" AND SC7.D_E_L_E_T_ =' ' "
   cQery +=" GROUP BY C1_USER,Y1_GRAPROV "
     
   
   If ( SELECT("TRAB2") ) > 0
	dbSelectArea("TRAB2")
	TRAB2->(dbCloseArea())
EndIf

TCQUERY cQery NEW ALIAS "TRAB2"
if TRAB2->C7_TOTAL > 1500
   // GERA APROVAÇÃO
   U_AFAT322(sc7->c7_num,"PC",TRAB2->Y1_GRAPROV,.T.,TRAB2->C1_USER,TRAB2->C7_TOTAL)
   // AJUSTA GRUPO APROVAÇÃO
   cNomFor := POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE +SC7->C7_LOJA,"A2_NOME")
   cUpdSCR := "update scr010 set CR_APROV ='"+TRAB2->Y1_GRAPROV+"', CR_CLIEFOR  ='"+cNomFor+"'  where cr_num ='"+sc7->c7_num+" ' and d_e_l_e_t_ =' '"
   If TCSQLEXEC(cUpdSCR) <> 0
      aviso("",cUpdSCR,{"ok"},3)
   Endif
   cDestino :="jair.andrade@abix.com.br"
   cAssunto := "Incluido aprovação manualmente do pedido: " + sc7->c7_num
   cMensagem := "Incluido aprovação manualmente do pedido" + sc7->c7_num + "fornecedor " + cNomFor
   U_MailTo(cDestino, cAssunto, cMensagem )
endif   
return
