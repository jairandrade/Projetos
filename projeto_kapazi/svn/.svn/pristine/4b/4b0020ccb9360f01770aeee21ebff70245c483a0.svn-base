#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: KP97PRPA		|	Autor: Luis Paulo							|	Data: 07/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio  DA planilha para supplier							//
//																									//
//==================================================================================================//
User Function KP97PRPA()
Local 	_cDir 		:= "\Supplier\Alt PV\" //GetSrvProfString("Startpath","")
Private _cDirTmp	:= ""

_cDirTmp := ALLTRIM(cGetFile("Salvar em?|*|",'Salvar em?', 0,'c:\Temp\', .T., GETF_OVERWRITEPROMPT + GETF_LOCALHARD + GETF_RETDIRECTORY,.T.))

If	!Empty(_cDirTmp)
	If __CopyFile( ( (_cDir) + Alltrim(cNmArq)), _cDirTmp + Alltrim(cNmArq) )
			//oExcelApp := MsExcel():New()
			//oExcelApp:WorkBooks:Open( _cDirTmp + cArq )
			//oExcelApp:SetVisible(.T.)
			MsgInfo( "Arquivo copiado com sucesso!" )
		Else
			MsgInfo( "Arquivo não copiado para temporário do usuário." )
	EndIf
EndIf
	
Return()