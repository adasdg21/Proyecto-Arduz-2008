Attribute VB_Name = "BOTS"

Option Explicit

Public Const PRCLER_NPC As Integer = 1 + 899
Public Const PRGUER_NPC As Integer = 2 + 899
Public Const PRMAGO_NPC As Integer = 3 + 899
Public Const PRCAZA_NPC As Integer = 4 + 899
Public Const PRKING_NPC As Integer = 5 + 899


Private Const SONIDO_Dragon_VIVO As Integer = 30

Public Const ALCOBA1_X As Integer = 35
Public Const ALCOBA1_Y As Integer = 25
Public Const ALCOBA2_X As Integer = 67
Public Const ALCOBA2_Y As Integer = 25

'Added by Nacho
'Cuantos pretorianos vivos quedan. Uno por cada alcoba
Public pretorianosVivos As Integer


Public Function esPretoriano(ByVal NpcIndex As Integer) As Integer
On Error GoTo errorh

    Dim N As Integer
    Dim i As Integer
    N = Npclist(NpcIndex).Numero
    i = Npclist(NpcIndex).Char.CharIndex
'    Call SendData(SendTarget.ToNPCArea, NpcIndex, Npclist(NpcIndex).Pos.Map, "||" & vbGreen & "� Soy Pretoriano �" & Str(ind))
    Select Case Npclist(NpcIndex).Numero
    Case PRCLER_NPC
        esPretoriano = 1
    Case PRMAGO_NPC
        esPretoriano = 2
    Case PRCAZA_NPC
        esPretoriano = 3
    Case PRKING_NPC
        esPretoriano = 4
    Case PRGUER_NPC
        esPretoriano = 5
    End Select

Exit Function

errorh:
    LogError ("Error en NPCAI.EsPretoriano? " & Npclist(NpcIndex).name)
    'do nothing

End Function


Sub CrearClanPretoriano(ByVal X As Integer)
If botsact = False Then Exit Sub

On Error GoTo errorh
    Dim wp As WorldPos
    Dim wp2 As WorldPos
    Dim TeleFrag As Integer
    
    wp.map = servermap
            wp.X = 50
            wp.Y = 50
    pretorianosVivos = 5 'Hay 7 + el Rey.
    TeleFrag = MapData(wp.map, wp.X, wp.Y).NpcIndex
    ''ya limpi� el lugar para el rey (wp)
    ''Los otros no necesitan este caso ya que respawnan lejos
    'Call CrearNPC(PRKING_NPC, servermap, wp, ePK)
    wp.X = wp.X - 4
    ''Call CrearNPC(PRCLER_NPC, servermap, wp, eKip.ePK)
    wp.X = wp.X - 3
    'Call CrearNPC(PRCLER_NPC, servermap, wp, eKip.ePK)
    wp.X = wp.X + 3
    wp.Y = wp.Y - 1
    Call CrearNPC(PRCLER_NPC, servermap, wp, eKip.epk)
    wp.X = wp.X - 2
    ''Call CrearNPC(PRCLER_NPC, servermap, wp, eKip.eCUI)
    wp.X = wp.X + 2
    'Call CrearNPC(PRCLER_NPC, servermap, wp)
    'wp.Y = wp.Y + 3
    'Call CrearNPC(PRGUER_NPC, servermap, wp, eKip.ePK)
    'wp.X = wp.X + 1
    'wp.Y = wp.Y + 1
    'Call CrearNPC(PRGUER_NPC, servermap, wp, eKip.eCUI)
    wp.X = wp.X + 2
    'Call CrearNPC(PRGUER_NPC, servermap, wp)
    wp.Y = wp.Y - 1
    'wp.X = wp.X - 5
    Call CrearNPC(PRMAGO_NPC, servermap, wp, eKip.epk)
    Call CrearNPC(PRMAGO_NPC, servermap, wp, eKip.eCUI)
     wp.Y = wp.Y + 1
    'Call CrearNPC(PRMAGO_NPC, servermap, wp, eKip.ePK)
    
Exit Sub

errorh:
    LogError ("Error en NPCAI.CrearClanPretoriano ")
    'do nothing

End Sub


Sub PRCAZA_AI(ByVal npcind As Integer)
'Exit Sub
On Error GoTo errorh
    '' NO CAMBIAR:
    '' HECHIZOS: 1- FLECHA
    

    Dim X As Integer
    Dim Y As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    Dim BestTarget As Integer
    Dim NPCAlInd As Integer
    Dim PJEnInd  As Integer
    
    Dim PJBestTarget As Boolean
    Dim BTx As Integer
    Dim BTy As Integer
    Dim Xc As Integer
    Dim Yc As Integer
    Dim azar As Integer
    Dim azar2 As Integer
    Static puedobbmanda As Boolean
    Dim quehacer As Byte
        ''1- Ataca usuarios
    
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    NPCPosM = Npclist(npcind).Pos.map
    
    PJBestTarget = False
    X = 0
    Y = 0
    quehacer = 0
    
    
    azar = Sgn(RandomNumber(-1, 1))
    'azar = Sgn(azar)
    If azar = 0 Then azar = 1
    azar2 = Sgn(RandomNumber(-1, 1))
    'azar2 = Sgn(azar2)
    If azar2 = 0 Then azar2 = 1
    
    'pick the best target according to the following criteria:
    '1) magues ARE dangerous, but they are weak too, they're
    '   our primary target
    '2) in any other case, our nearest enemy will be attacked
    
    For X = NPCPosX + (azar * 8) To NPCPosX + (azar * -8) Step -azar
        For Y = NPCPosY + (azar2 * 7) To NPCPosY + (azar2 * -7) Step -azar2
            NPCAlInd = MapData(NPCPosM, X, Y).NpcIndex  ''por si implementamos algo contra NPCs
            PJEnInd = MapData(NPCPosM, X, Y).UserIndex
            If (PJEnInd > 0) And (Npclist(npcind).CanAttack = 1) Then
                If (UserList(PJEnInd).flags.invisible = 0 Or UserList(PJEnInd).flags.Oculto = 0) And Not (UserList(PJEnInd).flags.Muerto = 1) And Not UserList(PJEnInd).flags.AdminInvisible = 1 And UserList(PJEnInd).flags.AdminPerseguible Then
                'ToDo: Borrar los GMs
                    If (EsMagoOClerigo(PJEnInd)) Then
                        ''say no more, atacar a este
                        PJBestTarget = True
                        BestTarget = PJEnInd
                        quehacer = 1
                        'Call NpcLanzaSpellSobreUser(npcind, PJEnInd, Npclist(npcind).Spells(1)) ''flecha pasa como spell
                        X = NPCPosX + (azar * -8)
                        Y = NPCPosY + (azar2 * -7)
                        ''forma espantosa de zafar del for
                     Else
                        If (BestTarget > 0) Then
                            ''ver el mas cercano a mi
                            If Sqr((X - NPCPosX) ^ 2 + (Y - NPCPosY) ^ 2) < Sqr((NPCPosX - UserList(BestTarget).Pos.X) ^ 2 + (NPCPosY - UserList(BestTarget).Pos.Y) ^ 2) Then
                                ''el nuevo esta mas cerca
                                PJBestTarget = True
                                BestTarget = PJEnInd
                                quehacer = 1
                            End If
                        Else
                            PJBestTarget = True
                            BestTarget = PJEnInd
                            quehacer = 1
                        End If
                    End If
                End If
            End If  ''Fin analisis del tile
        Next Y
    Next X
Select Case quehacer
    Case 1  ''nearest target
    puedobbmanda = Not puedobbmanda
    If Npclist(npcind).Stats.MinHP < Npclist(npcind).Stats.MaxHP Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        If Npclist(npcind).Stats.MinHP + 45 > Npclist(npcind).Stats.MaxHP Then
            Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP
        Else
            Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MinHP + 20
        End If
    Else
        'If (Npclist(npcind).CanAttack = 1) Then
            If Round(RandomNumber(-1, mankismo)) = 0 And puedobbmanda = True Then
                Call NpcLanzaSpellSobreUser(npcind, BestTarget, Npclist(npcind).Spells(1))
            End If
        'End If
    End If
    ''case 2: not yet implemented
End Select
    
''  Vamos a setear el hold on del cazador en el medio entre el rey
''  y el atacante. De esta manera se lo podra atacar aun asi est� lejos
''  pero sin alejarse del rango de los an hoax vorps de los
''  clerigos o rey. A menos q este paralizado, claro

If Npclist(npcind).flags.Paralizado = 1 Then
Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, RandomNumber(1, 4))
Exit Sub
End If
If Not NPCPosM = servermap Then Exit Sub


'MEJORA: Si quedan solos, se van con el resto del ejercito
If Npclist(npcind).Invent.ArmourEqpSlot <> 0 Then
    'si me estoy yendo a alguna alcoba
    Call CambiarAlcoba(npcind)
    Exit Sub
End If




If EstoyMuyLejos(npcind) Then
    VolverAlCentro (npcind)
    Exit Sub
End If

If (BestTarget > 0) Then

    BTx = UserList(BestTarget).Pos.X
    BTy = UserList(BestTarget).Pos.Y
    
    If NPCPosX < 50 Then
        
        Call GreedyWalkTo(npcind, servermap, ALCOBA1_X + ((BTx - ALCOBA1_X) \ 2), ALCOBA1_Y + ((BTy - ALCOBA1_Y) \ 2))
        'GreedyWalkTo npcind, servermap, ALCOBA1_X + ((BTx - ALCOBA1_X) \ 2), ALCOBA1_Y + ((BTy - ALCOBA1_Y) \ 2)
    Else
        Call GreedyWalkTo(npcind, servermap, ALCOBA2_X + ((BTx - ALCOBA2_X) \ 2), ALCOBA2_Y + ((BTy - ALCOBA2_Y) \ 2))
        'GreedyWalkTo npcind, servermap, ALCOBA2_X + ((BTx - ALCOBA2_X) \ 2), ALCOBA2_Y + ((BTy - ALCOBA2_Y) \ 2)
    End If
Else
    ''2do Loop. Busca gente acercandose por otros frentes para frenarla
    If NPCPosX < 50 Then Xc = ALCOBA1_X Else Xc = ALCOBA2_X
    Yc = ALCOBA1_Y
    
    For X = Xc - 16 To Xc + 16
        For Y = Yc - 14 To Yc + 14
            If Not (X <= NPCPosX + 8 And X >= NPCPosX - 8 And Y >= NPCPosY - 7 And Y <= NPCPosY + 7) Then
                ''si es un tile no analizado
                PJEnInd = MapData(NPCPosM, X, Y).UserIndex    ''por si implementamos algo contra NPCs
                If (PJEnInd > 0) Then
                    If Not (UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1 Or UserList(PJEnInd).flags.Muerto = 1) Then
                        ''si no esta muerto.., ya encontro algo para ir a buscar
                        Call GreedyWalkTo(npcind, servermap, UserList(PJEnInd).Pos.X, UserList(PJEnInd).Pos.Y)
                        Exit Sub
                    End If
                End If
            End If
        Next Y
    Next X
    
    ''vuelve si no esta en proceso de ataque a usuarios
    If (Npclist(npcind).CanAttack = 1) Then Call VolverAlCentro(npcind)

End If
    
Exit Sub
errorh:
    LogError ("Error en NPCAI.PRCAZA_AI ")
    'do nothing

End Sub

Sub PRMAGO_AI(ByVal npcind As Integer)

'On Error GoTo errorh
    
    'HECHIZOS: NO CAMBIAR ACA
    'REPRESENTAN LA UBICACION DE LOS SPELLS EN NPC_HOSTILES.DAT y si se los puede cambiar en ese archivo
    '1- APOCALIPSIS 'modificable
    '2- REMOVER INVISIBILIDAD 'NO MODIFICABLE
    Dim DAT_APOCALIPSIS As Integer
    Dim DAT_REMUEVE_INVI As Integer
    DAT_APOCALIPSIS = 1
    DAT_REMUEVE_INVI = 2
    Dim inicio As Long
    inicio = GetTickCount
    ''EL mago pretoriano guarda  el index al NPC Rey en el
    ''inventario.barcoobjind parameter. Ese no es usado nunca.
    ''EL objetivo es no modificar al TAD NPC utilizando una propiedad
    ''que nunca va a ser utilizada por un NPC (espero)
    Dim X As Integer
    Dim Y As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    Dim BestTarget As Integer
    Dim NPCAlInd As Integer
    Dim PJEnInd As Integer
    Dim PJBestTarget As Boolean
    Dim bs As Byte
    Dim azar As Integer
    Dim azar2 As Integer

    Dim quehacer As Byte
        ''1- atacar a enemigos
        ''2- remover invisibilidades
        ''3- rotura de vara

    NPCPosX = Npclist(npcind).Pos.X   ''store current position
    NPCPosY = Npclist(npcind).Pos.Y   ''for direct access
    NPCPosM = Npclist(npcind).Pos.map
    
    PJBestTarget = False
    BestTarget = 0
    quehacer = 0
    X = 0
    Y = 0
    'Debug.Print Npclist(npcind).Stats.MaxMAN & "/" & Npclist(npcind).Stats.MinMAN
        If Npclist(npcind).Stats.MaxMAN = 0 Then
            Npclist(npcind).Stats.MaxMAN = 2000
            Npclist(npcind).Stats.MinMAN = 2000
        End If
        If Npclist(npcind).Stats.MinHP < Npclist(npcind).Stats.MaxHP Then
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
            If Npclist(npcind).Stats.MinHP + 20 > Npclist(npcind).Stats.MaxHP Then
                Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP
            Else
                Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MinHP + 15
            End If
            GoTo karlos
        ElseIf Npclist(npcind).Stats.MinMAN < Npclist(npcind).Stats.MaxMAN And Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP Then
            'Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
            Dim rans As Byte
            rans = Porcentaje(Npclist(npcind).Stats.MaxMAN, 5)
            If rans = 1 Then Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
            If Npclist(npcind).Stats.MinMAN + rans > Npclist(npcind).Stats.MaxMAN Then
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MaxMAN
            Else
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN + rans
            End If
        End If
        
        If Not (Npclist(npcind).Invent.BarcoSlot = 6) Then
            Npclist(npcind).Invent.BarcoSlot = 6    ''restore wand break counter
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageCreateFX(Npclist(npcind).Char.CharIndex, 0, 0))
        End If
    
        'pick the best target according to the following criteria:
        '1) invisible enemies can be detected sometimes
        '2) a wizard's mission is background spellcasting attack
        
        azar = Sgn(RandomNumber(-1, 1))
        'azar = Sgn(azar)
        If azar = 0 Then azar = 1
        azar2 = Sgn(RandomNumber(-1, 1))
        'azar2 = Sgn(azar2)
        If azar2 = 0 Then azar2 = 1
        
        ''esto fue para rastrear el combat field al azar
        ''Si no se hace asi, los NPCs Pretorianos "combinan" ataques, y cada
        ''ataque puede sumar hasta 700 Hit Points, lo cual los vuelve
        ''invulnerables
        If (Npclist(npcind).flags.Paralizado = 1 Or Npclist(npcind).flags.Inmovilizado = 1) And Npclist(npcind).Stats.MinMAN > Hechizos(10).ManaRequerido Then
        'ESTOY
            If RandomNumber(0, 2) = 1 And puede_npc(npcind, 1000, False) = True Then
                    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("AN HOAX VORP", Npclist(npcind).Char.CharIndex, vbCyan))
                    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(Hechizos(10).WAV, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
                    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageCreateFX(Npclist(npcind).Char.CharIndex, Hechizos(10).FXgrh, Hechizos(10).loops))
                    Npclist(npcind).Contadores.Paralisis = 0
                    Npclist(npcind).flags.Inmovilizado = 0
                    Npclist(npcind).flags.Paralizado = 0
                    Npclist(npcind).CanAttack = 0
                    Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(10).ManaRequerido
            End If
            Exit Sub
        End If
'        azar = 1
        Dim np As Boolean
        np = False
        For X = NPCPosX + (azar * 8) To NPCPosX + (azar * -8) Step -azar
        If PJBestTarget = False Then
            For Y = NPCPosY + (azar2 * 7) To NPCPosY + (azar2 * -7) Step -azar2
                NPCAlInd = MapData(NPCPosM, X, Y).NpcIndex  ''por si implementamos algo contra NPCs
                PJEnInd = MapData(NPCPosM, X, Y).UserIndex
                If (PJEnInd > 0) Then
                    If Not (UserList(PJEnInd).flags.Muerto = 1) Then
                    If UserList(PJEnInd).bando = Npclist(npcind).bando Then
                        If UserList(PJEnInd).flags.Paralizado = 1 Then
                            'If puede_npc(npcind, 1000, False) = True Then
                                If RandomNumber(0, 2) = 1 Then
                                    If Npclist(npcind).Stats.MinMAN > Hechizos(10).ManaRequerido Then
                                        'Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(10).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                                        'Call SendData(SendTarget.ToPCArea, PJEnInd, PrepareMessagePlayWave(Hechizos(10).WAV, UserList(PJEnInd).Pos.X, UserList(PJEnInd).Pos.Y))
                                        'Call SendData(SendTarget.ToPCArea, PJEnInd, PrepareMessageCreateFX(UserList(PJEnInd).Char.CharIndex, Hechizos(10).FXgrh, Hechizos(10).loops))
                                        Call NpcLanzaSpellSobreUser(npcind, PJEnInd, 10) ''SPELL 1 de Clerigo es PARALIZAR
                                        Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(10).ManaRequerido
                                    Npclist(npcind).ultimox = GetTickCount
                                    End If
                                End If
                                'Npclist(npcind).CanAttack = 0
                                'Exit Sub
                            'End If
                        End If
                    Else
                        If (UserList(PJEnInd).flags.invisible = 1) Or (UserList(PJEnInd).flags.Oculto = 1) Then
                            If UserList(PJEnInd).flags.Paralizado = 1 Then
                                BestTarget = PJEnInd
                                PJBestTarget = True
                                quehacer = 2
                                Exit For
                            End If
                        ElseIf (UserList(PJEnInd).flags.Paralizado = 1) Then
                            If (BestTarget > 0) Then
                                If Not (UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1) Then
                                    ''encontre un paralizado visible, y no hay un besttarget invisible (paralizado invisible)
                                    BestTarget = PJEnInd
                                    PJBestTarget = True
                                    quehacer = 2
                                    Exit For
                                End If
                            Else
                                BestTarget = PJEnInd
                                PJBestTarget = True
                                quehacer = 2
                                Exit For
                            End If
                        ElseIf BestTarget = 0 Then
                            ''movil visible
                            BestTarget = PJEnInd
                            PJBestTarget = True
                            quehacer = 2
                            Exit For
                        End If  ''
                    End If  ''endif:    not muerto
                    End If
                ElseIf (NPCAlInd > 0) Then
                    If (Npclist(npcind).bando <> Npclist(NPCAlInd).bando) And Npclist(NPCAlInd).Numero <> PRKING_NPC Then
                        BestTarget = NPCAlInd
                        quehacer = 30
                        np = True
                    Else    'es un PJ aliado en combate
                        If (Npclist(NPCAlInd).flags.Paralizado = 1 Or Npclist(NPCAlInd).flags.Inmovilizado = 1) And Npclist(NPCAlInd).Numero <> PRKING_NPC Then
                                        If (Npclist(npcind).flags.Paralizado = 1 Or Npclist(npcind).flags.Inmovilizado = 1) And Npclist(npcind).Stats.MinMAN > Hechizos(10).ManaRequerido Then
                                        'ESTOY
                                            If CInt(RandomNumber(0, 1)) = 1 And puede_npc(npcind, 1300, False) = True Then
                                                    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("AN HOAX VORP", Npclist(npcind).Char.CharIndex, vbCyan))
                                                    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessagePlayWave(Hechizos(10).WAV, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
                                                    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessageCreateFX(Npclist(npcind).Char.CharIndex, Hechizos(10).FXgrh, Hechizos(10).loops))
                                                    Npclist(NPCAlInd).Contadores.Paralisis = 0
                                                    Npclist(NPCAlInd).flags.Inmovilizado = 0
                                                    Npclist(NPCAlInd).flags.Paralizado = 0
                                                    Npclist(npcind).CanAttack = 0
                                                    Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(10).ManaRequerido
                                                Exit Sub
                                            End If
                                            
                                        End If
                        End If
                    End If
                End If  ''endif: es un tile con PJ y puede atacar
            Next Y
        End If
        Next X
    

    Select Case quehacer
    ''case 1 esta "harcodeado" en el doble for
    ''es remover invisibilidades
    Case 2          ''apocalipsis Rahma Na�arak O'al
        'If puede_npc(npcind, 1000, False) = True Then
        If Npclist(npcind).Stats.MinMAN > Hechizos(Npclist(npcind).Spells(DAT_APOCALIPSIS)).ManaRequerido + 400 Then
            If Round(RandomNumber(0, mankismo)) = 0 Then
                'Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(Npclist(npcind).Spells(DAT_APOCALIPSIS)).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                Call NpcLanzaSpellSobreUser2(npcind, BestTarget, Npclist(npcind).Spells(DAT_APOCALIPSIS)) ''SPELL 1 de Mago: Apocalipsis
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - 1000
                'Npclist(npcind).ultimox = GetTickCount()
            End If
            'Npclist(npcind).CanAttack = 0
        'End If
        End If
    Case 30  '' ataque a enemigobots
    Dim da�o As Long
    Dim mult As Integer
    mult = 2
    If Npclist(BestTarget).flags.Paralizado = 1 Or Npclist(BestTarget).flags.Inmovilizado = 1 Then mult = 0
        If Npclist(npcind).Stats.MinMAN > Hechizos(25).ManaRequerido Then
            If Round(RandomNumber(0, mankismo * mult + 2)) = 0 Then
                        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(25).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                        'Call NpcLanzaSpellSobreNpc(npcind, BestTarget, 25)
                        
                        da�o = RandomNumber(Hechizos(25).MinHP, Hechizos(25).MaxHP)
                        Call SendData(SendTarget.ToNPCArea, BestTarget, PrepareMessagePlayWave(Hechizos(25).WAV, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y))
                        Call SendData(SendTarget.ToNPCArea, BestTarget, PrepareMessageCreateFX(Npclist(BestTarget).Char.CharIndex, Hechizos(25).FXgrh, Hechizos(25).loops))
                        Npclist(BestTarget).Stats.MinHP = Npclist(BestTarget).Stats.MinHP - da�o
                        'Muere
                        If Npclist(BestTarget).Stats.MinHP < 1 Then
                            Npclist(BestTarget).Stats.MinHP = 0
                            Call MuereNpc(BestTarget, 0)
                        End If
                        'Npclist(npcind).CanAttack = 0
                        Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(25).ManaRequerido
                        'Npclist(npcind).CanAttack = 0
            End If
        ElseIf Npclist(npcind).Stats.MinMAN > Hechizos(23).ManaRequerido Then
            If Round(RandomNumber(0, mankismo * mult + 3)) = 0 Then
                        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(23).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                        'Call NpcLanzaSpellSobreNpc(npcind, BestTarget, 23)

                        da�o = RandomNumber(Hechizos(23).MinHP, Hechizos(23).MaxHP)
                        Call SendData(SendTarget.ToNPCArea, BestTarget, PrepareMessagePlayWave(Hechizos(23).WAV, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y))
                        Call SendData(SendTarget.ToNPCArea, BestTarget, PrepareMessageCreateFX(Npclist(BestTarget).Char.CharIndex, Hechizos(23).FXgrh, Hechizos(23).loops))
                        Npclist(BestTarget).Stats.MinHP = Npclist(BestTarget).Stats.MinHP - da�o
                        'Muere
                        If Npclist(BestTarget).Stats.MinHP < 1 Then
                            Npclist(BestTarget).Stats.MinHP = 0
                            Call MuereNpc(BestTarget, 0)
                        End If
                        'Npclist(npcind).CanAttack = 0
                        Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(23).ManaRequerido
                        'Npclist(npcind).CanAttack = 0
            End If
        End If
    End Select
    
    ''movimiento (si puede)
    ''El mago no se mueve a menos q tenga alguien al lado
    
If Npclist(npcind).flags.Paralizado = 1 Then
Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, RandomNumber(1, 4))
Exit Sub
End If
    
    'If Not (quehacer = 3) Then      ''si no ta matandose
            ''alejarse si tiene un PJ cerca
            ''pero alejarse sin alejarse del rey
        
        ''Si no hay nadie cerca, o no tengo nada que hacer...
        If Npclist(npcind).flags.AtacaAPJ > 0 Then
            If (UserList(Npclist(npcind).flags.AtacaAPJ).flags.invisible = 1 Or UserList(Npclist(npcind).flags.AtacaAPJ).flags.Oculto = 1 Or UserList(Npclist(npcind).flags.AtacaAPJ).flags.Muerto = 1) Then Npclist(npcind).flags.AtacaAPJ = 0
        End If
        
        If BestTarget > 0 Then GoTo karlos
        If Npclist(npcind).flags.AtacaAPJ > 0 Then GoTo karlos
        'If (BestTarget = 0) And (Npclist(npcind).flags.AtacaAPJ = 0 And Npclist(npcind).flags.AtacaANPC = 0) Then
            'Call VolverAlCentro(npcind)
            Dim distBestTarget As Long
            Dim dist As Long
            Dim ni As Integer
            Dim espj As Long
            For X = 9 To 95
            For Y = 9 To 95
                    PJEnInd = MapData(NPCPosM, X, Y).UserIndex
                    ni = MapData(NPCPosM, X, Y).NpcIndex
            
                    If (PJEnInd > 0) Then
                        If (Not (UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1 Or UserList(PJEnInd).flags.Muerto = 1)) Then
                            ''caluclo la distancia al PJ, si esta mas cerca q el actual
                            ''mejor besttarget entonces ataco a ese.
                            If (BestTarget > 0) And UserList(PJEnInd).bando <> Npclist(npcind).bando Then
                                dist = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                                If (dist < distBestTarget) Then
                                    BestTarget = PJEnInd
                                    np = False
                                    distBestTarget = dist
                                    Npclist(npcind).flags.AtacaAPJ = PJEnInd
                                    espj = True
                                End If
                            Else
                                distBestTarget = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                                BestTarget = PJEnInd
                                np = False
                                espj = True
                            End If
                        End If
                    ElseIf (ni > 0) And espj = False Then
                            ''caluclo la distancia al PJ, si esta mas cerca q el actual
                            ''mejor besttarget entonces ataco a ese.
                            If (BestTarget > 0) And Npclist(ni).bando <> Npclist(npcind).bando Then
                                dist = Sqr((Npclist(ni).Pos.X - NPCPosX) ^ 2 + (Npclist(ni).Pos.Y - NPCPosY) ^ 2)
                                If (dist < distBestTarget) Then
                                    BestTarget = ni
                                    np = True
                                    Npclist(npcind).flags.AtacaANPC = ni
                                    distBestTarget = dist
                                End If
                            Else
                                distBestTarget = Sqr((Npclist(ni).Pos.X - NPCPosX) ^ 2 + (Npclist(ni).Pos.Y - NPCPosY) ^ 2) 'Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                                BestTarget = ni
                                np = True
                            End If
                    End If
            
            Next Y
        Next X
            'ElseIf (BestTarget = 0) Then
            'For X = 9 To 95
            'For Y = 9 To 95
            '        BestTarget = MapData(NPCPosM, X, Y).UserIndex
            '        NPCAlInd = MapData(NPCPosM, X, Y).NpcIndex
            '        If NPCAlInd > 0 Then
            '            If Npclist(NPCAlInd).bando <> Npclist(npcind).bando Then
            '                Call MOVIMIENTOWAR(npcind, servermap, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y)
            '                Exit Sub
            '            End If
            '        ElseIf BestTarget > 0 Then
            '            If UserList(BestTarget).bando <> Npclist(npcind).bando Then
            '                Call MOVIMIENTOWAR(npcind, servermap, UserList(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y)
            '                Exit Sub
            '            End If
            '        End If'

            'Next Y
        'Next X
        'Else
        'end if
        'Call VolverAlCentro(npcind)
            'If np = True Then
            '    GreedyWalkTo npcind, Npclist(npcind).Pos.map, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y
            'Else
            '    GreedyWalkTo npcind, Npclist(npcind).Pos.map, UserList(BestTarget).Pos.X, UserList(BestTarget).Pos.Y
            'End If
            'If np = True Then
            '    GreedyWalkTo npcind, Npclist(npcind).Pos.map, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y
            'Else
GoTo karlos
karlos:
If Npclist(npcind).flags.Paralizado = 1 Then Exit Sub
'Debug.Print GetTickCount - inicio
If BestTarget > 0 Then
If np = True Then
    GreedyWalkTo npcind, Npclist(npcind).Pos.map, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y
Else
    GreedyWalkTo npcind, Npclist(npcind).Pos.map, UserList(BestTarget).Pos.X, UserList(BestTarget).Pos.Y
End If
Exit Sub
ElseIf Npclist(npcind).flags.AtacaAPJ > 0 Then
                GreedyWalkTo npcind, Npclist(npcind).Pos.map, UserList(Npclist(npcind).flags.AtacaAPJ).Pos.X, UserList(Npclist(npcind).flags.AtacaAPJ).Pos.Y
Exit Sub
ElseIf Npclist(npcind).flags.AtacaANPC > 0 Then
                GreedyWalkTo npcind, Npclist(npcind).Pos.map, Npclist(Npclist(npcind).flags.AtacaANPC).Pos.X, Npclist(Npclist(npcind).flags.AtacaANPC).Pos.Y
Exit Sub
End If


Dim mueje As Integer
mueje = RandomNumber(2, 8) / 2
Select Case mueje
Case 1
                If LegalPos(servermap, NPCPosX, NPCPosY + 1) Then
                    Call MoverAba(npcind)
                    Exit Sub
                End If
Case 2
                If LegalPos(servermap, NPCPosX - 1, NPCPosY) Then
                    Call MoverIzq(npcind)
                    Exit Sub
                End If
Case 3
                If LegalPos(servermap, NPCPosX + 1, NPCPosY) Then
                    Call MoverDer(npcind)
                    Exit Sub
                End If
Case 4
                If LegalPos(servermap, NPCPosX, NPCPosY - 1) Then
                    Call MoverArr(npcind)
                    Exit Sub
                End If
End Select
    
Exit Sub
    
errorh:
    LogError ("Error en NPCAI.PRMAGO_AI? ")

End Sub

Sub PRREY_AI(ByVal npcind As Integer)
On Error GoTo errorh
    'HECHIZOS: NO CAMBIAR ACA
    'REPRESENTAN LA UBICACION DE LOS SPELLS EN NPC_HOSTILES.DAT y si se los puede cambiar en ese archivo
    '1- CURAR_LEVES 'NO MODIFICABLE
    '2- REMOVER PARALISIS 'NO MODIFICABLE
    '3- CEUGERA - 'NO MODIFICABLE
    '4- ESTUPIDEZ - 'NO MODIFICABLE
    '5- CURARVENENO - 'NO MODIFICABLE
    Dim DAT_CURARLEVES As Integer
    Dim DAT_REMUEVEPARALISIS As Integer
    Dim DAT_CEGUERA As Integer
    Dim DAT_ESTUPIDEZ As Integer
    Dim DAT_CURARVENENO As Integer
    DAT_CURARLEVES = 1
    DAT_REMUEVEPARALISIS = 2
    DAT_CEGUERA = 3
    DAT_ESTUPIDEZ = 4
    DAT_CURARVENENO = 5
    
    
    Dim UI As Integer
    Dim X As Integer
    Dim Y As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    Dim NPCAlInd As Integer
    Dim PJEnInd As Integer
    Dim BestTarget As Integer
    Dim distBestTarget As Integer
    Dim dist As Integer
    Dim e_p As Integer
    Dim hayPretorianos As Boolean
    Dim headingloop As Byte
    Dim npos As WorldPos
    ''Dim quehacer As Integer
        ''1- remueve paralisis con un minimo % de efecto
        ''2- remueve veneno
        ''3- cura
    
    NPCPosM = Npclist(npcind).Pos.map
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    BestTarget = 0
    distBestTarget = 0
    hayPretorianos = False
    
    'pick the best target according to the following criteria:
    'King won't fight. Since praetorians' mission is to keep him alive
    'he will stay as far as possible from combat environment, but close enought
    'as to aid his loyal army.
    'If his army has been annihilated, the king will pick the
    'closest enemy an chase it using his special 'weapon speedhack' ability
    For X = NPCPosX - 8 To NPCPosX + 8
        For Y = NPCPosY - 7 To NPCPosY + 7
            'scan combat field
            NPCAlInd = MapData(NPCPosM, X, Y).NpcIndex
            PJEnInd = MapData(NPCPosM, X, Y).UserIndex
            If (Npclist(npcind).CanAttack = 1) Then   ''saltea el analisis si no puede atacar para evitar cuentas
                If (NPCAlInd > 0) Then
                    e_p = esPretoriano(NPCAlInd)
                    If e_p > 0 And e_p < 6 And (Not (NPCAlInd = npcind)) Then
                        hayPretorianos = True
                        'Me curo mientras haya pretorianos (no es lo ideal, deber�a no dar experiencia tampoco, pero por ahora es lo que hay)
                        Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP
                    End If
                    
                    If (Npclist(NPCAlInd).flags.Paralizado = 1 And e_p > 0 And e_p < 6) Then
                        ''el rey puede desparalizar con una efectividad del 20%
                        If Round(RandomNumber(0, mankismo + 1 * 2)) = 0 Then
                            Call NPCRemueveParalisisNPC(npcind, NPCAlInd, DAT_REMUEVEPARALISIS)
                        End If
                            'Npclist(npcind).CanAttack = 0
                            Exit Sub
                    ''failed to remove
                    ElseIf (Npclist(NPCAlInd).flags.Envenenado = 1) Then    ''un chiche :D
                        If esPretoriano(NPCAlInd) Then
                            Call NPCRemueveVenenoNPC(npcind, NPCAlInd, DAT_CURARVENENO)
                            'Npclist(npcind).CanAttack = 0
                            Exit Sub
                        End If
                    End If
                End If

                If PJEnInd > 0 And Not hayPretorianos Then
                    If Not (UserList(PJEnInd).flags.Muerto = 1 Or UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1 Or UserList(PJEnInd).flags.Ceguera = 1) And UserList(PJEnInd).flags.AdminPerseguible Then
                        ''si no esta muerto o invisible o ciego... o tiene el /ignorando
                        dist = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                        If (dist < distBestTarget Or BestTarget = 0) Then
                            BestTarget = PJEnInd
                            distBestTarget = dist
                        End If
                    End If
                End If
            End If  ''canattack = 1
        Next Y
    Next X
    If Npclist(npcind).flags.Paralizado = 1 Or Npclist(npcind).flags.Inmovilizado = 1 Then
        Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, RandomNumber(1, 4))
        Exit Sub
    End If
    If Not hayPretorianos Then
        ''si estoy aca es porque no hay pretorianos cerca!!!
        ''Todo mi ejercito fue asesinado
        ''Salgo a atacar a todos a lo loco a espadazos
        If BestTarget > 0 Then
            If EsAlcanzable(npcind, BestTarget) Then
                If Npclist(npcind).flags.Paralizado = 0 And Npclist(npcind).flags.Inmovilizado = 0 Then Call MOVIMIENTOWAR(npcind, UserList(BestTarget).Pos.map, UserList(BestTarget).Pos.X, UserList(BestTarget).Pos.Y)
                'GreedyWalkTo npcind, UserList(BestTarget).Pos.Map, UserList(BestTarget).Pos.X, UserList(BestTarget).Pos.Y
            Else
                 If Round(RandomNumber(0, mankismo + 1)) = 0 Then
                     Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(Npclist(npcind).Spells(4)).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                     Call NpcLanzaSpellSobreUser(npcind, BestTarget, Npclist(npcind).Spells(4)) ''SPELL 1 de Clerigo es PARALIZAR
                 End If
            End If
            
            ''heading loop de ataque
            ''teclavolaespada
                If Npclist(npcind).Stats.MinHP < Npclist(npcind).Stats.MaxHP Then
                    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
                    If Npclist(npcind).Stats.MinHP + 20 > Npclist(npcind).Stats.MaxHP Then
                        Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP
                    Else
                        Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MinHP + 20
                    End If
                Else
                    If Npclist(npcind).CanAttack = 1 Then
                    For headingloop = eHeading.NORTH To eHeading.WEST
                        npos = Npclist(npcind).Pos
                        Call HeadtoPos(headingloop, npos)
                        If InMapBounds(npos.map, npos.X, npos.Y) Then
                            UI = MapData(npos.map, npos.X, npos.Y).UserIndex
                            If UI > 0 Then
                                If NpcAtacaUser(npcind, UI) Then
                                    If Round(RandomNumber(0, mankismo)) = 0 Then Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, headingloop)
                                End If
                                
                                ''special speed ability for praetorian king ---------
                                'Npclist(npcind).CanAttack = 1   ''this is NOT a bug!!
                                '----------------------------------------------------
                            
                            End If
                        End If
                    Next headingloop
                End If
        End If
        Else    ''no hay targets cerca
            Call VolverAlCentro(npcind)
        End If
    End If
Exit Sub

errorh:
    LogError ("Error en NPCAI.PRREY_AI? ")
    
End Sub

Sub PRGUER_AI(ByVal npcind As Integer)
'Exit Sub
'On Error GoTo errorh

    Dim headingloop As Byte
    Dim npos As WorldPos
    Dim X As Integer
    Dim Y As Integer
    Dim dist As Integer
    Dim distBestTarget As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    Dim NPCAlInd As Integer
    Dim UI As Integer
    Dim PJEnInd As Integer
    Dim BestTarget As Integer
    NPCPosM = Npclist(npcind).Pos.map
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    BestTarget = 0
    dist = 0
    distBestTarget = 0
    Dim ni As Integer
    Dim np As Boolean
    Dim sigo As Boolean
    For X = NPCPosX - 8 To NPCPosX + 8
    If sigo = False Then
        For Y = NPCPosY - 8 To NPCPosY + 8
            PJEnInd = MapData(NPCPosM, X, Y).UserIndex
            ni = MapData(NPCPosM, X, Y).NpcIndex
            If (PJEnInd > 0) Then
                If (Not (UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1 Or UserList(PJEnInd).flags.Muerto = 1)) And EsAlcanzable(npcind, PJEnInd) And UserList(PJEnInd).flags.AdminPerseguible Then
                    ''caluclo la distancia al PJ, si esta mas cerca q el actual
                    ''mejor besttarget entonces ataco a ese.
                    If (BestTarget > 0) Then
                        dist = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                        If (dist < distBestTarget) Then
                            BestTarget = PJEnInd
                            distBestTarget = dist
                            sigo = True
                        End If
                    Else
                        distBestTarget = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                        BestTarget = PJEnInd
                    End If
                End If
            ElseIf (ni > 0) Then
                    ''caluclo la distancia al PJ, si esta mas cerca q el actual
                    ''mejor besttarget entonces ataco a ese.
                    If (BestTarget > 0) Then
                        dist = Sqr((Npclist(ni).Pos.X - NPCPosX) ^ 2 + (Npclist(ni).Pos.Y - NPCPosY) ^ 2)
                        If (dist < distBestTarget) Then
                            BestTarget = ni
                            np = True
                            distBestTarget = dist
                            sigo = True
                        End If
                    Else
                        distBestTarget = Sqr((Npclist(ni).Pos.X - NPCPosX) ^ 2 + (Npclist(ni).Pos.Y - NPCPosY) ^ 2) 'Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                        BestTarget = ni
                        np = True
                    End If
            End If
        Next Y
        End If
    Next X
ni = 0
    ''LLamo a esta funcion si lo llevaron muy lejos.
    ''La idea es que no lo "alejen" del rey y despues queden
    ''lejos de la batalla cuando matan a un enemigo o este
    ''sale del area de combate (tipica forma de separar un clan)
    If Npclist(npcind).flags.Paralizado = 0 Then
        'MEJORA: Si quedan solos, se van con el resto del ejercito
        'If Npclist(npcind).Invent.ArmourEqpSlot <> 0 Then
        '    Call CambiarAlcoba(npcind)
        'Else
        If BestTarget < 1 Then
        '    Call VolverAlCentro(npcind)

            For X = 9 To 95
            For Y = 9 To 95
                    BestTarget = MapData(servermap, X, Y).UserIndex
                    NPCAlInd = MapData(servermap, X, Y).NpcIndex
                    If NPCAlInd > 0 Then
                            Call MOVIMIENTOWAR(npcind, servermap, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y)
                            Exit Sub
                    ElseIf BestTarget > 0 Then
                            Call MOVIMIENTOWAR(npcind, servermap, UserList(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y)
                            Exit Sub
                    End If

            Next Y
        Next X
        ElseIf BestTarget > 0 Then
            If np = True Then
                Call MOVIMIENTOWAR(npcind, servermap, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y)
            Else
                Call MOVIMIENTOWAR(npcind, servermap, UserList(BestTarget).Pos.X, UserList(BestTarget).Pos.Y)
            End If
        End If
    Else
        Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, RandomNumber(1, 4))
    End If

''teclavolaespada
    If Npclist(npcind).Stats.MinHP < Npclist(npcind).Stats.MaxHP Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        If Npclist(npcind).Stats.MinHP + 20 > Npclist(npcind).Stats.MaxHP Then
            Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP
        Else
            Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MinHP + 20
        End If
    Else

        For headingloop = eHeading.EAST To eHeading.WEST
            npos = Npclist(npcind).Pos
            Call HeadtoPos(headingloop, npos)
            If InMapBounds(npos.map, npos.X, npos.Y) Then
                UI = MapData(npos.map, npos.X, npos.Y).UserIndex
                ni = MapData(npos.map, npos.X, npos.Y).NpcIndex
                If UI > 0 Then
                    If Not (UserList(UI).flags.Muerto = 1) Then
                    Npclist(npcind).Char.heading = headingloop
                    Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, headingloop)
                        If Round(RandomNumber(0, mankismo)) = 0 Then
                            Call NpcAtacaUser(npcind, UI)
                        End If
                        'Npclist(npcind).CanAttack = 0
                        Exit For
                    End If
                    
                ElseIf ni > 0 Then
                    Npclist(npcind).Char.heading = headingloop
                    Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, headingloop)
                    If Round(RandomNumber(0, mankismo)) = 0 Then
                        SistemaCombate.NpcAtacaNpc npcind, ni, False
                    End If
                    'Npclist(npcind).CanAttack = 0
                    Exit For
                End If
            End If
        Next headingloop
    End If

Exit Sub

errorh:
    LogError ("Error en NPCAI.PRGUER_AI? ")
    

End Sub

Sub PRCLER_AI(ByVal npcind As Integer)
On Error GoTo errorh
    
    'HECHIZOS: NO CAMBIAR ACA
    'REPRESENTAN LA UBICACION DE LOS SPELLS EN NPC_HOSTILES.DAT y si se los puede cambiar en ese archivo
    '1- PARALIZAR PJS 'MODIFICABLE
    '2- REMOVER PARALISIS 'NO MODIFICABLE
    '3- CURARGRAVES - 'NO MODIFICABLE
    '4- PARALIZAR MASCOTAS - 'NO MODIFICABLE
    '5- CURARVENENO - 'NO MODIFICABLE
    Dim DAT_PARALIZARPJ As Integer
    Dim DAT_REMUEVEPARALISIS As Integer
    Dim DAT_CURARGRAVES As Integer
    Dim DAT_PARALIZAR_NPC As Integer
    Dim DAT_TORMENTAAVANZADA As Integer
    DAT_PARALIZARPJ = 24 'MENDUZ A LA HARCODEADA MANDA(?)
    DAT_REMUEVEPARALISIS = 2
    DAT_PARALIZAR_NPC = 3
    DAT_CURARGRAVES = 4
    DAT_TORMENTAAVANZADA = 5

    Dim X As Integer
    Dim Y As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    Dim NPCAlInd As Integer
    Dim PJEnInd As Integer
    Dim centroX As Integer
    Dim centroY As Integer
    Dim BestTarget As Integer
    Dim PJBestTarget As Boolean
    Dim azar, azar2 As Integer
    Dim quehacer As Byte
    Dim np As Boolean
        ''1- paralizar enemigo,
        ''2- bombardear enemigo
        ''3- ataque a mascotas
        ''4- curar aliado
    quehacer = 0
    NPCPosM = Npclist(npcind).Pos.map
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    PJBestTarget = False
    BestTarget = 0
    
    azar = Sgn(RandomNumber(-1, 1))
    If azar = 0 Then azar = 1
    azar2 = Sgn(RandomNumber(-1, 1))
    If azar2 = 0 Then azar2 = 1

    'pick the best target according to the following criteria:
    '1) "hoaxed" friends MUST be released
    '2) enemy shall be annihilated no matter what
    '3) party healing if no threats
        If Npclist(npcind).CanAttack = 1 Then
    Dim headingloop As Integer
    Dim npos As WorldPos
        For headingloop = 1 To 4
            npos = Npclist(npcind).Pos
            Call HeadtoPos(headingloop, npos)
            If InMapBounds(npos.map, npos.X, npos.Y) Then
                PJEnInd = MapData(npos.map, npos.X, npos.Y).UserIndex
                NPCAlInd = MapData(npos.map, npos.X, npos.Y).NpcIndex
                If PJEnInd > 0 Then
                    If Not (UserList(PJEnInd).flags.Muerto = 1) And (UserList(PJEnInd).bando <> Npclist(npcind).bando) Then
                        Npclist(npcind).Char.heading = headingloop
                        Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, headingloop)
                            If NpcAtacaUser(npcind, PJEnInd) = True Then Exit Sub
                    End If
                ElseIf NPCAlInd > 0 Then
                    If (Npclist(NPCAlInd).bando <> Npclist(npcind).bando) Then
                        Npclist(npcind).Char.heading = headingloop
                        Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, headingloop)
                            SistemaCombate.NpcAtacaNpc npcind, NPCAlInd, False
                            Exit Sub
                    End If
                End If
            End If
        Next headingloop
End If
    If Npclist(npcind).flags.Paralizado = 1 Or Npclist(npcind).flags.Inmovilizado = 1 Then
        'ESTOY
        If Round(RandomNumber(0, mankismo + 5)) = 0 Then
            Call NPCRemueveParalisisNPC(npcind, npcind, DAT_REMUEVEPARALISIS)
        End If
        Exit Sub
    End If
    For X = NPCPosX + (azar * 10) To NPCPosX + (azar * -10) Step -azar
    If PJBestTarget = False Then
        For Y = NPCPosY + (azar2 * 10) To NPCPosY + (azar2 * -10) Step -azar2
            'scan combat field
            NPCAlInd = MapData(NPCPosM, X, Y).NpcIndex
            PJEnInd = MapData(NPCPosM, X, Y).UserIndex
            If (Npclist(npcind).CanAttack = 1) Then   ''saltea el analisis si no puede atacar para evitar cuentas
                If (PJEnInd > 0) Then ''aggressor
                    If Not (UserList(PJEnInd).flags.Muerto = 1) Then
                        If UserList(PJEnInd).bando = Npclist(npcind).bando Then
                            If UserList(PJEnInd).flags.Paralizado Then
                                'If Not (BestTarget > 0) Or Not (PJBestTarget) Then ''a menos q tenga algo mejor
                                    BestTarget = PJEnInd
                                    PJBestTarget = True
                                    quehacer = 20
                                    GoTo siguiente
                                    Exit For
                                'End If
                            End If  ''endif paralizado
                        Else
                            If (UserList(PJEnInd).flags.Paralizado = 0) Then
                                If (Not (UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1)) Then
                                    ''PJ movil y visible, jeje, si o si es target
                                    BestTarget = PJEnInd
                                    PJBestTarget = True
                                    quehacer = 1
                                    GoTo siguiente
                                    Exit For
                                End If
                            Else    ''PJ paralizado, ataca este invisible o no
                                    BestTarget = PJEnInd
                                    PJBestTarget = True
                                    quehacer = 2
                                    GoTo siguiente
                                    Exit For
                            End If  ''endif paralizado
                        End If
                    End If  ''end if not muerto
                ElseIf (NPCAlInd > 0) Then  ''allie?
                    If Npclist(npcind).bando <> Npclist(NPCAlInd).bando Then
                        BestTarget = NPCAlInd
                        quehacer = 30
                        np = True
                        If Npclist(NPCAlInd).flags.Paralizado = 0 Then
                            If Round(RandomNumber(0, (mankismo + 1) * 3)) = 0 Then
                                Call NPCparalizaNPC(npcind, NPCAlInd, DAT_PARALIZAR_NPC)
                            End If
                            'Npclist(npcind).CanAttack = 0
                            'Exit Sub
                        End If

                    Else    'es un PJ aliado en combate
                        If Npclist(NPCAlInd).flags.Paralizado = 1 Or Npclist(NPCAlInd).flags.Inmovilizado = 1 Then
                            ' amigo paralizado, an hoax vorp YA
                            If Round(RandomNumber(0, mankismo + 2)) = 0 Then
                                Call NPCRemueveParalisisNPC(npcind, NPCAlInd, DAT_REMUEVEPARALISIS)
                            End If
                            'Npclist(npcind).CanAttack = 0
                            'Exit Sub
                        End If
                    End If
                
                End If  ''listo el analisis del tile
            End If  ''saltea el analisis si no puede atacar, en realidad no es lo "mejor" pero evita cuentas in�tiles
        Next Y
    End If
    Next X
siguiente:
            If Npclist(npcind).Stats.MaxMAN = 0 Then
                Npclist(npcind).Stats.MaxMAN = 1500
                Npclist(npcind).Stats.MinMAN = 1500
            End If
    ''aqui (si llego) tiene el mejor target
        If Npclist(npcind).Stats.MinHP < Npclist(npcind).Stats.MaxHP Then
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
            If Npclist(npcind).Stats.MinHP + 20 > Npclist(npcind).Stats.MaxHP Then
                Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP
            Else
                Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MinHP + 20
            End If
            GoTo karlos
        ElseIf Npclist(npcind).Stats.MinMAN < Npclist(npcind).Stats.MaxMAN And Npclist(npcind).Stats.MinHP = Npclist(npcind).Stats.MaxHP Then
            'Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SND_BEBER, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
            If Npclist(npcind).Stats.MinMAN + 30 > Npclist(npcind).Stats.MaxMAN Then
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MaxMAN
            Else
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN + Porcentaje(Npclist(npcind).Stats.MaxMAN, 5)
            End If
        End If
    Select Case quehacer
    Case 0
        ''nada que hacer. Buscar mas alla del campo de visi�n algun aliado, a menos
        ''que este paralizado pq no puedo ir
        If Npclist(npcind).flags.Paralizado = 1 Then
        Npclist(npcind).Char.heading = RandomNumber(1, 4)
        Exit Sub
        End If
        
        'If Not NPCPosM = servermap Then Exit Sub
        
        'If NPCPosX < 50 Then centroX = ALCOBA1_X Else centroX = ALCOBA2_X
        'centroY = ALCOBA1_Y
        ''aca establec� el lugar de las alcobas
        
        ''Este doble for busca amigos paralizados lejos para ir a rescatarlos
        ''Entra aca solo si en el area cercana al rey no hay algo mejor que
        ''hacer.
        'For X = centroX - 16 To centroX + 16
        '    For Y = centroY - 15 To centroY + 15
        '        If Not (X < NPCPosX + 8 And X > NPCPosX + 8 And Y < NPCPosY + 7 And Y > NPCPosY - 7) Then
        '        ''si no es un tile ya analizado... (evito cuentas)
        '            NPCAlInd = MapData(NPCPosM, X, Y).NpcIndex
        '            If NPCAlInd > 0 Then
        '                If (esPretoriano(NPCAlInd) > 0 And Npclist(NPCAlInd).flags.Paralizado = 1) Then
        '                    ''si esta paralizado lo va a rescatar, sino
        '                    ''ya va a volver por su cuenta
        '                    Call MOVIMIENTOWAR(npcind, NPCPosM, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y)
'       '                     GreedyWalkTo npcind, NPCPosM, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y
        '                    Exit Sub
        '                End If
        '            End If  ''endif npc
        '        End If  ''endif tile analizado
        '    Next Y
        'Next X

        ''si estoy aca esta totalmente al cuete el clerigo o mal posicionado por rescate anterior
        'If Npclist(npcind).Invent.ArmourEqpSlot = 0 Then
        '    Call VolverAlCentro(npcind)
        '    Exit Sub
        'End If
        ''fin quehacer = 0 (npc al cuete)
        
    Case 1  '' paralizar enemigo PJ
        If Round(RandomNumber(0, mankismo)) = 0 Then
            If Npclist(npcind).Stats.MinMAN > Hechizos(24).ManaRequerido Then
                'Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(24).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                Call NpcLanzaSpellSobreUser(npcind, BestTarget, 24) ''SPELL 1 de Clerigo es PARALIZAR
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(24).ManaRequerido
            End If
            
        End If
        'Npclist(npcind).CanAttack = 0
        
    Case 20  '' REMOVER AMIGO
        If Round(RandomNumber(0, IIf(mankismo - 1 < 0, 0, mankismo - 1))) = 0 Then
            If Npclist(npcind).Stats.MinMAN > Hechizos(10).ManaRequerido Then
                Call NpcLanzaSpellSobreUser(npcind, BestTarget, 10) ''SPELL 1 de Clerigo es PARALIZAR
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(10).ManaRequerido
            End If

        End If
        'Npclist(npcind).CanAttack = 0
    Case 2  '' ataque a usuarios (invisibles tambien)
        If Round(RandomNumber(0, mankismo + 2)) = 0 Then
            If Npclist(npcind).Stats.MinMAN > Hechizos(Npclist(npcind).Spells(DAT_TORMENTAAVANZADA)).ManaRequerido Then
                Call NpcLanzaSpellSobreUser(npcind, BestTarget, Npclist(npcind).Spells(DAT_TORMENTAAVANZADA)) ''SPELL 2 de Clerigo es Vax On Tar avanzado
                Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(DAT_TORMENTAAVANZADA).ManaRequerido
            End If

        End If
        'Npclist(npcind).CanAttack = 0

    Case 3  '' ataque a mascotas
        If Npclist(npcind).Stats.MinMAN > Hechizos(Npclist(npcind).Spells(DAT_PARALIZAR_NPC)).ManaRequerido Then
            If Round(RandomNumber(0, mankismo + 2)) = 0 Then
                If Not (Npclist(BestTarget).flags.Paralizado = 1) Then
                        Call NPCparalizaNPC(npcind, BestTarget, DAT_PARALIZAR_NPC)
                        'Npclist(npcind).CanAttack = 0
                        Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(DAT_PARALIZAR_NPC).ManaRequerido
                End If  ''TODO: vax on tar sobre mascotas
            End If
        End If
    Case 30  '' ataque a enemigobots
        If Npclist(npcind).Stats.MinMAN > Hechizos(15).ManaRequerido Then
            If Round(RandomNumber(0, mankismo + 3)) = 0 Then
                        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(15).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
                        Call NpcLanzaSpellSobreNpc(npcind, BestTarget, 15)
                        Dim da�o As Long
                        da�o = RandomNumber(Hechizos(15).MinHP, Hechizos(15).MaxHP)
                        Call SendData(SendTarget.ToNPCArea, BestTarget, PrepareMessagePlayWave(Hechizos(15).WAV, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y))
                        Call SendData(SendTarget.ToNPCArea, BestTarget, PrepareMessageCreateFX(Npclist(BestTarget).Char.CharIndex, Hechizos(15).FXgrh, Hechizos(15).loops))
                        
                        Npclist(BestTarget).Stats.MinHP = Npclist(BestTarget).Stats.MinHP - da�o
                        
                        'Muere
                        If Npclist(BestTarget).Stats.MinHP < 1 Then
                            Npclist(BestTarget).Stats.MinHP = 0
                            Call MuereNpc(BestTarget, 0)
                        End If
                        'Npclist(npcind).CanAttack = 0
                        Npclist(npcind).Stats.MinMAN = Npclist(npcind).Stats.MinMAN - Hechizos(15).ManaRequerido
                        Npclist(npcind).CanAttack = 0
            End If
        End If
    End Select

    ''movimientos
    ''EL clerigo no tiene un movimiento fijo, pero es esperable
    ''que no se aleje mucho del rey... y si se aleje de espaderos
    
If Npclist(npcind).flags.Paralizado = 1 Or Npclist(npcind).flags.Inmovilizado = 1 Then
Call ChangeNPCChar(npcind, Npclist(npcind).Char.body, Npclist(npcind).Char.Head, RandomNumber(1, 4))
Exit Sub
End If
    
    'MEJORA: Si quedan solos, se van con el resto del ejercito
    'If Npclist(npcind).Invent.ArmourEqpSlot <> 0 Then
        'Call CambiarAlcoba(npcind)
        'Exit Sub
    'End If

        If Npclist(npcind).flags.AtacaAPJ > 0 Then
            If (UserList(Npclist(npcind).flags.AtacaAPJ).flags.invisible = 1 Or UserList(Npclist(npcind).flags.AtacaAPJ).flags.Oculto = 1 Or UserList(Npclist(npcind).flags.AtacaAPJ).flags.Muerto = 1) Then Npclist(npcind).flags.AtacaAPJ = 0
        End If
        
        If BestTarget > 0 Then GoTo karlos
        If Npclist(npcind).flags.AtacaAPJ > 0 Then GoTo karlos
        'If (BestTarget = 0) And (Npclist(npcind).flags.AtacaAPJ = 0 And Npclist(npcind).flags.AtacaANPC = 0) Then
            'Call VolverAlCentro(npcind)
            Dim distBestTarget As Long
            Dim dist As Long
            Dim ni As Integer
            Dim espj As Long
            For X = 9 To 95
            For Y = 9 To 95
                    PJEnInd = MapData(NPCPosM, X, Y).UserIndex
                    ni = MapData(NPCPosM, X, Y).NpcIndex
            
                    If (PJEnInd > 0) Then
                        If (Not (UserList(PJEnInd).flags.invisible = 1 Or UserList(PJEnInd).flags.Oculto = 1 Or UserList(PJEnInd).flags.Muerto = 1)) Then
                            ''caluclo la distancia al PJ, si esta mas cerca q el actual
                            ''mejor besttarget entonces ataco a ese.
                            If (BestTarget > 0) And UserList(PJEnInd).bando <> Npclist(npcind).bando Then
                                dist = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                                If (dist < distBestTarget) Then
                                    BestTarget = PJEnInd
                                    np = False
                                    distBestTarget = dist
                                    Npclist(npcind).flags.AtacaAPJ = PJEnInd
                                    espj = True
                                End If
                            Else
                                distBestTarget = Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                                BestTarget = PJEnInd
                                np = False
                                espj = True
                            End If
                        End If
                    ElseIf (ni > 0) And espj = False Then
                            ''caluclo la distancia al PJ, si esta mas cerca q el actual
                            ''mejor besttarget entonces ataco a ese.
                            If (BestTarget > 0) And Npclist(ni).bando <> Npclist(npcind).bando Then
                                dist = Sqr((Npclist(ni).Pos.X - NPCPosX) ^ 2 + (Npclist(ni).Pos.Y - NPCPosY) ^ 2)
                                If (dist < distBestTarget) Then
                                    BestTarget = ni
                                    np = True
                                    Npclist(npcind).flags.AtacaANPC = ni
                                    distBestTarget = dist
                                End If
                            Else
                                distBestTarget = Sqr((Npclist(ni).Pos.X - NPCPosX) ^ 2 + (Npclist(ni).Pos.Y - NPCPosY) ^ 2) 'Sqr((UserList(PJEnInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJEnInd).Pos.Y - NPCPosY) ^ 2)
                                BestTarget = ni
                                np = True
                            End If
                    End If
            
            Next Y
        Next X

GoTo karlos
karlos:
If Npclist(npcind).flags.Paralizado = 1 Then Exit Sub
    If BestTarget > 0 Then
        If np = True Then
            MOVIMIENTOWAR npcind, Npclist(npcind).Pos.map, Npclist(BestTarget).Pos.X, Npclist(BestTarget).Pos.Y
        Else
            MOVIMIENTOWAR npcind, Npclist(npcind).Pos.map, UserList(BestTarget).Pos.X, UserList(BestTarget).Pos.Y
        End If
        Exit Sub
    ElseIf Npclist(npcind).flags.AtacaAPJ > 0 Then
                    MOVIMIENTOWAR npcind, Npclist(npcind).Pos.map, UserList(Npclist(npcind).flags.AtacaAPJ).Pos.X, UserList(Npclist(npcind).flags.AtacaAPJ).Pos.Y
                    Exit Sub
    ElseIf Npclist(npcind).flags.AtacaANPC > 0 Then
                    MOVIMIENTOWAR npcind, Npclist(npcind).Pos.map, Npclist(Npclist(npcind).flags.AtacaANPC).Pos.X, Npclist(Npclist(npcind).flags.AtacaANPC).Pos.Y
                    Exit Sub
End If


Dim mueje As Integer
mueje = RandomNumber(2, 8) / 2
Select Case mueje
Case 1
                If LegalPos(servermap, NPCPosX, NPCPosY + 1) Then
                    Call MoverAba(npcind)
                    Exit Sub
                End If
Case 2
                If LegalPos(servermap, NPCPosX - 1, NPCPosY) Then
                    Call MoverIzq(npcind)
                    Exit Sub
                End If
Case 3
                If LegalPos(servermap, NPCPosX + 1, NPCPosY) Then
                    Call MoverDer(npcind)
                    Exit Sub
                End If
Case 4
                If LegalPos(servermap, NPCPosX, NPCPosY - 1) Then
                    Call MoverArr(npcind)
                    Exit Sub
                End If
End Select
Exit Sub

errorh:
    LogError ("Error en NPCAI.PRCLER_AI? ")
    
End Sub

Function EsMagoOClerigo(ByVal PJEnInd As Integer) As Boolean
On Error GoTo errorh

    EsMagoOClerigo = UserList(PJEnInd).clase = eClass.Mage Or _
                        UserList(PJEnInd).clase = eClass.Cleric Or _
                        UserList(PJEnInd).clase = eClass.Druid Or _
                        UserList(PJEnInd).clase = eClass.Bard
Exit Function

errorh:
    LogError ("Error en NPCAI.EsMagoOClerigo? ")
End Function

Sub NPCRemueveVenenoNPC(ByVal npcind As Integer, ByVal NPCAlInd As Integer, ByVal indice As Integer)
On Error GoTo errorh
    Dim indireccion As Integer
    
    indireccion = Npclist(npcind).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(indireccion).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessageCreateFX(Npclist(NPCAlInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y))
    Npclist(NPCAlInd).Veneno = 0
    Npclist(NPCAlInd).flags.Envenenado = 0

Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCRemueveVenenoNPC? ")

End Sub

Sub NPCCuraLevesNPC(ByVal npcind As Integer, ByVal NPCAlInd As Integer, ByVal indice As Integer)
Exit Sub
On Error GoTo errorh
    Dim indireccion As Integer
    
    indireccion = Npclist(npcind).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(indireccion).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y))
    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessageCreateFX(Npclist(NPCAlInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    
    If (Npclist(NPCAlInd).Stats.MinHP + 5 < Npclist(NPCAlInd).Stats.MaxHP) Then
        Npclist(NPCAlInd).Stats.MinHP = Npclist(NPCAlInd).Stats.MinHP + 5
    Else
        Npclist(NPCAlInd).Stats.MinHP = Npclist(NPCAlInd).Stats.MaxHP
    End If
    
Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCCuraLevesNPC? ")
    
End Sub


Sub NPCRemueveParalisisNPC(ByVal npcind As Integer, ByVal NPCAlInd As Integer, ByVal indice As Integer)
On Error GoTo errorh
    Dim indireccion As Integer
    If puede_npc(npcind, 1000, False) = False Then Exit Sub
Npclist(npcind).ultimox = GetTickCount()
    indireccion = Npclist(npcind).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("AN HOAX VORP", Npclist(npcind).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, Npclist(NPCAlInd).Pos.X, Npclist(NPCAlInd).Pos.Y))
    Call SendData(SendTarget.ToNPCArea, NPCAlInd, PrepareMessageCreateFX(Npclist(NPCAlInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    Npclist(NPCAlInd).Contadores.Paralisis = 0
    Npclist(NPCAlInd).flags.Inmovilizado = 0
    Npclist(NPCAlInd).flags.Paralizado = 0
Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCRemueveParalisisNPC? " & Err.Description)

End Sub

Sub NPCparalizaNPC(ByVal paralizador As Integer, ByVal Paralizado As Integer, ByVal indice)
If puede_npc(paralizador, 1000, False) = False Then Exit Sub
Npclist(paralizador).ultimox = GetTickCount()
On Error GoTo errorh
    Dim indireccion As Integer
    
    indireccion = Npclist(paralizador).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, paralizador, PrepareMessageChatOverHead("HOAX VORP", Npclist(paralizador).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, Paralizado, PrepareMessagePlayWave(Hechizos(indireccion).WAV, Npclist(Paralizado).Pos.X, Npclist(Paralizado).Pos.Y))
    Call SendData(SendTarget.ToNPCArea, Paralizado, PrepareMessageCreateFX(Npclist(Paralizado).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    
    Npclist(Paralizado).flags.Paralizado = 1
    Npclist(Paralizado).Contadores.Paralisis = IntervaloParalizado

Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCParalizaNPC? ")

End Sub

Sub NPCcuraNPC(ByVal curador As Integer, ByVal curado As Integer, ByVal indice As Integer)
Exit Sub
On Error GoTo errorh
    Dim indireccion As Integer
    

    indireccion = Npclist(curador).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, curador, PrepareMessageChatOverHead(Hechizos(indireccion).PalabrasMagicas, Npclist(curador).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, curado, PrepareMessagePlayWave(Hechizos(indireccion).WAV, Npclist(curado).Pos.X, Npclist(curado).Pos.Y))
    Call SendData(SendTarget.ToNPCArea, curado, PrepareMessageCreateFX(Npclist(curado).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    If Npclist(curado).Stats.MinHP + 30 > Npclist(curado).Stats.MaxHP Then
        Npclist(curado).Stats.MinHP = Npclist(curado).Stats.MaxHP
    Else
        Npclist(curado).Stats.MinHP = Npclist(curado).Stats.MinHP + 30
    End If
Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCcuraNPC? ")

End Sub

Sub NPCLanzaCegueraPJ(ByVal npcind As Integer, ByVal PJEnInd As Integer, ByVal indice As Integer)
On Error GoTo errorh
    Dim indireccion As Integer
    
    indireccion = Npclist(npcind).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(indireccion).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, PJEnInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, UserList(PJEnInd).Pos.X, UserList(PJEnInd).Pos.Y))
    Call SendData(SendTarget.ToPCArea, PJEnInd, PrepareMessageCreateFX(UserList(PJEnInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    
    UserList(PJEnInd).flags.Ceguera = 1
    UserList(PJEnInd).Counters.Ceguera = IntervaloInvisible
    ''Envia ceguera
    Call WriteBlind(PJEnInd)
    ''bardea si es el rey
    If Npclist(npcind).name = "Rey Pretoriano" Then
        Call WriteConsoleMsg(PJEnInd, "El rey pretoriano te ha vuelto ciego ", FontTypeNames.FONTTYPE_FIGHT)
        Call WriteConsoleMsg(PJEnInd, "A la distancia escuchas las siguientes palabras: �Cobarde, no eres digno de luchar conmigo si escapas! ", FontTypeNames.FONTTYPE_VENENO)
    End If

Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCLanzaCegueraPJ? ")
End Sub

Sub NPCLanzaEstupidezPJ(ByVal npcind As Integer, ByVal PJEnInd As Integer, ByVal indice As Integer)
On Error GoTo errorh
    Dim indireccion As Integer
    

    indireccion = Npclist(npcind).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(indireccion).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, PJEnInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, UserList(PJEnInd).Pos.X, UserList(PJEnInd).Pos.Y))
    Call SendData(SendTarget.ToPCArea, PJEnInd, PrepareMessageCreateFX(UserList(PJEnInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    UserList(PJEnInd).flags.Estupidez = 1
    UserList(PJEnInd).Counters.Estupidez = IntervaloInvisible
    'manda estupidez
    Call WriteDumb(PJEnInd)

    'bardea si es el rey
    If Npclist(npcind).name = "Rey Pretoriano" Then
        Call WriteConsoleMsg(PJEnInd, "El rey pretoriano te ha vuelto est�pido ", FontTypeNames.FONTTYPE_FIGHT)
    End If
Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCLanzaEstupidezPJ? ")
End Sub

Sub NPCRemueveInvisibilidad(ByVal npcind As Integer, ByVal PJEnInd As Integer, ByVal indice As Integer)
Exit Sub
On Error GoTo errorh
    Dim indireccion As Integer
    
    indireccion = Npclist(npcind).Spells(indice)
    '' Envia las palabras magicas, fx y wav del indice-esimo hechizo del npc-hostiles.dat
    Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(Hechizos(indireccion).PalabrasMagicas, Npclist(npcind).Char.CharIndex, vbCyan))
    Call SendData(SendTarget.ToNPCArea, PJEnInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, UserList(PJEnInd).Pos.X, UserList(PJEnInd).Pos.Y))
    Call SendData(SendTarget.ToPCArea, PJEnInd, PrepareMessageCreateFX(UserList(PJEnInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
    
    'Sacamos el efecto de ocultarse
    If UserList(PJEnInd).flags.Oculto = 1 Then
        UserList(PJEnInd).Counters.TiempoOculto = 0
        UserList(PJEnInd).flags.Oculto = 0
        Call SendData(SendTarget.ToPCArea, PJEnInd, PrepareMessageSetInvisible(UserList(PJEnInd).Char.CharIndex, False))
        Call WriteConsoleMsg(PJEnInd, "�Has sido detectado!", FontTypeNames.FONTTYPE_VENENO)
    Else
    'sino, solo lo "iniciamos" en la sacada de invisibilidad.
        Call WriteConsoleMsg(PJEnInd, "Comienzas a hacerte visible.", FontTypeNames.FONTTYPE_VENENO)
        UserList(PJEnInd).Counters.Invisibilidad = IntervaloInvisible - 1
    End If

    
Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCRemueveInvisibilidad ")

End Sub

Sub NpcLanzaSpellSobreUser2(ByVal NpcIndex As Integer, ByVal UserIndex As Integer, ByVal Spell As Integer)
On Error GoTo errorh
''  Igual a la otra pero ataca invisibles!!!
'' (malditos controles de casos imposibles...)
If puede_npc(NpcIndex, 1700, False) = False Then Exit Sub
Npclist(NpcIndex).ultimox = GetTickCount()
'If Npclist(NpcIndex).CanAttack = 0 Then Exit Sub
If UserIndex < 1 Then Exit Sub



'If Npclist(NpcIndex).CanAttack = 0 Then Exit Sub
'If UserList(UserIndex).Flags.Invisible = 1 Then Exit Sub

Npclist(NpcIndex).CanAttack = 0
Dim da�o As Integer
Call SendData(SendTarget.ToNPCArea, NpcIndex, PrepareMessageChatOverHead(Hechizos(Spell).PalabrasMagicas, Npclist(NpcIndex).Char.CharIndex, vbCyan))
Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(Hechizos(Spell).WAV, UserList(UserIndex).Pos.X, UserList(UserIndex).Pos.Y))
Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessageCreateFX(UserList(UserIndex).Char.CharIndex, Hechizos(Spell).FXgrh, Hechizos(Spell).loops))
If Hechizos(Spell).SubeHP = 1 Then

    da�o = RandomNumber(Hechizos(Spell).MinHP, Hechizos(Spell).MaxHP)
    Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(Hechizos(Spell).WAV, UserList(UserIndex).Pos.X, UserList(UserIndex).Pos.Y))
    Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessageCreateFX(UserList(UserIndex).Char.CharIndex, Hechizos(Spell).FXgrh, Hechizos(Spell).loops))

    UserList(UserIndex).Stats.MinHP = UserList(UserIndex).Stats.MinHP + da�o
    If UserList(UserIndex).Stats.MinHP > UserList(UserIndex).Stats.MaxHP Then UserList(UserIndex).Stats.MinHP = UserList(UserIndex).Stats.MaxHP
    
    Call WriteConsoleMsg(UserIndex, Npclist(NpcIndex).name & " repuesto " & da�o & " puntos de vida.", FontTypeNames.FONTTYPE_FIGHT)
    
ElseIf Hechizos(Spell).SubeHP = 2 Then
    
    da�o = RandomNumber(Hechizos(Spell).MinHP * 2, Hechizos(Spell).MaxHP * 2)
    Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(Hechizos(Spell).WAV, UserList(UserIndex).Pos.X, UserList(UserIndex).Pos.Y))
    Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessageCreateFX(UserList(UserIndex).Char.CharIndex, Hechizos(Spell).FXgrh, Hechizos(Spell).loops))

UserList(UserIndex).Stats.MinHP = UserList(UserIndex).Stats.MinHP - da�o
    
    Call WriteConsoleMsg(UserIndex, Npclist(NpcIndex).name & " te ha quitado " & da�o & " puntos de vida.", FontTypeNames.FONTTYPE_FIGHT)
    
    'Muere
    If UserList(UserIndex).Stats.MinHP < 1 Then
        UserList(UserIndex).Stats.MinHP = 0
        Call UserDie(UserIndex)
    End If
    
End If

If Hechizos(Spell).Paraliza = 1 Then
     If UserList(UserIndex).flags.Inmovilizado = 0 Then
          UserList(UserIndex).flags.Inmovilizado = 1
          UserList(UserIndex).Counters.Paralisis = IntervaloParalizado
          Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(Hechizos(Spell).WAV, UserList(UserIndex).Pos.X, UserList(UserIndex).Pos.Y))
          Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessageCreateFX(UserList(UserIndex).Char.CharIndex, Hechizos(Spell).FXgrh, Hechizos(Spell).loops))
          Call WriteParalizeOK(UserIndex)
     End If
End If
Call WriteUpdateUserStats(UserIndex)
Exit Sub

errorh:
    LogError ("Error en NPCAI.NPCLanzaSpellSobreUser2 ")


End Sub



Sub MagoDestruyeWand(ByVal npcind As Integer, ByVal bs As Byte, ByVal indice As Integer)
On Error GoTo errorh
    ''sonidos: 30 y 32, y no los cambien sino termina siendo muy chistoso...
    ''Para el FX utiliza el del hechizos(indice)
    Dim X As Integer
    Dim Y As Integer
    Dim PJInd As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    Dim danio As Double
    Dim dist As Double
    Dim danioI As Integer
    Dim MascotaInd As Integer
    Dim indireccion As Integer
    
    Select Case bs
        Case 5
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("Rahma", Npclist(npcind).Char.CharIndex, vbGreen))
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SONIDO_Dragon_VIVO, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        Case 4
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("v�rtax", Npclist(npcind).Char.CharIndex, vbGreen))
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SONIDO_Dragon_VIVO, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        Case 3
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("Zill", Npclist(npcind).Char.CharIndex, vbGreen))
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SONIDO_Dragon_VIVO, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        Case 2
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("y�k� E'nta", Npclist(npcind).Char.CharIndex, vbGreen))
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SONIDO_Dragon_VIVO, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        Case 1
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("��Kor�t�!!", Npclist(npcind).Char.CharIndex, vbGreen))
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SONIDO_Dragon_VIVO, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
        Case 0
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead(vbNullString, Npclist(npcind).Char.CharIndex, vbGreen))
            Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessagePlayWave(SONIDO_Dragon_VIVO, Npclist(npcind).Pos.X, Npclist(npcind).Pos.Y))
            NPCPosX = Npclist(npcind).Pos.X
            NPCPosY = Npclist(npcind).Pos.Y
            NPCPosM = Npclist(npcind).Pos.map
            PJInd = 0
            indireccion = Npclist(npcind).Spells(indice)
            ''Da�o masivo por destruccion de wand
            For X = 8 To 95
                For Y = 8 To 95
                    PJInd = MapData(NPCPosM, X, Y).UserIndex
                    MascotaInd = MapData(NPCPosM, X, Y).NpcIndex
                    If PJInd > 0 Then
                        dist = Sqr((UserList(PJInd).Pos.X - NPCPosX) ^ 2 + (UserList(PJInd).Pos.Y - NPCPosY) ^ 2)
                        danio = 880 / (dist ^ (3 / 7))
                        danioI = Abs(Int(danio))

                        UserList(PJInd).Stats.MinHP = UserList(PJInd).Stats.MinHP - danioI
                        
                        Call WriteConsoleMsg(PJInd, Npclist(npcind).name & " te ha quitado " & danioI & " puntos de vida al romper su vara.", FontTypeNames.FONTTYPE_FIGHT)
                        Call SendData(SendTarget.ToPCArea, PJInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, UserList(PJInd).Pos.X, UserList(PJInd).Pos.Y))
                        Call SendData(SendTarget.ToPCArea, PJInd, PrepareMessageCreateFX(UserList(PJInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
                        
                        If UserList(PJInd).Stats.MinHP < 1 Then
                            UserList(PJInd).Stats.MinHP = 0
                            Call UserDie(PJInd)
                        End If
                    
                    ElseIf (MascotaInd > 0) Then
                        If (Npclist(MascotaInd).MaestroUser > 0) Then
                        
                            dist = Sqr((Npclist(MascotaInd).Pos.X - NPCPosX) ^ 2 + (Npclist(MascotaInd).Pos.Y - NPCPosY) ^ 2)
                            danio = 880 / (dist ^ (3 / 7))
                            danioI = Abs(Int(danio))
                            ''efectiviza el danio
                            Npclist(MascotaInd).Stats.MinHP = Npclist(MascotaInd).Stats.MinHP - danioI
                            
                            Call SendData(SendTarget.ToNPCArea, MascotaInd, PrepareMessagePlayWave(Hechizos(indireccion).WAV, Npclist(MascotaInd).Pos.X, Npclist(MascotaInd).Pos.Y))
                            Call SendData(SendTarget.ToNPCArea, MascotaInd, PrepareMessageCreateFX(Npclist(MascotaInd).Char.CharIndex, Hechizos(indireccion).FXgrh, Hechizos(indireccion).loops))
                            
                            If Npclist(MascotaInd).Stats.MinHP < 1 Then
                                Npclist(MascotaInd).Stats.MinHP = 0
                                Call MuereNpc(MascotaInd, 0)
                            End If
                        End If  ''es mascota
                    End If  ''hay npc
                    
                Next Y
            Next X
    End Select

Exit Sub

errorh:
    LogError ("Error en NPCAI.MagoDestruyeWand ")

End Sub


Sub GreedyWalkTo(ByVal npcorig As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error GoTo errorh
''  Este procedimiento es llamado cada vez que un NPC deba ir
''  a otro lugar en el mismo mapa. Utiliza una t�cnica
''  de programaci�n greedy no determin�stica.
''  Cada paso azaroso que me acerque al destino, es un buen paso.
''  Si no hay mejor paso v�lido, entonces hay que volver atr�s y reintentar.
''  Si no puedo moverme, me considero piketeado
''  La funcion es larga, pero es O(1) - orden algor�tmico temporal constante

'Rapsodius - Changed Mod by And for speed

Dim NPCx As Integer
Dim NPCy As Integer
Dim USRx As Integer
Dim USRy As Integer
Dim dual As Integer
Dim mapa As Integer

If Not (Npclist(npcorig).Pos.map = map) Then Exit Sub   ''si son distintos mapas abort

NPCx = Npclist(npcorig).Pos.X
NPCy = Npclist(npcorig).Pos.Y

Dim pipo As Integer
pipo = RandomNumber(2, 3)
If (NPCx = X And NPCy = Y) Then pipo = 3
''  Levanto las coordenadas del destino
USRx = X
USRy = Y
mapa = map
If pipo = 2 Then
''  moverse
    If (NPCx > USRx) Then
        If (NPCy < USRy) Then
            ''NPC esta arriba a la derecha
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move down
                If LegalPos(mapa, NPCx, NPCy + 1) Then
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    ''aqui no puedo ir a ningun lado. Hay q ver si me bloquean caspers
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
                
            Else        ''random first move
                If LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If  ''checked random first move
        ElseIf (NPCy > USRy) Then   ''NPC esta abajo a la derecha
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move up
                If LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                    Call MoverArr(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            Else    ''random first move
                If LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If  ''endif random first move
        Else    ''x completitud, esta en la misma Y
            If LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                Call MoverIzq(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                Call MoverAba(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                Call MoverArr(npcorig)
                Exit Sub
            Else
                ''si me muevo abajo entro en loop. Aca el algoritmo falla
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("Maldito bastardo, � ven aqu� !", str(Npclist(npcorig).Char.CharIndex), vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        End If
    
    ElseIf (NPCx < USRx) Then
        
        If (NPCy < USRy) Then
            ''NPC esta arriba a la izquierda
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move down
                If LegalPos(mapa, NPCx, NPCy + 1) Then  ''ABA
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            Else    ''random first move
                If LegalPos(mapa, NPCx + 1, NPCy) Then  ''DER
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''ABA
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If
        
        ElseIf (NPCy > USRy) Then   ''NPC esta abajo a la izquierda
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move up
                If LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                    Call MoverArr(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            Else
                If LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                    Call MoverArr(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If
        Else    ''x completitud, esta en la misma Y
            If LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                Call MoverDer(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                Call MoverAba(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                Call MoverArr(npcorig)
                Exit Sub
            Else
                ''si me muevo loopeo. aca falla el algoritmo
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("Maldito bastardo, � ven aqu� !", Npclist(npcorig).Char.CharIndex, vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        End If
    
    
    Else ''igual X
        If (NPCy > USRy) Then    ''NPC ESTA ABAJO
            If LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                Call MoverArr(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                Call MoverDer(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                Call MoverIzq(npcorig)
                Exit Sub
            Else
                ''aca tambien falla el algoritmo
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("Maldito bastardo, � ven aqu� !", Npclist(npcorig).Char.CharIndex, vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        Else    ''NPC ESTA ARRIBA
            If LegalPos(mapa, NPCx, NPCy + 1) Then  ''ABA
                Call MoverAba(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                Call MoverDer(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                Call MoverIzq(npcorig)
                Exit Sub
            Else
                ''posible loop
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("MUejEJEJ", Npclist(npcorig).Char.CharIndex, vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        End If
    End If
Else
Dim mueje As Integer
mueje = RandomNumber(2, 8) / 2
Select Case mueje
Case 1
                If LegalPos(mapa, NPCx, NPCy + 1) Then
                    Call MoverAba(npcorig)
                    Exit Sub
                End If
Case 2
                If LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                End If
Case 3
                If LegalPos(mapa, NPCx + 1, NPCy) Then
                    Call MoverDer(npcorig)
                    Exit Sub
                End If
Case 4
                If LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                End If
End Select
End If
Exit Sub

errorh:
    LogError ("Error en NPCAI.GreedyWalkTo")

End Sub


Sub MOVIMIENTOWAR(ByVal npcorig As Integer, ByVal map As Integer, ByVal X As Integer, ByVal Y As Integer)
On Error GoTo errorh
''  Este procedimiento es llamado cada vez que un NPC deba ir
''  a otro lugar en el mismo mapa. Utiliza una t�cnica
''  de programaci�n greedy no determin�stica.
''  Cada paso azaroso que me acerque al destino, es un buen paso.
''  Si no hay mejor paso v�lido, entonces hay que volver atr�s y reintentar.
''  Si no puedo moverme, me considero piketeado
''  La funcion es larga, pero es O(1) - orden algor�tmico temporal constante

'Rapsodius - Changed Mod by And for speed

Dim NPCx As Integer
Dim NPCy As Integer
Dim USRx As Integer
Dim USRy As Integer
Dim dual As Integer
Dim mapa As Integer

'If Not (Npclist(npcorig).Pos.map = map) Then Exit Sub   ''si son distintos mapas abort

NPCx = Npclist(npcorig).Pos.X
NPCy = Npclist(npcorig).Pos.Y

If (NPCx = X And NPCy = Y) Then Exit Sub    ''ya llegu�!!


''  Levanto las coordenadas del destino
USRx = X
USRy = Y
mapa = map
''  moverse
    If (NPCx > USRx) Then
        If (NPCy < USRy) Then
            ''NPC esta arriba a la derecha
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move down
                If LegalPos(mapa, NPCx, NPCy + 1) Then
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    ''aqui no puedo ir a ningun lado. Hay q ver si me bloquean caspers
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
                
            Else        ''random first move
                If LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If  ''checked random first move
        ElseIf (NPCy > USRy) Then   ''NPC esta abajo a la derecha
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move up
                If LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                    Call MoverArr(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            Else    ''random first move
                If LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If  ''endif random first move
        Else    ''x completitud, esta en la misma Y
            If LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                Call MoverIzq(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                Call MoverAba(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                Call MoverArr(npcorig)
                Exit Sub
            Else
                ''si me muevo abajo entro en loop. Aca el algoritmo falla
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("Maldito bastardo, � ven aqu� !", str(Npclist(npcorig).Char.CharIndex), vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        End If
    
    ElseIf (NPCx < USRx) Then
        
        If (NPCy < USRy) Then
            ''NPC esta arriba a la izquierda
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move down
                If LegalPos(mapa, NPCx, NPCy + 1) Then  ''ABA
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            Else    ''random first move
                If LegalPos(mapa, NPCx + 1, NPCy) Then  ''DER
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''ABA
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then
                    Call MoverArr(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If
        
        ElseIf (NPCy > USRy) Then   ''NPC esta abajo a la izquierda
            dual = RandomNumber(0, 10)
            If ((dual And 1) = 0) Then ''move up
                If LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                    Call MoverArr(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            Else
                If LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                    Call MoverDer(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                    Call MoverArr(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                    Call MoverAba(npcorig)
                    Exit Sub
                ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                    Call MoverIzq(npcorig)
                    Exit Sub
                Else
                    If CasperBlock(npcorig) Then Call LiberarCasperBlock(npcorig)
                End If
            End If
        Else    ''x completitud, esta en la misma Y
            If LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                Call MoverDer(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy + 1) Then  ''D
                Call MoverAba(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                Call MoverArr(npcorig)
                Exit Sub
            Else
                ''si me muevo loopeo. aca falla el algoritmo
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("Maldito bastardo, � ven aqu� !", Npclist(npcorig).Char.CharIndex, vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        End If
    
    
    Else ''igual X
        If (NPCy > USRy) Then    ''NPC ESTA ABAJO
            If LegalPos(mapa, NPCx, NPCy - 1) Then  ''U
                Call MoverArr(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                Call MoverDer(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                Call MoverIzq(npcorig)
                Exit Sub
            Else
                ''aca tambien falla el algoritmo
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("Maldito bastardo, � ven aqu� !", Npclist(npcorig).Char.CharIndex, vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        Else    ''NPC ESTA ARRIBA
            If LegalPos(mapa, NPCx, NPCy + 1) Then  ''ABA
                Call MoverAba(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx + 1, NPCy) Then  ''R
                Call MoverDer(npcorig)
                Exit Sub
            ElseIf LegalPos(mapa, NPCx - 1, NPCy) Then  ''L
                Call MoverIzq(npcorig)
                Exit Sub
            Else
                ''posible loop
                If Npclist(npcorig).CanAttack = 1 And (RandomNumber(1, 100) > 95) Then
                    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageChatOverHead("MUejEJEJ", Npclist(npcorig).Char.CharIndex, vbYellow))
                    Npclist(npcorig).CanAttack = 0
                End If
            End If
        End If
    End If
Exit Sub

errorh:
    LogError ("Error en NPCAI.GreedyWalkTo")

End Sub




Sub MoverAba(ByVal npcorig As Integer)
On Error GoTo errorh

    Dim mapa As Integer
    Dim NPCx As Integer
    Dim NPCy As Integer
    mapa = Npclist(npcorig).Pos.map
    NPCx = Npclist(npcorig).Pos.X
    NPCy = Npclist(npcorig).Pos.Y
    
    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageCharacterMove(Npclist(npcorig).Char.CharIndex, NPCx, NPCy + 1))
    'Update map and npc pos
    MapData(mapa, NPCx, NPCy).NpcIndex = 0
    Npclist(npcorig).Pos.Y = NPCy + 1
    Npclist(npcorig).Char.heading = eHeading.SOUTH
    MapData(mapa, NPCx, NPCy + 1).NpcIndex = npcorig
    
    'Revisamos sidebemos cambair el �rea
    Call ModAreas.CheckUpdateNeededNpc(npcorig, SOUTH)
Exit Sub

errorh:
    LogError ("Error en NPCAI.MoverAba ")

End Sub

Sub MoverArr(ByVal npcorig As Integer)
On Error GoTo errorh

    Dim mapa As Integer
    Dim NPCx As Integer
    Dim NPCy As Integer
    mapa = Npclist(npcorig).Pos.map
    NPCx = Npclist(npcorig).Pos.X
    NPCy = Npclist(npcorig).Pos.Y
    
    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageCharacterMove(Npclist(npcorig).Char.CharIndex, NPCx, NPCy - 1))
    'Update map and npc pos
    MapData(mapa, NPCx, NPCy).NpcIndex = 0
    Npclist(npcorig).Pos.Y = NPCy - 1
    Npclist(npcorig).Char.heading = eHeading.NORTH
    MapData(mapa, NPCx, NPCy - 1).NpcIndex = npcorig
    
    'Revisamos sidebemos cambair el �rea
    Call ModAreas.CheckUpdateNeededNpc(npcorig, NORTH)
Exit Sub

errorh:
    LogError ("Error en NPCAI.MoverArr")
End Sub

Sub MoverIzq(ByVal npcorig As Integer)
On Error GoTo errorh

    Dim mapa As Integer
    Dim NPCx As Integer
    Dim NPCy As Integer
    mapa = Npclist(npcorig).Pos.map
    NPCx = Npclist(npcorig).Pos.X
    NPCy = Npclist(npcorig).Pos.Y

    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageCharacterMove(Npclist(npcorig).Char.CharIndex, NPCx - 1, NPCy))
    'Update map and npc pos
    MapData(mapa, NPCx, NPCy).NpcIndex = 0
    Npclist(npcorig).Pos.X = NPCx - 1
    Npclist(npcorig).Char.heading = eHeading.WEST
    MapData(mapa, NPCx - 1, NPCy).NpcIndex = npcorig
    
    'Revisamos sidebemos cambair el �rea
    Call ModAreas.CheckUpdateNeededNpc(npcorig, WEST)
Exit Sub

errorh:
    LogError ("Error en NPCAI.MoverIzq")

End Sub

Sub MoverDer(ByVal npcorig As Integer)
On Error GoTo errorh

    Dim mapa As Integer
    Dim NPCx As Integer
    Dim NPCy As Integer
    mapa = Npclist(npcorig).Pos.map
    NPCx = Npclist(npcorig).Pos.X
    NPCy = Npclist(npcorig).Pos.Y
    
    Call SendData(SendTarget.ToNPCArea, npcorig, PrepareMessageCharacterMove(Npclist(npcorig).Char.CharIndex, NPCx + 1, NPCy))
    'Update map and npc pos
    MapData(mapa, NPCx, NPCy).NpcIndex = 0
    Npclist(npcorig).Pos.X = NPCx + 1
    Npclist(npcorig).Char.heading = eHeading.EAST
    MapData(mapa, NPCx + 1, NPCy).NpcIndex = npcorig
    
    'Revisamos sidebemos cambair el �rea
    Call ModAreas.CheckUpdateNeededNpc(npcorig, EAST)
Exit Sub

errorh:
    LogError ("Error en NPCAI.MoverDer")

End Sub


Sub VolverAlCentro(ByVal npcind As Integer)
On Error GoTo errorh
    
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NpcMap As Integer
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    NpcMap = Npclist(npcind).Pos.map
    
    If NpcMap = servermap Then
        ''35,25 y 67,25 son las posiciones del rey
        If NPCPosX < 50 Then    ''esta a la izquierda
            Call GreedyWalkTo(npcind, NpcMap, ALCOBA1_X, ALCOBA1_Y)
            'GreedyWalkTo npcind, NpcMap, 35, 25
        Else
            Call GreedyWalkTo(npcind, NpcMap, ALCOBA2_X, ALCOBA2_Y)
            'GreedyWalkTo npcind, NpcMap, 67, 25
        End If
    End If

Exit Sub

errorh:
    LogError ("Error en NPCAI.VolverAlCentro")

End Sub

Function EstoyMuyLejos(ByVal npcind) As Boolean
''me dice si estoy fuera del anillo exterior de proteccion
''de los clerigos
    
    Dim retvalue As Boolean
    
    If Npclist(npcind).Pos.X < 50 Then
        retvalue = Npclist(npcind).Pos.X < 43 And Npclist(npcind).Pos.X > 27
    Else
        retvalue = Npclist(npcind).Pos.X < 80 And Npclist(npcind).Pos.X > 59
    End If
    
    'retvalue = Npclist(npcind).Pos.Y > 39
    
    If Not Npclist(npcind).Pos.map = servermap Then
        EstoyMuyLejos = False
    Else
        EstoyMuyLejos = retvalue
    End If

Exit Function

errorh:
    LogError ("Error en NPCAI.EstoymUYLejos")

End Function

Function EstoyLejos(ByVal npcind) As Boolean
On Error GoTo errorh

    ''35,25 y 67,25 son las posiciones del rey
    ''esta fction me indica si estoy lejos del rango de vision
    
    
    Dim retvalue As Boolean
    
    If Npclist(npcind).Pos.X < 50 Then
        retvalue = Npclist(npcind).Pos.X < 43 And Npclist(npcind).Pos.X > 27
    Else
        retvalue = Npclist(npcind).Pos.X < 75 And Npclist(npcind).Pos.X > 59
    End If
    
    retvalue = retvalue And Npclist(npcind).Pos.Y > 19 And Npclist(npcind).Pos.Y < 31
    
    If Not Npclist(npcind).Pos.map = servermap Then
        EstoyLejos = False
    Else
        EstoyLejos = Not retvalue
    End If

Exit Function

errorh:
    LogError ("Error en NPCAI.EstoyLejos")

End Function

Function EsAlcanzable(ByVal npcind As Integer, ByVal PJEnInd As Integer) As Boolean
On Error GoTo errorh
    
    ''esta funcion es especialmente hecha para el mapa pretoriano
    ''Est� dise�ada para que se ignore a los PJs que estan demasiado lejos
    ''evitando asi que los "lockeen" en la pelea sacandolos de combate
    ''sin matarlos. La fcion es totalmente inutil si los NPCs estan en otro mapa.
    ''Chequea la posibilidad que les hagan /racc desde otro mapa para evitar
    ''malos comportamientos
    ''35,25 y 67,25 son las posiciones del rey
''On Error Resume Next


    Dim retvalue As Boolean
    Dim retValue2 As Boolean
    
    Dim PJPosX As Integer
    Dim PJPosY As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    
    PJPosX = UserList(PJEnInd).Pos.X
    PJPosY = UserList(PJEnInd).Pos.Y
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    
    If (Npclist(npcind).Pos.map = servermap) And (UserList(PJEnInd).Pos.map = servermap) Then
        ''los bounds del mapa pretoriano son fijos.
        ''Esta en una posicion alcanzable si esta dentro del
        ''espacio de las alcobas reales del mapa dise�ado por mi.
        ''Y dentro de la alcoba en el rango del perimetro de defensa
        '' 8+8+8+8 x 7+7+7+7
        retvalue = PJPosX > 18 And PJPosX < 49 And NPCPosX <= 51 'And NPCPosX < 49
        retvalue = retvalue And (PJPosY > 14 And PJPosY < 40) 'And NPCPosY > 14 And NPCPosY < 50)
        retValue2 = PJPosX > 52 And PJPosX < 81 And NPCPosX > 51 'And NPCPosX < 81
        retValue2 = retValue2 And (PJPosY > 14 And PJPosY < 40) 'And NPCPosY > 14 And NPCPosY < 50)
        ''rv dice si estan en la alcoba izquierda los 2 y en zona valida de combate
        ''rv2 dice si estan en la derecha
        retvalue = retvalue Or retValue2
        'If retvalue = False Then
        '    If Npclist(npcind).CanAttack = 1 Then
        '        Call SendData(SendTarget.ToNPCArea, npcind, Npclist(npcind).Pos.Map, "||" & vbYellow & "�� Cobarde !�" & str(Npclist(npcind).Char.CharIndex))
        '        Npclist(npcind).CanAttack = 0
        '    End If
        'End If
    Else
        retvalue = False
    End If
    
    EsAlcanzable = retvalue
     
Exit Function

errorh:
    LogError ("Error en NPCAI.EsAlcanzable")
 
 
End Function



Function CasperBlock(ByVal npc As Integer) As Boolean
On Error GoTo errorh
    
    Dim NPCPosM As Integer
    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim PJ As Integer
    
    Dim retvalue As Boolean
    
    NPCPosX = Npclist(npc).Pos.X
    NPCPosY = Npclist(npc).Pos.Y
    NPCPosM = Npclist(npc).Pos.map
    
    retvalue = Not (LegalPos(NPCPosM, NPCPosX + 1, NPCPosY) Or _
                LegalPos(NPCPosM, NPCPosX - 1, NPCPosY) Or _
                LegalPos(NPCPosM, NPCPosX, NPCPosY + 1) Or _
                LegalPos(NPCPosM, NPCPosX, NPCPosY - 1))
                
    If retvalue Then
        ''si son todas invalidas
        ''busco que algun casper sea causante de piketeo
        retvalue = False

        PJ = MapData(NPCPosM, NPCPosX + 1, NPCPosY).UserIndex
        If PJ > 0 Then
            retvalue = UserList(PJ).flags.Muerto = 1
        End If
        
        PJ = MapData(NPCPosM, NPCPosX - 1, NPCPosY).UserIndex
        If PJ > 0 Then
            retvalue = retvalue Or UserList(PJ).flags.Muerto = 1
        End If
        
        PJ = MapData(NPCPosM, NPCPosX, NPCPosY + 1).UserIndex
        If PJ > 0 Then
            retvalue = retvalue Or UserList(PJ).flags.Muerto = 1
        End If
        
        PJ = MapData(NPCPosM, NPCPosX, NPCPosY - 1).UserIndex
        If PJ > 0 Then
            retvalue = retvalue Or UserList(PJ).flags.Muerto = 1
        End If
        
    Else
        retvalue = False
    
    End If
    
    CasperBlock = retvalue
    Exit Function

errorh:
'    MsgBox ("ERROR!!")
    CasperBlock = False
    LogError ("Error en NPCAI.CasperBlock")

End Function


Sub LiberarCasperBlock(ByVal npcind As Integer)
On Error GoTo errorh

    Dim NPCPosX As Integer
    Dim NPCPosY As Integer
    Dim NPCPosM As Integer
    
    NPCPosX = Npclist(npcind).Pos.X
    NPCPosY = Npclist(npcind).Pos.Y
    NPCPosM = Npclist(npcind).Pos.map
    
    If LegalPos(NPCPosM, NPCPosX + 1, NPCPosY + 1) Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageCharacterMove(Npclist(npcind).Char.CharIndex, NPCPosX + 1, NPCPosY + 1))
        'Update map and npc pos
        MapData(NPCPosM, NPCPosX, NPCPosY).NpcIndex = 0
        Npclist(npcind).Pos.Y = NPCPosY + 1
        Npclist(npcind).Pos.X = NPCPosX + 1
        Npclist(npcind).Char.heading = eHeading.SOUTH
        MapData(NPCPosM, NPCPosX + 1, NPCPosY + 1).NpcIndex = npcind
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("��JA JA JA JA!!", Npclist(npcind).Char.CharIndex, vbYellow))
        Exit Sub
    End If

    If LegalPos(NPCPosM, NPCPosX - 1, NPCPosY - 1) Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageCharacterMove(Npclist(npcind).Char.CharIndex, NPCPosX - 1, NPCPosY - 1))
        'Update map and npc pos
        MapData(NPCPosM, NPCPosX, NPCPosY).NpcIndex = 0
        Npclist(npcind).Pos.Y = NPCPosY - 1
        Npclist(npcind).Pos.X = NPCPosX - 1
        Npclist(npcind).Char.heading = eHeading.NORTH
        MapData(NPCPosM, NPCPosX - 1, NPCPosY - 1).NpcIndex = npcind
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("��JA JA JA JA!!", Npclist(npcind).Char.CharIndex, vbYellow))
        Exit Sub
    End If

    If LegalPos(NPCPosM, NPCPosX + 1, NPCPosY - 1) Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageCharacterMove(Npclist(npcind).Char.CharIndex, NPCPosX + 1, NPCPosY - 1))
        'Update map and npc pos
        MapData(NPCPosM, NPCPosX, NPCPosY).NpcIndex = 0
        Npclist(npcind).Pos.Y = NPCPosY - 1
        Npclist(npcind).Pos.X = NPCPosX + 1
        Npclist(npcind).Char.heading = eHeading.EAST
        MapData(NPCPosM, NPCPosX + 1, NPCPosY - 1).NpcIndex = npcind
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("��JA JA JA JA!!", Npclist(npcind).Char.CharIndex, vbYellow))
        Exit Sub
    End If
    
    If LegalPos(NPCPosM, NPCPosX - 1, NPCPosY + 1) Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageCharacterMove(Npclist(npcind).Char.CharIndex, NPCPosX - 1, NPCPosY + 1))
        'Update map and npc pos
        MapData(NPCPosM, NPCPosX, NPCPosY).NpcIndex = 0
        Npclist(npcind).Pos.Y = NPCPosY + 1
        Npclist(npcind).Pos.X = NPCPosX - 1
        Npclist(npcind).Char.heading = eHeading.WEST
        MapData(NPCPosM, NPCPosX - 1, NPCPosY + 1).NpcIndex = npcind
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("��JA JA JA JA!!", Npclist(npcind).Char.CharIndex, vbYellow))
        Exit Sub
    End If
    
    ''si esta aca, estamos fritos!
    If Npclist(npcind).CanAttack = 1 Then
        Call SendData(SendTarget.ToNPCArea, npcind, PrepareMessageChatOverHead("�Por las barbas de los antiguos reyes! �Alej�os endemoniados espectros o sufrir�is la furia de los dioses!", Npclist(npcind).Char.CharIndex, vbYellow))
        Npclist(npcind).CanAttack = 0
    End If
    
Exit Sub

errorh:
    LogError ("Error en NPCAI.LiberarCasperBlock")

End Sub

Public Sub CambiarAlcoba(ByVal npcind As Integer)
On Error GoTo errorh

    Select Case Npclist(npcind).Invent.ArmourEqpSlot
        Case 2
            Call GreedyWalkTo(npcind, servermap, 48, 70)
            If Npclist(npcind).Pos.X = 48 And Npclist(npcind).Pos.Y = 70 Then Npclist(npcind).Invent.ArmourEqpSlot = Npclist(npcind).Invent.ArmourEqpSlot + 1
        Case 6
            Call GreedyWalkTo(npcind, servermap, 52, 71)
            If Npclist(npcind).Pos.X = 52 And Npclist(npcind).Pos.Y = 71 Then Npclist(npcind).Invent.ArmourEqpSlot = Npclist(npcind).Invent.ArmourEqpSlot + 1
        Case 1
            Call GreedyWalkTo(npcind, servermap, 73, 56)
            If Npclist(npcind).Pos.X = 73 And Npclist(npcind).Pos.Y = 56 Then Npclist(npcind).Invent.ArmourEqpSlot = Npclist(npcind).Invent.ArmourEqpSlot + 1
        Case 7
            Call GreedyWalkTo(npcind, servermap, 73, 48)
            If Npclist(npcind).Pos.X = 73 And Npclist(npcind).Pos.Y = 48 Then Npclist(npcind).Invent.ArmourEqpSlot = Npclist(npcind).Invent.ArmourEqpSlot + 1
        Case 5
            Call GreedyWalkTo(npcind, servermap, 31, 56)
            If Npclist(npcind).Pos.X = 31 And Npclist(npcind).Pos.Y = 56 Then Npclist(npcind).Invent.ArmourEqpSlot = Npclist(npcind).Invent.ArmourEqpSlot + 1
        Case 3
            Call GreedyWalkTo(npcind, servermap, 31, 48)
            If Npclist(npcind).Pos.X = 31 And Npclist(npcind).Pos.Y = 48 Then Npclist(npcind).Invent.ArmourEqpSlot = Npclist(npcind).Invent.ArmourEqpSlot + 1
        Case 4, 8
            Npclist(npcind).Invent.ArmourEqpSlot = 0
            Exit Sub
    End Select

Exit Sub
errorh:
Call LogError("Error en CambiarAlcoba " & Err.Description)
End Sub

