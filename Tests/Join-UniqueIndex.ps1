Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-UniqueIndex" {

    Context 'Default' {

        It 'Works' {
            $list = "
            Label,Field1,Field2
            A,One,1
            B,One,1
            C,One,2
            D,One,1
            E,Two,1
            " -replace ' ' | ForEach-Object Trim | ConvertFrom-Csv

            $results = $list | Join-UniqueIndex -Property Field1, Field2 -IndexProperty UniqueIndex -StartAt 1
            $results[0].UniqueIndex | Should Be 1
            $results[1].UniqueIndex | Should Be 1
            $results[2].UniqueIndex | Should Be 2
            $results[3].UniqueIndex | Should Be 1
            $results[4].UniqueIndex | Should Be 3
        }

        It "Can override starting indices" {
            $results = @(
                [pscustomobject]@{A=0}
                [pscustomobject]@{A=1}
                [pscustomobject]@{A=2}
                [pscustomobject]@{A=3}
            ) | Join-UniqueIndex A -StartingValues 2, 1

            $results[0].UniqueIndex | Should Be 2
            $results[1].UniqueIndex | Should Be 1
            $results[2].UniqueIndex | Should Be 0
            $results[3].UniqueIndex | Should Be 3
        }
    }
}
