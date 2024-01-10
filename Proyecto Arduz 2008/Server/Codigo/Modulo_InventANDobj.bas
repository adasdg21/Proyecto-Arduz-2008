Attribute VB_Name = "InvNpc"
Public Function TirarItemAlPiso(Pos As WorldPos, Obj As Obj, Optional NotPirata As Boolean = True) As WorldPos
On Error GoTo Errhandler

    Dim NuevaPos As WorldPos
    NuevaPos.X = 0
    NuevaPos.Y = 0
    
    Tilelibre Pos, NuevaPos, Obj, NotPirata, True
    If NuevaPos.X <> 0 And NuevaPos.Y <> 0 Then
        Call MakeObj(Obj, Pos.map, NuevaPos.X, NuevaPos.Y)
    End If
    TirarItemAlPiso = NuevaPos

Exit Function
Errhandler:

End Function

Public Sub NPC_TIRAR_ITEMS(ByRef npc As npc)
'TIRA TODOS LOS ITEMS DEL NPC
On Error Resume Next

If npc.Invent.NroItems > 0 Then
    
    Dim i As Byte
    Dim MiObj As Obj
    
    For i = 1 To MAX_INVENTORY_SLOTS
    
        If npc.Invent.Object(i).ObjIndex > 0 Then
              MiObj.amount = npc.Invent.Object(i).amount
              MiObj.ObjIndex = npc.Invent.Object(i).ObjIndex
              Call TirarItemAlPiso(npc.Pos, MiObj)
        End If
      
    Next i

End If

End Sub

Function QuedanItems(ByVal NpcIndex As Integer, ByVal ObjIndex As Integer) As Boolean
On Error Resume Next
'Call LogTarea("Function QuedanItems npcindex:" & NpcIndex & " objindex:" & ObjIndex)

Dim i As Integer
If Npclist(NpcIndex).Invent.NroItems > 0 Then
    For i = 1 To MAX_INVENTORY_SLOTS
        If Npclist(NpcIndex).Invent.Object(i).ObjIndex = ObjIndex Then
            QuedanItems = True
            Exit Function
        End If
    Next
End If
QuedanItems = False
End Function

Function EncontrarCant(ByVal NpcIndex As Integer, ByVal ObjIndex As Integer) As Integer
On Error Resume Next
'Devuelve la cantidad original del obj de un npc

Dim ln As String, npcfile As String
Dim i As Integer

'If Npclist(NpcIndex).Numero > 499 Then
'    npcfile = DatPath & "NPCs-HOSTILES.dat"
'Else
    npcfile = DatPath & "NPCs.dat"
'End If
 
For i = 1 To MAX_INVENTORY_SLOTS
    ln = GetVar(npcfile, "NPC" & Npclist(NpcIndex).Numero, "Obj" & i)
    If ObjIndex = Val(ReadField(1, ln, 45)) Then
        EncontrarCant = Val(ReadField(2, ln, 45))
        Exit Function
    End If
Next
                   
EncontrarCant = 50

End Function

Sub ResetNpcInv(ByVal NpcIndex As Integer)
On Error Resume Next

Dim i As Integer

Npclist(NpcIndex).Invent.NroItems = 0

For i = 1 To MAX_INVENTORY_SLOTS
   Npclist(NpcIndex).Invent.Object(i).ObjIndex = 0
   Npclist(NpcIndex).Invent.Object(i).amount = 0
Next i

Npclist(NpcIndex).InvReSpawn = 0

End Sub

Sub QuitarNpcInvItem(ByVal NpcIndex As Integer, ByVal Slot As Byte, ByVal Cantidad As Integer)



Dim ObjIndex As Integer
ObjIndex = Npclist(NpcIndex).Invent.Object(Slot).ObjIndex

    'Quita un Obj
    If ObjData(Npclist(NpcIndex).Invent.Object(Slot).ObjIndex).Crucial = 0 Then
        Npclist(NpcIndex).Invent.Object(Slot).amount = Npclist(NpcIndex).Invent.Object(Slot).amount - Cantidad
        
        If Npclist(NpcIndex).Invent.Object(Slot).amount <= 0 Then
            Npclist(NpcIndex).Invent.NroItems = Npclist(NpcIndex).Invent.NroItems - 1
            Npclist(NpcIndex).Invent.Object(Slot).ObjIndex = 0
            Npclist(NpcIndex).Invent.Object(Slot).amount = 0
            If Npclist(NpcIndex).Invent.NroItems = 0 And Npclist(NpcIndex).InvReSpawn <> 1 Then
               Call CargarInvent(NpcIndex) 'Reponemos el inventario
            End If
        End If
    Else
        Npclist(NpcIndex).Invent.Object(Slot).amount = Npclist(NpcIndex).Invent.Object(Slot).amount - Cantidad
        
        If Npclist(NpcIndex).Invent.Object(Slot).amount <= 0 Then
            Npclist(NpcIndex).Invent.NroItems = Npclist(NpcIndex).Invent.NroItems - 1
            Npclist(NpcIndex).Invent.Object(Slot).ObjIndex = 0
            Npclist(NpcIndex).Invent.Object(Slot).amount = 0
            
            If Not QuedanItems(NpcIndex, ObjIndex) Then
                   
                   Npclist(NpcIndex).Invent.Object(Slot).ObjIndex = ObjIndex
                   Npclist(NpcIndex).Invent.Object(Slot).amount = EncontrarCant(NpcIndex, ObjIndex)
                   Npclist(NpcIndex).Invent.NroItems = Npclist(NpcIndex).Invent.NroItems + 1
            
            End If
            
            If Npclist(NpcIndex).Invent.NroItems = 0 And Npclist(NpcIndex).InvReSpawn <> 1 Then
               Call CargarInvent(NpcIndex) 'Reponemos el inventario
            End If
        End If
    
    
    
    End If
End Sub

Sub CargarInvent(ByVal NpcIndex As Integer)

'Vuelve a cargar el inventario del npc NpcIndex
Dim LoopC As Integer
Dim ln As String
Dim npcfile As String

'If Npclist(NpcIndex).Numero > 499 Then
'    npcfile = DatPath & "NPCs-HOSTILES.dat"
'Else
    npcfile = DatPath & "NPCs.dat"
'End If

Npclist(NpcIndex).Invent.NroItems = Val(GetVar(npcfile, "NPC" & Npclist(NpcIndex).Numero, "NROITEMS"))

For LoopC = 1 To Npclist(NpcIndex).Invent.NroItems
    ln = GetVar(npcfile, "NPC" & Npclist(NpcIndex).Numero, "Obj" & LoopC)
    Npclist(NpcIndex).Invent.Object(LoopC).ObjIndex = Val(ReadField(1, ln, 45))
    Npclist(NpcIndex).Invent.Object(LoopC).amount = Val(ReadField(2, ln, 45))
    
Next LoopC

End Sub


