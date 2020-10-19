

#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
USER FUNCTION AGPE0001()
    PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "CN9" MODULO "SIGAGCT"
        U_AGPE001A()
    RESET ENVIRONMENT
RETURN


USER FUNCTION AGPE002()
    PREPARE ENVIRONMENT EMPRESA '03' FILIAL '01' TABLES "CN9" MODULO "SIGAGCT"
        U_AGPE001A()
    RESET ENVIRONMENT
RETURN

//Atualiza senhas portal
USER FUNCTION AGPE001A(cFiltro)

    DBSelectArea('RD0')
    RD0->(DBSetOrder(1))
    RD0->(DbGoTop())

    if !EMPTY(cFiltro)
        RD0->(DBSeek(cFiltro))
    ENDIF 

    WHILE (RD0->(!EOF()))

        DBSelectArea('SRA')
        SRA->(DBSetOrder(5))
        IF(SRA->(DbSeek(xFilial('SRA')+RD0->RD0_CIC)) )

            //4Digitos - ddmm ADMISSÃO
            cNewSenha := SUBSTRING(DTOS(SRA->RA_ADMISSA),7,2)+SUBSTRING(DTOS(SRA->RA_ADMISSA),5,2)
            //3 digitos nome da mãe
            cNewSenha += SUBSTRING(ALLTRIM(Lower(SRA->RA_MAE)),1,3)
            //3 digitos nome da mãe
            cNewSenha += SUBSTRING(ALLTRIM(DTOS(SRA->RA_NASC)),1,4)
            RecLock("RD0",.F.)
            RD0->RD0_SENHA := embaralha(cNewSenha,0)
            RD0->(MsUnlock())

        ENDIF

        RD0->(DbSkip())
    enddo
RETURN
