#Include 'Protheus.ch'
 
/*/{Protheus.doc} XPUTSX1HELP 
@author Kaique Mathias
@type User Function
@description Funùùo para criar help de perguntas no mesmo molde da padrùo. 
@obs #CONFIGURADOR #GENERICO #SX1
@since 15/03/2017
@version Protheus 12
 
@param cKey     , Caracter, Nome do help a ser cadastrado.
@param aHelpPor , Array   , Array com o texto do help em Portuguùs.
@param aHelpEng , Array   , Array com o texto do help em Inglùs.
@param aHelpSpa , Array   , Array com o texto do help em Espanhol.
@param lUpd     , Boolean , Caso seja .T. e jù existir um help com o mesmo nome, atualiza o registro. Se for .F. nùo atualiza.
@param cStatus  , Caracter, Parùmetro reservado.
 
@see http://tdn.totvs.com/display/public/PROT/PutSx1Help+-+Cadastro+de+Help
/*/
 
User Function XPUTSX1HELP(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpd,cStatus)
Local cFilePor := "SIGAHLP.HLP"
Local cFileEng := "SIGAHLE.HLE"
Local cFileSpa := "SIGAHLS.HLS"
Local nRet
Local nT
Local nI
Local cLast
Local cNewMemo
Local cAlterPath := ''
Local nPos  
 
If ( ExistBlock('HLPALTERPATH') )
    cAlterPath := Upper(AllTrim(ExecBlock('HLPALTERPATH', .F., .F.)))
    If ( ValType(cAlterPath) != 'C' )
        cAlterPath := ''
    ElseIf ( (nPos:=Rat('\', cAlterPath)) == 1 )
        cAlterPath += '\'
    ElseIf ( nPos == 0  )
        cAlterPath := '\' + cAlterPath + '\'
    EndIf
     
    cFilePor := cAlterPath + cFilePor
    cFileEng := cAlterPath + cFileEng
    cFileSpa := cAlterPath + cFileSpa
     
EndIf
 
Default aHelpPor := {}
Default aHelpEng := {}
Default aHelpSpa := {}
Default lUpd     := .T.
Default cStatus  := ""
 
If Empty(cKey)
    Return
EndIf
 
If !(cStatus $ "USER|MODIFIED|TEMPLATE")
    cStatus := NIL
EndIf
 
cLast    := ""
cNewMemo := ""
                                                                                                 
nT := Len(aHelpPor)
 
For nI:= 1 to nT
   cLast := Padr(aHelpPor[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next
 
If !Empty(cNewMemo)
    nRet := SPF_SEEK( cFilePor, cKey, 1 )
    If nRet < 0
        SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
    Else
        If lUpd 
            SPF_DELETE( cFilePor, nRet ) 
            SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
        EndIf                                                           
    EndIf
EndIf
 
cLast    := ""
cNewMemo := ""
 
nT := Len(aHelpEng)
 
For nI:= 1 to nT
   cLast := Padr(aHelpEng[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next
 
If !Empty(cNewMemo)
    nRet := SPF_SEEK( cFileEng, cKey, 1 )
    If nRet < 0
        SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
    Else
        If lUpd
            SPF_DELETE( cFileEng, nRet ) 
            SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
        EndIf
    EndIf
EndIf
 
cLast    := ""
cNewMemo := ""
 
nT := Len(aHelpSpa)
 
For nI:= 1 to nT
   cLast := Padr(aHelpSpa[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next
 
If !Empty(cNewMemo)
    nRet := SPF_SEEK( cFileSpa, cKey, 1 )
    If nRet < 0
        SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
    Else
        If lUpd
            SPF_DELETE( cFileSpa, nRet ) 
            SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
        EndIf
    EndIf
EndIf
Return