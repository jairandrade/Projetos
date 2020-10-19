#include "protheus.ch"

/*/{Protheus.doc} TCGP001
Notificação de head-count por centro de custo
@type  User Function
@author Kaique Sousa
@since 09/03/2020
@version 1.0
/*/

User Function TCGP001()

    Local cErro         := ""
    Local cBody         := ""
    Local cBody         := ""
    Local aDados        := {}
    Local cMailNotify   := GetMV("TCP_MAILHC")

    RpcSetType(3)
    RPCSetEnv("02","01")

    If fGetDados(@aDados)
    
        cBody := assembleHTML(aDados)

        oMail := TCPMail():New()
        oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILAVISO.HTML")
        oHtml:ValByName("CHEADER","CURRENT HEAD-COUNT")
        oHtml:ValByName("CBODY",cBody)
        oMail:SendMail(cMailNotify,"CURRENT HEAD-COUNT", oHtml:HtmlCode(),@cErro,{})
        FreeObj(oMail)
        FreeObj(oHtml)

    Endif

    RPCClearEnv()

Return( Nil )

Static Function assembleHTML(aDados)
    
    Local cHtml     := ""
    Local nC        := 0
    Local aTotais   := {0,0,0,0}

    cHtml := '<style type="text/css">'
    cHtml += '.tg  {border-collapse:collapse;border-spacing:0;border-color:#aabcfe;}'
    cHtml += '.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aabcfe;color:#669;background-color:#e8edff;}'
    cHtml += '.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:6px 20px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aabcfe;color:#039;background-color:#b9c9fe;}'
    cHtml += '.tg .tg-amwm{font-weight:bold;text-align:center;vertical-align:top}'
    cHtml += '.tg .tg-0lax{text-align:center;vertical-align:top}'
    cHtml += '@media screen and (max-width: 767px) {.tg {width: auto !important;}.tg col {width: auto !important;}.tg-wrap {overflow-x: auto;-webkit-overflow-scrolling: touch;}}</style>'
    cHtml += '<div class="tg-wrap"><table class="tg" style="undefined; width: 605px" align="center">'
    cHtml += '<tr>'
    cHtml += '    <th class="tg-amwm"><br>COST CENTER</th>'
    cHtml += '    <th class="tg-amwm"><br>VACATION</th>'
    cHtml += '    <th class="tg-amwm">MEDICAL TESTIMONIAL</th>'
    cHtml += '    <th class="tg-amwm">INSS MEDICAL LEAVE</th>'
    cHtml += '    <th class="tg-amwm"><br>ACTIVE</th>'
    cHtml += '</tr>'
    
    For nC := 1 to len(aDados)
    
        cHtml += '<tr>'
        cHtml += '    <td class="tg-0lax" style="width: 40%">'
        cHtml += aDados[nC,1] + ' - ' + aDados[nC,2]
        cHtml += '    </td>'
        cHtml += '    <td class="tg-0lax" style="width: 20%">'
        cHtml += Alltrim(Str(aDados[nC,3]))
        cHtml += '    </td>'
        cHtml += '    <td class="tg-0lax" style="width: 20%">'
        cHtml += Alltrim(Str(aDados[nC,4]))
        cHtml += '    </td>'
        cHtml += '    <td class="tg-0lax" style="width: 20%">'
        cHtml += Alltrim(Str(aDados[nC,5]))
        cHtml += '    </td>'
        cHtml += '    <td class="tg-0lax" style="width: 20%">'
        cHtml += Alltrim(Str(aDados[nC,6]))
        cHtml += '    </td>'
        cHtml += '</tr>'

        aTotais := { aTotais[1]+aDados[nC,3],;
                     aTotais[2]+aDados[nC,4],;
                     aTotais[3]+aDados[nC,5],;
                     aTotais[4]+aDados[nC,6]}
    
    Next nC

    cHtml += '<tr>'
    cHtml += '    <td class="tg-0lax" style="width: 40%">'
    cHtml += '<b>AMOUNT</b>'
    cHtml += '    </td>'
    cHtml += '    <td class="tg-0lax" style="width: 20%">'
    cHtml += '<b>' + Alltrim(Str(aTotais[1])) + '</b>'
    cHtml += '    </td>'
    cHtml += '    <td class="tg-0lax" style="width: 20%">'
    cHtml += '<b>' +  Alltrim(Str(aTotais[2])) + '</b>'
    cHtml += '    </td>'
    cHtml += '    <td class="tg-0lax" style="width: 20%">'
    cHtml += '<b>' +  Alltrim(Str(aTotais[3])) + '</b>'
    cHtml += '    </td>'
    cHtml += '    <td class="tg-0lax" style="width: 20%">'
    cHtml += '<b>' +  Alltrim(Str(aTotais[4])) + '</b>'
    cHtml += '    </td>'
    cHtml += '</tr>'
    cHtml += '</table></div>'

Return( cHtml )

Static Function fGetDados(aDados)

    Local lRet      := .F.
    Local cAliasTRB := GetNextAlias()

    BeginSql Alias cAliasTRB

    SELECT	RA_CC cost_center,
            CTT_DESC01 description,
            SUM(count_vacation) count_vacation, 
            SUM(count_mcertificate) count_mcertificate, 
            SUM(count_mleave) count_mleave,
            SUM(count_active) count_active
    FROM(
        SELECT RA_CC,
            CTT_DESC01,
            COUNT(*) count_vacation,
            0 count_mcertificate,
            0 count_mleave,
            0 count_active
        FROM %table:SR8% SR8
        INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = SR8.R8_FILIAL AND
                                SRA.RA_MAT = SR8.R8_MAT AND
                                SRA.%NotDel%
        LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND
                                CTT.CTT_CUSTO=SRA.RA_CC AND
                                CTT.%NotDel%
        WHERE ( %exp:dDataBase% BETWEEN R8_DATAINI AND R8_DATAFIM OR R8_DATAFIM='' ) AND 
            SR8.%NotDel% AND
        EXISTS(
            SELECT 1 
            FROM %table:RCM% RCM
            WHERE RCM.RCM_TIPO=SR8.R8_TIPOAFA AND
                RCM.RCM_TIPOAF='4' AND
                RCM.%NotDel%	
        )
        GROUP BY RA_CC,CTT_DESC01
        UNION
        SELECT RA_CC,
            CTT_DESC01,
            0 count_vacation,
            COUNT(*) count_mcertificate,
            0 count_mleave,
            0 count_active
        FROM %table:SR8% SR8
        INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = SR8.R8_FILIAL AND
                                SRA.RA_MAT = SR8.R8_MAT AND
                                SRA.%NotDel%
        LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND
                                CTT.CTT_CUSTO=SRA.RA_CC AND
                                CTT.%NotDel%
        WHERE ( %exp:dDataBase% BETWEEN R8_DATAINI AND R8_DATAFIM OR R8_DATAFIM='' ) AND 
            R8_DURACAO <= 15 AND
            SR8.%NotDel% AND
        EXISTS(
            SELECT 1 
            FROM %table:RCM% RCM
            WHERE RCM.RCM_TIPO=SR8.R8_TIPOAFA AND
                RCM.RCM_TIPOAF='1' AND
                RCM.%NotDel%	
        )
        GROUP BY RA_CC,CTT_DESC01
        UNION
        SELECT RA_CC,
            CTT_DESC01,
            0 count_vacation,
            0 count_mcertificate,
            COUNT(*) count_mleave,
            0 count_active
        FROM %table:SR8% SR8
        INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = SR8.R8_FILIAL AND
                                SRA.RA_MAT = SR8.R8_MAT AND
                                SRA.%NotDel%
        LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND
                                CTT.CTT_CUSTO=SRA.RA_CC AND
                                CTT.%NotDel%
        WHERE ( %exp:dDataBase% BETWEEN R8_DATAINI AND R8_DATAFIM OR R8_DATAFIM='' ) AND 
            R8_DURACAO > 15 AND
            SR8.%NotDel% AND
        EXISTS(
            SELECT 1 
            FROM %table:RCM% RCM
            WHERE RCM.RCM_TIPO=SR8.R8_TIPOAFA AND
                RCM.RCM_TIPOAF='1' AND
                RCM.%NotDel%	
        )
        GROUP BY RA_CC,CTT_DESC01
        UNION
        SELECT RA_CC, CTT_DESC01, 0 COUNT_VACATION, 0 COUNT_MCERTIFICATE, 0 COUNT_MLEAVE, COUNT(*) COUNT_ACTIVE
        FROM %table:SRA% SRA
        LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND CTT.CTT_CUSTO=SRA.RA_CC AND CTT.D_E_L_E_T_= ' '
        WHERE SRA.D_E_L_E_T_='' AND 
                SRA.RA_SITFOLH <> 'D' AND  
                SRA.RA_MAT NOT IN (
                        SELECT RA_MAT
                        FROM %table:SR8% SR8 INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT AND SRA.D_E_L_E_T_= ' ' LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND CTT.CTT_CUSTO=SRA.RA_CC AND CTT.D_E_L_E_T_= ' '
                        WHERE  ( %exp:dDataBase% BETWEEN R8_DATAINI AND R8_DATAFIM OR R8_DATAFIM=' ' ) AND SR8.D_E_L_E_T_= ' ' AND EXISTS(SELECT 1
                                FROM %table:RCM% RCM
                                WHERE  RCM.RCM_TIPO=SR8.R8_TIPOAFA AND RCM.RCM_TIPOAF='4' AND RCM.D_E_L_E_T_= ' ' )
                        
                        UNION
                        SELECT RA_MAT
                        FROM %table:SR8% SR8 INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT AND SRA.D_E_L_E_T_= ' ' LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND CTT.CTT_CUSTO=SRA.RA_CC AND CTT.D_E_L_E_T_= ' '
                        WHERE  ( %exp:dDataBase% BETWEEN R8_DATAINI AND R8_DATAFIM OR R8_DATAFIM=' ' ) AND R8_DURACAO <= 15 AND SR8.D_E_L_E_T_= ' ' AND EXISTS(SELECT 1
                                FROM %table:RCM% RCM
                                WHERE  RCM.RCM_TIPO=SR8.R8_TIPOAFA AND RCM.RCM_TIPOAF='1' AND RCM.D_E_L_E_T_= ' ' )
                        UNION
                        SELECT RA_MAT
                        FROM %table:SR8% SR8 INNER JOIN %table:SRA% SRA ON SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT AND SRA.D_E_L_E_T_= ' ' LEFT JOIN %table:CTT% CTT ON CTT.CTT_FILIAL=SRA.RA_FILIAL AND CTT.CTT_CUSTO=SRA.RA_CC AND CTT.D_E_L_E_T_= ' '
                        WHERE  ( %exp:dDataBase% BETWEEN R8_DATAINI AND R8_DATAFIM OR R8_DATAFIM=' ' ) AND R8_DURACAO > 15 AND SR8.D_E_L_E_T_= ' ' AND EXISTS(SELECT 1
                                FROM %table:RCM% RCM
                                WHERE  RCM.RCM_TIPO=SR8.R8_TIPOAFA AND RCM.RCM_TIPOAF='1' AND RCM.D_E_L_E_T_= ' ' )
                        
                )
        GROUP BY RA_CC,CTT_DESC01     
        ) TMP
    GROUP BY RA_CC,CTT_DESC01
    ORDER BY RA_CC

    EndSql

    dbSelectArea(cAliasTRB)
    (cAliasTRB)->(dbgotop())

    While !Eof()
        lRet := .T.
        aAdd(aDados,{   (cAliasTRB)->cost_center,;
                        (cAliasTRB)->description,;
                        (cAliasTRB)->count_vacation,;
                        (cAliasTRB)->count_mcertificate,;
                        (cAliasTRB)->count_mleave,;
                        (cAliasTRB)->count_active;
                    })
        (cAliasTRB)->(dbSkip())
    EndDo

Return( lRet )