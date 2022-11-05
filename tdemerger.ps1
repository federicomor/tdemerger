#! pwsh

# Comando per l'esecuzione:
# Powershell.exe -executionpolicy remotesigned -File  .\tdemerger.ps1

# Per ulteriori dubbi leggere il file readme.md

if(Test-Path tde.tex){
	Remove-Item tde.tex
}

$info = "
Ciao!
Questo e' uno script per unire temi d'esame, dispense, esercitazioni, ecc in un unico pdf indicizzato, grazie a LaTex, in modo da avere un unico file con dei collegamenti ai diversi singoli file, per accedervi in modo veloce ed efficiente.
Cosi' si ha tutto in un solo file ordinato e si evita di dover balzare tra diversi file.
Cominciamo.
"
$info

$name = Read-Host -Prompt "Nome del file? "
$titolo = Read-Host -Prompt "Titolo? "
$risp = Read-Host -Prompt "Hai gia' i pdf? (si/s/no/n) "


if ( $risp -eq "no" -Or $risp -eq "n"){
	$url = Read-Host -Prompt "Url da cui scaricarli? "

	# Url d'esempio/test
	# https://staff.polito.it/sergio.lancelotti/didattica/analisi2_new/analisi2_new_temi.html
	# https://staff.polito.it/sergio.lancelotti/didattica/analisi2_new/analisi2_new_temi_aa16-17.html
	# https://people.unica.it/alessiofilippetti/didattica/materiale-didattico/archivio-prove-desame-fisica-2/
	# https://www.mat.uniroma2.it/~tauraso/analisi1ing1920.html

	try {
		echo "Tentativo 1: "
		$psPage = Invoke-WebRequest $url
		$urls = $psPage.ParsedHtml.getElementsByTagName("A") | ? {$_.href -like "*.pdf"} | Select-Object -ExpandProperty href
		$urls | ForEach-Object {Invoke-WebRequest -Uri $_ -OutFile ($_ | Split-Path -Leaf)}
	}
	catch{
		Write-Host "An error occurred:"
		Write-Host $_
	}
	try {
		echo "Tentativo 2: "
		$r1 = $psPage = Invoke-WebRequest $url 
		$urls = $r1.Links | Where-Object {$_.href -like "*.pdf"} | Select-Object -ExpandProperty href
		$url_pre = $url -replace "[a-z0-9-_]*\.[a-z]*$",""
		# $url_suff = $urls -replace "^[a-z0-9-_]*\/",""
		$urls | ForEach-Object {Invoke-WebRequest -Uri "$url_pre$_" -OutFile ($_ | Split-Path -Leaf)}
		# $urls | ForEach-Object {echo "$url_pre$_" }
	}
	catch{
		Write-Host "An error occurred:"
		Write-Host $_
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
\usepackage{geometry}

%comando definitivo :)
\newcommand{\addtde}[1]{%
	\pdfximage{#1} %prepara il pdf per il conteggio delle pagine
	\ifthenelse{\the\pdflastximagepages > 1 }% caso con più di 1 pagina:
		{\includepdf[pages=1,pagecommand=\section{#1} \thispagestyle{empty}, scale=0.9, offset=0 -1.2cm]{#1}
		\includepdf[pages=2-,pagecommand={\thispagestyle{empty}}]{#1}}% caso con solo una pagina:
		{\includepdf[pages=1,pagecommand=\section{#1} \thispagestyle{empty}, scale=0.9, offset=0 -1.2cm]{#1}}
}

\makeindex
\begin{document}
\pagestyle{empty}
\begin{center}
\Huge{\textsc{$titolo}}
\end{center}
\newpage
\tableofcontents
\newpage
\newgeometry{lmargin=1cm,rmargin=1cm,tmargin=1cm,bmargin=1cm}"

$pre | Add-Content tde.tex

# Rimozione caratteri "scomodi" per latex, per sicurezza
gci *.pdf | Rename-Item -NewName {$_.Name -replace '_+', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '-+', '-'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace "\'", ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'à', 'a'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '(è|é)', 'e'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'ì', 'i'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'ò', 'o'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace 'ù', 'u'}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '%+', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace '\++', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace ' +', ' '}
gci *.pdf | Rename-Item -NewName {$_.Name -replace ',+', ''}

Write-Host ""
$risp = Read-Host -Prompt "Vuoi includere nel file $name.pdf tutti i pdf che ora hai in questa cartella, o vuoi selezionare a mano quali includere? (tutti/t/mano/m) "

$files = Get-ChildItem -Filter *.pdf
if ( $risp -eq "tutti" -Or $risp -eq "t"){
	foreach ($f in $files.Name) {
		$val = "\addtde{$f}"
		$val | Add-Content tde.tex
	}
}
else{
	foreach ($f in $files.Name) {
		$posso = Read-Host -Prompt "Vuoi includere $f ? (si/s/no/n) "
		if ( $posso -eq "si" -Or $posso -eq "s"){
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
Write-Host "Sto compilando ..."

# Prima compilazione
pdflatex -quiet -file-line-error -halt-on-error tde.tex
Write-Host "Ci siamo quasi ..."
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
Write-Host "Finito! Ora dovresti trovare il tuo file $name.pdf
Buono studio!"
Write-Host ""

# Resta comunque anche il file $name.tex, in caso si volesse modificare qualcosa a mano
