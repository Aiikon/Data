Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Select-Including" {

    Context 'Default' {

        It 'Filters' {
            $result = @(
                [pscustomobject]@{PropA=1}
                [pscustomobject]@{PropA=2}
            ) |
                Select-Including PropA @([pscustomobject]@{PropA=1}) PropA

            @($result).Count | Should Be 1
            $result.PropA | Should Be 1
        }

        It 'Filters with InputKeys if CompareKeys not set' {
            $result = @(
                [pscustomobject]@{PropA=1}
                [pscustomobject]@{PropA=2}
            ) |
                Select-Including PropA @([pscustomobject]@{PropA=1})

            @($result).Count | Should Be 1
            $result.PropA | Should Be 1
        }

        It "Edge case when comparing null and empty objects" {
            # TBD if this behavior needs to be reversed; right now if ($false) { }
            # results in a non-null value that is skipped in the $(foreach ($key) { })
            # loop. If this is to change it needs to change everywhere.
            $result = [pscustomobject]@{PropA=1; PropB=if ($false) { 2 }} |
                Select-Including PropA, PropB ([pscustomobject]@{PropA=1; PropB=$null})

            @($result).Count | Should Be 0
        }
    }
}
