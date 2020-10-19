/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras	                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para retorno de informações de aprovadores	!
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Bahl e Dotti										!
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 15/10/2014														!
+------------------+---------------------------------------------------------+
!                               ATUALIZACOES                                 !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH" 
#INCLUDE "TOPCONN.CH"

wsservice wsPWAlcadaTCP description "Webservice retorno cadastro de aprovadores/grupos de aprovadores"

	// DECLARACAO DAS VARIVEIS GERAIS	
	wsdata sFILIAL as string
	wsdata cGRUPO as string
	wsdata nVALOR as float

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oAprovador as PWAprovador_Struct
	wsdata oAprovadores as array of PWAprovador_Struct
	
	// DELCARACAO DO METODOS
	wsmethod GetAppByValue description "Retorna o aprovador baseado no valor informado"
	wsmethod GetTabAprova description "Retorna a tabela de niveis de aprovacao do Protheus"
		
endwsservice

/*
+------------+---------------------------------------------------------------+
! Funcao     ! GetAppByValue														!
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna o aprovador da requisicao com base no grupo/valor		!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetAppByValue wsreceive sFILIAL, cGRUPO, nVALOR wssend oAprovador wsservice wsPWAlcadaTCP
	
	local aArea := GetArea()
	
	sFILIAL := IIF(Empty(sFILIAL), xFilial("SAL"), sFILIAL)
	
	SAK->(dbSetOrder(1))
	SAL->(dbSetOrder(2))
	SAL->(dbSeek(sFILIAL + cGRUPO))
	while !SAL->(eof()) .and. SAL->(AL_FILIAL + AL_COD) == sFILIAL + cGRUPO
		if SAK->(dbSeek(SAL->(AL_FILIAL + AL_APROV)))
			if SAK->AK_LIMMIN <= nVALOR .and. nVALOR <= SAK->AK_LIMMAX
				::oAprovador:cCODAPR := SAK->AK_COD
				::oAprovador:cCODUSR := SAK->AK_USER
				::oAprovador:cNOME := SAK->AK_NOME
			endif
		endif
		SAL->(dbSkip())
	enddo

	RestArea(aArea)
return .T.

/*
+------------+---------------------------------------------------------------+
! Funcao     ! GetTabAprova															!
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna a tabela de aprovadores completa (grupo)				!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetTabAprova wsreceive sFILIAL, cGRUPO wssend oAprovadores wsservice wsPWAlcadaTCP
	
	local aArea := GetArea()
	
	sFILIAL := IIF(Empty(sFILIAL), xFilial("SAL"), sFILIAL)
	
	SAK->(dbSetOrder(1))
	SAL->(dbSetOrder(2))
	SAL->(dbSeek(sFILIAL + cGRUPO))
	
	while !SAL->(eof()) .and. SAL->(AL_FILIAL + AL_COD) == sFILIAL + cGRUPO
		if SAK->(dbSeek(SAL->(AL_FILIAL + AL_APROV)))
			
			oPWAprov := WSClassNew("PWAprovador_Struct")
			
			oPWAprov:CODAPR := SAK->AK_COD
			oPWAprov:CODUSR := SAK->AK_USER
			oPWAprov:NOME := SAK->AK_NOME
			
			oPWAprov:ValMin := SAK->AK_LIMMIN
			oPWAprov:ValMax := SAK->AK_LIMMAX
			
			aAdd(::oAprovadores, oPWAprov)
		endif
		SAL->(dbSkip())
	enddo

	RestArea(aArea)
return .T.


// Definicao das estruturas de retorno

// Estrutura de um aprovador
wsstruct PWAprovador_Struct
	wsdata CodApr AS string
	wsdata CodUsr AS string
	wsdata Nome AS string
	
	wsdata ValMin as float optional
	wsdata ValMax as float optional
endwsstruct

//user function MT120APV()

//	alert("passou por aqui \| liberado: " + cValToCHar(n120TotLib))
//return