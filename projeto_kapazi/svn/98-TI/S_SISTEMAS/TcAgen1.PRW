#include "rwmake.ch"        
#INCLUDE "tbiconn.ch" 
#define GD_INSERT 1
#define GD_UPDATE 2
#define GD_DELETE 4


#xcommand DEFINE MSDIALOG <oDlg> ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName> ] ;
				 [ TITLE <cTitle> ] ;
				 [ FROM <nTop>, <nLeft> TO <nBottom>, <nRight> ] ;
				 [ <lib: LIBRARY, DLL> <hResources> ] ;
				 [ <vbx: VBX> ] ;
				 [ STYLE <nStyle> ] ;
				 [ <color: COLOR, COLORS> <nClrText> [,<nClrBack> ] ] ;
				 [ BRUSH <oBrush> ] ;
				 [ <of: WINDOW, DIALOG, OF> <oWnd> ] ;
				 [ <pixel: PIXEL> ] ;
				 [ ICON <oIco> ] ;
				 [ FONT <oFont> ] ;
				 [ <status: STATUS> ] ;
		 => ;
			 <oDlg> = MsDialog():New( <nTop>, <nLeft>, <nBottom>, <nRight>,;
					  <cTitle>, <cResName>, <hResources>, <.vbx.>, <nStyle>,;
					  <nClrText>, <nClrBack>, <oBrush>, <oWnd>, <.pixel.>,;
					  <oIco>, <oFont> , <.status.> )

#xcommand ACTIVATE MSDIALOG <oDlg> ;
				 [ <center: CENTER, CENTERED> ] ;
				 [ <NonModal: NOWAIT, NOMODAL> ] ;
				 [ WHEN <uWhen> ] ;
				 [ VALID <uValid> ] ;
				 [ ON [ LEFT ] CLICK <uClick> ] ;
				 [ ON INIT <uInit> ] ;
				 [ ON MOVE <uMoved> ] ;
				 [ ON PAINT <uPaint> ] ;
				 [ ON RIGHT CLICK <uRClicked> ] ;
		  => ;
			 <oDlg>:Activate( <oDlg>:bLClicked [ := <{uClick}> ], ;
									<oDlg>:bMoved	  [ := <{uMoved}> ], ;
									<oDlg>:bPainted  [ := <{uPaint}> ], ;
									<.center.>, [{|Self|<uValid>}],;
									[ ! <.NonModal.> ], [{|Self|<uInit>}],;
									<oDlg>:bRClicked [ := <{uRClicked}> ],;
									[{|Self|<uWhen>}] )


#define VK_F4           -3    //   F4
*-----------------------------------------------------------------------------------------------
User Function Tcagen1()                                                                         
* Ricardo Luiz da Rocha
* Utilitarios para uso no Protheus
* Atualizacao para MP8
*-----------------------------------------------------------------------------------------------              

SetPrvt("_LCHESTR,_LCHCONT,_LCHQUANT,_LQUANT,_LESTRIG,_LRECIG")
SetPrvt("_CALIAS,_CPERG1,_CRDMAKE,_CEXPR,_CARQ1,_CARQ2")
SetPrvt("_LERRO,_CQUEBRAL,_NTEMORI,_NTEMDES,_CNOMERR,_NHDL")
SetPrvt("_VESTR1,_VESTR2,_VESTRLIT1,_VESTRLIT2,_NVEZ,_CDET")
SetPrvt("_CCHAVE,_CCAMPO,_CACRESC,CINDEX,CKEY,CFILTER")
SetPrvt("_CULTIMO,_NJAFOI,_CCOND,_CCONT1,_CCONT2,_CRESULT")
SetPrvt("_CEXPRT,_XRESULT,_CTIPO,_CRDMAKEXEC,_NALIAS,SSALIAS")
SetPrvt("AREGS,I,J,")
lEnd:=.f.
Private tamanho,areturn,limite
_cRdmake:=space(12)
_cArqCfg:='TcAGen1_'+alltrim(substr(cUsuario,7,15))+'.ini'
if file(_cArqCfg)
   _cInicio:=alltrim(memoread(_cArqCfg))
   _cInicio:=strtran(_cInicio,chr(13),'')
   _cComando:=_cLido:=''
   for _nVez:=1 to len(_cInicio)
       _cLido:=substr(_cInicio,_nVez,1)
       if _cLido==chr(10)
          if !empty(_cComando)
             _x:=&_cComando
          endif   
          _cComando:=''
       else
          _cComando+=_cLido
       endif   
   next
endif

_lChEstr:=_lChCont:=_lChQuant:=.t.

_lQuant:=_lEstrIg:=_lRecIg:=.t.
_cAlias:=space(3)
_cPerg1:='TCGENa'
_cRdmake:=space(12)
_cExpr:=space(300)

validperg(_cPerg1)
pergunte(_cPerg1,.f.)
_cArq1:=alltrim(mv_par01)
_cArq2:=alltrim(mv_par02)
@ 000,000 To 460, 610 Dialog oDlg0 Title "(In) utilities - Estacao: " +getcomputername()+" | IP: "+getclientip()+" | Db: "+tcgetdb()+" | Server Type: "+TcSrvType()
//@ 010,010 To 035,110
@ 010,020 Say u__fAjTxt("AxCadastro de:")
@ 020,015 Get _cAlias size 40,10 Picture "@!"
@ 020,070 BmpButton Type 1 Action _fAx()// Substituido pelo assistente de conversao do AP5 IDE em 04/11/99 ==> @ 020,070 BmpButton Type 1 Action Execute(_fAx)
//@ 040,010 To 065,110
@ 040,020 Say u__fAjTxt("Executar Rdmake:")
@ 050,015 Get _cRdmake size 40,10 Picture "@!"
@ 050,070 BmpButton Type 1 Action _fRdmake()// Substituido pelo assistente de conversao do AP5 IDE em 04/11/99 ==> @ 050,070 BmpButton Type 1 Action Execute(_fRdmake)

@ 075,010 Say u__fAjTxt("Testar expressao obtendo resultados na linguagem ADVPL")
@ 090,012 Get _cExpr SIZE 230,10
@ 088,250 BmpButton Type 1 Action _fTestExpr()// Substituido pelo assistente de conversao do AP5 IDE em 04/11/99 ==> @ 100,015 BmpButton Type 1 Action Execute(_fTestExpr)

@ 105,012 BmpButton Type 1 Action _fChecaDup()
@ 105,050 Say u__fajtxt("Checagem anti-duplicidade de registros")
@ 120,012 BmpButton Type 1 Action _fEARA()
@ 120,050 Say u__fajtxt("Exporta-Apaga-Recria-Appenda (Top)")
@ 135,012 BmpButton Type 1 Action _fTestaCond()
@ 135,050 Say u__fajtxt("Testar condicoes de pagamento")
@ 150,012 BmpButton Type 1 Action _fGeraB2()
@ 150,050 Say u__fajtxt("Gerar saldos em SB2")
@ 165,012 BmpButton Type 1 Action _fGeraB9()
@ 165,050 Say u__fajtxt("Gerar saldos em SB9")

@ 180,012 BmpButton Type 1 Action _fInvCt5()
@ 180,050 say "Inverte CT5"

@ 195,012 BmpButton Type 1 Action _fCtt2Si3()
@ 195,050 say "Sobrepor SI3 com CTT"

@ 210,012 BmpButton Type 1 Action _fReordX3()
@ 210,050 say "Ajusta ordem em SX3"
@ 105,160 BmpButton Type 1 Action _fInvUser()
@ 105,193 Say u__fajtxt("Inventario de usuarios do sistema")

@ 120,160 BmpButton Type 1 Action _fGeraSx1()
@ 120,193 Say u__fajtxt('Gerar codigo para "ValidPerg" a partir de SX1')

@ 135,160 BmpButton Type 1 Action _fReplace()
@ 135,193 Say u__fajtxt('Replace condicional')

@ 150,160 BmpButton Type 1 Action _fB7Zero()
@ 150,193 Say u__fajtxt('Gerar saldo 0 para inventario')

@ 165,160 BmpButton Type 1 Action u_RBackup(.f.)
@ 165,193 Say u__fajtxt('Backup')

@ 180,160 BmpButton Type 1 Action _fReindex()
@ 180,193 say "Reindexar/Recriar tabelas"

@ 195,160 BmpButton Type 1 Action _fB1ToBz()
@ 195,193 say "Popular SBZ com SB1"

@ 210,160 BmpButton Type 1 Action _fCriaCts()
@ 210,193 say "Criar visao gerencial"

@ 010,125 Say u__fAjTxt("Comparar:")
@ 020,130 CHECKBOX "Estruturas             " var _lChEstr 
@ 030,130 CHECKBOX "Conteudo               " var _lChCont 
@ 040,130 CHECKBOX "Quantidade de registros" var _lChQuant
@ 004,120 to 73,228
@ 004,120 to 73,228

@ 055,140 BmpButton Type 1 Action _fCompara()
@ 055,180 BmpButton Type 5 Action _fPar()
@ 010,265 BmpButton Type 2 Action close(oDlg0)
@ 040,255 button "Sair do sistema" size 45,20 action(_fQuit())
Activate Dialog oDlg0 Centered
return

*----------------------------------------------------------------------------------
static function _fCriaCts()
* Cria uma visao gerencial simples com base no plano de contas
*----------------------------------------------------------------------------------

_cCodPla:=criavar("CTS_CODPLA")
_cNome:=criavar("CTS_NOME")
cts->(dbsetorder(1))
@ 000,000 to 200,500 dialog _oDlgCts title "Criar visao gerencial"
@ 010,005 say "Esta rotina criara uma visao gerencial simples com base em seu plano de contas"
@ 022,005 say "Informe abaixo os dados da nova visao a ser criada: "
@ 045,005 say "Codigo: "
@ 045,070 get _cCodPla picture x3picture("CTS_CODPLA") valid cts->(!dbseek(xfilial()+_cCodPla,.f.))
@ 057,005 say "Nome: "
@ 057,070 get _cNome size 130,15 picture x3picture("CTS_NOME") valid !empty(_cNome)
@ 080,100 button "Criar" action(processa({||_fContCts()},"Criando a nova visao"),close(_oDlgCts)) object _oButCts
_oButCts:BWhen:={||!empty(_cCodPla).and.!empty(_cNome)}
@ 080,200 button "Sair" action(close(_oDlgCts))
activate dialog _oDlgCts center

*----------------------------------------------------------------------------------
static function _fContCts()
*----------------------------------------------------------------------------------
cve->(dbsetorder(1))
_lExiste:=cve->(dbseek(xfilial()+_cCodPla,.f.))
cve->(reclock(alias(),!_lExiste))
if !_lExiste
   cve->cve_filial:=xfilial("CVE")
   cve->cve_codigo:=_cCodPla
endif
cve->cve_descri:=_cNome
cve->(msunlock())
   
ct1->(dbsetorder(1))
procregua(ct1->(lastrec()))
ct1->(dbgotop())
_nOrdem:=0
_cCt1Ini:=_cCt1Fim:=_cContaSup:=''
_vSinteticas:={}
do while .t.
	incproc()
	if _cContaSup<>left(ct1->ct1_conta,len(_cContaSup))
	   _cContaSup:=''
	endif
	
   if ct1->(ct1_classe=='1'.or.eof()) // Sintetica
      aadd(_vSinteticas,alltrim(ct1->ct1_conta))
      
      if !empty(_cCt1Ini).and.!empty(_cCt1Fim)
	      if cts->(reclock(alias(),.f.))
	         cts->cts_classe:='2'
	         cts->cts_ident :='1'
	         cts->cts_ct1Ini:=_cCt1Ini
	         cts->cts_ct1Fim:=_cCt1Fim
	         cts->(Msunlock())
	      endif
	      _cCt1Ini:=_cCt1Fim:=''
	      if ct1->(eof())
	         exit
	      endif   
      endif

	   	_nOrdem+=10
      if cts->(reclock(alias(),.t.))
         cts->cts_filial:=xfilial("CTS")
         cts->cts_codpla:=_cCodPla
         cts->cts_nome  :=_cNome
         cts->cts_ordem :=strzero(_nOrdem,10)
         cts->cts_contag:=ct1->ct1_conta

         if empty(_cContaSup) // Se a conta superior está vazia, faz mas uma tentativa de localizacao

            _cBuscar:=alltrim(ct1->ct1_conta)
            _cBuscar:=left(_cBuscar,len(_cBuscar)-1)

            do while empty(_cContaSup).and.!empty(_cBuscar)
               if (_nPosic:=ascan(_vSinteticas,{|_cConta|_cConta==_cBuscar}))==0
                  _cBuscar:=left(_cBuscar,len(_cBuscar)-1)
               else
                  _cContaSup:=_vSinteticas[_nPosic]   
               endif
            enddo
         
         endif
         
         cts->cts_ctasup:=_cContaSup
         cts->cts_desccg:=ct1->ct1_desc01
         cts->cts_normal:=ct1->ct1_normal
         cts->cts_classe:=ct1->ct1_classe
         cts->cts_linha :='001'
         cts->cts_ident :='1'
         cts->cts_tpsald:='1'
         cts->cts_coluna:=if(left(cts->cts_contag,1)$'1357',1,2)
         
         //cts->cts_cttfim:='z'
         //cts->cts_ctdfim:='z'
         //cts->cts_cthfim:='z'

         // Identificadores
         cts->cts_totvis:='2'
         cts->cts_visent:='1'
         cts->cts_sldent:='1'
         cts->cts_fatsld:='1'
         cts->cts_ident :='3'
         
         cts->(msunlock())
		 _cContaSup:=alltrim(ct1->ct1_conta)         
      endif
   else
      if empty(_cCt1Ini)
         _cCt1Ini:=ct1->ct1_conta
      endif
      _cCt1Fim:=ct1->ct1_conta
      _cContaSup:=alltrim(cts->cts_ctaSup)         
   endif      
    ct1->(dbskip(1)) 
enddo
alert("Criacao concluida, entrando na rotina de manutencao")
ctba160()
*----------------------------------------------------------------------------------
static function _fQuit()
*----------------------------------------------------------------------------------
dbcommitall()
commit
//abandona()
quit

*----------------------------------------------------------------------------------
static function _fReordX3()
*----------------------------------------------------------------------------------
_cAlias:=space(3)
@ 0,0 to 100,280 dialog _oDlgX3 title 'Ajustar a ordem em SX3'
@ 12,010 say 'Alias: '
@ 10,025 get _cAlias picture '@!'  valid !empty(_cAlias)
@ 10,065 bmpbutton type 1 action (if(_fReordX3a(),close(_oDlgx3),nil))
@ 10,100 bmpbutton type 2 action close(_oDlgX3)
activate dialog _oDlgX3 centered

*----------------------------------------------------------------------------------
static function _fReordX3a()
*----------------------------------------------------------------------------------
local _lReturn:=.f.,_nVez
sx3->(dbsetorder(1))

if sx3->(dbseek(_cAlias,.f.))
   cursorwait()
   _vCampos:={}
   do while sx3->(!eof().and.alltrim(x3_arquivo)==_cAlias)
      aadd(_vCampos,sx3->x3_campo)
      sx3->(dbskip(1))
   enddo          
   sx3->(dbsetorder(2))
   _cOrdem:='00'
   for _nVez:=1 to len(_vCampos)
       _cOrdem:=soma1(_cOrdem,2)
       if sx3->(dbseek(_vCampos[_nVez],.f.).and.reclock(alias(),.f.))
          sx3->x3_ordem:=_cOrdem //RetAsc(Str(_nVez),2,.T.)
          sx3->(msunlock())
       endif
   next
   sx3->(dbsetorder(1))
   cursorarrow()
   _lReturn:=.t.
   msgbox('O alias ['+_cAlias+'] foi reordenado com sucesso')

else
   msgbox('Alias ['+_cAlias+'] não localizado em SX3')
endif

Return _lReturn

*----------------------------------------------------------------------------------
Static function _fEara()
* Exporta / Apaga / Recria / Appenda tabelas
* Bom para regularização de estruturas de dados
*----------------------------------------------------------------------------------
local _oDlg1,aregs:={}

private _cPerg:="FEARA1"

             *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
             *+---------------------------------------------------------------------------------------------------------------------------------+
             *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
             *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
             *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
             *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
             *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
   AADD(aRegs,{_cPerg,"01","Tabelas a tratar             :","mv_ch1","C",60,0,0,"G","","mv_par01",""    ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg,"02","Continuacao Tabelas a tratar :","mv_ch2","C",60,0,0,"G","","mv_par02",""    ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg,"03","Diretorio temporario         :","mv_ch3","C",60,0,0,"G","","mv_par03",""    ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg,"04","Considera registros excluidos:","mv_ch4","N",01,0,0,"C","","mv_par04","Sim"    ,"","","Nao"      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg,"05","Enviar copias ao dir. local  :","mv_ch5","C",60,0,0,"G","","mv_par05",""    ,"","",""      ,"","","","","","","","","","",""})
   
u__fAtuSx1(padr(_cPerg,len(sx1->x1_grupo)),aRegs)

@ 0,0 to 210,500 dialog _oDlg1 title "Atualizacao de estruturas"
@ 010,010 say u__fAjTxt("Esta rotina permite que se atualize as estruturas das tabelas mencionadas nos parametros")
@ 020,010 say u__fAjTxt("Os dados tratados sempre se referem a empresa atual ("+sm0->(alltrim(m0_nome)+" / "+alltrim(m0_filial))+").")
@ 030,010 say u__fAjTxt("Nos parametros, informe apenas os prefixos das tabelas, separando-os por virgula.")
@ 040,010 say u__fAjTxt("O diretorio temporario devera estar diretamente localizado sob AP_DATA.")

@ 060,010 button "Exporta" size 40,15 action _fEAra1("exporta")
@ 060,060 button "Apaga"   size 40,15 action _fEAra1("apaga")
@ 060,110 button "Recria"  size 40,15 action _fEAra1("recria")
@ 060,160 button "Appenda" size 40,15 action _fEAra1("appenda")

@ 085,140 Bmpbutton type 5 action pergunte(_cPerg,.t.)
@ 085,180 Bmpbutton type 2 action close(_oDlg1)

activate dialog _oDlg1 centered

return

*----------------------------------------------------------------------------------
Static function _fEara1(_cOper)
*----------------------------------------------------------------------------------
local _cTabelas,_cPermit:=",0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",;
      _cLido,_cSepar:=";/.-",_cTab1:="",_cAdiciona:="",_cAlias,_nVez
private _vTabelas:={}
pergunte(_cPerg,.f.)
_cOper:=alltrim(lower(_cOper))
_cTabelas:=upper(alltrim(mv_par01))+","+upper(alltrim(mv_par02))
_cPath:=alltrim(mv_par03)
_lExcluidos:=(mv_par04==1)
_cDirLocal:=alltrim(mv_par05)
if empty(_cPath)
   msgbox("O diretorio temporario nao pode ficar em branco")
   return
endif
if right(_cPath,1)<>"\"                                                            
   _cPath+="\"
endif
_cTabelas:=strtran(_cTabelas," ","")
for _nVez:=1 to len(_cTabelas)
    _cLido:=substr(_cTabelas,_nVez,1)
    if !_cLido$_cPermit
       if _cLido$_cSepar
          _cLido:=","
       else
          _cLido:=""
       endif
    endif         
    _cTab1+=_cLido
next
_cTab1+=","
_cTab1:=strtran(_cTab1,",,",",")
_lContinua:=.t.

for _nVez:=1 to len(_cTab1)
    _cLido:=substr(_cTab1,_nVez,1)
    if _cLido==","
       if len(_cAdiciona)<>3
          _lContinua:=.f.
       elseif !u__fIsOpen(_cAdiciona)
          chkfile(_cAdiciona)
          if !u__fIsOpen(_cAdiciona)
             msgbox("Nao foi possivel abrir "+_cAdiciona)
             _lContinua:=.f.
          endif
       endif
       if _lContinua
          aadd(_vTabelas,_cAdiciona)
       endif
       _cAdiciona:=""
    else
       _cAdiciona+=_cLido
    endif
next

if !_lContinua
   return
endif
if msgyesno("Operacao: "+_cOper+chr(13)+;
            if(_cOper$"apaga/recria","","Diretorio temporario: "+_cPath+chr(13))+;
            "Tabela(s): "+_cTabelas+chr(10)+chr(13)+;
            "Deseja prosseguir ?")
   cursorwait()         
   u_rsaguarde({||_fEara2(_cOper)},"Aguarde")
   cursorarrow()
endif

*-----------------------------------------------------------------------------------
static function _fEara2(_cOper)   
*-----------------------------------------------------------------------------------
local _nVez
// Se chegou nesse ponto, todas as tabelas mencionadas nos parametros estao abertas
// e alimentadas em _vTabelas
_lContinua:=.t.
for _nVez:=1 to len(_vTabelas)
    _cAlias:=_vTabelas[_nVez]
    dbselectarea(_cAlias)
    if alias()<>_cAlias
       msgbox("Nao foi possivel selecionar "+_cAlias+" nao e possivel continuar.")
       exit
    endif   
    if _lExcluidos
       set(11,"OFF")
    endif
    _cSqlName:=retSqlName(_cAlias)
    u_rsproctxt("Operacao: "+_cOper+" Tabela: "+if(_cOper$"apaga/recria",_cSqlName,_cAlias))
    
    do case
       case _cOper=="exporta" //TcSrvType()
            if "LINUX"$upper(TcSrvType())  
               if left(_cPath,1)$'/\'
                  _cPath:=substr(_cPath,2)
               endif   
               _cDestino:=_cPath+_cSqlName
            else
               _cDestino:="\"+_cPath+_cSqlName
            endif
            copy to &_cDestino
            if !empty(_cDirLocal)
                _cStartPath:=GetSrvProfString("Startpath","")
                u_rsproctxt("Operacao: "+_cOper+" Tabela: "+if(_cOper$"apaga/recria",_cSqlName,_cAlias)+" (Copiando para "+_cDirLocal+")")
               __copyfile(_cDestino+".*",_cDirLocal)
            endif   
            /*
            if !file(_cDestino+".*")
               msgbox("Falha na criacao de: "+_cDestino)
               _lContinua:=.f.
            endif
            */
       case _cOper=="apaga"
            dbclosearea()                     
            if tccanopen(_cSqlName)
               tcdelfile(_cSqlName)
               if tccanopen(_cSqlName)
                  msgbox("Falha: "+_cSqlname)
                  _lContinua:=.f.
               endif
            endif
       case _cOper=="recria"
            u__fCloseDb(_cAlias)
            if !chkfile(_cAlias)
               msgbox("Falha: "+_cAlias)
               _lContinua:=.f.
            endif
       case _cOper=="appenda"         
            _cOrigem:=_cPath+_cSqlName
            append from &_cOrigem
    endcase
    if _lExcluidos
       set(11,"ON")
    endif   
    if !_lContinua
       exit
    endif   
next    

if "MP8"$cVersao
   dbselectarea("SM0")
endif   

*----------------------------------------------------------------------------------
Static function _fCompara()
*----------------------------------------------------------------------------------
u_RsAguarde({||_fCompstr()},'Comparando o conteudo dos arquivos')// Substituido pelo assistente de conversao do AP5 IDE em 04/11/99 ==> MsAguarde({||Execute(_fCompstr)},'Comparando o conteudo dos arquivos')
return

*----------------------------------------------------------------------------------
Static function _fCompStr()
*----------------------------------------------------------------------------------
local _nVez
pergunte(_cPerg1,.f.)
_cArq1:=alltrim(mv_par01)
_cArq2:=alltrim(mv_par02)
_cChave:=alltrim(mv_par03)+alltrim(mv_par04)

_vLog:={}
_lErro:=.f.
_cQuebral:=chr(13)+chr(10)
_cArq1:=if(lower(right(_cArq1,4))<>lower('.dbf'),_cArq1+'.dbf',_cArq1)
_cArq2:=if(lower(right(_cArq2,4))<>lower('.dbf'),_cArq2+'.dbf',_cArq2)

if _lChCont
   _lChEstr:=.t.
endif

if !file(_cArq1)
   _lErro:=.t.
   msgbox('Arquivo origem '+_cArq1+' nao encontrado')
endif
if !file(_cArq2)
   _lErro:=.t.
   msgbox('Arquivo destino '+_cArq2+' nao encontrado')
endif
if _lErro
   return
endif
dbusearea(.t.,,_cArq1,'Origem',.t.,.f.)
if lower(alias())<>lower('origem')
   _lErro:=.t.
   msgbox('Erro de abertura em '+_cArq1)
endif
dbusearea(.t.,,_cArq2,'Destino',.t.,.f.)
if lower(alias())<>lower('Destino')
   _lErro:=.t.
   msgbox('Erro de abertura em '+_cArq2)
endif
if _lErro
   return
endif
// Comparar a quantidade de registros nao deletados
_lQuant:=.t.
if _lChQuant

   origem->(dbgotop())
   destino->(dbgotop())
   _nTemOri:=1
   do while !origem->(eof()).and.lastkey()<>27
      u_Rsproctxt('Contando registros nao apagados na origem '+alltrim(str(_nTemOri)))
      _nTemOri:=_nTemOri+1
      origem->(dbskip(1))
   enddo
   _nTemDes:=1
   do while !destino->(eof()).and.lastkey()<>27
      u_rsproctxt('Contando registros nao apagados no Destino '+alltrim(str(_nTemDes)))
      _nTemDes:=_nTemDes+1
      Destino->(dbskip(1))
   enddo
   if _nTemDes<>_nTemOri
      _lQuant:=.f.
      _lErro:=.t.
      aadd(_vLog,'O arquivo '+_cArq1+' possue '+alltrim(str(_nTemOri))+' registros nao apagados, e '+;
             _cArq2+' possue '+alltrim(str(_nTemDes)))
   else
      aadd(_vLog,"Os arquivos possuem a mesma quantidade de registros nao apagados ("+alltrim(str(_nTemOri))+")")
   endif
endif

// Comparar estruturas
_lEstrIg:=.t.
if _lChEstr
   _vEstr1:=origem->(dbstruct())
   _vEstr2:=destino->(dbstruct())

   if len(_vEstr1)<>len(_vEstr2)
      if len(_vEstr1)>len(_vEstr2)
         _cMens:=_cArq1+' possue mais campos que '+_cArq2
         aadd(_vLog,_cMens)
         //msgbox(_cMens)
      else
         _cMens:=_cArq2+' possue mais campos que '+_cArq1
         //msgbox(_cMens)
         aadd(_vLog,_cMens)
      endif
      _lEstrIg:=.f.
      _lErro:=.t.
   endif
   //_vEstrLit1:={}
   //_vEstrLit2:={}
   _vEstrLit:={}
   _nVez:=1
   _nLen:=len(padr(_vEstr1[_nVez][1],12)+_vEstr1[_nVez][2]+' '+;
              padr(alltrim(str(_vEstr1[_nVez][3])),5)+padr(alltrim(str(_vEstr1[_nVez][4])),5))
   aadd(_vLog,'')
   aadd(_vLog,'     Origem                  Destino')
  
   for _nVez:=1 to len(_vEstr1)
       _cDet1:=padr(_vEstr1[_nVez][1],12)+_vEstr1[_nVez][2]+' '+;
              padr(alltrim(str(_vEstr1[_nVez][3])),5)+padr(alltrim(str(_vEstr1[_nVez][4])),5)
       if (_nPosic:=ascan(_vEstr2,{|_vAux|_vAux[1]==_vEstr1[_nVez][1]}))>0
          _cDet2:=padr(_vEstr2[_nPosic][1],12)+_vEstr2[_nPosic][2]+' '+;
              padr(alltrim(str(_vEstr2[_nPosic][3])),5)+padr(alltrim(str(_vEstr2[_nPosic][4])),5)
          adel(_vEstr2,_nPosic)
          asize(_vEstr2,len(_vEstr2)-1)
          if _cDet1==_cDet2
             aadd(_vLog,"     "+_cDet1+_cDet2)
          else
             _lEstrIg:=.f.
             aadd(_vLog,"*--> "+_cDet1+_cDet2)
          endif
       else
          aadd(_vLog,"*-.> "+_cDet1+space(_nLen))
       endif
   next   

   for _nVez:=1 to len(_vEstr2)
       _lEstrIg:=.f.
       _cDet2:=padr(_vEstr2[_nVez][1],12)+_vEstr2[_nVez][2]+' '+;
               padr(alltrim(str(_vEstr2[_nVez][3])),5)+padr(alltrim(str(_vEstr2[_nVez][4])),5)
       aadd(_vLog,"*.-> "+space(_nLen)+_cDet2)
   next
   _vEstr2:=destino->(dbstruct())

   if !_lEstrIg
      aadd(_vLog,'As Estruturas sao diferentes')
   endif
endif         
aadd(_vLog,"")
_lCont:=.t.
if _lChCont
   if lastkey()<>27
      dbselectarea('Origem')
      cIndex:=CriaTrab(nil,.f.) 
      cKey:=_cChave
      cFilter:=""
      IndRegua(alias(),cIndex,cKey,,cFilter,"Selecionando Registros no arquivo "+alias())
   endif
   if lastkey()<>27
      dbselectarea('Destino')
      cIndex:= CriaTrab(nil,.f.)
      cKey:=_cChave
      cFilter:=""
      IndRegua(alias(),cIndex,cKey,,cFilter,"Selecionando Registros no arquivo "+alias())
   endif
   _cUltimo:='/'+alltrim(str(origem->(lastrec())))

   origem->(dbgotop())
   //destino->(dbgotop())
   _nJafoi:=0
   _vComum:={}
   for _nVez:=1 to len(_vEstr1)
       if ascan(_vEstr2,{|_vAux|_vAux[1]==_vEstr1[_nVez][1]})==0
       else
          aadd(_vComum,_vEstr1[_nVez][1])
       endif
   next

   do while !origem->(eof()).and.lastkey()<>27
      _nJafoi:=_nJafoi+1
      u_Rsproctxt('Origem x Destino: '+alltrim(str(_nJafoi))+_cUltimo)
      _cSeek:=&("origem->("+_cChave+")")

      if destino->(dbseek(_cSeek,.f.))
         _cDetP:='O registro '+alltrim(str(origem->(recno())))+' em '+_cArq1+;
                       ' e diferente do registro '+alltrim(str(destino->(recno())))+' no arquivo '+_cArq2+" Chave: "+_cSeek
      
         for _nVez:=1 to len(_vComum)
             _cCond:='origem->'+_vComum[_nVez]+'==destino->'+_vComum[_nVez]
             _cCont1:=_fxToC(&('origem->' +_vComum[_nVez]))
             _cCont2:=_fxToC(&('destino->'+_vComum[_nVez]))

             if _cCont1==_cCont2
             else
                _lRecIg:=.f.
                _lCont:=.f.
                _cInicio:="Campo: "+_vComum[_nVez]
                _cDet:=' Conteudo na origem:  "'+_cCont1+'"'

                if ascan(_vLog,_cDetP)==0
                   aadd(_vLog,_cDetP)
                endif
                aadd(_vLog,_cInicio+_cDet)
                _cDet:=' Conteudo no destino: "'+_cCont2+'"'
                aadd(_vLog,space(len(_cInicio))+_cDet)
                aadd(_vLog,"")
             endif
         next
      else
         aadd(_vLog,'Chave: "'+_cSeek+'" em '+alltrim(_cArq1)+'" nao localizada em '+alltrim(_cArq2))
      endif
      origem->(dbskip(1))
   enddo
   _cUltimo:='/'+alltrim(str(destino->(lastrec())))
   destino->(dbgotop())
   _nJafoi:=0
   do while !destino->(eof()).and.lastkey()<>27
      _nJafoi:=_nJafoi+1
      u_rsproctxt('Destino x Origem: '+alltrim(str(_nJafoi))+_cUltimo)
      _cSeek:=&("destino->"+_cChave)

      if origem->(dbseek(_cSeek,.f.))
      else
         aadd(_vLog,'Chave: "'+_cSeek+'" em '+alltrim(_cArq2)+'" nao localizada em '+alltrim(_cArq1))
      endif
      destino->(dbskip(1))
   enddo
endif
origem->(dbclosearea())
destino->(dbclosearea())
_cResult1:=_cResult2:=_cResult3:=''
if _lChEstr
   _cResult1:='Estruturas: '+if(_lEstrIg,'Iguais','Diferentes')
endif
if _lChCont
   _cResult2:='Conteudos: '+if(_lCont,'Iguais','Diferentes')
endif
if _lChQuant
   _cResult3:='Quantidade de registros: '+if(_lQuant,'Iguais','Diferentes')
endif
if lastkey()==27
   aadd(_vLog,"")
   msgbox('Processamento interrompido')
else
   msgbox(_cResult1+chr(13)+_cResult2+chr(13)+_cResult3)
   if _lEstrIg.and._lCont.and._lQuant
      _vLog:={}
   endif   
endif
if len(_vLog)>0
   _fImpLog()
endif   

return

*-------------------------------------------------------------------------
static function _fImpLog()
*-------------------------------------------------------------------------

nLastKey  :=0
limite    :=220
wnrel     :=nomeprog:="TcaGen1"
cDesc1    :="Comparacao de arquivos "+_cArq1+"(Origem) x "+_cArq2+" (Destino)"
cDesc2    :=" "
cDesc3    :=" "
cString   :="SA1" // isto, ao inves de "SX2". resolve o erro "array out off bounds" na setprint
tamanho   := "G"
titulo    := cDesc1
aReturn   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",0 }
_nLin     :=99
m_pag     :=1
Li        :=0
Cabec1:=""
Cabec2:=""

wnrel := SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.t.,,.t.,tamanho)
if nLastkey==27
   set filter to
   return
endif

RptStatus({|| RptDetail() })

*-------------------------------------------
Static function rptdetail
*-------------------------------------------
local _nVez
setdefault(aReturn,cString)
setregua(len(_vLog))
_nLin:=99
_cUltimo:=_vLog[1]
for _nVez:=1 to len(_vLog)
    incregua()
    if _nLin>58
       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
       _nLin:=li+2
    endif
    @ _nLin++,0 PSAY _vLog[_nVez]
next

roda(0,"",tamanho)

If aReturn[5] == 1
   Set Printer To
   Commit
   ourspool(wnrel)
Endif
MS_FLUSH()
Return

*----------------------------------------------------------------------------------
Static function _fPar()
*----------------------------------------------------------------------------------
pergunte(_cperg1,.t.)

return

*----------------------------------------------------------------------------------
Static function _fAx()
*----------------------------------------------------------------------------------
Dbselectarea(_cAlias)
if lower(alias())==lower(_cAlias)
   AxCadastro( _cAlias,'Arquivo '+_cAlias)
else 
   msgbox('Alias ['+_cAlias+'] nao disponivel')
endif   

Return
*----------------------------------------------------------------------------------              
user function _fAjTxt(_cTexto)
// Incrementa o texto com espacos, para que o protheus exiba corretamente
*----------------------------------------------------------------------------------
return padr(_cTexto,(int(len(_cTexto)*1.5)))



// Substituido pelo assistente de conversao do AP5 IDE em 04/11/99 ==> function _fTestExpr
Static function _fTestExpr()
_cExprT:=alltrim(_cExpr)
_xResult:=&_cExprT
_cTipo:=valtype(_xResult)
if _cTipo=='D'
   _xResult:=dtoc(_xResult)
elseif _cTipo=='N'
   _xResult:=alltrim(str(_xResult))
elseif _cTipo=='L'
   _xResult:=if(_xResult,'.T.','.F')
elseif _cTipo=='B'
   _xResult:='A expressao retorna bloco de codigo'
elseif _cTipo=='U'
   _xResult:='A variavel nao existe ou nao e visivel'
endif
Tone(400,3)
msgbox('('+_cTipo+') '+_xResult)

return
*----------------------------------------------------------------------------------
Static function _fRdmake()
*----------------------------------------------------------------------------------
/*
_cRdmakexec:=alltrim(_cRdmake)+'._iw'
if !file(_cRdmakexec)
   msgbox('O arquivo '+_cRdmakexec+' nao foi localizado')
else
   Execblock(_cRdmakexec)
endif                    
*/
_cInicio:=alltrim(memoread(_cArqCfg))
_cExec:="u_"+alltrim(_cRdmake)+"()"
_x:=&_cExec
return

*----------------------------------------------------------------------------------
Static Function VALIDPERG(_cPerg1)
*----------------------------------------------------------------------------------
local aRegs:={}
             *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
             *+---------------------------------------------------------------------------------------------------------------------------------+
             *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
             *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
             *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
             *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
             *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
   AADD(aRegs,{_cPerg1,"01","Arquivo origem     :","mv_ch1","C",30,0,0,"G","","mv_par01",""    ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg1,"02","Arquivo destino    :","mv_ch2","C",30,0,0,"G","","mv_par02",""    ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg1,"03","Chave primaria     :","mv_ch3","C",60,0,0,"G","","mv_par03",""    ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg1,"04","Continuacao chave  :","mv_ch4","C",60,0,0,"G","","mv_par04",""    ,"","",""      ,"","","","","","","","","","",""})

u__fAtuSx1(padr(_cPerg1,len(sx1->x1_grupo)),aRegs)
Return

*-----------------------------------------------------------------------------
user function _fCloseDb(_cAlias)
* Tenta fechar o alias indicado                                               
*-----------------------------------------------------------------------------
local _cAliasAtu:=Upper(alias())
   
if u__fIsOpen(_cAlias)
   dbselectarea(_cAlias)
   DbClosearea()
endif              

if _cAliasAtu<>upper(_cAlias).and.!empty(_cAliasAtu)
   Dbselectarea(_cAliasAtu)
endif
Return

*-----------------------------------------------------------------------------
user function _fIsOpen(_cAlias)
* Retorna logico, se o alias esta ou nao aberto                        
*-----------------------------------------------------------------------------
local _cAliasAtu:=Upper(alias()),_nVez:=1,_lAberto,_nTeste
_nTeste:=select("SM0")
_nTeste:=select(_cAlias)
_lAberto:=(!empty(_cAlias).and._nTeste>0)

if "MP8"$cVersao//.and.!_lAberto
   // Atualizacao para MP8
   //dbselectarea(_cAlias)
   //if upper(alias())==_cAlias
   //   _lAberto:=.t.
   //endif
else
   dbselectarea(_nVez)
   do while _nVez<300
      dbselectarea(_nVez)
      _nVez++
      if lower(alltrim(alias()))==lower(alltrim(_cAlias))
        _lAberto:=.t.
        exit
      endif
   enddo
endif
if !empty(_cAliasAtu)
   dbselectarea(_cAliasAtu)
endif   
return _lAberto
                                                    
*-----------------------------------------------------------------------------*
static function _fChecaDup()
*-----------------------------------------------------------------------------*

_cAlias:='   '
_nOrdem:=1
_cChave:=space(200)

@ 010,000 To 200, 610 Dialog oDlg Title OemToAnsi( "Checagem anti-duplicidade")
@ 010,020 Say 'Alias    : '
@ 010,050 get _cAlias
@ 020,020 Say 'Ordem:     '
@ 020,050 get _nOrdem pict '99'    valid _fOrdem()
@ 030,020 Say 'Chave:     '  
@ 030,050 get _cChave pict '@ks50' SIZE 200,10
@ 080,080 BmpButton Type 1 Action _fProssegue()
@ 080,110 BmpButton Type 2 action Close(oDlg)
ACTIVATE DIALOG oDlg CENTER

Return

*----------------------------------------------------------------------------------
static function _fOrdem
*----------------------------------------------------------------------------------
if _nOrdem==0
   return .t.
endif   
dbselectarea(_cAlias)
if empty(alias())
   msgbox('Alias ['+_cAlias+'] nao disponivel')
   return .t.
endif            
dbsetorder(_nOrdem)
_cChave:=indexkey()
return .t.

*----------------------------------------------------------------------------------
static function _fProssegue
*----------------------------------------------------------------------------------                  

ferase('pare.txt')            
msaguarde({||_fVerifica()},'Verificando arquivo...')
return                                                    
      
static function _fVerifica
_cChave:=alltrim(_cChave)

if _nOrdem=0.and.empty(_cChave)
   msgbox('Sem chave / Sem acordo')
   return
elseif _nOrdem==0
  dbselectarea(_cAlias)
  if empty(alias())
     msgbox('Alias ['+_cAlias+'] nao disponivel')
     return
  endif
  indregua(alias(),criatrab(,.f.),_cChave,,,"Ordenando: "+alias())

endif

dbgotop()
_nPerc:=0
_cAnt:='estanaotemmesmo...'
_nDuplic:=0
_nPerc:=0
_vDuplic:={'Alias: '+alias()+' Chave: '+Indexkey(),''}
do while !eof().and.!file('pare.txt')
   msproctxt("Lidos: "+alltrim(str(_nperc++))+' / '+alltrim(str(lastrec()))+;
             '   Duplicados: '+alltrim(str(_nDuplic)))
   if &_cChave==_cAnt
      _nDuplic++      
      aadd(_vDuplic,'Registro: ['+strzero(recno(),6)+'] Chave: ['+_cAnt+']')
   endif              
   _cAnt:=&_cChave
   dbskip(1)
enddo

if _nDuplic>0.and.msgyesno('Ha '+alltrim(str(_nDuplic))+;
                         ' registros duplicados, deseja imprimir ?')
   
   aReturn := { "Zebrado",;      // Tipo do formulario
                        1,;      // Numero de vias
          "Administracao",; // Destinatario
                        1,;      // Formato 1-Comprimido  2-Normal
                        1,;      // Midia  1-Disco  2-Impressora
               'CHECADUP',;      // Porta ou arquivo (1-LPT1...)
                        "",;      // Expressao do filtro
                         1 }      // Ordem (Numero do indice)                                                                        
                         
   cString:=alias()                      
   wnrel:="CHECADUP" 
   Titulo:='Registros duplicados em '+alias()
                 
   cperg:=''
   cdesc1:=cdesc2:=cdesc3:=''
   tamanho:='P'
   
   WnRel := SetPrint( cString, WnRel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F. , "", .T., Tamanho, "", .F. )         
   
   SetDefault( aReturn, cString )
   RptStatus({||_fImprime()},Titulo)
else
   msgbox("Nao foram encontradas duplicacoes na chave informada")   
endif   
Return

*----------------------------------------------------------------------------------
static Function _fImprime
*----------------------------------------------------------------------------------
local _nVez
li:=1
SetRegua(len(_vDuplic))
for _nVez:=1 to len(_vDuplic)
    incregua()
    @ li++,02 PSAY _vDuplic[_nVez]
next

if aReturn[5]=1
   Set Device To Screen
   Set Printer To
   dbCommitAll()
   OurSpool( WnRel )
endif   

return

*-----------------------------------------------------------------------------*
user Function _fValAcols(_nItem,_cCampo)
* Retorna o valor atual de um campo em edicao no acols
*-----------------------------------------------------------------------------*
local _xValor,_nPosic
_cCampo:=alltrim(upper(_cCampo))
// Verifica se nao é ele mesmo que está sendo digitado no momento
if _cCampo$upper(readvar()).and.N==_nItem
   _xValor:=readVar()
   _xValor:=&(_xValor)
else   
   _nPosic:=aScan(aHeader,{|x|Alltrim(upper(x[2])) == alltrim(upper(_cCampo))})
   if _nPosic==0
      msgbox("u__fValAcols: Campo "+_cCampo+" nao localizado no acols atual")
   else
     _xValor  := aCols[_nItem,_nPosic]
   endif
endif

return _xValor

*------------------------------------------------------------------------------
User function _fAtuSx1(cPerg,aRegs)
*------------------------------------------------------------------------------
local _nOrdSx1:=sx1->(indexord()),;
      _nRecSx1:=sx1->(recno()),_nVez,_lApaga:=.f.,_nPergs:=0

sx1->(dbsetorder(1))
// Verifica se o formato solicitado ainda e o mesmo, caso contrario,
// apaga e inclui tudo novamente
For _nVez:=1 to Len(aRegs)
  If sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
     _nPergs++
     if alltrim(sx1->x1_pergunt)<>alltrim(aRegs[_nVez,3])
        if len(aRegs[_nVez,3])>len(sx1->x1_pergunt)
           msgbox("Atencao, a pergunta: ["+alltrim(aRegs[_nVez,3])+"] nao cabe no campo X1_PERGUNT")
        endif   
        _lApaga:=.t.
        exit
     endif   
  endif   
next
if _nPergs<>len(aRegs).or._lApaga          
   sx1->(DbSeek(cPerg,.f.))
   do while sx1->(!eof().and.alltrim(x1_grupo)==alltrim(aRegs[1,1]))
      if sx1->(reclock(alias(),.f.))
         sx1->(dbdelete())
         sx1->(msunlock())
      endif
      sx1->(dbskip(1))
   enddo
endif

For _nVez:=1 to Len(aRegs)
  If !sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
    sx1->(RecLock(alias(),.T.))
    sx1->X1_GRUPO  :=aRegs[_nVez,01]
    sx1->X1_ORDEM  :=aRegs[_nVez,02]
    sx1->X1_PERGUNT:=aRegs[_nVez,03]
    
    sx1->X1_PERSPA:=aRegs[_nVez,03]
    sx1->X1_PERENG:=aRegs[_nVez,03]
    
    sx1->X1_VARIAVL:=aRegs[_nVez,04]
    sx1->X1_TIPO   :=aRegs[_nVez,05]
    sx1->X1_TAMANHO:=aRegs[_nVez,06]
    sx1->X1_DECIMAL:=aRegs[_nVez,07]
    sx1->X1_PRESEL :=aRegs[_nVez,08]
    sx1->X1_GSC    :=aRegs[_nVez,09]
    sx1->X1_VALID  :=aRegs[_nVez,10]
    sx1->X1_VAR01  :=aRegs[_nVez,11]
    sx1->X1_DEF01  :=aRegs[_nVez,12]

    sx1->X1_DEFSPA1  :=aRegs[_nVez,12]
    sx1->X1_DEFENG1  :=aRegs[_nVez,12]
    
    sx1->X1_CNT01  :=aRegs[_nVez,13]
    sx1->X1_VAR02  :=aRegs[_nVez,14]
    sx1->X1_DEF02  :=aRegs[_nVez,15]

    sx1->X1_DEFSPA2  :=aRegs[_nVez,15]
    sx1->X1_DEFENG2  :=aRegs[_nVez,15]

    sx1->X1_CNT02  :=aRegs[_nVez,16]
    sx1->X1_VAR03  :=aRegs[_nVez,17]
    sx1->X1_DEF03  :=aRegs[_nVez,18]

    sx1->X1_DEFSPA3  :=aRegs[_nVez,18]
    sx1->X1_DEFENG3  :=aRegs[_nVez,18]

    sx1->X1_CNT03  :=aRegs[_nVez,19]
    sx1->X1_VAR04  :=aRegs[_nVez,20]
    sx1->X1_DEF04  :=aRegs[_nVez,21]

    sx1->X1_DEFSPA4  :=aRegs[_nVez,21]
    sx1->X1_DEFENG4  :=aRegs[_nVez,21]

    sx1->X1_CNT04  :=aRegs[_nVez,22]
    sx1->X1_VAR05  :=aRegs[_nVez,23]
    sx1->X1_DEF05  :=aRegs[_nVez,24]

    sx1->X1_DEFSPA5  :=aRegs[_nVez,24]
    sx1->X1_DEFENG5  :=aRegs[_nVez,24]

    sx1->X1_CNT05  :=aRegs[_nVez,25]
    sx1->X1_F3     :=aRegs[_nVez,26]
    if len(aRegs[_nVez])>26
       sx1->x1_picture:=aRegs[_nVez,27]
    endif
    sx1->(MsUnlock())
  Endif
Next
sx1->(dbgoto(_nRecSx1))
sx1->(dbsetorder(_nOrdSx1))
Return

*--------------------------------------------------------------
user function _fCalcEst(_cProd,_cLocal,_dDt)
*--------------------------------------------------------------
local _vSaldo
_nRecD1:=sd1->(recno())
_nRecD2:=sd2->(recno())
_nRecD3:=sd3->(recno())         
_nRecB1:=sb1->(recno())         
_nRecB9:=sb9->(recno())         
_nOrdD1:=sd1->(indexord())
_nOrdD2:=sd2->(indexord())         
_nOrdD3:=sd3->(indexord())         
_nOrdB1:=sb1->(indexord())
_nOrdB9:=sb9->(indexord())
_vSaldo:=calcest(_cProd,_cLocal,_dDt)
sd1->(dbsetorder(_nOrdD1))
sd1->(dbgoto(_nRecD1))
sd2->(dbsetorder(_nOrdD2))
sd2->(dbgoto(_nRecD2))
sd3->(dbsetorder(_nOrdD3))
sd3->(dbgoto(_nRecD3))
sb1->(dbsetorder(_nOrdB1))  
sb1->(dbgoto(_nRecB1))
sb9->(dbsetorder(_nOrdB9))  
sb9->(dbgoto(_nRecB9))
return _vSaldo

*-----------------------------------------------------
user function _fDbCount(_cForCond)
*-----------------------------------------------------
local _nRec:=recno()
private _nCount:=0
_cComando:="DBEVAL( {||_nCount++},{||"+_cForCond+"})"
_x:=&_cComando
dbgoto(_nRec)
return _nCount

*------------------------------------------------------------------------------------------------------------------
user function _fEmptyLin(_cAlias,_vHeader)
* Retorna um vetor com valores em branco, correspondente a linha do acols
*------------------------------------------------------------------------------------------------------------------
local _nVez,_vLin:={},_cTipo,_xConteudo
for _nVez:=1 to len(_vHeader)
    if posicione("SX3",2,_vHeader[_nVez][2],"x3_context")=="V"
       _xConteudo:=criavar(_vHeader[_nVez][2])
       if valtype(_xConteudo)=="D"
          _xConteudo:=dtoc(_xConteudo)
       elseif valtype(_xConteudo)=="N"
          _xConteudo:=alltrim(str(_xConteudo))
       endif
       _xConteudo:="'"+_xConteudo+"'"
    else
       _xConteudo:=_cAlias+"->("+_vHeader[_nVez][2]+")"
    endif
   
    _xConteudo:=&(_xConteudo)
   
    _cTipo:=valtype(_xConteudo)
    _xConteudo:=if(_cTipo$"CM",space(len(_xConteudo)),if(_cTipo=="D",ctod(''),if(_cTipo=="N",0,'')))

    aadd(_vLin,_xConteudo)
next                      
aadd(_vLin,.f.)
return _vLin
*------------------------------------------------------------------------------------------------------------------
user function _fMesLit(_nMes)
* Retorna um string contendo o nome do mes ou em branco se invalido
*------------------------------------------------------------------------------------------------------------------
local _cMes,_vMeses:={"janeiro","fevereiro","marco",;
      "abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro"}
if _nMes==nil.or._nMes<1.or._nMes>12
   _cMes:=""
else        
   _cMes:=_vMeses[_nMes]
endif   
return _cMes

*------------------------------------------------------------------------------------------------------------------
user function _fHelice()
* Retorna um string contendo uma das posicoes da helice
*------------------------------------------------------------------------------------------------------------------
local _vHelice:={"-","\","|","/","-","\","|","/"}         
static _nPosic
if _nPosic==nil.or._nPosic==len(_vHelice) 
   _nPosic:=1
else
   _nPosic++
endif   
return _vHelice[_nPosic]

*----------------------------------------------------------------------------------------
static function _fTestaCond()
* Testa a condicao de pagamento e exibe resultado
*----------------------------------------------------------------------------------------
private _cCond:=se4->e4_codigo,_dDataIni:=ddatabase,_nValor:=100
@ 000,000 To 160,280 Dialog oDlg1 Title "Condicoes de pagamento" 

@ 010,015 Say u__fAjTxt("Data de referencia:")
@ 010,075 Get _dDataIni size 55,10

@ 025,015 Say u__fAjTxt("Valor total:")
@ 025,075 Get _nValor pict "@er 999,999.99" size 55,10

@ 040,015 Say u__fAjTxt("Condicao:")
@ 040,075 Get _cCond valid !empty(_cCond) f3 "SE4" size 55,10

@ 055,100 bmpButton type 1 Action _fTestA()
@ 055,040 BmpButton Type 2 action Close(oDlg1)
Activate Dialog oDlg1 Centered
return                                                                                   

*----------------------------------------------------------------------------------------
static function _fTestA()
*----------------------------------------------------------------------------------------
local _nVez,_vDiasA:={'D','L','S','Q','F','Z'},;
      _vDiasB:={'Data do Dia','Fora o Dia','Fora Semana','Fora quinzena',;
                'Fora Mes','Fora Dezena'},;
                _vCondLit:={}

if empty(_cCond).or.empty(_nValor).or.empty(_dDataIni).or.;
  !se4->(dbseek(xfilial()+_cCond,.f.))
   msgbox("Desculpe, mas estou sem condicoes de testar essa condicao...")
   return
endif   
_vCondicao:=condicao(_nValor,_cCond,0,_dDataIni)           

for _nVez:=1 to len(_vCondicao)
    aadd(_vCondLit,"Parcela   "+alltrim(str(_nVez))+if(_nVez<10,":       ",":      ")+;
           dtoc(_vCondicao[_nVez][1])+"    "+tran(_vCondicao[_nVez][2],"@er 999,999,999.99"))
next
_cDias:=se4->e4_ddd  
if (_nVez:=ascan(_vDiasA,_cDias))>0
   _cDias:=alltrim(_cDias)+'    ('+_vDiasB[_nVez]+')'
endif
_nVez:=len(_vCondLit)  
@ 000,000 TO 235,515 DIALOG oDlg2 TITLE "Resultado "
@ 010,010 say u__fAjTxt("Condicao: ")
@ 010,060 say u__fAjTxt(se4->e4_codigo)
@ 020,010 say u__fAjTxt("Tipo: ")
@ 020,060 say u__fAjTxt(se4->e4_tipo)
@ 030,010 say u__fAjTxt("Parametro COND: ")
@ 030,060 say u__fAjTxt(alltrim(se4->e4_cond))
@ 040,010 say u__fAjTxt("Descricao: ")
@ 040,060 say u__fAjTxt(alltrim(se4->e4_descri))
@ 050,010 say u__fAjTxt("Parametro Dias: ")
@ 050,060 say u__fAjTxt(_cDias)
@ 060,010 say u__fAjTxt("Data de referencia: ")
@ 060,060 say u__fAjTxt(dtoc(_dDataIni))
@ 070,010 say "Valor a parcelar: "
@ 070,060 say u__fAjTxt(alltrim(tran(_nValor,"@er 999,999,999.99")))
@ 010,140 LISTBOX _nVez ITEMS _vCondLit SIZE 115,80
@ 095,225 BUTTON "_Ok" SIZE 30,15 ACTION Close(oDlg2)             
ACTIVATE DIALOG oDlg2 CENTER
Return                                     

*----------------------------------------------------------------------------------
static function _fGeraB2()  
*----------------------------------------------------------------------------------
_cPerg2  :="GeraB2"
@ 000,000 TO 150,350 DIALOG oDlg3 TITLE " Gerar saldos em SB2 "
@ 010,015 say u__fajtxt(" Esse programa atribui saldos ") 
@ 025,015 say u__fajtxt(" em quantidade para o SB2 ")
@ 050,020 BMPBUTTON type 1  ACTION msaguarde({||_fGeraB2a()},"Gerando Saldos") 
@ 050,060 BMPBUTTON type 5  ACTION _fGeraB2b()  // verifica Parametros
@ 050,100 BMPBUTTON type 2  ACTION Close(oDlg3) 
ACTIVATE DIALOG oDlg3 CENTER  

*----------------------------------------------------------------------------------
Static Function _fGeraB2b()
*----------------------------------------------------------------------------------
   ssAlias  := Alias()
   aRegs := {}   //cria vetor em branco
   dbSelectArea("SX1")
   dbSetOrder(1)
             *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
             *+---------------------------------------------------------------------------------------------------------------------------------+
             *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
             *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
             *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
             *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
             *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
   AADD(aRegs,{_cPerg2,"01","Almoxarifado       ?","mv_ch1","C",02,0,0,"G","","mv_par01",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"02","Produto De         :","mv_ch2","C",15,0,0,"G","","mv_par02",""  ,"","",""      ,"","","","","","","","","","","SB1"})
   AADD(aRegs,{_cPerg2,"03","Produto Ate        :","mv_ch3","C",15,0,0,"G","","mv_par03",""  ,"","",""      ,"","","","","","","","","","","SB1"})
   AADD(aRegs,{_cPerg2,"04","Qtde p/ B2_QATU    :","mv_ch4","N",12,2,0,"G","","mv_par04",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"05","Ja Existentes      :","mv_ch5","N",01,0,0,"C","","mv_par05","Sobrepoe"  ,"","","Ignora"      ,"","","","","","","","","","",""})
   
   u__fAtuSx1(padr(_cPerg2,len(sx1->x1_grupo)),aRegs)   
   pergunte(_cperg2,.t.)
Return       

*----------------------------------------------------------------------------------
Static Function _fGeraB2a
*----------------------------------------------------------------------------------

pergunte(_cperg2,.f.)
_clocal   := Mv_Par01
_cProdIni := Mv_Par02
_cProdFim := Mv_Par03
_nQAtu    := Mv_Par04                                       
_nExist   := Mv_Par05

if empty (_clocal) // se almoxarifado nao foi informado
          msgbox("O almoxarifado deve ser informado!")
          return  // volta para quem chamou a funcao ou procedure
endif                                

SB1->(dbsetorder(1)) //_filial+_cod
SB2->(dbsetorder(1)) //_filial+_cod+_local
SB1->(dbseek(Xfilial()+alltrim(_cProdIni),.t.)) //se Sx2 for c=compartilhado , retorna branco 2pos. , senao retorna cod. da filial atual
While SB1->(!eof().and.Xfilial()==B1_Filial.and.B1_cod<=_cProdFim)
          _lTemB2:=SB2->(dbseek(Xfilial()+SB1->B1_Cod+_clocal,.f.))
          if !_lTemB2 .or. _nExist<>2 .or. (_nExist==2 .and. SB2->B2_Qatu==0)
                    SB2->(reclock("SB2",!_lTemB2))
                    SB2->B2_FILIAL:=XFILIAL("SB2")
                    SB2->B2_LOCAL:=_cLocal
                    SB2->B2_COD:=SB1->B1_COD 
                    SB2->B2_QATU:=_nQatu
                    SB2->(msunlock()) 
                    msproctxt("Gerando saldo do produto "+SB1->B1_COD)
          endif     
          SB1->(dbskip())
enddo
return

*-----------------------------------------------------------------------------------
static function _fGeraB9()  
*-----------------------------------------------------------------------------------
_cPerg2  :="GeraB9"
@ 000,000 TO 150,350 DIALOG oDlg3 TITLE " Gerar saldos em SB9 "
@ 010,015 say u__fajtxt(" Esse programa atribui saldos ") 
@ 025,015 say u__fajtxt(" em quantidade para o SB9 ")
@ 050,020 BMPBUTTON type 1  ACTION msaguarde({||_fGeraB9a()},"Gerando Saldos") 
@ 050,060 BMPBUTTON type 5  ACTION _fGeraB9b()  // Parametros
@ 050,100 BMPBUTTON type 2  ACTION Close(oDlg3) 
ACTIVATE DIALOG oDlg3 CENTER  

Static Function _fGeraB9b()
   ssAlias  := Alias()
   _cPerg2       := PADR(_cPerg2,len(sx1->x1_grupo)) //acrescenta espacos em branco do lado direito de acordo com o tamanho do campo X1_grupo
   aRegs := {}   //cria vetor em branco
   dbSelectArea("SX1")
   dbSetOrder(1)
             *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
             *+---------------------------------------------------------------------------------------------------------------------------------+
             *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
             *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
             *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
             *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
             *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
   AADD(aRegs,{_cPerg2,"01","Almoxarifado       ?","mv_ch1","C",02,0,0,"G","","mv_par01",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"02","Produto De         :","mv_ch2","C",15,0,0,"G","","mv_par02",""  ,"","",""      ,"","","","","","","","","","","SB1"})
   AADD(aRegs,{_cPerg2,"03","Produto Ate        :","mv_ch3","C",15,0,0,"G","","mv_par03",""  ,"","",""      ,"","","","","","","","","","","SB1"})
   AADD(aRegs,{_cPerg2,"04","Qtde p/ B2_QINI    :","mv_ch4","N",12,2,0,"G","","mv_par04",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"05","Data p/ B9_DATA    :","mv_ch5","D",08,2,0,"G","","mv_par05",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"06","Ja Existentes      :","mv_ch6","N",01,0,0,"C","","mv_par06","Sobrepoe"  ,"","","Ignora"      ,"","","","","","","","","","",""})
   u__fAtuSx1(padr(_cPerg2,len(sx1->x1_grupo)),aRegs)   
   DbSelectArea(ssAlias)
   pergunte(_cperg2,.t.)
Return       

*----------------------------------------------------------------------------------
Static Function _fGeraB9a
*----------------------------------------------------------------------------------

pergunte(_cperg2,.f.)
_clocal   := Mv_Par01
_cProdIni := Mv_Par02
_cProdFim := Mv_Par03
_nQini    := Mv_Par04
_dData    := mv_par05
_nExist   := Mv_Par06

if empty (_clocal) // se almoxarifado nao foi informado
          msgbox("O almoxarifado deve ser informado!")
          return  // volta para quem chamou a funcao ou procedure
endif                                

SB1->(dbsetorder(1)) //_filial+_cod
SB9->(dbsetorder(1)) //_filial+_cod+_local+DTOS(B9_DATA)
SB1->(dbseek(Xfilial()+alltrim(_cProdIni),.t.)) 
While SB1->(!eof().and.Xfilial()==B1_Filial.and.B1_cod<=_cProdFim)
          _lTemB9:=SB9->(dbseek(Xfilial()+SB1->B1_Cod+_clocal+dtos(_dData),.f.))
          if !_lTemB9 .or. _nExist<>2 .or. (_nExist==2 .and. SB9->B9_Qini==0)
                    SB9->(reclock("SB9",!_lTemB9))
                    SB9->B9_FILIAL:=XFILIAL("SB9")
                    SB9->B9_LOCAL:=_cLocal
                    SB9->B9_COD:=SB1->B1_COD 
                    SB9->B9_QINI:=_nQini
                    SB9->B9_data:=_dData
                    SB9->(msunlock()) 
                    msproctxt("Gerando saldo do produto "+SB1->B1_COD)
          endif     
          SB1->(dbskip())
enddo
return

*-------------------------------------------
Static function _fUsDet1()
*-------------------------------------------
local _nVez,_nVezMen
setDefault(aReturn,cString)      
setprc(0,0)
setregua(1)
incregua()
_vUsers:=allusers(.t.)
setregua(len(_vUsers)*len(_vUsers[1][3])) 
_nLin:=99
for _nVez:=1 to len(_vUsers)
   incregua()
   @ ++_nLin,0 PSAY _vUsers[_nVez][1][4]+" "
   if _nLin>60
      Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
      _nLin:=li+1
   endif

   _nCol:=pcol()
   for _nVezMen:=1 to len(_vUsers[_nVez][3])
       incregua()
       _cMenu:=_vUsers[_nVez][3][_nVezMen]
       if !(substr(_cMenu,3,1)$"xX")
          if _nLin>60
              Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
              _nLin:=li+1
          endif
          @ _nLin++,_nCol PSAY _cMenu
       endif
   next
next

Set Filter To
If aReturn[5] == 1
   Set Printer To
   Commit
   ourspool(wnrel) 
Endif
MS_FLUSH()     
Return

*--------------------------------------------------------------------------------------------------
User Function fModelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,;
                       nLinhas,aAltEnchoice,nFreeze,aCoordTot,aCoordSup,aCoordInf,_cItemIncr,_vCpoMem)
* Modelo 3 com possibilidade de passar as coordenadas como parametro (opcional)
*--------------------------------------------------------------------------------------------------
Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno()),oDlg,_nVez,oGetDados

if aCoordTot==nil
   aCoordTot:={9,0,28,80}
endif
if aCoordInf==nil
   aCoordInf:={75,1,143,315}
endif   
if aCoordSup==nil
   aCoordSup:={15,1,70,315}
endif
if _cItemIncr==nil
   _cItemIncr:=""
endif   
//Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,
private aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

DEFINE MSDIALOG oDlg TITLE cTitulo From aCoordTot[1],aCoordTot[2] to aCoordTot[3],aCoordTot[4] of oMainWnd
EnChoice(cAlias1,nReg,nOpcE,,,,aMyEncho,aCoordSup,aAltEnchoice,3,,,,,,lVirtual)                                             
//nfreeze:="C"

oGetDados := MsGetDados():New(aCoordInf[1],aCoordInf[2],aCoordInf[3],aCoordInf[4],nOpcG,cLinOk,cTudoOk,_cItemIncr,.T.,,nFreeze,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg centered ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()})

if _vCpoMem<>nil
   for _nVez:=1 to len(_vCpoMem)
       aadd(_vCpoMem[_nVez],&("m->"+_vCpoMem[_nVez][1]))
   next
endif
lRet:=(nOpca==1)
Return lRet

*---------------------------------------------------------------------------
user Function RSAguarde(bAction,_cTitle)
*---------------------------------------------------------------------------
Local oDlg, oTimer,_cTexto:=""
LEND:=.F.
private _cText1:=_cText2:=_cText3:=_cText4:=_cText5:=padr(" ",100),;//space(100),;
	        _oText1,_oText2,_oText3,_oText4,_oText5,_oTela,_oMeter
/*
<oDlg> = TDialog():New( <nTop>, <nLeft>, <nBottom>, <nRight>,;
                 <cTitle>, <cResName>, <hResources>, <.vbx.>, <nStyle>,;
                 <nClrText>, <nClrBack>, <oBrush>, <oWnd>, <.pixel.>,;
                 <oIco>, <oFont>, <nHelpId>, <nWidth>, <nHeight> )

lEnd:=.f.
@ 00, 00 to 150, 445 DIALOG _oTela  TITLE _cTitle 
@ 1000,0 say _cTitle object _oTitle
@ 10, 08  GET _cText1 when .f. object _oText1
@ 20, 08  SAY _cText2 object _oText2
@ 30, 08  SAY _cText3 object _oText3
@ 40, 08  SAY _cText4 object _oText4
@ 50, 08  SAY _cText5 object _oText5
_oTela:bStart = { || Eval( bAction,@lEnd),lEnd :=.t.,_oTela:End()}

[ <oSay> := ] TSay():New( <nRow>, <nCol>, <{cText}>,;
        [<oWnd>], [<cPict>], <oFont>, <.lCenter.>, <.lRight.>, <.lBorder.>,;
        <.lPixel.>, <nClrText>, <nClrBack>, <nWidth>, <nHeight>,;
        <.design.>, <.update.>, <.lShaded.>, <.lBox.>, <.lRaised.> )

	
ACTIVATE DIALOG _oTela centered //valid .f.

*/
	
_oTela:=TDialog():new(0,0,150,445,_cTitle,,,,,,,,_oWnd:=nil,_lPixel:=.t.)

_oText1:=TSay():New(10,08,{||_cText1},_oTela,,,,,,_lPixel:=.t.)
_oText2:=TSay():New(20,08,{||_cText2},_oTela,,,,,,_lPixel:=.t.)
_oText3:=TSay():New(30,08,{||_cText3},_oTela,,,,,,_lPixel:=.t.)
_oText4:=TSay():New(40,08,{||_cText4},_oTela,,,,,,_lPixel:=.t.)
_oText5:=TSay():New(50,08,{||_cText5},_oTela,,,,,,_lPixel:=.t.)

_oMeter:=TMeter():New( 62, 08, {||0},;
 20,_oTela,nWidth:=205, nHeight:=10,_lupdate:=.t., ;
 _lPixel:=.t.,, _cPrompt:="Prompt",lNoPercentage:=.t.)

_oTela:bStart = { ||cursorwait(),Eval(bAction,@lEnd),lEnd :=.t.,cursorarrow(),_oTela:End()}

_oTela:Activate(,,,_lcenter:=.t.)

Return nil

*---------------------------------------------------------------------------
user function RsProcTxt(_cTexto)
*---------------------------------------------------------------------------
local _nLarg:=80,_cQuebra:=chr(10),_vTexto:={},_cLinha,_nPosic,_nVez

static _nOndeta,_nIncremen
lend:=.f.
if _nOndeta==nil
   _nOndeta:=0
   _nIncremen:=1
endif   
if _nOndeta>20
   _nIncremen:=-1
endif
if _nOndeta<1
   _nIncremen:=1
endif      
_nOndeta+=_nIncremen
_oMeter:Set(_nOndeta)     

//_oTitle:SetText(_oTitle:ccaption+".")
if _cTexto==nil
   _cTexto:=""
endif

_cTexto:=alltrim(_cTexto)
_cTexto:=strtran(_cTexto,chr(13),chr(10))
_cTexto:=strtran(_cTexto,chr(10)+chr(10),chr(10))

do while (_nPosic:=at(chr(10),_cTexto))>0
   _cLinha:=left(_cTexto,_nPosic-1)
   if len(alltrim(_cLinha))>0
      for _nVez:=1 to mlcount(_cLinha,_nLarg)
          aadd(_vTexto,memoline(_cLinha,_nLarg,_nVez))
      next
   endif
   _cTexto:=substr(_cTexto,_nPosic+1)
enddo
// Adiciona a ultima linha
_cTexto:=alltrim(_cTexto)
if len(alltrim(_cTexto))>0
   for _nVez:=1 to mlcount(_cTexto,_nLarg)
       aadd(_vTexto,memoline(_cTexto,_nLarg,_nVez))
   next
endif

   for _nVez:=len(_vTexto) to 5
       aadd(_vTexto,"")
   next

//_oText1:cCaption:=_vTexto[1]
_cText1:=_oText1:cCaption:=_vTexto[1]
_cText2:=_oText2:cCaption:=_vTexto[2]
_cText3:=_oText3:cCaption:=_vTexto[3]
_cText4:=_oText4:cCaption:=_vTexto[4]
_cText5:=_oText5:cCaption:=_vTexto[5]
//_oText1:SetText(_vTexto[1])

//_oText1:lModified:=.t.

//_oTela:bStart = { || }

//_oTela:refresh()
//_oTela:bStart = { || Eval( bAction,@lEnd),lEnd :=.t.,_oTela:End()}

//_oTela:refresh(.t.)
//_oTela:refresh(.f.)
//_oTela:setfocus()
//_oTela:paint()
//_oTela:update()
//SysRefresh()

//bBlock:={|| _oText1:Settext(_vTexto[1]), SysRefresh(), !lEnd}
//EVAL(bBlock)

return nil

*---------------------------------------------------------------------------
user function _fPExcel()
* Retorna o caminho do excel instalado na estacao do usuario
*---------------------------------------------------------------------------
local _cTabPath:="P8",; // Tabela Path Excel por usuario   
      _nOrdSx5:=sx5->(indexord()),_nRecSx5:=sx5->(indexord()),_cReturn:="",;
      _cConteudo,_nVez,_nAbre:=_nFecha:=0
sx5->(dbsetorder(1)) // x5_filial+x5_tabela+x5_chave          
sx5->(dbseek(xfilial()+_cTabPath,.f.))
do while sx5->(!eof().and.x5_filial+x5_tabela==xfilial()+_cTabPath)
   if lower("["+alltrim(substr(cusuario,7,15))+"]")$lower(sx5->x5_descri).or.;
      "[administrador]"$lower(sx5->x5_descri)
      _cConteudo:=sx5->(alltrim(x5_descri)+alltrim(x5_desceng))
      _cReturn:=''
      for _nVez:=1 to len(_cConteudo)
          _cByte:=substr(_cConteudo,_nVez,1)
          if _cByte=='['
             _nAbre:=_nAbre+1
          elseif _cByte==']'
             _nFecha:=_nFecha+1
          else
             if _nAbre==2.and._nFecha==1
                _cReturn+=_cByte
             endif
          endif
      next
      _cReturn:=alltrim(_cReturn)
      _cReturn+=if(right(_cReturn,1)=="\","","\")
      if lower("["+alltrim(substr(cusuario,7,15))+"]")$lower(sx5->x5_descri)
         exit
      endif   
   endif
   sx5->(dbskip(1))
enddo
sx5->(dbgoto(_nRecSx5))
sx5->(dbsetorder(_nOrdSx5))        

return _cReturn

*-------------------------------------------------------------------
user Function _fDatUser(_nOrdem,_cKey)
* Na ordem 1, procure pelo codigo (u__fDatUser(1,"000010")
* Na ordem 2, 
*-------------------------------------------------------------------
local _vArea:=getarea(),_vDatUser

PswOrder(_nOrdem)
PswSeek(_cKey)
_vDatuser:= PswRet(1)
restarea(_vArea)
Return _vDatUser

*-------------------------------------------------------------------------------
static Function _fInvUser()
* Inventario dos usuarios / modulos do sistema
* Ricardo Luiz da Rocha - 06/03/2003
*-------------------------------------------------------------------------------
msaguarde({||_fInvUserA()},"Colhendo dados dos usuarios...")
static function _fInvUserA()
local _vDatUser,_cUser:="000000",_nCont:=0,_vStruct:={},_cNome:="INVUSER",_nVez,;
      _vModulo:={} ,_cModulo,_nPosic,_cMenu
aadd(_vStruct,{"Codigo","C",06,0})
aadd(_vStruct,{"Nome_red", "C",15,0})  
aadd(_vStruct,{"Nome_compl", "C",30,0})
aadd(_vStruct,{"Modulo", "C",10,0})  
aadd(_vStruct,{"Menu",   "C",30,0})
aadd(_vStruct,{"Dir_Rel", "C",30,0})    
aadd(_vStruct,{"Emp_Fil", "C",200,0})    
dbcreate(_cNome,_vStruct)
dbusearea(.t.,,_cNome,"InvUser",.t.,.f.)
PswOrder(1)
do while _nCont<200
   PswSeek(_cUser) 
   _vDatuser:= PswRet()
   
   if _cUser=="000000" // Administrador
      // Colher os nomes e codigos dos modulos
      for _nVez:=1 to len(_vDatUser[3])
          _cModulo:=alltrim(_vDatUser[3][_nVez])
          _cModulo:=substr(_cModulo,rat("\",_cModulo)+1)
          _cModulo:=left(_cModulo,at(".",_cModulo)-1)
          aadd(_vModulo,{left(alltrim(_vDatUser[3][_nVez]),2),_cModulo})
      next    
   endif   
   
   if len(_vDatUser)>1
      msproctxt(_vDatUser[1][4])
      // Acumula em _cEmpFil as empresas e filiais onde o usuario tem acesso
      _cEmpFil:=""
      for _nVez:=1 to len(_vDatUser[2][6])
          _cEmpFil+=left(_vDatUser[2][6][_nVez],2)+"/"+Substr(_vDatUser[2][6][_nVez],3,2)+" "
      next      
      
      for _nVez:=1 to len(_vDatUser[3])
          if substr(_vDatUser[3][_nVez],3,1)$"xX"
          else
            if (_nPosic:=ascan(_vModulo,{|_vAux|_vAux[1]==left(_vDatUser[3][_nVez],2)}))>0
               _cModulo:=_vModulo[_nPosic][2]
            else
               _cModulo:="Nao localizado"
            endif
            InvUser->(Reclock(alias(),.t.))
            InvUser->Codigo    :=_cUser
            InvUser->Nome_Red  :=_vDatUser[1][2]
            InvUser->Nome_Compl:=_vDatUser[1][4]
            InvUser->Modulo    :=_cModulo
            _cMenu:=alltrim(_vDatUser[3][_nVez])
            _cMenu:=alltrim(substr(_cMenu,rat("\",_cMenu)+1))
            InvUser->Menu      :=_cMenu
            InvUser->Dir_Rel   :=_vDatUser[2][3]
            InvUser->Emp_Fil   :=_cEmpFil
            InvUser->(msunlock())
         endif   
      next
   else
      _nCont++
   endif   
   _cUser:=soma1(_cUser)
enddo
InvUser->(dbclosearea())
PswSeek(__cUserId)
msgbox("Concluido, resultados no STARTPATH (default = \Sigaadv\), INVUSER.DBF") 
Return 

*---------------------------------------------------------------------
user function _fVldHora(_cHora)
*----------------------------------------------------------------------
local _lReturn:=.f.
private _cSoHora:=strzero(val(substr(_cHora,1,2)),2),;
        _cSoMin:=strzero(val(substr(_cHora,4,2)),2),_cReturn:=""
if alltrim(_cHora)==":"
   _lReturn:=.t.
elseif _cSoHora>="00".and._cSoHora<="24".and.;
   _cSoMin >="00".and._cSoMin <="59".and.;
    (_cSoHora+":"+_cSomin)<"24:00"
   _cHora:=_cSoHora+":"+_cSomin
   _lReturn:=.t.
else   
   msgbox("Horario invalido: "+_cSoHora+":"+_cSomin)
endif   
return _lReturn
*---------------------------------------------------------------------
user function _fVldFHora(_cHora)
* Valida apenas se a formatacao estiver correta (bom para validar SX1)
*----------------------------------------------------------------------
local _lReturn:=.f.
private _cSoHora:=strzero(val(substr(_cHora,1,2)),2),;
        _cSoMin:=strzero(val(substr(_cHora,4,2)),2),_cReturn:=""
if _cHora=="  :  "
   _lReturn:=.t.
elseif substr(_cHora,1,1)$"012".and.substr(_cHora,2,1)$"0123456789".and.;
      substr(_cHora,3,1)==":".and.substr(_cHora,4,1)$"012345".and.;
      substr(_cHora,5,1)$"0123456789"
   _lReturn:=.t.
endif      
if _lReturn.and._cSoHora>="00".and._cSoHora<="24".and.;
   _cSoMin >="00".and._cSoMin <="59".and.;
    (_cSoHora+":"+_cSomin)<"24:00"
   _cHora:=_cSoHora+":"+_cSomin
   _lReturn:=.t.
else   
   msgbox("Horario invalido: "+_cSoHora+":"+_cSomin)
endif   
return _lReturn

*--------------------------------------------------------------------
user function fCallStack()
* Retorna um vetor com a pilha de chamadas
*--------------------------------------------------------------------
local _nVez:=1,_cNome,_vReturn:={}
do while !empty(_cNome:=Procname(_nVez++))
   aadd(_vReturn,_cNome)
enddo
return _vReturn   
*----------------------------------------------------------------------------
user function fX3Cbox(_cCampo,_cValor)
* Retorna a descricao correspondente de um valor para o combobox padrao
*----------------------------------------------------------------------------
local _vAmbSx3	:= sx3->(getarea())
local _cReturn :=""
local _vComboCont:={}
local _cComboCont:=""
local _nVez
local _cAdic	:= _cReturn 
Local _nPosic:=0

_cCampo:=sx3->(padr(alltrim(upper(_cCampo)),len(x3_campo)))
sx3->(dbsetorder(2))
if sx3->(dbseek(_cCampo,.f.))
   _cComboCont:=alltrim(sx3->x3_cBox)
   for _nVez:=1 to len(_cComboCont)
       if substr(_cComboCont,_nVez,1)==";".or._nVez==len(_cComboCont)
          _cAdic+=substr(_cComboCont,_nVez,1)
          if !empty(_cAdic)
             aadd(_vComboCont,_cAdic)
             _cAdic:=""
          endif
       else
         _cAdic+=substr(_cComboCont,_nVez,1)
       endif
   next
   if (_nPosic:=ascan(_vComboCont,_cValor+"="))>0
      _cReturn:=substr(_vComboCont[_nPosic],at("=",_vComboCont[_nPosic])+1)
   endif
endif
if right(_cReturn,1)==";"
   _cReturn:=left(_cReturn,len(_cReturn)-1)
endif   
sx3->(restarea(_vAmbSx3))
return _cReturn

*-------------------------------------------------------------------------------------------------------------------------
User Function fModelo2(cTitulo,aC,aR,aCGD,nOpcx,cLineOk,cAllOk,aGetsGD,bF4,cIniCpos,nMax,aCordW,lDelGetD,aButtons,cDelOk)
*  Parametros   cTitulo=Titulo da Janela
*  			    aC=Array com campos do cabecalho
*  			    aR=Array com campos do rodape
*			    aCGD=Array com coordenadas da GetDados
*			    nOpcx=Modo de operacao
*			    cLineOk=Validacao de linha da GetDados
*			    cAllOkk=Validacao de toda GetDados
*			    aGetsD=Array com gets editaveis
*			    bF4=bloco de codigo para tecla F4
*			    cIniCpos=string com nome dos campos que devem ser inicializados ao teclar seta para baixo.
*			    lDelGetD=determina se as linhas da Getdados podem ser deletadas ou nao.
*			    aButtons=Array com botoes para EnchoiceBar
*			    cDelOk  =Funcao ou expressao para verificar se a linha
*			    pode ser marcada para exclusao
*-------------------------------------------------------------------------------------------------------------------------

Local   nOpca:=0, i,lAllOk,;
oDlg, cCampo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay, nLargGet, uConteudo, oSay, oGet
Local   cBlkGet,cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
Private nCOunt := 0
if clineok==nil
   cLineOk := "AllwaysTrue()"
endif
if cAllOk==nil   
   cAllOk  := "AllwaysTrue()"
endif
if nOpcx==nil   
   nOpcx	:= 3
endif
if aCGD==nil   
   aCGD	:= {}
endif
if lDelGetD==nil   
   lDelGetD := .T.
endif   

nOpcX := Iif(nOpcX<1,3,nOpcX)
cIniCpos := Iif(cIniCpos==Nil,"",cIniCpos)
nCount++
_xcLineOk := cLineOK
_xnOpcx	 := nOpcx

If nCount > 1
	oSaveGetdad := oGetDados
	oSaveGetdad:lDisablePaint := .t.
EndIf
oGets := {}
If Type("aRotina") == "A"
	aSvRot := aClone(aRotina)
EndIf

//aRotina := {}

For nX := 1 to len(aRotina) //nOpcX
	AADD(aRotina,{"","",0,nOpcx})
Next
aCGD:=Iif(Len(aCGD)==0,{34,5,128,315},aCGD)
If bF4<>nil.and.!Empty(bF4)
	SetKey(VK_F4,bF4)
EndIf
aCordW :=Iif(aCordW==Nil,{125,0,400,635},aCordW)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd

For i:=1 to Len(aC)
	If Len(aC[i])==7
		cCampo:=aC[i,1]
		nX:=aC[i,2,1]
		nY:=aC[i,2,2]
		cCaption:=Iif(Empty(aC[i,3])," ",aC[i,3])
		cPict:=Iif(Empty(aC[i,4]),Nil,aC[i,4])
		cValid:=Iif(Empty(aC[i,5]),".t.",aC[i,5])
		cF3:=Iif(Empty(aC[i,6]),NIL,aC[i,6])
		cWhen:=Iif(aC[i,7]==NIL,".t.",Iif(aC[i,7],".t.",".f."))
		cWhen := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
		cBlKSay := "{|| OemToAnsi('"+cCaption+"')}"
		oSay := TSay():New( nX-1, nY, &cBlkSay,oDlg,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
		// 							@ nX,nY SAY oSay PROMPT OemToAnsi(cCaption) OF oDlg PIXEL
		nLargSay := GetTextWidth(0,cCaption) / 1.8  // estava 2.2
		cCaption := oSay:cCaption
		
		cBlkGet := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
		cBlKVld := "{|| "+cValid+"}"
		cBlKWhen := "{|| "+cWhen+"}"
		
		oGet := TGet():New( nX, nY+nLargSay,&cBlKGet,oDlg,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
		AADD(oGets,oGet)
		// 							@ nX,nY+nLargSay MSGET oGet VAR &(cCampo) OF oDlg PIXEL Valid &cValid When &cWhen F3 cF3 PICTURE cPict
	EndIf
Next

// 	  oGetDados:=MSGetDados():New(aCGD[1],aCGD[2],aCGD[3],aCGD[4],1,"_xMOD2LineOK()","AllwaysTrue()","",.T.,aGetsGD, , , ,"_xFieldOk()")
oGetDados:=MSGetDados():New(aCGD[1],aCGD[2],aCGD[3],aCGD[4],nOpcX,"U_MOD2LineOK()","AllwaysTrue()",cIniCpos,lDelGetD,aGetsGD, , ,nMax ,"U_FieldOk()")
if cDelOk<>nil
   oGetDados:cDelOk:=cDelOk
endif   
For i:=1 to Len(aR)
	If Len(aR[i])==7
		cCampo:=aR[i,1]
		nX:=aR[i,2,1]
		nY:=aR[i,2,2]
		cCaption:=Iif(Empty(aR[i,3])," ",aR[i,3])
		cPict:=Iif(Empty(aR[i,4]),NIL,aR[i,4])
		cValid:=Iif(Empty(aR[i,5]),".t.",aR[i,5])
		cF3:=Iif(Empty(aR[i,6]),NIL,aR[i,6])
		cWhen:=Iif(aR[i,7]==NIL,".t.",Iif(aR[i,7],".t.",".f."))
		cWhen := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
		cBlKSay := "{|| OemToAnsi('"+cCaption+"')}"
		oSay := TSay():New( nX-1, nY, &cBlkSay,oDlg,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
		// 							@ nX,nY SAY oSay PROMPT OemToAnsi(cCaption) OF oDlg PIXEL
		nLargSay := GetTextWidth(0,cCaption) / 1.8
		cCaption := oSay:cCaption
		
		cBlkGet := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
		cBlKVld := "{|| "+cValid+"}"
		cBlKWhen := "{|| "+cWhen+"}"
		
		oGet := TGet():New( nX, nY+nLargSay,&cBlKGet,oDlg,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
		AADD(oGets,oGet)
		// 							@ nX,nY+nLargSay MSGET oGet VAR &(cCampo) OF oDlg PIXEL Valid &cValid When &cWhen F3 cF3
	EndIf
Next
public lcancel
lCancel:=.t.
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,lAllOk:=U_Mod2OK(cAllOk),Iif(lAllOk.and.(lcancel:=.t.),oDlg:End(),nOpca:=0)},{||iif(lCancel,oDlg:End(),Aviso("Atencao","Nao pode ser cancelado!",{"OK"}))},,aButtons) Centered Valid lCancel
//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||iif(lCancel,oDlg:End(),Aviso("Atencao","Nao e possivel cancelamento.",{"OK"}))},,aButtons)

nCount--
If nCount > 0
	oGetDados := oSaveGetDad
	oGetDados:lDisablePaint := .f.
EndIf
If ValType(aSvRot) == "A"
	aRotina := aClone(aSvRot)
EndIf
if bF4<>nil.and.!empty(bF4)
   SetKey(VK_F4,{||Nil})
endif   

Return (nOpca==1)

User Function Mod2LineOk()
Local lRet:=.t. , ni
If Str(_xnOpcx,1,0)$"346"
	lRet := &_xcLineOK
	For ni:= 1 to Len(oGets)
		oGets[ni]:Refresh()
	Next
EndIf
Return lRet
*---------------------------------------------------------------------------
User Function Mod2Ok(cAllOK)                                                
*---------------------------------------------------------------------------
Local lRet
lRet := U_Mod2LineOk()
If lRet
	lRet := &cAllOk
EndIf
Return lRet
                                                                            
*---------------------------------------------------------------------------
User Function CallMod2Obj()                                                 
*---------------------------------------------------------------------------
Return oGetDados
*---------------------------------------------------------------------------
User Function FieldOk()                                                     
*---------------------------------------------------------------------------
Local ni
For ni:= 1 to Len(oGets)
	oGets[ni]:Refresh()
Next
Return .t.

*---------------------------------------------------------------------------
user function CriaMv(_cFilial,_cTipo,_cNome,_cDefault,_cDescri)
*---------------------------------------------------------------------------
local _vAmbSX6:=sx6->(getarea()),_lOk:=.t.
_cFilial:=if(empty(_cFilial),space(len(sx6->x6_fil)),_cFilial)

if _cDescri<>nil.and.mlcount(alltrim(_cDescri),50)>3
	msgbox("u_CriaMv: Tamanho excedente na descricao do parametro...")
	_lOk:=.f.
endif
if _cTipo==nil.or.!((_cTipo:=upper(_cTipo))$"CDNL")
	msgbox("u_CriaMv: Tipo invalido...")
	_lOk:=.f.
endif
if _cNome==nil.or.empty(_cNome).or.len(alltrim(_cNome))>10
	msgbox("u_CriaMv: Nome invalido para o novo parametro...")
	_lOk:=.f.
endif
if _cDefault==nil
	_cDefault:=""
endif
if valtype(_cDefault)<>"C"
	msgbox("u_CriaMv: O valor default do parametro devera ser caracter ou nulo...")
	_lOk:=.f.
endif

sx6->(dbsetorder(1)) // X6_FIL+X6_VAR

_cNome:=padr(upper(_cNome),len(sx6->x6_var))
if _lOk.and.sx6->(!dbseek(_cFilial+_cNome,.f.).and.reclock(alias(),.t.))
	sx6->x6_fil     :=_cFilial
	sx6->x6_tipo    :=_cTipo
	sx6->x6_var     :=_cNome
	sx6->x6_conteud :=_cDefault
	sx6->x6_descric :=memoline(_cDescri,50,1)
	sx6->x6_desc1   :=memoline(_cDescri,50,2)
	sx6->x6_desc2   :=memoline(_cDescri,50,3)
	sx6->x6_propri  :='U'
	sx6->(msunlock())
endif
return

*---------------------------------------------------------------------------
user function CriaTab(_cTabela,_cDescri,_cCodItem,_cDescItem)
*---------------------------------------------------------------------------
local _vAmbSX5:=sx5->(getarea()),_lOk:=.t.,_lReturn:=.f.
_cTabela:=padr(alltrim(upper(_cTabela)),2)
_cDescri:=alltrim(upper(_cDescri))
_cCodItem:=padr(alltrim(upper(_cCodItem)),6)
_cDescItem:=alltrim(upper(_cDescItem))
sx5->(dbsetorder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
if sx5->(!dbseek(xfilial()+"00"+_cTabela,.f.))
   sx5->(reclock(alias(),.t.))
   sx5->x5_filial:=xfilial("SX5")
   sx5->X5_TABELA:="00"
   sx5->X5_CHAVE :=_cTabela
   sx5->X5_DESCRI:=_cDescri
   sx5->X5_DESCSPA:=_cDescri
   sx5->X5_DESCENG:=_cDescri
   sx5->(msunlock())
endif
if sx5->(!dbseek(xfilial()+"00"+_cTabela,.f.))
   msgbox("Criatab: Erro na localizacao do registro principal da tabela")
else
   if alltrim(upper(sx5->x5_descri))<>_cDescri
      msgbox("Criatab: a tabela localizada ("+alltrim(upper(sx5->x5_descri))+") nao corresponde a descricao informada ("+_cDescri+")")
   else
      // Se chegou aqui, pode criar o registro caso nao exista
      if sx5->(!dbseek(xfilial()+_cTabela+_cCodItem,.f.))
         sx5->(reclock(alias(),.t.))
         sx5->x5_filial:=xfilial("SX5")
         sx5->X5_TABELA:=_cTabela
         sx5->X5_CHAVE :=_cCodItem
         sx5->X5_DESCRI:=_cDescItem
         sx5->X5_DESCSPA:=_cDescItem
         sx5->X5_DESCENG:=_cDescItem
         sx5->(msunlock())
      endif
      _lReturn:=.t.
   endif
endif
return _lReturn

*---------------------------------------------------------------------------
user function TesteInt()
* Teste de processamento com interrupcao
*---------------------------------------------------------------------------
private lEnd:=.f.
Processa({|lEnd| TesteIntA()}, 'Clique para interromper')
static function testeIntA()
procregua(10000)
_nCont:=0
do while !lEnd
   incproc("Status: "+alltrim(str(_nCont)))
   _nCont++
   if _nCont>10000
      _nCont:=1
      procregua(10000)
   endif
enddo
msgbox("Processamento interrompido")
return      

*-----------------------------------------------------------------------------------------         
static function _fxToC(_xParam)
*-----------------------------------------------------------------------------------------         
local _cTipo:=valtype(_xParam),_cReturn
if _cTipo=="C"
   _cReturn:=alltrim(_xParam)
elseif _cTipo=='D'
   _cReturn:=dtoc(_xParam)
elseif _cTipo=='N'
   _cReturn:=alltrim(str(_xParam))
elseif _cTipo=='L'
   _cReturn:=if(_xParam,'.T.','.F')
elseif _cTipo=='B'
   _cReturn:='A expressao retorna bloco de codigo'
elseif _cTipo=='U'
   _cReturn:='A variavel nao existe ou nao e visivel'
endif

return _cReturn

*-----------------------------------------------------------------------------------------         
static function _fReplace() 
*-----------------------------------------------------------------------------------------
local _oDlg1
static _cRepAlias,_cRepFor,_cRepWith,_cRepCampo

if _cRepAlias==nil
   _cRepAlias:=space(3)
   _cRepCampo:=space(10)
   _cRepFor:=_cRepWith:=space(300)
endif

@ 000,000 to 180,600 dialog _odlg1 title 'Inutilities Replace'
@ 010,005 say "Alias: "
@ 010,020 get _cRepAlias pict "@!" size 10,10 valid(_fAtuCombo())
_vCampos:={}        
@ 010,047 Say "Selecione ou informe o campo a ser alterado: "
_nCampo:=0
@ 010,160 COMBOBOX _nCampo ITEMS _vCampos SIZE 90,10 object _oCampos 
_oCampos:bValid:={||len(_cRepCampo:=left(_vCampos[_oCampos:nAt],10))<>99}

@ 010,252 get _cRepCampo PICT "@!" size 42,10

@ 020,005 say "Condicao For: "
@ 030,003 get _cRepFor size 297,10

@ 040,005 say "With:: "
@ 050,003 get _cRepWith size 297,10

@ 065,225 bmpbutton type 1 action u_RsAguarde({||_fReplace1(_cRepAlias,_cRepCampo,_cRepFor,_cRepWith)},"Aguarde, em processamento")
@ 065,260 bmpbutton type 2 action close(_oDlg1)

activate dialog _oDlg1 centered

*-----------------------------------------------------------------------------------------         
static function _fAtucombo() 
*-----------------------------------------------------------------------------------------
local _vAmbAtu:=getarea(),_lErro,_x,_cAlias,_cCampoSel,_vCampos1,_nVez

_cAlias:=_cRepAlias
_cAlias:=upper(alltrim(_cAlias))
if !u__fIsOpen(_cAlias)
   msgbox("O alias ("+alltrim(_cAlias)+") nao esta disponivel")
   return .f.
endif

dbselectarea(_cAlias)

if alias()<>_cAlias
   msgbox("Nao foi possivel selecionar a area solicitada: ("+_cAlias+")")
   return .f.
endif

_vCampos1:=dbstruct()
_vCampos:={}
for _nVez:=1 to len(_vCampos1)     
    _cCampoSel:=upper(padr(_vCampos1[_nVez][1],10))
    aadd(_vCampos,_cCampoSel+" - "+posicione("SX3",2,_cCampoSel,"x3_titulo"))
next
_oCampos:aItems:=aclone(_vCampos)
_oCampos:nAt:=1
return .t.

*-----------------------------------------------------------------------------------------         
static function _fReplace1(_cAlias,_cCampo,_cFor,_cWith) 
*-----------------------------------------------------------------------------------------
local _vAmbAtu:=getarea(),_cMens

dbselectarea(_cAlias)

if empty(_cFor)
   _cFor:=".t."
else
   _cFor:=alltrim(_cFor)
   _x:=valtype(&_cFor)
   
   if _x=="L"    
   else
      msgbox('Erro de sintaxe na condicao "For"')   
      return
   endif
endif      
_cCampo:=alltrim(upper(_cCampo))
if empty(_cCampo)
   msgbox("O nome do campo a ser alterado nao foi informado")
   return
else
   if ascan(dbstruct(),{|_vAux|alltrim(_vAux[1])==_cCampo})==0
      msgbox("Campo invalido: ("+_cCampo+")")
      return
   endif
endif   
   
if empty(_cWith)   
   msgbox('Erro de sintaxe na clausula "With"')             
   return
else 
   _cWith:=alltrim(_cWith)
   _cTipoExp:=valtype(&_cWith)
   _cTipoCampo:=valtype(&(alias()+"->"+_cCampo))
   if _cTipoExp<>_cTipoCampo
      msgbox("O tipo de dados resultante da expressao ("+_cTipoExp+") nao confere com o do campo solicitado ("+_cTipoCampo+")")
      return
   endif
endif

dbgotop()
_nAlterados:=_nJafoi:=0
do while !eof()
   if &_cFor
      reclock(alias(),.f.)
      _cComando:=alias()+"->"+_cCampo+":="+_cWith
      _x:=&_cComando
      msunlock()
      _nAlterados++
   endif
   dbskip(1)
   _cUltimo:="/"+alltrim(str(lastrec()))
   u_rsproctxt(_cMens:="Registros percorridos: "+alltrim(str(++_nJafoi))+_cUltimo+chr(10)+;
                "Alterados: "+alltrim(str(_nAlterados)))
enddo      

dbselectarea(_vAmbAtu[1])
restarea(_vAmbAtu)

msgbox(_cMens)
return


*-----------------------------------------------------------------------------------------         
static function _fB7Zero() 
* Geracao de lancamentos com quantidade 0 no inventario
*-----------------------------------------------------------------------------------------
private _cPerg :="B7Zero",_oDlg4,_cQuebral:=chr(13)+chr(10)

VldPB70(_cPerg)

@ 000,000 TO 200,470 DIALOG _oDlg4 TITLE "Geracao de apontamentos com quantidade 0 para inventario"
@ 010,008 say u__fajtxt("Esta rotina gera apontamentos com quantidade 0, comparando SB2 e SB8 com os")
@ 020,008 say u__fajtxt("registros constantes em SB7 para uma UNICA data de inventario.")
@ 030,008 say u__fajtxt("Pode ser utilizada simultaneamente para produtos com ou sem rastreabilidade de lote.")
@ 040,008 say u__fajtxt("Nao esta preparada para uso com rastreabilidade de sub-lote ou localizacao fisica.")
@ 050,008 say u__fajtxt("Os registros complementares serao gerados em SB7 com a mesma data informada")
@ 060,008 say u__fajtxt("nos parametros.")

@ 080,070 BMPBUTTON type 1  ACTION (u_rsaguarde({||_fB7ZerA()},"Gerando apontamentos de inventario"),Close(_oDlg4))
@ 080,110 BMPBUTTON type 5  ACTION pergunte(_cPerg,.t.) 
@ 080,150 BMPBUTTON type 2  ACTION Close(_oDlg4)

ACTIVATE DIALOG _oDlg4 CENTER                                                       

*----------------------------------------------------------------------------------
Static Function _fB7ZerA()
*----------------------------------------------------------------------------------
local _nVez
u_RsProctxt("Preparando dados")
pergunte(_cPerg,.f.)

_dDataInv:=mv_par01 // Data do inventario
_cProdIni:=mv_par02 // Produto de
_cProdFim:=mv_par03 // Produto ate
_cLocaIni:=mv_par04 // Almoxarifado de
_cLocaFim:=mv_par05 // Almoxarifado ate

_cOrdSb2:="b2_filial+b2_cod+b2_local"
_cFilSb2:="b2_filial=='"+xfilial("SB2")+"'"
_cFilSb2+=".and.b2_cod>='"+_cProdIni+"'.and.b2_cod<='"+_cProdFim+"'"
_cFilSb2+=".and.b2_local>='"+_cLocaIni+"'.and.b2_local<='"+_cLocaFim+"'"
_cFilSb2+=".and.b2_qatu<>0"

sb2->(indregua(alias(),criatrab(,.f.),_cOrdSb2,,_cFilSb2))

_cOrdSb8:="b8_filial+b8_produto+b8_local+b8_lotectl+b8_numlote"
_cFilSb8:="b8_filial=='"+xfilial("SB8")+"'"
_cFilSb8+=".and.b8_produto>='"+_cProdIni+"'.and.b8_produto<='"+_cProdFim+"'"
_cFilSb8+=".and.b8_local>='"+_cLocaIni+"'.and.b8_local<='"+_cLocaFim+"'"
_cFilSb8+=".and.b8_saldo<>0"
sb8->(indregua(alias(),criatrab(,.f.),_cOrdSb8,,_cFilSb8))

_cOrdSb7:="B7_FILIAL+B7_COD+B7_LOCAL+B7_LOTECTL+B7_NUMLOTE"
_cFilSb7:="b7_filial=='"+xfilial("SB7")+"'"
_cFilSb7+=".and.dtos(b7_data)=='"+dtos(_dDataInv)+"'"
sb7->(indregua(alias(),criatrab(,.f.),_cOrdSb7,,_cFilSb7))

_nJafoi:=_nGerouCL:=_nGerouSL:=0
sb2->(dbgotop())
_vB70:={}

/*
 Layout de _vB70 
 _vB70[n][1]=Codigo do produto
 _vB70[n][2]=Local
 _vB70[n][3]=Lote
 _vB70[n][4]=Validade do lote

*/
do while sb2->(!eof())
   _cMen1:="Verificando o produto: "+sb2->b2_cod+" Local: "+sb2->b2_local
   _cMen2:="Apontamentos gerados com Lote: "+alltrim(str(_nGerouCL))
   _cMen3:="Apontamentos gerados sem Lote: "+alltrim(str(_nGerouSL))
   _cMen4:="Total registros processados a partir de SB2: "+alltrim(str(++_nJafoi))
   u_RsProcTxt(_cMen1+_cQuebral+_cMen2+_cQuebral+_cMen3+_cQuebral+_cMen4)
   if sb8->(dbseek(xfilial()+sb2->(b2_cod+b2_local),.f.))
      _cKeySb8Main:=sb8->(b8_filial+b8_produto+b8_local)
      do while sb8->(!eof().and.b8_filial+b8_produto+b8_local==_cKeySb8Main)
         if sb7->(dbseek(xfilial()+sb8->(b8_produto+b8_local+b8_lotectl),.f.))
            sb8->(dbskip(1))
         else   
            _nGerouCl++
            sb8->(aadd(_vB70,{b8_produto,b8_local,b8_lotectl,b8_dtvalid}))
            _cKeySb8:=sb8->(b8_filial+b8_produto+b8_local+b8_lotectl)
            do while sb8->(!eof().and.b8_filial+b8_produto+b8_local+b8_lotectl==_cKeySb8)
               sb8->(dbskip(1))
            enddo
         endif   
      enddo
   else
      if !sb7->(dbseek(xfilial()+sb2->(b2_cod+b2_local),.f.))
         _nGerouSl++
         sb2->(aadd(_vB70,{b2_cod,b2_local,"",ctod("")}))
      endif
   endif
   sb2->(dbskip(1))
enddo

for _nVez:=1 to len(_vB70)
    u_RsProcTxt("Gravando apontamentos"+_cQuebral+alltrim(str(_nVez))+"/"+alltrim(str(len(_vB70))))
    sb7->(reclock(alias(),.t.))
    sb7->B7_FILIAL :=xfilial("SB7")
    sb7->B7_COD    :=_vB70[_nVez][1]
    sb7->B7_LOCAL  :=_vB70[_nVez][2]
    sb7->B7_TIPO   :=posicione("SB1",1,xfilial("SB1")+sb7->b7_cod,"b1_tipo")
    sb7->B7_DOC    :="ZERAB7"
    sb7->B7_QUANT  :=0
    sb7->B7_DATA   :=_dDataInv
    sb7->B7_LOTECTL:=_vB70[_nVez][3]
    sb7->B7_DTVALID:=_vB70[_nVez][4]
    sb7->(msunlock())
next

sb2->(retindex())
sb7->(retindex())
sb8->(retindex())

msgbox("Processamento concluido, "+alltrim(str(len(_vB70)))+" registros gerados.")

return

*----------------------------------------------------------------------------------
Static Function VldPB70(_cPerg)
*----------------------------------------------------------------------------------
local aRegs:={}

aadd(aRegs,{_cPerg,"01","Data do inventario           :","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"02","Produto de                   :","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SB1"})
aadd(aRegs,{_cPerg,"03","Produto ate                  :","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1"})
aadd(aRegs,{_cPerg,"04","Almoxarifado de              :","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
aadd(aRegs,{_cPerg,"05","Almoxarifado ate             :","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})

u__fAtuSx1(padr(_cPerg,len(sx1->x1_grupo)),aRegs)
Return

*-----------------------------------------------------------------------------------------         
static function _fGeraSx1() 
*-----------------------------------------------------------------------------------------
local _oDlgSx1

private _oTitCod,_oCodigo,_cCodigo,_cQuebral:=chr(13)+chr(10),_cGrupo:=space(len(sx1->x1_grupo)),_nIdioma:=1
                         
_cCodigo:="*----------------------------------------------------------------------------------"+_cQuebraL
_cCodigo+="Static Function VALIDPERG()"+_cQuebraL
_cCodigo+="*----------------------------------------------------------------------------------"+_cQuebraL
_cCodigo+="local aRegs:={}"+_cQuebraL

_cCodigo+="            *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26"+_cQuebraL
_cCodigo+="*+---------------------------------------------------------------------------------------------------------------------------------+"+_cQuebraL
_cCodigo+="*¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦"+_cQuebraL
_cCodigo+="*¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦"+_cQuebraL
_cCodigo+="*¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦"+_cQuebraL
_cCodigo+="*¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦"+_cQuebraL
_cCodigo+="*¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦"+_cQuebraL

_cCodigo+='AADD(aRegs,{cPerg,"01","Pergunta 1 (Get)   :","mv_ch1","C",06,0,0,"G","","mv_par01",""    ,"","",""      ,"","","","","","","","","","",""})'+_cQuebral
_cCodigo+='AADD(aRegs,{cPerg,"02","Pergunta 2 (Combo) :","mv_ch2","N",01,0,0,"C","","mv_par02","Opcao 1","","","Opcao 2","","","Opcao 3","","","Opcao 4","","","Opcao 5","",""})'+_cQuebral

_cCodigo+="u__fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)"+_cQuebral
_cCodigo+="Return"+_cQuebral

@ 000,000 to 400,600 dialog _odlg title 'Geracao de codigo para a funcao "ValidPerg" a partir de Sx1'
@ 010,010 say "Grupo em Sx1: "
@ 010,060 get _cGrupo
@ 010,090 bmpbutton type 1 action _fGeraSx1a(_cGrupo,@_cCodigo,@_oCodigo)
@ 010,200 radio {"Portugues  ","Ingles     ","Espanhol   "} var _nIdioma 
//@ 020,010 say "Codigo padrao" object _oTitCod
@ 045,005 get _cCodigo size 280,160 memo object _oCodigo

activate dialog _oDlg centered

*-----------------------------------------------------------------------------------------         
static function _fGeraSx1a() 
*-----------------------------------------------------------------------------------------

sx1->(dbsetorder(1))
if sx1->(dbseek(_cGrupo,.f.))
   
   _cCodigo:="*----------------------------------------------------------------------------------"+_cQuebraL
   _cCodigo+="Static Function VALIDPERG()"+_cQuebraL
   _cCodigo+="*----------------------------------------------------------------------------------"+_cQuebraL
   _cCodigo+="local aRegs:={}"+_cQuebraL+_cQuebraL

   _cCodigo+="            *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26"+_cQuebraL
   _cCodigo+="*+---------------------------------------------------------------------------------------------------------------------------------+"+_cQuebraL
   _cCodigo+="*¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦"+_cQuebraL
   _cCodigo+="*¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦"+_cQuebraL
   _cCodigo+="*¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦"+_cQuebraL
   _cCodigo+="*¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦"+_cQuebraL
   _cCodigo+="*¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦"+_cQuebraL+_cQuebraL

   do while sx1->(!eof().and.x1_grupo==_cGrupo)
      _cCodigo+=sx1->('aadd(aRegs,{cPerg,"'+x1_ordem+'","'+;
                      if(_nIdioma==1,x1_pergunt,if(_nIdioma==2,x1_pereng,x1_perspa))+'","'+x1_variavl+'","'+x1_tipo+'",'+;
                      strzero(x1_tamanho,2)+','+str(x1_decimal,1)+',0,"'+;
                      x1_gsc+'","'+alltrim(x1_valid)+'","'+;
                      alltrim(x1_var01)+'","'+alltrim(if(_nIdioma==1,x1_def01,if(_nIdioma==2,x1_defeng1,x1_defspa1)))+'","'+alltrim(x1_cnt01)+'","'+;
                      alltrim(x1_var02)+'","'+alltrim(if(_nIdioma==1,x1_def02,if(_nIdioma==2,x1_defeng2,x1_defspa2)))+'","'+alltrim(x1_cnt02)+'","'+;
                      alltrim(x1_var03)+'","'+alltrim(if(_nIdioma==1,x1_def03,if(_nIdioma==2,x1_defeng3,x1_defspa3)))+'","'+alltrim(x1_cnt03)+'","'+;
                      alltrim(x1_var04)+'","'+alltrim(if(_nIdioma==1,x1_def04,if(_nIdioma==2,x1_defeng4,x1_defspa4)))+'","'+alltrim(x1_cnt04)+'","'+;
                      alltrim(x1_var05)+'","'+alltrim(if(_nIdioma==1,x1_def05,if(_nIdioma==2,x1_defeng5,x1_defspa5)))+'","'+alltrim(x1_cnt05)+'","'+;
                      alltrim(x1_f3)+'"})')+_cQuebral
      sx1->(dbskip(1))
  enddo
  _cCodigo+=_cQuebraL
  _cCodigo+="u__fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)"+_cQuebral
  _cCodigo+="Return"+_cQuebral+_cQuebral+_cQuebral
  
  _oCodigo:cCaption:='Codigo para o grupo "'+_cGrupo+'"'
else
  msgbox("O grupo nao foi encontrado")
endif

*--------------------------------------------------------------------------------
user Function fMMens(_cTitulo,_cMens)
*--------------------------------------------------------------------------------
local _oFont:=TFont():New( "Courier New",,nHeight:=15,,lBold:=.f.,,,,,lUnderLine:=.f.),;
      _oDlg

@ 0,0 to 308,495 dialog _oDlg title _cTitulo
@ 5,5 get _cMens memo size 239,134 object _oGetMens
@ 142,200 bmpbutton type 1 action(close(_oDlg))
_oGetMens:lReadOnly:=.t.
_oGetMens:oFont:=_oFont
activate dialog _oDlg centered
return

*-----------------------------------------------------------------------------------------         
user function RBackup(_lSchedulP)
* Ricardo Luiz da Rocha 08/02/2006 GNSJC
* Exporta os dados (em ambientes TopConnect) para DBF, podendo opcionalmente
* acionar um batch para ser executado apos o termino.
*-----------------------------------------------------------------------------------------         
private aRegs:={},_oDlgBkp
private _lSchedule:=.f.,_cPergBkp:='RBack1'


if _lSchedulP==nil
   _lSchedule:=.t.
   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
endif

          *   1    2            3                   4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
          *+------------------------------------------------------------------------------------------------------------------------------------+
          *¦G    ¦ O  ¦ PERGUNT                 ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
          *¦ R   ¦ R  ¦                         ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
          *¦  U  ¦ D  ¦                         ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
          *¦   P ¦ E  ¦                         ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
          *¦    O¦ M  ¦                         ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
AADD(aRegs,{_cPergBkp,"01","Path destino (sob ap_data)   :","mv_ch1","C",60,0,0,"G","","mv_par01",""    ,"RBackup\Dados","",""      ,"","","","","","","","","","",""})
AADD(aRegs,{_cPergBkp,"02","Batch (opc-use path completo):","mv_ch2","C",60,0,0,"G","","mv_par02",""    ,"RBackup\Batch\Rbackup.bat","",""      ,"","","","","","","","","","",""})

u__fAtuSx1(padr(_cPergBkp,len(sx1->x1_grupo)),aRegs)
    
pergunte(_cPergBkp,.f.)
_cPath:=alltrim(mv_par01)
if empty(_cPath)
   msgbox("O diretorio para exportacao nao pode ficar em branco")
   return
endif
if right(_cPath,1)<>"\"
   _cPath+="\"
endif

if left(_cPath,1)=='\'
   _cPath:=substr(_cPath,2)
endif

_cBatch:=alltrim(mv_par02)

if _lSchedule
    _fExpBkp()
else
   @ 000,000 TO 170,430 DIALOG _oDlgBkp TITLE "Exportacao de dados para Backup"
   @ 008,005 say u__fajtxt(" Esse programa exporta os dados de ambientes TopConnect para DBF.") 
   @ 018,005 say u__fajtxt(" Pode-se opcionalmente configurar um Batch para execucao no final da exportacao.")
   @ 040,020 BMPBUTTON type 15 action _fHelpSchedule()
   @ 043,055 say u__fajtxt("Veja aqui como schedular essa rotina atraves do workflow")
   @ 065,020 BMPBUTTON type 1  ACTION u_RsAguarde({||_fExpBkp()},"Backup em andamento") 
   @ 065,060 BMPBUTTON type 5  ACTION pergunte(_cPergBkp,.t.)  // Parametros
   @ 065,100 BMPBUTTON type 2  ACTION Close(_oDlgbkp) 

   ACTIVATE DIALOG _oDlgbkp CENTERED
endif   
       
*-----------------------------------------------------------------------------------------         
static function _fExpBkp()
*-----------------------------------------------------------------------------------------
local _vTabelas:={},_cNome,_nVez,_cDestino

pergunte(_cPergBkp,.f.)
_cPath:=alltrim(mv_par01)
if empty(_cPath)
   msgbox("O diretorio para exportacao nao pode ficar em branco")
   return
endif
if right(_cPath,1)<>"\"
   _cPath+="\"
endif

if left(_cPath,1)=='\'
   _cPath:=substr(_cPath,2)
endif

_cBatch:=alltrim(mv_par02)

// Testa a existencia do diretorio de destino da exportacao
_cNome:=criatrab(,.f.)

dbcreate(_cPath+_cNome,{{'TEST1','C',1,0}})
dbusearea(.t.,'DBFCDX',_cPath+_cNome,'TESTEBKP',.t.,.f.)
if !file(_cPath+_cNome+'.dbf')
   msgbox('O diretorio de destino e invalido')
   return
endif
if alias()<>'TESTEBKP'
   msgbox('O diretorio de destino e invalido (nao foi possivel gravar os dados de teste)')
   return
else
  testebkp->(dbclosearea())
endif
ferase(_cPath+_cNome+'.dbf')
if !_lSchedule.and.!empty(_cBatch).and.!file(_cBatch)
   msgbox('O Batch nao foi encontrado')
   return
endif
_cLog:=alltrim(left(memoread(_cPath+'RBackup.log'),5000))
memowrit(_cPath+'RBackup.log',sm0->m0_codigo+' - Inicio: '+dtoc(date())+' as '+time()+' h'+chr(13)+chr(10)+_cLog)
ferase(_cPath+'RBackup.ok')

_cLog:=''

if !_lSchedule
   u_RsProcTxt('1a fase, abrindo as tabelas')
endif   
// colher as tabelas a exportar
//_cQuery:="select name from sysobjects where xtype='U' and right(rtrim(name),4)<>'_BKP' and left(name,4)<>'TOP_' order by name"
_cQuery:="select name from sysobjects where xtype='U' and right(rtrim(name),4)<>'_BKP' and name<>'dtproperties' and left(name,4)<>'TOP_' order by name"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"X_TABELAS",.T.,.T.)

set(11,"OFF")

do while x_tabelas->(!eof())
    _cSqlName:=x_Tabelas->name
    dbusearea(.t.,'TOPCONN',_cSqlName,_cSqlName,.t.,.f.)

    if upper(alltrim(_cSqlName))<>alias()
       msgbox('Nao foi possivel selecionar a tabela '+_cSqlName+' para a exportacao, saindo do sistema')
       quit
    endif

    _cDestino:=alltrim("\"+_cPath+_cSqlName)

    if !_lSchedule
       u_RsProctxt('Exportando: '+_cSqlName)
    endif   

    copy to &_cDestino
    commit
    if !file(_cDestino+".dbf")
       msgbox("Falha na criacao de: "+_cDestino+', abandonando o sistema.' )
       quit
    endif
    dbclosearea()
    x_tabelas->(dbskip(1))
enddo

if !_lSchedule
   msgbox('Processamento concluido, abandonando o sistema')
endif         
if !empty(_cBatch)
   // Nao esta acionando corretamente via WF, entao schedular o batch pelo windows
   if !_lSchedule
      winexec(_cBatch)
   endif   
endif   

_cLog:=alltrim(left(memoread(_cPath+'RBackup.log'),5000))
memowrit(_cPath+'RBackup.log',sm0->m0_codigo+' - Termino '+dtoc(date())+' as '+time()+' h'+chr(13)+chr(10)+_cLog+'-----------------------------------'+chr(13)+chr(10))
memowrit(_cPath+'RBackup.Ok','')

quit

*---------------------------------------------------------------------------------------------------------         
static function _fHelpSchedule() 
*---------------------------------------------------------------------------------------------------------
local _cTexto:='',_cQuebral:=chr(13)+chr(10),_oDlgHelp,_oGetTexto,;
      _oFont:=TFont():New( "Courier New",,nHeight:=15,,lBold:=.f.,,,,,lUnderLine:=.f.)

_cTexto+='Para que esta rotina seja executada atraves do workflow, siga os seguintes passos:'+_cQuebral+_cQuebral
_cTexto+='1 - Inclua no server.ini do Protheus (ap7srv.ini, mp8srv.ini, etc...) as seguintes secoes, uma para cada EMPRESA cujo backup deseje executar. O exemplo abaixo contempla 3 empresas:'+_cQuebral+_cQuebral
_cTexto+='[ONSTART]'+_cQuebral
_cTexto+='jobs=JOBEMP01,JOBEMP02,JOBEMP_N,WORKEMP01,WORKEMP02,WORKEMP_N'+_cQuebral+_cQuebral
_cTexto+='[JOBEMP01]'+_cQuebral
_cTexto+='Main=Schedjob'+_cQuebral
_cTexto+='Environment=Nome_do_ambiente'+_cQuebral
_cTexto+='nParms=2'+_cQuebral
_cTexto+='Parm1=01 ;Codigo da empresa '+_cQuebral
_cTexto+='Parm2=01 ;Codigo da filial (Nao importa que codigo seja informado, os dados de todas as filiais serao exportados) '+_cQuebral+_cQuebral
_cTexto+='[JOBEMP02]'+_cQuebral
_cTexto+='Main=Schedjob'+_cQuebral
_cTexto+='Environment=Nome_do_ambiente'+_cQuebral
_cTexto+='nParms=2'+_cQuebral
_cTexto+='Parm1=02 ;Codigo da empresa '+_cQuebral
_cTexto+='Parm2=01 '+_cQuebral+_cQuebral
_cTexto+='[JOBEMP_N]'+_cQuebral
_cTexto+='Main=Schedjob'+_cQuebral
_cTexto+='Environment=Nome_do_ambiente'+_cQuebral
_cTexto+='nParms=2'+_cQuebral
_cTexto+='Parm1=0N ;Codigo da empresa '+_cQuebral
_cTexto+='Parm2=01'+_cQuebral+_cQuebral
_cTexto+='[WORKEMP01]'+_cQuebral
_cTexto+='Main=U_INITS01'+_cQuebral
_cTexto+='Environment=Nome_do_ambiente'+_cQuebral
_cTexto+='nParms=2'+_cQuebral
_cTexto+='Parm1=01'+_cQuebral
_cTexto+='Parm2=01'+_cQuebral+_cQuebral
_cTexto+='[WORKEMP02]'+_cQuebral
_cTexto+='Main=U_INITS02'+_cQuebral
_cTexto+='Environment=Nome_do_ambiente'+_cQuebral
_cTexto+='nParms=2'+_cQuebral
_cTexto+='Parm1=02'+_cQuebral
_cTexto+='Parm2=01'+_cQuebral+_cQuebral
_cTexto+='[WORKEMP0N]'+_cQuebral
_cTexto+='Main=U_INITS0N'+_cQuebral
_cTexto+='Environment=Nome_do_ambiente'+_cQuebral
_cTexto+='nParms=2'+_cQuebral
_cTexto+='Parm1=0N'+_cQuebral
_cTexto+='Parm2=01'+_cQuebral+_cQuebral
_cTexto+='2 - Para cada empresa, crie uma user function (pode até ser no mesmo .prw) com o nome correspondente, de maneira similar ao exemplo abaixo:'+_cQuebral+_cQuebral
_cTexto+='*---------------------------------------------------------------------------------------------'+_cQuebral
_cTexto+='USER FUNCTION INITS01()'+_cQuebral
_cTexto+='*---------------------------------------------------------------------------------------------'+_cQuebral
_cTexto+="Local aParams := {'01','01'}  //Coloque aqui o codigo da empresa e filial, igual a chamada do workflow"+_cQuebral
_cTexto+='WFScheduler(aParams)'+_cQuebral+_cQuebral
_cTexto+='Return .T.'+_cQuebral+_cQuebral
_cTexto+='3 - Agora, pelo configurador, acesse a rotina Schedule/Schedule (caso nao a tenha no menu, adicione, funcao MSSCHEDULE'+_cQuebral+_cQuebral
_cTexto+='Entre nas opcoes "Processos especiais" e selecione diario, semanal ou mensal como queira. Na tela a seguir configure as opcoes, e na caixa "Acao" informe "U_RBackup(.t.)"'+_cQuebral+_cQuebral
_cTexto+='4 - Com tudo pronto, o servico do Protheus devera ser reiniciado. Boa sorte !'

@ 0,0 to 480,776 dialog _oDlgHelp title "Para executar o RBackup atraves do Workflow do Protheus"
@ 5,5 get _cTexto memo size 382,215 object _oGetTexto
@ 225,280 bmpbutton type 1 action(close(_oDlgHelp))
_oGetTexto:lReadOnly:=.f.
_oGetTexto:oFont:=_oFont
activate dialog _oDlgHelp centered
return

*------------------------------------------------------------------------------------------------
static function _fInvCt5()
* Inversao de lancamentos contabeis - Ricardo Luiz da Rocha - 03/01/2007 GNSJC
*------------------------------------------------------------------------------------------------                                                                                                 
@ 0,0 to 250,600 dialog _oDlgCt5 title "Inversao de lancamentos contabeis"
@ 10,10 say "Esta rotina gera os lancamentos inversos (cancelamentos / estornos)"
@ 20,10 say "aos ja cadastrados no CT5 da empresa atual."
@ 30,10 say "Caso voce execute a geracao de lancamentos ja existentes, estes poderao"
@ 40,10 say "ser substituidos mediante confirmacao."

_vSuportados:={"500->505",;
     		   "501->588",;
               "508->509",;
               "510->515",;
               "511->512",;
               "513->589",;
               "520->527",;
               "530->531",;
               "562->564",;
               "563->565",;
               "566->571",;
               "590->591",;
               "610->630",;
               "610->641",;
               "620->635",;
               "620->640",;
               "650->655",;
               "660->665"}

_cOpcao:=''
@ 60,14 say "Lancamentos suportados: "
@ 60,80 combobox _cOpcao items _vSuportados  size 40,40
@ 58,130 button "Inverter agora" size 60,15 action _fInvCt5a(_cOpcao) 
@ 80,12 Button "Renumerar sequencias (todos os lancamentos)" size 120,15 action _fRenumSeq()
activate dialog _oDlgCt5 center

*-------------------------------------------------------------------------------------------------
static function _fRenumSeq()
* Renumeracao do ct5_sequen de forma a ajustar as sequencias
*-------------------------------------------------------------------------------------------------
local _nVez
if !msgyesno("Confirma a renumeracao de sequencias ?")
   return
endif   

_vSeq:={}
_cMaxSeq:=space(3)
ct5->(dbgotop())
cursorwait()
_nQuant:=0
do while ct5->(!eof())
   aadd(_vSeq,ct5->ct5_sequen)
   _nQuant++
   ct5->(dbskip(1))
enddo

asort(_vSeq)
_cMaxSeq:=_vSeq[len(_vSeq)]
_vSeq:={}                           

_cMaxSeq:=soma1(_cMaxSeq)
for _nVez:=1 to _nQuant
    _cMaxSeq:=soma1(_cMaxSeq)
    aadd(_vSeq,_cMaxSeq)
next
ct5->(dbgobottom())
_nVez:=len(_vSeq)
do while ct5->(!bof()).and._nVez>0
   ct5->(reclock(alias(),.f.))
   ct5->ct5_sequen:=_vSeq[_nVez]
   _nVez--
   ct5->(msunlock())
   ct5->(dbskip(-1))
enddo

ct5->(dbgotop())
do while ct5->(!eof())
   _cLanc:=ct5->(ct5_filial+ct5_lanpad)
   _cSeq:='001'
   do while ct5->(ct5_filial+ct5_lanpad==_cLanc)
      ct5->(reclock(alias(),.f.))
      ct5->ct5_sequen:=_cSeq
      _cSeq:=soma1(_cSeq)
      ct5->(Msunlock())
      ct5->(dbskip(1))
   enddo
enddo
cursorarrow()
msgbox("Renumeracao concluida")    

return

*-------------------------------------------------------------------------------------------------
static function _fInvCt5a(_cLanc)
* Gera os novos lancamentos em CT5
*-------------------------------------------------------------------------------------------------
local _nVez,_nVezExc
_cBase:=left(_cLanc,3)
_cNovo:=substr(_cLanc,6,3)

_lContinua:=.t.
if ct5->(dbseek(xfilial()+_cNovo,.f.))
   if msgyesno("Ja existem lancamentos "+_cNovo+", deseja sobrescreve-los ?")
      do while ct5->(!eof().and.ct5_filial==xfilial().and.ct5_lanpad==_cNovo)
         ct5->(reclock(alias(),.f.))
         ct5->(dbdelete())
         ct5->(dbskip(1))
      enddo   
   else
      _lContinua:=.f.
   endif
endif
if !_lContinua
   return
endif

_cChave:=ct5->(xfilial())+_cBase
dbcreate(_cNomArq:=criatrab(,.f.),ct5->(dbstruct()))
dbusearea(.t.,,_cNomArq,'TMPCT5',.t.,.f.)

if ct5->(!dbseek(_cChave,.f.))
   msgbox("Lancamento-base "+_cBase+" nao encontrado")
else   
   if _lContinua.and.msgyesno("Inverter os lancamentos de "+_cBase+" para "+_cNovo+" ?")
      cursorwait()
      do while ct5->(!eof().and.ct5_filial+ct5_lanpad==_cChave)
         tmpct5->(reclock(alias(),.t.))
         for _nVez:=1 to tmpct5->(fcount())
             _cCampo:=tmpct5->(fieldname(_nVez))
             _cComando:='tmpct5->'+_cCampo+":=ct5->"+_cCampo
             _x:=&_cComando      
         next    
         tmpct5->(msunlock())
         ct5->(dbskip(1))
      enddo  
      tmpct5->(dbgotop())
      do while tmpct5->(!eof())
         ct5->(reclock(alias(),.t.))
         for _nVez:=1 to tmpct5->(fcount())
             _cCampo:=tmpct5->(fieldname(_nVez))
             if _cCampo=='CT5_LANPAD'
                ct5->ct5_lanpad:=_cNovo
             else
                _cComando:='ct5->'+_cCampo+":=tmpct5->"+_cCampo
                _x:=&_cComando
             endif
             
             if _cCampo=='CT5_DESC'
                ct5->ct5_desc:='CANC '+tmpct5->ct5_desc
             elseif _cCampo=='CT5_DC'
                if ct5->ct5_dc=='1'
                   ct5->ct5_dc:='2'
                elseif ct5->ct5_dc=='2'
                   ct5->ct5_dc:='1'
                endif
             elseif _cCampo=='CT5_DEBITO'
                ct5->ct5_debito:=tmpct5->ct5_credit
             elseif _cCampo=='CT5_CREDIT'
                ct5->ct5_credit:=tmpct5->ct5_debito
             elseif _cCampo=='CT5_HIST'
                ct5->ct5_hist:="'CANC '+"+tmpct5->ct5_hist
             elseif _cCampo=='CT5_ORIGEM'   
                ct5->ct5_origem:='"'+_cNovo+' - '+ct5->ct5_sequen+'"'
             elseif _cCampo=='CT5_ITEMD'
                ct5->ct5_itemd:=tmpct5->ct5_itemc
             elseif _cCampo=='CT5_ITEMC'
                ct5->ct5_itemc:=tmpct5->ct5_itemd
             elseif _cCampo=='CT5_CLVLDB'
                ct5->ct5_clvldb:=tmpct5->ct5_clvlcr
             elseif _cCampo=='CT5_CLVLCR'
                ct5->ct5_clvlcr:=tmpct5->ct5_clvldb
             elseif _cCampo=='CT5_ATIVDE'
                ct5->ct5_ativde:=tmpct5->ct5_clvlcr
             elseif _cCampo=='CT5_ATIVCR'
                ct5->ct5_ativcr:=tmpct5->ct5_clvldb
             endif   

             // Excecoes
             _vCampos:={'CT5_CREDIT','CT5_DEBITO','CT5_VLR01','CT5_VLR02','CT5_VLR03','CT5_VLR04','CT5_VLR05'}
             if _cOpcao=='610->641'.or._cOpcao=='620->640'
                for _nVezExc:=1 to len(_vCampos)
                    _cCampo:=_vCampos[_nVezExc]                               
                    _cComando:="ct5->"+_cCampo+":=upper(ct5->"+_cCampo+")"
                    _x:=&_cComando
                    _cComando:="ct5->"+_cCampo+":=strtran(ct5->"+_cCampo+",'D2_','D1_')"
                    _x:=&_cComando
                     _cComando:="ct5->"+_cCampo+":=strtran(ct5->"+_cCampo+",'F2_','F1_')"
                    _x:=&_cComando
                    _cComando:="ct5->"+_cCampo+":=strtran(ct5->"+_cCampo+",'SD2','SD1')"
                    _x:=&_cComando
                    _cComando:="ct5->"+_cCampo+":=strtran(ct5->"+_cCampo+",'SF2','SF1')"
                    _x:=&_cComando
                next    
             endif
                
         next      
         ct5->(msunlock())
         tmpct5->(dbskip(1))
      enddo    
      cursorarrow()
   endif
endif            
tmpct5->(dbclosearea())
msgbox("Inversao concluida")

*-----------------------------------------------------------------------------
static function _fReindex() 
*-----------------------------------------------------------------------------
_cAlias:=alias()
u_RsAguarde({||_fReindex1()},'Recriando / reindexando tabelas')
dbselectarea(_cAlias)
static function _fReindex1()
cursorwait()
sx2->(dbgotop())
do while sx2->(!eof())
   _cAliasR:=sx2->x2_chave
   if _cAliasR<>'SX2'.and.six->(dbseek(_cAliasR))
      u_RsProctxt('Recriando / reindexando: '+_cAliasR)
      dbselectarea(_cAliasR)
      if left(_cAliasR,2)<>'SX'
         dbclosearea()
      endif   
   
   endif   
   sx2->(dbskip(1))
enddo
cursorarrow()
return   

*---------------------------------------------------------------
user function _fGatilhos(_cPCampo)
*---------------------------------------------------------------
local _nPosic,_nVez,_cNomCampo:=_cComando:=""
// Caso haja aHeader, cria variaveis de memoria
if valtype(aHeader)=="A"
   for _nVez:=1 to len(aHeader)
       _cNomCampo:=aHeader[_nVez,2]
       _cComando:="M->"+_cNomCampo+":=u__fValAcols(n,'"+_cNomCampo+"')"
       _x:=&_cComando
   next
       
endif
_cPCampo:=upper(_cPCampo)
if posicione('SX3',2,_cPCampo,'x3_trigger')<>'S'
   return
endif

sx7->(dbseek(_cPCampo))
do while sx7->(!eof().and.alltrim(x7_campo)==_cPCampo)
   _nPosic := aScan(aheader,{ |x| UPPER(ALLTRIM(x[2])) == alltrim(sx7->x7_cdomin)}) 
   if _nPosic==0
      _cComando:='M->'+sx7->x7_cdomin+':='+alltrim(sx7->x7_regra)
      //msgbox('Testando: '+sx7->(x7_campo+'-'+x7_sequenc+': '+chr(13)+_cComando))
	  a:=1
	  b:=1
	  _x:=&_cComando
   else
      if sx7->x7_seek=='S'
         _cComando:=sx7->(x7_alias+'->(dbsetorder('+alltrim(str(x7_ordem))+'))')
         _x:=&_cComando
         _cComando:=sx7->(x7_alias+'->(dbseek('+alltrim(x7_chave)+'))')
         _x:=&_cComando
      endif
      //msgbox('Testando: '+_cCampo+' - '+sx7->x7_sequenc)
      aCols[n][_nPosic]:=&(sx7->x7_regra)
      // Atualiza variavel de memoria
      _cComando:='M->'+aHeader[_nPosic][2]+':=aCols[n]['+alltrim(str(_nPosic))+']'
	  _x:=&_cComando
   endif
   sx7->(dbskip(1))
enddo                                   

*-----------------------------------------------------------------------------------------
user function fAnaCred(_cCliente,_cLoja,_nValor)
* Retorna dados sobre o credito disponivel do cliente:
* _vRetorno[1]=Logico, se ha credito disponivel para o valor informado
* _vRetorno[2]=Caracter 2 - Codigo do bloqueio, onde:
*-----------------------------------------------------------------------------------------
local _cBlCred:='',_aEmpenho:={},_nVlrDisp

/* Chamada de MaAvalCred:

 01 - Bloqueio de Credito por Valor
 04 - Vencto do Limite de Credito
 05 - Bloqueio de Credito por Estorno
 06 - Bloqueio de Credito por Risco
 09 - Rejeicao de Credito

Parametros:
----------------------------------------------------------
ExpC1: Codigo do Cliente
ExpC2: Loja do Cliente
ExpN3: Valor a ser avaliado
ExpN4: Moeda do valor a ser avaliado
ExpL5: Considera acumulados de Pedido de Venda do SA1
ExpC6: Codigo do Bloqueio.
ExpC7: aEmpenho
ExpN8: Valor a ser adicionado ao limite de credito
----------------------------------------------------------
Retorna: Logico - Credito (Sim/Nao)
*/

_lTemCred:=MaAvalCred(_cCliente,_cLoja,_nValor,_nMoeda:=1,_lPedido:=.t.,@_cBlCred,@_aEmpenho,@_nVlrDisp)
_vRetorno:={_lTemCred,_cBlCred}

return _vRetorno

*-------------------------------------------------------------
static function _fCtt2Si3()
* Sobrepoe SI3 com os dados de CTT
*-------------------------------------------------------------
local _cPerg:="CttSi3",_lTodas:=.f.,_vEmpJaFoi,aRegs:={}

          *   1    2            3                   4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
          *+------------------------------------------------------------------------------------------------------------------------------------+
          *¦G    ¦ O  ¦ PERGUNT                 ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
          *¦ R   ¦ R  ¦                         ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
          *¦  U  ¦ D  ¦                         ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
          *¦   P ¦ E  ¦                         ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
          *¦    O¦ M  ¦                         ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
AADD(aRegs,{_cPerg,"01","Atualizar Empresa            :","mv_ch1","N",01,0,0,"C","","mv_par01","Corrente"    ,"","","Todas"      ,"","","","","","","","","","",""})

u__fAtuSx1(padr(_cPerg,len(sx1->x1_grupo)),aRegs)

if !pergunte(_cPerg,.t.)
   return
endif   
_lTodas:=(mv_par01==2)
_vAmbSm0:=sm0->(getarea())
_vEmpJaFoi:={}
_vSi3Jafoi:={}
cursorwait()
if _lTodas
   sm0->(dbgotop())
endif
do while sm0->(!eof())
   if ascan(_vEmpJaFoi,sm0->m0_codigo)==0
      aadd(_vEmpJaFoi,sm0->m0_codigo)
      u__fCloseDb("SX2")
      // 1-Compatibiliza X2_MODO
      _cSx2:="SX2"+sm0->m0_codigo+"0"
      dbusearea(.t.,,_cSx2,'SX2',.t.,.f.)
      Sx2->(indregua(alias(),criatrab(,.f.),"X2_arquivo"))
      if Sx2->(!dbseek("CTT",.f.))
         msgbox("Nao foi possivel localizar a chave [CTT] em "+_cSx2+", abandonando o sistema...")
         quit
      else  
         _cCtt:=alltrim(Sx2->x2_arquivo)
         _cModo:=Sx2->x2_modo
         if Sx2->(!dbseek("SI3",.f.))
            msgbox("Nao foi possivel localizar a chave [SI3] em "+_cSx2+", abandonando o sistema...")
            quit
         else
            if Sx2->x2_modo<>_cModo
               if !reclock("SX2",.f.)
                  msgbox("Nao foi possivel travar o registro relativo ao alias SI3 em "+_cSx2)
                  quit
               else
                  Sx2->x2_modo:=_cModo
                  Sx2->(msunlock())
               endif      
            endif
            _cSi3:=alltrim(Sx2->x2_arquivo)
            if ascan(_vSi3Jafoi,_cSi3)==0
               // Se chegou aqui, X2_MODO de SI3 ja eh compativel, este SI3 ainda nao foi atualizado agora eh eliminar os registros
               u__fCloseDb("SI3")
               chkfile("SI3",_lExclusivo:=.t.,_cAliasTmp:="SI3TMP")
               if alias()<>"SI3TMP" 
                  msgbox("Nao foi possivel abrir ["+_cSi3+"] em modo exclusivo, abandonando o sistema...")
                  quit
               else
                  SI3TMP->(dbgotop())
                  do while SI3Tmp->(!eof())   
                     Si3Tmp->(reclock(alias(),.f.))
                     Si3Tmp->(dbdelete())
                     Si3Tmp->(msunlock())
                     Si3Tmp->(dbskip(1))
                  enddo
               endif
               // Agora cria os novos registros em SI3
               chkfile("CTT",_lExclusivo:=.f.,_cAliasTmp:="CTTTMP")      
               CttTmp->(dbgotop())
               do while CttTmp->(!eof())
                  Si3Tmp->(reclock(alias(),.t.))
                  Si3Tmp->i3_filial:=CttTmp->Ctt_filial
                  Si3Tmp->i3_Custo :=CttTmp->Ctt_custo
                  Si3Tmp->i3_Desc  :=CttTmp->Ctt_Desc01
                  Si3Tmp->(msunlock())
                  CttTmp->(Dbskip(1))
               enddo
            endif   
         endif      
      endif   
      u__fCloseDb("SX2")
      u__fCloseDb("SI3TMP")
      u__fCloseDb("CTTTMP")

   endif           
   
   if _lTodas
      sm0->(dbskip(1))
   else
      exit
   endif   
enddo
sm0->(restarea(_vAmbSm0))
cursorarrow()
msgbox("Concluido")
msgbox("Termino normal, abandonando o sistema...")
quit
return

*--------------------------------------------------------------------------------------
user function LESER()
*--------------------------------------------------------------------------------------

private oSerial 
private  oEntDig
private  _nHnd := 0, _lRet := .F., _cText := "", _i

private  _lResult := MSOpenPort(@_nHnd, "COM2:57600,e,8,1,n")
MsRead(_nHnd, @_cText)
/*
While .T.
	For _i:= 1 To 10
		MsRead(_nHnd, @_cText)
		IF !Empty(_cText)
			Exit
		EndIf
		Inkey(.5)
	Next _i

	msgalert(_cText)
	
	IF !Empty(_cText)
		Alert("não leu")
		Exit
	EndIf
//	aAdd(_aPecas, SubStr(_cSerial,1,6) + " - " + SubStr(_cSerial,9,3) + "," + SubStr(_cSerial,12,2) )

		oSerial:Refresh()
	oEntDig:Refresh()
	Close(oEntDig)

	MsClearBuffer(_nHnd)
Enddo
*/

MsClosePort(_nHnd)
_cLe1:=_cText

// 2a leitura

private nHandle := 0
private cRetDll := 0             
private nHdl1   := 0 
private cText   := space(15)                 
private bAcao := {|lFim| LeE_peso(@lFim) }
private cTitulo := 'Lendo Pesagem da Balanca'
private cMsg := 'Peso ... '
private lAborta := .T. 
Private nHdll := 0  
MSOpenPort(nHdll,"COM2:57600,n,8,1") 
cPeso   := space(30)
nPeso   := 0 
xx := MsRead(nHdll,@cText)

/*
if !xx
  msgbox("Nao foi possivel pegar informações da porta",,"STOP")
Else
  nVezes := 0            
  nEstab := 0                
  cPeso  := "00000"  
  Processa( bAcao, cTitulo,cMsg, lAborta )
Endif                                                      
*/  

_cLe2:=cText

msgbox("Leitura 1 : ["+_cLe1+"]"+chr(13)+"Leitura 2 : ["+_cLe2+"] xx: "+IF(XX,'Verdadeiro','Falso') )

*-----------------------------------------------------------------------------------------         
user function FTransmite()
* Ricardo Luiz da Rocha 21/11/2008 GNSJC
* Exporta os dados para a matriz da Polimix
*-----------------------------------------------------------------------------------------         
private aRegs:={},_oDlgTr
private _cPergTr:='_TRans'

          *   1    2            3                   4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
          *+------------------------------------------------------------------------------------------------------------------------------------+
          *¦G    ¦ O  ¦ PERGUNT                 ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
          *¦ R   ¦ R  ¦                         ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
          *¦  U  ¦ D  ¦                         ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
          *¦   P ¦ E  ¦                         ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
          *¦    O¦ M  ¦                         ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
//AADD(aRegs,{_cPergBkp,"01","Path destino (sob ap_data)   :","mv_ch1","C",60,0,0,"G","","mv_par01",""    ,"Transmite\","",""      ,"","","","","","","","","","",""})
AADD(aRegs,{_cPergTr,"01","Tipo de transmissao          :","mv_ch1","N",01,0,0,"N","","mv_par02","Total"    ,"","","Parcial"      ,"","","","","","","","","","",""})

u__fAtuSx1(padr(_cPergTr,len(sx1->x1_grupo)),aRegs)
    
@ 000,000 TO 170,430 DIALOG _oDlgTr TITLE "Exportacao de dados para a Matriz"
@ 008,005 say u__fajtxt(" Esse programa exporta os dados de ambientes TopConnect para DBF,") 
@ 018,005 say u__fajtxt("para posterior envio a matriz")
@ 065,020 BMPBUTTON type 1  ACTION u_RsAguarde({||_fExpTr()},"Exportacao em andamento") 
@ 065,060 BMPBUTTON type 5  ACTION pergunte(_cPergTr,.t.)  // Parametros
@ 065,100 BMPBUTTON type 2  ACTION Close(_oDlgTr) 

ACTIVATE DIALOG _oDlgTr CENTERED

*-----------------------------------------------------------------------------------------         
static function _fExpTr()
*-----------------------------------------------------------------------------------------
local _vTabelas:={},_cNome,_nVez,_cDestino,_cQuebraL:=chr(13)+chr(10)

pergunte(_cPergTr,.f.)
_cPath:='Transmite\'
if empty(_cPath)
   msgbox("O diretorio para exportacao nao pode ficar em branco")
   return
endif
if right(_cPath,1)<>"\"
   _cPath+="\"
endif

if left(_cPath,1)=='\'
   _cPath:=substr(_cPath,2)
endif

// Testa a existencia do diretorio de destino da exportacao
_cNome:=criatrab(,.f.)

dbcreate(_cPath+_cNome,{{'TEST1','C',1,0}})
dbusearea(.t.,'DBFCDX',_cPath+_cNome,'TESTEBKP',.t.,.f.)
if !file(_cPath+_cNome+'.dbf')
   msgbox('O diretorio de destino e invalido')
   return
endif
if alias()<>'TESTEBKP'
   msgbox('O diretorio de destino e invalido (nao foi possivel gravar os dados de teste)')
   return
else
  testebkp->(dbclosearea())
endif
ferase(_cPath+_cNome+'.dbf')

if !file(_cPath+'arj.exe')
   msgbox('O arquivo ARJ.EXE devera estar no diretorio de transmissao, impossivel continuar')
   return
endif

u_RsProcTxt('1a fase, abrindo as tabelas')

// colher as tabelas a exportar
//_cQuery:="select name from sysobjects where xtype='U' and right(rtrim(name),4)<>'_BKP' and left(name,4)<>'TOP_' order by name"
_cQuery:="select name from sysobjects where xtype='U' and right(rtrim(name),4)<>'_BKP' and name<>'dtproperties' and name like '%990%' and left(name,4)<>'TOP_' order by name"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"X_TABELAS",.T.,.T.)

set(11,"OFF")

do while x_tabelas->(!eof())
    _cSqlName:=x_Tabelas->name
    //if _cSqlName$'SA1990;SB1990;SF4990;SD2990;SF2990;SE1990;SC5990;SC6990;SC9990;SE4990;SED990'
    dbusearea(.t.,'TOPCONN',_cSqlName,_cSqlName,.t.,.f.)

    if upper(alltrim(_cSqlName))<>alias()
       msgbox('Nao foi possivel selecionar a tabela '+_cSqlName+' para a exportacao, saindo do sistema')
       quit
    endif
    
    if lastrec()>0
       
       _cDestino:=alltrim("\"+_cPath+_cSqlName)

       u_RsProctxt('Exportando: '+_cSqlName)
    
       copy to &_cDestino
       commit
       if !file(_cDestino+".dbf")
          msgbox("Falha na criacao de: "+_cDestino+', abandonando o sistema.' )
          quit
       endif
    endif   
    dbclosearea()
    x_tabelas->(dbskip(1))
enddo

U_RsProcTxt('Exportacao concluida, iniciando a compactacao dos dados exportados...')
_cNome:='BKMMA_'+dtos(ddatabase)+'__'+strtran(time(),':','_')+'h'
_cBatch:='cd\Mp8\Protheus_data\Transmite'+_cQuebraL
_cBatch+='arj m '+_cNome+' *.* -x*.arj -gmMa1391'+_cQuebraL

memowrit(_cPath+'ftransm.bat',_cBatch)

winexec('c:\Mp8\Protheus_data\Transmite\ftransm.bat')
_nSecIni:=seconds()
do while .t.   
   u_RsProcTxt('Compactando dados ('+alltrim(str(seconds()-_nSecIni))+' segundos )')
   if file('c:\Mp8\Protheus_data\Transmite\'+_cNome+'.arj')
      msgbox('Compactacao concluida, abandonando o sistema...')
      quit
   endif   
enddo

return   


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AliqIcms()³ Autor ³ Juan Jose Pereira     ³ Data ³ 30/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna aliquota de Icms para a Operacao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcos Simidu³26/11/97³11808A³Considerar Tipo cliente na venda.       ³±±
±±³ Marcelo Pime.³22/12/97³13811A³Ajuste na Aliquota de ICMS,qdo.cliente=F³±± 
±±³ Ben-Hur      ³21/01/98³14128A³Ajuste na Aliquota de ICMS,qdo.cliente=F³±±
±±³ Edson   M.   ³27/01/98³xxxxxx³Acerto do Calculo do ICMS,qdo.cliente=F ³±±
±±³ Marcos Simidu³27/04/98³XXXXXX³Desconsiderar tipo cliente F.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user FUNCTION fAliqIcms(	cTpOper,; 	// Tipo de Operacao
					cTpNf,;		// Tipo de Nota ('E'ntrada/'S'aida)
					cTpCliFor,;	// Tipo do Cliente ou Fornecedor
					cTipoAliq,;	// Tipo da Aliquota ("S"olidario/"I"cms)
					nRecOri,;	// Numero do Registro caso seja devolucao
					lCupFis)	// Se eh cupom fiscal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis 					                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nAliquota:=0
Local cEstCliFor:='',cInscr:=''
Local nMV_ICMPAD:=GetMv('MV_ICMPAD')
Local cGpTrib:=SB1->B1_GRTRIB, nPerIcm:=SB1->B1_PICM
Local nMargemLucro:=0
Local aExcecao:={},cGrpCli  
Local lCalcIss:= .F.
Local nNfOri		:= 0		// Posicao da Nf Original
Local nSerOri		:= 0		// Posicao da Serie Original
Local nItemOri		:= 0		// Posicao do Item Original
Local nProdOri		:= 0		// Posicao do Produto Original
Local nAliqFECP		:= 0		// Alíquota FECP
Local lNaoContrib	:= .T.      // Nao-Contribuinte ICMS?

Private cMV_NORTE:=GetMv('MV_NORTE'),cMV_ESTADO:=GetMv('MV_ESTADO')
nRecOri		:= 0		// Define o valor do registro
lCupFis		:= .F.		// Se eh cupom fiscal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca dados do Cliente ou Fornecedor                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTpNf=='S' .and. !(cTpOper$'DB')) .or.;
	(cTpNf=='E' .and. (cTpOper$'DB'))
	cEstCliFor	:=SA1->A1_EST
	cInscr		:=SA1->A1_INSCR
	cTpCliFor  :=IIf(Empty(cTpCliFor),SA1->A1_TIPO,cTpCliFor)
	cGrpCli		:=SA1->A1_GRPTRIB
	lNaoContrib	:= IIf(Empty(SA1->A1_INSCR).Or."ISENT"$SA1->A1_INSCR.Or."RG"$SA1->A1_INSCR.Or.(SA1->(FieldPos("A1_CONTRIB")) > 0 .And. SA1->A1_CONTRIB == "2"),.T.,.F.)
Else
	cEstCliFor	:=SA2->A2_EST
	cInscr		:=SA2->A2_INSCR
	cTpCliFor  :=IIf(Empty(cTpCliFor),SA2->A2_TIPO,cTpCliFor)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo da Margem de Lucro para Icms Retido                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModulo$'FAT/DIS'
	nMargemLucro:=IIF(SC6->C6_PICMRET==0,SB1->B1_PICMRET,SC6->C6_PICMRET) 
Else
	nMargemLucro:=IIf(cTpNF=='S',SB1->B1_PICMRET,0)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Excessoes Fiscais (Somente no SIGAFAT/SIGALOJA/SIGATMK.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTpNf=='S' .and. cModulo $ 'FAT/DIS/LOJ/TMK'
	aExcecao:=ExcecFis(cGpTrib,cGrpCli)
	If aExcecao[7]=="S"
		nMargemLucro:=aExcecao[3]
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca da aliquota de ICMS                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for NF de Devolucao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  cTpOper=='D' .And. nRecOri <> 0 

	Do Case

	Case cTpNf == 'S' 
	
		SD1->(MsGoto(nRecOri))
		nAliquota	:= SD1->D1_PICM
		
	Case cTpNf == 'E'
	
		SD2->(MsGoto(nRecOri))
		nAliquota	:= SD2->D2_PICM

	EndCase		
Else
	While .t.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Para Servicos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!Empty(SB1->B1_CODISS).or. (cModulo$"FAT/DIS" .And. !Empty(SC6->C6_CODISS))) .and. SF4->F4_ISS=='S'
			lCalcIss := .T.
			nAliquota:=If(SB1->B1_ALIQISS>0,SB1->B1_ALIQISS,GetMv("MV_ALIQISS"))
			If (Len(aExcecao) >= 9 .And. !aExcecao[9]=="S") .Or. Len(aExcecao) == 0 //ISS
				Exit
			EndIf
			If aExcecao[7]=="S"
				If cMV_ESTADO==cEstCliFor
					nAliquota:=aExcecao[1]  //Aliq. de ICMS Interna
				Else
					nAliquota:=IIf(aExcecao[8]>0,aExcecao[8],AliqDest(aExcecao,cEstCliFor))  //Aliq. de ICMS Destino
				Endif
			Else
				If cMV_ESTADO<>cEstCliFor
					If ( cTpOper$"DB" )
						nAliquota:=AliqDest(aExcecao,cMV_ESTADO)
					Else
						nAliquota:=AliqDest(aExcecao,cEstCliFor)
					EndIf
				Endif
			Endif
			Exit
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nas Exportacoes,verifica se h  exce‡„o fiscal, se houver, respeita-a, caso³
		//³ contr rio atribui 13% como valor default                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cTpCliFor == "X") .And. (((cTpNF == "S") .And. (cTpOper # "D")) .Or. ((cTpNF == "E") .And. (cTpOper == "D")))
			if len(aExcecao) >=7
				nAliquota := If( aExcecao[7] == "S",aExcecao[1],13) //Aliq. de ICMS Interna
				Exit
			Else
				nAliquota := 13
				Exit
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nas Importacoes       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cTpCliFor == "X") .And. (((cTpNF == "E") .And. (cTpOper # "D")) .Or. ((cTpNF == "S") .And. (cTpOper == "D")))
			nAliquota := If( Empty( nPerICM ),nMV_ICMPAD,nPerICM )
			Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Excessao Fiscal                          ³
		//³ Utilizado pelo SIGAFAT e SIGALOJA.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpNf=="S" .and. cModulo $ "FAT/DIS/LOJ" .and. nMargemLucro>0.and.cTpCliFor=="S".and.cTipoAliq=="S"
			If aExcecao[7]=="S"
				If cMV_ESTADO==cEstCliFor
					nAliquota:=aExcecao[1]  //Aliq. de ICMS Interna
				Else
					nAliquota:=IIf(aExcecao[8]>0,aExcecao[8],AliqDest(aExcecao,cEstCliFor))  //Aliq. de ICMS Destino
				Endif
			Else
				If ( cTpOper$"DB" )
					nAliquota:=AliqDest(aExcecao,cMV_ESTADO)
				Else
					nAliquota:=AliqDest(aExcecao,cEstCliFor)
				EndIf
				If cMV_ESTADO==cEstCliFor.and.nPerIcm>0
					nAliquota:=nPerIcm
				Endif
			Endif
			Exit
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pessoa Fisica         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nota de Saida sem inscr. Estadual ou isento						³
		//³ Nota de Devolucao de Saida e cliente Pessoa Fisica 			³
		//³ Nota de Devolucao de Entrada sem inscr. Estadual ou Isenta ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lCalcIss
			If (cTpNf=='S' .and. (Empty(cInscr).Or."ISENT"$Upper(cInscr))) .or. ;
				(cTpNf=='S' .and. cTpOper=='D'  .and. cTpCliFor =='F') .Or. ;
				(cTpNf=='E' .and. cTpOper=='D'  .and. (Empty(cInscr).Or."ISENT"$Upper(cInscr)))
				If (Empty(cInscr).Or."ISENT"$Upper(cInscr))
					If cTpNF=='S'
						If cModulo == "LOJ"  
							If ( (cTpNf=='S' .and. !(cTpOper$'DB')) .Or. (cTpNf=='E' .and. (cTpOper$'DB')) ) .And. ;
								cMV_ESTADO != cEstCliFor .And. ( !Empty(SA1->A1_INSCR) .And. !("ISENT" $ SA1->A1_INSCR) )
								If cMV_ESTADO $ cMV_NORTE
									nAliquota:=12
								Else
									nAliquota:=IIf( cEstCliFor $ cMV_NORTE , 7 , 12 )
								Endif
							Else     
								nAliquota:=IIf(nPerIcm>0,nPerIcm,nMV_ICMPAD)
							EndIf
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se for NF de Devolucao³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cTpNf=='S' .and. cTpOper=='D'  .and. cTpCliFor =='F')
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica o item na NF para pegar a mesma aliquota de ICMS nas devolucoes³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 			nNfOri		:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
					 			nSerOri		:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
					 			nItemOri	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEMORI"})
								nProdOri	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_COD"})
								If !Empty(aCols[n][nNfOri])
									SD1->(DbSetOrder(1))
									If SD1->(DbSeek(xFilial("SD1")+aCols[n][nNfOri]+aCols[n][nSerOri]+SA2->A2_COD+SA2->A2_LOJA+aCols[n][nProdOri]+aCols[n][nItemOri]))
										nAliquota	:= SD1->D1_PICM
									Endif
								Endif
							EndIf
					 	Else
						 	nAliqFECP := Iif(cMV_ESTADO == "RJ",Iif(SB1->(FieldPos("B1_FECP")) > 0 .And.SB1->B1_FECP > 0,SB1->B1_FECP,1),0)
							nAliquota:=IIf(nPerIcm>0,nPerIcm,nMV_ICMPAD) + nAliqFECP
						EndIf
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Quando for devolucao de vendas a aliquota da entrada deve  ³
						//³ ser igual a aliquota da Sa¡da.                     			³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cTpNf=='E' .and. cTpOper=='D'
							nAliquota := nMV_ICMPAD
						Else
							nAliquota:=If(nPerIcm>0,nPerIcm,AliqDest(aExcecao,cEstCliFor))
						EndIf
					Endif
				Else
					If cTpNf=='E' .and. cTpOper=='D'
						nAliquota := nMV_ICMPAD
					Else
						nAliqFECP := Iif(cMV_ESTADO == "RJ",Iif(SB1->(FieldPos("B1_FECP")) > 0 .And.SB1->B1_FECP > 0,SB1->B1_FECP,1),0)
						nAliquota:=IIf(nPerIcm>0,nPerIcm,nMV_ICMPAD) + nAliqFECP
					EndIf
				Endif
				If cEstCLiFor == cMV_ESTADO
					If ( Len(aExcecao) >= 1 )
						If ( aExcecao[1] ) != 0
							nAliquota := aExcecao[1]  //Aliq. de ICMS Interna
						EndIf	
					EndIf				
				Else
					If ( Len(aExcecao) >= 2 ).And.!(Empty(cInscr).Or."ISENT"$Upper(cInscr))
						If (aExcecao[2]) != 0
							nAliquota := aExcecao[2] //Aliq. de ICMS Externa
						EndIf	
					Else 
						if Len(aExcecao) >0
							If (aExcecao[1]) != 0
								nAliquota := aExcecao[1]  //Aliq. de ICMS Interna
							EndIf
						endif	
					EndIf				
				EndIf
				Exit
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nas Operacoes         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF cModulo $ "FAT/DIS/LOJ" 
			IF cEstCLiFor == cMV_ESTADO
				If Len(aExcecao) >=1
				IF !Empty(aExcecao[1])
					nAliquota := aExcecao[1]  //Aliq. de ICMS Interna
					Exit
				Endif
				Endif
			Else
				If Len(aExcecao) >= 2
				IF !Empty(aExcecao[2])
					nAliquota := aExcecao[2] //Aliq. de ICMS Externa
					Exit
					Endif
				Endif
			Endif
		Endif
		If cEstCliFor==cMV_ESTADO.or.cTipoAliq=='S' .OR. ( cModulo $ 'LOJ' .AND. lNaoContrib ) .OR. lCupFis
			nAliqFECP := Iif(cMV_ESTADO == "RJ",Iif(SB1->(FieldPos("B1_FECP")) > 0 .And.SB1->B1_FECP > 0,SB1->B1_FECP,1),0)
			nAliquota := IIf( nPerIcm > 0 , nPerIcm , nMV_ICMPAD ) + nAliqFECP
		Else
			If (cTpNF=='S' .and. !(cTpOper$'DB')) .or.;
				(cTpNF=='E' .and. cTpOper$'DB')
				If cMV_ESTADO $ cMV_NORTE
					nAliquota:=12
				Else
					nAliquota:=IIf( cEstCliFor $ cMV_NORTE , 7 , 12 )
				Endif
			Else
				If cMV_ESTADO $ cMV_NORTE
					nAliquota:=IIf( cEstCliFor $ cMV_NORTE , 12 , 7)
				Else
					nAliquota:=12
				Endif
			Endif	
		Endif
		Exit
	End
Endif
Return (nAliquota)

*-------------------------------------------------------------------
User function EstTime()
* Retorna a hora da estação
*-------------------------------------------------------------------
_vDir:={getenv("TMP"),getenv("TEMP")}
for _nVez:=1 to len(_vDir)
    _cDir:=_vDir[_nVez]
    _cArq1:=_cDir+'\esttime.txt'
    _cArq2:=_cDir+'\esttime.bat'
    _cComando:="time /t >"+_cArq1
    memowrit(_cArq2,_cComando)
    winexec(_cArq2)
    _cTime:=left(alltrim(memoread(_cArq1)),5)
    if !empty(_cTime)
       exit
    endif
next   

return _cTime

*---------------------------------------------------------------------------------------
User function fEditSx5(_cTabela,_lAltCab,_lDelAll,_lReplFil)
* Manutencao de tabelas do SX5
* _cTabela: Codigo da tabela
* _lAltCab: Se permite alterar a descrição da tabela
* _lDelAll: Se permite eliminar tudo inclusive o cabeçalho da tabela
* _lReplFil: Em caso de SX5 exclusivo, se propaga a manutencao para as demais filiais
*---------------------------------------------------------------------------------------
if _cTabela==nil.or.sx5->(!dbseek(xfilial()+'00'+_cTabela,.f.))
   msgbox("Tabela nao encontrada")
else
  aHeader:={}
  aCols:={}
  
  if _lAltCab==nil
     _lAltCab:=.f.
  endif      
  if _lDelAll==nil
     _lDelAll:=.f.
  endif      
  if _lReplFil==nil
     _lReplFil:=.f.
  endif      
  if _lReplFil
     _vFiliais:={}
     _nRecSm0:=sm0->(recno())
     _cSm0Cod:=sm0->m0_codigo
     sm0->(dbseek(sm0->m0_codigo,.f.))
     do while sm0->(!eof().and.m0_codigo==_cSm0Cod)
        aadd(_vFiliais,sm0->m0_codfil)
        sm0->(dbskip(1))
     enddo
     sm0->(dbgoto(_nRecSm0))
  else
     _vFiliais:={sm0->m0_codfil}
  endif
    
  @ 0,0 to 400,600 dialog _oDlg Title "Manutenção de tabelas"
  
  _cCod   :=sx5->x5_tabela
  _cDescri:=sx5->x5_descri
  @ 08,05 get _cTabela size 30,15 when .f.
  @ 08,35 get _cDescri size 120,15 when _lAltCab
  @ 08,180 button "Salvar" size 35,10 action (fEditSx5a(_cTabela,_vFiliais),close(_oDlg))
  @ 08,220 button "Excluir tudo" size 35,10 action fEditSx5b(_cTabela,_vFiliais) object _oExclTudo
  _oExclTudo:BWhen:={||_lDelAll}
  @ 08,260 button "Sair" size 35,10 action close(_oDlg)

  _vCampos:={"X5_CHAVE","X5_DESCRI","X5_DESCSPA","X5_DESCENG"}
  _vEmptyLin:={}

  sx3->(dbsetorder(2))
  for _nVez:=1 to len(_vCampos)
      _cCampo:=_vCampos[_nVez]

   	sx3->(dbseek(_cCampo,.F.))
	   _cValid:=sx3->x3_valid
	   if _cCampo=="X5_DESCRI"
	      _cValid:="empty( (aCols[N][ascan(aHeader,{|_vAux|alltrim(_vAux[2])='X5_DESCSPA'})]:=u__fValAcols(n,'X5_DESCRI'))+(aCols[N][ascan(aHeader,{|_vAux|alltrim(_vAux[2])='X5_DESCENG'})]:=u__fValAcols(n,'X5_DESCRI')) ).or.1==1"
	   endif

      sx3->(aAdd( aHeader,{x3_Titulo,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,;
      _cValid, X3_USADO,X3_TIPO,x3_f3,X3_CONTEXT,X3_CBOX,x3_relacao,".T.",x3_visual,X3_VLDUSER,X3_PICTVAR}))

      aadd(_vEmptyLin,criavar(_cCampo))
  next

  sx3->(dbsetorder(1))

  aadd(_vEmptyLin,.f.)
  sx5->(dbseek(xfilial()+_cTabela,.f.))
  do while sx5->(!eof().and.x5_tabela==_cTabela)
     sx5->(aadd(aCols,{x5_chave,x5_descri,x5_descspa,x5_desceng,.f.}))
     sx5->(dbskip(1))
  enddo   
  if len(aCols)==0
	  aCols:={aClone(_vEmptyLin)}
  endif	  
  aEmptyAcols:={aClone(aCols)}
  _oGetDad1 := MsNewGetDados():New( 25, 001, 201,301 ,GD_INSERT+GD_UPDATE+GD_DELETE, /*cLinhaOk*/, /*cTudoOk*/,/*cInitCpo*/,/*aCamposAlt*/,/*lVazio*/,99,/*cCampoOk*/,/*Superdel*/,/*cApagaOk*/,_oDlg,aHeader,aCols)
  activate dialog _oDlg Center
endif

return  
   
*---------------------------------------------------------------------------------------
static function fEditSx5a(_cTabela,_vFiliais)
* Atualiza a tabela e se for o caso o cabecalho
*---------------------------------------------------------------------------------------
local _cFilial:="",_nVez,_nVezFil
cursorwait()
aCols:=_oGetDad1:aCols
sx5->(dbsetorder(1))
for _nVezFil:=1 to len(_vFiliais)
    _cFilial:=_vFiliais[_nVezFil]
	if sx5->(dbseek(_cFilial+"00"+_cTabela,.f.))
	   if alltrim(sx5->x5_descri)<>_cDescri
		   do while sx5->(!reclock(alias(),.f.))
		   enddo
	   	sx5->(x5_descri:=x5_descspa:=x5_desceng:=_cDescri)
		   sx5->(msunlock())
		endif   
	else
	   do while sx5->(!reclock(alias(),.t.))
	   enddo
	   sx5->x5_filial:=_cFilial
	   sx5->x5_tabela:='00'
	   sx5->x5_chave:=_cTabela
		sx5->(x5_descri:=x5_descspa:=x5_desceng:=_cDescri)
		sx5->(msunlock())
	
	endif
	// Primeiro trata eventuais exclusoes de itens
	sx5->(dbseek(_cFilial+_cTabela,.f.))
	do while sx5->(!eof().and._cFilial+_cTabela==x5_filial+x5_tabela)
	   _lApaga:=.t.
	   for _nVez:=1 to len(aCols)

	       if sx5->x5_chave==u__fValAcols(_nVez,"X5_CHAVE").and.!aCols[_nVez][len(aCols[1])]
	          _lApaga:=.f.
	          exit
	       endif
	   next       

	   if _lApaga
		   do while sx5->(!reclock(alias(),.f.))
		  	enddo
			sx5->(dbdelete())
			sx5->(msunlock())
		endif
		
		sx5->(dbskip(1))
	enddo   
	// Trata inclusoes e alteracoes
   for _nVez:=1 to len(aCols)                  
       if !aCols[_nVez][len(aCols[1])]
          _cChave:= u__fValAcols(_nVez,"X5_CHAVE")
		    _lExiste:=sx5->(dbseek(_cFilial+_cTabela+_cChave,.f.))
			 do while sx5->(!reclock(alias(),!_lExiste))
		  	 enddo
			 sx5->x5_filial:=_cFilial
			 sx5->x5_tabela:=_cTabela
			 sx5->x5_chave :=_cChave
			 sx5->x5_descri :=u__fValAcols(_nVez,"X5_DESCRI")
			 sx5->x5_descspa:=u__fValAcols(_nVez,"X5_DESCSPA")
			 sx5->x5_desceng:=u__fValAcols(_nVez,"X5_DESCENG")
			 sx5->(msunlock())
      endif
   next       
	
next
cursorarrow()

*---------------------------------------------------------------------------------------
static function fEditSx5b(_cTabela,_vFiliais)
* Elimina a tabela e o cabecalho
*---------------------------------------------------------------------------------------
local _cFilial:="",_nVez
cursorwait()
sx5->(dbsetorder(1))
for _nVez:=1 to len(_vFiliais)
    _cFilial:=_vFiliais[_nVez]
	if sx5->(dbseek(_cFilial+"00"+_cTabela,.f.))
	   do while sx5->(!reclock(alias(),.f.))
	   enddo
	   sx5->(dbdelete())
	   sx5->(msunlock())
	endif
	sx5->(dbseek(_cFilial+_cTabela,.f.))
	do while sx5->(!eof().and._cFilial+_cTabela==x5_filial+x5_tabela)
	   do while sx5->(!reclock(alias(),.f.))
	  	enddo
		sx5->(dbdelete())
		sx5->(msunlock())
		sx5->(dbskip(1))
	enddo   
next
cursorarrow()	
	
*-----------------------------------------------------------------------------------------------------------
Static Function _fB1ToBz()
* Popula o conteúdo corrente de SB1 em SBZ, para os campos existentes, de acordo com a filial corrente
*-----------------------------------------------------------------------------------------------------------

local _oDlg1,aregs:={}

private _cPerg:="FB1tBz"

             *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
             *+---------------------------------------------------------------------------------------------------------------------------------+
             *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
             *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
             *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
             *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
             *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
   AADD(aRegs,{_cPerg,"01","Produto de                   :","mv_ch1","C",60,0,0,"G","","mv_par01",""    ,"","",""      ,"","","","","","","","","","","SB1"})
   AADD(aRegs,{_cPerg,"02","Produto até                  :","mv_ch2","C",60,0,0,"G","","mv_par02",""    ,"","",""      ,"","","","","","","","","","","SB1"})
   AADD(aRegs,{_cPerg,"03","Campos a atualizar           :","mv_ch4","N",01,0,0,"C","","mv_par03","Todos"    ,"","","Codigo e descricao"      ,"","","","","","","","","","",""})
   
u__fAtuSx1(padr(_cPerg,len(sx1->x1_grupo)),aRegs)

@ 0,0 to 195,450 dialog _oDlg1 title "Replicação de SB1 em SBZ"
@ 010,010 say u__fAjTxt("Esta rotina atualiza o cadastro SBZ com os dados de SB1, para a filial corrente ("+cFilAnt+")")
@ 020,010 say u__fAjTxt("conforme o escopo definido nos parâmetros")

@ 060,010 BmpButton Type 1 action u_RsAguarde({||_fB1ToBzA()},"Atualizando indicadores de produto")
@ 060,060 Bmpbutton Type 5 action pergunte(_cPerg,.t.)
@ 060,110 Bmpbutton type 2 action close(_oDlg1)

activate dialog _oDlg1 centered

return

*----------------------------------------------------------------------------------
Static function _fB1ToBzA()
*----------------------------------------------------------------------------------
pergunte(_cPerg,.f.)
                                  
_cProdIni:=mv_par01
_cProdFim:=mv_par02
_lSoCodDes:=(mv_par03==2)

if msgyesno("Confirma o inicio do processamento ?")
	sb1->(dbsetorder(1)) // B1_filial+b1_cod
	sb1->(dbseek(xfilial()+alltrim(_cProdIni),.f.))
	sbz->(dbsetorder(1))
	do while sb1->(!eof().and.b1_filial==xfilial().and.b1_cod<=_cProdFim)
	   if sb1->b1_msblql<>'1' // se não bloqueado
		   u_RsProcTxt("Atualizando dados do produto: "+sb1->(b1_cod+" - "+alltrim(b1_desc)))
		   _lExiste:=sbz->(dbseek(cFilAnt+sb1->b1_cod,.f.))
		   do while sbz->(!reclock(alias(),!_lExiste))
		   enddo
		   for _nVez:=1 to sbz->(fcount())
		       _cCampoBz:=sbz->(fieldname(_nVez))
		       _cCampoB1:="B1_"+substr(_cCampoBz,4)
		       if !_lSoCodDes.or.alltrim(_cCampoB1)$'B1_COD,B1_DESC'
	   	       _cComando:="Sbz->"+_cCampoBz+":=sb1->"+_cCampoB1
		          _x:=&_cComando
		       endif   
		   next
		   sbz->bz_filial:=cFilAnt
		   sbz->(msunlock())
    	endif   
	   sb1->(dbskip(1))
	enddo
	
	msgbox("Processamento concluido")
endif

return	
*-----------------------------------------------------
user function DropEmpty()
* Elimina as tabelas em branco do BD (Sql Server)
*-----------------------------------------------------

_cQuery:="select name from sysobjects where xtype='U' and right(rtrim(name),4)<>'_BKP' and name<>'dtproperties' and left(name,4)<>'TOP_' order by name"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"X_TABELAS",.T.,.T.)

set(11,"OFF")

do while x_tabelas->(!eof())
    _cSqlName:=x_Tabelas->name
    dbusearea(.t.,'TOPCONN',_cSqlName,"_TMP",.t.,.f.)

    if '_TMP'<>alias()
       msgbox('Nao foi possivel selecionar a tabela '+_cSqlName+' , saindo do sistema')
       quit
    endif

    //u_RsProctxt('Exportando: '+_cSqlName)
    _nRecs:=0
    do while _TMP->(!eof())
       _nRecs++
       exit
    enddo
    _Tmp->(dbclosearea())
    if _nRecs==0
       tcsqlexec("drop table "+_cSqlName)
    endif   
    x_Tabelas->(dbskip(1))
enddo    

quit


*------------------------------------------------------------
user function RWrite(_cArq,_cConteudo)
* Cria/Sobrepoe um arquivo com o conteudo informado
*------------------------------------------------------------
local _nHdl,_lSair:=.f.
ferase(_cArq)           
do while !_lSair
	if (_nHdl:=fcreate(_cArq,0))==-1
	   if !msgyesno("Erro na criacao do arquivo ["+_cArq+"], deseja tentar novamente ?")
	       Return .f.
	       _lSair:=.t.
		endif
	else
	   _lSair:=.t.	
	endif
enddo	

Fwrite(_nHdl,_cConteudo)
fClose(_nHdl)
Return .t.

*------------------------------------------------------------------
User function ValFilial(_cFilial,_cNomFil)
* Verifica a existência da filial mencionada na empresa corrente
*------------------------------------------------------------------
local _lReturn:=.f.
_vAmbSm0:=Sm0->(getarea())
Sm0->(dbsetorder(1))
if sm0->(dbseek(cEmpAnt+_cFilial,.f.))
   _cNomFil:=sm0->m0_FILIAL
   _lReturn:=.t.
endif
Sm0->(restarea(_vAmbSm0))

Return _lReturn   
*--------------------------------------------------------------------------------
Static function CopySys(_cMascara,_cPDestino,_lPSobrepoe)
* Baixa o diretorio SYSTEM+mascara para o drive/diretorio destino, 
* com excecao de 
* Exemplo: CopyDir('*.*','c:\Temp\x')
*--------------------------------------------------------------------------------
Private _vConteudo:=Directory(_cMascara),_cDestino:=_cPDestino,_lSobrepoe:=_LpSobrepoe

if right(_cDestino,1)<>"\"
   _cDestino+="\"
endif

processa({|lEnd|_fCopySys()},"Copiando arquivos...")                                       
Return
*------------------------------------------------------------------
static function _fCopySys()
*------------------------------------------------------------------
local _nVez,_cArquivo,_cExt,_nCopiou:=0

ProcRegua(len(_vConteudo))
for _nVez:=1 to len(_vConteudo)
    if lEnd
       exit
    endif
    _lCopiou:=.f.
    _cArquivo:=alltrim(_vConteudo[_nVez,1])
    
    _cDest:=_cDestino+_cArquivo
    _cExt:=lower(substr(_cArquivo,at(".",_cArquivo)))
    if left(_cArquivo,2)=='sc'.or.left(_cExt,2)==".#".or._cExt$".log,.cdx,.ind,.tmp,.lck,.txt,.old,.rpo"
	else                                         
	   if !file(_cDest).or._lSobrepoe
		   incproc("Copiando: "+_cArquivo)
    		if __CopyFile(_cArquivo,_cDest)
	    		_lCopiou:=.t.
    			_nCopiou++
    		endif
     	endif	
    endif
    if !_lCopiou
		incproc("Ignorado: "+_cArquivo)
	endif
next

alert("Concluido, "+alltrim(str(_nCopiou))+" arquivo(s) copiado(s)")

Return

*------------------------------------------------------------------
User function StrToVet(_cConteudo,_cSepara)
* Transforma a string em um vetor, com base no separador informado
*------------------------------------------------------------------
local _vReturn:={},_nVez,_cLido,_cCampo:=''

for _nVez:=1 to len(_cConteudo)
    _cLido:=substr(_cConteudo,_nVez,1)
    if _cLido==_cSepara.or._nVez==len(_cConteudo)
       aadd(_vReturn,_cCampo)
       _cCampo:=''
    else
       _cCampo+=_cLido
    endif
next          

Return _vReturn	
