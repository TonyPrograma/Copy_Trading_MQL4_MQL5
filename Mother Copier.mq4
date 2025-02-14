//+------------------------------------------------------------------+
//|                                                Tony Programa.mq4 |
//|                                   Copyright 2023, Tony Programa. |
//|                         https://www.instagram.com/tony_programa/ |
//+------------------------------------------------------------------+
#property copyright "Tony Programa"
#property link      "https://www.instagram.com/tony_programa/"
#property version   "1.00"
#property description "\nExpert Advisor made by @Tony_Programa"
#property description "Asesor Experto realizado por @Tony_Programa"
#property strict


//For function socket()
#define AF_INET         2
#define SOCK_STREAM     1
#define IPPROTO_TCP     6

struct sockaddr
  {
   short             family;
   ushort            port;
   uint              address;
   ulong             ignore;
  };

#import "ws2_32.dll"

//---Principal Functions
int socket(int af, int type, int protocol);
int WSACleanup();
ushort htons(ushort hostshort);
uint inet_addr(uchar&[]);
int WSAGetLastError();
int closesocket(int s);

//---Send Message
int connect(int, sockaddr&, int);
int send(int s, uchar& buf[], int len, int flags);

#import


sinput string  _____0_____                = "-------MOTHER´S PARAMETERS -------";    //---
input char Number_Child                   = 4;                      // Number of Children (less than 20)
input ushort Port_Child_1                 = 1120;                    // Port Child 1 (less than 65535)
input string IP_Port_1                    = "127.0.0.1";        //IP of Port 1
input ushort Port_Child_2                 = 1121;                    // Port Child 2 (less than 65535)
input string IP_Port_2                    = "127.0.0.1";        //IP of Port 2
input ushort Port_Child_3                 = 1122;                    // Port Child 3 (less than 65535)
input string IP_Port_3                    = "127.0.0.1";        //IP of Port 3
input ushort Port_Child_4                 = 1123;                    // Port Child 4 (less than 65535)
input string IP_Port_4                    = "127.0.0.1";        //IP of Port 4
input ushort Port_Child_5                 = 1124;                    // Port Child 5 (less than 65535)
input string IP_Port_5                    = "127.0.0.1";        //IP of Port 5
input ushort Port_Child_6                 = 1120;                    // Port Child 6 (less than 65535)
input string IP_Port_6                    = "127.0.0.1";        //IP of Port 6
input ushort Port_Child_7                 = 1121;                    // Port Child 7 (less than 65535)
input string IP_Port_7                    = "127.0.0.1";        //IP of Port 7
input ushort Port_Child_8                 = 1122;                    // Port Child 8 (less than 65535)
input string IP_Port_8                    = "127.0.0.1";        //IP of Port 8
input ushort Port_Child_9                 = 1123;                    // Port Child 9 (less than 65535)
input string IP_Port_9                    = "127.0.0.1";        //IP of Port 9
input ushort Port_Child_10                = 1124;                    // Port Child 10 (less than 65535)
input string IP_Port_10                   = "127.0.0.1";        //IP of Port 10
input ushort Port_Child_11                = 1120;                    // Port Child 11 (less than 65535)
input string IP_Port_11                   = "127.0.0.1";         //IP of Port 11
input ushort Port_Child_12                = 1121;                    // Port Child 12 (less than 65535)
input string IP_Port_12                   = "127.0.0.1";         //IP of Port 12
input ushort Port_Child_13                = 1122;                    // Port Child 13 (less than 65535)
input string IP_Port_13                   = "127.0.0.1";         //IP of Port 13
input ushort Port_Child_14                = 1123;                    // Port Child 14 (less than 65535)
input string IP_Port_14                   = "127.0.0.1";         //IP of Port 14
input ushort Port_Child_15                = 1124;                    // Port Child 15 (less than 65535)
input string IP_Port_15                   = "127.0.0.1";         //IP of Port 15
input ushort Port_Child_16                = 1039;                    // Port Child 16 (less than 65535)
input string IP_Port_16                   = "127.0.0.1";         //IP of Port 16
input ushort Port_Child_17                = 1040;                    // Port Child 17 (less than 65535)
input string IP_Port_17                   = "127.0.0.1";         //IP of Port 17
input ushort Port_Child_18                = 1041;                    // Port Child 18 (less than 65535)
input string IP_Port_18                   = "127.0.0.1";         //IP of Port 18
input ushort Port_Child_19                = 1042;                    // Port Child 19 (less than 65535)
input string IP_Port_19                   = "127.0.0.1";         //IP of Port 19
input ushort Port_Child_20                = 1043;                    // Port Child 20 (less than 65535)
input string IP_Port_20                   = "127.0.0.1";         //IP of Port 20


//---Inputs for Sockets
int Mother_Socket = -1;

//Variables for Lead (Mother)
int Number_Operations = 0;
ushort Ports [];
string IPS[];

string Value_For_Comparative        = "None";
string Value_For_Comparative_Before = "None";

datetime Time_Expire = D'2024.04.28 00:00';
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetMillisecondTimer(100);
   if(TimeCurrent() > Time_Expire)
     {
      Alert("Expired EA");
      return(INIT_FAILED);
     }

   ArrayResize(Ports,Number_Child);
   ArrayResize(IPS,Number_Child);

   for(int i=0; i<Number_Child; i++)
     {
      if(i==0)
        {
         Ports[i] = Port_Child_1;
         IPS[i] = IP_Port_1;
         continue;
        }

      if(i==1)
        {
         Ports[i] = Port_Child_2;
         IPS[i] = IP_Port_2;
         continue;
        }

      if(i==2)
        {
         Ports[i] = Port_Child_3;
         IPS[i] = IP_Port_3;
         continue;
        }

      if(i==3)
        {
         Ports[i] = Port_Child_4;
         IPS[i] = IP_Port_4;
         continue;
        }

      if(i==4)
        {
         Ports[i] = Port_Child_5;
         IPS[i] = IP_Port_5;
         continue;
        }

      if(i==5)
        {
         Ports[i] = Port_Child_6;
         IPS[i] = IP_Port_6;
         continue;
        }

      if(i==6)
        {
         Ports[i] = Port_Child_7;
         IPS[i] = IP_Port_7;
         continue;
        }


      if(i==7)
        {
         Ports[i] = Port_Child_8;
         IPS[i] = IP_Port_8;
         continue;
        }

      if(i==8)
        {
         Ports[i] = Port_Child_9;
         IPS[i] = IP_Port_9;
         continue;
        }

      if(i==9)
        {
         Ports[i] = Port_Child_10;
         IPS[i] = IP_Port_10;
         continue;
        }

      if(i==10)
        {
         Ports[i] = Port_Child_11;
         IPS[i] = IP_Port_11;
         continue;
        }

      if(i==11)
        {
         Ports[i] = Port_Child_12;
         IPS[i] = IP_Port_12;
         continue;
        }

      if(i==12)
        {
         Ports[i] = Port_Child_13;
         IPS[i] = IP_Port_13;
         continue;
        }

      if(i==13)
        {
         Ports[i] = Port_Child_14;
         IPS[i] = IP_Port_14;
         continue;
        }

      if(i==14)
        {
         Ports[i] = Port_Child_15;
         IPS[i] = IP_Port_15;
         continue;
        }

      if(i==15)
        {
         Ports[i] = Port_Child_16;
         IPS[i] = IP_Port_16;
         continue;
        }

      if(i==16)
        {
         Ports[i] = Port_Child_17;
         IPS[i] = IP_Port_17;
         continue;
        }

      if(i==17)
        {
         Ports[i] = Port_Child_18;
         IPS[i] = IP_Port_18;
         continue;
        }

      if(i==18)
        {
         Ports[i] = Port_Child_19;
         IPS[i] = IP_Port_19;
         continue;
        }

      if(i==19)
        {
         Ports[i] = Port_Child_20;
         IPS[i] = IP_Port_20;
         continue;
        }
     }


   ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, clrWhite);
   ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_GRID, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_UP, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_DOWN, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BEAR, clrWhite);
   ChartSetInteger(ChartID(), CHART_COLOR_CANDLE_BULL, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_CHART_LINE, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_VOLUME, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_ASK, clrRed);
   ChartSetInteger(ChartID(), CHART_COLOR_BID, clrBlack);
   ChartSetInteger(ChartID(), CHART_COLOR_STOP_LEVEL, clrRed);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string Message = Operations_Lead(Number_Operations, Value_For_Comparative);

   if(Value_For_Comparative != Value_For_Comparative_Before)
     {
      Print("Antes de enviar mensajes: ");
      for(int i=0; i<Number_Child; i++)
        {
         Start_Account_Mother();
         Send_To_Server(IPS[i], Ports[i], Mother_Socket, Message);
        }

      Value_For_Comparative_Before = Value_For_Comparative;
      Print("Message: ", Message);
     }
  }


//+----------Close Connection
void Close_Connection_Socket(int server)
  {
   closesocket(server);
   Mother_Socket = -1;
  }


//+------Socket
void Start_Account_Mother()
  {
   Mother_Socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
   if(Mother_Socket == -1)
     {
      Print("Error in Socket number: ", WSAGetLastError());
      Close_Connection_Socket(Mother_Socket);
      return;
     }
  }


//+-------Connection and Send message
void Send_To_Server(string addr_server, ushort port_server, int server_Socket, string message_Mother)
  {
   uchar addr_server_array[];
   StringToCharArray(addr_server, addr_server_array);
   ArrayResize(addr_server_array, ArraySize(addr_server_array) + 1);

   sockaddr server;
   server.family = AF_INET;
   server.port = htons(port_server);
   server.address = inet_addr(addr_server_array);

   int Mother_Server_Connect = connect(Mother_Socket, server, sizeof(server));
   if(Mother_Server_Connect == -1)
     {
      Print("Error in connect number: ", WSAGetLastError(), " and Port number: ", port_server);
      Close_Connection_Socket(Mother_Socket);
      return;
     }

   uchar Mens[];
   StringToCharArray(message_Mother, Mens, 0, StringLen(message_Mother), 0);
   int send_message = send(server_Socket, Mens, ArraySize(Mens), 0);

   if(send_message == -1)
     {
      Print("Error in Send Message number: ", WSAGetLastError(), " IP: ", addr_server, " and Port: ", port_server);
      Close_Connection_Socket(Mother_Socket);
      return;
     }

   Close_Connection_Socket(Mother_Socket);
  }
//+------------------------------------------------------------------+


//---------Specific string for send in TXTand Number OPerations
string Operations_Lead(int &number_Operations, string &Value_For_Comparative_1)
  {
   string Words = "";

   Value_For_Comparative_1 = ""; //For Comparative
   number_Operations = 0;

   for(int i = 0; i < OrdersTotal(); i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         number_Operations++;
         Value_For_Comparative_1 = Value_For_Comparative_1 + "A" + OrderSymbol() + "A1" + "B" + IntegerToString(OrderTicket()) + "B1" + "C" + OrderComment() + "C1" + "D" + DoubleToString(OrderLots(),3) + "D1" + "E" + DoubleToString(OrderOpenPrice(),5) + "E1" + "F" + DoubleToString(OrderTakeProfit(),5) + "F1" + "G" + DoubleToString(OrderStopLoss(),5) + "G1" + "H" + IntegerToString(OrderType()) + "H1" + "J" + IntegerToString(OrderExpiration()) + "J1" + "/";
         Words = Words + "A" + OrderSymbol() + "A1" + "B" + IntegerToString(OrderTicket()) + "B1" + "C" + OrderComment() + "C1" + "D" + DoubleToString(OrderLots(),3) + "D1" + "E" + DoubleToString(OrderOpenPrice(),5) + "E1" + "F" + DoubleToString(OrderTakeProfit(),5) + "F1" + "G" + DoubleToString(OrderStopLoss(),5) + "G1" + "H" + IntegerToString(OrderType()) + "H1" + "I" + TimeLocal() + "I1" + "J" + IntegerToString(OrderExpiration()) + "J1" + "K" + OrderOpenTime() + "K1" + "L" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),1) + "L1" + "/";
        }

   if(Words== "")
      Words = "None";

   return Words;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
