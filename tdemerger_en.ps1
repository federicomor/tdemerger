#! pwsh

# Comando per l'esecuzione:
# Powershell.exe -executionpolicy remotesigned -File  .\tdemerger_en.ps1

# For any doubts read the readme_en.md

if(Test-Path tde.tex){
	Remove-Item tde.tex
}

$info = "
Hello!
This is a script to merge exams, lecture notes, exercises, etc. into a single indexed pdf, thanks to LaTex, in order to have a single file with links to different individual files, to access it quickly and efficiently.
So you have everything in one sorted file and avoid having to jump between different files.
Let's start.
"
$info

$name = Read-Host -Prompt "File name? "
$titolo = Read-Host -Prompt "Title? "
$risp = Read-Host -Prompt "Do you already have the pdfs? (yes/y/no/n) "


if ( $risp -eq "no" -Or $risp -eq "n"){
	$url = Read-Host -Prompt "Url to download them? "

	# Url d'esempio/test
	# https://staff.polito.it/sergio.lancelotti/didattica/analisi2_new/analisi2_new_temi.html
	# https://staff.polito.it/sergio.lancelotti/didattica/analisi2_new/analisi2_new_temi_aa16-17.html
	# https://people.unica.it/alessiofilippetti/didattica/materiale-didattico/archivio-prove-desame-fisica-2/
	try {
		echo "Attempt 1: "
		$psPage = Invoke-WebRequest $url
		$urls = $psPage.ParsedHtml.getElementsByTagName("A") | ? {$_.href -like "*.pdf"} | Select-Object -ExpandProperty href
		$urls | ForEach-Object {Invoke-WebRequest -Uri $_ -OutFile ($_ | Split-Path -Leaf)}
	}
	catch{
		"failed"
	}
	try {
		echo "Attempt 2: "
		$r1 = $psPage = Invoke-WebRequest $url 
		$urls = $r1.Links | Where-Object {$_.href -like "*.pdf"} | Select-Object -ExpandProperty href
		$url_pre = $url -replace "[a-z0-9-_]*\.[a-z]*$",""
		# $url_suff = $urls -replace "^[a-z0-9-_]*\/",""
		$urls | ForEach-Object {Invoke-WebRequest -Uri "$url_pre$_" -OutFile ($_ | Split-Path -Leaf)}
		# $urls | ForEach-Object {echo "$url_pre$_" }
	}
	catch{
		"failed"
	}
}

# Out-Null per sopprimere l'output
New-Item -ItemType File -Name "tde.tex" | Out-Null

# Controllare di aver installato tutti i pacchetti richiesti
# hyperref, pdfpages

$pre = "\documentclass[a4paper,openany,12pt]{article}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[utf8]{inputenc}
\usepackage[italian]{babel}
\usepackage{hyperref}
\usepackage{pdfpages}
\newcommand{\addtde}[1]{\section{#1} \newpage \includepdf[pages=-,pagecommand={\thispagestyle{empty}}]{#1}}
\makeindex
\begin{document}
\pagestyle{empty}
\begin{center}
\Huge{\textsc{$titolo}}
\end{center}
\newpage
\tableofcontents
\newpage"

$pre | Add-Content tde.tex

# Rimozione caratteri "scomodi" per latex, per sicurezza
gci *.pdf | Rename-Item -NewName {$_.Name -replace '_+', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '-+', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'à', 'a'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '(è|é)', 'e'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'ì', 'i'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'ò', 'o'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'ù', 'u'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '%+', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '\++', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace ' +', ' '}


Write-Host ""
$risp = Read-Host -Prompt "Do you want to include into $name.pdf all the pdfs you have in this folder, or do you prefer to select only some of them? (all/a/select/s) "

$files = Get-ChildItem -Filter *.pdf
if ( $risp -eq "all" -Or $risp -eq "a"){
	foreach ($f in $files.Name) {
		$val = "\addtde{$f}"
		$val | Add-Content tde.tex
	}
}
else{
	foreach ($f in $files.Name) {
		$posso = Read-Host -Prompt "Do you want to include $f ? (yes/y/no/n) "
		if ( $posso -eq "yes" -Or $posso -eq "y"){
			$val = "\addtde{$f}"
			$val | Add-Content tde.tex
		}
	}
}

# Inserimento della fine del documento
$end = "\end{document}" 
$end | Add-Content tde.tex

# Decommentare per vedere il contenuto del file
# gc tde.tex

Write-Host ""
Write-Host "I am compiling ..."

# Prima compilazione
pdflatex -quiet -file-line-error -halt-on-error tde.tex
# Seconda compilazione
pdflatex -quiet -file-line-error -halt-on-error tde.tex
# Doppia compilazione perche' serve per creare i collegamenti ai pdf

# Rimozione file ausiliari
rm tde.aux
rm tde.idx
rm tde.out
rm tde.toc
rm tde.log

$fileout ="$name.tex"
Rename-Item tde.tex -NewName $fileout


$fileout ="$name.pdf"
Rename-Item tde.pdf -NewName $fileout

Write-Host ""
Write-Host "Finished! Now you should have the file $name.pdf"
Write-Host ""

# Resta comunque anche il file $name.tex, in caso si volesse modificare qualcosa a mano
