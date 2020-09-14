# Ethernet-HTTP-Relays
Library to control Ethernet HTTP relays with Free Pascal

This is a library to control Ethernet Relays that use web browser commands similar to:

* http://192.168.1.4/30000/00 : Relay-01 OFF 
* http://192.168.1.4/30000/01 : Relay-01 ON 
* http://192.168.1.4/30000/02 : Relay-02 OFF 
* http://192.168.1.4/30000/03 : Relay-02 ON 
* http://192.168.1.4/30000/04 : Relay-03 OFF 
* Http://192.168.1.4/30000/05 : Relay-03 ON 
* ... 
* http://192.168.1.4/30000/30 : Relay-16 OFF 
* http://192.168.1.4/30000/31 : Relay-16 ON 
* http://192.168.1.4/30000/41 : Enter 
* http://192.168.1.4/30000/40 : Exit 
* http://192.168.1.4/30000/42 : Next Page 
* http://192.168.1.4/30000/43 : Next Page 


These Relays are inexpensive and come either with a relay board or made to attach to common relay boards

It was tested with these boards:
--------------------------------
* 16 Relay:  https://www.amazon.com/gp/product/B00NDS9LBK (Controller) With https://www.amazon.com/gp/product/B07Y2X4F77 (Relay Board)
*  8 Relay:  https://www.amazon.com/gp/product/B076CNJNFH (comes with both the controller and the relay board)
 

It allows you to turn any relay on or off programmatically without using a web browser

It also deciphers the pages provided by the board's web server to all you to programmatically get the status of each relay

It can control multiple relay boards at the same time, they are referenced by their IP Address


Functions:
----------

     Function Ethernet_Device_Add(IP_Address_String);  // Adds a Relay Board To The Relay Manager
     Example: Ethernet_Device_Add('192.168.1.4');
     Returns: Added: Ethernet Relay #1:   192.168.1.4   16 Relays   0000000000000000

     Function Write_Ethernet_Relay(IP_Address_String,Relay_Number_Byte,State_Boolean);  //Turns a Relay On or Off
     Example: Write_Ethernet_Relay('192.168.1.4',14,True);
     
     Function Clear_Ethernet_Relays(IP_Address_String);  // Turn off all Rellays on the board
     Example: Clear_Ethernet_Relays('192.168.1.4');

     Function Set_Ethernet_Relays(IP_Address_String);  // Turn on all Rellays on the board
     Example: Set_Ethernet_Relays('192.168.1.4');
     
     Function Ethernet_Relay_Status(IP_Address_String);  // Reports a status string of the relay board at the specified IP address
     Example: Ethernet_Relay_Status('192.168.1.4');
     Returns: Ethernet Relay #1:   192.168.1.4   16 Relays   0010000000000000

     Function Ethernet_Relay_Status('All');  // Reports a status string of all relay boards
     Example: Ethernet_Relay_Status('All');
     Returns: Ethernet Relay #1:   192.168.1.4   16 Relays   0010000000000000
              Ethernet Relay #2:   192.168.1.5   16 Relays   0000010010010000
              2 Devices
     
     Function Ethernet_Relay_Device_Status(IP_Address_String); // Returns the status of all relays in a word
     Example: Ethernet_Relay_Device_Status('192.168.1.4');
     Returns: 8192
     
     Function Ethernet_Relay_Device_Status_String(IP_Address_String);  // Returns a string of the binary representation of the relay states
     Example: Ethernet_Relay_Device_Status_String(192.168.1.4); 
     Returns: 0010000010001000
     
     Function Ethernet_Relay_State(IP_Address_String,Relay_Number_Byte); // Returns a boolean state of the relay
     Example: Ethernet_Relay_State('192.168.1.4',4);
     Returns: FALSE
     
     Function Read_Ethernet_Relay(IP_Address_String,Relay_Number_Byte); // Returns a numerical state of the relay 0 if the relay is off or a 1 if it is on
     Example: Read_Ethernet_Relay('192.168.1.4',4);
     Returns: 0

Variables:   // If you kow the device index you can use these variables
----------
* Ethernet_Relay.Count                      Byte      1
* Ethernet_Relay.Device[i].Address          String    '10.10.03.03'
* Ethernet_Relay.Device[i].Count            Byte      16
* Ethernet_Relay.Device[i].Status           Word      65535
* Ethernet_Relay.Device[i].Relay[j].State   Boolean   TRUE
* Ethernet_Relay.Device[i].Current_Page     Byte      4

