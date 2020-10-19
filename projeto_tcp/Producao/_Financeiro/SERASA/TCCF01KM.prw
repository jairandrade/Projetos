#include "protheus.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} TCCF01KM
Job responsavel por processar os numeros de notas fiscais x titulos
@type  User Function
@author Kaique Sousa
@since 17/09/2019
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
/*/
User Function TCCF01KM()
    
    Private _lJob := IsBlind()
    
    if _lJob 
        PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" FUNNAME Alltrim(FunName()) //TABLES "SA1","SA2","SA3"
    EndIf
    
    ExecuteSP()
    
    If _lJob
        //RpcClearEnv()
        RESET ENVIRONMENT
    EndIf

Return( Nil )

Static Function ExecuteSP()
     
    Local cProcName         := "SP_NFVSTIT" 
    Local aResult           := {}
    Local nDias             := 30
    
    If !TCSPExist(cProcName)
        If !_lJob
            Aviso("Aviso","Stored Procedure "+cProcName+" não localizada.",{"Sair"},,"Atenção:",,"BMPPERG") 
       
        Endif

    Else
        aResult := TCSPEXEC(cProcName,;
                            (MsDate()-nDias),;
                            '')
    EndIf

Return( Nil )