Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-Index" {

    Context 'Default' {

        It "Adds Index to objects" {
            $results = @(
                [pscustomobject]@{Key='A'; Value=1}
                [pscustomobject]@{Key='A'; Value=2}
                [pscustomobject]@{Key='B'; Value=3}
            ) | Join-Index

            @($results).Count | Should Be 3
            $results[0].Index | Should Be 0
            $results[1].Index | Should Be 1
            $results[2].Index | Should Be 2
        }

        It "Does not error on empty sets" {
            $results = @() | Join-Index
            @($results).Count | Should Be 0
        }

        It "Can change the starting index and property name" {
            $results = @(
                [pscustomobject]@{Key='A'; Value=1}
                [pscustomobject]@{Key='A'; Value=2}
                [pscustomobject]@{Key='B'; Value=3}
            ) | Join-Index -Start 1 -IndexProperty Location

            @($results).Count | Should Be 3
            $results[0].Location | Should Be 1
            $results[1].Location | Should Be 2
            $results[2].Location | Should Be 3
        }

        It "Can index by key values" {
            $results = @(
                [pscustomobject]@{Key='A'; Value=1}
                [pscustomobject]@{Key='A'; Value=2}
                [pscustomobject]@{Key='B'; Value=3}
                [pscustomobject]@{Key='C'; Value=4}
                [pscustomobject]@{Key='B'; Value=5}
                [pscustomobject]@{Key='A'; Value=5}
            ) | Join-Index -KeyProperty Key

            @($results).Count | Should Be 6
            $results[0].Index | Should Be 0
            $results[1].Index | Should Be 1
            $results[2].Index | Should Be 0
            $results[3].Index | Should Be 0
            $results[4].Index | Should Be 1
            $results[5].Index | Should Be 2
        }
    }
}
