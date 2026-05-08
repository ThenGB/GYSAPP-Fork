$cmake = $args[0]
$cmakeArgs = @()
if ($args.Count -gt 1) {
  $cmakeArgs = $args[1..($args.Count - 1)]
}

if ($cmakeArgs.Count -gt 0 -and ($cmakeArgs[0] -eq '--build' -or $cmakeArgs[0] -eq '-E')) {
  & $cmake @cmakeArgs
} else {
  & $cmake -Wno-deprecated -Wno-dev @cmakeArgs
}

exit $LASTEXITCODE
