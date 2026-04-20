param (
    [string]$InputPath,
    [string]$OutputPath
)

if (Test-Path -LiteralPath $InputPath) {
    $txt = Get-Content -LiteralPath $InputPath -Raw
    
    # Split by period
    $sentences = $txt -split '\.'  -split '\,'
    $result = foreach($s in $sentences){ 
        # Remove characters like * or : that break FFmpeg filters
        $clean = $s.Trim() -replace '[\r\n]+', ' ' -replace '[;*:]', '' -replace "[\r\n]+", " "
        if($clean){ '$result |' + $clean + '.|' + $clean + '.' } 
    }
    
    $result | Out-File -LiteralPath $OutputPath -Encoding utf8
} else {
    exit 1
}