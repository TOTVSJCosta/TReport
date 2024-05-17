#include "Totvs.ch"
#include "FWMVCDef.ch"
#INCLUDE "Topconn.CH"
#INCLUDE "report.CH"

user Function funcao01(cPar1)
    RPCSetEnv("99","01")
    local oBrowse := FWLoadBrw("arqFonte01")

    oBrowse:SetAlias("SC5")
    oBrowse:SetDescription("Pedidos de Venda")
    oBrowse:DisableDetails()
    //oBrowse:SetMenuDef("ARQFONTE01")
    oBrowse:SetOnlyFields({"C5_NUM", "C5_CLIENTE", "C5_LOJACLI", "C5_EMISSAO", "C5_CONDPAG"})

    oBrowse:AddLegend("C5_TIPOCLI == 'R'", "GREEN", "Revendedor")
    oBrowse:AddLegend({|| C5_TIPOCLI == 'F'}, "ORANGE", "Cons. Final")
    //oBrowse:SetFilterDefault("C5_TIPO == 'N'")
    oBrowse:AddButton("Importar pedidos de venda", {||IncPV()},, MODEL_OPERATION_INSERT)
    oBrowse:AddButton("Imprimir", {||u_tReport_SQL()},, MODEL_OPERATION_VIEW)

    oDlg := BrwDlg()

    oBrowse:Activate(oDlg)
    Activate MsDialog oDlg Centered

Return lRet

static function PrintPV()
    local oSect1 AS Object
    local oReport AS Object

    /*aAdd(aPergs, {1, "Produto De", xPar0,  "", ".T.", "SB1", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Produto Até", xPar1,  "", ".T.", "SB1", ".T.", 80,  .T.})
      
    //Se a pergunta for confirma, cria as definicoes do relatorio
    If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
        oReport := fReportDef()
          
        //Se usar esse comando, ele mostra a tela para selecionar, arquivo, spool, planilha, etc
        //oReport:PrintDialog()
  
        //Já o trecho abaixo, já gera o arquivo pdf em uma pasta
        //  O relatório será gerado em %temp%/totvsprinter
        oReport:nDevice  := 6 // 6 = PDF
        oReport:cFile    := "produtos_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
        oReport:lPreview := .F.
        oReport:lViewPDF := .F.
        oReport:Print()
    EndIf*/
    
    oReport := TReport():New("AdvplAdv" , "Advpl Avancado" ,, {|oReport| PrintReport(oReport)} , "Treinamento Asddvpl Avan" ,;
     .t. , '<uTotalText>' , .t./*<lTotalInLine>*/ , '<cPageTText>' , .t./*<lPageTInLine>*/ , .t./*<lTPageBreak>*/ , 50 )

    oSect1 := TRSection():New(oReport,'Pedidos de Venda', {"SC5"})

    TRCell():New(oSect1, "C5_EMISSAO" , "SC5", "EMISSAO", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| DDATABASE -7 }*/)
    TRCell():New(oSect1, "C5_NUM" , "SC5", "NO. PEDIDO", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| 'code-block de impressao' }*/)
    TRCell():New(oSect1, "C5_TIPO", "SC5", "TIPO" , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSect1, "C5_CLIENTE" , "SC5", "CLIENTE"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSect1, "C5_LOJA" , "SC5", "LOJA"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New(oSect1, "C5_CONDPAG" , "SC5", "COND.PAGTO"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

    oReport:PrintDialog()

    //oReport:lPreview := .F.
    //    oReport:lViewPDF := .F.
        //oReport:Print()
return

static function PrintReport(oReport)
/*
    cAlias := cAlias

    BEGIN REPORT QUERY oSect1 //oReport:Section(1)

        BeginSql alias cAlias
            SELECT C5_EMISSAO,C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_CONDPAG
            FROM %table:SC5% 
            WHERE C5_FILIAL = %XFILIAL:SC5% AND %NOTDEL%
            ORDER BY C5_FILIAL,C5_NUM
        EndSql

    END REPORT QUERY oSect1 

    local nTotal := 0

    oSectDad := oReport:Section(1)

    DbSelectArea("SC5")
    Count to nTotal
    oReport:SetMeter(nTotal)
    SC5->(dbSetOrder(1))
    SC5->(dbGoTop())


    While !Eof()
      
        //Incrementando a regua
        nAtual:=10
        oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        oReport:IncMeter()
          
        //Imprimindo a linha atual
        oSectDad:PrintLine()
          
        DbSkip()
    EndDo
    oSectDad:Finish()*/
    Local oSection := oReport:Section(1)
Local cPart := ""

oSection:BeginQuery()

	cPart := "% AND A1_COD >= '" + MV_PAR01 + "' "
	cPart += "  AND A1_COD <= '" + MV_PAR02 + "' %"
  
BeginSql alias "QRYSA1"

	SELECT C5_EMISSAO,C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_CONDPAG
            FROM %table:SC5% 
            WHERE C5_FILIAL = %XFILIAL:SC5% AND %NOTDEL%
            ORDER BY C5_FILIAL,C5_NUM
EndSql

aRetSql := GetLastQuery()
oSection:EndQuery()
oSection:Print()

return



static function IncPV(aParams)
    default aParams := {"99", "01"}

    local aLinha, cFile := cGetFile()
    local aCab, aItens, aSC6
    local oFile := FWFileReader():New(cFile)

    If (oFile:Open())
        BEGIN TRANSACTION
            While oFile:HasLine()
                aLinha := if(empty(aLinha), separa(oFile:GetLine(), ';'), aLinha)

                if aLinha[1] == 'SC5'
                    aCab := {}
                    aAdd(aCab, {"C5_NUM",  aLinha[2], nil})
                    aAdd(aCab, {"C5_TIPO", aLinha[3], nil})
                    aAdd(aCab, {"C5_CLIENTE", aLinha[4], nil})
                    aAdd(aCab, {"C5_LOJACLI", aLinha[5], nil})
                    aAdd(aCab, {"C5_CONDPAG", aLinha[6], nil})
                    aLinha := {}
                else
                    aSC6 := {}
                    aItens := if(empty(aItens), Array(0), aItens)

                    aAdd(aSC6, {"C6_PRODUTO", '00001' , nil})
                    aAdd(aSC6, {"C6_QTDVEN", 5.0 , nil})
                    aAdd(aSC6, {"C6_PRUNIT", 6.0 , nil})
                    aAdd(aSC6, {"C6_TES", '501' , nil})
                    aadd(aItens,aSC6)
                    aSC6 := {}

                    While oFile:HasLine()
                        aLinha := separa(oFile:GetLine(), ';')
                        if aLinha[1] == 'SC5'
                            exit
                        endif
                        aAdd(aSC6, {"C6_PRODUTO", '00001' , nil})
                        aAdd(aSC6, {"C6_QTDVEN", 5.0 , nil})
                        aAdd(aSC6, {"C6_PRUNIT", 6.0 , nil})
                        aAdd(aSC6, {"C6_TES", '501' , nil})
                        aadd(aItens,aSC6)
                        aSC6 := {}
                    end
                    lMsErroAuto := .F.

                    MSExecAuto({|a,b,c,d| MATA410(a,b,c,d)}, aCab, aItens, MODEL_OPERATION_INSERT)
                    if lMsErroAuto
                        MostraErro()
                        DisarmTransaction()
                    else
                        alert("sucesso")
                    endif
                endif
            EndDo
            oFile:Close()
        END TRANSACTION
    else
        msgstop(cvaltochar(ferror()))
    endif

/*
    local aCab :={  {"B1_COD" ,     "199945" ,                  NIL},;
                    {"B1_DESC" ,    "TESt ROTINA AUTOMATICA" ,  NIL},;
                    {"B1_TIPO" ,    "PA" ,                      Nil},;
                    {"B1_UM" ,      "PC" ,                      Nil},;
                    {"B1_LOCPAD" ,  "01" ,                      Nil}}

    RPCSetEnv(aParams[1], aParams[2])

    BEGIN TRANSACTION
        if SB1->(RecLock("SB1", .t.,,, .t.))
            SB1->B1_FILIAL   := FWxFilial("SB1")
            SB1->B1_COD      := "PRD" + strtran(time(), ':')
            SB1->B1_DESC     := "ROTINA RECLOCK: " + dtoc(date()) + ' - ' + time()
            SB1->B1_TIPO     := "MO"
            SB1->B1_UM       := "UN"
            SB1->B1_LOCPAD   := "09"
            SB1->B1_MSBLQL   := '1'
            SB1->(MSUnlock())
            
            SB5->(dbSetOrder(1))
            SB5->(RecLock("SB5", !dbSeek(xFilial("SB5") + SB1->B1_COD)))
                SB5->B5_FILIAL   := FWxFilial("SB5")
                SB5->B5_COD      := SB1->B1_COD
                SB5->B5_CEME     := "ROTINA RECLOCK: " + dtoc(date()) + ' - ' + time()
            SB5->(MSUnlock())
        else
            FWLogMsg("WARN",, "IncProd" ,,,, "nao foi possivel bloquear registro")
            alert("nao foi possivel bloquear registro")
            DisarmTransaction()
        endif
    END TRANSACTION
*/
/*
    lMsErroAuto := .F.

    MSExecAuto({|x,y| Mata010(x,y)}, aCab, MODEL_OPERATION_INSERT)

    if lMsErroAuto
        MostraErro()
        DisarmTransaction()
    else
        alert("sucesso")
    endif*/
    //RPCClearEnv()
return

static function _IncProd()
    local lOk := .t., aLinha, cFile := cGetFile()
    local oFile := FWFileReader():New(cFile)


    FT_FUSE(cFile)
    FT_FGoTop()

    BEGIN TRANSACTION
        While oFile:HasLine()
                 
            //Buscando o texto da linha atual
            aLinha := separa(oFile:GetLine(), ';')

            if lOK
                lOk := u_ProdMVC({aLinha[1], aLinha[2], aLinha[3], aLinha[4]})
            else
                DisarmTransaction()
                exit
            endif
        EndDo
        oFile:Close()
/*
        while !FT_FEOF()
            aLinha := separa(FT_FReadLn(), ';')

            if lOK
                lOk := u_ProdMVC({aLinha[1], aLinha[2], aLinha[3], aLinha[4]})
            else
                DisarmTransaction()
                exit
            endif
            FT_FSkip()
        end
        FT_FUSE()
*/
    END TRANSACTION
return

static function ModelDef()
    local oModel := MPFormModel():New("MYID001")
    local aStruSC5 := FWFormStruct(1, "SC5")
    local aStruSC6 := FWFormStruct(1, "SC6")
    local aStruSE1 := FWFormStruct(1, "SE1")

    oModel:AddFields("SC5MASTER",, aStruSC5)
    oModel:AddGrid("SC6DETAIL", "SC5MASTER", aStruSC6, /*< bLinePre >, < bLinePost >, < bPre >, < bPost >, < bLoad >*/)
    oModel:AddGrid("SE1DETAIL", "SC5MASTER", aStruSE1, /*< bLinePre >, < bLinePost >, < bPre >, < bPost >, < bLoad >*/)

    oModel:SetRelation("SC6DETAIL",;
        { { 'C6_FILIAL', 'xFilial("SC6")' }, { 'C6_NUM', 'C5_NUM' } }, SC6->( IndexKey( 1 ) ) )
    oModel:SetRelation("SE1DETAIL",;
        { { 'E1_FILIAL', 'xFilial("SE1")' }, { 'E1_CLIENTE', 'C5_CLIENTE' }, { 'E1_LOJA', 'C5_LOJACLI' } }, SE1->( IndexKey( 2 ) ) )

return oModel

static function ViewDef()
    local oModel := ModelDef()
    local aStruSC5 := FWFormStruct(2, "SC5")
    local aStruSC6 := FWFormStruct(2, "SC6")
    local aStruSE1 := FWFormStruct(2, "SE1")
    local oView := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_SC5", aStruSC5, "SC5MASTER")
    oView:AddGrid("VIEW_SC6", aStruSC6, "SC6DETAIL")
    oView:AddGrid("VIEW_SE1", aStruSE1, "SE1DETAIL")

    oView:CreateHorizontalBox("TELA_SC5", 40)
    oView:CreateHorizontalBox("INFERIOR", 60)

    oView:CreateVerticalBox( 'INFESQ', 70, 'INFERIOR' )
    oView:CreateVerticalBox( 'INFDIR', 30, 'INFERIOR' )

    oView:SetOwnerView("VIEW_SC5", "TELA_SC5")
    oView:SetOwnerView("VIEW_SC6", "INFESQ")
    oView:SetOwnerView("VIEW_SE1", "INFDIR")

    oView:EnableTitleView("VIEW_SC6")
    oView:EnableTitleView("VIEW_SE1", "Títulos em aberto")

return oView

static function MenuDef()
    local aRotinas := {}

    ADD OPTION aRotinas TITLE "Incluir" ACTION "VIEWDEF.ARQFONTE01" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotinas TITLE "Alterar" ACTION "VIEWDEF.ARQFONTE01" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotinas TITLE "Visualizar" ACTION "VIEWDEF.ARQFONTE01" OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotinas TITLE "Pesquisar" ACTION "PesqBrw" OPERATION 2 ACCESS 0
    ADD OPTION aRotinas TITLE "Onde é usado" ACTION "u_whereUse()" OPERATION 2 ACCESS 0

return aRotinas             //FWMVCMenu("arqfonte01")

user function whereUsed
    local aCampos1, aCampos2, cQuery, nRes
    local oTbl1 := FWTemporaryTable():New(GetNextAlias())
    local oTbl2 := FWTemporaryTable():New(GetNextAlias())

    RPCSetEnv("99", "01")

    aCampos1 := {;
        {"OK"       , "C", 2, 0 },;
        {"pedido",  "C", 6, 0},;
        {"cliente",  "C", 6, 0},;
        {"loja",    "C", 2,  0},;
        {"cdpg", "C", 3,  0},;
        {"emissao",  "D", 8,  0},;
        {"totalB",  "N", 12,  2};
    }
    aCampos2 := {;
        {"pedido",      "C", 6, 0},;
        {"item",      "C", 3, 0},;
        {"produto",   "C", 10, 0},;
        {"qtd",        "N", 12,  2},;
        {"preco",  "N", 12,  2},;
        {"total",  "N", 12,  2},;
        {"TES", "C", 3,  0};
    }
    
    oTbl1:SetFields(aCampos1)
    oTbl2:SetFields(aCampos2)

    oTbl1:Create()
    oTbl2:Create()

    cQuery := " INSERT INTO " + oTbl1:GetRealName()
    cQuery += " (pedido,cliente,loja,cdpg,emissao,totalB) values"
    cQuery += " ('100000','000001','01','000','20240517',1589.25)"

    nRes   := TCSQLExec(cQuery)
    calias := oTbl1:GetAlias()

    RecLock((calias), .t.)
        (calias)->pedido := '100001'
    (calias)->( MsUNlock() )

    (calias)->( dbgotop() )

    aCols := {}
    aAdd(aCols, {"Num. Pedido",    "pedido", "C", 6})
    aAdd(aCols, {"Cliente", "cliente", "C", 6})
    aAdd(aCols, {"Loja", "loja", "C", 2})
    aAdd(aCols, {"Cond.Pagto", "cdpg", "C", 3})
    aAdd(aCols, {"Emissão", "emissao", "D", 8})
    aAdd(aCols, {"Total Bruto", "totalB", "N", 12, 2})

    oDlg := BrwDlg()

    oBrowse := FWLoadBrw("arqFonte01")
    oBrowse:SetTemporary(.T.)
    oBrowse:SetAlias((calias))
    oBrowse:SetDescription('Pedidos de Vendas')
    oBrowse:DisableReport(.t.)
    oBrowse:SetFieldMark( 'OK' )
    oBrowse:AddButton("Processar", {||Processar()},, MODEL_OPERATION_INSERT)
    oBrowse:SetFields(aCols)

    oBrowse:Activate(oDlg)

    //oDlg:Activate(,,,.t.)
    Activate MsDialog oDlg Centered


/*
    while (calias)->(!eof())
    
    RecLock((calias), .f.)

        msgInfo( str((calias)->totalB), 'InfoTmp' )
        (calias)->( dbDelete() )


        (calias)->( dbskip() )
    end
*/
    oTbl1:Delete()
    oTbl2:Delete()
return

static function BrwDlg()

    Local oDlg  // := MSDialog():New(,,600,800,'',,,,,CLR_RED,CLR_WHITE,,,.T.)

    DEFINE MSDIALOG oDlg TITLE "Exemplo MSDialog"  FROM 0, 0 TO 600, 960 PIXEL

return oDlg

static function Processar()
    msgstop('iniciando')
return

static function BrowseDef()
    local oBrowse := FWMarkBrowse():New()
    oBrowse:SetDescription("Generico")
    oBrowse:DisableDetails()
return oBrowse



#include "Totvs.ch"
#include "FWMVCDef.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "Topconn.CH"
//#include "tlpp-core.th"

user function funcao02()
    local oBrowse := FWLoadBrw("arqFonte01")

    oBrowse:SetAlias("SAH")
    oBrowse:SetDescription("Unidades de Medidas")
    oBrowse:DisableDetails()
    oBrowse:SetMenuDef("ARQFONTE02")
    //oBrowse:SetOnlyFields({"AH_UNIMED", "AH_UMRES", "AH_DESCPO"})

    oBrowse:AddLegend("AH_UNIMED != 'PC' .AND. AH_UNIMED != 'AR'", "GRAY", "OUTRAS UNIDADES")
    oBrowse:AddLegend("AH_UNIMED == 'AR'", "OK", "Arroba")
    oBrowse:AddLegend({|| AH_UNIMED == 'PC'}, "ORANGE", "Peça")
    //oBrowse:SetFilterDefault("left(AH_UNIMED, 1) == 'S'")

    oBrowse:Activate()
return

// Ponto de entrada filtrar colunas borwse cadastro de produtos
User Function MT010VCP

Return {"B1_COD", "B1_DESC", "B1_UM", "B1_LOCPAD"}

// ponto de entrada cadastro de produtos MVC
User Function ITEM()
    //local oModel := PARAMIXB[1]
    local cID := PARAMIXB[2]
    local xRet := .t.

    if cID == "BUTTONBAR"
        // Adicionar botao cadastro de produtos
        xRet := {{"Importarr produtos", "XX", {|| IncProd()}}}
    endif
    //Help( ,, 'Help_0001',, 'Preço unitário não informado.', 1, 0 )

Return xRet

static function IncProd()
    local lOk := .t., aLinha, cFile := cGetFile()
    local oFile := FWFileReader():New(cFile)

    If (oFile:Open())
        //FT_FUSE(cFile)
        //FT_FGoTop()

        BEGIN TRANSACTION
            While oFile:HasLine()
                aLinha := separa(oFile:GetLine(), ';')

                if lOK
                    lOk := u_ProdMVC({aLinha[1], aLinha[2], aLinha[3], aLinha[4]})
                else
                    DisarmTransaction()
                    exit
                endif
            EndDo
            oFile:Close()
    /*
            while !FT_FEOF()
                aLinha := separa(FT_FReadLn(), ';')

                if lOK
                    lOk := u_ProdMVC({aLinha[1], aLinha[2], aLinha[3], aLinha[4]})
                else
                    DisarmTransaction()
                    exit
                endif
                FT_FSkip()
            end
            FT_FUSE()
    */
        END TRANSACTION
    else
        msgstop(cvaltochar(ferror()))
    endif
return
//rotina automatica em MVC 
user function ProdMVC(aData)
    local oModel, lRet := .t.

    //RPCSetEnv("99", "01", "admin", "1")

    oModel := FWLoadModel("MATA010")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    
    oModel:SetValue("SB1MASTER", "B1_COD", "PRD-" + strtran(time(), ':'))

    FWFldPut("B1_DESC",     alltrim(aData[1]))
    FWFldPut("B1_TIPO",     alltrim(aData[2]))
    FWFldPut("B1_UM",       alltrim(aData[3]))
    FWFldPut("B1_LOCPAD",   alltrim(aData[4]))
    FWFldPut("B1_MSBLQL",   '1')

    if oModel:VldData()
        if oModel:CommitData()
            msgInfo("Sucesso", "Sucesso")
        else
            aErro := oModel:GetErrorMessage()
            lRet := .f.
        endif
    else
        aErro := oModel:GetErrorMessage()
        lRet := .f.
    endif
    oModel:DeActivate()
return lRet

static function MenuDef(); return FWMVCMenu("ARQFONTE02")

user function _MY_ID_SAH
    local xRet := .F.
    //local oModel := PARAMIXB[1]
    local cID := PARAMIXB[2]

    DO CASE
        CASE cID == "FORMCANCEL"
            alert("Cancelamento de cadastro nao autorizado!")
            xRet := .F.
        
        CASE cID == "MODELPOS"
            xRet := .F.

        CASE cID == "BUTTONBAR"
            xRet := {{"Btn Cust 002", "SAVE", {|| Folder3()}, "Botão customizado via PE"}}

        OTHERWISE
            xRet := .T.
    END CASE

return xRet

static function ModelDef()
    local oModel := MPFormModel():New("MY_ID_SAH")
    local aStruSAH := FWFormStruct(1, "SAH")

    oModel:AddFields("SAHMASTER",, aStruSAH)

return oModel


static function ViewDef()
    local oModel := FWLoadModel("ARQFONTE02")
    local aStruSAH := FWFormStruct(2, "SAH")
    local oView := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_SAH", aStruSAH, "SAHMASTER")

    oView:CreateHorizontalBox("TelaSAH", 100)
    oView:SetOwnerView("VIEW_SAH", "TelaSAH")

    oView:AddUserButton("Botão Customizado", 'LOK', {|oView| Folder3(oView) } )

return oView

static function Folder3(oView)

return


user function CCSE1VLR0()
    //local cAlias := GetNextAlias()
    //local cSQL
    local aLinha

    rpcsetenv("99", "01")

    FT_FUSE("data/sb19901.csv")
    FT_FGoTop()

    while !FT_FEOF()
        aLinha := separa(FT_FReadLn(), ',')

        //RecLock("SB1", .f.)
        //SB1->B1_DESC := upper(lower(SB1->B1_DESC))
        //SB1->(MsUNlock())

        FT_FSkip()
    end
    FT_FUSE()


/*
    cSQL := "SELECT SB1.R_E_C_N_O_ RECNO FROM " + RetSqlName("SB1") + " SB1 "
    cSQL += "WHERE B1_FILIAL = '" + XFILIAL("SB1") + "' AND D_E_L_E_T_ = ' ' ORDER BY B1_FILIAL,B1_COD"
    cSQL := ChangeQuery(cSQL)

    dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSQL), (cAlias), .f., .t.)

    while (cAlias)->(!eof())
        SB1->(dbGoTo((cAlias)->RECNO))

        RecLock("SB1", .f.)
        SB1->B1_DESC := upper(lower(SB1->B1_DESC))
        SB1->(MsUNlock())

        (cAlias)->(dbSkip())
    end
    (cAlias)->(dbCloseArea())
*/

return
