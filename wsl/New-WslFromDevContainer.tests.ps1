Set-StrictMode -Version 3.0
Describe 'New-WslFromDevContainer' {

    BeforeAll {

        function Get-DevContainerJsonContent {
            #return $devContainerJson
            return @'
{
    "name": "test-container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu"
}
'@
        }

        function New-DevContainerJsonFile {
            param(
                [string]$workspaceFolder,
                [string]$subfolder = $null,
                [string]$jsonContent
            )
    
            #Create the .devcontainer folder if it does not exist
            $devContainerFolder = Join-Path -Path $workspaceFolder -ChildPath '.devcontainer'
            if(-not (Test-Path $devContainerFolder)) {
                New-Item -ItemType Directory -Path $devContainerFolder | Out-Null
            }
    
            #If the $subfolder parameter is provided and does not exist, create it
            if($subfolder) {
                $devContainerFolder = Join-Path -Path $devContainerFolder -ChildPath $subfolder
                New-Item -ItemType Directory -Path $devContainerFolder | Out-Null
            }
            
            $devContainerJsonPath = Join-Path -Path $devContainerFolder -ChildPath 'devcontainer.json'
            $jsonContent | Set-Content -Path $devContainerJsonPath | Out-Null
    
            return $devContainerJsonPath
        }

        function Remove-WslInstance {
            param(
                [string]
                [Parameter(Mandatory = $true)]
                $wslInstanceName
            )
    
            wsl --unregister $wslInstanceName
            wsl --list | Should -Not -Contain $wslInstanceName
        }

        function Assert-WslInstance {
            param(
                [string]
                [Parameter(Mandatory = $true)]
                $wslInstanceName
            )
    
            wsl --list | Should -Contain $wslInstanceName
        }
        
        # Recreate the test data folder
        $testDataPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestData'
        if ((Test-Path -Path $testDataPath)) {
            Remove-Item -Path $testDataPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $testDataPath | Out-Null
    }
    BeforeEach {
        $testDataPath | Should -Exist
    }
    AfterEach {
        Get-ChildItem -Path $testDataPath -Recurse | Remove-Item -Recurse -Force
    }
    AfterAll {
        Remove-Item -Path $testDataPath -Recurse -Force
    }

    It 'Throw error if no .devcontainer file' {
        # Arrange
        $expectedMessage = "No devcontainer.json files found."

        # Act
        { .\New-WslFromDevContainer -WorkspaceFolder $testDataPath } | Should -Throw $expectedMessage
    }

    It 'Throw error if multiple .devcontainer files and no json path parameter' {
        # Arrange
        $expectedMessage = "Multiple devcontainer.json files found. Please provide the DevContainerJsonPath parameter."
        New-DevContainerJsonFile -workspaceFolder $testDataPath -subfolder 'subfolder1' -jsonContent (Get-DevContainerJsonContent) | Should -Exist
        New-DevContainerJsonFile -workspaceFolder $testDataPath -subfolder 'subfolder2' -jsonContent (Get-DevContainerJsonContent) | Should -Exist
        
        # Act
        { .\New-WslFromDevContainer -WorkspaceFolder $testDataPath } | Should -Throw $expectedMessage
    }

    It 'Throw error if invalid container path given' {
        # Arrange
        $expectedMessage = "No devcontainer.json file found."

        # Act
        { & .\New-WslFromDevContainer -WorkspaceFolder $testDataPath -DevContainerJsonPath 'invalid-path' } | Should -Throw $expectedMessage
    }

    It 'Throw error when null user name given' {
        # Arrange
        New-DevContainerJsonFile -workspaceFolder $testDataPath -jsonContent (Get-DevContainerJsonContent)
        $expectedMessage = "Cannot validate argument on parameter 'WslUserName'. The argument is null, empty, or consists of only white-space characters. Provide an argument that contains non white-space characters, and then try the command again."

        # Act
        { & .\New-WslFromDevContainer -WorkspaceFolder $testDataPath -DevContainerJsonPath 'invalid-path' -WslUserName $null } | Should -Throw $expectedMessage
    }

    It 'Create WSL instance from workspace folder with one devcontainer.json' {
        # Arrange
        New-DevContainerJsonFile -workspaceFolder $testDataPath -jsonContent (Get-DevContainerJsonContent)
        $wslInstanceName = 'test-container-wsl'
        
        # Act
        { .\New-WslFromDevContainer -WorkspaceFolder $testDataPath -WslInstanceName $wslInstanceName } | Should -Not -Throw

        # Assert
        Assert-WslInstance -wslInstanceName $wslInstanceName
        Remove-WslInstance -wslInstanceName $wslInstanceName
    }

    It 'Create WSL instance from workspace folder with multiple devcontainer.json files' {
        # Arrange
        New-DevContainerJsonFile -workspaceFolder $testDataPath -subfolder 'subfolder1' -jsonContent (Get-DevContainerJsonContent)
        $devContainerJsonPath = New-DevContainerJsonFile -workspaceFolder $testDataPath -subfolder 'subfolder2' -jsonContent (Get-DevContainerJsonContent)
        
        $wslInstanceName = 'test-container-wsl'
        
        # Act
        { .\New-WslFromDevContainer `
            -WorkspaceFolder $testDataPath `
            -DevContainerJsonPath $devContainerJsonPath `
            -WslInstanceName $wslInstanceName } | Should -Not -Throw

        # Assert
        Assert-WslInstance -wslInstanceName $wslInstanceName
        Remove-WslInstance -wslInstanceName $wslInstanceName
    }

    It 'Create WSL instance with default name' {
        # Arrange
        $devContainerJsonPath = New-DevContainerJsonFile -workspaceFolder $testDataPath -jsonContent (Get-DevContainerJsonContent)
        $wslInstanceName = (Get-Content -Path $devContainerJsonPath -Raw | ConvertFrom-Json).name
        
        # Act
        { .\New-WslFromDevContainer -WorkspaceFolder $testDataPath } | Should -Not -Throw

        # Assert
        Assert-WslInstance -wslInstanceName $wslInstanceName
        Remove-WslInstance -wslInstanceName $wslInstanceName
    }
}