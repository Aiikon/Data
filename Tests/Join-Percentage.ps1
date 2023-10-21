Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-UniqueIndex" {

    Context 'Default' {

        It 'Works' {
            $list = "
            Label,Field1,Count
            A,One,1
            B,One,3
            C,One,6
            " -replace ' ' | ForEach-Object Trim | ConvertFrom-Csv

            $results = @(
                [pscustomobject]@{Label='A';Count=1}
                [pscustomobject]@{Label='A';Count=3}
                [pscustomobject]@{Label='A';Count=6}
            ) | Join-Percentage

            $results[0].Percentage | Should Be '10%'
            $results[1].Percentage | Should Be '30%'
            $results[2].Percentage | Should Be '60%'
        }

        It "Can use AsDouble" {
            $results = @(
                [pscustomobject]@{Label='A';Count=1}
                [pscustomobject]@{Label='A';Count=3}
                [pscustomobject]@{Label='A';Count=46}
            ) | Join-Percentage -AsDouble -DecimalPlaces 2

            $results[0].Percentage | Should Be 0.02
            $results[1].Percentage | Should Be 0.06
            $results[2].Percentage | Should Be 0.92
        }
    }
}
