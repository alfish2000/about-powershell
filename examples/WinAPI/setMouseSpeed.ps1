param (
  [validateRange(1,20)]
  [int] $newSpeed
)

set-strictMode -version latest

# Toggle mouse speed between 10 and 20 when no parameter is given
if ($newSpeed -eq 0)
{
    $currentSpeed = (get-itemProperty 'hkcu:\Control Panel\Mouse').MouseSensitivity
    switch ( $currentSpeed )
    {
        10 { $newSpeed = 20 }
        20 { $newSpeed = 10 }
        default { $newSpeed = 10 }
    }
}

$winApi = add-type -name user32 -namespace tq84 -passThru -memberDefinition '
   [DllImport("user32.dll")]
    public static extern bool SystemParametersInfo(
       uint uiAction,
       uint uiParam ,
       uint pvParam ,
       uint fWinIni
    );
'

$SPI_SETMOUSESPEED = 0x0071

$null = $winApi::SystemParametersInfo($SPI_SETMOUSESPEED, 0, $newSpeed, 0)

#
#    Calling SystemParametersInfo() does not permanently store the modification
#    of the mouse speed. It needs to be changed in the registry as well
#

set-itemProperty 'hkcu:\Control Panel\Mouse' -name MouseSensitivity -value $newSpeed

"MouseSensitivity set to: $((get-itemProperty 'hkcu:\Control Panel\Mouse').MouseSensitivity)"
