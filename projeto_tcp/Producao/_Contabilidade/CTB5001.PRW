/*
+------------------+-------------------------------------------------------------------------------+
! Nome             ! CTH5001                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Geração automática de classes de valor na contabilidade                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 29/06/2015                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/

#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"

User function CTH5001
  Private cQuery      :=Space(0)
  Private aSize       := {}
  Private aObjects    := {} 
  Private aInfo       := {}
  Private aPosObj     := {}
  Private oDlg                   
  Private cTitulo	  := "Geração de Classes de Valor"   
  Private nOpcao      := 0                                       
  Private aReturn     := {}  
  Private cMensagem   := "Selecione os cadastros que deseja gerar classes de valor "
  Private cMensagem1  := "e execute o processo. "
  Private oMensagem
  Private oMensagem1
  Private cSA1        := Space(01)
  Private oSA1   
  Private cSA2        := Space(01)
  Private oSA2   
  Private cSRA        := Space(01)
  Private oSRA   

  aSize    := MsAdvSize()
  aAdd( aObjects, { 100, 100, .T., .T. } )
  aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2}
  aPosObj  := MsObjSize( aInfo, aObjects,.T.)
   

  DEFINE MSDIALOG oDlg Title cTitulo From aSize[7],0 to aSize[6], aSize[5] of oMainWnd PIXEL  
  
  @ 020,010 To 200,550
  @ 003,002 MsGet oMensagem  Var cMensagem	 		    		Size 400,008 of oDlg                        
  @ 004,002 MsGet oMensagem1 Var cMensagem1	 		    		Size 400,008 of oDlg                        
  @ 005,002 Say "Clientes ?" 			    	                Size 020,008 of oDlg
  @ 005,020 MsGet oSA1       Var cSA1	 		    	      	Size 020,008 of oDlg                        
  @ 006,002 Say "Fornecedores ?" 			    	            Size 020,008 of oDlg
  @ 006,020 MsGet oSA2       Var cSA2	 		    	      	Size 020,008 of oDlg                        
  @ 007,002 Say "Funcionários ?" 			    	            Size 020,008 of oDlg
  @ 007,020 MsGet oSRA       Var cSRA	 		    	      	Size 020,008 of oDlg                       
    
  oMensagem:Disable()
  oMensagem1:Disable()

  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (nOpcao := 1, oDlg:End())}, {|| (nOpcao := 2, oDlg:End())})

  If nOpcao = 1   
     MsAguarde({|| ImpCTH(cSA1,cSA2,cSRA)},'Processando dados...')                     	
  EndIf
                                        
Return

// ---------------------------------------------------------------------------------------------------------------
//   Função para executar a migração de Funcionários / Clientes e Fornecedores para Itens Contábeis
// ---------------------------------------------------------------------------------------------------------------
Static Function ImpCTH(cSA1,cSA2,cSRA)
  Local cQuery := Space(0)
  Local nCont  := 0  
  
  // -> Importação dos Funcionários
  If Upper(cSRA) == "S"  
     
      If Select("SRATMP") > 0
         dbSelectArea("SRATMP")
         dbCloseArea("SRATMP")
      Endif
          
     cQuery := "SELECT SRA.RA_FILIAL, "
     cQuery += "SRA.RA_MAT, "
     cQuery += "SRA.RA_NOME "
     cQuery += "FROM " + RetSqlName("SRA") + " AS SRA "
     cQuery += "WHERE SRA.D_E_L_E_T_ <>'*' "
     DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SRATMP", .F., .T.)
     
     DbSelectArea("SRATMP")
     SRATMP->(DbGoTop())
     While !SRATMP->(Eof())  
        DbSelectArea("CTH")
        CTH->(DbSetOrder(1))
        If !CTH->(DbSeek(xFilial("CTH")+"N"+SRATMP->RA_MAT))
           nCont     := nCont + 1
           cMensagem := "Funcionário -> "+SRATMP->RA_NOME     
           RecLock("CTH",.T.)                  
           CTH_FILIAL := xFilial("CTH")
           CTH_CLVL   := "N"+SRATMP->RA_MAT
           CTH_CLASSE := "2"                           
           CTH_DESC01 := SRATMP->RA_NOME
           CTH_DESC02 := SRATMP->RA_NOME
           CTH_DESC03 := SRATMP->RA_NOME
           CTH_DESC04 := SRATMP->RA_NOME
           CTH_DESC05 := SRATMP->RA_NOME
           CTH_BLOQ   := "2"
           CTH_DTEXIS := CtoD("01/01/1980")                      
           MsUnlock("CTH")
        EndIf   
        SRATMP->(DbSkip())  
     EndDo                
  
     dbSelectArea("SRATMP")
     dbCloseArea()
  
  EndIf   

  // -> Importação de Clientes
  If Upper(cSA1) == "S"  

      If Select("SA1TMP") > 0
         dbSelectArea("SA1TMP")
         dbCloseArea("SA1TMP")
      Endif

     cQuery := "SELECT SA1.A1_FILIAL, SA1.A1_COD, "
     cQuery += "SA1.A1_LOJA, "
     cQuery += "SA1.A1_NOME "
     cQuery += "FROM " + RetSqlName("SA1") + " AS SA1 "
     cQuery += "WHERE SA1.D_E_L_E_T_ <>'*' "
     DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SA1TMP", .F., .T.)
     
     DbSelectArea("SA1TMP")
     SA1TMP->(DbGoTop())
     While !SA1TMP->(Eof())  
        DbSelectArea("CTH")

        CTH->(DbSetOrder(1))
        If !CTH->(DbSeek(xFilial("CTH")+"C"+SA1TMP->A1_COD+SA1TMP->A1_LOJA))
           nCont     := nCont + 1
           cMensagem := "Cliente -> "+SA1TMP->A1_NOME     
           RecLock("CTH",.T.)                  
           CTH_FILIAL := xFilial("CTH")
           CTH_CLVL   := "C"+SA1TMP->A1_COD+SA1TMP->A1_LOJA
           CTH_CLASSE := "2"                                  
           CTH_DESC01 := SA1TMP->A1_NOME
           CTH_DESC02 := SA1TMP->A1_NOME
           CTH_DESC03 := SA1TMP->A1_NOME
           CTH_DESC04 := SA1TMP->A1_NOME
           CTH_DESC05 := SA1TMP->A1_NOME
           CTH_BLOQ   := "2"
           CTH_DTEXIS := CtoD("01/01/1980")
           MsUnlock("CTH")
        EndIf
        SA1TMP->(DbSkip())  
     EndDo                    
  
     dbSelectArea("SA1TMP")
     dbCloseArea()
  
  EndIf   

  // -> Importação de fornecedores
  If Upper(cSA2) == "S"  

      If Select("SA2TMP") > 0
         dbSelectArea("SA2TMP")
         dbCloseArea("SA2TMP")
      Endif

     cQuery := "SELECT SA2.A2_FILIAL, SA2.A2_COD, "
     cQuery += "SA2.A2_LOJA, "
     cQuery += "SA2.A2_NOME "
     cQuery += "FROM " + RetSqlName("SA2") + " AS SA2 "
     cQuery += "WHERE SA2.D_E_L_E_T_ <>'*' "
     DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SA2TMP", .F., .T.)
     
     DbSelectArea("SA2TMP")
     SA2TMP->(DbGoTop())
     While !SA2TMP->(Eof())  
        DbSelectArea("CTH")
        CTH->(DbSetOrder(1))
        If !CTH->(DbSeek(xFilial("CTH")+"F"+SA2TMP->A2_COD+SA2TMP->A2_LOJA))
           nCont     := nCont + 1
           cMensagem := "Fornecedor -> "+SA2TMP->A2_NOME     
           RecLock("CTH",.T.)                  
           CTH_FILIAL := xFilial("CTH")
           CTH_CLVL   := "F"+SA2TMP->A2_COD+SA2TMP->A2_LOJA
           CTH_CLASSE := "2"                           
           CTH_DESC01 := SA2TMP->A2_NOME
           CTH_DESC02 := SA2TMP->A2_NOME
           CTH_DESC03 := SA2TMP->A2_NOME
           CTH_DESC04 := SA2TMP->A2_NOME
           CTH_DESC05 := SA2TMP->A2_NOME
           CTH_BLOQ   := "2"
           CTH_DTEXIS := CtoD("01/01/1980")
           MsUnlock("CTH")
        EndIf
        SA2TMP->(DbSkip())  
     EndDo                
     
     dbSelectArea("SA2TMP")
     dbCloseArea()
     
  EndIf              
  
Return