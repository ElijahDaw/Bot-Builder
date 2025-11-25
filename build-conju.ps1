# Downloads repo zip, builds, copies exe to Downloads, cleans temp
$drop    = "$env:USERPROFILE\Downloads"
$repoZip = $env:REPO_ZIP
if (-not $repoZip) { $repoZip = "https://github.com/ElijahDaw/Gui/archive/refs/heads/main.zip" }
$repoUrl = $env:REPO_URL
if (-not $repoUrl) { $repoUrl = "https://github.com/ElijahDaw/Gui.git" }

$tmp = Join-Path $env:TEMP "cbb-build"
$zip = Join-Path $tmp "src.zip"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
  $headers = @{}
  if ($env:GITHUB_TOKEN) { $headers["Authorization"] = "Bearer $($env:GITHUB_TOKEN)" }
  Invoke-WebRequest $repoZip -OutFile $zip -Headers $headers -ErrorAction Stop
  Expand-Archive $zip -DestinationPath $tmp -ErrorAction Stop
  $root = Get-ChildItem $tmp -Directory | Select-Object -First 1
}
catch {
  Write-Host "Zip download failed from $repoZip; trying git clone from $repoUrl"
  git clone --depth 1 $repoUrl (Join-Path $tmp "repo")
  $root = Get-Item (Join-Path $tmp "repo")
}

# Ensure Node/npm available (download portable Node if missing)
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  $nodeVersion = "v22.11.0"
  $arch = if ([Environment]::Is64BitOperatingSystem) { "win-x64" } else { "win-x86" }
  $nodeZipUrl = "https://nodejs.org/dist/$nodeVersion/node-$nodeVersion-$arch.zip"
  $nodeZip = Join-Path $tmp "node.zip"
  Invoke-WebRequest $nodeZipUrl -OutFile $nodeZip
  Expand-Archive $nodeZip -DestinationPath $tmp
  $nodeHome = Join-Path $tmp "node-$nodeVersion-$arch"
  $env:PATH = "$nodeHome;$env:PATH"
}

# If repo root contains CuratedBuilder subdir, use it
if (Test-Path (Join-Path $root.FullName "CuratedBuilder")) {
  Push-Location (Join-Path $root.FullName "CuratedBuilder")
} else {
  Push-Location $root.FullName
}
npm install
npm run build:win
$exe = Get-ChildItem -Path "dist" -Filter "*.exe" | Select-Object -First 1
Copy-Item $exe.FullName -Destination (Join-Path $drop $exe.Name) -Force
Pop-Location

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done: $(Join-Path $drop $exe.Name)"
