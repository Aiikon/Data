Import-Module $PSScriptRoot\.. -DisableNameChecking -Force
Describe "Set-PropertyValue" {

    Context "Basic Checks" {
        It 'Ignores null input' {
            $result = $null | Set-PropertyValue B 2
            @($result).Count | Should Be 0
        }

        It 'Ignores empty input' {
            $result = @() | Set-PropertyValue B 2
            @($result).Count | Should Be 0
        }

        It 'Sets Property to Value' {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B 2 |
                ForEach-Object B |
                Should Be 2
        }

        It 'Clones' {
            $original = [pscustomobject]@{A=1}
            $new = $original | Set-PropertyValue B 2
            $new | Should Not Be $original
        }

        It 'Skips cloning with NoClone' {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B 2 -NoClone |
                ForEach-Object B |
                Should Be 2
        }

        It "Skips cloning with NoClone (Testing with -Value)" {
            $original = [pscustomobject]@{A=1}
            $new = $original | Set-PropertyValue B 2 -NoClone
            $new | Should Be $original
        }

        It "Executes a ScriptBlock" {
            [pscustomobject]@{A=3} |
                Set-PropertyValue B { $_.A * 2 } |
                ForEach-Object B |
                Should Be 6
        }
    }

    Context "IfUnset Tests" {

        It "-Property -Value -IfUnset (When Unset)" {
            [pscustomobject]@{A=$null} |
                Set-PropertyValue A 1 -IfUnset |
                ForEach-Object A |
                Should Be 1

            [pscustomobject]@{A=''} |
                Set-PropertyValue A 1 -IfUnset |
                ForEach-Object A |
                Should Be 1

            [pscustomobject]@{A=' '} |
                Set-PropertyValue A 1 -IfUnset |
                ForEach-Object A |
                Should Be 1
        }

        It "-Property -Value -IfUnset (When Set)" {
            [pscustomobject]@{A=3} |
                Set-PropertyValue A 1 -IfUnset |
                ForEach-Object A |
                Should Be 3

            [pscustomobject]@{A=0} |
                Set-PropertyValue A 1 -IfUnset |
                ForEach-Object A |
                Should Be 0
        }
    }

    Context "Where Tests" {

        It "Where Property is Truthy (Int 1)" {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B 2 -Where A |
                ForEach-Object B |
                Should Be 2
        }

        It "Where Property is Truthy (Int 0)" {
            [pscustomobject]@{A=0} |
                Set-PropertyValue B 2 -Where A |
                ForEach-Object B |
                Should Be $null
        }

        It "Where Property is Truthy (Empty String" {
            [pscustomobject]@{A=''} |
                Set-PropertyValue B 2 -Where A |
                ForEach-Object B |
                Should Be $null
        }

        It "Where Property is Truthy (Null Value)" {
            [pscustomobject]@{A=$null} |
                Set-PropertyValue B 2 -Where A |
                ForEach-Object B |
                Should Be $null
        }

        It "Where Property is Truthy (Whitespace)" {
            [pscustomobject]@{A=' '} |
                Set-PropertyValue B 2 -Where A |
                ForEach-Object B |
                Should Be 2
        }

        It "Where Property is Truthy (Confirming an old value isn't overwritten)" {
            [pscustomobject]@{A=$null; B='old'} |
                Set-PropertyValue B 2 -Where A |
                ForEach-Object B |
                Should Be 'old'
        }

        It "Where ScriptBlock (Result is Int 1)" {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B 2 -Where { $_.A } |
                ForEach-Object B |
                Should Be 2
        }

        It "Where ScriptBlock (Result is Int 0)" {
            [pscustomobject]@{A=0} |
                Set-PropertyValue B 2 -Where { $_.A } |
                ForEach-Object B |
                Should Be $null
        }
    }

    Context "Match Tests" {

        It "Where ScriptBlock contains Match; Match persists to Value ScriptBlock (Match is True)" {
            [pscustomobject]@{A="abc123def"} |
                Set-PropertyValue B { $Matches[1] } -Where { $_.A -match "(\d+)" } |
                ForEach-Object B |
                Should Be 123
        }

        It "Where ScriptBlock contains Match; Match persists to Value ScriptBlock (Match is False)" {
            [pscustomobject]@{A="abc123def"} |
                Set-PropertyValue B { $Matches[1] } -Where { $_.A -match "xyz" } |
                ForEach-Object B |
                Should Be $null
        }

        It "Where Match Value" {
            [pscustomobject]@{A="abc123def"} |
                Set-PropertyValue B { $Matches[1] } -Where A -Match "(\d+)" |
                ForEach-Object B |
                Should Be 123
        }

        It "Where Match Value (Ignore group)" {
            [pscustomobject]@{A="abc123def"} |
                Set-PropertyValue B { 'C' } -Where A -Match "(\d+)" |
                ForEach-Object B |
                Should Be C
        }

        It "Where Match Value (Group 0)" {
            [pscustomobject]@{A="abc123def"} |
                Set-PropertyValue B { $Matches[0] } -Where A -Match "(\d+)" |
                ForEach-Object B |
                Should Be 123
        }

        It "Where Match Value (Named Group)" {
            [pscustomobject]@{A="abc123def"} |
                Set-PropertyValue B { $Matches['myname'] } -Where A -Match "abc(?<myname>\d+)" |
                ForEach-Object B |
                Should Be 123
        }
    }

    Context "JoinWith Tests" {

        It "-JoinWith Single Value" {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B { 1 } -JoinWith '+' |
                ForEach-Object B |
                Should Be '1'
        }

        It "-JoinWith Multi Value" {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B { 1, 2, 3 } -JoinWith '+' |
                ForEach-Object B |
                Should Be '1+2+3'
        }

        It "-JoinWith Empty String" {
            [pscustomobject]@{A=1} |
                Set-PropertyValue B { 1, 2, 3 } -JoinWith '' |
                ForEach-Object B |
                Should Be '123'
        }
    }
}
