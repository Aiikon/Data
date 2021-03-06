﻿foreach ($value in $true, $false)
{
    $Global:191cf922f94e46709f6b1818ae32f66b_ForceLoadPowerShellCmdlets = $value
    Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

    Describe "Rename-Property" {

        Context "Default - PowerShell: $value" {
            It 'Test -From -To' {
                $single = [pscustomobject][ordered]@{A=1;B=2}
                $new = $single | Rename-Property -From B -To C
                $new.PSObject.Properties.Name -join '' | Should Be AC
                $new.A | Should Be 1
                $new.C | Should Be 2
                $new | Should Not Be $single
            }

            It 'Test Positionally' {
                $single = [pscustomobject][ordered]@{A=1;B=2}
                $new = $single | Rename-Property B C
                $new.PSObject.Properties.Name -join '' | Should Be AC
                $new.A | Should Be 1
                $new.C | Should Be 2
                $new | Should Not Be $single
            }

            It 'Test Multiple' {
                $single = [pscustomobject][ordered]@{A=1;B=2;C=3;D=4}
                $new = $single | Rename-Property A AA C CC + D DDD
                $new.PSObject.Properties.Name -join '' | Should Be AABCCDDD
                $new.AA | Should Be 1
                $new.B | Should Be 2
                $new.CC | Should Be 3
                $new.DDD | Should Be 4
            }
        }
    }
}