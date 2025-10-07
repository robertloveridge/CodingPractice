param (
    [string]$ConfigPath = ".\fileMerger_fileSchema.json"
)

if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config file not found: $ConfigPath"
    exit 1
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$items = $config.items

foreach ($outputName in $items.PSObject.Properties.Name) {
    $item = $items.$outputName
    $wildcard = $item.files
    $columns = $item.columns

    Write-Host "`nProcessing $wildcard -> $outputName..."

    # Find files matching the wildcard
    $files = Get-ChildItem -Path $wildcard -File -ErrorAction SilentlyContinue
    if (-not $files) {
        Write-Warning "No files found for pattern: $wildcard"
        continue
    }

    $allRows = @()

    foreach ($file in $files) {
        Write-Host "  Reading $($file.FullName)"
        try {
            $csv = Import-Csv -Path $file.FullName
            if ($csv.Count -eq 0) { continue }

            # Keep only the columns that exist in this file and are in the desired list
            $available = $columns | Where-Object { $_ -in $csv[0].PSObject.Properties.Name }

            if (-not $available) {
                Write-Warning "  No matching columns found in $($file.Name)"
                continue
            }

            # Select in correct order
            $processed = $csv | Select-Object $available
            $allRows += $processed
        }
        catch {
            Write-Warning "  Failed to process $($file.FullName): $_"
        }
    }

    if ($allRows.Count -gt 0) {
        Write-Host "  Writing output: $outputName"
        $allRows | Export-Csv -Path $outputName -NoTypeInformation -Force
    } else {
        Write-Warning "No valid rows to export for $outputName"
    }
}

Write-Host "`nProcessing complete."
