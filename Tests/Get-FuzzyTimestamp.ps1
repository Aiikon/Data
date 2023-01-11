Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Get-IndentedText" {
    Context "Basic Tests" {
        It "0 Minutes" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddSeconds(-30)) | Should Be "less than a minute ago"
        }

        It "1 Minute" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddSeconds(-90)) | Should Be "a minute ago"
        }

        It "15 Minutes" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddMinutes(-15)) | Should Be "15 minutes ago"
        }

        It "60 Minutes" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddMinutes(-60)) | Should Be "about 1 hour ago"
        }

        It "3 Hours" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddHours(-3)) | Should Be "about 3 hours ago"
        }

        It "1 Day" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddHours(-24)) | Should Be "1 day ago"
            Get-FuzzyTimestamp ([DateTime]::Now.AddHours(-25)) | Should Be "1 day ago"
        }

        It "5 Days" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddDays(-5)) | Should Be "5 days ago"
        }

        It "1 Month" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddDays(-30)) | Should Be "about 1 month ago"
            Get-FuzzyTimestamp ([DateTime]::Now.AddDays(-35)) | Should Be "about 1 month ago"
        }

        It "6 Months" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddMonths(-6)) | Should Be "6 months ago"
        }

        It "1 Year" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddMonths(-13)) | Should Be "about 1 year ago"
        }

        It "2 Years" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddYears(-2)) | Should Be "2 years ago"
        }

        It "20 Years" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddYears(-20)) | Should Be "20 years ago"
        }

        It "15 minutes in the future" {
            Get-FuzzyTimestamp ([DateTime]::Now.AddMinutes(15)) | Should Be "15 minutes from now"
        }

        It "15 minutes ago (utc)" {
            Get-FuzzyTimestamp ([DateTime]::UtcNow.AddMinutes(15)) -Utc | Should Be "15 minutes from now"
        }
    }
}
