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

    Context 'Joining to Input Ranges' {
        It 'Inserts values into ranges' {
            $result = @(
                [pscustomobject]@{Timestamp='1/1/2022 3:05:00 AM'; Events=50}
                [pscustomobject]@{Timestamp='1/1/2022 3:10:00 AM'; Events=40}
                [pscustomobject]@{Timestamp='1/1/2022 3:30:00 AM'; Events=10}
            ) |
                Join-MissingTimestamps Timestamp -Minutes 5 -From '1/1/2022 3:00:00 AM' -To '1/1/2022 3:55:00 AM' -SetNew @{Events=0}

            @($result).Count | Should Be 12
            $result[0].Timestamp | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[1].Timestamp | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[-1].Timestamp | Should Be ([datetime]"1/1/2022 3:55 AM")

            $result[0].Events | Should Be 0
            $result[1].Events | Should Be 50
            $result[2].Events | Should Be 40
            $result[3].Events | Should Be 0
            $result[6].Events | Should Be 10
            $result[-1].Events | Should Be 0
        }

        It 'Formats timestamps in ranges' {
            $result = @(
                [pscustomobject]@{Timestamp='1/1/2022 3:05:00 AM'; Events=50}
                [pscustomobject]@{Timestamp='1/1/2022 3:10:00 AM'; Events=40}
                [pscustomobject]@{Timestamp='1/1/2022 3:30:00 AM'; Events=10}
            ) |
                Join-MissingTimestamps Timestamp -Minutes 5 -From '1/1/2022 3:00:00 AM' -To '1/1/2022 3:55:00 AM' -SetNew @{Events=0} -Format 'yyyy-MM-dd HH:mm:ss'

            @($result).Count | Should Be 12
            $result[0].Timestamp | Should Be '2022-01-01 03:00:00'
            $result[1].Timestamp | Should Be '2022-01-01 03:05:00'
            $result[-1].Timestamp | Should Be '2022-01-01 03:55:00'

            $result[0].Events | Should Be 0
            $result[1].Events | Should Be 50
            $result[2].Events | Should Be 40
            $result[3].Events | Should Be 0
            $result[6].Events | Should Be 10
            $result[-1].Events | Should Be 0
        }

        It 'Can get From and To from the input range' {
            $result = @(
                [pscustomobject]@{Timestamp='1/1/2022 3:05:00 AM'; Events=50}
                [pscustomobject]@{Timestamp='1/1/2022 3:10:00 AM'; Events=40}
                [pscustomobject]@{Timestamp='1/1/2022 3:30:00 AM'; Events=10}
            ) |
                Join-MissingTimestamps Timestamp -Minutes 5 -SetNew @{Events=0}

            @($result).Count | Should Be 6
            $result[0].Timestamp | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[1].Timestamp | Should Be ([datetime]"1/1/2022 3:10 AM")
            $result[-1].Timestamp | Should Be ([datetime]"1/1/2022 3:30 AM")

            $result[0].Events | Should Be 50
            $result[1].Events | Should Be 40
            $result[2].Events | Should Be 0
            $result[5].Events | Should Be 10
        }
    }

    Context 'Joining to Input Ranges with Set' {
        It 'Does a single set property/value' {
            $result = @(
                [pscustomobject]@{Timestamp='1/1/2022 3:05:00 AM'; Series='A'; Events=50}
                [pscustomobject]@{Timestamp='1/1/2022 3:05:00 AM'; Series='B'; Events=40}
                [pscustomobject]@{Timestamp='1/1/2022 3:30:00 AM'; Series='B'; Events=10}
            ) |
                Join-MissingTimestamps Timestamp -Minutes 5 -From '1/1/2022 3:00:00 AM' -To '1/1/2022 3:55:00 AM' -SetKeys Series -SetNew @{Events=0}

            @($result).Count | Should Be 24
            $result[0].Timestamp | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[1].Timestamp | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[2].Timestamp | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[3].Timestamp | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[-1].Timestamp | Should Be ([datetime]"1/1/2022 3:55 AM")

            $result[0].Events | Should Be 0
            $result[1].Events | Should Be 0
            $result[2].Events | Should Be 50
            $result[3].Events | Should Be 40
            $result[4].Events | Should Be 0
            $result[5].Events | Should Be 0
            $result[12].Events | Should Be 0
            $result[13].Events | Should Be 10
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

        It 'Floors minutes when ranges are used' {
            $result = @(
                [pscustomobject]@{Timestamp='1/1/2022 3:05:10 AM'; Events=50}
                [pscustomobject]@{Timestamp='1/1/2022 3:10:00 AM'; Events=40}
                [pscustomobject]@{Timestamp='1/1/2022 3:30:10 AM'; Events=10}
            ) |
                Join-MissingTimestamps Timestamp -Minutes 5 -From '1/1/2022 3:00:00 AM' -To '1/1/2022 3:55:00 AM' -SetNew @{Events=0}

            @($result).Count | Should Be 12
            $result[0].Timestamp | Should Be ([datetime]"1/1/2022 3:00 AM")
            $result[1].Timestamp | Should Be ([datetime]"1/1/2022 3:05 AM")
            $result[-1].Timestamp | Should Be ([datetime]"1/1/2022 3:55 AM")

            $result[0].Events | Should Be 0
            $result[1].Events | Should Be 50
            $result[2].Events | Should Be 40
            $result[3].Events | Should Be 0
            $result[6].Events | Should Be 10
            $result[-1].Events | Should Be 0
        }

        It 'Floors relative to the date for non-single-digit increments' {
            
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

        It 'Must use both or neither To and From' {
            try
            {
                $result = Join-MissingTimestamps Date -Days 1 -From "1/10/2022" -ErrorAction Stop
            }
            catch { $ex=$_.Exception }

            $ex.Message | Should Be 'To and From must be used together or not at all.'
        }

        It 'ExcludingTo can only be used with To' {
            try
            {
                $result = Join-MissingTimestamps Date -Days 1 -ExcludingTo -ErrorAction Stop
            }
            catch { $ex=$_.Exception }

            $ex.Message | Should Be 'ExcludingTo can only be used with To.'
        }

        It 'Cannot use the same input timestamp twice' {
            try
            {
                $result = @(
                    [pscustomobject]@{Date='1/1/2022'}
                    [pscustomobject]@{Date='1/1/2022'}
                    [pscustomobject]@{Date='1/3/2022'}
                ) |
                    Join-MissingTimestamps Date -Days 1
            }
            catch { $ex=$_.Exception }

            $ex.Message | Should Match 'The same timestamp cannot be present more than once in the input data.'
        }
    }
}
