VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsIniReader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False


Option Explicit
Option Base 0

Private Type ChildNode
    key As String
    value As String
End Type

Private Type MainNode
    Name As String
    values() As ChildNode
    numValues As Integer
End Type

Private fileData() As MainNode

Private MainNodes As Long

''
'Default constructor. Does nothing.

Private Sub Class_Initialize()
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'
'
End Sub

''
'Destroy every array and deallocates al memory.
'

Private Sub Class_Terminate()
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'
'
    Dim i As Long
    
    'Clean up
    If MainNodes Then
        For i = 1 To MainNodes - 1
            Erase fileData(i).values
        Next i
        
        Erase fileData
    End If
    
    MainNodes = 0
End Sub

''
'Loads a INI file so it's values can be read. Must be called before being able to use GetValue.
'
'file Complete path of the INI file to be loaded.
' @see      GetValue

Public Sub Initialize(ByVal file As String)
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 27/07/2006
'Opens the requested file and loads it's data into memory
'
    Dim handle As Integer
    Dim Text As String
    Dim Pos As Long
    
    'Prevent memory losses if we are attempting to reload a file....
    Call Class_Terminate
    
    'Get a free handle and start reading line by line until the end
    handle = FreeFile
    
    Open file For Input As handle
    
    Do Until EOF(handle)
        Line Input #handle, Text
        
        'Is it null??
        If Len(Text) Then
            'If it starts with '[' it is a main node or nothing (GetPrivateProfileStringA works this way), otherwise it's a value
            If Left$(Text, 1) = "[" Then
                'If it has an ending ']' it's a main node, otherwise it's nothing
                Pos = InStr(2, Text, "]")
                If Pos Then
                    'Add a main node
                    ReDim Preserve fileData(MainNodes) As MainNode
                    
                    fileData(MainNodes).Name = UCase$(Trim$(mid$(Text, 2, Pos - 2)))
                    
                    MainNodes = MainNodes + 1
                End If
            Else
                'So it's a value. Check if it has a '=', otherwise it's nothing
                Pos = InStr(2, Text, "=")
                If Pos Then
                    'Is it under any main node??
                    If MainNodes Then
                        With fileData(MainNodes - 1)
                            'Add it to the main node's value
                            ReDim Preserve .values(.numValues) As ChildNode
                            
                            .values(.numValues).value = Right$(Text, Len(Text) - Pos)
                            .values(.numValues).key = UCase$(Left$(Text, Pos - 1))
                            
                            .numValues = .numValues + 1
                        End With
                    End If
                End If
            End If
        End If
    Loop
    
    Close handle
    
    Dim i As Long
    
    If MainNodes Then
        'Sort main nodes to allow binary search
        Call SortMainNodes(0, MainNodes - 1)
        
        'Sort values of each node to allow binary search
        For i = 0 To MainNodes - 1
            If fileData(i).numValues Then _
                Call SortChildNodes(fileData(i), 0, fileData(i).numValues - 1)
        Next i
    End If
End Sub

''
'Sorts all child nodes within the given MainNode alphabetically by their keys. Uses quicksort.
'
'Node The MainNode whose values are to be sorted.
'first The first index to consider when sorting.
'last The last index to be considered when sorting.

Private Sub SortChildNodes(ByRef Node As MainNode, ByVal First As Integer, ByVal Last As Integer)
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'Sorts the list of values in a given MainNode using quicksort,
'this allows the use of Binary Search for faster searches
'
    Dim min As Integer      'First item in the list
    Dim max As Integer      'Last item in the list
    Dim comp As String      'Item used to compare
    Dim temp As ChildNode
    
    min = First
    max = Last
    
    With Node
        comp = .values((min + max) \ 2).key
    
        Do While min <= max
            Do While .values(min).key < comp And min < Last
                min = min + 1
            Loop
            Do While .values(max).key > comp And max > First
                max = max - 1
            Loop
            If min <= max Then
                temp = .values(min)
                .values(min) = .values(max)
                .values(max) = temp
                min = min + 1
                max = max - 1
            End If
        Loop
    End With
    
    If First < max Then SortChildNodes Node, First, max
    If min < Last Then SortChildNodes Node, min, Last
End Sub

''
'Sorts all main nodes in the loaded INI file alphabetically by their names. Uses quicksort.
'
'first The first index to consider when sorting.
'last The last index to be considered when sorting.

Private Sub SortMainNodes(ByVal First As Integer, ByVal Last As Integer)
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'Sorts the MainNodes list using quicksort,
'this allows the use of Binary Search for faster searches
'
    Dim min As Integer      'First item in the list
    Dim max As Integer      'Last item in the list
    Dim comp As String      'Item used to compare
    Dim temp As MainNode
    
    min = First
    max = Last
    
    comp = fileData((min + max) \ 2).Name
    
    Do While min <= max
        Do While fileData(min).Name < comp And min < Last
            min = min + 1
        Loop
        Do While fileData(max).Name > comp And max > First
            max = max - 1
        Loop
        If min <= max Then
            temp = fileData(min)
            fileData(min) = fileData(max)
            fileData(max) = temp
            min = min + 1
            max = max - 1
        End If
    Loop
    
    If First < max Then SortMainNodes First, max
    If min < Last Then SortMainNodes min, Last
End Sub

''
'Searches for a given key within a given main section and if it exists retrieves it's value, otherwise a null string
'
'Main The name of the main section in which we will be searching.
'key The key of the value we are looking for.
' @returns  The value asociated with the given key under the requeted main section of the INI file or a null string if it's not found.

Public Function GetValue(ByVal Main As String, ByVal key As String) As String
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'Returns a value if the key and main node exist, or a nullstring otherwise
'
    Dim i As Long
    Dim j As Long
    
    'Search for the main node
    i = FindMain(UCase$(Main))
    
    If i >= 0 Then
        'If valid, binary search among keys
        j = FindKey(fileData(i), UCase$(key))
        
        'If we found it we return it
        If j >= 0 Then GetValue = fileData(i).values(j).value
    End If
End Function

''
'Searches for a given key within a given main node and returns the index in which it's stored or the negation of the index in which it should be if not found.
'
'Node The MainNode among whose value entries we will be searching.
'key The key of the value we are looking for.
' @returns  The index in which the value with the key we are looking for is stored or the negation of the index in which it should be if not found.

Private Function FindKey(ByRef Node As MainNode, ByVal key As String) As Long
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'Returns the index of the value which key matches the requested one,
'or the negation of the position were it should be if not found
'
    Dim min As Long
    Dim max As Long
    Dim mid As Long
    
    min = 0
    max = Node.numValues - 1
    
    Do While min <= max
        mid = (min + max) \ 2
        
        If Node.values(mid).key < key Then
            min = mid + 1
        ElseIf Node.values(mid).key > key Then
            max = mid - 1
        Else
            'We found it
            FindKey = mid
            Exit Function
        End If
    Loop
    
    'Not found, return the negation of the position where it should be
    '(all higher values are to the right of the list and lower values are to the left)
    FindKey = Not mid
End Function

''
'Searches for a main section with the given name within the loaded INI file and returns the index in which it's stored or the negation of the index in which it should be if not found.
'
'name The name of the MainNode we are looking for.
' @returns  The index in which the main section we are looking for is stored or the negation of the index in which it should be if not found.

Private Function FindMain(ByVal Name As String) As Long
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 5/01/2006
'Returns the index of the MainNode which name matches the requested one,
'or the negation of the position were it should be if not found
'
    Dim min As Long
    Dim max As Long
    Dim mid As Long
    
    min = 0
    max = MainNodes - 1
    
    Do While min <= max
        mid = (min + max) \ 2
        
        If fileData(mid).Name < Name Then
            min = mid + 1
        ElseIf fileData(mid).Name > Name Then
            max = mid - 1
        Else
            'We found it
            FindMain = mid
            Exit Function
        End If
    Loop
    
    'Not found, return the negation of the position where it should be
    '(all higher values are to the right of the list and lower values are to the left)
    FindMain = Not mid
End Function

''
'Checks wether a given key exists or not.
'
'name    The name of the element whose existance is being checked.
' @returns  True if the key exists, false otherwise.

Public Function KeyExists(ByVal Name As String) As Boolean
'
'Author: Juan Mart�n Sotuyo Dodero
'Last Modify Date: 04/01/2008
'Returns true of the key exists, false otherwise.
'
    KeyExists = FindMain(Name) >= 0
End Function

