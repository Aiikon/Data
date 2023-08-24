Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Set-PropertyTotalValue" {

    Context 'Default' {

        It 'Can add a TotalProperty property to all records' {
            $inputList = @(
                [pscustomobject]@{A=1;B=1;CountA=1;CountB=8}
                [pscustomobject]@{A=1;B=2;CountA=2;CountB=16}
                [pscustomobject]@{A=2;B=3;CountA=4;CountB=32}
            )

            $result = $inputList |
                Set-PropertyTotalValue CountA, CountB -TotalProperty CountAB

            $result[0].CountAB | Should Be 9
            $result[1].CountAB | Should Be 18
            $result[2].CountAB | Should Be 36
        }

    }
}
