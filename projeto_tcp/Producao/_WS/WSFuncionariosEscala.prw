/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Financiero                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para enviar dados dos títulos a pagar!
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/07/2018                                              !
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
#INCLUDE "TBICONN.CH"

wsStruct StFuncionarios

	wsdata Nome                   as string 
	wsdata Matricula              as string 
	wsdata CentroCusto            as string 
	wsdata CodigoFuncao           as string 
	wsdata DescricaoFuncao        as string 
	wsdata DataAdmissao          as date 
	wsdata DataDemissao           as date Optional
	wsdata DataAlteracaoFuncao    as date 
	wsdata Telefone               as string 
	wsdata Logradouro             as string 
	wsdata Numero                 as string 
	wsdata Complemento            as string 
	wsdata Bairro                 as string 
	wsdata Cidade                 as string 
	wsdata CEP                    as string 
	wsdata Pais                   as string 
	wsdata Afastamentos           as Array of StAfastamentos       Optional  

endWsStruct

wsStruct StAfastamentos

	wsdata TipoAfastamento        as string 
	wsdata DescricaoAfastamento   as string 
	wsdata DataInicioAfastamento  as date 
	wsdata DataFimAfastamento     as date Optional 

endWsStruct

WSSTRUCT StJornadas
     WSDATA JORNADA			    As Array Of StJornada
ENDWSSTRUCT

wsStruct StJornada
	wsdata Operacao           	  as string
	wsdata Matricula           	  as string 
	wsdata CentroCusto        	  as string 
	wsdata DataEscala          	  as date 
	wsdata PERIODO01       	  	  as string //1=Normal;2=Supressão;3=Trab.Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata PERIODO02       	  	  as string //1=Normal;2=Supressão;3=Trab.Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata PERIODO03       	  	  as string //1=Normal;2=Supressão;3=Trab.Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata PERIODO04       	  	  as string //1=Normal;2=Supressão;3=Trab.Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata Escalado           	  as string  
	//wsdata OperouGm           	  as boolean  
	//wsdata Horarios               as Array of StHorarios         
endWsStruct

wsStruct StHorarios
	//wsdata Turno           	  as string  //1234
	wsdata PERIODO01       	  as string //1=Normal;2=Supressão;3=Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata PERIODO02       	  as string //1=Normal;2=Supressão;3=Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata PERIODO03       	  as string //1=Normal;2=Supressão;3=Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata PERIODO04       	  as string //1=Normal;2=Supressão;3=Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Suspensão
	wsdata Escalado           as string         
endWsStruct

wsStruct StRetornoJornadas
	wsdata Matricula       	  as string  
	wsdata Status          	  as boolean 
	wsdata Erro               as string         
endWsStruct

WSSERVICE WsFuncionariosEscala  description "WebService para consultar dados do funcionário e marcar a escala de trabalho."

	// DECLARACAO DAS VARIVEIS GERAIS	
	wsdata Usuario 		 		 as string 	
	wsdata Senha 		 		 as string 	
	wsdata CentroCusto 	 		 as string 
	//O solicitante envia a data da última consulta, para filtrarmos os demitidos a partir deste dia.
	wsdata DataUltimaConsulta	 as date 
	
	wsdata Jornadas  as  StJornadaS
	
	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oStFuncionarios  as Array of StFuncionarios
	wsdata oStAfastamentos  as Array of StAfastamentos
	wsdata oStRetornoJornadas		as Array of StRetornoJornadas
	
	// DELCARACAO DO METODOS
	WSMETHOD FUNCIONARIOS   description "Retorna todos os funcionários de um determinado centro de custo."
	WSMETHOD GRAVAESCALA   description "Grava a escala."
	
endWSSERVICE

/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna os títulos em aberto!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
WSMETHOD FUNCIONARIOS WSRECEIVE Usuario,Senha,CentroCusto,DataUltimaConsulta WSSEND oStFuncionarios WSSERVICE WsFuncionariosEscala
	lOCAL dDataFunc := CTOD('  /  /    ')
	lOCAL cAlias
	Local cAliasFunc
	Local dDtUltC   := ::DataUltimaConsulta
	Local cCc       := ::CentroCusto
	
	cErro := validaPar('1',::Usuario,::Senha,::CentroCusto,dDtUltC)

	if !empty(cErro)
		SetSoapFault("Consulta FUNCIONARIOS",cErro)		 			
		Return .F.
	EndIf
	
	cAliasFunc := getNextAlias()

	BeginSQL Alias cAliasFunc

		SELECT RA_MAT,RA_FILIAL,RA_NUMENDE,RA_CODFUNC,RA_CC,RA_NOMECMP,RA_ADMISSA,RA_DEMISSA,RA_NUMCELU,RA_ENDEREC,RA_LOGRNUM,RA_COMPLEM,RA_BAIRRO,
		RA_CODMUN,RA_ESTADO,RA_CEP,RA_CPAISOR
		FROM %TABLE:SRA% SRA
		WHERE SRA.%NotDel% AND RA_FILIAL = %EXP:xFilial('SRA')% AND (RA_DEMISSA = ' ' OR RA_DEMISSA >= %EXP:DTOS(dDtUltC)%)
		AND RA_CC = %EXP:ALLTRIM(cCc)%
		ORDER BY RA_NOMECMP

	EndSQL
	
	dbSelectArea('SRA')
	DbsetOrder(2)
	IF !(cAliasFunc)->(Eof())

		while !(cAliasFunc)->(Eof()) 
			
			cAlias := getNextAlias()

			BeginSQL Alias cAlias

				SELECT R7_DATA
				FROM %TABLE:SR7% SR7
				WHERE SR7.%NotDel% AND R7_FILIAL = %EXP:(cAliasFunc)->RA_FILIAL% AND R7_MAT = %EXP:(cAliasFunc)->RA_MAT% AND R7_FUNCAO <> %EXP:(cAliasFunc)->RA_CODFUNC%
				ORDER BY R7_DATA DESC

			EndSQL

			
			
			dDataFunc := CTOD('  /  /    ')
			IF !(cAlias)->(Eof())
				dDataFunc := STOD((cAlias)->R7_DATA)
			ENDIF
			(cAlias)->(dbclosearea())
			
			
			AAdd(oStFuncionarios, WsClassNew("StFuncionarios"))
			oStFuncionarios[len(oStFuncionarios)]:Nome                 := (cAliasFunc)->RA_NOMECMP
			oStFuncionarios[len(oStFuncionarios)]:Matricula            := (cAliasFunc)->RA_MAT
			oStFuncionarios[len(oStFuncionarios)]:CentroCusto          := (cAliasFunc)->RA_CC
			oStFuncionarios[len(oStFuncionarios)]:CodigoFuncao         := (cAliasFunc)->RA_CODFUNC
			oStFuncionarios[len(oStFuncionarios)]:DescricaoFuncao      := POSICIONE('SRJ',1,xFilial('SRJ')+(cAliasFunc)->RA_CODFUNC,'RJ_DESC')
			oStFuncionarios[len(oStFuncionarios)]:DataAdmissao         := STOD((cAliasFunc)->RA_ADMISSA)
			if(!empty((cAliasFunc)->RA_DEMISSA))
				oStFuncionarios[len(oStFuncionarios)]:DataDemissao     := STOD((cAliasFunc)->RA_DEMISSA)
			endif
			oStFuncionarios[len(oStFuncionarios)]:DataAlteracaoFuncao  := dDataFunc
			oStFuncionarios[len(oStFuncionarios)]:Telefone             := (cAliasFunc)->RA_NUMCELU
			oStFuncionarios[len(oStFuncionarios)]:Logradouro           := (cAliasFunc)->RA_ENDEREC
			oStFuncionarios[len(oStFuncionarios)]:Numero               := IF(!EMPTY(ALLTRIM((cAliasFunc)->RA_NUMENDE)),ALLTRIM((cAliasFunc)->RA_NUMENDE),ALLTRIM((cAliasFunc)->RA_LOGRNUM))
			oStFuncionarios[len(oStFuncionarios)]:Complemento          := (cAliasFunc)->RA_COMPLEM 
			oStFuncionarios[len(oStFuncionarios)]:Bairro               := (cAliasFunc)->RA_BAIRRO
			oStFuncionarios[len(oStFuncionarios)]:Cidade               := POSICIONE('CC2',1,xFilial('CC2')+(cAliasFunc)->RA_ESTADO +(cAliasFunc)->RA_CODMUN,'CC2_MUN')
			oStFuncionarios[len(oStFuncionarios)]:CEP                  := (cAliasFunc)->RA_CEP
			oStFuncionarios[len(oStFuncionarios)]:Pais                 := POSICIONE('CCH',1,xFilial('CCH')+(cAliasFunc)->RA_CPAISOR,'CCH_PAIS')
			
			cAlias := getNextAlias()

			BeginSQL Alias cAlias

				SELECT *
				FROM %TABLE:SR8% SR8
				WHERE SR8.%NotDel% AND R8_FILIAL = %EXP:(cAliasFunc)->RA_FILIAL% AND R8_MAT = %EXP:(cAliasFunc)->RA_MAT% AND R8_DATAFIM >= %EXP:DTOS(DATE())%
				ORDER BY R8_DATAINI DESC

			EndSQL


			IF !(cAlias)->(Eof())
				oStFuncionarios[len(oStFuncionarios)]:Afastamentos := {}
			
				WHILE !(cAlias)->(Eof())
					aadd(oStFuncionarios[len(oStFuncionarios)]:Afastamentos, WSClassNew("StAfastamentos"))
			
					oStFuncionarios[len(oStFuncionarios)]:Afastamentos[len(oStFuncionarios[len(oStFuncionarios)]:Afastamentos)]:TipoAfastamento       := (cAlias)->R8_TIPOAFA
					oStFuncionarios[len(oStFuncionarios)]:Afastamentos[len(oStFuncionarios[len(oStFuncionarios)]:Afastamentos)]:DescricaoAfastamento  := POSICIONE('RCM',1,xFilial('RCM')+(cAlias)->R8_TIPOAFA,'RCM_DESCRI')
					oStFuncionarios[len(oStFuncionarios)]:Afastamentos[len(oStFuncionarios[len(oStFuncionarios)]:Afastamentos)]:DataInicioAfastamento := STOD((cAlias)->R8_DATAINI)
					if(!empty((cAlias)->R8_DATAFIM))
						oStFuncionarios[len(oStFuncionarios)]:Afastamentos[len(oStFuncionarios[len(oStFuncionarios)]:Afastamentos)]:DataFimAfastamento    := STOD((cAlias)->R8_DATAFIM)
					endif
	
					(cAlias)->(DbSkip())
				ENDDO
			ENDIF
			(cAlias)->(dbclosearea())
			
			/*
			aadd(oStFuncionarios[len(oStFuncionarios)]:Afastamentos, WSClassNew("StAfastamentos"))
			
			oStFuncionarios[len(oStFuncionarios)]:Afastamentos[1]:TipoAfastamento
			oStFuncionarios[len(oStFuncionarios)]:Afastamentos[1]:DescricaoAfastamento
			oStFuncionarios[len(oStFuncionarios)]:Afastamentos[1]:DataInicioAfastamento
			oStFuncionarios[len(oStFuncionarios)]:Afastamentos[1]:DataFimAfastamento
			*/

			(cAliasFunc)->(DbSkip())

		enddo 	
	ELSE	
		SetSoapFault("Consulta FUNCIONARIOS",'Não existe nenhum funcionário vinculado a este centro de custo. Centro de Custo: '+CentroCusto)		 			
		Return .F.
	ENDIF
	
	
	(cAliasFunc)->(dbclosearea())
	
return .T. /* fim do metodo  */



/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna os títulos em aberto!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
WSMETHOD GRAVAESCALA WSRECEIVE Usuario,Senha,Jornadas WSSEND oStRetornoJornadas WSSERVICE WsFuncionariosEscala
	Local cErro     := ''
	Local cMatric   := ''
	Local dDataEscala 
	Local cTurno    := ''
	Local cSeqTur   := ''
	Local cErroFun  := ''
	Local cTpTurno  := ''
	Local lRetFunc  := .T.
	Local cUltTurn  := ''
	Local cUltSeq   := ''
	Local oJornadas := ::Jornadas
	
	Local aInclui := {} 
	Local aAltera := {} 
	Local aCancel := {} 
	
	Local nRecLog 
	Local cCodigo := GETSX8NUM("ZZI","ZZI_CODIGO")
	Local ccAutom := GETMV('TCP_CCAUT')
	//Array com os possíveis horários de entrada para deste dia, de acordo com a configuração do turno
	Local aEntDia := {}
	Local nQtdHoras := 0
	Local nTotHoras := 0
	Local nDiaEscala 
	Local cTpDia    := '' 
	Local nInd
	PRIVATE lMsErroAuto := .F.
	//turnos devem estar no SX6
	Private cT01 := Alltrim(GetNewPar("TCP_TNO1", "M01"))
	Private cT02 := Alltrim(GetNewPar("TCP_TNO2", "M02"))
	Private cT03 := Alltrim(GetNewPar("TCP_TNO3", "M03"))
	Private cT04 := Alltrim(GetNewPar("TCP_TNO4", "M04"))
	Private cT13 := Alltrim(GetNewPar("TCP_TNO5", "M01"))
	Private cT14 := Alltrim(GetNewPar("TCP_TNO6", "M01"))
	Private cT24 := Alltrim(GetNewPar("TCP_TNO7", "M02"))
	Private cT08 := Alltrim(GetNewPar("TCP_TNO8", "M14"))
	
	cErro := validaPar('2',::Usuario,::Senha)

	if !empty(cErro)
		
		AAdd(oStRetornoJornadas, WsClassNew("StRetornoJornadas"))
		oStRetornoJornadas[len(oStRetornoJornadas)]:Matricula :=  cMatric
		oStRetornoJornadas[len(oStRetornoJornadas)]:Status 	  :=  .F.
		oStRetornoJornadas[len(oStRetornoJornadas)]:Erro      :=  cErro 
	
	ELSE
	
		FOR nInd := 1 to LEN(oJornadas:Jornada)	
			
			nRecLog := GRAVAlOG(cCodigo,oJornadas:Jornada[nInd])
			
			cTpTurno := ALLTRIM(oJornadas:Jornada[nInd]:PERIODO01+oJornadas:Jornada[nInd]:PERIODO02+oJornadas:Jornada[nInd]:PERIODO03+oJornadas:Jornada[nInd]:PERIODO04)
			
			cTpTurno := caracEsp(cTpTurno)
			
			cMatric 	:= oJornadas:Jornada[nInd]:MATRICULA
			dDataEscala := oJornadas:Jornada[nInd]:DATAESCALA
			
			lRetFunc := .T.
			cErroFun := ''
			
			IF dDataEscala > DATE()
				lRetFunc := .F.
				cErroFun := 'Não é possível cadastrar uma chamada de trabalho com data futura. Data'+DTOC(dDataEscala)
			elseif(! (ALLTRIM(oJornadas:Jornada[nInd]:CENTROCUSTO) $ ALLTRIM(ccAutom)))
				lRetFunc := .F.
				cErroFun := 'Centro de custo '+oJornadas:Jornada[nInd]:CENTROCUSTO+' não autorizado para chamada de trabalho automática.'
				
			elseIF(oJornadas:Jornada[nInd]:OPERACAO == 'I' .OR. (oJornadas:Jornada[nInd]:OPERACAO == 'A'))
				
				lRetFunc  := .T.
			
				cAlias := getNextAlias()
		
				BeginSQL Alias cAlias
		
					SELECT PF_TURNOPA,PF_SEQUEPA,RA_TNOTRAB,RA_REGRA,PF_DATA,RA_SEQTURN
					FROM %TABLE:SRA% SRA
					LEFT JOIN %TABLE:SPF% SPF ON PF_FILIAL = RA_FILIAL AND PF_MAT = RA_MAT AND PF_DATA <= %EXP:DTOS(dDataEscala)% AND SPF.%NotDel%
					WHERE SRA.%NotDel% AND RA_FILIAL = %EXP:xFilial('SRA')% AND RA_MAT = %EXP:cMatric% 
					ORDER BY PF_DATA DESC
		
				EndSQL
				
				
				IF !(cAlias)->(Eof())
					cUltSeq    := 01
					if (empty((cAlias)->RA_TNOTRAB))
						lRetFunc := .F.
						cErroFun := 'Funcionário não possui turno cadastrado. Matricula '+cMatric
					Else
						cUltTurn := IF (!EMPTY((cAlias)->PF_TURNOPA),(cAlias)->PF_TURNOPA,(cAlias)->RA_TNOTRAB)
						cUltSeq := IF (!EMPTY((cAlias)->PF_SEQUEPA),(cAlias)->PF_SEQUEPA,(cAlias)->RA_SEQTURN)
						cTurno  := (cAlias)->RA_TNOTRAB
					endif
				ELSE
					lRetFunc := .F.
					cErroFun := 'Funcionário não encontrado. Matricula '+cMatric
				EndIf
				
				(cAlias)->(dbclosearea())
				
				IF lRetFunc
					nDiaEscala := DOW(dDataEscala)
					aEntDia := HorasDia(cUltTurn,cUltSeq,nDiaEscala,@nQtdHoras,@nTotHoras,@cTpDia)
					
					if LEN(aEntDia) == 0
						lRetFunc := .F.
						cErroFun := 'Não existe horário válido cadastrado para este dia. Matricula'+cMatric +' Data: '+DTOC(dDataEscala)
					elseif nQtdHoras == 0
						lRetFunc := .F.
						cErroFun := 'Não foi encontrada a quantidade de horas do turno. Matricula'+cMatric +' Data: '+DTOC(dDataEscala)
					ELSE
						
						nHrInic  := 0
						nSegInic := 0
						nHrDobra := 0
						
						IF( 'A' $ cTpTurno )
							if !EMPTY(oJornadas:Jornada[nInd]:PERIODO01) .AND. oJornadas:Jornada[nInd]:PERIODO01 != 'A'
								nSegInic := HoraPadrao('2')
							ELSE
								nHrInic := HoraPadrao('1')
							ENDIF
							
						ENDIF
						
						IF( '8' $ cTpTurno .OR.  '3' $ cTpTurno )
							//DSR
							gravaExe('D',cMatric,dDataEscala)
						
						ELSEIF EMPTY(ALLTRIM( cTpTurno))
							//TRAB=NAO
							gravaExe('N',cMatric,dDataEscala)
						//1=Normal;2=Adicional(Supressão);3=Trab.Folga;4=Recusa;5=Falta;6=Falta sem contato;7=Dobra;8=Folga;9=Feriado;A=Supensão
						//Se era para trabalhar, e não foi. Tanto faz a hora do turno, só exclui possíveis exceções
						ELSEIF( '9' $ cTpTurno)
							excExce(cMatric,dDataEscala)
						ELSEIF('1' $ cTpTurno .OR. '2' $ cTpTurno .OR. '7' $ cTpTurno .OR. '4' $ cTpTurno .OR. '5' $ cTpTurno .OR. '6' $ cTpTurno .OR. 'A' $ cTpTurno )
						
							//Descobre a hora de início da jornada dele
							IF oJornadas:Jornada[nInd]:PERIODO01 $ '1|2|3|4|5|6|7'
								
								IF oJornadas:Jornada[nInd]:PERIODO01 $ '2|3|7'
									nHrDobra := HoraPadrao('1')
								ELSEif nHrInic == 0
									nHrInic := HoraPadrao('1')
								else
									nSegInic := HoraPadrao('1')
								endif
							endif
							IF oJornadas:Jornada[nInd]:PERIODO02 $ '1|2|3|4|5|6|7'
							
								IF oJornadas:Jornada[nInd]:PERIODO02 $ '2|3|7'
									nHrDobra := HoraPadrao('2')
								ELSEif nHrInic == 0
									nHrInic := HoraPadrao('2')
								else
									nSegInic := HoraPadrao('2')
								endif
							endif
							IF oJornadas:Jornada[nInd]:PERIODO03 $ '1|2|3|4|5|6|7'
							
								IF oJornadas:Jornada[nInd]:PERIODO03 $ '2|3|7'
									nHrDobra := HoraPadrao('3')
								ELSEif nHrInic == 0
									nHrInic := HoraPadrao('3')
								else
									nSegInic := HoraPadrao('3')
								endif
							endif
							IF oJornadas:Jornada[nInd]:PERIODO04 $ '1|2|3|4|5|6|7'
							
								IF oJornadas:Jornada[nInd]:PERIODO04 $ '2|3|7' 
									nHrDobra := HoraPadrao('4')
								ELSEif nHrInic == 0
									nHrInic := HoraPadrao('4')
								else
									nSegInic := HoraPadrao('4')
								endif
							ENDIF
							
							IF nHrInic == 0 .AND. nHrDobra ==0
								lRetFunc := .F.
								cErroFun := 'Não foi encontrado período válido para a exceção. Matricula'+cMatric +' Data: '+DTOC(dDataEscala)
							ENDIF
							
							if lRetFunc
							
								IF  nHrInic == 0 .AND. nSegInic != 0
									nHrInic := nSegInic
								ENDIF
								
								//Se ele trabalhou apenas em extra, tratamos como não escalado
								if nHrInic == 0 .AND. nHrDobra != 0
									gravaExe('N',cMatric,dDataEscala)
								ELSE
									gravaExe('S',cMatric,dDataEscala,nHrInic,nQtdHoras,nSegInic,IF(nSegInic>0,nQtdHoras,0))
								ENDIF
//									ELSE
//										excExce(cMatric,dDataEscala)
//									ENDIF
							endif
							
						endif
					ENDIF
					
					
					IF lRetFunc
						dbSelectArea('ZP0')
						ZP0->(dbSetOrder(1))
						if ZP0->(dbSeek(xFilial("ZP0")+cMatric+DTOS(dDataEscala)))
	//						aadd(aAltera,{cMatric,dDataEscala})
							Reclock("ZP0",.f.)
						ELSE	
	//						aadd(aInclui,{cMatric,dDataEscala})
							Reclock("ZP0",.T.)
						EndIf
						
						ZP0->ZP0_FILIAL  := xFilial("ZP0")
						ZP0->ZP0_MAT  	 := cMatric
						ZP0->ZP0_DATA  	 := dDataEscala
						
						if  '3' $ cTpTurno .OR. '8' $ cTpTurno
							
							ZP0->ZP0_ESCALA   := ' '
						else
							ZP0->ZP0_ESCALA   := IF(EMPTY(ALLTRIM( cTpTurno)),'N',oJornadas:Jornada[nInd]:ESCALADO)
						endif
						ZP0->ZP0_PER01   := oJornadas:Jornada[nInd]:PERIODO01
						ZP0->ZP0_PER02   := oJornadas:Jornada[nInd]:PERIODO02
						ZP0->ZP0_PER03   := oJornadas:Jornada[nInd]:PERIODO03
						ZP0->ZP0_PER04   := oJornadas:Jornada[nInd]:PERIODO04
						ZP0->ZP0_TNOSEQ   := cUltTurn+'/'+cUltSeq
						ZP0->ZP0_CONTA    := 0
						ZP0->ZP0_DTALT    := DATE()
						
						ZP0->(Msunlock())
					endif
				ENDIF
			ELSE
				lRetFunc := .F.
				cErroFun := 'Operação inválida. Operação:'+oJornadas:Jornada[nInd]:OPERACAO
			ENDIF
			
			AAdd(oStRetornoJornadas, WsClassNew("StRetornoJornadas"))
			oStRetornoJornadas[len(oStRetornoJornadas)]:Matricula :=  cMatric
			oStRetornoJornadas[len(oStRetornoJornadas)]:Status 	  :=  lRetFunc
			oStRetornoJornadas[len(oStRetornoJornadas)]:Erro      :=  cErroFun        
			
			atuLog(nRecLog,cErroFun, '')
			
		NEXT
		
		ConfirmSX8() 
	ENDIF
	
	if LEN(aInclui) > 0 .OR. LEN(aAltera) > 0 .OR. LEN(aCancel) > 0
		STARTJOB("U_MAILTRAB", GetEnvServer(), .F., cEmpAnt, cFilAnt,aInclui,aAltera,aCancel)
	endif
	
return .T. /* fim do metodo  */


static function validaPar(cTpWs, cUsuWs,cPassWs,cCentroCusto,DataUltCons)
	Local cErro := ''
	Local cUsuario 	:= GetNewPar("TCP_WSPGUS",'tcp')
	Local cSenha 	:= GetNewPar("TCP_WSPGSN",'yTX27qkuwm')

	If Empty(cUsuWs)
		cErro := "Informe o usuário."	
	EndIf

	If Empty(cPassWs)
		cErro := "Informe a senha."
	EndIf

	If ALLTRIM(cUsuWs) != cUsuario
		cErro := "Usuário inválido."
	EndIf

	If ALLTRIM(cPassWs) != cSenha
		cErro :="Senha inválida."
	EndIf


	if cTpWs == '1'
		
		If Empty(cCentroCusto)
			cErro :="Informe o Centro de Custo."
		EndIf
		
		dbSelectArea('CTT')
		DbsetOrder(1)
		IF !CTT->(DBSeek(xFilial('CTT')+ALLTRIM(cCentroCusto)))
			cErro :="Centro de Custo inválido. Centro de Custo: "+cCentroCusto
		endif	
		
		IF(EMPTY(DataUltCons) )
			cErro :="Data da última consulta não pode ser vazia."
		ENDIF
		
		IF(VALTYPE(DataUltCons) != 'D')
			cErro :="Data da última consulta inválida."
		ENDIF
	ENDIF
return cErro


static function gravaLog(cCodigo,oEscala)

	dbSelectArea('ZZI')
	RecLock("ZZI",.T.)
	ZZI->ZZI_FILIAL := xFilial('ZZE')
	ZZI->ZZI_CODIGO := cCodigo
	ZZI->ZZI_CC	    := oEscala:CENTROCUSTO
	ZZI->ZZI_DTESCA	:= oEscala:DATAESCALA
	ZZI->ZZI_ESCALA	:= oEscala:ESCALADO
	ZZI->ZZI_MAT   	:= oEscala:MATRICULA
	ZZI->ZZI_OPERAC	:= oEscala:OPERACAO
	ZZI->ZZI_PER01  := oEscala:PERIODO01
	ZZI->ZZI_PER02  := oEscala:PERIODO02
	ZZI->ZZI_PER03  := oEscala:PERIODO03
	ZZI->ZZI_PER04  := oEscala:PERIODO04
	
	ZZI->ZZI_DATA   :=  DATE()
	ZZI->ZZI_HORA   :=  TIME()
	
	ZZI->(msUnlock())
	
	
	
return ZZI->(RECNO())

static function atuLog(cCodLog,cErro,cTurno)
	dbSelectArea('ZZI')
	ZZI->(DbGoto(cCodLog))
	RecLock("ZZI",.F.)
	ZZI->ZZI_TURNO := cTurno
	ZZI->ZZI_ERRO  := cErro
	
	ZZI->(msUnlock())
return
//
//static function intTaf(_cMat,_cTurno,_cSeqturno,_dDtTroca)
//
//Static lPonap160Block
//Static lIncluir:= .F. 
//Static lIntegDef 	:= FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI")
//Static cAA1Fil	:= ""
//Static lInteRHAA1	:= If(FindFunction("IntegRHAA1"),IntegRHAA1(),.F.)
////Integração com o TAF
//Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.,cFilAnt) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ',cFilAnt)) >= 1 )
//Static lEFDMsg		:= SuperGetMv("MV_EFDMSG",,.F.)
//Static cVersEnvio	:= ""
//Static cVersGPE		:= ""
//
//Local aErros:= {}	 
//
//DbSelectArea('SRA')
//SRA->(DBSetOrder(1))
//SRA->(DBSeek(xFilial('SRA')+_cMat))
//
//DBSelectArea("SX3")
//DBSetOrder(01)
//DBGoTop()
//If SX3->(dbSeek("SRA"))
//	While !SX3->(Eof()).And. SX3->X3_ARQUIVO == "SRA"
//		IF SX3->X3_CONTEXT != 'V'
//			M->&(SX3->X3_CAMPO) := SRA->&(SX3->X3_CAMPO)
//		ENDIF
//		SX3->(DBSkip())
//	EndDo
//EndIf
//
//M->RA_MAT := SRA->RA_MAT
//
//If FindFunction("fVersEsoc")
//	fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE )
//EndIf
//lAtuTaf:= fInt2206("SRA",,,"S2206",,,_cTurno,SRA->RA_REGRA,_cSeqturno,,cVersEnvio,,_dDtTroca,,,aErros)
//
//return

static function excTrocaTurno(_oJornada)

Local dDataEscala := _oJornada:DATAESCALA
Local cMatric 	  := _oJornada:MATRICULA
Local cTurnoDe    := ''
Local cSeqDe      := ''
Local nRecSpf     := 0	
		
dbSelectArea('SPF')
SPF->(DbSetOrder(1))

If SPF->(DbSeek(Xfilial("SPF")+cMatric+dtos(dDataEscala)))
	
	RecLock("SPF", .F.)
	SPF->(DbDelete())
	SPF->(MsUnLock())
endif

cAlias := getNextAlias()
		
BeginSQL Alias cAlias

	SELECT PF_DATA,PF_TURNOPA,PF_SEQUEPA
	FROM %TABLE:SPF% SPF
	WHERE SPF.%NotDel% AND PF_FILIAL = %EXP:xFilial('SPF')% AND PF_MAT = %EXP:cMatric% 
	AND PF_DATA < %EXP:DTOS(dDataEscala)% 
	ORDER BY PF_DATA DESC
	OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY  

EndSQL

IF !(cAlias)->(Eof())
	cTurnoDe := (cAlias)->PF_TURNOPA
	cSeqDe	 := (cAlias)->PF_SEQUEPA
ELSE
	DbSelectArea('SRA')
	SRA->(DBSetOrder(1))
	SRA->(DBSeek(xFilial('SRA')+cMatric))
	
	cTurnoDe := SRA->RA_TNOTRAB
	cSeqDe	 := SRA->RA_SEQTURN
	
EndIf

(cAlias)->(dbclosearea())

atuProxTurno(dDataEscala,cTurnoDe,cSeqDe, cMatric)

if ZP0->(dbSeek(xFilial("ZP0")+cMatric+DTOS(dDataEscala)))
	RecLock("ZP0", .F.)
	ZP0->(DbDelete())
	ZP0->(MsUnLock())
ENDIF

return

static function atuProxTurno(dDataAtu,cTurno,cSeqTur, cMatric)

cAlias := getNextAlias()
		
BeginSQL Alias cAlias

	SELECT SPF.R_E_C_N_O_ AS RECSPF
	FROM %TABLE:SPF% SPF
	WHERE SPF.%NotDel% AND PF_FILIAL = %EXP:xFilial('SPF')% AND PF_MAT = %EXP:cMatric% 
	AND PF_DATA > %EXP:DTOS(dDataAtu)% 
	ORDER BY PF_DATA 
	OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY  

EndSQL

IF !(cAlias)->(Eof())
	nRecSpf := (cAlias)->RECSPF
	
	DBSelectArea('SPF')
	SPF->(DBGoTo(nRecSpf))
	RecLock("SPF", .F.)
	SPF->PF_TURNODE := cTurno
	SPF->PF_SEQUEDE := cSeqTur
	SPF->(MsUnLock())
	
ENDIF

(cAlias)->(dbclosearea())

return

STATIC FUNCTION HorasDia(cUltTurn,cUltSeq,nDiaEscala,nQtdHoras,nTotHoras,cTpDia)
Local aEntradas := {}
Local nRecSpj
DbSelectArea('SPJ')
SPJ->(DBSetOrder(1))
if SPJ->(DBSeek(xFilial('SPJ')+cUltTurn+cUltSeq+ALLTRIM(STR(nDiaEscala))))
	
	IF (SPJ->PJ_ENTRA1 > 0)
		AADD(aEntradas,SPJ->PJ_ENTRA1)
	ENDIF
	IF (SPJ->PJ_ENTRA2 > 0)
		AADD(aEntradas,SPJ->PJ_ENTRA2)
	ENDIF
	IF (SPJ->PJ_ENTRA3 > 0)
		AADD(aEntradas,SPJ->PJ_ENTRA3)
	ENDIF
	IF (SPJ->PJ_ENTRA4 > 0)
		AADD(aEntradas,SPJ->PJ_ENTRA4)
	ENDIF
	
	//Como o último turno começa a 1, e vale para o dia anterior, o turno é cadastrado para as 2359.
//	for nIndx := 1 to LEN(aEntradas)
//		if aEntradas[nIndx] == 23.59
//			aEntradas[nIndx] := 1
//		endif
//	NEXT
//	
	cTpDia    := SPJ->PJ_TPDIA
	nHrDia    := SPJ->PJ_HRTOTAL
	
	IF nHrDia == 0
		nRecSpj := SPJ->(RECNO())
		SPJ->(DBGoTop())
		if SPJ->(DBSeek(xFilial('SPJ')+cUltTurn+cUltSeq))
			While !SPJ->(Eof()).And. xFilial('SPJ')+cUltTurn+cUltSeq == SPJ->PJ_FILIAL+SPJ->PJ_TURNO +SPJ->PJ_SEMANA
				IF SPJ->PJ_TPDIA == 'S'
					nHrDia := SPJ->PJ_HRTOTAL
				ENDIF
				SPJ->(DBSkip())
			ENDDO
		ENDIF
		SPJ->(dbGoTo(nRecSpj))
		
//		IF nQtdHoras == 0
//			nQtdHoras := 6
//		ENDIF
	ENDIF
	
	//Atualmente todos os turnos são de 6 horas, porém como tem o turno da 1 que está configurado as 23.59, este fica com mais horas trabalhadas que o real
	IF(nHrDia >= 7 .AND. nHrDia <= 10)
		nHrDia    := 6
	endif
	
	nQtdHoras := ROUND(nHrDia,0)
	nTotHoras := ROUND(nHrDia,0)
	//Acima de 10 horas, tem 2 entradas
	IF nQtdHoras >10
		nQtdHoras := nQtdHoras / 2
	ENDIF
	
endif

RETURN aEntradas

//Retorna o horário padrão de início
STATIC FUNCTION HoraPadrao(cPeriodo)

Local nEntrada := 0

if cPeriodo == '1'
	nEntrada := GETNEWPAR('TCP_HRPER1', 7 )
elseif cPeriodo == '2'
	nEntrada := GETNEWPAR('TCP_HRPER2', 13 )
elseif cPeriodo == '3'
	nEntrada := GETNEWPAR('TCP_HRPER3', 19 )
elseif cPeriodo == '4'
	nEntrada := GETNEWPAR('TCP_HRPER4', 23.59 )
endif

RETURN nEntrada


static function convHora(nHora)
Local cHora
Local cSepar := ":"

cHora := Alltrim(Transform(nHora, "@E 99.99"))
         
//Se o tamanho da hora for menor que 5, adiciona zeros a esquerda
If Len(cHora) < 5
    cHora := Replicate('0', 5-Len(cHora)) + cHora
EndIf
//Atualizando o separador
cHora := StrTran(cHora, ',', cSepar)

return cHora

static function xSumHora(nHrInic,nHrFim)
Local nHrRet
Local cHraIni := convHora(nHrInic)
Local cHraFim := convHora(nHrFim)

nHrRet := SomaHoras(cHraIni, cHraFim )

if(nHrRet > 23.59)
	nHrRet := nHrRet - 24
endif

return nHrRet

static function xTotHora(nHrInic,nHrFim)
Local nHrRet
Local cHraIni := convHora(nHrInic)
Local cHraFim := convHora(nHrFim)

nHrRet := SomaHoras(cHraIni, cHraFim )

return nHrRet

static function excExce(cMatric,dDataEscala)
cAlias := getNextAlias()
		
BeginSQL Alias cAlias

	SELECT SP2.R_E_C_N_O_ AS RECP2
	FROM %TABLE:SP2% SP2
	WHERE SP2.%NotDel% AND P2_FILIAL = %EXP:xFilial('SP2')% AND P2_MAT = %EXP:cMatric% AND P2_DATA = %EXP:DTOS(dDataEscala)% 

EndSQL

IF !(cAlias)->(Eof())
	SP2->(dbGoTo((cAlias)->RECP2))
	Reclock("SP2",.F.)
	SP2->(DbDelete())
	SP2->(MsUnLock())
ENDIF	

(cAlias)->(dbclosearea())

return 
			
STATIC FUNCTION gravaExe(cTipo,cMatric,dDataEscala,nHrInic,nTotPrim,nSegInic,nTotSeg)

Local lAjutHE := GETMV('TCP_AJUSHE')

cAlias := getNextAlias()
		
BeginSQL Alias cAlias

	SELECT SP2.R_E_C_N_O_ AS RECP2
	FROM %TABLE:SP2% SP2
	WHERE SP2.%NotDel% AND P2_FILIAL = %EXP:xFilial('SP2')% AND P2_MAT = %EXP:cMatric% AND P2_DATA = %EXP:DTOS(dDataEscala)% 

EndSQL

IF !(cAlias)->(Eof())
	SP2->(dbGoTo((cAlias)->RECP2))
	Reclock("SP2",.F.)
else
	Reclock("SP2",.T.)
ENDIF	

SP2->P2_FILIAL  := xFilial('SP2')
SP2->P2_DATA    := dDataEscala
SP2->P2_DATAATE := dDataEscala
SP2->P2_MAT	    := cMatric

IF cTipo == 'S' 
	SP2->P2_ENTRA1  := nHrInic
	//O horário das 23.59 é cadastrado assim, pois o turno da 1 da manhã deve contar para o dia anterior.
	//Por isso deixo fixo a saída as 7, pois se for calcular não vai fazer corretamente
	SP2->P2_SAIDA1  := IF(nHrInic == 23.59,7,xSumHora(nHrInic,nTotPrim))
	SP2->P2_ENTRA2  := nSegInic
	SP2->P2_SAIDA2  := IF(nSegInic>0,IF(nSegInic == 23.59,7,xSumHora(nSegInic,nTotSeg)),0)
	SP2->P2_TOTHORA := nTotPrim + nTotSeg
	SP2->P2_HRSTRAB := nTotPrim
	SP2->P2_HRSTRA2 := nTotSeg
	
	SP2->P2_HORMENO := nTotPrim + 1
	SP2->P2_HORMAIS := nTotPrim + 1
ELSE
	SP2->P2_ENTRA1  := 0
	SP2->P2_SAIDA1  := 0
	SP2->P2_ENTRA2  := 0
	SP2->P2_SAIDA2  := 0
	SP2->P2_TOTHORA := 0
	
	SP2->P2_HORMENO := 1
	SP2->P2_HORMAIS := 1
	SP2->P2_HRSTRAB := 0
	SP2->P2_HRSTRA2 := 0
	
ENDIF

SP2->P2_TRABA := cTipo
IF cTipo == 'D'
	SP2->P2_CODHEXT := '2'
	SP2->P2_CODHNOT := '6'
	SP2->P2_MOTIVO  := '-- DSR '+DTOC(dDataEscala) + ' --'
ELSE
	SP2->P2_CODHEXT := '1'
	SP2->P2_CODHNOT := '5'
	IF cTipo == 'S'
		SP2->P2_MOTIVO  := '-- Excecao Trabalhada --'
	ELSE
		SP2->P2_MOTIVO  := '-- Não Escalado --'
		SP2->P2_TRABA   := 'N'
	ENDIF
ENDIF

SP2->P2_NONAHOR := 'N'
SP2->P2_INTERV1 := 'N'
SP2->P2_INTERV2 := 'N'
SP2->P2_INTERV3 := 'N'
SP2->P2_JND1CON := 'N'
SP2->P2_JND2CON := 'N'
SP2->P2_JND3CON := 'N'
SP2->P2_JND4CON := 'N'
SP2->P2_HNOTTAB := 'N'
SP2->P2_HNOTTBI := 'N'
SP2->P2_INIHNOT := 22

IF lAjutHE .AND. (nHrInic == 23.59 .OR. nSegInic == 23.59)
	SP2->P2_FIMHNOT := 4
ELSE
	SP2->P2_FIMHNOT := 5
ENDIF

SP2->P2_MINHNOT := 52.5	

SP2->(MsUnLock())
(cAlias)->(dbclosearea())

return

static function caracEsp(cString)
Local _sRet := cString

   _sRet := StrTran (_sRet, "á", "a")
   _sRet := StrTran (_sRet, "é", "e")
   _sRet := StrTran (_sRet, "í", "i")
   _sRet := StrTran (_sRet, "ó", "o")
   _sRet := StrTran (_sRet, "ú", "u")
   _sRet := StrTran (_sRet, "Á", "A")
   _sRet := StrTran (_sRet, "É", "E")
   _sRet := StrTran (_sRet, "Í", "I")
   _sRet := StrTran (_sRet, "Ó", "O")
   _sRet := StrTran (_sRet, "Ú", "U")
   _sRet := StrTran (_sRet, "ã", "a")
   _sRet := StrTran (_sRet, "õ", "o")
   _sRet := StrTran (_sRet, "Ã", "A")
   _sRet := StrTran (_sRet, "Õ", "O")
   _sRet := StrTran (_sRet, "â", "a")
   _sRet := StrTran (_sRet, "ê", "e")
   _sRet := StrTran (_sRet, "î", "i")
   _sRet := StrTran (_sRet, "ô", "o")
   _sRet := StrTran (_sRet, "û", "u")
   _sRet := StrTran (_sRet, "Â", "A")
   _sRet := StrTran (_sRet, "Ê", "E")
   _sRet := StrTran (_sRet, "Î", "I")
   _sRet := StrTran (_sRet, "Ô", "O")
   _sRet := StrTran (_sRet, "Û", "U")
   _sRet := StrTran (_sRet, "ç", "c")
   _sRet := StrTran (_sRet, "Ç", "C")
   _sRet := StrTran (_sRet, "à", "a")
   _sRet := StrTran (_sRet, "À", "A")
   _sRet := StrTran (_sRet, "º", ".")
   _sRet := StrTran (_sRet, "ª", ".")
   _sRet := StrTran (_sRet, ">", "-")
   _sRet := StrTran (_sRet, "<", "-")
   _sRet := StrTran (_sRet, "|", "-")
   _sRet := StrTran (_sRet, "(", "-")
   _sRet := StrTran (_sRet, ")", "-")
   _sRet := StrTran (_sRet, "[", "-")
   _sRet := StrTran (_sRet, "]", "-")
   _sRet := StrTran (_sRet, ":", "-")
   _sRet := StrTran (_sRet, ";", "-")
   _sRet := StrTran (_sRet, "\", "-")
   _sRet := StrTran (_sRet, "/", "-")
   _sRet := StrTran (_sRet, "_", "-")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
   _sRet := StrTran (_sRet, Chr(13) + Chr(10) , " ") // enter
   _sRet := StrTran (_sRet, Chr(13)  , " ") 
   _sRet := StrTran (_sRet, Chr(10)  , " ") 
return _sRet
