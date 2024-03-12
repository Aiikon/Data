Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Group-CommonSetValues" {
    Context "Basic Tests" {
        It "Empty test" {
            $result1 = @() | Group-CommonSetValues Series
            @($result1).Count | Should Be 0

            $result2 = $null | Group-CommonSetValues Series
            @($result2).Count | Should Be 0
        }

        It "Can group A, B" {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 2
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A'
            ($result[0].Group.Key | Sort-Object) -join '+' | Should Be '0'
            ($result[1].Keys | Sort-Object) -join '+' | Should Be 'B'
            ($result[1].Group.Key | Sort-Object) -join '+' | Should Be '1'
        }

        It "Can group A, B, A+B" {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B'
                2 = 'A', 'B'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A+B'
            ($result[0].Group.Key | Sort-Object) -join '+' | Should Be '0+1+2'
        }

        It "Can use -SplitOn" {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B'
                2 = 'A, B'
            }).GetEnumerator() |
                Group-CommonSetValues Value -SplitOn ', *'

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A+B'
            ($result[0].Group.Key | Sort-Object) -join '+' | Should Be '0+1+2'
        }

        It "Can group A, A+B, B" {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'A', 'B'
                2 = 'B'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A+B'
            ($result[0].Group.Key  | Sort-Object)-join '+' | Should Be '0+1+2'
        }

        It "Can group A, B+A, B" {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B', 'A'
                2 = 'B'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A+B'
            ($result[0].Group.Key | Sort-Object) -join '+' | Should Be '0+1+2'
        }

        It "Can group A, B, C, A+B, C+B" {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B'
                2 = 'C'
                3 = 'A', 'B'
                4 = 'C', 'B'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A+B+C'
            ($result[0].Group.Key | Sort-Object) -join '+' | Should Be '0+1+2+3+4'
        }

        It 'Can group A, B, C, D, A+B, C+D, B+C' {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B'
                2 = 'C'
                3 = 'D'
                4 = 'A', 'B'
                5 = 'C', 'D'
                6 = 'B', 'C'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '+' | Should Be 'A+B+C+D'
            ($result[0].Group.Key | Sort-Object) -join '+' | Should Be '0+1+2+3+4+5+6'
        }

        It 'Can group A, B, C, D, E, F, G, H, A+B, C+D, E+F, G+H, H+A' {
            $result = ([ordered]@{
                0 = 'A'
                1 = 'B'
                2 = 'C'
                3 = 'D'
                4 = 'E'
                5 = 'F'
                6 = 'G'
                7 = 'H'
                8 = 'A', 'B'
                9 = 'C', 'D'
                10 = 'E', 'F'
                11 = 'G', 'H'
                12 = 'B', 'C'
                13 = 'E', 'H'
                14 = 'A', 'E'
            }).GetEnumerator() |
                Group-CommonSetValues Value

            @($result).Count | Should Be 1
            ($result[0].Keys | Sort-Object) -join '' | Should Be 'ABCDEFGH'
        }
    }
}
