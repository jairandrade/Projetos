#include 'protheus.ch'
#include 'parmtype.ch'

/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! xGetAces                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        !  Rotina para Validar e retornar acssos ao Protheus                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function xGetAces(nCodMod, cNomeUsr, cRotina, oEventLog)
Local aRet		:= {}
Local nX		:= 0
Local aAcessos	:= Nil
Local cCodUsr	:= ""
Local aUserAc	:= {}
Local cElTime   := Time()

	// -> Verifica se o usuário é Admin
	If !((Upper(cNomeUsr)) $ "ADMIN")
		PswOrder(2)
		If !PswSeek(cNomeUsr, .T. ) 
			aAdd(aRet,"" )   
			aAdd(aRet,"" )
			aAdd(aRet,"" )
			aAdd(aRet,"" )
			aAdd(aRet,"" )
			aAdd(aRet,"" )
			aAdd(aRet,.F.)
			aAdd(aRet,{} )
			aAdd(aRet,"Usuario invalido. [" + cNomeUsr + "]")   
		Else
			ConOut("-> Pesquisando usuario as "+Time()+" hs")
			cCodUsr:=PswID() // Código do usuário
			aUserAc:=PswRet()
			ConOut("-> Fim da pesquisa do usuario as "+Time()+" hs")
			cElTime:=Time()
			ConOut("-> Validando acesso do usuario ao configurador as "+Time()+" hs")
			aAcessos := ValAce(cCodUsr, nCodMod, cRotina, oEventLog,cElTime)				
			If Len(aAcessos) > 1
				aAdd(aRet,ValUsr(aUserAc))		    //[01] - Usuário Ativo e Permissões de horarios
				aAdd(aRet,aUserAc[01,02])			//[02] - ID do Usuário
				aAdd(aRet,aUserAc[01,01])			//[03] - Código do Usuário
				aAdd(aRet,aUserAc[01,04])			//[04] - Nome do Usuário
				aAdd(aRet,aUserAc[01,14])			//[05] - E-mail do Usuário
				aAdd(aRet,aUserAc[01,23,02])		//[06] - Quantidade de dias permitida para retroceder a bada base
				aAdd(aRet,.T.)                      //[07] - Retorno do acesso
				aAdd(aRet,aAcessos)					//[08] - Acesso a rotina solicitada
				aAdd(aRet,"")					    //[09] - Retorno do erro
			Else
				aAdd(aRet,ValUsr(aUserAc))		    // [01] - Usuário Ativo e Permissões de horarios
				aAdd(aRet,aUserAc[01,02])			// [02] - ID do Usuário
				aAdd(aRet,aUserAc[01,01])			// [03] - Código do Usuário
				aAdd(aRet,aUserAc[01,04])			// [04] - Nome do Usuário
				aAdd(aRet,aUserAc[01,14])			// [05] - E-mail do Usuário
				aAdd(aRet,aUserAc[01,23,02])		// [06] - Quantidade de dias permitida para retroceder a bada base
				aAdd(aRet,.F.)                      // [07] - Retorno do acesso
				aAdd(aRet,{})					    // [08] - Acesso a rotina solicitada
				aAdd(aRet,aAcessos[1])	            // [09] - Retorno do erro
			EndIf
		EndIf
	Else
		aAdd(aRet,"" )   
		aAdd(aRet,"" )
		aAdd(aRet,"" )
		aAdd(aRet,"" )
		aAdd(aRet,"" )
		aAdd(aRet,"" )
		aAdd(aRet,.F.)
		aAdd(aRet,{} )
		aAdd(aRet,"Nao eh permitido utilizar o acesso do usuario Admin.")   
	EndIf	
Return aRet



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ValUsr                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para validar Usuário                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function ValUsr(aUser)
Local lRet := .T.
Local cHoras := IIF(Len(aUser[02,01])<=0,"23:59:59",aUser[02,01,Dow(Date())])


	If aUser[01,17] //Usuário Bloqueado
		lRet := .F.
	ElseIf !(Time() >= SubStr(cHoras,1,5) .And. Time() <= SubStr(cHoras,7,5)) //Dias da semana e horarios de acessos
		lRet := .F.
	EndIf

Return lRet



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ValAce                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para validar acessos                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function ValAce(cCodUsr, nCodMod, cRotina,oEventLog,cElTime)
Local aRet		:= {}
Local aValid	:= {}
Local nPosPes	:= 0
Local nPosVis	:= 0
Local nPosInc	:= 0
Local nPosAlt	:= 0
Local nPosExc	:= 0
Local aMenu		:= FWGetMnuAccess(cCodUsr,nCodMod)
Local cElTime   := Time()

	ConOut("-> Fim da validação do acesso do usuario no configurador as "+Time()+" hs")

	If Len(aMenu[04]) > 0
		cElTime:=Time()
		ConOut("-> Validando acesso do usuario no menu as "+Time()+" hs")
		aValid := u_ValArray(aMenu[04],cRotina)
		ConOut("-> Fim da validação do acesso do usuario no menu as "+Time()+" hs")

		If aValid[1]

			nPosPes := aScan(aValid[2],{ |X| Upper(Alltrim(X[1])) == "PESQUISAR"})
			nPosVis := aScan(aValid[2],{ |X| Upper(Alltrim(X[1])) == "VISUALIZAR"})
			nPosInc := aScan(aValid[2],{ |X| Upper(Alltrim(X[1])) == "INCLUIR"})
			nPosAlt := aScan(aValid[2],{ |X| Upper(Alltrim(X[1])) == "ALTERAR"})
			nPosExc := aScan(aValid[2],{ |X| Upper(Alltrim(X[1])) == "EXCLUIR"})
				
			If nPosAlt == 0
				nPosAlt := aScan(aValid[2],{ |X| Upper(Alltrim(X[1])) == "CLASSIFICAR"})
			EndIF
				
			// -> Monta array de acessos 
			//-> Caso não encontre a opção, preenche com .F.
			aRet := 	{;
							If (nPosPes != 0,aValid[2][nPosPes,3],.F.),;
							If (nPosVis != 0,aValid[2][nPosVis,3],.F.),;
							If (nPosInc != 0,aValid[2][nPosInc,3],.F.),;
							If (nPosAlt != 0,aValid[2][nPosAlt,3],.F.),;
							If (nPosExc != 0,aValid[2][nPosExc,3],.F.);
						}
							
		Else
			aAdd(aRet,"Rotina nao esta disponivel para este usuario. [" + cRotina + "]")
		EndIf		

	Else
		aAdd(aRet,"Modulo nao cadastrado para o usuario. Usuario [" + UsrRetName(cCodUsr) + "] - Modulo [" + cValToChar(nCodMod) + "]")
	EndIf
	
Return aRet



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ValArray                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa array do menu do usuário                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/11/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
User function ValArray(aArray, cRotina)
Local lValid 	:= .F.
Local nX		:= 1
Local aArrayAux	:= {}
Local aRet		:=	{}

	For  nX := 1 to LEN(aArray)
		If UPPER(ValType(aArray[nX][2])) != "C"
			aRet := u_ValArray(aArray[nX][2], cRotina)
		Else
			aRet := u_FindRot(aArray, cRotina)
		EndIf

		lValid := aRet[1]
		If lValid
			Exit
		EndIf
	Next nX

	If lValid
		aArrayAux := aRet[2]
	EndIf
Return {lValid,aArrayAux}                                         



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! FindRot                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa array do menu do usuário e busca rotina                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/11/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
User Function FindRot(aArray, cRotina)
Local lFind     := .F.
Local Index	    := 0
Local nY	    := 0 
Local aArrayAux := {}
 
	// -> Verifica os acessos
	For nY := 1 to LEN(aArray)
		Index := aScan(aArray[nY], Upper(cRotina))
		If Index > 0
			lFind:=AllTrim(aArray[nY,Index]) == AllTrim(Upper(cRotina))
			aArrayAux := aArray[nY][4]
			Exit
		EndIf
	Next nY

Return {lFind, aArrayAux}