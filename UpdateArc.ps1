$currChecksum = "./d3d9.dll.md5sum"
$newChecksum = "./nd3d9.dll.md5sum"

function Try-Remove-Item ([String]$itemName) {
	Remove-Item($itemName) 2>$null
}	

Invoke-WebRequest -Uri 'https://www.deltaconnected.com/arcdps/x64/d3d9.dll.md5sum' -OutFile $newChecksum
if (!([System.IO.File]::Exists($currChecksum)) -or (Compare-Object -ReferenceObject $(Get-Content $currChecksum) -DifferenceObject $(Get-Content $newChecksum))) {
	"Newer version of ArcDps found, fetching..."
	Invoke-WebRequest -Uri 'https://www.deltaconnected.com/arcdps/x64/d3d9.dll' -OutFile './d3d9.dll'
	
	$md5provider = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$d3d9Hash = [System.BitConverter]::ToString($md5provider.ComputeHash([System.IO.File]::ReadAllBytes('./d3d9.dll')))
	if(Compare-Object -ReferenceObject $(Get-Content $newChecksum) -DifferenceObject $d3d9Hash) {
		"New ArcDps version installed successfully."
		Try-Remove-Item $currChecksum
		Rename-Item -Force -Path $newChecksum -NewName "d3d9.dll.md5sum"
	}
	Else {
		"New ArcDps version is corrupted..."
		Try-Remove-Item $newChecksum
		Try-Remove-Item './bin64/d3d9.dll'
	}
}
Else {
	"Current version is the latest, aborting..."
	Try-Remove-Item $newChecksum
}

Start-Process -FilePath "./Gw2-64.exe"

