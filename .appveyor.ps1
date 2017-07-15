$ErrorActionPreference = "Stop"
Get-ChildItem C:\Python* | ForEach-Object{
    $python = $_.Name
    Write-Host ('Testing ' + $python) -ForegroundColor Magenta
    $originPath = $env:Path
    $env:Path = 'C:\' + $python + '\Scripts;' + 'C:\' + $python + ';' + $env:Path
    Write-Host (python -c "print(__import__('sys').version)") -ForegroundColor Yellow

    if($python.StartsWith('Python35') -or $python.StartsWith('Python36')){
        python .appveyor.py
        if(-not $?){ throw }
    }else{
        $cmd = 'call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" '
        if($python.EndsWith('x64')){
            $cmd += 'x64'
        }else{
            $cmd += 'x86'
        }
        $cmd += ' && python .appveyor.py'
        cmd /c $cmd
        if(-not $?){ throw }
    }

    Write-Host ('Success ' + $python) -ForegroundColor Green
    $env:Path = $originPath
}
