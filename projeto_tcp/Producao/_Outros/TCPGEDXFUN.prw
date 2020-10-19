#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCPGEDREP
Replica o anexo de uma entidade para outra
@author  Kaique Mathias
@since   16/07/20
@version 1.0
/*/
//-------------------------------------------------------------------

User Function TCPGEDREP( cEntidade, cFilEnt, cCodEnt, cCodNewEnt )

    Local aArea := GetArea()
    Local cAliasQry := GetNextAlias()
    Default cCodNewEnt := U_TCPGEDENT( cEntidade )[1]
    
    AC9->( dbSetOrder( 2 ) )

    BeginSql Alias cAliasQry
        SELECT AC9.* 
        FROM %table:AC9% AC9
        WHERE   AC9.AC9_FILIAL = %xFilial:AC9% AND
                AC9.AC9_FILENT = %exp:cFilEnt% AND
                AC9.AC9_ENTIDA = %exp:cEntidade% AND
                AC9.AC9_CODENT = %exp:cCodEnt% AND
                AC9.%NotDel%
    EndSql

	While !( cAliasQry )->( Eof() )
       lGravou := .T.
		RecLock( "AC9", .T. ) 
        AC9->AC9_FILIAL := xFilial( "AC9" )
        AC9->AC9_FILENT := cFilEnt
        AC9->AC9_ENTIDA := cEntidade
        AC9->AC9_CODENT := cCodNewEnt
        AC9->AC9_CODOBJ := (cAliasQry)->AC9_CODOBJ
        AC9->AC9_XUSER  := (cAliasQry)->AC9_XUSER
        AC9->AC9_XDATA  := STOD((cAliasQry)->AC9_XDATA)
        MsUnlock()
        (cAliasQry)->(dbSkip())
    EndDo

Return( Nil )
