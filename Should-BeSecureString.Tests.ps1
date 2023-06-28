BeforeDiscovery {
    # Loads and registers my custom assertion. Ignores usage of unapproved verb with -DisableNameChecking
    Import-Module "$PSScriptRoot\Should-BeSecureString.psm1" -DisableNameChecking
}

Describe 'Testing Should -BeSecureString' {

    BeforeAll {
        $Password = ConvertTo-SecureString 'P@ssW0rD!' -AsPlainText -Force
    }

    It 'Type check' {
        $Password | Should -BeSecureString
        'String' | Should -not -BeSecureString 
    }

    It 'Plaintext' {
        $Password | Should -BeSecureString 'P@ssW0rD!'
        $Password | Should -not -BeSecureString 'Something else'
    }

    It 'SecureString' {
        $SecureString = ConvertTo-SecureString '01000000d08c9ddf0115d1118c7a00c04fc297eb01000000d63fe8e2130898439bc1614dcea3f2c70000000002000000000010660000000100002000000088771547cc1125987fff88a0b77ba5596a4133ad9b3c862d51a69d1762126ce2000000000e800000000200002000000012557d0d0a101fcfd27050e459ed19e9b21224578ee35c162eed57b75f8bde96200000005c1b01787b3b7a931c84314c5a81a5973b8341da4e715247a58970ef4b327cab400000003c1ea6534eb066590b9082a8eb16cd6b08fc9898bb0108065cdb822888edcd936925cdb96f8c3c539a1e0003fe0d40c6ff3a3765d328a8dc819c9681559b4db9'
        $Password | Should -BeSecureString $SecureString
    }

    It 'Bytes' {
        $Bytes = [System.Convert]::FromBase64String('AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAA1j/o4hMImEObwWFNzqPyxwAAAAACAAAAAAAQZgAAAAEAACAAAACIdxVHzBElmH//iKC3e6VZakEzrZs8hi1Rpp0XYhJs4gAAAAAOgAAAAAIAACAAAAASVX0NChAfz9JwUORZ7RnpshIkV47jXBYu7Ve3X4veliAAAABcGwF4ezt6kxyEMUxagaWXO4NB2k5xUkeliXDvSzJ8q0AAAAA8HqZTTrBmWQuQgqjrFs1rCPyYmLsBCAZc24IoiO3Nk2klzblvjDxTmh4AA/4NQMb/Ojdl0yio3IGcloFVm025')
        $Password | Should -BeSecureString $Bytes
    }
}