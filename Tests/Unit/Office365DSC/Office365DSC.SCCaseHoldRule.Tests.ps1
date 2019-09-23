[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $CmdletModule = (Join-Path -Path $PSScriptRoot `
            -ChildPath "..\Stubs\Office365.psm1" `
            -Resolve)
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
        -ChildPath "..\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-O365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "SCCaseHoldRule"
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
        $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

        Mock -CommandName Test-MSCloudLogin -MockWith {

        }

        Mock -CommandName Import-PSSession -MockWith {

        }

        Mock -CommandName New-PSSession -MockWith {

        }

        Mock -CommandName Remove-CaseHoldRule -MockWith {
            return @{

            }
        }

        Mock -CommandName New-CaseHoldRule -MockWith {
            return @{

            }
        }

        Mock -CommandName Set-CaseHoldRule -MockWith {
            return @{

            }
        }

        # Test contexts
        Context -Name "Rule doesn't already exists and should" -Fixture {
            $testParams = @{
                Name               = "TestRule"
                Policy             = "TestPolicy"
                Comment            = "This is a test Rule"
                Disabled           = $false
                ContentMatchQuery  = "filename:2016 budget filetype:xlsx"
                GlobalAdminAccount = $GlobalAdminAccount
                Ensure             = "Present"
            }

            Mock -CommandName Get-CaseHoldRule -MockWith {
                return $null
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It 'Should return Absent from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should Be "Absent"
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "Rule already exists and should be updated" -Fixture {
            $testParams = @{
                Name               = "TestRule"
                Policy             = "TestPolicy"
                Comment            = "This is a test Rule"
                Disabled           = $false
                ContentMatchQuery  = "filename:2016 budget filetype:xlsx"
                GlobalAdminAccount = $GlobalAdminAccount
                Ensure             = "Present"
            }

            Mock -CommandName Get-CaseHoldRule -MockWith {
                return @{
                    Name               = "TestRule"
                    Policy             = "12345-12345-12345-12345-12345"
                    Comment            = "Different comment"
                    Disabled           = $true
                    ContentMatchQuery  = "filename:2016 budget filetype:xlsx"
                }
            }

            Mock -CommandName Get-CaseHoldPolicy -MockWith {
                return @{
                    Name              = "TestPolicy"
                    Identity          = "12345-12345-12345-12345-12345"
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $False
            }

            It 'Should update from the Set method' {
                Set-TargetResource @testParams
            }

            It 'Should return Present from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }
        }

        Context -Name "Rule already exists, but should be absent" -Fixture {
            $testParams = @{
                Name               = "TestRule"
                Policy             = "TestPolicy"
                Comment            = "This is a test Rule"
                Disabled           = $false
                ContentMatchQuery  = "filename:2016 budget filetype:xlsx"
                GlobalAdminAccount = $GlobalAdminAccount
                Ensure             = "Absent"
            }

            Mock -CommandName Get-CaseHoldRule -MockWith {
                return @{
                    Name               = "TestRule"
                    Policy             = "12345-12345-12345-12345-12345"
                    Comment            = "Different comment"
                    Disabled           = $true
                    ContentMatchQuery  = "filename:2016 budget filetype:xlsx"
                }
            }

            Mock -CommandName Get-CaseHoldPolicy -MockWith {
                return @{
                    Name              = "TestPolicy"
                    Identity          = "12345-12345-12345-12345-12345"
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $False
            }

            It 'Should update from the Set method' {
                Set-TargetResource @testParams
            }

            It 'Should return Present from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should Be "Present"
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            $testParams = @{
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-CaseHoldRule -MockWith {
                return @{
                    Name               = "TestRule"
                    Policy             = "12345-12345-12345-12345-12345"
                    Comment            = "Different comment"
                    Disabled           = $true
                    ContentMatchQuery  = "filename:2016 budget filetype:xlsx"
                }
            }

            Mock -CommandName Get-CaseHoldPolicy -MockWith {
                return @{
                    Name              = "TestPolicy"
                    Identity          = "12345-12345-12345-12345-12345"
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
