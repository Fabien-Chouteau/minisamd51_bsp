------------------------------------------------------------------------------
--                                                                          --
--                        Copyright (C) 2020, AdaCore                       --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with System;
with System.Storage_Elements;

with HAL.GPIO;

with SAM.Clock_Setup_120Mhz;
with SAM.Main_Clock;
with SAM.Clock_Generator;
with SAM.Clock_Generator.IDs;
with SAM.Functions;

----------------
-- Minisamd51 --
----------------

package body Minisamd51 is

   System_Vectors : constant HAL.UInt32;
   pragma Import (Asm, System_Vectors, "__vectors");

   VTOR : System.Address
     with Volatile,
     Address => System.Storage_Elements.To_Address (16#E000_ED08#);

   procedure Init_System;
   procedure Init_I2C;
   procedure Init_SPI;

   -----------------
   -- Init_System --
   -----------------

   procedure Init_System is
   begin
      --  Set the vector table address
      VTOR := System_Vectors'Address;

      --  Setup the clock system
      SAM.Clock_Setup_120Mhz.Initialize_Clocks;

      LED.Clear;
      LED.Set_Mode (HAL.GPIO.Output);
      LED.Set_Pull_Resistor (HAL.GPIO.Floating);

      Button.Clear;
      Button.Set_Mode (HAL.GPIO.Input);
      Button.Set_Pull_Resistor (HAL.GPIO.Floating);

      DOTSTAR_DATA.Clear;
      DOTSTAR_DATA.Set_Mode (HAL.GPIO.Output);
      DOTSTAR_DATA.Set_Pull_Resistor (HAL.GPIO.Pull_Down);
      DOTSTAR_CLK.Clear;
      DOTSTAR_CLK.Set_Mode (HAL.GPIO.Output);
      DOTSTAR_CLK.Set_Pull_Resistor (HAL.GPIO.Pull_Down);

   end Init_System;

   --------------
   -- Init_I2C --
   --------------

   procedure Init_I2C is
   begin
      SAM.Clock_Generator.Configure_Periph_Channel
        (SAM.Clock_Generator.IDs.SERCOM2_CORE,
         SAM.Clock_Setup_120Mhz.Clk_48Mhz);

      SAM.Clock_Generator.Configure_Periph_Channel
        (SAM.Clock_Generator.IDs.SERCOM2_SLOW,
         SAM.Clock_Setup_120Mhz.Clk_32Khz);

      SAM.Main_Clock.SERCOM2_On;

      -- I2C --

      I2C_Port.Configure (Baud => 150);

      I2C_Port.Debug_Stop_Mode (Enabled => True);

      I2C_Port.Enable;

      -- IOs --

      SCL.Clear;
      SCL.Set_Mode (HAL.GPIO.Output);
      SCL.Set_Pull_Resistor (HAL.GPIO.Floating);
      SCL.Set_Function (SAM.Functions.PA13_SERCOM2_PAD1);

      SDA.Clear;
      SDA.Set_Mode (HAL.GPIO.Output);
      SDA.Set_Pull_Resistor (HAL.GPIO.Floating);
      SDA.Set_Function (SAM.Functions.PA12_SERCOM2_PAD0);
   end Init_I2C;

   --------------
   -- Init_SPI --
   --------------

   procedure Init_SPI is
   begin
      -- Clocks --

      SAM.Clock_Generator.Configure_Periph_Channel
        (SAM.Clock_Generator.IDs.SERCOM1_CORE,
         SAM.Clock_Setup_120Mhz.Clk_48Mhz);

      SAM.Clock_Generator.Configure_Periph_Channel
        (SAM.Clock_Generator.IDs.SERCOM1_SLOW,
         SAM.Clock_Setup_120Mhz.Clk_32Khz);

      SAM.Main_Clock.SERCOM1_On;

      -- SPI --

      SPI_Port.Configure
        (Baud                => 1,
         Data_Order          => SAM.SERCOM.SPI.Most_Significant_First,
         Phase               => SAM.SERCOM.SPI.Sample_Leading_Edge,
         Polarity            => SAM.SERCOM.SPI.Active_High,
         DIPO                => 0,
         DOPO                => 2,
         Slave_Select_Enable => False);

      SPI_Port.Debug_Stop_Mode (Enabled => True);

      SPI_Port.Enable;

      -- IOs --

      SCK.Clear;
      SCK.Set_Mode (HAL.GPIO.Output);
      SCK.Set_Pull_Resistor (HAL.GPIO.Floating);
      SCK.Set_Function (SAM.Functions.PA01_SERCOM1_PAD1);

      MOSI.Clear;
      MOSI.Set_Mode (HAL.GPIO.Output);
      MOSI.Set_Pull_Resistor (HAL.GPIO.Floating);
      MOSI.Set_Function (SAM.Functions.PB22_SERCOM1_PAD2);

      MISO.Clear;
      MISO.Set_Mode (HAL.GPIO.Output);
      MISO.Set_Pull_Resistor (HAL.GPIO.Floating);
      MISO.Set_Function (SAM.Functions.PB23_SERCOM1_PAD3);
   end Init_SPI;

   -----------------
   -- Turn_On_LED --
   -----------------

   procedure Turn_On_LED is
   begin
      LED.Set;
   end Turn_On_LED;

   ------------------
   -- Turn_Off_LED --
   ------------------

   procedure Turn_Off_LED is
   begin
      LED.Clear;
   end Turn_Off_LED;

   --------------------
   -- Button_Pressed --
   --------------------

   function Button_Pressed return Boolean
   is (Button.Set);

   -------------
   -- Set_RGB --
   -------------

   procedure Set_RGB (Brightness : HAL.UInt5;
                      R, G, B    : HAL.UInt8)
   is
      use HAL;

      procedure Bitbang (Val : UInt8);

      procedure Bitbang (Val : UInt8) is
         Shift : UInt8 := Val;
      begin
         for X in 1 .. 8 loop
            DOTSTAR_CLK.Clear;

            if (Shift and 2#1000_0000#) /= 0 then
               DOTSTAR_DATA.Set;
            else
               DOTSTAR_DATA.Clear;
            end if;

            DOTSTAR_CLK.Set;

            Shift := Shift_Left (Shift, 1);
         end loop;

         DOTSTAR_CLK.Clear;

      end Bitbang;
   begin
      --  Start frame
      for X in 1 .. 4 loop
         Bitbang (0);
      end loop;

      Bitbang (2#1110_0000# or UInt8 (Brightness));
      Bitbang (B);
      Bitbang (G);
      Bitbang (R);

      --  End Frame
      for X in 1 .. 4 loop
         Bitbang (HAL.UInt8'Last);
      end loop;
   end Set_RGB;

begin
   Init_System;
   Init_I2C;
   Init_SPI;
end Minisamd51;
