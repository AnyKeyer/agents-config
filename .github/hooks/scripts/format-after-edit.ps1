# format-after-edit.ps1
# PostToolUse hook: auto-formats a file after the Executor edits it.
# Silently exits 0 on any error — never blocks the agent.

$ErrorActionPreference = 'SilentlyContinue'

try {
    $raw = $input -join "`n"
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

    $data = $raw | ConvertFrom-Json -ErrorAction Stop

    # Only process file-editing operations
    $editTools = @('replace_string_in_file', 'create_file', 'multi_replace_string_in_file')
    if ($data.tool -notin $editTools) { exit 0 }

    $filePath = $data.toolInput.filePath
    if ([string]::IsNullOrWhiteSpace($filePath) -or -not (Test-Path $filePath -PathType Leaf)) { exit 0 }

    $ext = [System.IO.Path]::GetExtension($filePath).ToLower().TrimStart('.')

    function Invoke-Prettier {
        param([string]$File)
        # Walk up directories to find local node_modules/.bin/prettier
        $dir = Split-Path $File -Parent
        while ($dir -and $dir -ne [System.IO.Path]::GetPathRoot($dir)) {
            $bin = Join-Path $dir 'node_modules\.bin\prettier.cmd'
            if (Test-Path $bin) {
                & $bin --write $File 2>$null
                return
            }
            $dir = Split-Path $dir -Parent
        }
        # Fall back to global prettier
        if (Get-Command prettier -ErrorAction SilentlyContinue) {
            prettier --write $File 2>$null
        }
    }

    switch ($ext) {
        { $_ -in @('ts', 'tsx', 'js', 'jsx', 'mjs', 'cjs', 'json', 'css', 'html', 'md', 'yml', 'yaml') } {
            Invoke-Prettier $filePath
        }
        'py' {
            if (Get-Command ruff -ErrorAction SilentlyContinue) {
                ruff format $filePath 2>$null
            } elseif (Get-Command black -ErrorAction SilentlyContinue) {
                black $filePath 2>$null
            }
        }
        'go' {
            if (Get-Command gofmt -ErrorAction SilentlyContinue) {
                gofmt -w $filePath 2>$null
            }
        }
        'rs' {
            if (Get-Command rustfmt -ErrorAction SilentlyContinue) {
                rustfmt $filePath 2>$null
            }
        }
    }
} catch {
    # Silent failure — never block the agent
}

exit 0
