Attribute VB_Name = "Mod_General"
'Argentum Online 0.11.6
'
'Copyright (C) 2002 M�rquez Pablo Ignacio
'Copyright (C) 2002 Otto Perez
'Copyright (C) 2002 Aaron Perkins
'Copyright (C) 2002 Mat�as Fernando Peque�o
'
'This program is free software; you can redistribute it and/or modify
'it under the terms of the Affero General Public License;
'either version 1 of the License, or any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'Affero General Public License for more details.
'
'You should have received a copy of the Affero General Public License
'along with this program; if not, you can find it at http://www.affero.org/oagpl.html
'
'Argentum Online is based on Baronsoft's VB6 Online RPG
'You can contact the original creator of ORE at aaron@baronsoft.com
'for more information about ORE please visit http://www.baronsoft.com/
'
'
'You can contact me at:
'morgolock@speedy.com.ar
'www.geocities.com/gmorgolock
'Calle 3 n�mero 983 piso 7 dto A
'La Plata - Pcia, Buenos Aires - Republica Argentina
'C�digo Postal 1900
'Pablo Ignacio M�rquez

Option Explicit

Public Type tServers
    Item As String
    server As String
    Puerto As Long
    mapa As String
    Ping As String
    pjs As String
End Type

Public iplst As String

Public bFogata As Boolean

Public bLluvia() As Byte ' Array para determinar si
'debemos mostrar la animacion de la lluvia

Private lFrameTimer As Long

Public Function DirGraficos() As String
    DirGraficos = App.path & "\" & Config_Inicio.DirGraficos & "\"
End Function

Public Function DirSound() As String
    DirSound = App.path & "\" & Config_Inicio.DirSonidos & "\"
End Function

Public Function DirMidi() As String
    DirMidi = App.path & "\" & Config_Inicio.DirMusica & "\"
End Function

Public Function DirMapas() As String
    DirMapas = App.path & "\" & Config_Inicio.DirMapas & "\"
End Function

Public Function RandomNumber(ByVal LowerBound As Long, ByVal UpperBound As Long) As Long
    'Initialize randomizer
    Randomize Timer
    
    'Generate random number
    RandomNumber = (UpperBound - LowerBound) * Rnd + LowerBound
End Function

Sub CargarAnimArmas()
On Error Resume Next

    Dim loopc As Long
    Dim arch As String
    
    arch = App.path & "\init\" & "armas.dat"
    
    NumWeaponAnims = Val(GetVar(arch, "INIT", "NumArmas"))
    
    ReDim WeaponAnimData(1 To NumWeaponAnims) As WeaponAnimData
    
    For loopc = 1 To NumWeaponAnims
        InitGrh WeaponAnimData(loopc).WeaponWalk(1), Val(GetVar(arch, "ARMA" & loopc, "Dir1")), 0
        InitGrh WeaponAnimData(loopc).WeaponWalk(2), Val(GetVar(arch, "ARMA" & loopc, "Dir2")), 0
        InitGrh WeaponAnimData(loopc).WeaponWalk(3), Val(GetVar(arch, "ARMA" & loopc, "Dir3")), 0
        InitGrh WeaponAnimData(loopc).WeaponWalk(4), Val(GetVar(arch, "ARMA" & loopc, "Dir4")), 0
    Next loopc
End Sub

Sub CargarVersiones()
On Error GoTo errorH:

    Versiones(1) = Val(GetVar(App.path & "\init\" & "versiones.ini", "Graficos", "Val"))
    Versiones(2) = Val(GetVar(App.path & "\init\" & "versiones.ini", "Wavs", "Val"))
    Versiones(3) = Val(GetVar(App.path & "\init\" & "versiones.ini", "Midis", "Val"))
    Versiones(4) = Val(GetVar(App.path & "\init\" & "versiones.ini", "Init", "Val"))
    Versiones(5) = Val(GetVar(App.path & "\init\" & "versiones.ini", "Mapas", "Val"))
    Versiones(6) = Val(GetVar(App.path & "\init\" & "versiones.ini", "E", "Val"))
    Versiones(7) = Val(GetVar(App.path & "\init\" & "versiones.ini", "O", "Val"))
Exit Sub

errorH:
    Call MsgBox("Error cargando versiones")
End Sub

Sub CargarColores()
On Error Resume Next
    Dim archivoC As String
    
    archivoC = App.path & "\init\colores.dat"
    
    If Not FileExist(archivoC, vbArchive) Then
'TODO : Si hay que reinstalar, porque no cierra???
        Call MsgBox("ERROR: no se ha podido cargar los colores. Falta el archivo colores.dat, reinstale el juego", vbCritical + vbOKOnly)
        Exit Sub
    End If
    
    Dim i As Long
    
    For i = 0 To 48 '49 y 50 reservados para ciudadano y criminal
        ColoresPJ(i).r = CByte(GetVar(archivoC, CStr(i), "R"))
        ColoresPJ(i).g = CByte(GetVar(archivoC, CStr(i), "G"))
        ColoresPJ(i).b = CByte(GetVar(archivoC, CStr(i), "B"))
    Next i
    
    ColoresPJ(50).r = 255
    ColoresPJ(50).g = 0
    ColoresPJ(50).b = 0
    ColoresPJ(49).r = 0
    ColoresPJ(49).g = 128
    ColoresPJ(49).b = 255
End Sub

#If SeguridadAlkon Then
Sub InitMI()
    Dim alternativos As Integer
    Dim CualMITemp As Integer
    
    alternativos = RandomNumber(1, 7368)
    CualMITemp = RandomNumber(1, 1233)
    

    Set MI(CualMITemp) = New clsManagerInvisibles
    Call MI(CualMITemp).Inicializar(alternativos, 10000)
    
    If CualMI <> 0 Then
        Call MI(CualMITemp).CopyFrom(MI(CualMI))
        Set MI(CualMI) = Nothing
    End If
    CualMI = CualMITemp
End Sub
#End If

Sub CargarAnimEscudos()
On Error Resume Next

    Dim loopc As Long
    Dim arch As String
    
    arch = App.path & "\init\" & "escudos.dat"
    
    NumEscudosAnims = Val(GetVar(arch, "INIT", "NumEscudos"))
    
    ReDim ShieldAnimData(1 To NumEscudosAnims) As ShieldAnimData
    
    For loopc = 1 To NumEscudosAnims
        InitGrh ShieldAnimData(loopc).ShieldWalk(1), Val(GetVar(arch, "ESC" & loopc, "Dir1")), 0
        InitGrh ShieldAnimData(loopc).ShieldWalk(2), Val(GetVar(arch, "ESC" & loopc, "Dir2")), 0
        InitGrh ShieldAnimData(loopc).ShieldWalk(3), Val(GetVar(arch, "ESC" & loopc, "Dir3")), 0
        InitGrh ShieldAnimData(loopc).ShieldWalk(4), Val(GetVar(arch, "ESC" & loopc, "Dir4")), 0
    Next loopc
End Sub

Sub AddtoRichTextBox(ByRef RichTextBox As RichTextBox, ByVal Text As String, Optional ByVal red As Integer = -1, Optional ByVal green As Integer, Optional ByVal blue As Integer, Optional ByVal bold As Boolean = False, Optional ByVal italic As Boolean = False, Optional ByVal bCrLf As Boolean = False)
'******************************************
'Adds text to a Richtext box at the bottom.
'Automatically scrolls to new text.
'Text box MUST be multiline and have a 3D
'apperance!
'Pablo (ToxicWaste) 01/26/2007 : Now the list refeshes properly.
'Juan Mart�n Sotuyo Dodero (Maraxus) 03/29/2007 : Replaced ToxicWaste's code for extra performance.
'******************************************r
    With RichTextBox
        If Len(.Text) > 1000 Then
            'Get rid of first line
            .SelStart = InStr(1, .Text, vbCrLf) + 1
            .SelLength = Len(.Text) - .SelStart + 2
            .TextRTF = .SelRTF
        End If
        
        .SelStart = Len(RichTextBox.Text)
        .SelLength = 0
        .SelBold = bold
        .SelItalic = italic
        
        If Not red = -1 Then .SelColor = RGB(red, green, blue)
        
        .SelText = IIf(bCrLf, Text, Text & vbCrLf)
        
        RichTextBox.Refresh
    End With
End Sub

'TODO : Never was sure this is really necessary....
'TODO : 08/03/2006 - (AlejoLp) Esto hay que volarlo...
Public Sub RefreshAllChars()
'*****************************************************************
'Goes through the charlist and replots all the characters on the map
'Used to make sure everyone is visible
'*****************************************************************
    Dim loopc As Long
    
    For loopc = 1 To LastChar
        If charlist(loopc).Active = 1 Then
            MapData(charlist(loopc).Pos.x, charlist(loopc).Pos.y).CharIndex = loopc
        End If
    Next loopc
End Sub

Sub SaveGameini()
    'Grabamos los datos del usuario en el Game.ini
    Config_Inicio.Name = "BetaTester"
    Config_Inicio.Password = "DammLamers"
    Config_Inicio.Puerto = UserPort
    
    Call EscribirGameIni(Config_Inicio)
End Sub

Function AsciiValidos(ByVal cad As String) As Boolean
    Dim car As Byte
    Dim i As Long
    
    cad = LCase$(cad)
    
    For i = 1 To Len(cad)
        car = Asc(mid$(cad, i, 1))
        
        If ((car < 97 Or car > 122) Or car = Asc("�")) And (car <> 255) And (car <> 32) Then
            Exit Function
        End If
    Next i
    
    AsciiValidos = True
End Function

Function CheckUserData(ByVal checkemail As Boolean) As Boolean
    'Validamos los datos del user
    Dim loopc As Long
    Dim CharAscii As Integer
    
    If checkemail And UserEmail = "" Then
        MsgBox ("Direcci�n de email invalida")
        Exit Function
    End If
    
    If UserPassword = "" Then
        MsgBox ("Ingrese un password.")
        Exit Function
    End If
    
    For loopc = 1 To Len(UserPassword)
        CharAscii = Asc(mid$(UserPassword, loopc, 1))
        If Not LegalCharacter(CharAscii) Then
            MsgBox ("Password inv�lido. El caract�r " & Chr$(CharAscii) & " no est� permitido.")
            Exit Function
        End If
    Next loopc
    
    If UserName = "" Then
        MsgBox ("Ingrese un nombre de personaje.")
        Exit Function
    End If
    
    If Len(UserName) > 30 Then
        MsgBox ("El nombre debe tener menos de 30 letras.")
        Exit Function
    End If
    
    For loopc = 1 To Len(UserName)
        CharAscii = Asc(mid$(UserName, loopc, 1))
        If Not LegalCharacter(CharAscii) Then
            MsgBox ("Nombre inv�lido. El caract�r " & Chr$(CharAscii) & " no est� permitido.")
            Exit Function
        End If
    Next loopc
    
    CheckUserData = True
End Function

Sub UnloadAllForms()
On Error Resume Next

#If SeguridadAlkon Then
    Call UnprotectForm
#End If

    Dim mifrm As Form
    
    For Each mifrm In Forms
        Unload mifrm
    Next
End Sub

Function LegalCharacter(ByVal KeyAscii As Integer) As Boolean
'*****************************************************************
'Only allow characters that are Win 95 filename compatible
'*****************************************************************
    'if backspace allow
    If KeyAscii = 8 Then
        LegalCharacter = True
        Exit Function
    End If
    
    'Only allow space, numbers, letters and special characters
    If KeyAscii < 32 Or KeyAscii = 44 Then
        Exit Function
    End If
    
    If KeyAscii > 126 Then
        Exit Function
    End If
    
    'Check for bad special characters in between
    If KeyAscii = 34 Or KeyAscii = 42 Or KeyAscii = 47 Or KeyAscii = 58 Or KeyAscii = 60 Or KeyAscii = 62 Or KeyAscii = 63 Or KeyAscii = 92 Or KeyAscii = 124 Then
        Exit Function
    End If
    
    'else everything is cool
    LegalCharacter = True
End Function

Sub SetConnected()
'*****************************************************************
'Sets the client to "Connect" mode
'*****************************************************************
    'Set Connected
    Connected = True
    
    Call SaveGameini
    
#If SeguridadAlkon Then
    'Unprotect character creation form
    Call UnprotectForm
#End If
    
    'Unload the connect form
    Unload frmConnect

    
    frmMain.Label8.Caption = UserName
    'Load main form
    frmMain.Visible = True
    frmMain.pri = True
    renderasd = True
    
    Call SetMusicInfo("Jugando Arduz AO: " & UserName & " - http://ao.noicoder.com/", "", "", "Games", , "{0}")
#If SeguridadAlkon Then
    'Protect the main form
    Call ProtectForm(frmMain)
#End If

End Sub


Sub MoveTo(ByVal direccion As E_Heading)
'***************************************************
'Author: Alejandro Santos (AlejoLp)
'Last Modify Date: 06/28/2008
'Last Modified By: Lucas Tavolaro Ortiz (Tavo)
' 06/03/2006: AlejoLp - Elimine las funciones Move[NSWE] y las converti a esta
' 12/08/2007: Tavo    - Si el usuario esta paralizado no se puede mover.
' 06/28/2008: NicoNZ - Saqu� lo que imped�a que si el usuario estaba paralizado se ejecute el sub.
'***************************************************
    Dim LegalOk As Boolean
    
    If Cartel Then Cartel = False
    
    Select Case direccion
        Case E_Heading.NORTH
            LegalOk = LegalPos(UserPos.x, UserPos.y - 1)
        Case E_Heading.EAST
            LegalOk = LegalPos(UserPos.x + 1, UserPos.y)
        Case E_Heading.SOUTH
            LegalOk = LegalPos(UserPos.x, UserPos.y + 1)
        Case E_Heading.WEST
            LegalOk = LegalPos(UserPos.x - 1, UserPos.y)
    End Select
    
    If LegalOk And Not UserParalizado Then
        Call WriteWalk(direccion)
        If Not UserDescansar And Not UserMeditar Then
            MoveCharbyHead UserCharIndex, direccion
            MoveScreen direccion
        End If
    Else
        If charlist(UserCharIndex).Heading <> direccion Then
            Call WriteChangeHeading(direccion)
        End If
    End If
    
    
    ' Update 3D sounds!
    'Call Audio.MoveListener(UserPos.X, UserPos.y)
End Sub

Sub RandomMove()
'***************************************************
'Author: Alejandro Santos (AlejoLp)
'Last Modify Date: 06/03/2006
' 06/03/2006: AlejoLp - Ahora utiliza la funcion MoveTo
'***************************************************
    Call MoveTo(RandomNumber(NORTH, WEST))
End Sub

Sub CheckKeys()
'*****************************************************************
'Checks keys and respond
'*****************************************************************
On Error Resume Next
    Static lastMovement As Long
    
    'No input allowed while Argentum is not the active window
    If Not Application.IsAppActive() Then Exit Sub
    
    'No walking when in commerce or banking.
    If Comerciando Then Exit Sub
    
    'No walking while writting in the forum.
    'If frmForo.Visible Then Exit Sub
    
    'If game is paused, abort movement.
    If pausa Then Exit Sub
    
    'Control movement interval (this enforces the 1 step loss when meditating / resting client-side)
    If GetTickCount - lastMovement > 56 Then
        lastMovement = GetTickCount
    Else
        Exit Sub
    End If
    
    'Don't allow any these keys during movement..
    If UserMoving = 0 Then
        If Not UserEstupido Then
            'Move Up
            If GetKeyState(vbKeyUp) < 0 Then

                Call MoveTo(NORTH)
                'frmMain.Coord.Caption = "(" & UserMap & "," & UserPos.X & "," & UserPos.Y & ")"
                Exit Sub
            End If
            
            'Move Right
            If GetKeyState(vbKeyRight) < 0 Then

                Call MoveTo(EAST)
                'frmMain.Coord.Caption = "(" & UserMap & "," & UserPos.X & "," & UserPos.Y & ")"
                Exit Sub
            End If
        
            'Move down
            If GetKeyState(vbKeyDown) < 0 Then

                Call MoveTo(SOUTH)
                'frmMain.Coord.Caption = "(" & UserMap & "," & UserPos.X & "," & UserPos.Y & ")"
                Exit Sub
            End If
        
            'Move left
            If GetKeyState(vbKeyLeft) < 0 Then

                Call MoveTo(WEST)
                'frmMain.Coord.Caption = "(" & UserMap & "," & UserPos.X & "," & UserPos.Y & ")"
                Exit Sub
            End If
            
            ' We haven't moved - Update 3D sounds!
            'Call Audio.MoveListener(UserPos.X, UserPos.y)
        Else
            Dim kp As Boolean
            kp = (GetKeyState(vbKeyUp) < 0) Or _
                GetKeyState(vbKeyRight) < 0 Or _
                GetKeyState(vbKeyDown) < 0 Or _
                GetKeyState(vbKeyLeft) < 0
            If kp Then
                Call RandomMove
            End If
            

            'frmMain.Coord.Caption = "(" & UserPos.X & "," & UserPos.Y & ")"
        End If
    End If
End Sub

'TODO : Si bien nunca estuvo all�, el mapa es algo independiente o a lo sumo dependiente del engine, no va ac�!!!
Sub SwitchMap(ByVal map As Integer)
'**************************************************************
'Formato de mapas optimizado para reducir el espacio que ocupan.
'Dise�ado y creado por Juan Mart�n Sotuyo Dodero (Maraxus) (juansotuyo@hotmail.com)
'**************************************************************
    Dim y As Long
    Dim x As Long
    Dim tempint As Integer
    Dim ByFlags As Byte
    Dim handle As Integer
    
    handle = FreeFile()
    
    Open DirMapas & "Mapa" & map & ".map" For Binary As handle
    Seek handle, 1
            
    'map Header
    Get handle, , MapInfo.MapVersion
    Get handle, , MiCabecera
    Get handle, , tempint
    Get handle, , tempint
    Get handle, , tempint
    Get handle, , tempint
    
    'Load arrays
    For y = YMinMapSize To YMaxMapSize
        For x = XMinMapSize To XMaxMapSize
            Get handle, , ByFlags
            
            MapData(x, y).Blocked = (ByFlags And 1)
            
            Get handle, , MapData(x, y).Graphic(1).GrhIndex
            InitGrh MapData(x, y).Graphic(1), MapData(x, y).Graphic(1).GrhIndex
            
            'Layer 2 used?
            If ByFlags And 2 Then
                Get handle, , MapData(x, y).Graphic(2).GrhIndex
                InitGrh MapData(x, y).Graphic(2), MapData(x, y).Graphic(2).GrhIndex
            Else
                MapData(x, y).Graphic(2).GrhIndex = 0
            End If
                
            'Layer 3 used?
            If ByFlags And 4 Then
                Get handle, , MapData(x, y).Graphic(3).GrhIndex
                InitGrh MapData(x, y).Graphic(3), MapData(x, y).Graphic(3).GrhIndex
            Else
                MapData(x, y).Graphic(3).GrhIndex = 0
            End If
                
            'Layer 4 used?
            If ByFlags And 8 Then
                Get handle, , MapData(x, y).Graphic(4).GrhIndex
                InitGrh MapData(x, y).Graphic(4), MapData(x, y).Graphic(4).GrhIndex
            Else
                MapData(x, y).Graphic(4).GrhIndex = 0
            End If
            
            'Trigger used?
            If ByFlags And 16 Then
                Get handle, , MapData(x, y).Trigger
            Else
                MapData(x, y).Trigger = 0
            End If
            
            'Erase NPCs
            If MapData(x, y).CharIndex > 0 Then
                Call EraseChar(MapData(x, y).CharIndex)
            End If
            MapData(x, y).CharIndex = 0
            'Erase OBJs
            MapData(x, y).ObjGrh.GrhIndex = 0
        Next x
    Next y
    
    Close handle
    
    MapInfo.Name = ""
    MapInfo.Music = ""
    
    CurMap = map
End Sub

Function ReadField(ByVal Pos As Integer, ByRef Text As String, ByVal SepASCII As Byte) As String
'*****************************************************************
'Gets a field from a delimited string
'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
'Last Modify Date: 11/15/2004
'*****************************************************************
    Dim i As Long
    Dim lastPos As Long
    Dim CurrentPos As Long
    Dim delimiter As String * 1
    
    delimiter = Chr$(SepASCII)
    
    For i = 1 To Pos
        lastPos = CurrentPos
        CurrentPos = InStr(lastPos + 1, Text, delimiter, vbBinaryCompare)
    Next i
    
    If CurrentPos = 0 Then
        ReadField = mid$(Text, lastPos + 1, Len(Text) - lastPos)
    Else
        ReadField = mid$(Text, lastPos + 1, CurrentPos - lastPos - 1)
    End If
End Function

Function FieldCount(ByRef Text As String, ByVal SepASCII As Byte) As Long
'*****************************************************************
'Gets the number of fields in a delimited string
'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
'Last Modify Date: 07/29/2007
'*****************************************************************
    Dim Count As Long
    Dim curPos As Long
    Dim delimiter As String * 1
    
    If LenB(Text) = 0 Then Exit Function
    
    delimiter = Chr$(SepASCII)
    
    curPos = 0
    
    Do
        curPos = InStr(curPos + 1, Text, delimiter)
        Count = Count + 1
    Loop While curPos <> 0
    
    FieldCount = Count
End Function

Function FileExist(ByVal file As String, ByVal FileType As VbFileAttribute) As Boolean
    FileExist = (Dir$(file, FileType) <> "")
End Function

Sub WriteClientVer()
    Dim hFile As Integer
        
    hFile = FreeFile()
    Open App.path & "\init\Ver.bin" For Binary Access Write Lock Read As #hFile
    Put #hFile, , CLng(777)
    Put #hFile, , CLng(777)
    Put #hFile, , CLng(777)
    
    Put #hFile, , CInt(App.Major)
    Put #hFile, , CInt(App.Minor)
    Put #hFile, , CInt(App.Revision)
    
    Close #hFile
End Sub

Public Function IsIp(ByVal IP As String) As Boolean
    Dim i As Long
    
    For i = 1 To UBound(ServersLst)
        If ServersLst(i).IP = IP Then
            IsIp = True
            Exit Function
        End If
    Next i
End Function

Public Sub CargarServidores()
'********************************
'Author: Unknown
'Last Modification: 07/26/07
'Last Modified by: Rapsodius
'Added Instruction "CloseClient" before End so the mutex is cleared
'********************************

End Sub

Public Sub InitServersList()

End Sub

Public Function CurServerPasRecPort() As Integer

End Function

Public Function CurServerIp() As String

End Function

Public Function CurServerPort() As Integer

End Function

Sub Main()
INT_ATTACK = 1301
INT_ARROWS = 1551
INT_CAST_SPELL = 1051
INT_CAST_ATTACK = 1151
INT_USEITEMU = 449
INT_USEITEMDCK = 281
    Call WriteClientVer
    
    'Load config file
    If FileExist(App.path & "\init\Inicio.con", vbNormal) Then
        Config_Inicio = LeerGameIni()
    End If
    
    'Load ao.dat config file
    If FileExist(App.path & "\init\ao.dat", vbArchive) Then
        Call LoadClientSetup
        
        If ClientSetup.bDinamic Then
            Set SurfaceDB = New clsSurfaceManDyn
        Else
            Set SurfaceDB = New clsSurfaceManStatic
        End If
    Else
        'Use dynamic by default
        Set SurfaceDB = New clsSurfaceManDyn
    End If
    
    'Read command line. Do it AFTER config file is loaded to prevent this from
    'canceling the effects of "/nores" option.
    Call LeerLineaComandos
    
    If FindPreviousInstance Then
'        Call MsgBox("Argentum Online ya esta corriendo! No es posible correr otra instancia del juego. Haga click en Aceptar para salir.", vbApplicationModal + vbInformation + vbOKOnly, "Error al ejecutar") '
'        End
    End If
    
    
    'usaremos esto para ayudar en los parches
    Call SaveSetting("ArgentumOnlineCliente", "Init", "Path", App.path & "\")
    
    ChDrive App.path
    ChDir App.path

#If SeguridadAlkon Then
    'Obtener el HushMD5
    Dim fMD5HushYo As String * 32
    
    fMD5HushYo = MD5.GetMD5File(App.path & "\" & App.EXEName & ".exe")
    Call MD5.MD5Reset
    MD5HushYo = txtOffset(hexMd52Asc(fMD5HushYo), 55)
    
    Debug.Print fMD5HushYo
#Else
    MD5HushYo = "0123456789abcdef"  'We aren't using a real MD5
#End If
    
    tipf = Config_Inicio.tip
    
    'Set resolution BEFORE the loading form is displayed, therefore it will be centered.
    Call Resolution.SetResolution
    
    frmCargando.Show
    frmCargando.Refresh
    
    'frmConnect.version = "v" & App.Major & "." & App.Minor & " Build: " & App.Revision
    'AddtoRichTextBox frmCargando.Status, "Buscando servidores... ", 0, 0, 0, 0, 0, 1

    'Call CargarServidores
'TODO : esto de ServerRecibidos no se podr�a sacar???
    'ServersRecibidos = True
    
    'AddtoRichTextBox frmCargando.Status, "Hecho", , , , 1
    AddtoRichTextBox frmCargando.Status, "Iniciando Nombres... ", 0, 0, 0, 0, 0, 1
    Call InicializarNombres
    AddtoRichTextBox frmCargando.Status, "Hecho", , , , 1
    AddtoRichTextBox frmCargando.Status, "Iniciando Fuentes... ", 0, 0, 0, 0, 0, 1
    ' Initialize FONTTYPES
    Call Protocol.InitFonts
    
    frmOldPersonaje.NameTxt.Text = GetSetting(App.EXEName, "USER", "act", "Usuario")
    frmOldPersonaje.verpasswD
    
    AddtoRichTextBox frmCargando.Status, "Hecho", , , , 1
    
    AddtoRichTextBox frmCargando.Status, "Iniciando motor gr�fico... ", 0, 0, 0, 0, 0, 1
    
    If Not InitTileEngine(frmMain.hWnd, 160, 7, 32, 32, 13, 17, 9, 8, 8, 0.0185) Then
        Call CloseClient
    End If
    
    AddtoRichTextBox frmCargando.Status, "Hecho", , , , 1
    
    Call AddtoRichTextBox(frmCargando.Status, "Creando animaciones extra... ", , , , , , 1)
    

'unload me    Load Form1
'    Form1.Left = -50000
'    Form1.Top = -50000
'    Form1.Show
UserMap = 1
    
    Call CargarArrayLluvia
    Call CargarAnimArmas
    Call CargarAnimEscudos
    Call CargarVersiones
    Call CargarColores
    
    AddtoRichTextBox frmCargando.Status, "Hecho", , , , 1
    
    AddtoRichTextBox frmCargando.Status, "Iniciando sonidos... ", 0, 0, 0, 0, 0, True
    
    'Inicializamos el sonido
    Call Audio.Initialize(DirectX, frmMain.hWnd, App.path & "\" & Config_Inicio.DirSonidos & "\", App.path & "\" & Config_Inicio.DirMusica & "\")
    
    'Enable / Disable audio
    Audio.MusicActivated = Not ClientSetup.bNoMusic
    Audio.SoundActivated = Not ClientSetup.bNoSound
    
    'Inicializamos el inventario gr�fico
    Call Inventario.Initialize(DirectDraw, frmMain.picInv)
    
    AddtoRichTextBox frmCargando.Status, "Hecho", , , , 1, , False
    
#If SeguridadAlkon Then
    CualMI = 0
    Call InitMI
#End If
    
    AddtoRichTextBox frmCargando.Status, "                    �Bienvenido a Argentum Online!", , , , 1
    
    'Give the user enough time to read the welcome text
    
    Unload frmCargando
    
#If UsarWrench = 1 Then
    frmMain.Socket1.Startup
#End If

    frmConnect.Visible = True
    
    'Inicializaci�n de variables globales
    PrimeraVez = True
    prgRun = True
    pausa = False
    magicNumber = 1
    'Set the intervals of timers
    Call MainTimer.SetInterval(TimersIndex.Attack, INT_ATTACK)
    Call MainTimer.SetInterval(TimersIndex.Work, INT_WORK)
    Call MainTimer.SetInterval(TimersIndex.UseItemWithU, INT_USEITEMU)
    Call MainTimer.SetInterval(TimersIndex.UseItemWithDblClick, INT_USEITEMDCK)
    Call MainTimer.SetInterval(TimersIndex.SendRPU, INT_SENTRPU)
    Call MainTimer.SetInterval(TimersIndex.CastSpell, INT_CAST_SPELL)
    Call MainTimer.SetInterval(TimersIndex.Arrows, INT_ARROWS)
    Call MainTimer.SetInterval(TimersIndex.CastAttack, INT_CAST_ATTACK)


   'Init timers
    Call MainTimer.Start(TimersIndex.Attack)
    Call MainTimer.Start(TimersIndex.Work)
    Call MainTimer.Start(TimersIndex.UseItemWithU)
    Call MainTimer.Start(TimersIndex.UseItemWithDblClick)
    Call MainTimer.Start(TimersIndex.SendRPU)
    Call MainTimer.Start(TimersIndex.CastSpell)
    Call MainTimer.Start(TimersIndex.Arrows)
    Call MainTimer.Start(TimersIndex.CastAttack)
    
    'Set the dialog's font
    Dialogos.font = frmMain.font
    DialogosClanes.font = frmMain.font
    
    
    ' Load the form for screenshots
    'Call Load(frmScreenshots)
    Call SetMusicInfo("Jugando Arduz AO - http://ao.noicoder.com/", "", "", "Games", , "{0}")
    Do While prgRun
        'S�lo dibujamos si la ventana no est� minimizada
        If frmMain.WindowState <> vbMinimized And renderasd = True Then 'IsAppActive = True Then
            Call ShowNextFrame(frmMain.Top, frmMain.Left, frmMain.MouseX, frmMain.MouseY)
            Call RenderSounds
            If frmMain.soycheater.Interval <> 894 Then frmMain.soycheater.Interval = 894
            setfpslabel CStr(Mod_TileEngine.FPS)
        Else
            setfpslabel "--"
        End If
        
        Call CheckKeys

        'FPS Counter - mostramos las FPS
        If GetTickCount - lFrameTimer >= 1000 Then
            lFrameTimer = GetTickCount
        End If
        
        ' If there is anything to be sent, we send it
        Call FlushBuffer
        
        DoEvents
    Loop
    
    Call CloseClient
End Sub

Sub setfpslabel(str As String)
frmMain.FPS.Caption = str
frmMain.Label2(0).Caption = str
frmMain.Label2(1).Caption = str
frmMain.Label2(2).Caption = str
frmMain.Label2(3).Caption = str
frmMain.Label2(4).Caption = str
End Sub

Sub WriteVar(ByVal file As String, ByVal Main As String, ByVal Var As String, ByVal Value As String)
'*****************************************************************
'Writes a var to a text file
'*****************************************************************
    writeprivateprofilestring Main, Var, Value, file
End Sub

Function GetVar(ByVal file As String, ByVal Main As String, ByVal Var As String) As String
'*****************************************************************
'Gets a Var from a text file
'*****************************************************************
    Dim sSpaces As String ' This will hold the input that the program will retrieve
    
    sSpaces = Space$(100) ' This tells the computer how long the longest string can be. If you want, you can change the number 100 to any number you wish
    
    getprivateprofilestring Main, Var, vbNullString, sSpaces, Len(sSpaces), file
    
    GetVar = RTrim$(sSpaces)
    GetVar = Left$(GetVar, Len(GetVar) - 1)
End Function

'[CODE 002]:MatuX
'
'  Funci�n para chequear el email
'
'  Corregida por Maraxus para que reconozca como v�lidas casillas con puntos antes de la arroba y evitar un chequeo innecesario
Public Function CheckMailString(ByVal sString As String) As Boolean
On Error GoTo errHnd
    Dim lPos  As Long
    Dim lX    As Long
    Dim iAsc  As Integer
    
    '1er test: Busca un simbolo @
    lPos = InStr(sString, "@")
    If (lPos <> 0) Then
        '2do test: Busca un simbolo . despu�s de @ + 1
        If Not (InStr(lPos, sString, ".", vbBinaryCompare) > lPos + 1) Then _
            Exit Function
        
        '3er test: Recorre todos los caracteres y los val�da
        For lX = 0 To Len(sString) - 1
            If Not (lX = (lPos - 1)) Then   'No chequeamos la '@'
                iAsc = Asc(mid$(sString, (lX + 1), 1))
                If Not CMSValidateChar_(iAsc) Then _
                    Exit Function
            End If
        Next lX
        
        'Finale
        CheckMailString = True
    End If
errHnd:
End Function

'  Corregida por Maraxus para que reconozca como v�lidas casillas con puntos antes de la arroba
Private Function CMSValidateChar_(ByVal iAsc As Integer) As Boolean
    CMSValidateChar_ = (iAsc >= 48 And iAsc <= 57) Or _
                        (iAsc >= 65 And iAsc <= 90) Or _
                        (iAsc >= 97 And iAsc <= 122) Or _
                        (iAsc = 95) Or (iAsc = 45) Or (iAsc = 46)
End Function

'TODO : como todo lo relativo a mapas, no tiene nada que hacer ac�....
Function HayAgua(ByVal x As Integer, ByVal y As Integer) As Boolean
    HayAgua = ((MapData(x, y).Graphic(1).GrhIndex >= 1505 And MapData(x, y).Graphic(1).GrhIndex <= 1520) Or _
            (MapData(x, y).Graphic(1).GrhIndex >= 5665 And MapData(x, y).Graphic(1).GrhIndex <= 5680) Or _
            (MapData(x, y).Graphic(1).GrhIndex >= 13547 And MapData(x, y).Graphic(1).GrhIndex <= 13562)) And _
                MapData(x, y).Graphic(2).GrhIndex = 0
                
End Function

Public Sub ShowSendTxt()
    If Not frmCantidad.Visible Then
        frmMain.SendTxt.Visible = True
        frmMain.SendTxt.SetFocus
    End If
End Sub

Public Sub ShowSendCMSGTxt()

End Sub
    
Public Sub LeerLineaComandos()
NoRes = IIf(MsgBox("Cambiar resolucion?", vbYesNo) = vbNo, True, False)
End Sub

Private Sub LoadClientSetup()
'**************************************************************
'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
'Last Modify Date: 24/06/2006
'
'**************************************************************
    Dim fHandle As Integer
    
    fHandle = FreeFile
    Open App.path & "\init\ao.dat" For Binary Access Read Lock Write As fHandle
        Get fHandle, , ClientSetup
    Close fHandle
    
    NoRes = ClientSetup.bNoRes
End Sub

Private Sub InicializarNombres()
'**************************************************************
'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
'Last Modify Date: 11/27/2005
'Inicializa los nombres de razas, ciudades, clases, skills, atributos, etc.
'**************************************************************
    Ciudades(eCiudad.cUllathorpe) = "Ullathorpe"
    Ciudades(eCiudad.cNix) = "Nix"
    Ciudades(eCiudad.cBanderbill) = "Banderbill"
    Ciudades(eCiudad.cLindos) = "Lindos"
    Ciudades(eCiudad.cArghal) = "Argh�l"
    
    ListaRazas(eRaza.Humano) = "Humano"
    ListaRazas(eRaza.Elfo) = "Elfo"
    ListaRazas(eRaza.ElfoOscuro) = "Elfo Oscuro"
    ListaRazas(eRaza.Gnomo) = "Gnomo"
    ListaRazas(eRaza.Enano) = "Enano"

    ListaClases(eClass.Mage) = "Mago"
    ListaClases(eClass.Cleric) = "Clerigo"
    ListaClases(eClass.Warrior) = "Guerrero"
    ListaClases(eClass.Assasin) = "Asesino"
    ListaClases(eClass.Thief) = "Ladron"
    ListaClases(eClass.Bard) = "Bardo"
    ListaClases(eClass.Druid) = "Druida"
    ListaClases(eClass.Bandit) = "Bandido"
    ListaClases(eClass.Paladin) = "Paladin"
    ListaClases(eClass.Hunter) = "Cazador"
    ListaClases(eClass.Fisher) = "Pescador"
    ListaClases(eClass.Blacksmith) = "Herrero"
    ListaClases(eClass.Lumberjack) = "Le�ador"
    ListaClases(eClass.Miner) = "Minero"
    ListaClases(eClass.Carpenter) = "Carpintero"
    ListaClases(eClass.Pirat) = "Pirata"
    
    SkillsNames(eSkill.Suerte) = "Suerte"
    SkillsNames(eSkill.Magia) = "Magia"
    SkillsNames(eSkill.Robar) = "Robar"
    SkillsNames(eSkill.Tacticas) = "Tacticas de combate"
    SkillsNames(eSkill.Armas) = "Combate con armas"
    SkillsNames(eSkill.Meditar) = "Meditar"
    SkillsNames(eSkill.Apu�alar) = "Apu�alar"
    SkillsNames(eSkill.Ocultarse) = "Ocultarse"
    SkillsNames(eSkill.Supervivencia) = "Supervivencia"
    SkillsNames(eSkill.Talar) = "Talar �rboles"
    SkillsNames(eSkill.Comerciar) = "Comercio"
    SkillsNames(eSkill.Defensa) = "Defensa con escudos"
    SkillsNames(eSkill.Pesca) = "Pesca"
    SkillsNames(eSkill.Mineria) = "Mineria"
    SkillsNames(eSkill.Carpinteria) = "Carpinteria"
    SkillsNames(eSkill.Herreria) = "Herreria"
    SkillsNames(eSkill.Liderazgo) = "Liderazgo"
    SkillsNames(eSkill.Domar) = "Domar animales"
    SkillsNames(eSkill.Proyectiles) = "Armas de proyectiles"
    SkillsNames(eSkill.Wrestling) = "Wrestling"
    SkillsNames(eSkill.Navegacion) = "Navegacion"

    AtributosNames(eAtributos.Fuerza) = "Fuerza"
    AtributosNames(eAtributos.Agilidad) = "Agilidad"
    AtributosNames(eAtributos.Inteligencia) = "Inteligencia"
    AtributosNames(eAtributos.Carisma) = "Carisma"
    AtributosNames(eAtributos.Constitucion) = "Constitucion"
End Sub

''
' Removes all text from the console and dialogs

Public Sub CleanDialogs()
'**************************************************************
'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
'Last Modify Date: 11/27/2005
'Removes all text from the console and dialogs
'**************************************************************
    'Clean console and dialogs
    frmMain.RecTxt.Text = vbNullString
    
    Call DialogosClanes.RemoveDialogs
    
    Call Dialogos.RemoveAllDialogs
End Sub

Public Sub CloseClient()
'**************************************************************
'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
'Last Modify Date: 8/14/2007
'Frees all used resources, cleans up and leaves
'**************************************************************
    ' Allow new instances of the client to be opened
    Call PrevInstance.ReleaseInstance
    
    EngineRun = False
    frmCargando.Show
    AddtoRichTextBox frmCargando.Status, "Liberando recursos...", 0, 0, 0, 0, 0, 1
    
    Call Resolution.ResetResolution
    
    'Stop tile engine
    Call DeinitTileEngine
    
    'Destruimos los objetos p�blicos creados


    Set SurfaceDB = Nothing
    Set Dialogos = Nothing
    Set DialogosClanes = Nothing
    Set Audio = Nothing
    Set Inventario = Nothing
    Set MainTimer = Nothing
    Set incomingData = Nothing
    Set outgoingData = Nothing
    
#If SeguridadAlkon Then
    Set MD5 = Nothing
#End If
    
    Call UnloadAllForms
    
    'Actualizar tip
    Config_Inicio.tip = tipf
    Call EscribirGameIni(Config_Inicio)
    
    End
End Sub
