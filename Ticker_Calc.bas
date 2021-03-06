Attribute VB_Name = "Module1"
Sub Ticker_Calc()

'declare variables, WS variable to iterate through each worksheet
Dim WS As Worksheet
Dim Open_Price As Double
Dim Close_Price As Double
Dim Yearly_Change As Double
Dim Ticker_Name As String
Dim Percent_Change As Double
Dim i As Long
Dim r As Range

    For Each WS In ActiveWorkbook.Worksheets
    WS.Activate
        ' determine the Last Row
        A_lastrow = WS.Cells(Rows.Count, 1).End(xlUp).Row
        
        ' copy and paste unique ticker values
        With ActiveSheet
         .Range("I1:Q" & A_lastrow).Clear
         .Range("A1:A" & A_lastrow).AdvancedFilter Action:=xlFilterCopy, CopyToRange:=.Range("I1"), Unique:=True
        End With

        ' add headers to summary table
        Cells(1, "I").Value = "Ticker"
        Cells(1, "J").Value = "Yearly Change"
        Cells(1, "K").Value = "Percent Change"
        Cells(1, "L").Value = "Total Stock Volume"
        
        ' sort ticker to ensure data is formatted in
        I_lastrow = Cells(Rows.Count, "I").End(xlUp).Row
        With WS.Sort
            .SetRange Range("I2:I" & I_lastrow)
            .Header = xlYes
            .MatchCase = False
            .Orientation = xlTopToBottom
            .SortMethod = xlPinYin
            .Apply
        End With
        
        'calculating values, select starting range for formula, will remain consistant across sheets
        Range("J2").Select
        'initiate for loop from 2 to lastrow variable
        For i = 2 To I_lastrow
            ', ticker, open_price, close_pricestart setting values
                Ticker = Range("I" & i).Value
                Open_Price = Application.VLookup(Ticker, ActiveSheet.Range("A2:G" & A_lastrow), 3, 0)
                Close_Price = Application.VLookup(Ticker, ActiveSheet.Range("A2:G" & A_lastrow), 6, 1)
                Volume = Application.SumIf(ActiveSheet.Range("A2:A" & A_lastrow), Ticker, ActiveSheet.Range("G2:G" & A_lastrow))
                Cells(i, "L").Value = Volume
                ' add yearly change variable calling on close and open price variables
                Yearly_Change = Close_Price - Open_Price
                Cells(i, "J").Value = Yearly_Change
                ' add percent change, cover 0 value change to prevent error
                If (Open_Price = 0 And Close_Price = 0) Then
                    Percent_Change = 0
                ElseIf (Open_Price = 0 And Close_Price <> 0) Then
                    Percent_Change = 1
                'percent change calling yearlyly chagne and open price variables into formula.
                Else
                    Percent_Change = Yearly_Change / Open_Price
                    Cells(i, "K").Value = Percent_Change
                    'format return value as percentage
                    Cells(i, "K").NumberFormat = "0.00%"
                End If
         Next i
         
        ' Set the formatting for cells colors based on value
        Set r = Range("J1:J" & I_lastrow)
        With r.FormatConditions
                .Delete
                .Add Type:=xlCellValue, Operator:=xlLess, Formula1:="=0"
                .Item(.Count).Interior.ColorIndex = 3
                .Add Type:=xlCellValue, Operator:=xlGreater, Formula1:="=0"
                .Item(.Count).Interior.ColorIndex = 10
        End With
        
        ' set greatest % increase, % decrease, and total volume
        Cells(2, "O").Value = "Greatest % Increase"
        Cells(3, "O").Value = "Greatest % Decrease"
        Cells(4, "O").Value = "Greatest Total Volume"
    
        'ticker value for greatest increase
        Cells(1, "P").Value = "Ticker"
        MaxPer = Application.Match(Application.Max(WS.Range("K1:K" & I_lastrow)), WS.Range("K1:K" & I_lastrow), 0)
        MinPer = Application.Match(Application.Min(WS.Range("K1:K" & I_lastrow)), WS.Range("K1:K" & I_lastrow), 0)
        MaxVal = Application.Match(Application.Max(WS.Range("L1:L" & I_lastrow)), WS.Range("L1:L" & I_lastrow), 0)
        Cells(2, "P").Value = Cells(MaxPer, "I").Value
        Cells(3, "P").Value = Cells(MinPer, "I").Value
        Cells(4, "P").Value = Cells(MaxVal, "I").Value
        
        'percentage value for greatest increase
        Cells(1, "Q").Value = "Value"
        Cells(2, "Q").Value = Application.Max(WS.Range("K2:K" & I_lastrow))
        Cells(2, "Q").NumberFormat = "0.00%"
        Cells(3, "Q").Value = Application.Min(WS.Range("K2:K" & I_lastrow))
        Cells(3, "Q").NumberFormat = "0.00%"
        Cells(4, "Q").Value = Application.Max(WS.Range("L2:L" & I_lastrow))
        
        'auto fit columns to fit headers
        Columns("A:Q").AutoFit
         
    Next WS
     
End Sub

