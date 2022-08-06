Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-PropertyMultiValue" {

    Context "Odd input tests" {

        It 'Ignores empty input' {
            $result = @() |
                Join-PropertyMultiValue @{A=1}
            @($result).Count | Should Be 0
        }

        It 'Ignores null input' {
            $result = @() |
                Join-PropertyMultiValue @{A=1}
            @($result).Count | Should Be 0
        }

        It "Still passes the object if there's no scriptblock" {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { }

            @($result).Count | Should Be 1
            $result.PSObject.Properties.Name -join "|" | Should Be "A"
        }

        It "Still passes the object if the hashtable is empty" {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue @{}

            @($result).Count | Should Be 1
            $result.PSObject.Properties.Name -join "|" | Should Be "A"
        }
    }

    Context "Single result tests" {

        It 'Sets properties from Hashtable' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue @{B=2;C=3}

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from Ordered Dictionary' {

            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue ([ordered]@{B=2;C=3})

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from ScriptBlock object' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { [pscustomobject]@{B=2;C=3} }

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from ScriptBlock hashtable' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { @{B=2;C=3} }

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from ScriptBlock ordered dictionaries' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { [ordered]@{B=2;C=3} }

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from child property object' {
            $result = [pscustomobject]@{A=1;Z=[pscustomobject]@{B=2;C=3}} |
                Join-PropertyMultiValue Z

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from child property hashtable' {
            $result = [pscustomobject]@{A=1;Z=@{B=2;C=3}} |
                Join-PropertyMultiValue Z

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }

        It 'Sets properties from child property ordered dictionary' {
            $result = [pscustomobject]@{A=1;Z=[ordered]@{B=2;C=3}} |
                Join-PropertyMultiValue Z

            $result.A | Should Be 1
            $result.B | Should Be 2
            $result.C | Should Be 3
        }
    }

    Context "Multiple result tests" {

        It 'Returns multiple objects from scriptblock pscustomobject' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { [pscustomobject]@{B=2}; [pscustomobject]@{B=-2} }
            $result[0].A | Should Be 1
            $result[0].B | Should Be 2

            $result[1].A | Should Be 1
            $result[1].B | Should Be -2
        }

        It 'Returns multiple objects from scriptblock hashtables' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { @{B=2}; @{B=-2} }
            $result[0].A | Should Be 1
            $result[0].B | Should Be 2

            $result[1].A | Should Be 1
            $result[1].B | Should Be -2
        }

        It 'Returns multiple objects from child property objects' {
            $result = [pscustomobject]@{
                    A = 1
                    Z = [pscustomobject]@{B=2}, [pscustomobject]@{B=-2}
                } |
                Join-PropertyMultiValue Z
            $result[0].A | Should Be 1
            $result[0].B | Should Be 2

            $result[1].A | Should Be 1
            $result[1].B | Should Be -2
        }
    }

    Context "KeepProperty Tests" {

        It 'Adds empty properties with KeepProperty' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { } -KeepProperty B, C
            $result.PSObject.Properties.Name -join "|" | Should Be "A|B|C"
            $result.B | Should Be $null
        }

        It 'Filters out extra properties from hashtables' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue @{B=2;C=3} -KeepProperty C
            $result.PSObject.Properties.Name -join "|" | Should Be "A|C"
        }

        It 'Filters out extra properties from scriptblocks' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { @{B=2;C=3} } -KeepProperty C
            $result.PSObject.Properties.Name -join "|" | Should Be "A|C"
        }

        It 'Filters out extra properties from child objects' {
            $result = [pscustomobject]@{A=1;Z=[pscustomobject]@{B=2;C=3}} |
                Join-PropertyMultiValue Z -KeepProperty C
            $result.PSObject.Properties.Name -join "|" | Should Be "A|Z|C"
        }
    }

    Context "KeepInputProperty tests" {

        It 'Only passes specific input properties with hashtables' {
            $result = [pscustomobject]@{A=1; B=-2} |
                Join-PropertyMultiValue @{C=3} -KeepInputProperty B
            $result.PSObject.Properties.Name -join "|" | Should Be "B|C"
            $result.B | Should Be -2
            $result.C | Should Be 3
        }

        It 'Only passes specific input properties with script blocks' {
            $result = [pscustomobject]@{A=1; B=-2} |
                Join-PropertyMultiValue { [pscustomobject]@{C=3} } -KeepInputProperty B
            $result.PSObject.Properties.Name -join "|" | Should Be "B|C"
            $result.B | Should Be -2
            $result.C | Should Be 3
        }
    }

    Context "ExcludeProperty Tests" {

        It 'Excludes properties from hashtables' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue @{B=2;C=3} -ExcludeProperty A, C
            $result.PSObject.Properties.Name -join "|" | Should Be "B"
            $result.B | Should Be 2
        }

        It 'Excludes properties from scriptblocks' {
            $result = [pscustomobject]@{A=1} |
                Join-PropertyMultiValue { @{B=2;C=3} } -ExcludeProperty A, C
            $result.PSObject.Properties.Name -join "|" | Should Be "B"
            $result.B | Should Be 2
        }
    }

    Context "NoEmptyResults" {
        
        It "Filters objects that don't have results" {
            $resultList = [pscustomobject]@{A=1}, [pscustomobject]@{A=2}, [pscustomobject]@{A=3} |
                Join-PropertyMultiValue -NoEmptyResults {
                    if ($_.A -eq 1) { @{V='A'} }
                    elseif ($_.A -eq 2) { }
                    elseif ($_.A -eq 3) { @{V='B'}, @{V='C'} }
                }

            @($resultList).Count | Should Be 3

            $resultList[0].A | Should Be 1
            $resultList[0].V | Should Be A

            $resultList[1].A | Should Be 3
            $resultList[1].V | Should Be B

            $resultList[2].A | Should Be 3
            $resultList[2].V | Should Be C
        }

        It "Can't filter empty results if Values is a dictionary." {
            $exception = try
            {
                [pscustomobject]@{A=1} |
                    Join-PropertyMultiValue -NoEmptyResults -Values @{B=1} |
                    Out-Null
            } catch { $_ }

            $exception | Should Match "NoEmptyResults can't be provided when Values is a dictionary"
        }
    }

    Context "`$this Tests" {
         It 'Implemented' {
            $result = [pscustomobject]@{A=1; B=2} |
                Join-PropertyMultiValue {
                    $this.B = 3
                    $this.C = 4
                }

            $result.A | Should Be 1
            $result.B | Should Be 3
            $result.C | Should Be 4
         }
    }
}
