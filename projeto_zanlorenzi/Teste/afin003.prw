
User Function fSelect(cProd,cOp)

Private nOpca          := 0
Private cArq        := ‘‘
Private cQuery      := ‘‘
Private lInverte      := .F.
Private aEstru          := {}
Private aCpoBro      := {}
Private cMark        := GetMark()   
Private oMark
Private oDlgLocal
Private lCheck
Private cDesc           :=Posicione("SB1",1,xFilial("SB1")+cProd,‘B1_DESC‘)

AADD(aEstru,{"OK"     ,"C"     ,2          ,0          })
AADD(aEstru,{"CODSUB" ,"C"     ,15          ,0          })
AADD(aEstru,{"DESSUB" ,"C"     ,70          ,0          })

cArq :=Criatrab(aEstru,.T.)

If Select("TTRB")>0; TTRB->(DbCloseArea()); Endif
     
DbUseArea(.T.,,cArq,"TTRB",.F.,.F.)

If Select("BIN")>0; BIN->(DbCloseArea()); Endif

cQuery := " SELECT * FROM "+RetSqlName("QZ3")+" QZ3"
cQuery += " WHERE QZ3.D_E_L_E_T_!=‘*‘"
cQuery += " AND QZ3_CODPRO = ‘"+cProd+"‘"
cQuery += " ORDER BY QZ3_CODPRO"
     
TcQuery cQuery New Alias "BIN"
BIN->(dbGoTop())

While BIN->(!Eof())
     DbSelectArea("TTRB")     
     RecLock("TTRB",.T.)
     TTRB->CODSUB := BIN->QZ3_CODSUB          
     TTRB->DESSUB := BIN->QZ3_DESSUB
     TTRB->(MsUnlock())          
     BIN->(DbSkip())
EndDo

aCpoBro     := {{ "OK"      ,,""        ,"@!"},;               
               { "CODSUB",,"Produto" ,"@!"},;             
                { "DESSUB",,"Descricao","@!"}}

DEFINE MSDIALOG oDlg TITLE "Selecao de Produto Substituto" From 9,0 To 315,800 PIXEL

@ 035,002 SAY cOp+‘   ‘+Alltrim(cProd)+‘ - ‘+cDesc SIZE 290, 008 OF oDlg COLORS 0, 16777215 PIXEL

oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{45,1,150,400},,,,,)
oMark:bMark := {| | Disp()}

lCheck := .F.

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End() },{||oDlg:End() }) CENTERED

Iif(File(cArq + GetDBExtension()),FErase(cArq + GetDBExtension()) ,Nil)

TTRB->(DbGotop())
If nOpca == 1
     While TTRB->(!Eof())
          IF !Empty(TTRB->OK) //campos selecionados
               cProd := TTRB->CODSUB
          Endif
          TTRB->(DbSkip())          
     EndDo
Endif
       
Return cProd

//------------------------------                                                                                           
//Marcar/Desmarcar um registro.   
//------------------------------
     
Static Function Disp()

RecLock("TTRB",.F.)
If Marked("OK")     
     TTRB->OK := cMark
Else
     TTRB->OK := ""
Endif
TTRB->(MsUnlock())

oMark:oBrowse:Refresh()

Return
