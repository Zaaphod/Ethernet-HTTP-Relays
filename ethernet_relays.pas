Unit Ethernet_Relays;

{$mode objfpc}{$H+}

Interface

uses  fphttpclient, SSockets, Classes, SysUtils;

Type
   Relaytype = Record
      State    : Boolean;
   end;

   ETH_RLY_Record = record
      Address          :String;
      Relay            :Array [1..16] of Relaytype;
      Count            :Byte;
      Current_Page     :Byte;
      Status           :Word;
   End;

   Eth_Relay_Manager = Record
      Device           : Array [1..16] of ETH_RLY_Record;
      Count            : Byte;
   End;

Var
   Ethernet_Relay_Element: Eth_Relay_Manager;

Function Ethernet_Relay_Device_Status(Device:String):Word;
Function Ethernet_Relay_Device_Status_String(Device:String):String;
Function Ethernet_Relay_Device_Count(Device:String):Word;
Function Ethernet_Relay_State(Device:String;Relay_Number:Byte):Boolean;
Function Read_Ethernet_Relay(Device:String;Relay_Number:Byte):Byte;
Function Clear_All_Ethernet_Relays:integer;
Function Set_All_Ethernet_Relays:integer;
Function Clear_Ethernet_Relays(Device:String):integer;
Function Set_Ethernet_Relays(Device:String):integer;
Function Write_Ethernet_Relay(Device:String;Relay_Number:Byte;State:Boolean):integer;
Function Ethernet_Relay_Status(Device:String):integer;
Function Ethernet_Relay_List:integer;
Function Ethernet_Device_Add(Address:String):Boolean;

implementation

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
(**********************************************************)
(***          Remove Leading Spaces                     ***)
(**********************************************************)
Function NoLeadSpace(S:ANSIString):ANSIString;
Var
   X      : LongWord;
   Space  : Boolean;
   Tmp    : ANSIString;
Begin
   Tmp:='';
   Space:= False;
   For X := 1 To Length(S) Do
      Begin
         If (Space) OR (S[x]<>' ') Then
            Begin
               Tmp:=Tmp+S[x];
               Space:=True;
            End;
      End;
   NoLeadSpace:=Tmp;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
(**********************************************************)
(***                  Remove &NBSP                      ***)
(**********************************************************)
Function No_nbsp(S:ANSIString):ANSIString;
Var
   X     : LongWord;
   Tmp   : ANSIString;
Begin
   Tmp:='';
   x:=1;
   repeat
      Begin
         if copy(s,x,5) = '&nbsp' then
            x:=X+5
         Else
         if copy(s,x,7) = '<small>' then
            x:=X+7
         Else
         if copy(s,x,8) = '</small>' then
            x:=X+8
         Else
         if copy(s,x,4) = '</a>' then
            x:=X+4
         Else
            Begin
               Tmp:=Tmp+S[X];
               x:=x+1;
            End

      End;
   until x>=length(s);
   No_nbsp:=Tmp;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function BinStringCustom(BS:QWord;BL:Byte):String;
Var
   Bittest         :QWord;
   looptest        :Byte;
   Stringtemp      : String;
Begin
   Bittest:=1;
   Bittest:=Bittest SHL (BL-1);
   StringTemp:='';
   For  Looptest := 1 to bl do
      Begin
         //write(binstring(bs),' ',binstring(bittest),' ',binstring(BS AND Bittest),' ');
         //write((bs),' ',(bittest),' ',(BS AND Bittest),' ');
         If BS AND Bittest = Bittest then
            Begin
               //Writeln('1');
               Stringtemp:=Stringtemp+'1';
            end
         else
            Begin
               //Writeln('0');
               Stringtemp:=Stringtemp+'0';
            End;
         Bittest:= Bittest SHR 1;
      End;
   BinStringCustom:= Stringtemp;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_Status_Page(Device_Number:Byte;HTLMString:AnsiString):Integer;
Var
   Ethernet_Relay_String_List: TStringlist;
   Position_p,i:word;
   no_nbsp_string:ansistring;
   Relay_Number,RNP,rpos: Word;

Begin
   Ethernet_Relay_Status_Page := 0;
   Ethernet_Relay_String_List := TStringlist.create;
   no_nbsp_string:=No_nbsp(HTLMString);
   i:=1;
   Repeat
      Begin
         position_p:=pos('<p>',copy(no_nbsp_string,i,length(no_nbsp_string)-i));
         //writeln(position_p);
         If position_p>0 then
            Begin
               if (copy(no_nbsp_string,i,position_p-1)<>'<center>') and (Pos('Change',copy(no_nbsp_string,i,position_p-1))=0)
                  and (Pos('Relay-ALL',copy(no_nbsp_string,i,position_p-1))=0) then
                  Begin
                     Ethernet_Relay_String_List.add (copy(no_nbsp_string,i,position_p-1));
                     //Writeln (copy(no_nbsp_string,i,position_p-1));
                  End;
               i:=i+position_p+2;
            End;
      End;
   Until (i>=length(no_nbsp_string)) or (position_p=0);


   for i := 0 to Ethernet_Relay_String_List.count -1  do
      Begin
         rpos:=Pos('Relay-',Ethernet_Relay_String_List[i]);
         //Writeln(Copy(Ethernet_Relay_String_List[i],rpos+6,2));
         RNP:=Strtoint(Copy(Ethernet_Relay_String_List[i],rpos+6,2));
         //Writeln('rnp:',Copy(Ethernet_Relay_String_List[i],rpos+6,2),' ',RNP);
         If RNP > 0 Then
            Begin
               If (RNP>=1) And (RNP<=4) Then
                  Ethernet_Relay_Element.Device[Device_Number].Current_Page:=1
               Else
               If (RNP>=5) And (RNP<=8) Then
                  Ethernet_Relay_Element.Device[Device_Number].Current_Page:=2
               Else
               If (RNP>=9) And (RNP<=12) Then
                  Ethernet_Relay_Element.Device[Device_Number].Current_Page:=3
               Else
               If (RNP>=13) And (RNP<=16) Then
                  Ethernet_Relay_Element.Device[Device_Number].Current_Page:=4;
               Relay_Number:=StrtoInt(Copy(Ethernet_Relay_String_List[i],rpos+6,2));
               if (Pos('#00FF00',Ethernet_Relay_String_List[i])>0) Then
                  Begin
                     Ethernet_Relay_Element.Device[Device_Number].Relay[Relay_Number].state := True;
                     Ethernet_Relay_Element.Device[Device_Number].Status:=Ethernet_Relay_Element.Device[Device_Number].Status OR ($1 shl (Relay_Number-1));
                  End
               else
                  Begin
                     Ethernet_Relay_Element.Device[Device_Number].Relay[Relay_Number].state := False;
                     Ethernet_Relay_Element.Device[Device_Number].Status:= Ethernet_Relay_Element.Device[Device_Number].Status and (($1 shl (Relay_Number-1)) xor High(QWord));
                  End;
               //Writeln ('Ethernet Relay #',Relay_Number,' ',Ethernet_Relay_Element.Device[Relay_Number].status,'Page ',Ethernet_Relay_Element.Device[Device_Number].Current_Page);
            End;
      end;
   Ethernet_Relay_String_List.Free;
   Ethernet_Relay_Status_Page := Ethernet_Relay_Element.Device[Device_Number].Current_Page;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Send_HTTP(Send_String:AnsiString):AnsiString;
Var
   C : TFPHTTPClient;
   Receive_String:AnsiString;

begin
   C:=TFPHTTPClient.Create(Nil);
   try
      try
        //C.ConnectTimeout:=1500;
        Receive_String:=C.Get(Send_String);
        //writeln(Send_String,' ',Receive_String);
      except
         On E: ESocketError do
            Begin
               writeln(Send_String);
               Write(E.ClassName);
               Writeln(' Error Connecting To Relay Board: ',E.Message);
               Receive_String:='Error';
            End;
         On EH : EHTTPClient do
            begin
               writeln(Send_String);
               Write(EH.ClassName);
               Writeln(' Error Finding Relay Board: '+EH.Message);
               Receive_String:='Error';
            end;
         on E: Exception do
            begin
               writeln(Send_String);
               Write(E.ClassName);
               Writeln(' Error Connecting To Relay Board');
               Receive_String:='Error';
            End;


      end;
   finally
     C.Free;
   end;
   Send_HTTP:=Receive_String;

//Try
//   Receive_String:=TFPHTTPCLIENT.SIMPLEGET(Send_String);
//   //writeln(Send_String,' ',Receive_String);
//except
//   On E: Exception do
//       Begin
//       Write(E.ClassName);
//       Writeln(' Could not connect to server');
//       Receive_String:='Error'
//       end;
//     end;
//Send_HTTP:=Receive_String;
end;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_Send_Command(Device_Number:Byte;rc:Word):Boolean;
Var
   Ethernet_Response:Ansistring;
   E_Relay_Code:String;
Begin
   Ethernet_Response := '';
   If rc<= 9 then
      E_Relay_code := '0'+inttostr(rc)
   Else
      E_Relay_code := inttostr(rc);
   Ethernet_Response:=Send_HTTP('http://'+Ethernet_Relay_Element.Device[Device_Number].Address+'/30000/'+E_Relay_Code);
   If (Ethernet_Response = 'Error') or (Ethernet_Response = '') Then
      Ethernet_Relay_Send_Command:=False
   Else
      Begin
         Ethernet_Relay_Status_Page(Device_Number,Ethernet_Response);
         Ethernet_Relay_Send_Command:=True
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Get_Ethernet_Relay_DevicesCount(Device_Number:Byte):Byte;
Var
   Device_Count,i:Byte;
Begin
   Device_Count:=0;
   For i := 1 to 4 do
      Begin
         If Ethernet_Relay_Send_Command(Device_Number,42) Then
            Begin
               If Ethernet_Relay_Element.Device[Device_Number].Current_Page*4 > Device_Count then
                  Device_Count:=Ethernet_Relay_Element.Device[Device_Number].Current_Page*4;
            end
         Else
            Begin
               Device_Count:=0;
               Break;
            End;
      End;
   //Writeln(Device_Count,' Devices');
   Get_Ethernet_Relay_DevicesCount:=Device_Count;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_Device_Status(Device:String):Word;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Ethernet_Relay_Device_Status:=0 ;
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
      end
   Else
      Begin
         Ethernet_Relay_Device_Status:=Ethernet_Relay_Element.Device[Device_Number].Status;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_Device_Status_String(Device:String):String;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Ethernet_Relay_Device_Status_String:='';
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
      end
   Else
      Begin
         Ethernet_Relay_Device_Status_String := BinStringCustom(Ethernet_Relay_Element.Device[Device_Number].Status,Ethernet_Relay_Element.Device[Device_Number].Count);
      End;
End;

Function Ethernet_Relay_Device_Count(Device:String):Word;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Ethernet_Relay_Device_Count:=0 ;
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
      end
   Else
      Begin
         Ethernet_Relay_Device_Count:=Ethernet_Relay_Element.Device[Device_Number].Count;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_State(Device:String;Relay_Number:Byte):Boolean;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
      end
   Else
    if (Relay_Number>Ethernet_Relay_Element.Device[Device_Number].Count) or (Relay_Number<1) then
      begin
         writeln('Error: Relay number out of range ("',Relay_Number,'")  Must be between 1 and ',Ethernet_Relay_Element.Device[Device_Number].Count);
      End
   Else
      Begin
         Ethernet_Relay_State:=Ethernet_Relay_Element.Device[Device_Number].Relay[Relay_Number].State;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Read_Ethernet_Relay(Device:String;Relay_Number:Byte):Byte;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
      end
   Else
    if (Relay_Number>Ethernet_Relay_Element.Device[Device_Number].Count) or (Relay_Number<1) then
      begin
         writeln('Error: Relay number out of range ("',Relay_Number,'")  Must be between 1 and ',Ethernet_Relay_Element.Device[Device_Number].Count);
      End
   Else
      Begin
         If Ethernet_Relay_Element.Device[Device_Number].Relay[Relay_Number].State Then
            Read_Ethernet_Relay:=1
         Else
            Read_Ethernet_Relay:=0;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Clear_All_Ethernet_Relays:integer;
Var
   Device_Number:Byte;
Begin
   If Ethernet_Relay_Element.Count >=1 then
      Begin
         For Device_Number := 1 to Ethernet_Relay_Element.Count do
            Begin
               Ethernet_Relay_Send_Command(Device_Number,44);
               Get_Ethernet_Relay_DevicesCount(Device_Number); // reads in all states
            End;
         Clear_All_Ethernet_Relays:= 1;
      End
   Else
      begin
         writeln('Error: Device not found');
         Clear_All_Ethernet_Relays := 2;
      end
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Set_All_Ethernet_Relays:integer;
Var
   Device_Number:Byte;
Begin
   If Ethernet_Relay_Element.Count >=1 then
      Begin
         For Device_Number := 1 to Ethernet_Relay_Element.Count do
            Begin
               Ethernet_Relay_Send_Command(Device_Number,45);
               Get_Ethernet_Relay_DevicesCount(Device_Number); // reads in all states
            End;
         Set_All_Ethernet_Relays:= 1;
      End
   Else
      begin
         writeln('Error: Device not found');
         Set_All_Ethernet_Relays := 2;
      end;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Clear_Ethernet_Relays(Device:String):integer;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
         Clear_Ethernet_Relays := 2;
      end
   Else
      Begin
         Ethernet_Relay_Send_Command(Device_Number,44);
         Get_Ethernet_Relay_DevicesCount(Device_Number); // reads in all states
         Clear_Ethernet_Relays:= 1;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Set_Ethernet_Relays(Device:String):integer;
Var
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
         Set_Ethernet_Relays := 2;
      end
   Else
      Begin
         Ethernet_Relay_Send_Command(Device_Number,45);
         Get_Ethernet_Relay_DevicesCount(Device_Number); // reads in all states
         Set_Ethernet_Relays := 1;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Write_Ethernet_Relay(Device:String;Relay_Number:Byte;State:Boolean):integer;
Var
   Needed_Page,Relay_Code,
   Ethernet_Relay_j,Device_Number:Byte;
Begin
   Device_Number:=0;
   for Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Count do
      begin
         if Ethernet_Relay_Element.Device[Ethernet_Relay_j].Address=Device then
            begin
              Device_Number:=Ethernet_Relay_j;
              break;
            end;
      end;
   if Device_Number = 0 Then
      begin
         writeln('Error: Device not found ("',Device,'")');
         Write_Ethernet_Relay := 2;
      end
   Else
   if (Relay_Number>Ethernet_Relay_Element.Device[Device_Number].Count) or (Relay_Number<1) then
      begin
         writeln('Error: Relay number out of range ("',Relay_Number,'")  Must be between 1 and ',Ethernet_Relay_Element.Device[Device_Number].Count);
         Write_Ethernet_Relay := 3;
      End
   Else
      Begin
         If (Relay_Number>=1) And (Relay_Number<=4) Then
            Needed_Page:=1
         Else
         If (Relay_Number>=5) And (Relay_Number<=8) Then
            Needed_Page:=2
         Else
         If (Relay_Number>=9) And (Relay_Number<=12) Then
            Needed_Page:=3
         Else
         If (Relay_Number>=13) And (Relay_Number<=16) Then
            Needed_Page:=4;
         If Ethernet_Relay_Element.Device[Device_Number].Current_Page <> Needed_Page Then
         Begin
            Repeat
               Ethernet_Relay_Send_Command(Device_Number,42);
            Until Ethernet_Relay_Element.Device[Device_Number].Current_Page = Needed_Page;
         End;
         Relay_Code:=(Relay_Number-1)*2;
         If State then
            Inc(Relay_Code);
         //Writeln('RC: ',Relay_Code);
         Ethernet_Relay_Send_Command(Device_Number,Relay_Code);
         Write_Ethernet_Relay := 1;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Writeln_Relay_Device(Device_Number:Byte);
Begin
   Writeln('Ethernet Relay #',Device_Number,':   ',Ethernet_Relay_Element.Device[Device_Number].Address,
           '   ',Ethernet_Relay_Element.Device[Device_Number].Count,
           ' Relays   ',BinStringCustom(Ethernet_Relay_Element.Device[Device_Number].Status,Ethernet_Relay_Element.Device[Device_Number].Count));
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_Status(Device:String):integer;
Var
   Ethernet_Relay_i,Ethernet_Relay_j,Device_Number:Byte;
Begin
   If Upcase(Device) = 'ALL' Then
      Begin
         For Ethernet_Relay_i := 1 to Ethernet_Relay_Element.Count Do
            Begin
               Writeln_Relay_Device(Ethernet_Relay_i);
               //For Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Device[Ethernet_Relay_i].Count Do
               //   Writeln ('    ',Ethernet_Relay_j,' ',Ethernet_Relay_Element.Device[Ethernet_Relay_i].Relay[Ethernet_Relay_j].State);
            End;
         Write (Ethernet_Relay_Element.Count,' Device');
         If Ethernet_Relay_Element.Count <> 1 then
            Writeln ('s')
         Else
            Writeln;
      End
   Else
      Begin
         Device_Number:=0;
         for Ethernet_Relay_i := 1 to Ethernet_Relay_Element.Count do
            begin
               if Ethernet_Relay_Element.Device[Ethernet_Relay_i].Address=Device then
                  begin
                  Device_Number:=Ethernet_Relay_i;
                  break;
                  end;
            end;
         if Device_Number = 0 Then
            begin
               writeln('Error: Device not found ("',Device,'")');
               Ethernet_Relay_Status := 2;
            end
         Else
            Begin
               Writeln_Relay_Device(Device_Number);
               //For Ethernet_Relay_j := 1 to Ethernet_Relay_Element.Device[Device_Number].Count Do
               //   Writeln ('    ',Ethernet_Relay_j,' ',Ethernet_Relay_Element.Device[Device_Number].Relay[Ethernet_Relay_j].State);
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Relay_List:integer;
Begin
   Ethernet_Relay_Status('All');
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Ethernet_Device_Add(Address:String):Boolean;
Var
   Device_Number,Ethernet_Relay_i : Byte;
Begin
   Device_Number:=0;
   If Ethernet_Relay_Element.Count >= 1 Then
      Begin
         for Ethernet_Relay_i := 1 to Ethernet_Relay_Element.Count do
            begin
               if Ethernet_Relay_Element.Device[Ethernet_Relay_i].Address=Address then
                  begin
                  Device_Number:=Ethernet_Relay_i;
                  break;
                  end;
            end;
      End;
   if Device_Number = 0 Then
      Begin
         Inc (Ethernet_Relay_Element.Count);
         Ethernet_Relay_Element.Device[Ethernet_Relay_Element.Count].Address := Address;
         Ethernet_Relay_Element.Device[Ethernet_Relay_Element.Count].Count:=Get_Ethernet_Relay_DevicesCount(Ethernet_Relay_Element.Count);
         If Ethernet_Relay_Element.Device[Ethernet_Relay_Element.Count].Count >0 Then
            Begin
               Write('Added: ');
               Writeln_Relay_Device(Ethernet_Relay_Element.Count);
               Ethernet_Device_Add:=True;
            End
         Else
            Begin
               Ethernet_Relay_Element.Device[Ethernet_Relay_Element.Count].Address := '';
               Dec (Ethernet_Relay_Element.Count);
               Writeln('Ethernet Device Not Added');
               Ethernet_Device_Add:=False;
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Initialization
   Ethernet_Relay_Element.Count:=0
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Finalization
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
End.
