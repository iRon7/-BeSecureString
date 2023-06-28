#Requires -Module Pester

function Should-BeSecureString ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    <#
    .SYNOPSIS
        Checks provided string is encryted and equal to the expected value
    .EXAMPLE
        # Check if type is [SecureString]

        $Password | Should -BeSecureString

    .EXAMPLE
        # Check if value is a [SecureString] and contains plaintext string (not recommended)

        $Password | Should -BeSecureString 'P@ssW0rD!'

    .EXAMPLE
        # Check if value is a [SecureString] that equals an other SecureString

        # Create a encrypted hex string
        # $SecureString = ConvertTo-SecureString 'P@ssW0rD!' -AsPlainText -Force
        # $SecureString | ConvertFrom-SecureString
    
        $SecureString = ConvertTo-SecureString '01000000d08c9ddf0115d1118c7a00c04fc297eb01000000d63fe8e2130898439bc1614dcea3f2c70000000002000000000010660000000100002000000088771547cc1125987fff88a0b77ba5596a4133ad9b3c862d51a69d1762126ce2000000000e800000000200002000000012557d0d0a101fcfd27050e459ed19e9b21224578ee35c162eed57b75f8bde96200000005c1b01787b3b7a931c84314c5a81a5973b8341da4e715247a58970ef4b327cab400000003c1ea6534eb066590b9082a8eb16cd6b08fc9898bb0108065cdb822888edcd936925cdb96f8c3c539a1e0003fe0d40c6ff3a3765d328a8dc819c9681559b4db9'
        $Password | Should -BeSecureString $SecureString

    .EXAMPLE
        # Check if value is a [SecureString] and contains an encrypted byte array

        # Create a base64 string from hex string
        # $Bytes = [byte[]] -split ($HexString -replace '..', '0x$& ')   
        # [Convert]::ToBase64String($Bytes)

        $Bytes = [System.Convert]::FromBase64String('AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAA1j/o4hMImEObwWFNzqPyxwAAAAACAAAAAAAQZgAAAAEAACAAAACIdxVHzBElmH//iKC3e6VZakEzrZs8hi1Rpp0XYhJs4gAAAAAOgAAAAAIAACAAAAASVX0NChAfz9JwUORZ7RnpshIkV47jXBYu7Ve3X4veliAAAABcGwF4ezt6kxyEMUxagaWXO4NB2k5xUkeliXDvSzJ8q0AAAAA8HqZTTrBmWQuQgqjrFs1rCPyYmLsBCAZc24IoiO3Nk2klzblvjDxTmh4AA/4NQMb/Ojdl0yio3IGcloFVm025')
        $Password | Should -BeSecureString $Bytes
    #>

    $Succeeded = $ActualValue -is [SecureString]
    if ($Succeeded -and $Null -ne $ExpectedValue) {
        $ExpectedString = 
            if ($ExpectedValue -is [SecureString]) {
                $Pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ExpectedValue)
                [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Pointer)
            }
            elseif ($ExpectedValue -is [Byte[]]) {
                $HexString = -Join ($ExpectedValue | ForEach-Object ToString X2)
                $SecureString = ConvertTo-SecureString $HexString
                $Pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
                [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Pointer)
            }
            else { $ExpectedValue }
        $Pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ActualValue)
        $ActualString = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Pointer)
        $Succeeded = $ActualString -eq $ExpectedString
        Remove-Variable Pointer, ActualString, ExpectedString
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        if ($Negate) { $succeeded = -not $succeeded }
        if (-not $succeeded) {
            if ($Negate) {
                $failureMessage = "Expected the secure strings not to be equal$(if($Because) { " because $Because"})."
            }
            else {
                $failureMessage = "Expected the secure strings to be equal$(if($Because) { " because $Because"})."
            }
        }
    }
    else {
        if ($Negate) { $succeeded = -not $succeeded }
        if (-not $succeeded) {
            if ($Negate) {
                $failureMessage = "Expected value not to be of type [SecureString]$(if($Because) { " because $Because"})."
            }
            else {
                $failureMessage = "Expected value to be of type [SecureString]$(if($Because) { " because $Because"})."
            }
        }
    }
    return [pscustomobject]@{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}


$Parameters = @{ 
    Name               = 'BeSecureString'
    InternalName       = 'Should-BeSecureString'
    Test               = ${function:Should-BeSecureString}
    Alias              = 'BSS'
}
Add-ShouldOperator @Parameters
