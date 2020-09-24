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

with HAL;

with SAM.Device;
with SAM.Port;
with SAM.SERCOM.I2C;
with SAM.SERCOM.SPI;

package Minisamd51 is

   procedure Turn_On_LED;
   --  Turn on the red spaceship LED

   procedure Turn_Off_LED;
   --  Turn off the red spaceship LED

   function Button_Pressed return Boolean;
   --  Return True if the button the left leg of MiniSAM is pressed

   procedure Set_RGB (Brightness : HAL.UInt5;
                      R, G, B    : HAL.UInt8);
   --  Control the "dotstar" RGB LED

   -- IOs --

   I2C_Port : SAM.SERCOM.I2C.I2C_Device renames SAM.Device.I2C2;
   SPI_Port : SAM.SERCOM.SPI.SPI_Device renames SAM.Device.SPI1;

   D0  : SAM.Port.GPIO_Point renames SAM.Device.PA16;
   D1  : SAM.Port.GPIO_Point renames SAM.Device.PA17;
   D2  : SAM.Port.GPIO_Point renames SAM.Device.PA07;
   D3  : SAM.Port.GPIO_Point renames SAM.Device.PA19;
   D4  : SAM.Port.GPIO_Point renames SAM.Device.PA20;
   D5  : SAM.Port.GPIO_Point renames SAM.Device.PA21;
   D9  : SAM.Port.GPIO_Point renames SAM.Device.PA02;
   D10 : SAM.Port.GPIO_Point renames SAM.Device.PB08;
   D11 : SAM.Port.GPIO_Point renames SAM.Device.PB09;
   D12 : SAM.Port.GPIO_Point renames SAM.Device.PA04;
   D13 : SAM.Port.GPIO_Point renames SAM.Device.PA05;
   D14 : SAM.Port.GPIO_Point renames SAM.Device.PA06;

   AREF : SAM.Port.GPIO_Point renames SAM.Device.PA03;
   A0   : SAM.Port.GPIO_Point renames D9;
   A1   : SAM.Port.GPIO_Point renames D10;
   A2   : SAM.Port.GPIO_Point renames D11;
   A3   : SAM.Port.GPIO_Point renames D12;
   A4   : SAM.Port.GPIO_Point renames D13;
   A5   : SAM.Port.GPIO_Point renames D14;
   A6   : SAM.Port.GPIO_Point renames D2;

   DAC1 : SAM.Port.GPIO_Point renames D9;
   DAC0 : SAM.Port.GPIO_Point renames D13;

   LED : SAM.Port.GPIO_Point renames SAM.Device.PA15;
   Button : SAM.Port.GPIO_Point renames SAM.Device.PA00;

   RX    : SAM.Port.GPIO_Point renames D0;
   TX    : SAM.Port.GPIO_Point renames D1;

private

   SWDIO : SAM.Port.GPIO_Point renames SAM.Device.PA30;
   SWCLK : SAM.Port.GPIO_Point renames SAM.Device.PA31;

   -- I2C --

   SCL   : SAM.Port.GPIO_Point renames SAM.Device.PA13;
   SDA   : SAM.Port.GPIO_Point renames SAM.Device.PA12;

   -- SPI --
   MOSI  : SAM.Port.GPIO_Point renames SAM.Device.PB22;
   MISO  : SAM.Port.GPIO_Point renames SAM.Device.PB23;
   SCK   : SAM.Port.GPIO_Point renames SAM.Device.PA01;

   QSPI_SCK : SAM.Port.GPIO_Point renames SAM.Device.PB10;
   QSPI_CS  : SAM.Port.GPIO_Point renames SAM.Device.PB11;
   QSPI_D0  : SAM.Port.GPIO_Point renames SAM.Device.PA08;
   QSPI_D1  : SAM.Port.GPIO_Point renames SAM.Device.PA09;
   QSPI_D2  : SAM.Port.GPIO_Point renames SAM.Device.PA10;
   QSPI_D3  : SAM.Port.GPIO_Point renames SAM.Device.PA11;

   DOTSTAR_CLK : SAM.Port.GPIO_Point renames SAM.Device.PB02;
   DOTSTAR_DATA : SAM.Port.GPIO_Point renames SAM.Device.PB03;

end Minisamd51;
