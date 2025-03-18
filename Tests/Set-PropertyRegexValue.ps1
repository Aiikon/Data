Import-Module $PSScriptRoot\.. -DisableNameChecking -Force
Describe "Set-PropertyRegexValue" {

    Context "Basic Checks" {
        It 'Ignores null input' {
            $result = $null | Set-PropertyRegexValue -From SourceProperty -Regex "Today is (?<date>[\d\-]+)"

            @($result).Count | Should Be 0
        }

        It 'Ignores empty input' {
            $result = @() | Set-PropertyRegexValue -From SourceProperty -Regex "Today is (?<date>[\d\-]+)"

            @($result).Count | Should Be 0
        }

        It 'Extracts one string' {
            $result = [pscustomobject]@{
                SourceProperty = "Today is 2024-01-01"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "Today is (?<Date>[\d\-]+)"

            @($result).Count | Should Be 1
            $result.Date | Should Be "2024-01-01"
        }

        It 'Extracts two strings' {
            $result = [pscustomobject]@{
                SourceProperty = "Today is 2024-01-01 and breakfast was eggs"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "Today is (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)"

            @($result).Count | Should Be 1
            $result.Date | Should Be "2024-01-01"
            $result.Food | Should Be "eggs"
        }

        It 'Extracts two objects with the same regex' {
            $result = [pscustomobject]@{
                SourceProperty = "Today is 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast was pancakes"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "Today is (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)"

            @($result).Count | Should Be 2
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "pancakes"
        }

        It 'Extracts two objects with the same regex' {
            $result = [pscustomobject]@{
                SourceProperty = "Today is 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast was pancakes"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "Today is (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)"

            @($result).Count | Should Be 2
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "pancakes"
        }

        It 'Extracts two objects with different regex' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be pancakes"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+) and breakfast will be (?<Food>\S+)"

            @($result).Count | Should Be 2
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Today"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "pancakes"
        }

        It 'Extracts two objects with different regex with manual GroupNames' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be pancakes"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(Yesterday) was ([\d\-]+) and breakfast was (\S+)", "(Today) is ([\d\-]+) and breakfast will be (\S+)" -GroupNames Word, Date, Food

            @($result).Count | Should Be 2
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Today"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "pancakes"
        }

        It 'Extracts two objects with different regex with KeepProperty' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be pancakes"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+) and breakfast will be (?<Food>\S+)" -KeepProperty Food, Date

            @($result).Count | Should Be 2
            $result[0].PSObject.Properties.Name -join '+' | Should Be 'SourceProperty+Food+Date'
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].PSObject.Properties.Name -join '+' | Should Be 'SourceProperty+Food+Date'
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "pancakes"
        }

        It 'Extracts two objects with different regex with one property missing' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be something"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+)"

            @($result).Count | Should Be 2
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Today"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be $null
        }

        It 'Extracts two objects with different regex with DefaultValues' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be something"
            },[pscustomobject]@{
                SourceProperty = "I don't know what to do"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+)" -DefaultValues @{Word='Unknown'; Food='TBD'} -ActionIfNotMatched UseDefaultValues

            @($result).Count | Should Be 3
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Today"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "TBD"
            $result[2].Word | Should Be 'Unknown'
            $result[2].Date | Should Be $null
            $result[2].Food | Should Be "TBD"
        }

        It 'Can skip errors with ActionIfNotMatched Ignore' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be something"
            },[pscustomobject]@{
                SourceProperty = "I don't know what to do"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+)" -DefaultValues @{Word='Unknown'; Food='TBD'} -ActionIfNotMatched Ignore

            @($result).Count | Should Be 3
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Today"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "TBD"
            $result[2].Word | Should Be $null
            $result[2].Date | Should Be $null
            $result[2].Food | Should Be $null
        }

        It 'Can use a wildcard in DefaultValues' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be something"
            },[pscustomobject]@{
                SourceProperty = "I don't know what to do"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+)" -DefaultValues @{"*"='-'; Food='TBD'} -ActionIfNotMatched UseDefaultValues

            @($result).Count | Should Be 3
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Today"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "TBD"
            $result[2].Word | Should Be '-'
            $result[2].Date | Should Be '-'
            $result[2].Food | Should Be "TBD"
        }

        It 'Can be told to Overwrite IfNullOrEmpty' {
            $result = [pscustomobject]@{
                SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
            },[pscustomobject]@{
                SourceProperty = "Today is 2024-01-02 and breakfast will be something"
                Word = "Test2"
            },[pscustomobject]@{
                SourceProperty = "I don't know what to do"
                Word = "Test3"
                Food = "candy"
            } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+)" -DefaultValues @{"*"='-'; Food='TBD'} -ActionIfNotMatched UseDefaultValues -Overwrite IfNullOrEmpty

            @($result).Count | Should Be 3
            $result[0].Word | Should Be "Yesterday"
            $result[0].Date | Should Be "2024-01-01"
            $result[0].Food | Should Be "eggs"
            $result[1].Word | Should Be "Test2"
            $result[1].Date | Should Be "2024-01-02"
            $result[1].Food | Should Be "TBD"
            $result[2].Word | Should Be 'Test3'
            $result[2].Date | Should Be '-'
            $result[2].Food | Should Be "candy"
        }

        It "Raises an error if a match isn't found" {
            try
            {
                $ex = $null
                [pscustomobject]@{
                    SourceProperty = "Yesterday was 2024-01-01 and breakfast was eggs"
                },[pscustomobject]@{
                    SourceProperty = "Today is 2024-01-02 and breakfast will be something"
                },[pscustomobject]@{
                    SourceProperty = "I don't know what to do"
                } | Set-PropertyRegexValue -From SourceProperty -Regex "(?<Word>Yesterday) was (?<Date>[\d\-]+) and breakfast was (?<Food>\S+)", "(?<Word>Today) is (?<Date>[\d\-]+)" -ErrorAction Stop
            }
            catch
            {
                $ex = $_.Exception.Message
            }
            
            $ex | Should Be 'No regex matches found for object.'
        }
    }
}
