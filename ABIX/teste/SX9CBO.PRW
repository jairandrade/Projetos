#include "Totvs.Ch"
#define STR0001 "Atencion"
#define STR0002 "Este proceso debe ser realizado GRUPO DE EMPRESAS."
#define STR0003 "Quieres eliminar la relacion entre os campos RA_CBO (CBO Empleado) e RJ_CBO (CBO Funciones)?"
#define STR0004 "Relacion borrada com exito!"
#define STR0005 "Borrando relacion en diccionario SX9 (Relaciones)..."

/*/{Protheus.doc} SX9CBO
Funcao responsavel por executar o processo de exclusao do relacionamento entre os campos RA_CBO (CBO do Funcionario) e RJ_CBO (CBO na Funcao)
@author raquel.andrade
@since 04/08/2021
@version P12
@return lMsErroAuto, logic, retorna resultado da operação
/*/
User Function SX9CBO()
Private lMsErroAuto := .F.


If MsgYesNo( OemToAnsi( STR0002 + CRLF +  CRLF + STR0003), OemToAnsi( STR0001 ) )

    MsAguarde({|| MSExecAuto( {|| u_DelRel() }) },OemToAnsi( STR0005 ) ) 

    If lMsErroAuto
        MostraErro()
    Else
        MsgInfo(OemToAnsi( STR0004 ), OemToAnsi( STR0001 ))
    EndIf

EndIf

Return !lMsErroAuto


/*/{Protheus.doc} DelRel
Função responsável por excluir relacionamentos indevidos gerados no SX9.
@author raquel.andrade
@since 04/08/2021
@version P12
@return lRet, logic, retorna resultado da operação
/*/
User Function DelRel()
Local aArea     := GetArea()
Local lRet		:= .F.

    DbSelectArea("SX9")
    DbSetOrder(2) //X9_CDOM + X9_DOM

	If SX9->(DbSeek("SRASRJ"))
		While AllTrim(SX9->X9_DOM) == "SRJ" .And. AllTrim(SX9->X9_CDOM) == "SRA" .And. !lRet
			If AllTrim(SX9->X9_EXPDOM) == "RJ_CBO" .And. AllTrim(SX9->X9_EXPCDOM) == "RA_CBO" 
				RecLock( "SX9" , .F. )
			    SX9->( dbDelete() )
				lRet	:= .T.
			    MsUnLock()
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf
    
    RestArea(aArea)   
 
Return lRet
