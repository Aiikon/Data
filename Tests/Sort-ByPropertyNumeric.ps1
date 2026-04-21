Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Sort-ByPropertyNumeric" {

    Context 'Default' {
        It 'Sorts automatically without defaults' {
            $sortedList = 'dev11', 'dev1', 'dev2', 'preprod', 'alpha' |
                ForEach-Object { [pscustomobject]@{Value=$_} } |
                Sort-ByPropertyNumeric Value
            $sortedList.Value -join '+' | Should Be 'alpha+dev1+dev2+dev11+preprod'
        }
    }
}
