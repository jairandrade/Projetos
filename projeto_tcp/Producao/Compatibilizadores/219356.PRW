#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )


//-------------------------------------------------------------------
/*/{Protheus.doc} 219356  
description Funcao de update dos dicionários para compatibilização
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 219356()

Local aSay         := {}
Local aButton      := {}
Local aMarcadas    := {}
Local lExclu       := .T.
Local cTitulo      := '219356 - Atualização de dicionários e Tabelas'
Local cDesc1       := 'Esta rotina tem como objetivo realizar a atualização  dos dicionários do Sistema ( SX?/SIX )'
Local cDesc2       := Replicate('-',110)
Local cDesc3       := 'Esta atualização ' + if(lExclu,'deve','pode') + ' ser executada em modo [ ** ' + if(lExclu,'E X C L U S I V O','C O M P A R T I L H A D O') + ' ** ]'
Local cDesc4       := Replicate('-',110)
Local cDesc5       := '[DIVERSOS] :SX2,SX3,SIX,SX6'
Local cDesc6       := Replicate('-',110)
Local cDesc7       := '*******  [  Faça sempre BACKUP antes de aplicar qualquer compatibilizador  ]  *******'
Local cLibCli      := ''
Local lOk          := .F.

Private cDevName   := 'Kaique Mathias    '
Private cTicket    := '219356'
Private lAuditDic  := .F.
Private aAudiVal   := {,}
Private cAudiReg   := '' 
Private cTimeIni   := '' 
Private cTimeFim   := '' 
Private lOpen
Private lMacOS     := (GetRemoteType(@cLibCli),('MAC' $ cLibCli))
Private cComando   := If(lMacOS,'Open ','Cmd /c Start ')

Private oMainWnd   := Nil
Private oProcess   := Nil
Private cFixEmp    := '??'
Private lChkOrd    := .F.
Private lChkPar    := .F.
Private lChkTod    := .F.
Private cEmpSel    := ''
Private _nTamFil   := 0 

#IFDEF TOP
    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := Nil
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
aAdd( aSay, cDesc6 )
aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk

   aMarcadas := EscEmpresa(lExclu)

   If !Empty( aMarcadas )
      If  ApMsgNoYes( 'Confirma a atualização dos dicionários ?', cTitulo )

         oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lExclu ) }, cTicket + ' - Atualizando', 'Aguarde, atualizando ...', .F. )
         oProcess:Activate()

         If !lOk
            MsgStop( 'Atualização não Realizada.' )
         EndIf

      Else
         MsgStop( 'Atualização não Realizada.' )
      EndIf
   Else
      MsgStop( 'Você não selecionou nenhuma empresa !' )
   EndIf

EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
description Funcao de processamento da gravação dos arquivos
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lExclu )

Local   aTexto    := {}
Local   aLog      := {}
Local   cFile     := ''
Local   cSave     := ''
Local   cFileLog  := ''
Local   cAux      := ''
Local   cMask     := 'Arquivos Texto (*.LOG)|*.log|'
Local   nRecno    := 0
Local   nI        := 0
Local   nX        := 0
Local   nZ        := 0
Local   nPos      := 0
Local   aRecnoSM0 := {}
Local   aInfo     := {}
Local   lOpen     := .F.
Local   lRet      := .T.
Local   oDlg      := Nil
Local   oMemo     := Nil
Local   oFont     := Nil
Local   lAlertLog := .F.
Local   cFunction := ''
Local   cSequenc  := '0'

Private aArqUpd   := {}
Private aAuditDic := {}

//Marca a hora de inicio do compatibilizador
cTimeIni := Time()

If ( lOpen := MyOpenSm0Ex(lExclu) )

   dbSelectArea( 'SM0' )
   dbGoTop()

   While !SM0->( EOF() )
      // So adiciona no aRecnoSM0 se tiver sido escolhida e ainda nao estiver no array
      If Empty( nZ := aScan( aRecnoSM0, { |x| x[1] == SM0->M0_CODIGO } )) .And. (aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0)
            aAdd( aRecnoSM0, { SM0->M0_CODIGO , SM0->M0_CODFIL , SM0->M0_NOME , {} } )
            cEmpSel += If(Empty(cEmpSel),'','-') + SM0->M0_CODIGO
            nZ := Len(aRecnoSM0)
      EndIf

      If !Empty(nZ)
         aAdd( aRecnoSM0[nZ][4] , AllTrim(SM0->M0_CODFIL) )
      EndIf

      SM0->( dbSkip() )
   End

   If lOpen

      oProcess:SetRegua1( ( Len(aRecnoSM0) * DefRegua(1) ) )
      oProcess:SetRegua2( DefRegua(2) )

      For nI := 1 To Len( aRecnoSM0 )

         aArqUpd := {} 
         cSequenc := '0' 

         RpcSetType( 2 )
         RpcSetEnv( aRecnoSM0[nI][1] , aRecnoSM0[nI][2] , 'administrador' )

         lMsFinalAuto := .F.
         lMsHelpAuto  := .F.

         LogAdd( @aTexto , Replicate( '-', 128 ) )
         LogAdd( @aTexto , 'Empresa : ' + aRecnoSM0[nI][1] + '/' + aRecnoSM0[nI][3] )

         _nTamFil := Len(AllTrim(aRecnoSM0[nI][2]))


         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SX2         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SX2 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         While .T.
            cFunction := 'U_2193562' + cSequenc
            If FindFunction( cFunction )
               bBloco := MontaBlock('{|x,y|' + cFunction + '(@x,y) }')
               Eval( bBloco , aTexto, If(!Empty(cFixEmp).And.cFixEmp!='??',cFixEmp,aRecnoSM0[nI][1]) )
               cSequenc := Soma1(cSequenc)
            Else
               Exit
            EndIf
         EndDo

         cSequenc := '0'

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SX3         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SX3 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         While .T.
            cFunction := 'U_2193563' + cSequenc
            If FindFunction( cFunction )
               bBloco := MontaBlock('{|x,y|' + cFunction + '(@x,y) }')
               Eval( bBloco , aTexto, lChkOrd )
               cSequenc := Soma1(cSequenc)
            Else
               Exit
            EndIf
         EndDo

         cSequenc := '0'

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SIX         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SIX ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         While .T.
            cFunction := 'U_219356X' + cSequenc
            If FindFunction( cFunction )
               bBloco := MontaBlock('{|x|' + cFunction + '(@x) }')
               Eval( bBloco , aTexto )
               cSequenc := Soma1(cSequenc)
            Else
               Exit
            EndIf
         EndDo

         cSequenc := '0'

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SX6         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SX6 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         While .T.
            cFunction := 'U_2193566' + cSequenc
            If FindFunction( cFunction )
               bBloco := MontaBlock('{|x,y|' + cFunction + '(@x,y) }')
               Eval( bBloco , aTexto , If(lChkPar,aRecnoSM0[nI][4],Nil) )
               cSequenc := Soma1(cSequenc)
            Else
               Exit
            EndIf
         EndDo


         //------------------------------
         // Alteracao fisica dos arquivos
         //------------------------------
         __SetX31Mode( .F. )
         oProcess:SetRegua2( DefRegua(2) )

         For nX := 1 To Len( aArqUpd )

            //Se a Tabela for encontrada neste array, significa que alguma empresa anterior
            //aponta para ela e ja fez toda aplicacao das alteracoes, pulo sem fazer nada
            If !(SubStr(RetSQLName(aArqUpd[nx]),4,2)==aRecnoSM0[nI][1]) .AND. (SubStr(RetSQLName(aArqUpd[nx]),4,2) == '10' .And. aRecnoSM0[nI][1] <> '01')
               oProcess:IncRegua2('Aplicando alterações na base de dados...')
               Loop
            EndIf

            If Select( aArqUpd[nx] ) > 0
               dbSelectArea( aArqUpd[nx] )
               dbCloseArea()
            EndIf

            X31UpdTable( aArqUpd[nx] )

            If __GetX31Error()
               LogAdd( @aTexto , 'Erro.: Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : ' + aArqUpd[nx] )
               LogAdd( @aTexto , __GetX31Trace() )
            Else
               ChkFile(aArqUpd[nx])
               DbSelectArea(aArqUpd[nx])
            EndIf

            oProcess:IncRegua2('Aplicando alterações na base de dados...')

         Next nX

         __SetX31Mode( .T. )

         If nI = Len( aRecnoSM0 )
            LibTable( @aTexto )
         EndIf

         RpcClearEnv()

         If !( lOpen := MyOpenSm0Ex(lExclu) )
            lRet := .F.
            Exit
         EndIf

      Next nI

      //Marca a hora Fim do compatibilizador
      cTimeFim := Time()

      If lOpen

         If !Empty(aTexto) .And. ValType(aTexto[1])=='C'
            aTexto := {aTexto}
         EndIf

         For nI := 1 To Len(aTexto)
            For nZ := 1 To Len(aTexto[nI])
               If (lAlertLog := ('warning.' $ lower(aTexto[nI][nZ])) .Or. ('erro.' $ lower(aTexto[nI][nZ])))
                  Exit
               EndIf
            Next nZ
         Next nI

         aSize( aTexto , Len(aTexto)+1 )
         aIns( aTexto , 1 )
         aTexto[1] := {}

         aAdd( aTexto[1] , Replicate( '-', 128 ) )
         aAdd( aTexto[1] , 'LOG DA ATUALIZACAO DOS DICIONARIOS' )
         aAdd( aTexto[1] , Replicate( '-', 128 ) )

         aAdd( aTexto[1] , ' Dados Ambiente'        )
         aAdd( aTexto[1] , ' --------------------'  )
         aAdd( aTexto[1] , ' Data/Hora Inicio ..:' + cTimeIni )
         aAdd( aTexto[1] , ' Data/Hora Fim......: ' + cTimeFim )
         aAdd( aTexto[1] , ' Duracao............: ' + ElapTime(cTimeIni,cTimeFim) )
         aAdd( aTexto[1] , ' Environment........: ' + GetEnvServer() )
         aAdd( aTexto[1] , ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' ) )
         aAdd( aTexto[1] , ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' ) )
         aAdd( aTexto[1] , ' Versao.............: ' + GetVersao(.T.) )
         aAdd( aTexto[1] , ' Usuario Microsiga..: ' + If(Empty(__cUserID),'000000 Administrador', __cUserId + ' ' +  cUserName) )
         aAdd( aTexto[1] , ' Computer Name......: ' + GetComputerName() )

         aInfo   := GetUserInfo()
         If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
            aAdd( aTexto[1] , ' '  + CRLF )
            aAdd( aTexto[1] , ' Dados Thread' )
            aAdd( aTexto[1] , ' --------------------' )
            aAdd( aTexto[1] , ' Usuario da Rede....: ' + aInfo[nPos][1] )
            aAdd( aTexto[1] , ' Estacao............: ' + aInfo[nPos][2] )
            aAdd( aTexto[1] , ' Programa Inicial...: ' + aInfo[nPos][5] )
            aAdd( aTexto[1] , ' Environment........: ' + aInfo[nPos][6] )
            aAdd( aTexto[1] , ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) ) )
         EndIf

         aAdd( aTexto[1] , ' '  + CRLF )
         aAdd( aTexto[1] , ' Parametros de execucao' )
         aAdd( aTexto[1] , ' ----------------------' )
         aAdd( aTexto[1] , ' Modo do Compat.....: ' + If(lExclu,'Exclusivo','Compartilhado') )
         aAdd( aTexto[1] , ' Check Todos........: ' + If(lChkTod,'.T.','.F.') )
         aAdd( aTexto[1] , ' Check Param p/ Fil.: ' + If(lChkPar,'.T.','.F.') )
         aAdd( aTexto[1] , ' Fixar Empresa......: ' + cFixEmp )
         aAdd( aTexto[1] , ' Check Altera Ordem.: ' + If(lChkOrd,'.T.','.F.') )
         aAdd( aTexto[1] , ' Empresas Selec.....: ' + cEmpSel )

         aAdd( aTexto[1] , ' '  + CRLF )
         aAdd( aTexto[1] , ' Para ver o LOG Completo clique no botão abaixo !' )

         Define Font oFont Name 'Mono AS' Size 5, 12

         oDlg    := TDialog():New( 003, 000, 340, 417, cTicket + ' - Atualizacao concluida', , , , , CLR_BLACK, CLR_WHITE, , , .T. )
         oTimer  := TTimer():New( 0, { || (If(lAlertLog,MsgStop('Atenção...'+CRLF+'Houve erros/warnings durante a execução'+CRLF+'Verifique atentamente o LOG !!!'),Nil),oTimer:DeActivate()) }, oDlg )
         oBrowse := TCBrowse():New( 05 , 05, 200, 145,,{'Log de Atualização - Resumo'},{100},oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,/*bValid*/,.T.,.F.)
         oBrowse:SetArray(aTexto[1])
         oBrowse:oFont := oFont
         oBrowse:AddColumn( TCColumn():New('Log de Atualização'     ,{ || aTexto[1][oBrowse:nAt] },,,,'LEFT',,.F.,.T.,,,,.F.,) )

         oTBut1  := TButton():New(153,165,'Encerrar',oDlg,{|| oDlg:End()}, 040, 010, , , .F., .T., .F., , .F., , , .F. )     
         oTBut2  := TButton():New(153,125,'Salvar',oDlg,{|| (cFile:=cGetFile(cMask,'Salvar LOG',1,,.T.),If(!Empty(cFile),SaveLog(cFile,aTexto),Nil))}, 040, 010, , , .F., .T., .F., , .F., , , .F. )
         oTBut3  := TButton():New(153,005,'Ver Log Completo',oDlg,{|| (cFile:=CriaTrab(Nil,.F.)+'.Log',cSave:=GetTempPath(),SaveLog(if(lMacOS,'I:','')+cSave+cFile,aTexto),WaitRun(cComando+AllTrim(cSave+cFile),0),cFile:='')},070,010,,,.F.,.T.,.F.,,.F.,,,.F.)

         oDlg:Activate( , , , .T., { || .T. }, , { || oTimer:Activate() } )

      EndIf

   EndIf

Else

   lRet := .F.

EndIf

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} SAVELOG
description Funcao Generica para salvar o Log da Operacao do Patch
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function SaveLog(cFile,aLog)

Local nHdlLog := 0
Local nI,nZ   := 0

If At('.',cFile) = 0
   cFile := cFile + '.log'
EndIf

_nHdlLog := fCreate(cFile,Nil,Nil,!lMacOs)

For nI := 1 To Len(aLog)
   For nZ := 1 To Len(aLog[nI])
      If ValType(aLog[nI][nZ]) = 'C' .And. !(aLog[nI][nZ]==' Para ver o LOG Completo clique no botão abaixo !')
         fWrite(_nHdlLog,aLog[nI][nZ] + CRLF)
      EndIf
   Next nZ
Next nI

fClose(_nHdlLog)

Return( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} ESCEMPRESA
description Funcao Generica para escolha de Empresa, montado pelo SM0_
Retorna vetor contendo as selecoes feitas.
Se nao For marcada nenhuma o vetor volta vazio.
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function EscEmpresa(lExclu)

Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := Nil
Local   oChkMar  := Nil
Local   oChkPar  := Nil
Local   oChkOrd  := Nil
Local   oLbx     := Nil
Local   oFixEmp  := Nil
Local   oButInv  := Nil
Local   oSay     := Nil
Local   oOk      := LoadBitmap( GetResources(), 'LBOK' )
Local   oNo      := LoadBitmap( GetResources(), 'LBNO' )
Local   lOk      := .F.
Local   cVar     := ''
Local   cNomEmp  := ''
Local   aSelEmp  := {'01','02','03','04','05','90'}


If !MyOpenSm0Ex(lExclu)
   Return( aRet )
EndIf


dbSelectArea( 'SM0' )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

   If aScan( aSelEmp , {|x| x==AllTrim(SM0->M0_CODIGO)} ) == 0
      DbSkip()
      Loop
   EndIf

   If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
      aAdd(  aVetor, { .F. , SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
   EndIf

   DBSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title '' From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := 'Tela para Multiplas Seleções de Empresas/Filiais'

oDlg:cTitle := 'Selecione a(s) Empresa(s) para Atualização'

@ 10, 10 Listbox  oLbx Var  cVar Fields Header ' ', ' ', 'Empresa' Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| { IIf(aVetor[oLbx:nAt,1],oOk,oNo), aVetor[oLbx:nAt,2] , aVetor[oLbx:nAt,4] } }
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChkTod, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 109, 10 CheckBox oChkMar Var lChkTod Prompt 'Todos'   Message 'Marca / Desmarca Todos' Size 40, 007 Pixel Of oDlg on Click MarcaTodos( lChkTod, @aVetor, oLbx )


@ 123, 10 Button oButInv Prompt '&Inverter'  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChkTod, oChkMar ), VerTodos( aVetor, @lChkTod, oChkMar ) ) ;
Message 'Inverter Seleção' Of oDlg

Define SButton From 124, 127 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop 'Confirma a Seleção'  Enable Of oDlg
Define SButton From 124, 160 Type 2 Action ( oDlg:End() ) OnStop 'Abandona a Seleção' Enable Of oDlg

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( 'SM0' )
dbCloseArea()

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} MARCATODOS
description FFuncao Auxiliar para marcar/desmarcar todos os itens do
ListBox ativo.
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
   aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} INVSELECAO
description Funcao Auxiliar para inverter selecao do ListBox Ativo
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
   aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} RETSELECAO
description Funcao Auxiliar que monta o retorno com as selecoes
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
   If aVetor[nI][1]
      aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
   EndIf
Next nI

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} VERTODOS
description Funcao auxiliar para verificar se estao todos marcardos ou nao
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )

Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
   lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0Ex
description Funcao de processamento abertura do SM0 modo exclusivo
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function MyOpenSM0Ex(lExclu)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
   dbUseArea( .T.,, 'SIGAMAT.EMP', 'SM0', !lExclu , .F. )

   If !Empty( Select( 'SM0' ) )
      lOpen := .T.
      dbSetIndex( 'SIGAMAT.IND' )
      Exit
   EndIf

   Sleep( 500 )

Next nLoop

If !lOpen
   ApMsgStop( 'não foi possóvel a abertura da tabela ' + ;
              'de empresas' + If(lExclu,' de forma exclusiva.','.') , 'ATENção' )
EndIf

Return( lOpen )


//-------------------------------------------------------------------
/*/{Protheus.doc} LIBTABLE
description Executa a liberacao da role no Oracle para acessos aos
objetos porventura criados (executa no final do compatib.)
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function LibTable( aTexto )

If TcGetDB() == 'ORACLE' 

   oProcess:IncRegua1( 'Atualizando regras do Banco de dados...' )
   oProcess:IncRegua2( 'Atualizando regras do Banco de dados...' )

   TCSPEXEC('ap_atualizarolep11')

   LogAdd( @aTexto , 'Regras do Banco de dados atualizadas...' )

EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} LogAdd
description Funcao de gravacao do Log de processamento do compatibili
zador.@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function LogAdd(aTxt,cTxt)

If Empty(aTxt)
   aAdd( aTxt , cTxt )
ElseIf ValType(aTxt[1])=='C'
   If Len(aTxt) >= 3000
     aTxt := {aTxt,{}}       
     aAdd( aTxt[2] , cTxt )
   Else
      aAdd( aTxt , cTxt )
   EndIf
Else
   If Len(aTxt[Len(aTxt)]) >= 3000
      aAdd( aTxt , {} )
      aAdd( aTxt[Len(aTxt)] , cTxt )
 Else
      aAdd( aTxt[Len(aTxt)] , cTxt ) 
   EndIf
EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} DEFREGUA
description uFuncao Generica para informar a quantidade de registros a
a ser processada pela regua2.
@author Kaique Mathias    
@since 22/05/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function DefRegua( nI )

Local nRegua := 0 

If nI = 1
   nRegua := 4
Else
   nRegua := 318
EndIf

Return( nRegua )