# my preferred prompt for Powershell.
# change to root dev directory `;` to chain commands in powershell
cd C:\dev\

# produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# display git branch and stats when navigating inside a git repository.
# https://markembling.info/2009/09/my-ideal-powershell-prompt-with-git-integration

# see http://gist.github.com/180853 for gitutils.ps1 -- file must exist at this path, with content
# from this gist URL for colored prompts to work correctly in git projects
. (Resolve-Path C:/Users/chris/OneDrive/Documents/WindowsPowerShell/gitutils.ps1)

#other resource
# http://stackingcode.com/blog/2011/11/05/powershell-prompt

# admin checking utilities:  https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/


# get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator


# colorize command prompts
function prompt {
    $currentDirectory = $(Get-Location)
    $path = ""
$pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)
if($pathbits.length -eq 1) {
$path = $pathbits[0] + "\"
} else {
$path = $pathbits[$pathbits.length - 1]
}
    # change window title
    $host.ui.rawui.WindowTitle = " " + $adminRole
    # $host.ui.rawui.WindowTitle = " " + $adminRole + ": surfaceOwl@ $pwd" + " "

    # display user in terminal
    # to change depth of user path displayed change the number inside the first pair of []
    $userLocation = $currentDirectory
    # change $userlocation to '' to have nothing displayed
    # $userLocation example formats commented out below
    # $userLocation = ($pwd -split '\\')[3]+' '+$(($pwd -split '\\')[3] -join '\') + '> '
    # $userLocation = $(($pwd -split '\\')[-1] -join '\') + '> '

    # set colors based on location
    Write-Host($userLocation) -nonewline -foregroundcolor Green

    if (isCurrentDirectoryGitRepository) {
        $status = gitStatus
        $currentBranch = $status["branch"]

        Write-Host(' [') -nonewline -foregroundcolor Yellow
        if ($status["ahead"] -eq $FALSE) {
            # We are not ahead of origin
            Write-Host($currentBranch) -nonewline -foregroundcolor Cyan
        } else {
            # We are ahead of origin
            Write-Host($currentBranch) -nonewline -foregroundcolor Red
        }
        Write-Host(' +' + $status["added"]) -nonewline -foregroundcolor Yellow
        Write-Host(' ~' + $status["modified"]) -nonewline -foregroundcolor Yellow
        Write-Host(' -' + $status["deleted"]) -nonewline -foregroundcolor Yellow

        if ($status["untracked"] -ne $FALSE) {
            Write-Host(' !') -nonewline -foregroundcolor Yellow
        }

        Write-Host(']') -nonewline -foregroundcolor Yellow
    }

Write-Host('>') -nonewline -foregroundcolor Green
return " "
}

# turn off bell when trying to backspace at an empty prompt
Set-PSReadlineOption -BellStyle None

# fix powershell tab completion so it cycles through all available options rather than picking 1st one found
Set-PSReadlineOption -EditMode Emacs


# Clear-Host clears the powershell window
Clear-Host


# custom function - automate upgrade of python pip, setuptools, wheel and virtualenv
function upgradepip {
    # run this command from powershell to activate python venv in windows
    Invoke-Expression "python -m pip install --upgrade pip, setuptools, wheel, virtualenv --ignore-installed"
}


# custom function - simplify command for activation of python virtual environment
# venv activate; must be after elevating to Administrator Role
function Activate-venv {
    # run this command from powershell to activate python venv in windows
    Invoke-Expression ". .\venv\Scripts\activate"
}

Set-Alias activate Activate-venv

# last command - list current dir; useful when launching powershell to see where you are and local dir/files
ls
