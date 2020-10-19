#include 'protheus.ch'
#include "fwmvcdef.ch"
#include "Totvs.ch"  
#include "Rwmake.ch"  
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCMD01KM
Função executada através do gatilho TNY_DTINIC/TNY_DTFIM. Usado para
engatilhar os horarios nos campos TNY_HRINIC/TNY_HRFIM.
@author  Kaique Sousa
@since   07/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function TCMD01KM()

    Local aArea     := GetArea()
    Local cAlias    := GetNextAlias()
    Local cHoras    := ""
    Local cMatric   := ""
    Local dData     := &(ReadVar())
    Local dDtFim    := CTOD('//')

    dbSelectArea('TM0')
    TM0->(DBSETORDER(1))
    TM0->(Msseek(xFilial('TM0')+FwFldGet("TNY_NUMFIC")))
    
    If TM0->(!Found())
        MsgAlert("Matricula não informada na ficha médica.")
    else
        cMatric := TM0->TM0_MAT
    EndIf

    dbSelectArea('SRA')
    SRA->(dbSetOrder(1))
    SRA->(MsSeek(xFilial('SRA')+cMatric))

    cCC     := SRA->RA_CC

    //Verifico se houve transferencia de turno
    BeginSql Alias cAlias
        SELECT MAX(R_E_C_N_O_) NRECNO
        FROM %table:SPF% SPF
        WHERE   SPF.PF_FILIAL = %xFilial:SPF% And
                SPF.PF_MAT = %exp:cMatric% And
                SPF.PF_DATA <= %exp:DTOS(dData)% And
                SPF.%NotDel%
    EndSql
    
    dbSelectArea(cAlias)
    (cAlias)->(dbGotop())

    If !(cAlias)->(Eof())
        dbSelectArea('SPF')
        SPF->(dbGoto((cAlias)->(NRECNO)))
        If SPF->(Recno()) == (cAlias)->(NRECNO)
            cFilSRA:= cFilAnt
            cTurno := SPF->PF_TURNOPA
            cTurSEQ:= GetInfoPosTab(08,,dData,,,,,,cTurno,SPF->PF_SEQUEPA)
        EndIf
    else
        cFilSRA := SRA->RA_FILIAL
        cTurno  := SRA->RA_TNOTRAB
        cTurSEQ := SRA->RA_SEQTURN
    EndIf

    (cAlias)->(dbCloseArea())
    
    dDtFim := DaySum(FWFLDGET('TNY_DTINIC'),VAL(FWFLDGET('TNY_QTDTRA')))-1

    aHorasIni := RetHrTrn(cTurno,cTurSEQ,cCc,cFilSRA,cMatric,dData)
    aHorasFim := RetHrTrn(cTurno,cTurSEQ,cCc,cFilSRA,cMatric,dDtFim)
    
    lNoturn := aHorasFim[1]
    
    If len(aHorasIni)>0 .And. len(aHorasFim) > 0
        //Verifico se o turno do colaborador é noturno
        If ( lNoturn )
            dDtFim := dDtFim + 1
        EndIf
        oModel := FWModelActive()
        oModelTNY:= oModel:GetModel('TNYMASTER1')
        oModelTNY:SetValue('TNY_HRINIC',aHorasIni[2])
        oModelTNY:SetValue('TNY_HRFIM' ,aHorasFim[3])
        oModelTNY:SetValue('TNY_DTFIM' ,dDtFim )
    EndIf

    RestArea(aArea)

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetHrTrn
Retorna horario inicio e fim do turno.
@author  Kaique Sousa
@since   07/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RetHrTrn(cTurno,cTurSEQ,cCc,cFilSRA,cMatric,dData)
    
    Local aExcecoes := {}
    Local nFor      := 0
    Local aTabTno   := {} //Horarios do turno
    Local aTab685   := {}
    Local aHrIniFim := Array(02)
    Local bVld
    Local cTipoDia  := ""
    Local aExcePer  := {}
    Local lExcecao  := .F.
    Local cTrab     := ""
    Local nEntrada  := 0
    Local nSaida    := 0
    Local lNoturn   := .F.

    //Verifico se houve excecoes para o colaborador nesse dia
    lExcecao := GetExcecoes( @aExcecoes , cTurno , cCC , cFilSRA , cMatric , dData , @cTipoDia , aExcePer )
    
    If ( lExcecao ) 
        If ( aExcecoes[1,23] == "S" ) //Se for excecao trabalhada
            nEntrada := aExcecoes[1][5]
            nSaida   := aExcecoes[1][6]
            For nFor := 8 to 12 step 2
                //Se existem horas trabalhadas entre as outras entradas e saidas
                If aExcecoes[1,nFor] > 0
                    nSaida := aExcecoes[1,nFor]
                EndIf
            Next nFor
        else
            nEntrada := 0
            nSaida := 23.59
        EndIf
    else
        //se não houve excecoes carrego os horarios definidos no turno padrao
        If !Empty(cTurSEQ)
            bVld := &("{|| PJ_SEMANA == '"+cTurSEQ+"' }")
        else
            dbSelectArea("SPJ")
            SPJ->(dbSetOrder(1))
            If dbSeek(xFilial("SPJ",SRA->RA_FILIAL)+SPF->PF_TURNOPA)
                bVld := &("{|| PJ_SEMANA == '"+SPJ->PJ_SEMANA+"' }")
            Endif
        EndIf

        If ValType(bVld) == "B" .And. !Empty(dData)
        
            //Busca horario do turno
            fTabPadrao( @aTabTno , xFilial("SR6",SRA->RA_FILIAL) , cTurno , , bVld )
            aTab685 := aClone(aTabTno)

            nDow  := Dow(dData)
            
            //Analiso primeira entrada e primeira saida
            nEntrada := aTab685[1,3,nDow,1]
            nSaida   := aTab685[1,3,nDow,2]
            
            For nFor := 4 to 8 step 2
                //Se existem horas trabalhadas entre as outras entradas e saidas
                If aTab685[1,3,nDow,nFor] > 0
                    nSaida := aTab685[1,3,nDow,nFor]
                EndIf
            Next nFor
        EndIf
    EndIf

    If ( nSaida <= nEntrada ) //Quando o horario de Saida for menor que o de Entrada, funcionário trabalha noturno.
        lNoturn := .T.
    EndIf

    //nEntrada := TimeIntToStr(nEntrada)
    //nSaida := TimeIntToStr(nSaida)

Return( {lNoturn,TimeIntToStr(nEntrada),TimeIntToStr(nSaida)} )

//-------------------------------------------------------------------
/*/{Protheus.doc} TimeIntToStr
Converte inteiro em horas
@author  Kaique Sousa
@since   07/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TimeIntToStr(nValor)

    Local cHora     := ""
    Local cMinutos  := ""
    Local cSepar      := ":"
    Default nValor  := -1

    //Se for valores negativos, retorna a hora atual
    If nValor < 0
        cHora := SubStr(Time(), 1, 5)
        cHora := StrTran(cHora, ':', cSepar)

        //Senão, transforma o valor numérico
    Else
        cHora := Alltrim(Transform(nValor, "@E 99.99"))

        //Se o tamanho da hora for menor que 5, adiciona zeros a esquerda
        If Len(cHora) < 5
            cHora := Replicate('0', 5-Len(cHora)) + cHora
        EndIf

        //Atualizando o separador
        cHora := StrTran(cHora, ',', cSepar)
    EndIf

Return( cHora )