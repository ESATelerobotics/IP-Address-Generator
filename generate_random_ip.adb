with gnat.Command_Line;
use gnat.Command_Line;
with gnat.Strings;
with GNAT.sockets;

with ada.Text_IO;
with Ada.Exceptions;
with Ada.strings;
with ada.Strings.Fixed;
with ada.Strings.Maps;

with ada.numerics;
with ada.Numerics.Discrete_Random;

with ada.Containers.Vectors;

with System;

procedure Generate_Random_IP is
   Config : Command_Line_Configuration;

   Base_IP   : String := Get_Argument;
   Avoids: aliased gnat.Strings.String_Access;
   Avoid_IP : string (1..128);
   Upper_Limit    : aliased Integer;
   Lower_Limit    : aliased Integer;

   Address : GNAT.Sockets.Inet_Addr_Type;

   type IP_Octect is range 1..254;
   package IP_Vecs is new Ada.Containers.Vectors
     (Element_Type => IP_Octect,
      Index_Type => IP_Octect);

   Num : IP_Octect := 1;
   Allowed_IPs : IP_Vecs.Vector;
   Forbidden_IPs : IP_Vecs.Vector;

   C : IP_Vecs.Cursor;
   use IP_Vecs;
begin
   -- check the commandline
   Define_Switch(Config      => Config,
                 Output      => Lower_Limit'Access,
                 Switch      => "-l=",
                 Long_Switch => "--lower_limit=",
                 Help        => "Set the lower limit of the last octet",
                 Default     => 1);

   Define_Switch(Config      => Config,
                 Output      => Upper_Limit'Access,
                 Switch      => "-u=",
                 Long_Switch => "--upper_limit=",
                 Help        => "Set the upper limit of the last octet",
                 Default     => 254);

   Define_Switch(Config      => Config,
                 Output      => Avoids'Access,
                 Switch      => "-a=",
                 Long_Switch => "--avoid=",
                 Help        => "Set ocetets to be avoided, comma separated (e.g 4 or 4,7,8)");


   Getopt (Config);
   --assign prelim IP to automativcalli check the base parameter
   Address := GNAT.Sockets.Inet_Addr(Base_IP & "4");

   -- Get the string parameter
   ada.strings.fixed. Move (
                            Source  => Avoids.all,
                            Target  => Avoid_IP,
                            Drop    => ada.strings.Right,
                            Justify => ada.strings.Left,
                            Pad     => ada.strings.Space);

   --     Ada.Text_IO.Put_Line ("Input Data");
   --     Ada.Text_IO.Put_Line ("Base IP: " & Base_IP);
   --     Ada.Text_IO.Put_Line ("Lower limit: " & Lower_Limit'img);
   --     Ada.Text_IO.Put_Line ("Upper limit: " & Upper_Limit'img);
   --     Ada.Text_IO.Put_Line ("Avoid: " & Avoid_IP);

   --populate the array of the allow IPs
   for i in Lower_Limit..Upper_Limit loop
      Allowed_IPs.Append(IP_Octect(i));
   end loop;

   --  populate the array of the forbidden IPs from the input
   -- the first one
   declare
      Test : Integer := 0;
      Comma_Position : Natural;
   begin
      --ada.Text_IO.Put_Line("Test before: " & Test'img);

      --ada.Text_IO.Put_Line("Test after: " & Test'img);
      --        Forbidden_IPs.Append(IP_Octect'Value(Avoid_IP));


         loop
            --search for the comma and remove the stuff before
            Comma_Position := Ada.Strings.Fixed.Index(Avoid_IP, ",");
            exit when Comma_Position = 0;
            Test := Integer'Value(Avoid_IP(1..Comma_Position-1));
            Forbidden_IPs.Append(IP_Octect(Test));
            ada.Strings.Fixed.Delete(Source  => Avoid_IP,
                                     From    => Avoid_IP'First,
                                     Through => Comma_Position);

         end loop;
         -- get the last value
         Test := Integer'Value(Avoid_IP);
         Forbidden_IPs.Append(IP_Octect(Test));
   exception
      when Error : Constraint_Error =>
         null;
      when Error : others =>
         raise;
   end;

   --     ada.Text_IO.Put_Line("Forbidden");
   --     for i in 1..Forbidden_IPs.Length loop
   --        ada.Text_IO.Put_Line("i: " & i'Img & "vec: " & Forbidden_IPs.Element(IP_Octect(i))'img);
   --     end loop;
   --
   --     ada.Text_IO.Put_Line("Allowed");
   --     for i in 1..Allowed_IPs.Length loop
   --        ada.Text_IO.Put_Line("i: " & i'Img & "vec: " & Allowed_IPs.Element(IP_Octect(i))'img);
   --     end loop;

   --loop through the forbidden ip and eliminate them from the allowed ones
   while not Forbidden_IPs.Is_Empty loop
      C :=  Allowed_IPs.Find(Item => Forbidden_IPs.Element(1));
      if C = IP_Vecs.No_Element then
         Forbidden_IPs.Delete_First;
      else
         Allowed_IPs.Delete(C);
      end if;
   end loop;

   --     ada.Text_IO.Put_Line("Final Ips");
   --     for i in 1..Allowed_IPs.Length loop
   --        ada.Text_IO.Put_Line("i: " & i'Img & "vec: " & Allowed_IPs.Element(IP_Octect(i))'img);
   --     end loop;

   --select a random number of the allowed ones
   declare
      package Rand_Int is new Ada.Numerics.Discrete_Random(IP_Octect);
      seed : Rand_Int.Generator;
   begin
      Rand_Int.Reset(seed);
      Num := Rand_Int.Random(seed);
      while Num > IP_Octect(Allowed_IPs.Length) loop
         Num := Rand_Int.Random(seed);
      end loop;
      --Ada.Text_IO.Put_Line(Num'img);
      --ada.Text_IO.Put_Line("test" & ada.Strings.Fixed.Text);

   end;

   Ada.Text_IO.Put_Line(Base_IP(1..Base_IP'Length) & ada.Strings.fixed.Trim(Num'Img, ada.strings.left)); --Rand_Range'Image(Num));
   Address := GNAT.Sockets.Inet_Addr(Base_IP & ada.Strings.fixed.Trim(Num'Img, ada.strings.left));

exception
   when Error: gnat.Command_Line.Invalid_Switch =>
      ada.Text_IO.Put_Line("Invalid or missing parameter");
      ada.Text_IO.Put_Line(" ");
      Display_Help(Config);

   when Error : CONSTRAINT_ERROR =>
      ada.Text_IO.Put ("Please check if upper and lower limit are between 1 and 254");
      ada.Text_IO.Put ("Forbidden IP's correct? especially the comma (it should be 2 or 103,5,6)");

   when Error : GNAT.SOCKETS.SOCKET_ERROR =>
      ada.Text_IO.Put ("Please check if the format: ");
      ada.Text_IO.Put ("Is the Base IP is correct (it should be 192.168.220. or 10.1.0.)");

   when Error : GNAT.COMMAND_LINE.INVALID_PARAMETER =>
      ada.Text_IO.Put_Line("Invalid or missing parameter");
      ada.Text_IO.Put_Line(" ");
       Display_Help(Config);

   when Error: others =>
      ada.Text_IO.Put ("Unexpected exception: ");
      ada.Text_IO.Put_Line (Ada.Exceptions.Exception_Information(Error));
      raise;

end Generate_Random_IP;
