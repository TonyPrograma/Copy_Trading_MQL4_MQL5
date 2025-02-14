//+------------------------------------------------------------------+
//|                                                Tony Programa.mq4 |
//|                                   Copyright 2023, Tony Programa. |
//|                         https://www.instagram.com/tony_programa/ |
//+------------------------------------------------------------------+
#property copyright "Tony Programa"
#property link      "https://www.instagram.com/tony_programa/"
#property version   "1.0"
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

//---Recive Message
int bind(int s, sockaddr& name, int namelen);
int listen(int s, int backlog);
int ioctlsocket(int s, int cmd, int &argp);
int accept(int s, sockaddr& addr, int& addrlen);
int recv(int s, uchar& buf[], int len, int flags);

//---Send Message
int connect(int, sockaddr&, int);
int send(int s, uchar& buf[], int len, int flags);

#import


enum LOTAJE
  {
   Lotaje_Fijo = 0,
   Lotaje_Multiplicado = 1
  };


sinput string  _____0_____             = "------- MOTHER CURRENCY -------";    //---
input string Primer_Mercado            = "EURUSDz"; //Primer Mercado
input string Segundo_Mercado           = "None"; //Segundo Mercado
input string Tercer_Mercado            = "None"; //Tercer Mercado
input string Cuarto_Mercado            = "None"; //Cuarto Mercado
input string Quinto_Mercado            = "None"; //Quinto Mercado
input string Sexto_Mercado             = "None"; //Sexto Mercado
input string Septimo_Mercado           = "None"; //Septimo Mercado
input string Octavo_Mercado            = "None"; //Octavo Mercado


sinput string  _____1_____               = "-------CHILD CURRENCY-------";    //---
input string Primer_Mercado_S            = "EURUSDe"; //Primer Mercado
input string Segundo_Mercado_S           = "None"; //Segundo Mercado
input string Tercer_Mercado_S            = "None"; //Tercer Mercado
input string Cuarto_Mercado_S            = "None"; //Cuarto Mercado
input string Quinto_Mercado_S            = "None"; //Quinto Mercado
input string Sexto_Mercado_S             = "None"; //Sexto Mercado
input string Septimo_Mercado_S           = "None"; //Septimo Mercado
input string Octavo_Mercado_S            = "None"; //Octavo Mercado


sinput string  _____2_____               = "-------VOLUME CHILD-------";    //---
input int Magic_Number                   = 15451;  //Número Magico
input LOTAJE Tipo_de_Lotaje              = 1;      //Tipo de lotaje
input double lotaje_Fijo                 = 0.01;   //Lotaje si es fijo
input double Multiplicador_del_Lotaje    = 1;      //Multiplicador para el Lotaje


sinput string  _____3_____               = "-------OTHER PARAMETERS-------";    //---
input ushort Port                        = 1024; // Port Child Actually (less than 65535)
input int Aditional_StopLoss             = 0;  //Adición al SL en Puntos
input int Aditional_TakeProfit           = 0; //Adición al TP en Puntos
input ushort Delay                       = 0; // Delay for Orders in seconds

//input int Retraso_en_Segundos            = 10; //Máximos segundos de retraso

//---Inputs for Sockets
int Child_Socket = -1;
int New_Socket = -1;


//Arrays Lead (Extract Vales)
string message_child,                     message_child_before;
ulong Ticket_Lead[],                      Ticket_Lead_Provitional[];
string Symbol_Lead[],                     Symbol_Lead_Provitional[]; ///Posible Conffusion
int Order_Type_Lead[],                    Order_Type_Lead_Provitional[];
double Lot_Lead[],                        Lot_Lead_Provitional[];
double Open_Price_Lead[],                 Open_Price_Lead_Provitional[];
double TP_Lead[],                         TP_Lead_Provitional[];
double SL_Lead[],                         SL_Lead_Provitional[];
string Comment_Lead[],                    Comment_Lead_Provitional[];
datetime Start_Time_Lead[],               Start_Time_Lead_Provitional[];
datetime Time_Limit_Lead[],               Time_Limit_Lead_Provitional[];
datetime Order_Open_Time[],               Order_Open_Time_Provitional[];
datetime Order_Open_Time_Lead_Follow[];
ulong Ticket_Lead_Follow[];


//Arrays Leads_Follow (When make Order of Operation)
string Symbol_Lead_Follow[];
int Order_Type_Lead_Follow[];
double Lot_Lead_Follow[];
double Open_Price_Lead_Follow[];
double TP_Lead_Follow[];
double SL_Lead_Follow[];
string Comment_Lead_Follow[];
datetime Start_Time_Lead_Follow[];
datetime Time_Limit_Lead_Follow[];


//Arrays Follow
int Ticket_Follow[];
string Symbol_Follow[], Symbol_Follow_Provitional[];
int Number_Operation = 0;
uchar Message_Recive[];


//Follows Iputs of Python
int Max_Operation          = 20;
double Balance_Mother      = 0;

//Array for INIT
string Symbol_Follow_Init[];
string Symbol_Lead_Init[];



//For Price (Digits of Price for Open Price, SL y TP)
int Digits_symbol = 0;


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

   if(Child_Socket == -1)//---Child Account
     {
      Start_Account_Child("0.0.0.0", Port);
      if(Child_Socket == -1)
        {
         Alert("No Connect Socket");
         return(INIT_FAILED);
        }
     }


//Arrays Leads_Follow (When make Order of Operation)
   ArrayResize(Ticket_Lead_Follow, Max_Operation);
   ArrayFill(Ticket_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Symbol_Lead_Follow, Max_Operation);

   ArrayResize(Order_Type_Lead_Follow, Max_Operation);
   ArrayFill(Order_Type_Lead_Follow, 0, Max_Operation, -1);

   ArrayResize(Lot_Lead_Follow, Max_Operation);
   ArrayFill(Lot_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Open_Price_Lead_Follow, Max_Operation);
   ArrayFill(Open_Price_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(TP_Lead_Follow, Max_Operation);
   ArrayFill(TP_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(SL_Lead_Follow, Max_Operation);
   ArrayFill(SL_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Comment_Lead_Follow, Max_Operation);

   ArrayResize(Start_Time_Lead_Follow, Max_Operation);
   ArrayFill(Start_Time_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Time_Limit_Lead_Follow, Max_Operation);
   ArrayFill(Time_Limit_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Order_Open_Time, Max_Operation);
   ArrayFill(Order_Open_Time, 0, Max_Operation, 0);

   ArrayResize(Order_Open_Time_Lead_Follow, Max_Operation);
   ArrayFill(Order_Open_Time_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Order_Open_Time_Provitional, Max_Operation);
   ArrayFill(Order_Open_Time_Provitional, 0, Max_Operation, 0);

//Arrays Follow
   ArrayResize(Ticket_Follow, Max_Operation);
   ArrayFill(Ticket_Follow, 0, Max_Operation, 0);

//Arrays for INIT
   Array_Symbols(Symbol_Lead_Init, Symbol_Follow_Init);
   Number_Operation = 0;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   Close_Connection_Socket(Child_Socket);
   Close_Connection_Socket(New_Socket);
   WSACleanup();
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(Child_Socket == -1)
      Start_Account_Child("0.0.0.0", Port);
   else
     {
      int Len_Recive;
      message_child = Recive_Message(Len_Recive, Child_Socket);
      if(Len_Recive > 0 && message_child != message_child_before)
         if(Arrays_Extract(message_child_before,         message_child,
                           Ticket_Lead,                  Ticket_Lead_Provitional,
                           Symbol_Follow,                Symbol_Follow_Provitional,
                           Order_Type_Lead,              Order_Type_Lead_Provitional,
                           Lot_Lead,                     Lot_Lead_Provitional,
                           Open_Price_Lead,              Open_Price_Lead_Provitional,
                           TP_Lead,                      TP_Lead_Provitional,
                           SL_Lead,                      SL_Lead_Provitional,
                           Comment_Lead,                 Comment_Lead_Provitional,
                           Start_Time_Lead,              Start_Time_Lead_Provitional,
                           Time_Limit_Lead,              Time_Limit_Lead_Provitional,
                           Order_Open_Time,              Order_Open_Time_Provitional,
                           Order_Open_Time_Lead_Follow,  Ticket_Lead_Follow))
           {
            Print("Antes de realizar operación ");
            if(Delay>0)
               Sleep(1000*Delay);

            Operation(Ticket_Follow,                  Start_Time_Lead,
                      Ticket_Lead_Follow,             Ticket_Lead,
                      Symbol_Lead_Follow,             Symbol_Follow,
                      Order_Type_Lead_Follow,         Order_Type_Lead,
                      Lot_Lead_Follow,                Lot_Lead,
                      Open_Price_Lead_Follow,         Open_Price_Lead,
                      TP_Lead_Follow,                 TP_Lead,
                      SL_Lead_Follow,                 SL_Lead,
                      Comment_Lead_Follow,            Comment_Lead,
                      Order_Open_Time_Lead_Follow,    Order_Open_Time);

            Close_Operations(Ticket_Lead,
                             Ticket_Follow,
                             Ticket_Lead_Follow,
                             Symbol_Lead_Follow,
                             Order_Type_Lead_Follow,
                             Lot_Lead_Follow,
                             Open_Price_Lead_Follow,
                             TP_Lead_Follow,
                             SL_Lead_Follow,
                             Comment_Lead_Follow,
                             Order_Open_Time_Lead_Follow);
            Print("Despues de realizar operación ");
           }
     }

  }


//+------------------------------------------------------------------+
//|-----SOCKET SECTION COMMON--------------SOCKET SECTION COMMON-----|
//+------------------------------------------------------------------+

//+----------Close Connection
void Close_Connection_Socket(int server)
  {
   closesocket(server);
   Child_Socket = -1;
  }

//+------------------------------------------------------------------+
//|------SOCKET SECTION CHILD--------------SOCKET SECTION CHILD------|
//+------------------------------------------------------------------+

//+------From socket() to listen()
void Start_Account_Child(string addr_local, ushort port_local)
  {
   Child_Socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
   if(Child_Socket == -1)
     {
      Print("Error in create socket number: ", WSAGetLastError());
      WSACleanup();
      return;
     }

//---Direction and Port configuration (Local direction)
   uchar addr_array_local[];
   StringToCharArray(addr_local, addr_array_local);
   ArrayResize(addr_array_local, ArraySize(addr_array_local) + 1);

   sockaddr local_server;
   local_server.family  = AF_INET;
   local_server.port    = htons(port_local);
   local_server.address = inet_addr(addr_array_local);

//--- Bind socket with IP and Port local
   int Bind_Socket = bind(Child_Socket, local_server, sizeof(sockaddr));
   if(Bind_Socket != 0)
     {
      Print("Error in bind number: ", WSAGetLastError());
      Close_Connection_Socket(Child_Socket);
      return;
     }

//--- Listen socket
   int Listen_Socket = listen(Child_Socket, 2);
   if(Listen_Socket != 0)
     {
      Print("Error in listen number: ", WSAGetLastError());
      Close_Connection_Socket(Child_Socket);
      return;
     }

   Print("Waiting message of server...");
  }

//+-------Message recive
string Recive_Message(int &length_Message, int &Server_Socket)
  {
//--- Accept Conection
   length_Message = 0;
   string recive = "";

   sockaddr local_server;
   int  New_addrlen = sizeof(sockaddr);
   New_Socket = accept(Server_Socket, local_server, New_addrlen);

   if(New_Socket == -1)
      return recive;
   else
      Print("Accept New Socket");

   uchar Message_Child [];
   string Message = "";
   ArrayResize(Message_Child, 3000);

   length_Message = recv(New_Socket, Message_Child, 3000, 0);

   if(length_Message > 0)
     {
      ArrayResize(Message_Recive, length_Message);
      recive = CharArrayToString(Message_Child, 0, length_Message);
      closesocket(New_Socket);
     }
   else
     {
      Print("Error in reciv nuember: ", WSAGetLastError());
      return recive;
     }
   return recive;
  }


//+------------------------------------------------------------------+
//| FOLLOW SECTION-----------FOLLOW SECTION-----------FOLLOW SECTION |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Arrays And Comparative (true is operation or modification)        |
//+------------------------------------------------------------------+
bool Arrays_Extract(string &message_before,                    string message,
                    ulong &ticket_Lead[],                      ulong &ticket_Lead_Provitional[],
                    string &symbol_Follow[],                   string &symbol_Follow_Provitional[],
                    int &order_Type_Lead[],                    int &order_Type_Lead_Provitional[],
                    double &lot_Lead[],                        double &lot_Lead_Provitional[],
                    double &open_Price_Lead[],                 double &open_Price_Lead_Provitional[],
                    double &tp_Lead[],                         double &tp_Lead_Provitional[],
                    double &sl_Lead[],                         double &sl_Lead_Provitional[],
                    string &comment_Lead[],                    string &comment_Lead_Provitional[],
                    datetime &start_Time_Lead[],               datetime &start_Time_Lead_Provitional[],
                    datetime &time_Limit_Lead[],               datetime &time_Limit_Lead_Provitional[],
                    datetime &order_Open_Time[],               datetime &order_Open_Time_Provitional[],
                    datetime &order_Open_Time_Lead_Follow[],   ulong &ticket_Lead_Follow[])   //Onli extract Values
  {
   bool Operations_Mother = false;
   if(message != message_before)
     {
      message_before = message;
      Operations_Mother = true;

      if(message == "None")
        {
         ArrayResize(ticket_Lead, 0);
         ArrayResize(symbol_Follow, 0);
         ArrayResize(order_Type_Lead, 0);
         ArrayResize(lot_Lead, 0);
         ArrayResize(open_Price_Lead, 0);
         ArrayResize(tp_Lead, 0);
         ArrayResize(sl_Lead, 0);
         ArrayResize(comment_Lead, 0);
         ArrayResize(start_Time_Lead, 0);
         ArrayResize(time_Limit_Lead, 0);
         ArrayResize(ticket_Lead_Provitional, 0);
         ArrayResize(symbol_Follow_Provitional, 0);
         ArrayResize(order_Type_Lead_Provitional, 0);
         ArrayResize(lot_Lead_Provitional, 0);
         ArrayResize(open_Price_Lead_Provitional, 0);
         ArrayResize(tp_Lead_Provitional, 0);
         ArrayResize(sl_Lead_Provitional, 0);
         ArrayResize(comment_Lead_Provitional, 0);
         ArrayResize(start_Time_Lead_Provitional, 0);
         ArrayResize(time_Limit_Lead_Provitional, 0);
         ArrayResize(order_Open_Time, 0);
         ArrayResize(order_Open_Time_Provitional, 0);

         if(TimeCurrent() > Time_Expire)
            OnInit();
        }
      else
        {
         ArrayResize(ticket_Lead, Max_Operation);
         ArrayResize(symbol_Follow, Max_Operation);
         ArrayResize(order_Type_Lead, Max_Operation);
         ArrayResize(lot_Lead, Max_Operation);
         ArrayResize(open_Price_Lead, Max_Operation);
         ArrayResize(tp_Lead, Max_Operation);
         ArrayResize(sl_Lead, Max_Operation);
         ArrayResize(comment_Lead, Max_Operation);
         ArrayResize(start_Time_Lead, Max_Operation);
         ArrayResize(time_Limit_Lead, Max_Operation);
         ArrayResize(ticket_Lead_Provitional, Max_Operation);
         ArrayResize(symbol_Follow_Provitional, Max_Operation);
         ArrayResize(order_Type_Lead_Provitional, Max_Operation);
         ArrayResize(lot_Lead_Provitional, Max_Operation);
         ArrayResize(open_Price_Lead_Provitional, Max_Operation);
         ArrayResize(tp_Lead_Provitional, Max_Operation);
         ArrayResize(sl_Lead_Provitional, Max_Operation);
         ArrayResize(comment_Lead_Provitional, Max_Operation);
         ArrayResize(start_Time_Lead_Provitional, Max_Operation);
         ArrayResize(time_Limit_Lead_Provitional, Max_Operation);
         ArrayResize(order_Open_Time, Max_Operation);
         ArrayResize(order_Open_Time_Provitional, Max_Operation);

         int Position_Array = 0;
         bool Permit_Extract_Ticket = true;
         bool Exist_Partial_Close = false;
         for(int j = 0; j < StringLen(message) ; j++)
           {
            if(CharToStr(uchar(message[j])) == "A") //Symbol
              {
               string Value_Extract = Extract_Values(j, message, "A1");
               bool Currency_Permit = false;

               for(int k = 0; k < 8; k++)
                  if(Value_Extract == Symbol_Lead_Init[k])
                    {
                     Value_Extract = Symbol_Follow_Init[k];
                     Currency_Permit = true;
                     break;
                    }

               if(!Currency_Permit)
                  Permit_Extract_Ticket = false;
               else
                 {
                  symbol_Follow[Position_Array] = Value_Extract;
                  symbol_Follow_Provitional[Position_Array] = Value_Extract;
                  continue;
                 }
              }

            if(CharToStr(uchar(message[j])) == "B") //Tickets
              {
               ulong Value_Extract = StringToInteger(Extract_Values(j, message, "B1"));

               if(!Permit_Extract_Ticket)
                  continue;

               ticket_Lead[Position_Array] = Value_Extract;
               ticket_Lead_Provitional[Position_Array] = Value_Extract;
               continue;
              }

            if(CharToStr(uchar(message[j])) == "C") //Comment
              {
               string Value_Extract = Extract_Values(j, message, "C1");

               if(!Permit_Extract_Ticket)
                  continue;

               comment_Lead[Position_Array] = Value_Extract;
               comment_Lead_Provitional[Position_Array] = Value_Extract;

               if(StringSubstr(Value_Extract, 0, 6) == "from #")
                  Exist_Partial_Close = true;

               continue;
              }

            if(CharToStr(uchar(message[j])) == "D") //Lots
              {
               double Value_Extract = StringToDouble(Extract_Values(j, message, "D1"));

               if(!Permit_Extract_Ticket)
                  continue;

               int Digits_Lots_Symbol_Actually = Digits_lot_Size(symbol_Follow[Position_Array]);

               if(Tipo_de_Lotaje == 0) //Lotaje Fijo
                  Value_Extract = NormalizeDouble(lotaje_Fijo, Digits_Lots_Symbol_Actually);
               else
                 {
                  //Lotaje Multiplicado
                  Value_Extract = NormalizeDouble((Value_Extract * Multiplicador_del_Lotaje), Digits_Lots_Symbol_Actually);

                  double Minimo_Lotaje = MarketInfo(symbol_Follow[Position_Array], MODE_MINLOT);
                  double Maximo_Lotaje = MarketInfo(symbol_Follow[Position_Array], MODE_MAXLOT);

                  if(Value_Extract < Minimo_Lotaje)
                     Value_Extract = Minimo_Lotaje;

                  if(Value_Extract > Maximo_Lotaje)
                     Value_Extract = Maximo_Lotaje;
                 }

               lot_Lead[Position_Array] = Value_Extract;
               lot_Lead_Provitional[Position_Array] = Value_Extract;
               continue;
              }

            if(CharToStr(uchar(message[j])) == "E") //Open Price
              {
               Digits_symbol = Digits_Symbol(symbol_Follow[Position_Array]);
               double Value_Extract = NormalizeDouble(StringToDouble(Extract_Values(j, message, "E1")),Digits_symbol);

               if(!Permit_Extract_Ticket)
                  continue;

               open_Price_Lead[Position_Array] = Value_Extract;
               open_Price_Lead_Provitional[Position_Array] = Value_Extract;
               continue;
              }

            if(CharToStr(uchar(message[j])) == "F") //Take Profit
              {
               double Value_Extract = StringToDouble(Extract_Values(j, message, "F1"));

               if(!Permit_Extract_Ticket)
                  continue;

               tp_Lead[Position_Array] = NormalizeDouble(Value_Extract, Digits_symbol);
               tp_Lead_Provitional[Position_Array] = NormalizeDouble(Value_Extract, Digits_symbol);
               continue;
              }

            if(CharToStr(uchar(message[j])) == "G") //Stop Loss
              {
               double Value_Extract = StringToDouble(Extract_Values(j, message, "G1"));

               if(!Permit_Extract_Ticket)
                  continue;

               sl_Lead[Position_Array] = NormalizeDouble(Value_Extract, Digits_symbol);
               sl_Lead_Provitional[Position_Array] = NormalizeDouble(Value_Extract, Digits_symbol);
               continue;
              }

            if(CharToStr(uchar(message[j])) == "H") //Type Order
              {
               int Value_Extract = int(StringToInteger(Extract_Values(j, message, "H1")));

               if(!Permit_Extract_Ticket)
                  continue;

               order_Type_Lead[Position_Array] = Value_Extract;
               order_Type_Lead_Provitional[Position_Array] = Value_Extract;
               continue;
              }

            if(CharToStr(uchar(message[j])) == "I") //Time Current, Used for comparative and permit Operation
              {
               datetime Value_Extract = StrToTime(Extract_Values(j, message, "I1"));

               if(!Permit_Extract_Ticket)
                  continue;

               start_Time_Lead[Position_Array] = Value_Extract;
               start_Time_Lead_Provitional[Position_Array] = Value_Extract;
               continue;
              }

            if(CharToStr(uchar(message[j])) == "J") //time expiration
              {
               datetime Value_Extract = StringToTime(Extract_Values(j, message, "J1"));

               if(!Permit_Extract_Ticket)
                  continue;

               time_Limit_Lead[Position_Array] = 0;
               time_Limit_Lead_Provitional[Position_Array] = 0;
               continue;
              }

            if(CharToStr(uchar(message[j])) == "K") //order open time
              {
               datetime Value_Extract = StringToTime(Extract_Values(j, message, "K1"));

               if(!Permit_Extract_Ticket)
                  continue;

               order_Open_Time[Position_Array] = Value_Extract;
               order_Open_Time_Provitional[Position_Array] = Value_Extract;

               //Print("order_Open_Time in position ", Position_Array, " is: ", Value_Extract);

               if(Exist_Partial_Close)
                  for(int kk = 0; kk < ArraySize(order_Open_Time_Lead_Follow); kk++)
                     if(Value_Extract == order_Open_Time_Lead_Follow[kk])
                       {
                        ticket_Lead[Position_Array] = ticket_Lead_Follow[kk];
                        ticket_Lead_Provitional[Position_Array] = ticket_Lead_Follow[kk];
                       }

               //Print("ticket_Lead in position Array ", Position_Array, " is: ", ticket_Lead[Position_Array]);
               continue;
              }


            if(CharToStr(uchar(message[j])) == "L") //Balance
              {
               Balance_Mother = StringToDouble(Extract_Values(j, message, "L1"));

               if(!Permit_Extract_Ticket)
                  continue;

               Position_Array++;
               continue;
              }

           }

         ArrayResize(ticket_Lead, Position_Array);
         ArrayResize(symbol_Follow, Position_Array);
         ArrayResize(order_Type_Lead, Position_Array);
         ArrayResize(lot_Lead, Position_Array);
         ArrayResize(open_Price_Lead, Position_Array);
         ArrayResize(tp_Lead, Position_Array);
         ArrayResize(sl_Lead, Position_Array);
         ArrayResize(comment_Lead, Position_Array);
         ArrayResize(start_Time_Lead, Position_Array);
         ArrayResize(time_Limit_Lead, Position_Array);
         ArrayResize(ticket_Lead_Provitional, Position_Array);
         ArrayResize(symbol_Follow_Provitional, Position_Array);
         ArrayResize(order_Type_Lead_Provitional, Position_Array);
         ArrayResize(lot_Lead_Provitional, Position_Array);
         ArrayResize(open_Price_Lead_Provitional, Position_Array);
         ArrayResize(tp_Lead_Provitional, Position_Array);
         ArrayResize(sl_Lead_Provitional, Position_Array);
         ArrayResize(comment_Lead_Provitional, Position_Array);
         ArrayResize(start_Time_Lead_Provitional, Position_Array);
         ArrayResize(time_Limit_Lead_Provitional, Position_Array);

         ArrayResize(order_Open_Time, Position_Array);
         ArrayResize(order_Open_Time_Provitional, Position_Array);

         Sort_Tickets_Lead(ticket_Lead,      ticket_Lead_Provitional,
                           symbol_Follow,    symbol_Follow_Provitional,
                           order_Type_Lead,  order_Type_Lead_Provitional,
                           lot_Lead,         lot_Lead_Provitional,
                           open_Price_Lead,  open_Price_Lead_Provitional,
                           tp_Lead,          tp_Lead_Provitional,
                           sl_Lead,          sl_Lead_Provitional,
                           comment_Lead,     comment_Lead_Provitional,
                           start_Time_Lead,  start_Time_Lead_Provitional,
                           time_Limit_Lead,  time_Limit_Lead_Provitional,
                           order_Open_Time,  order_Open_Time_Provitional);
        }
     }
   return Operations_Mother;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Extract Values                                                    |
//+------------------------------------------------------------------+
string Extract_Values(int &Position_Actually, string Word_Lead_Completly, string Final_Letter)
  {
   string Word = "";
   for(int i = Position_Actually + 1; i < StringLen(Word_Lead_Completly); i++)
      if(CharToString(uchar(Word_Lead_Completly[i])) + CharToString(uchar(Word_Lead_Completly[i + 1])) == Final_Letter)
        {
         Position_Actually = i;
         break;
        }
      else
         Word = Word + CharToString(uchar(Word_Lead_Completly[i]));

   return Word;
  }
//+--------------------------------------------------------------



//+------------------------------------------------------------------+
//|Digits Lot Size                                                   |
//+------------------------------------------------------------------+
int Digits_lot_Size(string Symbol_Market)
  {
   int Value = 0;
   double Minimo_Lotaje = MarketInfo(Symbol_Market, MODE_MINLOT);
   double Value_Mul = 0;
   int A = 0;

   while(true)
     {
      Value_Mul = Minimo_Lotaje * (MathPow(10, A));
      int value_mult_2 = int(StringToInteger(DoubleToString(Value_Mul)));
      if(Value_Mul == value_mult_2 || A > 5)
         break;
      A++;
     }

   if(A <= 5)
      Value = A;

   return Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Digits Symbol                                                     |
//+------------------------------------------------------------------+
int Digits_Symbol(string Symbol_Market)
  {
   int Value = 0;
   double Current_Price = MarketInfo(Symbol_Market, MODE_ASK);
   double Value_Mul = 0;
   int A = 0;

   while(true)
     {
      Value_Mul = Current_Price * (MathPow(10, A));
      int value_mult_2 = int(StringToInteger(DoubleToString(Value_Mul)));
      if(Value_Mul == value_mult_2 || A > 6)
         break;
      A++;
     }

   if(A <= 6)
      Value = A;

   return Value;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Array_Symbols(string &symbol_lead_Init[], string &symbols_Follow_Init[])
  {
   ArrayResize(symbol_lead_Init, 8);
   ArrayResize(symbols_Follow_Init, 8);

   symbol_lead_Init[0] = Primer_Mercado;
   symbols_Follow_Init[0] = Primer_Mercado_S;

   symbol_lead_Init[1] = Segundo_Mercado;
   symbols_Follow_Init[1] = Segundo_Mercado_S;

   symbol_lead_Init[2] = Tercer_Mercado;
   symbols_Follow_Init[2] = Tercer_Mercado_S;

   symbol_lead_Init[3] = Cuarto_Mercado;
   symbols_Follow_Init[3] = Cuarto_Mercado_S;

   symbol_lead_Init[4] = Quinto_Mercado;
   symbols_Follow_Init[4] = Quinto_Mercado_S;

   symbol_lead_Init[5] = Sexto_Mercado;
   symbols_Follow_Init[5] = Sexto_Mercado_S;

   symbol_lead_Init[6] = Septimo_Mercado;
   symbols_Follow_Init[6] = Septimo_Mercado_S;

   symbol_lead_Init[7] = Octavo_Mercado;
   symbols_Follow_Init[7] = Octavo_Mercado_S;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Sorts Tickets Follow and Ticket Lead Follow                       |
//+------------------------------------------------------------------+
void Sort_Tickets_Follow(int &ticket_Follow[],
                         ulong &ticket_Lead_Follow[],
                         string &symbol_Lead_Follow[],
                         int &order_Type_Lead_Follow[],
                         double &lot_Lead_Follow[],
                         double &open_Price_Lead_Follow[],
                         double &tp_Lead_Follow[],
                         double &sl_Lead_Follow[],
                         string &comment_Lead_Follow[],
                         datetime &order_Open_Time[])
  {
//---Make the provitionals
   int ticket_Follow_Provitional[];
   ArrayResize(ticket_Follow_Provitional, ArraySize(ticket_Follow));

   ulong ticket_Lead_Follow_Provitional[];
   ArrayResize(ticket_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   string symbol_Lead_Follow_Provitional[];
   ArrayResize(symbol_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   int order_Type_Lead_Follow_Provitional[];
   ArrayResize(order_Type_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   double lot_Lead_Follow_Provitional[];
   ArrayResize(lot_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   double open_Price_Lead_Follow_Provitional[];
   ArrayResize(open_Price_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   double tp_Lead_Follow_Provitional[];
   ArrayResize(tp_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   double sl_Lead_Follow_Provitional[];
   ArrayResize(sl_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   string comment_Lead_Follow_Provitional[];
   ArrayResize(comment_Lead_Follow_Provitional, ArraySize(ticket_Follow));

   datetime order_Open_Price_Lead_Follow_Provitional[];
   ArrayResize(order_Open_Price_Lead_Follow_Provitional, ArraySize(ticket_Follow));

//---Make the array_position
   int Array_Position[];
   ArrayResize(Array_Position, ArraySize(ticket_Follow));

//---First loop for Position
   for(int i = 0; i < ArraySize(ticket_Follow); i++)
      if(ticket_Lead_Follow[i] > 0)
         Array_Position[i] = 1;
      else
         Array_Position[i] = 0;

//---Complete the Provitional Arrays
   int ArrayFinal = 0;
   int ArrayFinal_Lead_Follow = 0;
   for(int i = 0; i < ArraySize(ticket_Follow); i++)
     {
      if(ticket_Follow[i] != 0)
        {
         ticket_Follow_Provitional[ArrayFinal] = ticket_Follow[i];
         ArrayFinal++;
        }
      else
        {
         if(ticket_Follow[i] == 0)
           {
            ticket_Follow_Provitional[ArrayFinal] = ticket_Follow[i];
            ArrayFinal++;
           }
        }
     }

   for(int i = 0; i < ArraySize(ticket_Lead_Follow); i++)
     {
      if(ticket_Lead_Follow[i] != 0)
        {
         ticket_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = ticket_Lead_Follow[i];
         symbol_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = symbol_Lead_Follow[i];
         order_Type_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = order_Type_Lead_Follow[i];
         lot_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = lot_Lead_Follow[i];
         open_Price_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = open_Price_Lead_Follow[i];
         tp_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = tp_Lead_Follow[i];
         sl_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = sl_Lead_Follow[i];
         comment_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = comment_Lead_Follow[i];
         order_Open_Price_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = order_Open_Time[i];
         ArrayFinal_Lead_Follow++;
        }
      else
        {
         if(ticket_Lead_Follow[i] == 0)
           {
            ticket_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = 0;
            symbol_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = "";
            order_Type_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = 0;
            lot_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = 0;
            open_Price_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = 0;
            tp_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = 0;
            sl_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = 0;
            comment_Lead_Follow_Provitional[ArrayFinal_Lead_Follow] = "";
            order_Open_Time[ArrayFinal_Lead_Follow] = 0;
            ArrayFinal_Lead_Follow++;
           }
        }
     }

//---Sort Arrays
   int Position_Ticket = 0;
   for(int i = 0; i < ArraySize(ticket_Follow); i++)
      if(Array_Position[i] == 1)
        {
         ticket_Follow[Position_Ticket] = ticket_Follow_Provitional[i];
         ticket_Lead_Follow[Position_Ticket] = ticket_Lead_Follow_Provitional[i];
         symbol_Lead_Follow[Position_Ticket] = symbol_Lead_Follow_Provitional[i];
         order_Type_Lead_Follow[Position_Ticket] = order_Type_Lead_Follow_Provitional[i];
         lot_Lead_Follow[Position_Ticket] = lot_Lead_Follow_Provitional[i];
         open_Price_Lead_Follow[Position_Ticket] = open_Price_Lead_Follow_Provitional[i];
         tp_Lead_Follow[Position_Ticket] = tp_Lead_Follow_Provitional[i];
         sl_Lead_Follow[Position_Ticket] = sl_Lead_Follow_Provitional[i];
         comment_Lead_Follow[Position_Ticket] = comment_Lead_Follow_Provitional[i];
         order_Open_Time[Position_Ticket] = order_Open_Price_Lead_Follow_Provitional[i];
         Position_Ticket++;
        }

   for(int i = Position_Ticket; i < ArraySize(ticket_Follow); i++)
     {
      ticket_Follow[Position_Ticket] = 0;
      ticket_Lead_Follow[Position_Ticket] = 0;
      symbol_Lead_Follow[Position_Ticket] = "";
      order_Type_Lead_Follow[Position_Ticket] = 0;
      lot_Lead_Follow[Position_Ticket] = 0;
      open_Price_Lead_Follow[Position_Ticket] = 0;
      tp_Lead_Follow[Position_Ticket] = 0;
      sl_Lead_Follow[Position_Ticket] = 0;
      comment_Lead_Follow[Position_Ticket] = "";
      order_Open_Time[i] = 0;
      Position_Ticket++;
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Sorts Tickets Leads                                               |
//+------------------------------------------------------------------+
void Sort_Tickets_Lead(ulong &ticket_Lead[],                      ulong &ticket_Lead_Provitional[],
                       string &symbol_Follow[],                   string &symbol_Follow_Provitional[],
                       int &order_Type_Lead[],                    int &order_Type_Lead_Provitional[],
                       double &lot_Lead[],                        double &lot_Lead_Provitional[],
                       double &open_Price_Lead[],                 double &open_Price_Lead_Provitional[],
                       double &tp_Lead[],                         double &tp_Lead_Provitional[],
                       double &sl_Lead[],                         double &sl_Lead_Provitional[],
                       string &comment_Lead[],                    string &comment_Lead_Provitional[],
                       datetime &start_Time_Lead[],               datetime &start_Time_Lead_Provitional[],
                       datetime &time_Limit_Lead[],               datetime &time_Limit_Lead_Provitional[],
                       datetime &order_Open_Time[],               datetime &order_Open_Time_Provitional[])
  {
   if(ArraySize(ticket_Lead) > 1)
     {
      int Ar_Size = ArraySize(ticket_Lead);
      ArraySort(ticket_Lead, WHOLE_ARRAY, 0, MODE_ASCEND);
      for(int i = 0; i < Ar_Size; i++)//Lead
         for(int j = 0; j < Ar_Size; j++)//Lead provitional
            if(ticket_Lead[i] == ticket_Lead_Provitional[j] && ticket_Lead_Provitional[j] != 0)
              {
               //Print("ticket_Lead in position ", i, " is: ", ticket_Lead[i]);
               symbol_Follow[i] = symbol_Follow_Provitional[j];
               order_Type_Lead[i] = order_Type_Lead_Provitional[j];
               lot_Lead[i] = lot_Lead_Provitional[j];
               open_Price_Lead[i] = open_Price_Lead_Provitional[j];
               tp_Lead[i] = tp_Lead_Provitional[j];
               sl_Lead[i] = sl_Lead_Provitional[j];
               comment_Lead[i] = comment_Lead_Provitional[j];
               start_Time_Lead[i] = start_Time_Lead_Provitional[j];
               time_Limit_Lead[i] = time_Limit_Lead_Provitional[j];
               order_Open_Time[i] = order_Open_Time_Provitional[j];
               break;
              }

     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Creation and Modification Operation                               |
//+------------------------------------------------------------------+
void Operation(int &ticket_Follow[],                   datetime &start_Time_Lead[],
               ulong &ticket_Lead_Follow[],              ulong &ticket_Lead[],
               string &symbol_Lead_Follow[],             string &symbol_Follow[],
               int &order_Type_Lead_Follow[],            int &order_Type_Lead[],
               double &lot_Lead_Follow[],                double &lot_Lead[],
               double &open_Price_Lead_Follow[],         double &open_Price_Lead[],
               double &tp_Lead_Follow[],                 double &tp_Lead[],
               double &sl_Lead_Follow[],                 double &sl_Lead[],
               string &comment_Lead_Follow[],            string &comment_Lead[],
               datetime &order_Open_Time_Lead_Follow[],  datetime &order_Open_Time[])
  {
   double open_price;
   double SL;
   double TP;

   for(int i = 0; i < ArraySize(ticket_Lead); i++)
     {

      if(order_Type_Lead[i] == 0 || order_Type_Lead[i] == 1) //Make or Modification Operation
        {
         if(order_Type_Lead[i] == 0)
            open_price = MarketInfo(symbol_Follow[i], MODE_ASK);
         else
            open_price = MarketInfo(symbol_Follow[i], MODE_BID);

         if(ticket_Lead_Follow[i] == 0 && ticket_Lead_Follow[i] != ticket_Lead[i]) //Make Operation
           {
            //Modificatión of TP and SL for TP_ad and SL_ad
            if(order_Type_Lead[i] == 0)
              {
               SL = sl_Lead[i] - (Aditional_StopLoss * Point());
               TP = tp_Lead[i] + (Aditional_TakeProfit * Point());
              }
            else
              {
               SL = sl_Lead[i] + (Aditional_StopLoss * Point());
               TP = tp_Lead[i] - (Aditional_TakeProfit * Point());
              }

            if(sl_Lead[i] == 0)
               SL = sl_Lead[i];

            if(tp_Lead[i] == 0)
               TP = tp_Lead[i];


            //Make Operation
            ticket_Follow[i] = OrderSend(symbol_Follow[i], order_Type_Lead[i], lot_Lead[i], open_price, 100, SL, TP, comment_Lead[i], Magic_Number, 0, NULL);
            if(ticket_Follow[i] <= 0)
               Print("Error in Operation Number: ", GetLastError());
            else
              {
               ticket_Lead_Follow[i] = ticket_Lead[i];
               symbol_Lead_Follow[i] = symbol_Follow[i];
               order_Type_Lead_Follow[i] = order_Type_Lead[i];
               lot_Lead_Follow[i] = lot_Lead[i];
               open_Price_Lead_Follow[i] = open_Price_Lead[i];
               tp_Lead_Follow[i] = tp_Lead[i];
               sl_Lead_Follow[i] = sl_Lead[i];
               comment_Lead_Follow[i] = comment_Lead[i];
               order_Open_Time_Lead_Follow[i] = order_Open_Time[i];
               Number_Operation++;
              }
           }


         //Modificatión Operation
         if(ticket_Lead_Follow[i] == ticket_Lead[i] && ticket_Lead_Follow[i] != 0 && (sl_Lead_Follow[i] != sl_Lead[i] || tp_Lead_Follow[i] != tp_Lead[i]) && OrderSelect(ticket_Follow[i], SELECT_BY_TICKET)) //Modificatión TP, SL
           {
            //Modificatión of TP and SL for TP_ad and SL_ad
            if(order_Type_Lead[i] == 0)
              {
               SL = sl_Lead[i] - (Aditional_StopLoss * Point());
               TP = tp_Lead[i] + (Aditional_TakeProfit * Point());
              }
            else
              {
               SL = sl_Lead[i] + (Aditional_StopLoss * Point());
               TP = tp_Lead[i] - (Aditional_TakeProfit * Point());
              }

            if(sl_Lead[i] == 0)
               SL = sl_Lead[i];

            if(tp_Lead[i] == 0)
               TP = tp_Lead[i];

            //Modificatión Operation
            if(!OrderModify(ticket_Follow[i], OrderOpenPrice(), SL, TP, 0, NULL))
               Print("Error in modify number: ", GetLastError());
            else
              {
               tp_Lead_Follow[i] = tp_Lead[i];
               sl_Lead_Follow[i] = sl_Lead[i];
              }
           }

         //Partial Close
         if(ticket_Lead_Follow[i] == ticket_Lead[i] && ticket_Lead_Follow[i] != 0 && lot_Lead_Follow[i] != lot_Lead[i] && OrderSelect(ticket_Follow[i], SELECT_BY_TICKET)) //Partial Close
           {
            //Print("Start Partial Close");
            double Lot_Final =  OrderLots() - NormalizeDouble(lot_Lead[i], Digits_lot_Size(symbol_Follow[i]));
            double Minimo_Lotaje = MarketInfo(symbol_Follow[i], MODE_MINLOT);

            if(Lot_Final >= OrderLots())
               Lot_Final = OrderLots() - Minimo_Lotaje;

            if(OrderClose(ticket_Follow[i], Lot_Final, open_price, 100, NULL))
              {
               for(int k = 0; k < OrdersHistoryTotal(); k++)
                  if(OrderSelect(k, SELECT_BY_POS, MODE_HISTORY) && ticket_Follow[i] == OrderTicket())
                    {
                     ticket_Follow[i] = StrToInteger(StringSubstr(OrderComment(), 4, 0));
                     if(OrderSelect(ticket_Follow[i], SELECT_BY_TICKET))
                       {
                        comment_Lead_Follow[i] = OrderComment();
                        lot_Lead_Follow[i] = lot_Lead[i];
                        break;
                       }
                    }
              }
            else
               Print("Error in Partial Close Number: ", GetLastError());
           }
        }
      else //Create Pending Orders and/or Modification Orders
        {
         //Make Order
         if(ticket_Lead_Follow[i] != ticket_Lead[i] && ticket_Lead_Follow[i] == 0)
           {
            //Modificatión of TP and SL for TP_ad and SL_ad
            if(order_Type_Lead[i] == 2 || order_Type_Lead[i] == 4)//Order(s) Stop
              {
               SL = sl_Lead[i] - (Aditional_StopLoss * Point());
               TP = tp_Lead[i] + (Aditional_TakeProfit * Point());
              }
            else//Order(s) Limit
              {
               SL = sl_Lead[i] + (Aditional_StopLoss * Point());
               TP = tp_Lead[i] - (Aditional_TakeProfit * Point());
              }

            if(sl_Lead[i] == 0)
               SL = sl_Lead[i];

            if(tp_Lead[i] == 0)
               TP = tp_Lead[i];

            //Make Order
            ticket_Follow[i] = OrderSend(symbol_Follow[i], order_Type_Lead[i], lot_Lead[i], open_Price_Lead[i], 100, SL, TP, comment_Lead[i], Magic_Number, 0, NULL);
            if(ticket_Follow[i] <= 0)
               Print("Error in Order Number: ", GetLastError());
            else
              {
               ticket_Lead_Follow[i] = ticket_Lead[i];
               symbol_Lead_Follow[i] = symbol_Follow[i];
               order_Type_Lead_Follow[i] = order_Type_Lead[i];
               lot_Lead_Follow[i] = lot_Lead[i];
               open_Price_Lead_Follow[i] = open_Price_Lead[i];
               tp_Lead_Follow[i] = tp_Lead[i];
               sl_Lead_Follow[i] = sl_Lead[i];
               comment_Lead_Follow[i] = comment_Lead[i];
               Number_Operation++;
              }
           }


         //Modification Orders
         if(ticket_Lead_Follow[i] == ticket_Lead[i] && ticket_Lead_Follow[i] != 0 && (sl_Lead_Follow[i] != sl_Lead[i] || tp_Lead_Follow[i] != tp_Lead[i] || open_Price_Lead_Follow[i] != open_Price_Lead[i]))
           {
            //Modificatión of TP and SL for TP_ad and SL_ad
            if(order_Type_Lead[i] == 2 || order_Type_Lead[i] == 4)//Order(s) Stop
              {
               SL = sl_Lead[i] - (Aditional_StopLoss * Point());
               TP = tp_Lead[i] + (Aditional_TakeProfit * Point());
              }
            else//Order(s) Limit
              {
               SL = sl_Lead[i] + (Aditional_StopLoss * Point());
               TP = tp_Lead[i] - (Aditional_TakeProfit * Point());
              }

            if(sl_Lead[i] == 0)
               SL = sl_Lead[i];

            if(tp_Lead[i] == 0)
               TP = tp_Lead[i];

            //Modification Order
            if(!OrderModify(ticket_Follow[i], open_Price_Lead[i], SL, TP, 0, NULL))
               Print("Error in modify number: ", GetLastError());
            else
              {
               tp_Lead_Follow[i] = tp_Lead[i];
               sl_Lead_Follow[i] = sl_Lead[i];
               open_Price_Lead_Follow[i] = open_Price_Lead[i];
              }
           }
        }
     }//Finla for loop of Tickets Lead
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Close Operation and Delate Orders                                |
//+------------------------------------------------------------------+
void Close_Operations(ulong &ticket_Lead[],
                      int &ticket_Follow[],
                      ulong &ticket_Lead_Follow[],
                      string &symbol_Lead_Follow[],
                      int &order_Type_Lead_Follow[],
                      double &lot_Lead_Follow[],
                      double &open_Price_Lead_Follow[],
                      double &tp_Lead_Follow[],
                      double &sl_Lead_Follow[],
                      string &comment_Lead_Follow[],
                      datetime &order_Open_Time[])
  {
   bool close_Operation;
   int Size = Number_Operation;

   if(ArraySize(ticket_Lead) == 0) //Close All Operations
     {
      for(int i = 0; i < ArraySize(ticket_Follow); i++)
         Help_Close_Operations(ticket_Lead,
                               ticket_Follow,
                               ticket_Lead_Follow,
                               symbol_Lead_Follow,
                               order_Type_Lead_Follow,
                               lot_Lead_Follow,
                               open_Price_Lead_Follow,
                               tp_Lead_Follow,
                               sl_Lead_Follow,
                               comment_Lead_Follow,
                               i,
                               order_Open_Time);
      Inicialize();
     }
   else
     {
      for(int i = 0; i < ArraySize(ticket_Lead_Follow); i++)
        {
         if(ticket_Lead_Follow[i] != 0 && (close_Operation = true))
           {
            for(int j = 0; j < ArraySize(ticket_Lead); j++)
               if(ticket_Lead_Follow[i] == ticket_Lead[j])
                 {
                  close_Operation = false;
                  break;
                 }

            if(close_Operation)
              {
               Help_Close_Operations(ticket_Lead,
                                     ticket_Follow,
                                     ticket_Lead_Follow,
                                     symbol_Lead_Follow,
                                     order_Type_Lead_Follow,
                                     lot_Lead_Follow,
                                     open_Price_Lead_Follow,
                                     tp_Lead_Follow,
                                     sl_Lead_Follow,
                                     comment_Lead_Follow,
                                     i,
                                     order_Open_Time);
              }
           }

         if(i == ArraySize(ticket_Lead_Follow) - 1)
           {
            Sort_Tickets_Follow(ticket_Follow,
                                ticket_Lead_Follow,
                                symbol_Lead_Follow,
                                order_Type_Lead_Follow,
                                lot_Lead_Follow,
                                open_Price_Lead_Follow,
                                tp_Lead_Follow,
                                sl_Lead_Follow,
                                comment_Lead_Follow,
                                order_Open_Time);
           }

        } // Final for loop of int i
     }//Fina else

   Size = Number_Operation;

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Help Close Operation and Delate Orders                            |
//+------------------------------------------------------------------+
void Help_Close_Operations(ulong &ticket_Lead[],
                           int &ticket_Follow[],
                           ulong &ticket_Lead_Follow[],
                           string &symbol_Lead_Follow[],
                           int &order_Type_Lead_Follow[],
                           double &lot_Lead_Follow[],
                           double &open_Price_Lead_Follow[],
                           double &tp_Lead_Follow[],
                           double &sl_Lead_Follow[],
                           string &comment_Lead_Follow[],
                           int Position,
                           datetime &order_Open_Time[])
  {
   if(OrderSelect(ticket_Follow[Position], SELECT_BY_TICKET))
      if(OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
         if(OrderClose(ticket_Follow[Position], OrderLots(), OrderClosePrice(), 100, NULL))
           {
            ticket_Follow[Position] = 0;
            ticket_Lead_Follow[Position] = 0;
            symbol_Lead_Follow[Position] = "";
            order_Type_Lead_Follow[Position] = 0;
            lot_Lead_Follow[Position] = 0;
            open_Price_Lead_Follow[Position] = 0;
            tp_Lead_Follow[Position] = 0;
            sl_Lead_Follow[Position] = 0;
            comment_Lead_Follow[Position] = "";
            order_Open_Time[Position] = 0;
            Number_Operation--;
           }
         else
           {
            int ERROR = GetLastError();
            Print("Error in Close Operation Number: ", ERROR);
            if(ERROR == 4108) //Follow Closed Order
              {
               ticket_Follow[Position] = 0;
               ticket_Lead_Follow[Position] = 0;
               symbol_Lead_Follow[Position] = "";
               order_Type_Lead_Follow[Position] = 0;
               lot_Lead_Follow[Position] = 0;
               open_Price_Lead_Follow[Position] = 0;
               tp_Lead_Follow[Position] = 0;
               sl_Lead_Follow[Position] = 0;
               comment_Lead_Follow[Position] = "";
               order_Open_Time[Position] = 0;
               Number_Operation--;
              }
           }
        }
      else
         if(OrderDelete(ticket_Follow[Position]))
           {
            ticket_Follow[Position] = 0;
            ticket_Lead_Follow[Position] = 0;
            symbol_Lead_Follow[Position] = "";
            order_Type_Lead_Follow[Position] = 0;
            lot_Lead_Follow[Position] = 0;
            open_Price_Lead_Follow[Position] = 0;
            tp_Lead_Follow[Position] = 0;
            sl_Lead_Follow[Position] = 0;
            comment_Lead_Follow[Position] = "";
            Number_Operation--;
           }
         else
           {
            int ERROR = GetLastError();
            Print("Error in Close Order Number: ", ERROR);
            if(ERROR == 4108) //Follow Closed Order
              {
               ticket_Follow[Position] = 0;
               ticket_Lead_Follow[Position] = 0;
               symbol_Lead_Follow[Position] = "";
               order_Type_Lead_Follow[Position] = 0;
               lot_Lead_Follow[Position] = 0;
               open_Price_Lead_Follow[Position] = 0;
               tp_Lead_Follow[Position] = 0;
               sl_Lead_Follow[Position] = 0;
               comment_Lead_Follow[Position] = "";
               Number_Operation--;
              }
           }
  }
//+------------------------------------------------------------------+

//+--------Inicialize All Arrays
void Inicialize()
  {
//Arrays Leads_Follow (When make Order of Operation)
   ArrayResize(Ticket_Lead_Follow, Max_Operation);
   ArrayFill(Ticket_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Symbol_Lead_Follow, Max_Operation);

   ArrayResize(Order_Type_Lead_Follow, Max_Operation);
   ArrayFill(Order_Type_Lead_Follow, 0, Max_Operation, -1);

   ArrayResize(Lot_Lead_Follow, Max_Operation);
   ArrayFill(Lot_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Open_Price_Lead_Follow, Max_Operation);
   ArrayFill(Open_Price_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(TP_Lead_Follow, Max_Operation);
   ArrayFill(TP_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(SL_Lead_Follow, Max_Operation);
   ArrayFill(SL_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Comment_Lead_Follow, Max_Operation);

   ArrayResize(Start_Time_Lead_Follow, Max_Operation);
   ArrayFill(Start_Time_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Time_Limit_Lead_Follow, Max_Operation);
   ArrayFill(Time_Limit_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Order_Open_Time, Max_Operation);
   ArrayFill(Order_Open_Time, 0, Max_Operation, 0);

   ArrayResize(Order_Open_Time_Lead_Follow, Max_Operation);
   ArrayFill(Order_Open_Time_Lead_Follow, 0, Max_Operation, 0);

   ArrayResize(Order_Open_Time_Provitional, Max_Operation);
   ArrayFill(Order_Open_Time_Provitional, 0, Max_Operation, 0);

//Arrays Follow
   ArrayResize(Ticket_Follow, Max_Operation);
   ArrayFill(Ticket_Follow, 0, Max_Operation, 0);

//Arrays for INIT
   Array_Symbols(Symbol_Lead_Init, Symbol_Follow_Init);
   Number_Operation = 0;

   if(TimeCurrent() > Time_Expire)
      OnInit();
  }
//+------------------------------------------------------------------+
