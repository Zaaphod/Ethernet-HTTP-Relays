Program Test_Ethernet_Relays;

Uses Ethernet_Relays,sysutils,crt;

Var
   Ethernet_Relay_Address:String;
   I :Byte;

Begin
   Ethernet_Relay_Address:='192.168.1.4';
   Writeln ('Ethernet Relay Test Program');
   Writeln ('Functions:');
   Writeln ('     Ethernet_Device_Add(',Ethernet_Relay_Address,');');
   Ethernet_Device_Add(Ethernet_Relay_Address);
   Ethernet_Device_Add(Ethernet_Relay_Address);
   Ethernet_Device_Add(Ethernet_Relay_Address);
   Ethernet_Device_Add(Ethernet_Relay_Address);
   Writeln ('     Ethernet_Relay_Device_Count(',Ethernet_Relay_Address,'); ',Ethernet_Relay_Device_Count(Ethernet_Relay_Address));
   writeln('Press enter to test Clear_Ethernet_Relays(',Ethernet_Relay_Address,');');
   readln;
   Clear_Ethernet_Relays(Ethernet_Relay_Address);
   Ethernet_Relay_Status(Ethernet_Relay_Address);
   writeln('Press enter to Write_Ethernet_Relay(',Ethernet_Relay_Address,',14,True);');
   readln;
   Write_Ethernet_Relay(Ethernet_Relay_Address,14,True);
   Writeln ('     Ethernet_Relay_Status(',Ethernet_Relay_Address,');');
   Ethernet_Relay_Status(Ethernet_Relay_Address);
   Writeln ('     Ethernet_Relay_Device_Status(',Ethernet_Relay_Address,'); ',Ethernet_Relay_Device_Status(Ethernet_Relay_Address));
   Writeln ('     Ethernet_Relay_Device_Status_String(',Ethernet_Relay_Address,'); ',Ethernet_Relay_Device_Status_String(Ethernet_Relay_Address));
   Writeln ('     Ethernet_Relay_State(',Ethernet_Relay_Address,',4); ',Ethernet_Relay_State(Ethernet_Relay_Address,4));
   Writeln ('     Read_Ethernet_Relay(',Ethernet_Relay_Address,',4); ',Read_Ethernet_Relay(Ethernet_Relay_Address,4));
   writeln('Press enter to test Set_Ethernet_Relays(',Ethernet_Relay_Address,');');
   readln;
   Set_Ethernet_Relays(Ethernet_Relay_Address);
   Writeln('Ethernet_Relay_Status(''all'');');
   Ethernet_Relay_Status('all');

   writeln('Press enter to test Clear_All_Ethernet_Relays;');
   readln;
   Clear_All_Ethernet_Relays;
   writeln('Press enter to test Set_All_Ethernet_Relays);');
   readln;
   Set_All_Ethernet_Relays;
   Ethernet_Relay_List;

   Writeln ('Variables:   (must know device index)');
   Writeln('Ethernet_Relay_Element.Count                      ',Ethernet_Relay_Element.Count);
   Writeln('Ethernet_Relay_Element.Device[1].Address          ',Ethernet_Relay_Element.Device[1].Address);
   Writeln('Ethernet_Relay_Element.Device[1].Count            ',Ethernet_Relay_Element.Device[1].Count);
   Writeln('Ethernet_Relay_Element.Device[1].Status           ',Ethernet_Relay_Element.Device[1].Status);
   Writeln('Ethernet_Relay_Element.Device[1].Relay[1].State   ',Ethernet_Relay_Element.Device[1].Relay[1].State);
   Writeln('Ethernet_Relay_Element.Device[1].Current_Page     ',Ethernet_Relay_Element.Device[1].Current_Page);
   repeat
      readkey;
   until not(keypressed);
   Repeat
      For I := 1 to Ethernet_Relay_Element.Device[1].Count Do
         Begin
            Write_Ethernet_Relay(Ethernet_Relay_Address,i,Not(Ethernet_Relay_Element.Device[1].Relay[i].State));
            Sleep(100);
         End;
   Until Keypressed;

End.
