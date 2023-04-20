function ll {
	ls -ltr
}

function gs {
	git status -u $args
}

function listfonts {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
  (New-Object System.Drawing.Text.InstalledFontCollection).Families
}
