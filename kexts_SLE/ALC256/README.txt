Codec: Realtek ALC3246
Address: 0
AFG Function Id: 0x1 (unsol 1)
Vendor Id: 0x10ec0256
Subsystem Id: 0x10280704
Revision Id: 0x100002

Realtek ALC256 for Dell XPS 9350

You must change the Layout to 13  in the DSDT patch HDEF.

Kext Patched by Insanelydeepak 

 Layout_ID/Audio ID description :
. Layout_ID 11 = ​​3 ports supported (Pink, Green, Blue) (Note : without auto-switch , you have to manually select between output/input device's)
. Layout_ID 12 = 5/6 ports supported (Grey, Black, Laranja, Pink, Green, Blue) 
. Layout_ID 13 = 5/6 ports supported (Grey, Black, Laranja, Pink, Green, Blue, CodecAddress: 2)

. Default is Layout_ID: 13.


Method (_DSM, 4, NotSerialized)
                {
                    Store (Package (0x0c)
                    {                        
                        "built-in", 
                        Buffer (One)
                        {
                            0x00
                        }, 
                        "layout-id", 
                        Buffer (0x04)
                        {
                            0x0D, 0x00, 0x00, 0x00 //change Your Layout_Id Here
                        }, 
                       "PinConfigurations", 
                       Buffer (0x00)
                       {
                           0x00
                       }
                    }, Local0)
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }