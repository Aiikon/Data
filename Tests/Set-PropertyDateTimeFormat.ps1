Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

# This has to go outside the tests because Pester won't allow ANY error records to show up
$errorResult = [pscustomobject]@{A=[DateTime]::Today; B=$null; C=[DateTime]::Today.AddDays(-1); D='Nothing'} |
    Set-PropertyDateTimeFormat A, B, C, D 'yyyy-MM-dd tt' -ErrorAction SilentlyContinue

Describe "Set-PropertyDateTimeFormat" {

    $time1 = [pscustomobject]@{A=[datetime]"3/4/2019 11:55:45.123 PM"; B=[Datetime]"4/5/2019 4:30:15 AM"}

    Context 'Default' {
        It 'Passes nothing with null input' {
            $out = $null | Set-PropertyDateTimeFormat Nothing 'yyyy-MM-dd HH:mm:ss'
            $out.Count | Should Be 0
        }

        It 'Works' {
            $timestamp = [DateTime]::Now
            $result = [pscustomobject]@{A=1;Timestamp=$timestamp} |
                Set-PropertyDateTimeFormat Timestamp 'yyyy-MM-dd HH:mm:ss dddd h tt'

            $result.A | Should Be 1
            $result.Timestamp | Should Be ($timestamp.ToString('yyyy-MM-dd HH:mm:ss dddd h tt'))
        }

        It 'Works with AppendTimeZone Short' {
            [pscustomobject]@{Date="1/1/2020"} |
                Set-PropertyDateTimeFormat Date yyyy-MM-dd -AppendTimeZone Short
        }

        It 'Works with AppendTimeZone Long' {
            [pscustomobject]@{Date="1/1/2020"} |
                Set-PropertyDateTimeFormat Date yyyy-MM-dd -AppendTimeZone Long
        }

        It 'Works with AppendFuzzyTimestamp Default' {
            $timestamp = [DateTime]::Now.AddMinutes(15)
            $result = [pscustomobject]@{A=1;Timestamp=$timestamp} |
                Set-PropertyDateTimeFormat Timestamp 'yyyy-MM-dd HH:mm:ss dddd h tt' -AppendFuzzyTimestamp Default

            $result.A | Should Be 1
            $result.Timestamp | Should Be "$($timestamp.ToString('yyyy-MM-dd HH:mm:ss dddd h tt')) (15 minutes from now)"
        }

        It 'Ignores Null' {
            [pscustomobject]@{A=$null} |
                Set-PropertyDateTimeFormat A 'yyyy-MM-dd' |
                ForEach-Object A |
                Should Be $null
        }

        It 'Ignores Empty String' {
            [pscustomobject]@{A=''} |
                Set-PropertyDateTimeFormat A 'yyyy-MM-dd' |
                ForEach-Object A |
                Should Be ''
        }

        It 'Handles errors' {
            $errorResult.A | Should Be ([DateTime]::Today.ToString('yyyy-MM-dd tt'))
            $errorResult.B | Should Be $null
            $errorResult.C | Should Be ([DateTime]::Today.AddDays(-1).ToString('yyyy-MM-dd tt'))
            $errorResult.D | Should Be $null
        }
    }
}
