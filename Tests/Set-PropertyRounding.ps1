Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Set-PropertyRounding" {

    Context 'Default' {
        It 'Works' {
            $result = [pscustomobject]@{A=1.5; B=1.2345} |
                Set-PropertyRounding A, B -Digits 1

            $result.A | Should Be 1.5
            $result.B | Should Be 1.2
        }

        It 'Works with DivideBy' {
            $result = [pscustomobject]@{A=2.234MB} |
                Set-PropertyRounding A -Digits 2 -DivideBy (1024*1024)

            $result.A | Should Be 2.23
        }
    }
}
