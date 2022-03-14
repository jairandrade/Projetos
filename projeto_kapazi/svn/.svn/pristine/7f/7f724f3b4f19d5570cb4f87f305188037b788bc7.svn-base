#DEFINE CRLF Chr(13)+Chr(10)

User Function FMSGCLI 
    Local xA1_MSGPED := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,'A1_MSGPED')                           

    if Empty(Alltrim(xA1_MSGPED))
        return Alltrim(M->C5_MSGCLI)
    elseif AT(Alltrim(xA1_MSGPED),  Alltrim(M->C5_MSGCLI)) > 0 
        return Alltrim(M->C5_MSGCLI)
    end if
    
    return Alltrim(xA1_MSGPED + CRLF + M->C5_MSGCLI)
     
User Function FMSGNOTA 
    Local xA1_MSGPED := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,'A1_MSGPED')                           

    if Empty(Alltrim(xA1_MSGPED))
        return AllTrim(M->C5_MSGNOTA)
    elseif AT(Alltrim(xA1_MSGPED),  Alltrim(M->C5_MSGNOTA)) > 0 
        return AllTrim(M->C5_MSGNOTA)
    end if
    
    return Alltrim(xA1_MSGPED + CRLF + M->C5_MSGNOTA)
                   