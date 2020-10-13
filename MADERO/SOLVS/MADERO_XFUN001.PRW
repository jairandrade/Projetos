/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! XFUN001                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Funcionalidades padrões utilizadas no projeto MADERO                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 27/04/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#Include 'Protheus.ch'
#Include "topconn.ch"
#include "FileIO.ch"
#include "TBICONN.CH"
#include "rwmake.ch"

#define pos_fil  1
#define pos_cod	 2
#define pos_desc 3

#define CRLF chr(13)+CHR(10)


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AIMPSB1                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza cadastro de produtos com os códigos do cliente conforme arquivo de   !
!                  ! Importação passado                                                            !
!                  ! IMPORTANTE: Apenas campos na tabela SB1 por meio de UPDATE                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AIMPSB1()
Local cxFile  :="C:\IMP\SB1"+xFilial("SB1")+".CSV"
Private oRegua

   // -> Verifica se encontro o arquivo
   If File(cxFile)
      
      // -> Processa alteração dos dados do produto 
      oRegua := MsNewProcess():New({ || PUpdSB1(oRegua,cxFile) }, "Processamento dados")
	  oRegua:Activate()
	  FT_FUSE()	  

   Else

      Alert("Não foi possivel abir o arquivo "+cXFile)

   EndIf
   
Return()



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUpdSB1                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa atualização do cadastro de produtos                                  !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function PUpdSB1(oARegua,cxFile)
Local cAux     :=Space(0)
Local cOnde    :=Space(0)
Local cTipo    :=Space(0)
Local cClasse  :=Space(0)
Local cLinha   :=Space(0)
Local aDados   :={}
Local lok      :=.T.

   // Sequencia do layou :B1_COD;B1_XCODEXT;B1_XCDARVP

   // -> Abre o arquivo
   FT_FUSE(cxFile)
   FT_FGOTOP()
   While (!FT_FEof())
  
      // -> Le daos do arquivo     
      cLinha:=FT_FReadLn()
      aDados:=StrTokArr(cLinha,";")
      ConOut("--> Lina: " + cLinha)
      oARegua:SetRegua1(2)
      oARegua:IncRegua1("Lina : " + cLinha)

      // -> Valida dados da Linha
      lok:=!(StrZero(Len(aDados),5,0) <> "00003")
      If !lok
         ConOut("Erro: Estrutura do arquivo (numero de colunas)")   
      EndIf
       
      If lok .and. SubStr(aDados[1],1,3) <> "B1_"

         // -> Posiciona no cadastro de Produtos
         cAux:=AllTrim(aDados[1])
         cAux:=cAux+Space(TamSX3("B1_COD")[1]-Len(cAux))
         DbSelectArea("SB1")
         SB1->(DbSetOrder(1))
         If !SB1->(DbSeek(xFilial("SB1")+cAux))
            ConOut("Erro: Produto não encontrado.)")
            lok:=.F.   
         EndIf
         
         // -> Localiza local onde o produto pertence
         cOnde:=SubStr(SB1->B1_COD,1,1)

         // -> Localiza tipo do Produto na tabela Z2
         cTipo:=SubStr(SB1->B1_COD,2,2)
         DbSelectArea("SX5")
         SX5->(DbSetOrder(1))
         If !SX5->(DbSeek(xFilial("SX5")+"Z2"+cTipo))
            ConOut("Erro: Tipo do poduto nao encontrado [Tabela Z2] )")
            lok:=.F.
         EndIf   
         
         // -> Localiza tipo do Produto na tabela Z3
         cClasse:=SubStr(SB1->B1_COD,4,2)
         DbSelectArea("SX5")
         SX5->(DbSetOrder(1))
         If !SX5->(DbSeek(xFilial("SX5")+"Z3"+cClasse))
            ConOut("Erro: Classe do poduto nao encontrado [Tabela Z3] )")
            lok:=.F.
         EndIf   

         // -> Localiza Unidade de negócio
         If cOnde == "2"
            DbSelectArea("ADK")
            ADK->(DbSetOrder(5))
            If !ADK->(DbSeek(xFilial("ADK")+xFilial("SB1")))
               ConOut("Erro: Unidade de negocio nao encontrada. ")
               lok:=.F.
            EndIf
         EndIf      
         
         // -> Verifica código externo
         If AllTrim(aDados[2]) == ""
            ConOut("Erro: Codigo externo vazio. )")
            lok:=.F.
         EndIf 
         
         // -> Verifica nives do Tekniza (nivel 4) 
         DbSelectArea("Z21")
         Z21->(DbSetOrder(1))
         If !Z21->(DbSeek(xFilial("Z21")+SubStr(AllTrim(aDados[2]),1,8)))
            ConOut("Erro: Nível nao encontrado: "+SubStr(AllTrim(aDados[2]),1,8))
            lok:=.F.
         EndIf
                             
         // -> Se tudo ok, altera dados
         If lok

            Begin Transaction

               // -> Se não encotrar os dados auxiliar do produto, inclui
               If cOnde == "2"
               
                  // -> Atualiza tabela auxiliar
                  DbSelectArea("Z13")
                  Z13->(DbSetOrder(1))
                  If !Z13->(DbSeek(SB1->B1_FILIAL+SB1->B1_COD))
                     RecLock("Z13",.T.)
                     Z13->Z13_COD   :=SB1->B1_COD
                     Z13->Z13_DESC  :=SB1->B1_DESC
                     Z13->Z13_XCODEX:=AllTrim(aDados[2])
                     Z13->Z13_XCDARV:=SubStr(AllTrim(aDados[2]),1,8) 
                     Z13->Z13_XEMP  :=ADK->ADK_XEMP
                     Z13->Z13_XFIL  :=ADK->ADK_XFIL
                     Z13->Z13_XSTINT:="I"
                     Z13->Z13_XDINT :=SB1->B1_DATREF
                     Z13->Z13_XEXC  :="N"
                     Z13->(MsUnlock())   
                  EndIf         
            
               EndIf
               
               // -> Altera dados dos produtos
               RecLock("SB1",.F.)
               SB1->B1_XN1   :=SubStr(AllTrim(aDados[2]),1,1) 
               SB1->B1_XN2   :=SubStr(AllTrim(aDados[2]),2,2)
               SB1->B1_XN3   :=SubStr(AllTrim(aDados[2]),4,2)
               SB1->B1_XN4   :=SubStr(AllTrim(aDados[2]),6,3)
               SB1->B1_XLOCAL:=cOnde
               SB1->B1_XTIPO :=cTipo
               SB1->B1_XCLAS :=cClasse
               Sb1->(MsUnlock())

            End Transaction
	     
	        ConOut("Ok.")

	     Else
	     
	       ConOut("Erro.")
	     
	     EndIf   
	        	
      EndIf   

      FT_FSkip()

   EndDo

Return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AIMPSA5                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza cadastros de produto x fornecedores                                  !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AIMPSA5()
Local cxFile  :="C:\IMP\SA5"+xFilial("SA5")+".CSV"
Private oRegua

   // -> Verifica se encontro o arquivo
   If File(cxFile)
      
      // -> Processa inclusão das amarrações de produtos x fornecedores 
      oRegua := MsNewProcess():New({ || PUpdSA5(oRegua,cxFile) }, "Processamento dados")
	  oRegua:Activate()
	  FT_FUSE()	  

   Else

      Alert("Não foi possivel abir o arquivo "+cXFile)

   EndIf
   
Return()



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUpdSA5                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa amarração de produtos x fornecedores                                 !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function PUpdSA5(oARegua,cxFile)
Local cAux     :=Space(0)
Local cAux1    :=Space(0)
Local aDados   :={}
Local lok      :=.T.
Local PARAMIXB1:={}
Local PARAMIXB2:=3
Local cPathTmp  := "\temp\"
Local cFileErr  := ""
Private lMsErroAuto := .F.

   // Sequencia do layou :A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_CODPRF, A5_UNID, A5_XTPCUNF, A5_XCVUNF, A5_XOPER, A5_CODTAB, A5_CODBAR

   // -> Abre o arquivo
   nLinha:=1
   FT_FUSE(cxFile)
   FT_FGOTOP()
   While (!FT_FEof())
      
      // -> Le daos do arquivo     
      cLinha:=FT_FReadLn()
      aDados:=StrTokArr(cLinha,";")
      ConOut("--> Lina: " + cLinha)
      oARegua:SetRegua1(2)
      oARegua:IncRegua1("Lina : " + cLinha)

      // -> Valida dados da Linha
      //If Len(aDados) < 10
      //	 lok:=.F.
      //   ConOut("Erro: Estrutura do arquivo (numero de colunas)")   
      //EndIf
       
      If lok .and. SubStr(aDados[1],1,3) <> "A5_"

         // -> Posiciona no cadastro de Produtos
         cAux:=AllTrim(aDados[3])
         cAux:=cAux+Space(TamSX3("A5_PRODUTO")[1]-Len(cAux))
         DbSelectArea("SB1")
         SB1->(DbSetOrder(1))
         If !SB1->(DbSeek(xFilial("SB1")+cAux))
            ConOut("Erro: Produto não encontrado.)")   
         EndIf

         // -> Posiciona no cadastro de fornecedor
         cAux :=AllTrim(aDados[1])
         cAux :=cAux+Space(TamSX3("A5_FORNECE")[1]-Len(cAux))
         cAux1:=AllTrim(aDados[2])
         cAux1:=cAux1+Space(TamSX3("A5_LOJA")[1]  -Len(cAux1))
         DbSelectArea("SA2")
         SA2->(DbSetOrder(1))
         If !SA2->(DbSeek(xFilial("SA2")+cAux+cAux1))
            ConOut("Erro: Fornecedor não encontrado.)")   
         EndIf

         // -> Posiciona no cadastro de unidades de medida
         cAux :=AllTrim(aDados[5])
         cAux :=cAux+Space(TamSX3("A5_UNID")[1]-Len(cAux))
         DbSelectArea("SAH")
         SAH->(DbSetOrder(1))
         If !SAH->(DbSeek(xFilial("SAH")+cAux))
            ConOut("Erro: Unidade de medida não encontrada)")   
         EndIf
         
         // -> Tabela de preço
         cAux :=AllTrim(aDados[09])
         cAux :=cAux+Space(TamSX3("A5_CODTAB")[1]-Len(cAux))
         
         // -> Posiciona na tabela de preços
         DbSelectArea("AIB")
         AIB->(DbSetOrder(2))
         If !AIB->(DbSeek(xFilial("AIB")+SA2->A2_COD+SA2->A2_LOJA+cAux+SB1->B1_COD))
            ConOut("Erro: Produto nao encontrado na tabela de preco para o fornecedor)")   
         EndIf
         
         // -> Quantidade
         cAux1 :=IIF(Len(StrTokArr(AllTrim(aDados[07]),','))<2,StrTokArr(AllTrim(aDados[07]),',')[1]+".00",StrTokArr(AllTrim(aDados[07]),',')[1]+"."+StrTokArr(AllTrim(aDados[07]),',')[2])
         
         // -> Verifica se existe a amarração de produtos x forcedores
         //DbSelectArea("SA5")
         //SA5->(DbSetOrder(2))
         //If !SA5->(DbSeek(xFilial("SA5")+SB1->B1_COD+SA2->A2_COD+SA2->A2_LOJA)) 
            PARAMIXB1 := {}	
	        aadd(PARAMIXB1,{"A5_FORNECE",SA2->A2_COD,.F.})	
	        aadd(PARAMIXB1,{"A5_LOJA"   ,SA2->A2_LOJA,.F.})	
	        aadd(PARAMIXB1,{"A5_NOMEFOR",SA2->A2_NOME,.F.})	
	        aadd(PARAMIXB1,{"A5_PRODUTO",SB1->B1_COD,.F.})	
	        aadd(PARAMIXB1,{"A5_NOMPROD",SB1->B1_DESC,.F.})	        
	        aadd(PARAMIXB1,{"A5_CODPRF" ,aDados[04],.F.})	        
            aadd(PARAMIXB1,{"A5_UNID"   ,SAH->AH_UNIMED,})
            aadd(PARAMIXB1,{"A5_XTPCUNF",aDados[06],.F.})
            aadd(PARAMIXB1,{"A5_XCVUNF" ,Val(aDados[07]),.F.})
            aadd(PARAMIXB1,{"A5_XOPER"  ,aDados[08],.F.})
            aadd(PARAMIXB1,{"A5_CODTAB" ,AIB->AIB_CODTAB,.F.})
            aadd(PARAMIXB1,{"A5_CODBAR" ,IIF(Len(aDados)<10,"",aDados[10]),.F.})
	        lMsErroAuto:=.F.
	        MSExecAuto({|x,y| u_AMATA060(x,y)},PARAMIXB1,PARAMIXB2)		
	        // -> Verifica erros
	        If !lMsErroAuto		
	           ConOut("Ok.")		
	        Else		
	           cFileErr := "pv_"+cFilAnt+"_"+StrZero(nLinha,4)+"_"+strtran(time(),":","")
				MostraErro(cPathTmp, cFileErr)
				cFileErr := memoread(cPathTmp+cFileErr)
	           ConOut(cFileErr)
	           	
	        EndIf
	     
	     nLinha := nLinha + 1
	     //Else
	     
	       //ConOut("Ok. Já importado.")
	     
	     //EndIf   
	        	

      EndIf   
      
      FT_FSkip()

   EndDo

Return()


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AIMPZ21                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza de niveis de produtos do TEKNIZA                                     !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AIMPZ21()
Local cxFile  :="C:\IMP\Z21"+AllTrim(xFilial("Z21"))+".CSV"
Private oRegua

   // -> Verifica se encontro o arquivo
   If File(cxFile)
      
      // -> Processa dos nives de produtos do Tekniza 
      oRegua := MsNewProcess():New({ || PUpdZ21(oRegua,cxFile) }, "Processamento dados")
	  oRegua:Activate()
	  FT_FUSE()	  

   Else

      Alert("Não foi possivel abir o arquivo "+cXFile)

   EndIf
   
Return()



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUpdZ21                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa níveis de produtos do Tekniza                                        !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function PUpdZ21(oARegua,cxFile)
Local cAux     :=Space(0)
Local cAux1    :=Space(0)
Local cAux2    :=Space(0)
Local aDados   :={}
Local lok      :=.T.

   // Sequencia do layou :RELACIONAMENTO;COD_NIVEL;NMPRODUTO

   // -> Abre o arquivo
   FT_FUSE(cxFile)
   FT_FGOTOP()
   While (!FT_FEof())
      
      // -> Le daos do arquivo     
      cLinha:=FT_FReadLn()
      aDados:=StrTokArr(cLinha,";")
      ConOut("--> Lina: " + cLinha)
      oARegua:SetRegua1(2)
      oARegua:IncRegua1("Lina : " + cLinha)

      // -> Valida dados da Linha
      lok:=!(StrZero(Len(aDados),5,0) <> "00003")
      If !lok
         ConOut("Erro: Estrutura do arquivo (numero de colunas)")   
      EndIf
       
      If lok .and. SubStr(aDados[1],1,3) <> "REL"

         // -> Posiciona no nivel 1
         cAux:=SubStr(AllTrim(aDados[1]),1,1)
         DbSelectArea("Z18")
         Z18->(DbSetOrder(1))
         If !Z18->(DbSeek(xFilial("Z18")+cAux))
            ConOut("Erro: Nivel 1 nao encontrado.)")   
         EndIf

         // -> Posiciona no nivel 2
         cAux1:=SubStr(AllTrim(aDados[1]),2,2)
         DbSelectArea("Z19")
         Z19->(DbSetOrder(1))
         If !Z19->(DbSeek(xFilial("Z19")+Z18->Z18_COD+cAux1))
            ConOut("Erro: Nivel 2 nao encontrado.)")   
         EndIf

         // -> Posiciona no nivel 3 
         cAux2:=SubStr(AllTrim(aDados[1]),4,2)
         DbSelectArea("Z20")
         Z20->(DbSetOrder(1))
         If !Z20->(DbSeek(xFilial("Z20")+Z19->Z19_CODN1+Z19->Z19_CODN2+cAux2))
            ConOut("Erro: Nivel 3 nao encontrado.)")   
         EndIf
         
         // -> Verifica o nivel 4 cadastrado
         DbSelectArea("Z21")
         Z21->(DbSetOrder(1))
         If !Z21->(DbSeek(xFilial("Z21")+Z20->Z20_CODN1+Z20->Z20_CODN2+Z20->Z20_CODN3+aDados[02])) 
	        If RecLock("Z21",.T.)
	           Z21->Z21_FILIAL:=xFilial("Z21")
	           Z21->Z21_CODN1 :=Z20->Z20_CODN1
	           Z21->Z21_DESCN1:=Z20->Z20_DESCN1
	           Z21->Z21_CODN2 :=Z20->Z20_CODN2
	           Z21->Z21_DESCN2:=Z20->Z20_DESCN2
	           Z21->Z21_CODN3 :=Z20->Z20_CODN3
	           Z21->Z21_DESCN3:=Z20->Z20_DESCN3
	           Z21->Z21_CODN4 :=aDados[02]
	           Z21->Z21_DESCN4:=aDados[03]
               Z21->(MsUnlock())	     
	           ConOut("Ok.")		
	        Else		
	           ConOut("Erro.")	
	        EndIf
	     Else
	       ConOut("Ok. Ja importado.")
	     EndIf   
      EndIf   
      
      FT_FSkip()
      
   EndDo

Return()




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AIMPZ10                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Importa dados de condições de pagamento por filial                            !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AIMPZ10()
Local cxFile  :="C:\IMP\Z10ALL.CSV"
Private oRegua

   // -> Verifica se encontro o arquivo
   If File(cxFile)
      
      // -> Processa dados das condições de pagamento 
      oRegua := MsNewProcess():New({ || PUpdZ10(oRegua,cxFile) }, "Processamento dados")
	  oRegua:Activate()
	  FT_FUSE()	  

   Else

      Alert("Não foi possivel abir o arquivo "+cXFile)

   EndIf
   
Return()



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUpdZ10                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa condições de pagamento                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function PUpdZ10(oARegua,cxFile)
Local cAux     :=Space(0)
Local cAux1    :=Space(0)
Local cAux2    :=Space(0)
Local aDados   :={}
Local lok      :=.T.

   // Sequencia do layou : Z10_FILIAL;Z10_COD;Z10_CODEXT;Z10_DSEXT

   // -> Abre o arquivo
   FT_FUSE(cxFile)
   FT_FGOTOP()
   While (!FT_FEof())
      
      // -> Le daos do arquivo
      cLinha:=FT_FReadLn()
      aDados:=StrTokArr(cLinha,";")
      ConOut("--> Lina: " + cLinha)
      oARegua:SetRegua1(2)
      oARegua:IncRegua1("Lina : " + cLinha)

      // -> Valida dados da Linha
      lok:=!(StrZero(Len(aDados),5,0) <> "00004")
      If !lok
         ConOut("Erro: Estrutura do arquivo (numero de colunas)")   
      EndIf
       
      If lok .and. SubStr(aDados[1],1,3) <> "Z10"

         // -> Verifica cadastro da empresa
         cAux:=AllTrim(aDados[1])
         DbSelectArea("ADK")
         ADK->(DbSetOrder(5))
         If !ADK->(DbSeek(xFilial("ADK")+cAux))
            ConOut("Erro: Filial nao cadastrada nas unidades de negocio. )") 
            lok:=.F.  
         EndIf

         // -> Posiciona na condição de pagamento
         cAux1:=AllTrim(aDados[2])
         cAux1:=Replicate('0',TamSx3("Z10_CODIGO")[1]-Len(cAux1))+cAux1
         DbSelectArea("SE4")
         SE4->(DbSetOrder(1))
         If !SE4->(DbSeek(xFilial("SE4")+cAux1))
            ConOut("Erro: Condicao de pagamento nao encontrada.)")
            lok:=.F.   
         EndIf
         
         // -> Se já existe a condição de pagamento para a filial
         If lok
            DbSelectArea("Z10")
            Z10->(DbSetOrder(1))
            If !Z10->(DbSeek(xFilial("Z10")+ADK->ADK_XFILI+SE4->E4_CODIGO+aDados[3])) 
	           If RecLock("Z10",.T.)
	              Z10->Z10_FILIAL:=ADK->ADK_XFILI
	              Z10->Z10_CODIGO:=SE4->E4_CODIGO
	              Z10->Z10_DESC  :=SE4->E4_DESCRI
	              Z10->Z10_CODEXT:=aDados[3]
	              Z10->Z10_DSEXT :=aDados[4]
	              Z10->Z10_XEMP  :=ADK->ADK_XEMP
	              Z10->Z10_XFIL  :=ADK->ADK_XFIL
	              Z10->Z10_XSTINT:="I"
	              Z10->Z10_XDINT :=Date()
	              Z10->Z10_XHINT :=Time()
                  Z10->(MsUnlock())	     
	              ConOut("Ok.")		
   	           Else		
	              ConOut("Erro.")	
	           EndIf
	        Else
	          ConOut("Ok. Ja importado.")
	        EndIf
	     Else
	        ConOut("Erro.")
	     EndIf      
      EndIf   
      
      FT_FSkip()
      
   EndDo

Return()




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AIMPSB11                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa dados no cadastro de produtos                                        !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AIMPSB11()
Private oRegua

   // -> Processa dados das condições de pagamento 
   oRegua := MsNewProcess():New({ || PUpdSB11(oRegua) }, "Processamento dados")
   oRegua:Activate()
   
Return()


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUpdZB11                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa estrutura de produtos conforme cadastros auxiliaires                 ! 
!                  ! 1=Industria, 2=Restaurantes, Tabela Z2 e Z3 para os campos B1_XLOCAL, B1_XTIPO! 
!                  ! B1_XCLAS respectivamente                                                      !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function PUpdSB11(oARegua)
Local lok:=.T.

   // -> Le arquivo de produtos
   DbSelectArea("SB1")
   SB1->(DbSetOrder(1))
   SB1->(DbGoTop())
   SB1->(DbSeek(xFilial("SB1")))
   While !SB1->(Eof()) .and. SB1->B1_FILIAL == xFilial("SB1")
      ConOut("--> Produto: " + SB1->B1_COD + ' - ' + SB1->B1_DESC)
      oARegua:SetRegua1(2)
      oARegua:IncRegua1("--> Produto: " + SB1->B1_COD + ' - ' + SB1->B1_DESC)

      // -> Verifica dados nas tabelas auxiliaires
      DbSelectArea("SX5")
      SX5->(DbSetOrder(1))
      SX5->(DbGoTop())
      If !SX5->(DbSeek(xFilial("SX5")+"Z2"+SubStr(SB1->B1_COD,2,2)))
         ConOut("Erro: Tipo do produto nao cadastrado na tabela Z2: Codigo "+SubStr(SB1->B1_COD,2,2) )
         lok:=.F.         
      EndIf

      // -> Verifica dados nas tabelas auxiliaires
      DbSelectArea("SX5")
      SX5->(DbSetOrder(1))
      SX5->(DbGoTop())
      If !SX5->(DbSeek(xFilial("SX5")+"Z3"+SubStr(SB1->B1_COD,4,2)))
         ConOut("Erro: Classe do produto nao cadastrado na tabela Z3: Codigo "+SubStr(SB1->B1_COD,4,2))
         lok:=.F.         
      EndIf

      // -> Se ok. Altera os dados do produto
      If lok
         DbSelectArea("DB1")
         If RecLock("SB1",.F.)
            SB1->B1_XLOCAL:=SubStr(SB1->B1_COD,1,1)
            SB1->B1_XTIPO :=SubStr(SB1->B1_COD,2,2) 
            SB1->B1_XCLAS :=SubStr(SB1->B1_COD,4,2)
            SB1->(MsUnlock())	     
	        ConOut("Ok.")		
   	     Else		
	        ConOut("Erro.")	
	     EndIf
      EndIf   
      
      SB1->(DbSkip())
      
   EndDo

Return()                    









/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! IMPSF9                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Importação dos movimentos CIAP                                                ! 
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

User Function IMPSF9()

Local bProcess
Local oProcess
Local cPerg := Padr("IMPSF9",10)

bProcess := {|oSelf| Executa(oSelf) }

//Cria as perguntas se não existirem
CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oProcess := tNewProcess():New("IMPSF9","Importação Movimentos Ciap",bProcess,"Rotina para importação dos Movimentos Ciap. Na opção parâmetros, informe o nome do arquivo .CSV para importação",cPerg,,.F.,,,.T.,.T.)

Return

//----------------------------
Static Function Executa(oProc)

Local cArq      := Alltrim(mv_par01)
Local cQuery    := ""
Local cCodigo   := ""
Local cInicial  := "1"
Local cLinha    := ""
Local aLinha    := {}
Local nMostra   := 1 //mv_par02
Local aMata220  := {}
Local nCont     := 0
Local cDiretory   
Local cLocaliz          

Private lMsErroAuto	:= .F.

If ( nMostra == 2 )
	cDiretory := Alltrim(mv_par03)
	cDiretory += IIF( Right( cDiretory, 1 ) == "\", "", "\" )

	If !ExistDir( cDiretory )
		Aviso("Diretório","Diretório " + cDiretory + " não encontrado",{"Ok"},2)
		Return
	Endif
Endif

If Upper(Right(cArq,4)) != ".CSV"
	Aviso("Atençao","A extensão do arquivo deve ser obrigatoriamente .CSV",{"Ok"},2)
	Return
Endif

If !File(cArq)
	Aviso("Atenção","O arquivo " +cArq + " não foi encontrado",{"Ok"},2)
	Return

Endif

//Inicia o processamento
FT_FUSE(cArq)

oProc:SetRegua1(FT_FLastRec())

While !FT_FEOF()
	lMsErroAuto	:= .F.
	cLinha := FT_FReadLn()
	If Empty(cLinha)
		Exit
	Endif
	
	aLinha := Split(cLinha, ";")
	
	//Campos
	dbSelectArea("SF9")
	dbSetOrder(1)
			                      
	If !(dbSeek (aLinha[1]+strzero(val(aLinha[2]),6)))
		RecLock("SF9",.T.)       
		SF9->F9_FILIAL  := aLinha[1]
		SF9->F9_CODIGO  := strzero(val(aLinha[2]),6)
		SF9->F9_DESCRI  := aLinha[3]
		SF9->F9_FORNECE := aLinha[4]
		SF9->F9_LOJAFOR := aLinha[5]
		SF9->F9_DOCNFE  := aLinha[6]
		SF9->F9_SERNFE  := aLinha[7]
		SF9->F9_ITEMNFE := aLinha[8]
		SF9->F9_PROPRIO := aLinha[9]
		SF9->F9_DTENTNE := CtoD(aLinha[10])
		SF9->F9_DTEMINE := CtoD(aLinha[11])
		SF9->F9_VALICMS := Num(aLinha[12])
		SF9->F9_CFOENT  := aLinha[13]
		SF9->F9_PICM    := Num(aLinha[14])
		SF9->F9_ICMIMOB := Num(aLinha[15])
		SF9->F9_QTDPARC := Num(aLinha[16])
		SF9->F9_SLDPARC := Num(aLinha[17])
		SF9->F9_TIPO    := aLinha[18]
		SF9->F9_VLDBATV := Num(aLinha[19])
		SF9->F9_VALICCO := Num(aLinha[20])
		SF9->F9_VALFRET := Num(aLinha[21])
		SF9->F9_VALICMP := Num(aLinha[22])
		SF9->F9_DTINIUT := CtoD(aLinha[23])
		SF9->F9_ROTINA  := "IMPSF9"
		SF9->F9_VIDUTIL := Num(aLinha[24])
		SF9->F9_VALICST := Num(aLinha[25])
		
		MsUnLock()
	EndIf
	oProc:IncRegua1("Codigo: "+aLinha[2]+ "-" + aLinha[3])
	FT_FSKIP()
Enddo                                     

FT_FUSE()
fRename(cArq,cArq+".processado")


Aviso("Atenção","Importação Concluída",{"Ok"},2)

Return

//-----------------------
Static Function Num(cNum)
cNum := StrTran(cNum,",",".")

Return(Val(cNum))

//------------------------------
Static Function Split(cPar,cSep)

Local aPar := {}
Local nPos := ""

While AT(cSep, cPar) != 0
	nPos := AT(cSep, cPar)

	aAdd(aPar, Alltrim( Subs( cPar, 1, nPos-1)))
	cPar := Subs( cPar, nPos+1, len(cPar) )
Enddo

If !Empty(cPar)
	aAdd(aPar, Alltrim(Subs(cPar, 1, Len(cPar))))
Endif

Return aPar

//----------------------------
Static Function CriaSX1(cPerg)

PutSX1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importação,","obrigatóriamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
PutSX1(cPerg,"02","Mostra erro?","Mostra erro?","Mostra erro?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Mostra","Mostra","Mostra","","Grava em Disco","Grava em Disco","Grava em Disco","Não Mostra","Não Mostra","Não Mostra","","","","","","",{"Informe se deseja que a cada erro","mostra a mensagem na tela ou","seja gravada em disco.",""},{"","","",""},{"","",""},"")
PutSX1(cPerg,"03","Diretório?","Diretório?","Diretório?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diretório para gravar","erros se o parametros anterior","estiver para grava em disco.",""},{"","","",""},{"","",""},"")

Return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AIMPZ13                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza cadastro da tabela de relacionamento de produtos do Protheus com o   !
!                  ! Teknisa                                                                       !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AIMPZ13()
Local cxFile  :="C:\IMP\Z13"+xFilial("Z13")+".CSV"
Private oRegua

   // -> Verifica se encontro o arquivo
   If File(cxFile)
      
      // -> Processa alteração dos dados do produto 
      oRegua := MsNewProcess():New({ || PUpdZ13(oRegua,cxFile) }, "Processamento dados...")
	  oRegua:Activate()
	  FT_FUSE()	  

   Else

      Alert("Não foi possivel abir o arquivo "+cXFile)

   EndIf
   
Return()



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUpdz13                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa atualização do cadastro de produtos Protheus x Teknisa               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function PUpdZ13(oARegua,cxFile)
Local cAux     :=Space(0)
Local cOnde    :=Space(0)
Local cTipo    :=Space(0)
Local cClasse  :=Space(0)
Local cLinha   :=Space(0)
Local aDados   :={}
Local lok      :=.T.

   // Sequencia do layou :B1_COD;B1_XCODEXT;B1_XCDARVP

   // -> Abre o arquivo
   FT_FUSE(cxFile)
   FT_FGOTOP()
   While (!FT_FEof())
  
      // -> Le daos do arquivo     
      cLinha:=FT_FReadLn()
      aDados:=StrTokArr(cLinha,";")
      ConOut("--> Lina: " + cLinha)
      oARegua:SetRegua1(2)
      oARegua:IncRegua1("Lina : " + cLinha)

      // -> Valida dados da Linha
      lok:=!(StrZero(Len(aDados),5,0) <> "00003")
      If !lok
         ConOut("Erro: Estrutura do arquivo (numero de colunas)")   
      EndIf
       
      If lok .and. SubStr(aDados[1],1,4) <> "Z13_"

         // -> Posiciona no cadastro de Produtos
         cAux:=AllTrim(aDados[1])
         cAux:=cAux+Space(TamSX3("B1_COD")[1]-Len(cAux))
         DbSelectArea("SB1")
         SB1->(DbSetOrder(1))
         If !SB1->(DbSeek(xFilial("SB1")+cAux))
            ConOut("Erro: Produto não encontrado.)")
            lok:=.F.   
         EndIf

         // -> Localiza Unidade de negócio
         DbSelectArea("ADK")
         ADK->(DbSetOrder(5))
         If !ADK->(DbSeek(xFilial("ADK")+xFilial("SB1")))
         	ConOut("Erro: Unidade de negocio nao encontrada. ")
          	lok:=.F.
         EndIf      
         
         // -> Verifica código externo
         If AllTrim(aDados[2]) == ""
            ConOut("Erro: Codigo externo vazio. )")
            lok:=.F.
         EndIf 

         // -> Verifica código da árvore
         If AllTrim(aDados[3]) == ""
            ConOut("Erro: Codigo da árvore vazio. )")
            lok:=.F.
         EndIf 
         
         // -> Se tudo ok, altera dados
         If lok

            Begin Transaction

			// -> Atualiza tabela auxiliar
   			DbSelectArea("Z13")
      		Z13->(DbSetOrder(1))
        	If !Z13->(DbSeek(SB1->B1_FILIAL+SB1->B1_COD))
         		RecLock("Z13",.T.)
				Z13->Z13_FILIAL:=xFilial("Z13")
				Z13->Z13_COD   :=SB1->B1_COD
                Z13->Z13_DESC  :=SB1->B1_DESC
                Z13->Z13_XCODEX:=AllTrim(aDados[2])
                Z13->Z13_XCDARV:=AllTrim(aDados[3])
                Z13->Z13_XEMP  :=ADK->ADK_XEMP
                Z13->Z13_XFIL  :=ADK->ADK_XFIL
                Z13->Z13_XSTINT:="I"
                Z13->Z13_XDINT :=SB1->B1_DATREF
                Z13->Z13_XEXC  :="N"
                Z13->(MsUnlock())   
    		EndIf                                       
    		
			dbSelectArea("Z17")
			Z17->(dbSetOrder(1))
			Z17->(dbSeek(SB1->B1_FILIAL+SB1->B1_COD))	
			If !Z17->(found())
				RecLock("Z17",.T.)
				Z17->Z17_FILIAL		:= SB1->B1_FILIAL
				Z17->Z17_COD		:= SB1->B1_COD
				Z17->Z17_DESC       := SB1->B1_DESC      
				Z17->Z17_XCODEX     := AllTrim(aDados[2])
				Z17->Z17_XSTINT		:= "I"
				Z17->Z17_XCDARV		:= AllTrim(aDados[3])
				Z17->Z17_XEMP		:= ADK->ADK_XEMP
				Z17->Z17_XFIL		:= ADK->ADK_XFIL
				Z17->Z17_XATIVO		:= "S"
				Z17->Z17_XDINT      :=SB1->B1_DATREF
				Z17->( msUnLock())
			EndIf
    		
            // -> Altera dados dos produtos
            RecLock("SB1",.F.)
            SB1->B1_XN1   :=SubStr(AllTrim(aDados[3]),1,1) 
            SB1->B1_XN2   :=SubStr(AllTrim(aDados[3]),2,2)
            SB1->B1_XN3   :=SubStr(AllTrim(aDados[3]),4,2)
            SB1->B1_XN4   :=SubStr(AllTrim(aDados[3]),6,3)
            Sb1->(MsUnlock())

            End Transaction
	     
	        ConOut("Ok.")

	     Else
	     
	       ConOut("Erro.")
	     
	     EndIf   
	        	
      EndIf   

      FT_FSkip()

   EndDo

Return



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! IMPSLDLT                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa importação dos saldos em pré nota com lote                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function IMPSLDLT()
Private oRegua

   // -> Verifica se encontro o arquivo
      // -> Processa alteração dos dados do produto 
      oRegua := MsNewProcess():New({ || ProcSaldo(oRegua) }, "Processamento dados...")
	  oRegua:Activate()
	  FT_FUSE()	  

Return()

Static Function ProcSaldo(oProc)
Local cArq       := alltrim(mv_par01)
Local cLinha     := ""
Local lPrim      := .T.
Local aCampos    := {}
Local aDados     := {}
Local aMt140c	 := {}
Local aMt140i    := {}
Local aLinha	 := {}
Local cDiretory
//Local nMostra   := mv_par02
Local lErro := .F.
Local i
Local j
Local cCodP

	cArq:="C:\IMP\SALDOSIND.csv"

	IF !File("C:\IMP\SALDOSIND.csv")
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[IMPORT04] - ATENCAO")
		Return
	EndIF

	//valida o diretório se for pra gravar em disco
	//IF nMostra == 2
		//cDiretory := alltrim(mv_par03)
		//cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )
		//valida o diretório
		//If !ExistDir("C:\IMP\SALDOSIND.csv")
		//	Aviso("Diretório","Diretório " + cDiretory + " invalido.",{"Ok"},2)
		//	Return
		//EndIF
	//EndIF
	
	cAuxFun:=FunNAme()
	nAuxMod:=nModulo

	SetFunName("MATA140")
	nModulo:=2


	FT_FUSE(cArq)

	While !FT_FEOF()

		cLinha := alltrim(FT_FREADLN())

		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			aAdd(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDO

	FT_FUSE()

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(XFilial("SA2")+"20312302"))
	
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(XFilial("SE4")+"000"))

	oProc:SetRegua1( Len(aDados) )
		//Monta array com os dados para o cabeçalho da pré-nota
		aAdd(aMt140c,{"F1_FILIAL"  ,xFilial("SF1")  })
		aAdd(aMt140c,{"F1_DOC"     ,"000000001"	    })
		aAdd(aMt140c,{"F1_SERIE"   ,"80"			})
		aAdd(aMt140c,{"F1_EMISSAO" ,CToD("30/06/2018")})
		aAdd(aMt140c,{"F1_FORNECE" ,SA2->A2_COD		})
		aAdd(aMt140c,{"F1_LOJA"    ,SA2->A2_LOJA	})
		aAdd(aMt140c,{"F1_COND"    ,SE4->E4_CODIGO  })
		aAdd(aMt140c,{"F1_TIPO"    ,"N" 			})
		aAdd(aMt140c,{"F1_ESPECIE" ,"NF" 			})
	
	
		For i:=1 to Len(aDados)
			
			oProc:IncRegua1("Lendo Linha " + alltrim(str(i)) + " de " + alltrim(str(Len(aDados))) )
			If i > 1
			   // -> Verifica se o produto está cadastrado
			   DbSelectArea("SB1")
			   SB1->(DbSetOrder(1))
			   If SB1->(DbSeek(xFilial("SB1")+alltrim(aDados[i,1])))
			   		aLinha := {}
					AADD(aLinha,{"D1_FILIAL", xFilial("SD1") 	    , NIL})
					aAdd(aLinha,{"D1_COD"  ,  alltrim( aDados[i,1]) , NIL})
					aAdd(aLinha,{"D1_QUANT",  toNumber(aDados[i,2]) , NIL})
					aAdd(aLinha,{"D1_VUNIT",  toNumber(aDados[i,3]) , NIL})
					aAdd(aLinha,{"D1_TOTAL",  toNumber(aDados[i,4]) , NIL})
					aAdd(aLinha,{"D1_LOCAL",  alltrim( aDados[i,5]) , NIL})
					If SB1->B1_RASTRO == "L"
						aAdd(aLinha,{"D1_LOTECTL", alltrim(aDados[i,6]) , NIL})
						aAdd(aLinha,{"D1_DTVALID", CTOD(   aDados[i,7]) , NIL})					
					EndIf
					AADD(aLinha,{"D1_TESACLA", 	"499"			, NIL})
					aAdd(aMt140i, aClone(aLinha))
					
				EndIf	
			EndIf
		Next i	
						
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z|Mata140(x,y,z)},aMt140c,aMt140i,3)		

		IF lMsErroAuto
			MostraErro()
		EndIF


	SetFunName(cAuxFun)
	nModulo:=nAuxMod



oProc:IncRegua1("Fim da importação.")
Return

Static Function toNumber(xValor)

	//se exitir virgula na string
	IF At(",",xValor) != 0
		//se o ponto vier antes da virgula ou ponto não existir
		IF ( At(",",xValor) > At(".",xValor) ).Or.At(".",xValor) == 0
			xValor := StrTran(xValor,".","")
			xValor := StrTran(xValor,",",".")
			xValor := val(xValor)
		Else
			xValor := StrTran(xValor,",","")
			xValor := val(xValor)
		EndIF
	Else
		xValor := val(xValor)
	EndIF

Return xValor



Static Function CriaSX1SLD(cPerg)

	//Arquivo
	xPutSx1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importação,","obrigatóriamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
	//Mostra erros?
	xPutSx1(cPerg,"02","Mostra erro?","Mostra erro?","Mostra erro?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Mostra","Mostra","Mostra","","Grava em Disco","Grava em Disco","Grava em Disco","Não Mostra","Não Mostra","Não Mostra","","","","","","",{"Informe se deseja que a cada erro","mostra a mensagem na tela ou","seja gravada em disco.",""},{"","","",""},{"","",""},"")
	//Diretorio
	xPutSx1(cPerg,"03","Diretório?","Diretório?","Diretório?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diretório para gravar","erros se o parametros anterior","estiver para Grava em Disco.",""},{"","","",""},{"","",""},"")

Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     Reclock( "SX1" , .T. ) 

     Replace X1_GRUPO   With cGrupo 
     Replace X1_ORDEM   With cOrdem 
     Replace X1_PERGUNT With cPergunt 
     Replace X1_PERSPA With cPerSpa 
     Replace X1_PERENG With cPerEng 
     Replace X1_VARIAVL With cVar 
     Replace X1_TIPO    With cTipo 
     Replace X1_TAMANHO With nTamanho 
     Replace X1_DECIMAL With nDecimal 
     Replace X1_PRESEL With nPresel 
     Replace X1_GSC     With cGSC 
     Replace X1_VALID   With cValid 

     Replace X1_VAR01   With cVar01 

     Replace X1_F3      With cF3 
     Replace X1_GRPSXG With cGrpSxg 

     If Fieldpos("X1_PYME") > 0 
          If cPyme != Nil 
               Replace X1_PYME With cPyme 
          Endif 
     Endif 

     Replace X1_CNT01   With cCnt01 
     If cGSC == "C"               // Mult Escolha 
          Replace X1_DEF01   With cDef01 
          Replace X1_DEFSPA1 With cDefSpa1 
          Replace X1_DEFENG1 With cDefEng1 

          Replace X1_DEF02   With cDef02 
          Replace X1_DEFSPA2 With cDefSpa2 
          Replace X1_DEFENG2 With cDefEng2 

          Replace X1_DEF03   With cDef03 
          Replace X1_DEFSPA3 With cDefSpa3 
          Replace X1_DEFENG3 With cDefEng3 

          Replace X1_DEF04   With cDef04 
          Replace X1_DEFSPA4 With cDefSpa4 
          Replace X1_DEFENG4 With cDefEng4 

          Replace X1_DEF05   With cDef05 
          Replace X1_DEFSPA5 With cDefSpa5 
          Replace X1_DEFENG5 With cDefEng5 
     Endif 

     Replace X1_HELP With cHelp 

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 
Else 

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

   If lPort .Or. lSpa .Or. lIngl 
          RecLock("SX1",.F.) 
          If lPort 
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
          EndIf 
          If lSpa 
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
          EndIf 
          If lIngl 
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
          EndIf 
          SX1->(MsUnLock()) 
     EndIf 
Endif 

RestArea( aArea ) 

Return





User Function xPutSD3()

  dDataBase:=CtoD("29/09/2018")
  nModulo  :=4

	// -> Posiciona na tabela de saldos para inclui movimentos com quantidade negativa
  
  DbSelectArea("SB2")
  SB2->(DbGoTop())
  SB2->(DbSeek(xFilial("SB2")))
  While !SB2->(Eof()) .and. xFilial("SB2") == SB2->B2_FILIAL

    If SB2->B2_QATU < 0

			// -> Posiciona no cadastro do produto
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SB2->B2_COD)) 
			If SB1->(Found()) 

				// -> Faz apontamento
				lMsErroAuto := .F.
				aMATA240	:= {} 							  
				aadd(aMATA240,{"D3_TM"		 ,"002"			     								,Nil})	
				aadd(aMATA240,{"D3_COD"		 ,SB1->B1_COD						  			,Nil})	
				aadd(aMATA240,{"D3_LOCAL"	 ,SB1->B1_LOCPAD								,Nil})	
				aadd(aMATA240,{"D3_QUANT"	 ,SB2->B2_QATU*-1								,Nil})	
				aadd(aMATA240,{"D3_EMISSAO",dDataBase			      					,Nil})
				lMsErroAuto := .F.
				MSExecAuto({|x,y| mata240(x,y)},aMATA240,3)
				If lMsErroAuto
					Conout("Erro...")
				EndIf

			EndIf
			
		EndIf

    SB2->(DbSkip())

  EndDo

Return() 





User Function ExecSmart(Parm)
ConOut("Par1:"+Parm)
Return("")




User Function xPutZ13()
Local cQuery	   := ""
Local cAliasQry	:= GetNextAlias( )

DbSelectArea("Z13")
Z13->(DbSetOrder(1))

cQuery += "  SELECT * FROM Z13020MAZ WHERE D_E_L_E_T_ <> '*' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	
While !(cAliasQry)->(Eof())

  Z13->(DbSeek(xFilial("Z13")+(cAliasQry)->Z13_COD))
  If !Z13->(Found())
    Reclock("Z13",.T.)
    Z13->Z13_FILIAL := (cAliasQry)->Z13_FILIAL
    Z13->Z13_COD    := (cAliasQry)->Z13_COD
    Z13->Z13_DESC   := (cAliasQry)->Z13_DESC
    Z13->Z13_XCODEX := (cAliasQry)->Z13_XCODEX
    Z13->Z13_XCDARV := (cAliasQry)->Z13_XCDARV
    Z13->Z13_XSTINT := (cAliasQry)->Z13_XSTINT
    Z13->Z13_XDINT  := DToD((cAliasQry)->Z13_XDINT)
    Z13->Z13_XHINT  := (cAliasQry)->Z13_XHINT
    Z13->Z13_XEXC   := (cAliasQry)->Z13_XEXC
    Z13->(MsUnlock())
  EndIf


  (cAliasQry)->(DbSkip())
EndDo

DbSelectArea(cAliasQry)
DbCloseArea()

Return()





User Function xDelSC2(cFil)
Local cQuery	   := ""
Local cAliasQry	:= GetNextAlias( )
Private lMsErroAuto := .F.

DbSelectArea("SC2")

cQuery += "SELECT R_E_C_N_O_ REC FROM SC2010 WHERE D_E_L_E_T_ <> '*' AND C2_QUJE <= 0 and C2_FILIAL = '" + cFil + "'   ORDER BY C2_FILIAL, C2_EMISSAO "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	
While !(cAliasQry)->(Eof())

  SC2->(DbGoTo((cAliasQry)->REC))
  lMsErroAuto := .F.
  aMATA650 := { {'C2_FILIAL' ,SC2->C2_FILIAL ,NIL},;
                {'C2_NUM'    ,SC2->C2_NUM    ,NIL},; 
                {'C2_ITEM'   ,SC2->C2_ITEM   ,NIL},; 
                {'C2_SEQUEN' ,SC2->C2_EMISSAO,NIL},;
                {'C2_PRODUTO',SC2->C2_PRODUTO,NIL},;
                {'C2_LOCAL'  ,SC2->C2_LOCAL  ,NIL},;
                {'C2_QUANT'  ,SC2->C2_QUANT ,NIL},;
                {'C2_DATPRI' ,SC2->C2_DATPRI,NIL},;
                {'C2_DATPRF' ,SC2->C2_DATPRF ,NIL}}
 
  msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)
  If !lMsErroAuto
    ConOut("Sucesso! ")
  Else
    ConOut("Erro!")
    MostraErro()
  EndIf


  (cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return()





User Function xSaldSB8()
Local nSaldo:=0
   DbSelectArea("SB8")
   SB8->(DbSetOrder(3))
   SB8->(DbSeek(xFilial("SB8")+"10101065000100 "+"10"+"AUTO000123             "))
   while !SB8->(Eof()) .and. SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL == xFilial("SB8")+"10101065000100 "+"10"+"AUTO000123             "
      nSaldo+=SB8Saldo()
      SB8->(DbSkip())
   EndDo

Return("")

User Function xSaldSBF()
Local nSaldo:=0
   DbSelectArea("SBF")
   SBF->(DbSetOrder(2))
   SBF->(DbSeek("40MDST0001"+"20403905010800 "+"01"+"Lote PA 1              "))
   while !SBF->(Eof()) .and. SBF->BF_FILIAL+SBF->BF_PRODUTO+SBF->BF_LOCAL+SBF->BF_LOTECTL == "40MDST0001"+"20403905010900  "+"01"+"Lote PA 1              "
      nSaldo+=SBFSaldo()
      SBF->(DbSkip())
   EndDo

Return("")



User Function xF1Doc()
Local cFunName:= AllTrim(FunNAme())
If  (cFunName == "MATA103" .or. cFunName == "MATA140") .and. (!Empty(M->F1_DOC) .or. !Empty(CNFISCAL))
    FG_StrZero("CNFISCAL",TamSX3("F1_DOC")[1])
EndIf
Return(.T.)


