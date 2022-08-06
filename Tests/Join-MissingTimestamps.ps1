Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-MissingTimestamps" {

    Context 'Range Generator' {
        It 'Generates a date range' {
            $result = Join-MissingTimestamps Date -Days 1 -From "1/1/2022" -To "1/10/2022"
            @($result).Count | Should Be 10
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[1].Date | Should Be ([datetime]"1/2/2022")
            $result[-1].Date | Should Be ([datetime]"1/10/2022")
        }

        It 'Generates a date range with Format' {
            $result = Join-MissingTimestamps Date -Days 1 -From "1/1/2022" -To "1/10/2022" -Format 'yyyy-MM-dd'
            @($result).Count | Should Be 10
            $result[0].Date | Should Be "2022-01-01"
            $result[1].Date | Should Be "2022-01-02"
            $result[-1].Date | Should Be "2022-01-10"
        }

        It 'Generates an hour range' {
            $result = Join-MissingTimestamps Date -Hours 1 -From "1/1/2022" -To "1/2/2022"
            @($result).Count | Should Be 25
            $result[0].Date | Should Be ([datetime]"1/1/2022 12:00:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 1:00:00 AM")
            $result[-1].Date | Should Be ([datetime]"1/2/2022 12:00:00 AM")
        }

        It 'Generates a minute range' {
            $result = Join-MissingTimestamps Date -Minutes 5 -From "1/1/2022 3:00 AM" -To "1/1/2022 4:00 AM"
            @($result).Count | Should Be 13
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 4:00 AM")
        }

        It 'Generates a minute range with ExcludingTo' {
            $result = Join-MissingTimestamps Date -Minutes 5 -From "1/1/2022 3:00 AM" -To "1/1/2022 4:00 AM" -ExcludingTo
            @($result).Count | Should Be 12
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 3:55 AM")
        }

        It 'Generates a second range' {
            $result = Join-MissingTimestamps Date -Seconds 15 -From "1/1/2022 3:00 AM" -To "1/1/2022 4:00 AM"
            @($result).Count | Should Be 241
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:00:15 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 4:00:00 AM")
        }

        It 'Generates a millisecond range with ExcludingTo' {
            $result = Join-MissingTimestamps Date -Milliseconds 500 -From "1/1/2022 3:00:00 AM" -To "1/1/2022 3:00:10 AM" -ExcludingTo
            @($result).Count | Should Be 20
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00:00.000 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:00:00.500 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 3:00:09.500 AM")
        }

        It 'Generates a month range' {
            $result = Join-MissingTimestamps Date -Month -From "1/1/2022" -To "5/1/2022"
            @($result).Count | Should Be 5
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[1].Date | Should Be ([datetime]"2/1/2022")
            $result[-1].Date | Should Be ([datetime]"5/1/2022")
        }

        It 'Generates a month range with ExcludingTo' {
            $result = Join-MissingTimestamps Date -Month -From "1/1/2022" -To "5/1/2022" -ExcludingTo
            @($result).Count | Should Be 4
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[1].Date | Should Be ([datetime]"2/1/2022")
            $result[-1].Date | Should Be ([datetime]"4/1/2022")
        }
    }

    Context 'Setting Properties' {
        It 'Sets properties on generated objects with SetNew' {
            $result = Join-MissingTimestamps Date -Days 1 -From "1/1/2022" -To "1/10/2022" -SetNew @{Count=0;Series='One'}
            @($result).Count | Should Be 10
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[1].Date | Should Be ([datetime]"1/2/2022")
            $result[-1].Date | Should Be ([datetime]"1/10/2022")

            foreach ($r in $result)
            {
                $r.Count | Should Be 0
                $r.Series | Should Be One
            }
        }
    }

    Context 'Data Cleanup Checks' {
        
        It 'Can do a single date' {
            $result = Join-MissingTimestamps Date -Days 1 -From "1/1/2022" -To "1/1/2022"
            @($result).Count | Should Be 1
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[-1].Date | Should Be ([datetime]"1/1/2022")
        }

        It 'Floors the month' {
            $result = Join-MissingTimestamps Date -Month -From "1/5/2022" -To "3/1/2022"
            @($result).Count | Should Be 3
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[1].Date | Should Be ([datetime]"2/1/2022")
            $result[-1].Date | Should Be ([datetime]"3/1/2022")
        }

        It 'Floors the day' {
            $result = Join-MissingTimestamps Date -Days 1 -From "1/1/2022 5:00 AM" -To "1/10/2022"
            @($result).Count | Should Be 10
            $result[0].Date | Should Be ([datetime]"1/1/2022")
            $result[1].Date | Should Be ([datetime]"1/2/2022")
            $result[-1].Date | Should Be ([datetime]"1/10/2022")
        }

        It 'Floors the hour' {
            $result = Join-MissingTimestamps Date -Hours 1 -From "1/1/2022 12:15 AM" -To "1/2/2022 12:00 AM"
            @($result).Count | Should Be 25
            $result[0].Date | Should Be ([datetime]"1/1/2022 12:00:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 1:00:00 AM")
            $result[-1].Date | Should Be ([datetime]"1/2/2022 12:00:00 AM")
        }

        It 'Floors the minute' {
            $result = Join-MissingTimestamps Date -Minutes 5 -From "1/1/2022 3:00:01 AM" -To "1/1/2022 4:00:00 AM"
            @($result).Count | Should Be 13
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 4:00 AM")
        }

        It 'Floors the second' {
            $result = Join-MissingTimestamps Date -Seconds 15 -From "1/1/2022 3:00:00.500 AM" -To "1/1/2022 4:00:00 AM"
            @($result).Count | Should Be 241
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00:00 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:00:15 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 4:00:00 AM")
        }

        It 'Floors the millisecond' {
            $result = Join-MissingTimestamps Date -Milliseconds 500 -From "1/1/2022 3:00:00.00001 AM" -To "1/1/2022 3:00:10 AM" -ExcludingTo
            @($result).Count | Should Be 20
            $result[0].Date | Should Be ([datetime]"1/1/2022 3:00:00.000 AM")
            $result[1].Date | Should Be ([datetime]"1/1/2022 3:00:00.500 AM")
            $result[-1].Date | Should Be ([datetime]"1/1/2022 3:00:09.500 AM")
        }
    }

    Context 'Validation Checks' {

        It 'End cannot be less than start' {
            try
            {
                $result = Join-MissingTimestamps Date -Days 1 -From "1/10/2022" -To "1/1/2022" -ErrorAction Stop
            }
            catch { $ex=$_.Exception }

            $ex.Message | Should Be 'To must be greater than or equal to From.'
        }
    }
}
