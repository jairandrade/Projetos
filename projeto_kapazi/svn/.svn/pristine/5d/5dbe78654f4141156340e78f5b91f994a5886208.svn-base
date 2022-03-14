#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "apwizard.CH"

//==================================================================================================//
//	Programa: KPFIS01A		|	Autor: Andre Sakai							|	Data: 18/02/2021	//
//==================================================================================================//
//	Descrição: PE para tratar a conta na SFT                										//
//																									//
//==================================================================================================//
/*
Este ponto de entrada retorna a conta contabil conforme regra de cfop ou cadastro de grupo de produto
*/

USER FUNCTION KPFIS01A(_nTipo)

    Local _cAlias1 := getnextalias()
    Local _cAlias2 := getnextalias()
    Local _cSql := ''
    Local _cConta := '' 

    Local _cAreaFT := SFT->(GETAREA())
    Local _cCampo

    Local _lwizard := isincallstack('U_KPFIS01D')
    Local _nRegs := 0 

    Default _nTipo := 0

    

    If(isincallstack('U_M460FIM') .or. _nTipo = 1)
        _cSql += "% AND FT_FILIAL='"+SF2->F2_FILIAL+"' AND FT_NFISCAL='"+SF2->F2_DOC+"' AND FT_SERIE='"+SF2->F2_SERIE+"' AND FT_CLIEFOR='"+SF2->F2_CLIENTE+"' AND FT_LOJA='"+SF2->F2_LOJA+"' %"
        //conout ('KPFIS01','M460FIM - SQL',_cSql)
        If(_nTipo=1)
            _cSeek := SUBSTR(SD2->D2_CFOP,2,3)
        EndIf
    ElseIf(isincallstack('U_MT930SF3') .or. _nTipo = 2)
        _cSql += "% AND FT_FILIAL='"+SF3->F3_FILIAL+"' AND FT_NFISCAL='"+SF3->F3_NFISCAL+"' AND FT_SERIE='"+SF3->F3_SERIE+"' AND FT_CLIEFOR='"+SF3->F3_CLIEFOR+"' AND FT_LOJA='"+SF3->F3_LOJA+"' %"
         //conout ('KPFIS01','MT930SF3 - SQL',_cSql)
        If(_nTipo=2)
            _cSeek := SUBSTR(SF3->F3_CFOP,2,3)
        EndIf
    ElseIf(isincallstack('U_MT103FIM') .or. _nTipo = 3)
        _cSql += "% AND FT_FILIAL='"+SF1->F1_FILIAL+"' AND FT_NFISCAL='"+SF1->F1_DOC+"' AND FT_SERIE='"+SF1->F1_SERIE+"' AND FT_CLIEFOR='"+SF1->F1_FORNECE+"' AND FT_LOJA='"+SF1->F1_LOJA+"' %"
        //conout ('KPFIS01','MT103FIM - SQL',_cSql)
       If(_nTipo=3)
            _cSeek := SUBSTR(SD1->D1_CFOP,2,3)
        EndIf
    ElseIf(_nTipo = 4)
        _cSql += "% AND FT_FILIAL='"+xFilial('SFT')+"'  %"
        //conout ('KPFIS01','SFT-SCHEDULE - SQL',_cSql)
        If(_nTipo=4)
            _cSeek := SUBSTR(SFT->FT_CFOP,2,3)
        EndIf
       
    EndIf


    BeginSQL ALIAS _cAlias1
        SELECT SFT.R_E_C_N_O_ REC, FT_CONTA , FT_CFOP, FT_TIPOMOV,FT_PRODUTO
        FROM %TABLE:SFT% SFT (NOLOCK)
        WHERE SFT.D_E_L_E_T_=' ' %EXP:_cSql% AND FT_CONTA=' ' 
    EndSQL

    If(_lwizard)
        _nRegs := (_cAlias1)->(LastRec())
        procregua(_nRegs)
    EndIf

    //CONOUT('CONTASFT',GETLASTQUERY()[2])
    _nX := 1
    While (_cAlias1)->(!EOF())
        If(_lwizard)
            incproc(cvaltochar(_nX++) + '/' + cvaltochar(_nRegs))
        Endif
        
        /*
            AND FT_ENTRADA >= '20200101'
            AND FT_CONTA = ' '
            AND FT_TIPOMOV = 'S'
        */
        _cSeek := SUBSTR((_cAlias1)->FT_CFOP,2,3)
        If(SX2->(DBSEEK('ZCA')))
            If(ZCA->(DBSEEK(_cSeek)))
                _cConta := ZCA->ZCA_CC
                //conout('Regra ZCA - Conta:'+ZCA->ZCA_CC)
            EndIf
        EndIf

        IF(Empty(_cConta ))
             If(SUBSTR((_cAlias1)->FT_CFOP,2,3) = '933')
                If((_cAlias1)->FT_TIPO='S')
                    _cConta := '310101003'
                     //conout('Regra Fixa - Conta:'+_cConta)
                EndIf
            Else
                If((_cAlias1)->FT_TIPOMOV='E')
                    If(Select(_cAlias2)<>0)
                        (_cAlias2)->(DBCLOSEAREA())
                    EndIf
                    BeginSQL ALIAS _cAlias2
                        SELECT  * 
                        FROM %TABLE:SB1%  SB1 (NOLOCK)
                        INNER JOIN %TABLE:SBM% SBM (NOLOCK) ON BM_GRUPO=B1_GRUPO AND SBM.D_E_L_E_T_=' '
                        WHERE B1_COD=%EXP:(_cAlias1)->FT_PRODUTO% AND SB1.D_E_L_E_T_=' '
                    EndSQL

                     If((_cAlias2)->(!EOF()))
                        If(cEmpAnt $ '01#02#03#04')
                            _cCampo := 'BM_E'+substr(cEmpAnt,2,1)+cFilAnt
                            If((_cAlias2)->(fieldpos(_cCampo))>0)
                               _cConta :=(_cAlias2)->(&(_cCampo))
                            EndIf
                            //conout('Regra Grupo de Produto 01 - Conta:'+_cConta+' - CAMPO '+_cCampo)
                        EndIf
                    EndIf
                    //CONOUT('CONTASFT - entrada',GETLASTQUERY()[2],_cConta)
                    (_cAlias2)->(DBCLOSEAREA())
                ElseIf((_cAlias1)->FT_TIPOMOV='S')
                    If(Select(_cAlias2)<>0)
                        (_cAlias2)->(DBCLOSEAREA())
                    EndIf

                    BeginSQL ALIAS _cAlias2
                        SELECT  B1_CONTA,B1_COD,SBM.* 
                        FROM %TABLE:SB1%  SB1 (NOLOCK)
                        INNER JOIN %TABLE:SBM% SBM (NOLOCK) ON BM_GRUPO=B1_GRUPO AND SBM.D_E_L_E_T_=' '
                        WHERE B1_COD=%EXP:(_cAlias1)->FT_PRODUTO% AND SB1.D_E_L_E_T_=' '
                    EndSQL
                    //B1_CONTA,B1_COD,BM_E101,BM_E102,BM_E103,BM_E104,BM_E201,BM_E202,BM_E203,BM_E204,BM_E301,BM_E302,BM_E303,BM_E304,BM_E401,BM_E402,BM_E403,BM_E404,BM_E405,BM_E406
                    //CONOUT('CONTASFT2 - saida',GETLASTQUERY()[2],_cConta)

                    If((_cAlias2)->(!EOF()))
                        If(cEmpAnt $ '01#02#03#04')
                            _cCampo := 'BM_E'+substr(cEmpAnt,2,1)+cFilAnt
                            If((_cAlias2)->(fieldpos(_cCampo))>0)
                                _cConta :=(_cAlias2)->(&(_cCampo))
                            EndIf
                            //conout('Regra Grupo de Produto 01 - Conta:'+_cConta+' - CAMPO '+_cCampo)
                        EndIf
                    EndIf
                    (_cAlias2)->(DBCLOSEAREA())
                EndIf
            EndIf
        EndIf
       

        SFT->(DBGoto((_cAlias1)->REC))
        
        RECLOCK("SFT",.F.)
            SFT->FT_CONTA := _cConta 
        SFT->(MSUNLOCK())

        (_cAlias1)->(DBSkip())
    EndDo

     (_cAlias1)->(DBCloseArea())
    RESTAREA(_cAreaFT)

Return


//==================================================================================================//
//	Programa: KPFIS01B		|	Autor: Andre Sakai							|	Data: 18/02/2021	//
//==================================================================================================//
//	Descrição: PE para tratar a conta na SD1 / SD2             										//
//																									//
//==================================================================================================//
/*
Este ponto de entrada retorna a conta contabil conforme regra de cfop ou cadastro de grupo de produto
*/
User Function KPFIS01B(_nTipo)

Local _cConta := space(tamsx3('D1_CONTA')[1])

DEFAULT _nTipo := 0

DO CASE
    CASE _nTipo = 1
        _cSeek := substr(M->D1_CFOP,2,3)
    CASE _nTipo = 2
        _cSeek := substr(M->D2_CFOP,2,3)
    CASE _nTipo = 3
        _cSeek := substr(M->C6_CFOP,2,3)
    OTHERWISE
        return ' '

ENDCASE

If(SX2->(DBSEEK('ZCA')))
    If(ZCA->(DBSEEK(_cSeek)))
        _cConta := ZCA->ZCA_CC
    EndIf
EndIf


IF(Empty(_cConta ))
    If (_cSeek = '933')
        If(SFT->FT_TIPO='S')
            _cConta := '310101003'
        EndIf
    Else
        If(SFT->FT_TIPO='E')
            BeginSQL ALIAS _cAlias2
                SELECT B1_CONTA,B1_COD,BM_E101 FROM %EXP:SB1%  SB1 (NOLOCK)
                INNER JOIN %EXP:SBM% SBM (NOLOCK) ON BM_GRUPO=B1_GRUPO AND SBM.D_E_L_E_T_=' '
                WHERE B1_COD=%EXP:SFT->FT_PRODUTO% AND SB1.D_E_L_E_T_=' '
            EndSQL

            If((_cAlias2)->(EOF()))
                If(_cEmpAnt = '01')
                    _cConta :=IiF(_cAlias2->(!EOF),(_cAlias2)->BM_E101,'')
                Elseif(_cEmpAnt = '04')
                    _cConta :=IiF(_cAlias2->(!EOF),(_cAlias2)->BM_E401,'')
                EndIf'
            EndIf
            //CONOUT('CONTASFT2',GETLASTQUERY()[2],_cConta)
        EndIf
    EndIf
EndIf

Return _cConta



//==================================================================================================//
//	Programa: KPFIS01C		|	Autor: Andre Sakai							|	Data: 18/02/2021	//
//==================================================================================================//
//	Descrição: Tela para cadastro de CFOP x Conta Contabil                										//
//																									//
//==================================================================================================//

USER FUNCTION KPFIS01C()

Local _cAlias := 'ZCA'
Local _cTexto := 'Cadastro de CFOP x Conta Contabil'

AXCADASTRO(_cAlias,_cTexto)

RETURN
