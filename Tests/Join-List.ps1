Import-Module $PSScriptRoot\.. -DisableNameChecking -Force

Describe "Join-List" {

    Context 'Default' {

        $clusterList = "
            ClusterId,ClusterName,ClusterType
            1,SQL001,SQL
            2,SQL002,SQL
            3,CAFile,File
            4,TXFile,File
            6,SQL003,SQL
        ".Trim() -replace '\A +' | ConvertFrom-Csv

        $groupList = "
            ClusterId,GroupName
            1,INST1
            1,INST2
            2,INST1
            3,Departments
            3,IT
            4,IT
            5,Finance
        ".Trim() -replace '\A +' | ConvertFrom-Csv

        It 'Works' {
            $resultList = $groupList | Join-List ClusterId $clusterList ClusterId
            $resultList[0].ClusterName | Should Be SQL001
            $resultList[0].ClusterType | Should Be SQL
            $resultList[-1].ClusterName | Should Be $null
            $resultList[-1].ClusterType | Should Be $null
            @($resultList[-1].PSObject.Properties)[-2].Name | Should Be ClusterName
            @($resultList[-1].PSObject.Properties)[-1].Name | Should Be ClusterType
        }

        It 'Works with -MatchesOnly' {
            $resultList = $groupList | Join-List ClusterId $clusterList ClusterId -MatchesOnly
            $resultList[0].ClusterName | Should Be SQL001
            $resultList[-1].ClusterName | Should Not Be $null
        }

        It 'Works with a null key' {
            $resultList = $groupList | Join-List NotAMatch $clusterList ClusterId
            $resultList[0].ClusterName | Should Be $null
        }

        It "Uses InputKey if JoinKey isn't specified" {
            $result = [pscustomobject]@{Key='A'; Value1=1} | Join-List Key ([pscustomobject]@{Key='A'; Value2=2})
            $result.Value2 | Should Be 2
        }

    }

    Context 'KeepProperty' {
        It 'Keeps specified properties' {
            $result = [pscustomobject]@{Key='A'; Value1='AAA'} | Join-List Key ([pscustomobject]@{Key='A'; Value2='BBB'; Value3='CCC'}) Key -KeepProperty Value2
            $result.Value1 | Should Be 'AAA'
            $result.Value2 | Should Be 'BBB'
            $null -eq $result.PSObject.Properties['Value3'] | Should Be $true
        }

        It 'Renames properties' {
            $result = [pscustomobject]@{Key='A'; Value1='AAA'} | Join-List Key ([pscustomobject]@{Key='A'; Value2='BBB'; Value3='CCC'}) Key -KeepProperty Value2, @{Value3='ValueX'}
            $result.Value1 | Should Be 'AAA'
            $result.Value2 | Should Be 'BBB'
            $null -eq $result.PSObject.Properties['Value3'] | Should Be $true
            $result.ValueX | Should Be 'CCC'
        }

        It "Doesn't add properties that don't exist" {
            $result = [pscustomobject]@{Key='A'; Value1='AAA'} | Join-List Key ([pscustomobject]@{Key='A'; Value2='BBB'}) Key -KeepProperty Value2, Value3
            $result.Value1 | Should Be 'AAA'
            $result.Value2 | Should Be 'BBB'
            $null -eq $result.PSObject.Properties['Value3'] | Should Be $true
        }

        It "Does add properties if a join didn't occur" {
            $result = [pscustomobject]@{Key='A'; Value1='AAA'} | Join-List Key ([pscustomobject]@{Key='B'; Value2='BBB'}) Key -KeepProperty Value2, Value3
            $result.Value1 | Should Be 'AAA'
            $result.PSObject.Properties.Name -join ',' | Should Be 'Key,Value1,Value2'
        }

        It "Still renames properties if a join didn't occur" {
            $result = [pscustomobject]@{Key='A'; Value1='AAA'} | Join-List Key ([pscustomobject]@{Key='B'; Value2='BBB'}) Key -KeepProperty @{Value2='ValueX'}
            $result.Value1 | Should Be 'AAA'
            $result.PSObject.Properties.Name -join ',' | Should Be 'Key,Value1,ValueX'
        }

        It 'Coexists with the old value if present' {
            $result = [pscustomobject]@{Key='A'; Value1='AAA'} | Join-List Key ([pscustomobject]@{Key='A'; Value2='BBB'}) Key -KeepProperty @{Value2='ValueX'}
            $result.Value1 | Should Be 'AAA'
            $result.ValueX | Should Be 'BBB'
            $result.PSObject.Properties.Name -join ',' | Should Be 'Key,Value1,ValueX'
        }
    }

    Context 'Overwriting' {

        It 'Nothing is overwritten by default (Value)' {
            $result = [pscustomobject]@{Key='A'; Value='Old'} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key
            $result.Value | Should Be 'Old'
        }

        It 'Nothing is overwritten by default (Empty String)' {
            $result = [pscustomobject]@{Key='A'; Value=''} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key
            $result.Value | Should Be ''
        }

        It 'Nothing is overwritten by default (Null)' {
            $result = [pscustomobject]@{Key='A'; Value=$null} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key
            $null -eq $result.Value | Should Be $true
        }

        It 'Overwrite Always works' {
            $result = [pscustomobject]@{Key='A'; Value='Old'} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key -Overwrite Always
            $result.Value | Should Be 'New'
        }

        It 'Overwrite Always works with null values' {
            $result = [pscustomobject]@{Key='A'; Value='Old'} | Join-List Key ([pscustomobject]@{Key='A'; Value=$null}) Key -Overwrite Always
            $null -eq $result.Value | Should Be $true
        }

        It 'Overwrite IfNullOrEmpty overwrites empty strings' {
            $result = [pscustomobject]@{Key='A'; Value=''} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key -Overwrite IfNullOrEmpty
            $result.Value | Should Be 'New'
        }

        It 'Overwrite IfNullOrEmpty overwrites nulls' {
            $result = [pscustomobject]@{Key='A'; Value=$null} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key -Overwrite IfNullOrEmpty
            $result.Value | Should Be 'New'
        }

        It 'Overwrite IfNullOrEmpty does not overwrite values' {
            $result = [pscustomobject]@{Key='A'; Value='Old'} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key -Overwrite IfNullOrEmpty
            $result.Value | Should Be 'Old'
        }

        It 'Overwrite IfNullOrEmpty overwrites nulls' {
            $result = [pscustomobject]@{Key='A'; Value=$null} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key -Overwrite IfNullOrEmpty
            $result.Value | Should Be 'New'
        }

        It 'Overwrite IfNewValueNotNullOrEmpty overwrites when not null' {
            $result = [pscustomobject]@{Key='A'; Value='Old'} | Join-List Key ([pscustomobject]@{Key='A'; Value='New'}) Key -Overwrite IfNewValueNotNullOrEmpty
            $result.Value | Should Be 'New'
        }

        It 'Overwrite IfNewValueNotNullOrEmpty does not overwrite when null' {
            $result = [pscustomobject]@{Key='A'; Value='Old'} | Join-List Key ([pscustomobject]@{Key='A'; Value=$null}) Key -Overwrite IfNewValueNotNullOrEmpty
            $result.Value | Should Be 'Old'
        }

        It 'Overwrite does not overwrite when not matched as appropriate' {
            $result1 = [pscustomobject]@{Key = 1; Exists = 'Yes' } | Join-List Key ([pscustomobject]@{Key=2; Exists='No'}) -Overwrite IfNewValueNotNullOrEmpty
            $result1.Exists | Should Be 'Yes'

            $result2 = [pscustomobject]@{Key = 1; Exists = 'Yes' } | Join-List Key ([pscustomobject]@{Key=2; Exists='No'}) -Overwrite Always
            $result2.Exists | Should Be $null

            $result3 = [pscustomobject]@{Key = 1; Exists = 'Yes' } | Join-List Key ([pscustomobject]@{Key=2; Exists='No'}) -Overwrite Never
            $result3.Exists | Should Be Yes

            $result4 = [pscustomobject]@{Key = 1; Exists = 'Yes' } | Join-List Key ([pscustomobject]@{Key=2; Exists='No'}) -Overwrite IfNullOrEmpty
            $result4.Exists | Should Be Yes
        }
    }

    Context "Setting values on matches" {
        It "Sets values on matches" {
            $result = [pscustomobject]@{A=1}, [pscustomobject]@{A=2} |
                Join-List A ([pscustomobject]@{A=2;B=-1}) -SetOnMatched @{M=$true}

            @($result).Count | Should Be 2
            
            $result[0].PSObject.Properties.Name -join '+' | Should Be 'A+B+M'
            $result[0].A | Should Be 1
            $result[0].B | Should Be $null
            $result[0].M | Should Be $null

            $result[1].PSObject.Properties.Name -join '+' | Should Be 'A+B+M'
            $result[1].A | Should Be 2
            $result[1].B | Should Be -1
            $result[1].M | Should Be $true
        }

        It "Sets values on failed matches" {
            $result = [pscustomobject]@{A=1}, [pscustomobject]@{A=2} |
                Join-List A ([pscustomobject]@{A=2;B=-1}) -SetOnUnmatched @{M=$false}

            @($result).Count | Should Be 2
            
            $result[1].PSObject.Properties.Name -join '+' | Should Be 'A+B+M'
            $result[0].A | Should Be 1
            $result[0].B | Should Be $null
            $result[0].M | Should Be $false

            $result[1].PSObject.Properties.Name -join '+' | Should Be 'A+B+M'
            $result[1].A | Should Be 2
            $result[1].B | Should Be -1
            $result[1].M | Should Be $null
        }

        It "Sets values on unmatched right objects" {
            $result = [pscustomobject]@{A=1} |
                Join-List A ([pscustomobject]@{A=2;B=-1}) -SetOnUnmatched @{M=$false} -IncludeUnmatchedData

            @($result).Count | Should Be 2
            
            $result[1].PSObject.Properties.Name -join '+' | Should Be 'A+B+M'
            $result[0].A | Should Be 1
            $result[0].B | Should Be $null
            $result[0].M | Should Be $false

            $result[1].PSObject.Properties.Name -join '+' | Should Be 'A+B+M'
            $result[1].A | Should Be 2
            $result[1].B | Should Be -1
            $result[1].M | Should Be $false
        }
        
        It "Doesn't overwrite joined data when using SetOnUnmatched" {
            $result = [pscustomobject]@{A=1}, [pscustomobject]@{A=2} |
                Join-List A ([pscustomobject]@{A=1;B='OK'}) -SetOnUnmatched @{B='Unknown'}
            $result[0].A | Should Be 1
            $result[0].B | Should Be 'OK'
            $result[1].A | Should Be 2
            $result[1].B | Should Be 'Unknown'
        }

        It "Keeps order" {
            $result = [pscustomobject]@{A=1} |
                Join-List A ([pscustomobject]@{A=1;B=-1}) -SetOnUnmatched ([ordered]@{Y=1;Z=2;X=3})

            $result[0].PSObject.Properties.Name -join '+' | Should Be 'A+B+Y+Z+X'
        }
    }
}

return

# ================================================================================
# Performance Reasonings

# ================================================================================
# Question: How long does it take to enumerate an empty hashset 100,000 times?
# Why: To simplify the code so we don't have to test for the requirement
$hashset = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::CurrentCultureIgnoreCase)

Measure-Command {
    for ($i = 0; $i -lt 100000; $i++)
    {
        foreach ($n in $hashset.GetEnumerator())
        {
            1/0
        }
    }
}

# Answer: ~200 ms

# Followup: What about just an if count test?
Measure-Command {
    for ($i = 0; $i -lt 100000; $i++)
    {
        if ($hashset.Count)
        {
            1/0
        }
    }
}

# Followup: 100,000 if ($false) tests
# Answer: ~200 ms
Measure-Command {
    for ($i = 0; $i -lt 100000; $i++)
    {
        if ($false)
        {
            1/0
        }
    }
}

# Answer: ~100 ms
# Verdict: Save 100ms and use an if and separate boolean
