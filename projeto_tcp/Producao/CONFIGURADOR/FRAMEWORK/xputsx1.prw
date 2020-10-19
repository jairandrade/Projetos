#Include 'totvs.ch'
 
/*/{Protheus.doc}
@obs XPUTSX1
@author Kaique Mathias
@type User Function
@description Funo para criar grupo de perguntas no mesmo molde da padro.
@since 13/03/2017
@version Protheus 12
 
@param 01 - cGrupo  , Caracter  , Nome do grupo de pergunta.
@param 02 - cOrdem  , Caracter  , Ordem de apresentao das perguntas na tela.
@param 03 - cPergunt , Caracter  , Texto da pergunta a ser apresentado na tela.
@param 04 - cPerSpa , Caracter  , Texto em espanhol da pergunta a ser apresentado na tela.
@param 05 - cPerEng , Caracter  , Texto em ingls da pergunta a ser apresentado na tela.
@param 06 - cVar       , Caracter  , Variavel do item.
@param 07 - cTipo      , Caracter  , Tipo do contedo de resposta da pergunta.
@param 08 - nTamanho , Numrico  , Tamanho do campo para a resposta da pergunta.
@param 09 - nDecimal , Numrico  , Nmero de casas decimais da resposta, se houver.
@param 10 - nPresel , Numrico  , Valor que define qual o item do combo estar selecionado na apresentao da tela. Este campo somente poder ser preenchido quando o parmetro cGSC for preenchido com "C".
@param 11 - cGSC       , Caracter  , Estilo de apresentao da pergunta na tela: - "G" - formato que permite editar o contedo do campo. - "S" - formato de texto que no permite alterao. - "C" - formato que permite a opo de seleo de dados para o campo.
@param 12 - cValid  , Caracter  , Validao do item de pergunta.
@param 13 - cF3     , Caracter  , Nome da consulta F3 que poder ser acionada pela pergunta.
@param 14 - cGrpSxg , Caracter  , Cdigo do grupo de campos relacionado a pergunta.
@param 15 - cPyme      , Caracter  , Nulo
@param 16 - cVar01  , Caracter  , Nome do MV_PAR para a utilizao nos programas.
@param 17 - cDef01  , Caracter  , Contedo em portugus do primeiro item do objeto, caso seja Combo.
@param 18 - cDefSpa1 , Caracter  , Contedo em espanhol do primeiro item do objeto, caso seja Combo.
@param 19 - cDefEng1 , Caracter  , Contedo em ingls do primeiro item do objeto, caso seja Combo.
@param 20 - cCnt01  , Caracter  , Contedo padro da pergunta.
@param 21 - cDef02  , Caracter  , Contedo em portugus do segundo item do objeto, caso seja Combo.
@param 22 - cDefSpa2 , Caracter  , Contedo em espanhol do segundo item do objeto, caso seja Combo.
@param 23 - cDefEng2 , Caracter  , Contedo em ingls do segundo item do objeto, caso seja Combo.
@param 24 - cDef03  , Caracter  , Contedo em portugus do terceiro item do objeto, caso seja Combo.
@param 25 - cDefSpa3 , Caracter  , Contedo em espanhol do terceiro item do objeto, caso seja Combo.
@param 26 - cDefEng3 , Caracter  , Contedo em ingls do terceiro item do objeto, caso seja Combo.
@param 27 - cDef04  , Caracter  , Contedo em portugus do quarto item do objeto, caso seja Combo.
@param 28 - cDefSpa4 , Caracter  , Contedo em espanhol do quarto item do objeto, caso seja Combo.
@param 29 - cDefEng4 , Caracter  , Contedo em ingls do quarto item do objeto, caso seja Combo.
@param 30 - cDef05  , Caracter  , Contedo em portugus do quinto item do objeto, caso seja Combo.
@param 31 - cDefSpa5 , Caracter  , Contedo em espanhol do quinto item do objeto, caso seja Combo.
@param 32 - cDefEng5 , Caracter  , Contedo em ingls do quinto item do objeto, caso seja Combo.
@param 33 - aHelpPor , Vetor       , Help descritivo da pergunta em Portugus.
@param 34 - aHelpEng , Vetor       , Help descritivo da pergunta em Ingls.
@param 35 - aHelpSpa , Vetor       , Help descritivo da pergunta em Espanhol.
@param 36 - cHelp      , Caracter  , Nome do help equivalente, caso j exista algum no sistema.
 
@see http://tdn.totvs.com/pages/releaseview.action?pageId=244740739
/*/
 
user Function XPUTSX1( cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
 
   local aArea    := GetArea()
   local cKey
   local lPort    := .f.
   local lSpa     := .f.
   local lIngl    := .f.
   local cAlias   := "SX1"

   cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
 
   cPyme    := Iif( cPyme       == Nil, " ", cPyme       )
   cF3      := Iif( cF3         == NIl, " ", cF3         )
   cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg         )
   cCnt01   := Iif( cCnt01      == Nil, "" , cCnt01      )
   cHelp    := Iif( cHelp        == Nil, "" , cHelp      )
 
   dbSelectArea( cAlias )
   dbSetOrder( 1 )
 
   cGrupo := PadR( cGrupo , Len( & ( SubS(cAlias,2,2) + "_GRUPO" ) ) , " " )
 
   If !( DbSeek( cGrupo + cOrdem ))
 
      cPergunt  := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
      cPerSpa   := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
      cPerEng   := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
 
      Reclock( cAlias , .T. )
 
      Replace &( SubS(cAlias,2,2) + "_GRUPO" )   With cGrupo
      Replace &( SubS(cAlias,2,2) + "_ORDEM" )  With cOrdem
      Replace &( SubS(cAlias,2,2) + "_PERGUNT" )  With cPergunt
      Replace &( SubS(cAlias,2,2) + "_PERSPA" ) With cPerSpa
      Replace &( SubS(cAlias,2,2) + "_PERENG" ) With cPerEng
      Replace &( SubS(cAlias,2,2) + "_VARIAVL" ) With cVar
      Replace &( SubS(cAlias,2,2) + "_TIPO" ) With cTipo
      Replace &( SubS(cAlias,2,2) + "_TAMANHO" ) With nTamanho
      Replace &( SubS(cAlias,2,2) + "_DECIMAL" ) With nDecimal
      Replace &( SubS(cAlias,2,2) + "_PRESEL" ) With nPresel
      Replace &( SubS(cAlias,2,2) + "_GSC" ) With cGSC
      Replace &( SubS(cAlias,2,2) + "_VALID" ) With cValid
 
      Replace &( SubS(cAlias,2,2) + "_VAR01" ) With cVar01
 
      Replace &( SubS(cAlias,2,2) + "_F3" ) With cF3
      Replace &( SubS(cAlias,2,2) + "_GRPSXG" ) With cGrpSxg
 
      If Fieldpos(SubS(cAlias,2,2) + "_PYME") > 0
         If cPyme != Nil
            Replace &( SubS(cAlias,2,2) + "_PYME" ) With cPyme
         Endif
      Endif
 
      Replace &( SubS(cAlias,2,2) + "_CNT01" )  With cCnt01
 
      If cGSC == "C"            // Mult Escolha
         Replace &( SubS(cAlias,2,2) + "_DEF01" )   With cDef01
         Replace &( SubS(cAlias,2,2) + "_DEFSPA1" ) With cDefSpa1
         Replace &( SubS(cAlias,2,2) + "_DEFENG1" ) With cDefEng1
 
         Replace &( SubS(cAlias,2,2) + "_DEF02" ) With cDef02
         Replace &( SubS(cAlias,2,2) + "_DEFSPA2" ) With cDefSpa2
         Replace &( SubS(cAlias,2,2) + "_DEFENG2" ) With cDefEng2
 
         Replace &( SubS(cAlias,2,2) + "_DEF03" ) With cDef03
         Replace &( SubS(cAlias,2,2) + "_DEFSPA3" ) With cDefSpa3
         Replace &( SubS(cAlias,2,2) + "_DEFENG3" ) With cDefEng3
 
         Replace &( SubS(cAlias,2,2) + "_DEF04" ) With cDef04
         Replace &( SubS(cAlias,2,2) + "_DEFSPA4" ) With cDefSpa4
         Replace &( SubS(cAlias,2,2) + "_DEFENG4" ) With cDefEng4
 
         Replace &( SubS(cAlias,2,2) + "_DEF05" ) With cDef05
         Replace &( SubS(cAlias,2,2) + "_DEFSPA5" ) With cDefSpa5
         Replace &( SubS(cAlias,2,2) + "_DEFENG5" ) With cDefEng5
      Endif
 
      Replace &( SubS(cAlias,2,2) + "_HELP" ) With cHelp
 
      U_XPUTSX1HELP(cKey,aHelpPor,aHelpEng,aHelpSpa)
 
      MsUnlock()
 
   Else
 
      lPort := ! "?" $ &( SubS(cAlias,2,2) + "_PERGUNT" ) .And. ! Empty( &( SubS((cAlias)->cAlias,2,2) + "_PERGUNT" ) )
      lSpa  := ! "?" $ &( SubS(cAlias,2,2) + "_PERSPA" )  .And. ! Empty( &( SubS((cAlias)->cAlias,2,2) + "_PERSPA" ) )
      lIngl := ! "?" $ &( SubS(cAlias,2,2) + "_PERENG" )  .And. ! Empty( &( SubS((cAlias)->cAlias,2,2) + "_PERENG" ) )
 
      If lPort .Or. lSpa .Or. lIngl
         RecLock(cAlias,.F.)
         If lPort
            &( SubS((cAlias)->cAlias,2,2) + "_PERGUNT" ) := Alltrim( &( SubS((cAlias)->cAlias,2,2) + "_PERGUNT" ) ) +" ?"
         EndIf
         If lSpa
            &( SubS((cAlias)->cAlias,2,2) + "_PERSPA" ) := Alltrim( &( SubS((cAlias)->cAlias,2,2) + "_PERSPA" ) ) +" ?"
         EndIf
         If lIngl
            &( SubS((cAlias)->cAlias,2,2) + "_PERENG" ) := Alltrim( &( SubS((cAlias)->cAlias,2,2) + "_PERENG" ) ) +" ?"
         EndIf
         (cAlias)->(MsUnLock())
      EndIf
   Endif
 
   RestArea( aArea )
 
Return( Nil )