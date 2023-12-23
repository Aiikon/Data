Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-GroupHeaderRow" {

    Context 'Default' {
        It 'Handles empty input' {
            $result = @() | Join-GroupHeaderRow -Property A { }
            @($result).Count | Should Be 0
        }

        It 'Handles null input' {
            $result = $null | Join-GroupHeaderRow -Property A { }
            @($result).Count | Should Be 0
        }

        It 'Produces a basic header' {
            $inputList = @(
                [pscustomobject]@{A=1;B=1;Count=2}
                [pscustomobject]@{A=1;B=2;Count=3}
                [pscustomobject]@{A=2;B=3;Count=4}
            )

            $result = $inputList |
                Join-GroupHeaderRow -Property A -ObjectScript { @{B='Total'} } -Subtotal Count

            @($result).Count | Should Be 5

            $result[0].A | Should Be 1
            $result[0].B | Should Be 'Total'
            $result[0].Count | Should Be 5

            $result[1] | Should Be $inputList[0]
            $result[2] | Should Be $inputList[1]   

            $result[3].A | Should Be 2
            $result[3].B | Should Be 'Total'
            $result[3].Count | Should Be 4

            $result[4] | Should Be $inputList[2]
        }

        It 'Produces a footer' {
            $inputList = @(
                [pscustomobject]@{A=1;B=1;Count=2}
                [pscustomobject]@{A=1;B=2;Count=3}
                [pscustomobject]@{A=2;B=3;Count=4}
            )

            $result = $inputList |
                Join-GroupHeaderRow -Property A -ObjectScript { @{B='Total'} } -Subtotal Count -AsFooter

            @($result).Count | Should Be 5

            $result[0] | Should Be $inputList[0]
            $result[1] | Should Be $inputList[1]   

            $result[2].A | Should Be 1
            $result[2].B | Should Be 'Total'
            $result[2].Count | Should Be 5

            $result[3] | Should Be $inputList[2]

            $result[4].A | Should Be 2
            $result[4].B | Should Be 'Total'
            $result[4].Count | Should Be 4
        }

        It 'Works with custom objects' {
            $inputList = @(
                [pscustomobject]@{A=1;B=1;Count=2}
                [pscustomobject]@{A=1;B=2;Count=3}
            )

            $result = $inputList |
                Join-GroupHeaderRow -Property A -ObjectScript { [pscustomobject]@{B='Total'} } -Subtotal Count -AsFooter

            @($result).Count | Should Be 3

            $result[0] | Should Be $inputList[0]
            $result[1] | Should Be $inputList[1]   

            $result[2].A | Should Be 1
            $result[2].B | Should Be 'Total'
            $result[2].Count | Should Be 5
        }

        It 'Works with -KeepFirst' {
            $result = @(
                [pscustomobject]@{A=1;B=1;Count=2;Category='One'}
                [pscustomobject]@{A=1;B=2;Count=3;Category='One'}
            ) |
                Join-GroupHeaderRow A -KeepFirst Category

            $result[0].Category | Should Be 'One'
        }

        It 'Works with -Set' {
            $result = @(
                [pscustomobject]@{A=1;B=1;Count=2;Type='Record'}
                [pscustomobject]@{A=1;B=2;Count=3;Type='Record'}
            ) |
                Join-GroupHeaderRow A -Subtotal Count -Set @{Type='Record'}

            $result[0].PSObject.Properties.Name -join '|' | Should Be "A|B|Count|Type"
            $result[0].Count | Should Be 5
            $result[0].Type | Should Be 'Record'
        }

        It 'ObjectScript has access to $input variable' {
            $result = @(
                [pscustomobject]@{A=1;B=1;Count=2}
                [pscustomobject]@{A=1;B=2;Count=3}
            ) |
                Join-GroupHeaderRow A -Set @{B='Average'} -ObjectScript {
                    @{
                        Count = $input |
                            Measure-Object -Average Count |
                            ForEach-Object Average
                    }
                }

            $result[0].B | Should Be 'Average'
            $result[0].Count | Should Be 2.5
        }

        It 'Works with -SkipSingles' {
            $inputList = @(
                [pscustomobject]@{A=1;B=1;Count=2}
                [pscustomobject]@{A=1;B=2;Count=3}
                [pscustomobject]@{A=2;B=3;Count=4}
            )

            $result = $inputList |
                Join-GroupHeaderRow -Property A -Set @{B='Total'} -SkipSingles

            @($result).Count | Should Be 4

            $result[0].A | Should Be 1
            $result[0].B | Should Be 'Total'

            $result[1] | Should Be $inputList[0]
            $result[2] | Should Be $inputList[1]   
            $result[3] | Should Be $inputList[2]
        }

        It 'Works with no Property' {
            $inputList = @(
                [pscustomobject]@{A=1;B=1;Count=2}
                [pscustomobject]@{A=1;B=2;Count=3}
                [pscustomobject]@{A=2;B=3;Count=4}
            )

            $result = $inputList |
                Join-GroupHeaderRow -Set @{A='Total'} -Subtotal Count -AsFooter

            $result[0] | Should Be $inputList[0]
            $result[1] | Should Be $inputList[1]   
            $result[2] | Should Be $inputList[2]

            $result[3].A | Should Be Total
            $result[3].Count | Should Be 9
        }
    }
}
