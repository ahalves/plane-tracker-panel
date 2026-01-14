# plane-tracker-panel
An ADS-B receiver with a 128x64 HUB75 dot matrix display to track planes above you and displays other info.

---
I wanted to make a showpiece to keep in my room, so as an avgeek, this idea was perfect in my opinion.

This has a built in ADS-B receiver, so that you don't need to be reliant on external services. In fact, you can feed into the Flightradar24 network for a free business level account!

Instead of a traditional MCU or SBC, this uses a HP T520 Thin Client PC. It's ridiculously cheap even compared to many other MCUs, and you can run whatever OS you want on it. This connects to the FPGA, which then connects to the display.

## FPGA

I made my own iCE40UP5K FPGA to drive the HUB75 
Why make my own? for a challenge of course! The display needs a high refresh rate (multiple frames in 1/60s for just 60Hz assuming you want more than 3 bit color) and accurate clock timing, which is just more appropriate for an FPGA over a standard microcontroller.

<img width="708" height="602" alt="image" src="https://github.com/user-attachments/assets/d30e8a88-306d-4d09-9da5-4c529a0ea69e" />

A FTDI chip (FT2232H) is used for USB communication, both flashing and UART.

Channel A handles SPI flash programming whereas Channel B handles communication over UART. UART lines are directly connected to the pin headers labelled appropriately (from the perspective of the iCE40), then connected to the iCE40 pins.

This must be properly configured in the FT_PROG software (found [here](https://ftdichip.com/utilities/)) on first boot.

<img width="1675" height="1190" alt="SCH_Schematic1_1-P1_2025-12-07" src="https://github.com/user-attachments/assets/a14575b8-c83d-463d-b9fb-e81b90b7e650" />

## Wiring diagram

<img width="621" height="241" alt="image" src="https://github.com/user-attachments/assets/d476fb01-1611-4302-8467-accf653ff023" />

GPIOs depend on your FPGA configuration when you program.

## Enclosure
<img width="591" height="404" alt="image" src="https://github.com/user-attachments/assets/9b96981a-608c-40d4-88b5-744f22595921" />

I've essentially decided to make a 275x247x147 enclosure out of MDF, as can be more obviously seen in the below image. Holes can be drilled for cables and airflow where needed.

Required 9mm MDF sheet sizes:
- 247x275mm x2
- 129x257mm x3 (2 cut down by 10mm crosswise)
- 76x129mm x1 (width can be variable. Instead of ordering a sheet of this size, it ends up being cheaper getting one more of the above.)

<img width="786" height="564" alt="image" src="https://github.com/user-attachments/assets/637df748-d466-4302-b4df-2caaf286976e" />

The box gets glued together with PVA glue as above. The T520 is secured flat, with the square face on the bottom, IO facing inwards for the SDR to fit in the space.

[picture of build here for clarity when done]

## BOM

> [!NOTE]
> For PCB parts, see BOM.csv; it is uploadable to LCSC to get the most up to date info on the parts.

|Item|Qty|Link|Price|Shipping|Total|
|---|---|---|---|---|---|
|HP T520 Thin Client|1|https://www.ebay.co.uk/itm/357569483200|26.70|free|26.70|
|19.5V Laptop Charger|1|https://www.ebay.co.uk/itm/196839302164|9.00|free|9.00|
|24k resistor|1|https://www.aliexpress.com/item/1005007345052730.html|0.93|1.99|2.92|
|270k resistor|1|https://www.aliexpress.com/item/1005007345052730.html|0.95|above|0.95|
|5V 5A Power Supply|1|https://www.aliexpress.com/item/1005005763465796.html|5.39|free|5.39|
|SDR|1|https://www.aliexpress.com/item/1005005278826467.html|15.59|free|15.59|
|HUB75|1|https://www.aliexpress.com/item/1005001958308355.html|25.69|free|25.69|
|247x275x9mm MDF|2|https://www.woodsheets.com/mdf-sheet-cut-to-size/?plastic-group=MDF&plastic-type=Standard%20MDF&product-type=Sheet&thickness=9mm&measurement=mm&length=275&width=247|5.67+VAT|4.95|17.62|
|129x257x9mm MDF|4|https://www.woodsheets.com/mdf-sheet-cut-to-size/?plastic-group=MDF&plastic-type=Standard%20MDF&product-type=Sheet&thickness=9mm&measurement=mm&length=257&width=129|5.00+VAT|above|total above|
|PCBs|MOQ (5)|JLCPCB|$6.90|$1.50|$8.40|
|PCB components|MOQ|LCSC|$34.17 (-$5.23 discount)|$6.85|$35.79|

**Total:** £100.39 + $44.19 = **$179.06** as of 27 Dec 2025

