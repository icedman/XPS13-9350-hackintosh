// SSDT-UIAC.dsl
//
// This SSDT demonstrates a custom configuration for USBInjectAll.kext.
//

DefinitionBlock ("", "SSDT", 2, "hack", "UIAC", 0)
{
    Device(UIAC)
    {
        Name(_HID, "UIA00000")

        // override EH01 configuration to have only one port
        Name(RMCF, Package()
        {
            "XHC", Package()
            {
                "port-count", Buffer() { 0x0e, 0, 0, 0 },
                "ports", Package()
                {
                    "HS01", Package()
                    {
                        "UsbConnector", 0,
                        "port", Buffer() { 0x01, 0, 0, 0 },
                    },
                    "HS02", Package()
                    {
                        "UsbConnector", 0,
                        "port", Buffer() { 0x02, 0, 0, 0 },
                    },
                    "HS03", Package()
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x03, 0, 0, 0 },
                    },
                    "HS04", Package()
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x04, 0, 0, 0 },
                    },
                    "HS05", Package()
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 0x05, 0, 0, 0 },
                    },
                    "SS01", Package()
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x0d, 0, 0, 0 },
                    },
                    "SS02", Package()
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 0x0e, 0, 0, 0 },
                    }
                }
            }
        })
    }
}

//EOF