/**********************************************************************************************************************************/
/** user function RELMDIS                                                                                                        **/
/** Relatorio de medidas aplicadas.                						                                                         **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 16/08/2016     						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function RELMDIS

    private oReport := nil
    // variavel do relatorio
    private oSection := nil
    private oSection1 := nil      
    private oSection2 := nil
    // grupo de pergunta
    private cPerg      := "RELMDIS"


    // processa perguntas
    criaSX1(cPerg)

    Pergunte(cPerg, .F.)
    // cria o relatorio                                                                                                              
    oReport := GerRelDef(cPerg)

    // exibe tela de parametros
    oReport:PrintDialog()

return 

/**********************************************************************************************************************************/
/** static function GerRelDef()                                                                                                  **/
/** definição dos objetos do relatório                                                                                           **/
/**********************************************************************************************************************************/
static function GerRelDef(cPerg)

    // define o relatório
    oReport := TReport():New("RELMDIS", "Relatório Medidas Aplicadas", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime dados sobre medidas disciplinares aplicadas a colaboradores do TCP.")
    oReport:cFontBody := 'Courier New'
    oReport:nFontBody := 8

    // define a seção principal
    oSection := TRSection():New(oReport, "Medidas Aplicadas", {},,,,,,.T.,,,,,,,,,,,,)  
    
    TRCell():New(oSection,"FILIAL"            , nil, "Filial"              ,"@!",  2)
    TRCell():New(oSection,"MATRICULA"         , nil, "Matricula "          ,"@!",  6)
    TRCell():New(oSection,"NOME"              , nil, "Nome "               ,"@!", 30)
    TRCell():New(oSection,"CC"                , nil, "C.Custo"             ,"@!",  9)  
    TRCell():New(oSection,"CCDESC"            , nil, "Desc. Centro"        ,"@!",  30)  
    //TRCell():New(oSection,"MOTIVO"            , nil, "Motivo"              ,"@!",  3)
    TRCell():New(oSection,"DSMOTIVO"          , nil, "Desc. Motivo"        ,"@!", 30)
    TRCell():New(oSection,"DATA"              , nil, "Data"                ,"@!", 10) 
    TRCell():New(oSection,"OCORRENCIA"        , nil, "Ocorrência"          ,"@!", 10)
    TRCell():New(oSection,"HISTORICO"         , nil, "Histórico"           ,"@!", 20) 


return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
static function GerRelExe()

    oSection:Init() 

    ZP3QRY()
    ZP3QRY->(DbGoTop())
    While (!ZP3QRY->(Eof()))
        
        
        oSection:Cell("FILIAL")       :SetValue(ZP3QRY->FILIAL)     
        oSection:Cell("MATRICULA")    :SetValue(ZP3QRY->MATRICULA) 
        oSection:Cell("NOME")         :SetValue(ZP3QRY->NOME) 
        oSection:Cell("CC")           :SetValue(ZP3QRY->CENTRO)
        oSection:Cell("CCDESC")       :SetValue(Alltrim(ZP3QRY->DESCCC))
        //oSection:Cell("MOTIVO")       :SetValue(ZP3QRY->MOTIVO)
        oSection:Cell("DSMOTIVO")     :SetValue(ZP3QRY->DSMOT)
        oSection:Cell("DATA")         :SetValue(SUBSTR(ZP3QRY->DATAE,7,2)+'/'+SUBSTR(ZP3QRY->DATAE,5,2)+'/'+SUBSTR(ZP3QRY->DATAE,1,4)) 
        
        cDescri := ""
        aCombo := RetSX3Box(GetSX3Cache("ZP3_OCORRE", "X3_CBOX"),,,1)
        nPos := aScan(aCombo,{|x| Alltrim(Left(x[1],3)) == ZP3QRY->OCORRENCIA })
        cDescri := aCombo[nPos][3]
        
        oSection:Cell("OCORRENCIA")   :SetValue(cDescri)
        oSection:Cell("HISTORICO")    :SetValue(ZP3QRY->HISTORICO) 

        oSection:PrintLine() 
        
        ZP3QRY->(dbSkip())    
        
    EndDo                 

    ZP3QRY->(dbCloseArea())     
        
    oSection:Finish()

Return( Nil )


/**********************************************************************************************************************************/
/** static function ZP3QRY                                                                                                       **/
/** restaura as informações de afastamento                                                                                       **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/ 
static Function ZP3QRY
  	
    local aArea := GetArea()
    Local nFor,i 
	local cQry  := "" 

    cQry  := "select ZP3.ZP3_FILIAL FILIAL, ZP3.ZP3_MATR MATRICULA, RA2.RA_NOME NOME,ZP3.ZP3_CC CENTRO,CTT.CTT_DESC01 DESCCC, ZP3.ZP3_MOTIVO MOTIVO,ZP1.ZP1_DESCRI DSMOT, ZP3.ZP3_DATA DATAE, ZP3.ZP3_OCORRE OCORRENCIA, ZP3.ZP3_STATUS STATUS, "
    cQry  += " ISNULL(CAST(CAST(ZP3_HISTOR AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS HISTORICO "
    cQry  += " from "+ RetSqlName("ZP3") +" ZP3, "+ RetSqlName("SRA") +" RA2, "+ RetSqlName("CTT") +" CTT ,"+ RetSqlName("ZP1") +" ZP1"
    cQry  += " Where ZP3.D_E_L_E_T_ <> '*'"
    cQry  += " and RA2.RA_FILIAL = ZP3.ZP3_FILIAL"
    cQry  += " and RA2.RA_MAT    = ZP3.ZP3_MATR"
    cQry  += " and CTT.CTT_CUSTO = ZP3.ZP3_CC" 
    cQry  += " and ZP3.ZP3_MOTIVO = ZP1.ZP1_CODIGO"
    cQry  += " and CTT.CTT_FILIAL = ZP3.ZP3_FILIAL"
    cQry  += " and ZP3.ZP3_DATA between   '"+DtoS(mv_par07)+"' and '"+DtoS(mv_par08)+"'"  
    cQry  += " and ZP3.ZP3_CC between     '"+AllTrim(mv_par05)+"' and '"+AllTrim(mv_par06)+"'" 
    cQry  += " and ZP3.ZP3_MATR between   '"+AllTrim(mv_par03)+"' and '"+AllTrim(mv_par04)+"'"
    cQry  += " and ZP3.ZP3_FILIAL between '"+AllTrim(mv_par01)+"' and '"+AllTrim(mv_par02)+"'"
    cQry  += " and ZP3.ZP3_MOTIVO between '"+AllTrim(mv_par09)+"' and '"+AllTrim(mv_par10)+"'"
    
    cOcorr := ""

    for nFor := 1 to len(Alltrim(mv_par11)) step 3
        If Subs(mv_par11,nFor,3) <> '***'
            cOcorr += "'" + Subs(mv_par11,nFor,3) + "',"
        EndIf
    next nFor
    
    cOcorr := SubStr(cOcorr,1,len(cOcorr)-1)

    If !Empty(cOcorr)
        cQry  += " and ZP3.ZP3_OCORRE IN ( " + cOcorr + " )
    EndIf

    cStatus := ""

    for i := 1 to len(Alltrim(mv_par12))
        If Subs(mv_par12,i,1) <> '*'
            cStatus += "'" + Subs(mv_par12,i,1) + "',"
        EndIf
    Next i

    cStatus := SubStr(cStatus,1,len(cStatus)-1)

    If !Empty(cStatus)
        cQry  += " and ZP3.ZP3_STATUS IN ( " + cStatus + " )
    EndIf

    TcQuery cQry New Alias "ZP3QRY"
     
	// restaura area
	RestArea(aArea)   

return( Nil )

/**********************************************************************************************************************************/
/** static function criaSX1                                                                                                      **/
/** cria perguntas.											                                                                     **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
static function criaSX1(cPerg)

    u_xPutSx1(cPerg,"01","Filial de?"             ,"Filial de?"       ,"Filial de?"          ,"mv_ch1"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."   ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"02","Filial até?"            ,"Filial até?"      ,"Filial até?"         ,"mv_ch2"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"03","Matricula de?"          ,"Matricula de?"    ,"Matricula de?"       ,"mv_ch3"  ,"C" ,6,0,0,"G","","SRA","","","mv_par03","","","","","","","","","","","","","","","","",{"Matricula de."    ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"04","Matricula até?"         ,"Matricula até?"   ,"Matricula até?"      ,"mv_ch4"  ,"C" ,6,0,0,"G","","SRA","","","mv_par04","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"05","Centro de?"             ,"Centro de?"       ,"Centro de?"          ,"mv_ch5"  ,"C" ,9,0,0,"G","","CTT","","","mv_par05","","","","","","","","","","","","","","","","",{"Centro de."       ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"06","Centro até?"            ,"Centro até?"      ,"Centro até?"         ,"mv_ch6"  ,"C" ,9,0,0,"G","","CTT","","","mv_par06","","","","","","","","","","","","","","","","",{"Centro até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"07","Data de?"               ,"Data de?"         ,"Data de?"            ,"mv_ch7"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{"Data de."         ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"08","Data até?"              ,"Data até?"        ,"Data até?"           ,"mv_ch8"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{"Data até."        ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"09","Motivo de?"             ,"Motivo de?"       ,"Motivo de?"          ,"mv_ch9"  ,"C" ,3,0,0,"G","","ZP1","","","mv_par09","","","","","","","","","","","","","","","","",{"Motivo de."       ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"10","Motivo até?"            ,"Motivo até?"      ,"Motivo até?"         ,"mv_cha"  ,"C" ,3,0,0,"G","","ZP1","","","mv_par10","","","","","","","","","","","","","","","","",{"Motivo até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"11","Ocorrências?"           ,"Ocorrências?"     ,"Ocorrências?"        ,"mv_chb"  ,"C" ,99,0,0,"G","U_MDISOCORR","   ","","","mv_par11","","","","","","","","","","","","","","","","",{"Ocorrências"      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"12","Status ?"               ,"Status?"          ,"Status?"             ,"mv_chc"  ,"C" ,3,0,0,"G","U_MDISSTAT","   ","","","mv_par12","","","","","","","","","","","","","","","","",{"Status"           ,"","",""},{"","","",""},{"","",""},"")                                                                                                                                                  

return( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MDISOCORR
description Seleciona as ocorrências das medidas disciplinares 
@author  Kaique Sousa
@since   05/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User function MDISOCORR()
    
    Local MvParDef:= ""	
	Local MvPar	  := ""
    Local i,nFor
	Private aOcorr:= StrToKarr(getSX3Cache("ZP3_OCORRE","X3_CBOX"),";")

    MvPar:=&(Alltrim(ReadVar()))
    mvRet:=Alltrim(ReadVar())
	
    for i := 1 to len(aOcorr)
        MvParDef += left(aOcorr[i],3)
    next i
    
    mvRetor := ""
    
    If f_Opcoes(@MvPar,"Ocorrências",aOcorr,MvParDef,12,49,.f.,3)   // Chama funcao f_Opcoes
		For nFor := 1 To Len( mVpar ) Step 3
            IF ( SubStr( MvPar , nFor , 3 ) # "***" )
                mvRetor += SubStr( mVpar , nFor , 3 ) //+ ";"
            Endif
        Next nFor
        If( Empty(mvRetor) )
            mvRetor := Space(99)
        EndIf                       
        &MvRet 	:= mvRetor
    EndIF

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MDISSTAT
description Seleciona os status das medidas disciplinares 
@author  Kaique Sousa
@since   05/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function MDISSTAT()

    Local MvParDef  := ""
	Local MvPar	    := ""
    Local i
	Private aStatus := StrToKarr(getSX3Cache("ZP3_STATUS","X3_CBOX"),";")

    MvPar:=&(Alltrim(ReadVar()))
    mvRet:=Alltrim(ReadVar())
	
    for i := 1 to len(aStatus)
        MvParDef += left(aStatus[i],1)
    next i

    IF f_Opcoes(@MvPar,"Status",aStatus,MvParDef,12,49,.f.)   // Chama funcao f_Opcoes
		&MvRet := MvPar 
	EndIF 

Return( Nil )